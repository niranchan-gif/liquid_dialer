package com.liquid.dialer.liquid_dialer

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import com.liquid.dialer.liquid_dialer.dialer.DialIntentHandler
import com.liquid.dialer.liquid_dialer.dialer.DialerRoleManager
import com.liquid.dialer.liquid_dialer.dialer.IncomingCallNotificationManager
import com.liquid.dialer.liquid_dialer.dialer.OutgoingCallManager
import com.liquid.dialer.liquid_dialer.dialer.TelecomCallManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        private const val TELECOM_CHANNEL = "com.liquid.dialer/telecom"
        private const val CALL_EVENTS_CHANNEL = "com.liquid.dialer/call_events"
    }

    private lateinit var roleManager: DialerRoleManager
    private lateinit var outgoingCallManager: OutgoingCallManager
    private var telecomChannel: MethodChannel? = null
    private var callEventChannel: EventChannel? = null
    private var callEventSink: EventChannel.EventSink? = null

    private var initialDialNumber: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        roleManager = DialerRoleManager(this)
        outgoingCallManager = OutgoingCallManager(this, roleManager)

        IncomingCallNotificationManager.ensureNotificationChannel(this)

        // Enable display over lockscreen and screen wakeup for cellular call presentations
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        // Capture initial dial intent payload if launched via tel: URI
        initialDialNumber = DialIntentHandler.extractPhoneNumber(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        telecomChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TELECOM_CHANNEL).apply {
            setMethodCallHandler(this@MainActivity)
        }

        callEventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_EVENTS_CHANNEL).apply {
            setStreamHandler(this@MainActivity)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isDefaultDialer" -> {
                result.success(roleManager.isRoleHeld())
            }
            "canRequestDefaultDialer" -> {
                result.success(roleManager.isRoleAvailable())
            }
            "requestDefaultDialer" -> {
                roleManager.requestRole(this) { granted ->
                    result.success(granted)
                }
            }
            "placeCall" -> {
                val phoneNumber = call.argument<String>("phoneNumber") ?: ""
                val callResult = outgoingCallManager.placeCall(phoneNumber)
                result.success(callResult.toMap())
            }
            "getInitialDialNumber" -> {
                val number = initialDialNumber
                initialDialNumber = null
                result.success(number)
            }
            "answerCall" -> {
                val sessionId = call.argument<String>("sessionId")
                val success = TelecomCallManager.answerCall(sessionId)
                IncomingCallNotificationManager.cancelIncomingCallNotification(this)
                result.success(success)
            }
            "rejectCall" -> {
                val sessionId = call.argument<String>("sessionId")
                val success = TelecomCallManager.rejectCall(sessionId)
                IncomingCallNotificationManager.cancelIncomingCallNotification(this)
                result.success(success)
            }
            "disconnectCall", "disconnectActiveCall" -> {
                val sessionId = call.argument<String>("sessionId")
                val success = TelecomCallManager.disconnectCall(sessionId)
                IncomingCallNotificationManager.cancelIncomingCallNotification(this)
                result.success(success)
            }
            "holdCall" -> {
                val sessionId = call.argument<String>("sessionId")
                val success = TelecomCallManager.holdCall(sessionId)
                result.success(success)
            }
            "unholdCall" -> {
                val sessionId = call.argument<String>("sessionId")
                val success = TelecomCallManager.unholdCall(sessionId)
                result.success(success)
            }
            "setMuted" -> {
                val isMuted = call.argument<Boolean>("isMuted") ?: false
                val success = TelecomCallManager.setMuted(isMuted)
                result.success(success)
            }
            "setAudioRoute" -> {
                val route = call.argument<String>("route") ?: "earpiece"
                val success = TelecomCallManager.setAudioRoute(route)
                result.success(success)
            }
            "getCallSnapshot" -> {
                val snapshot = mapOf(
                    "calls" to TelecomCallManager.getCallSnapshot(),
                    "audioState" to TelecomCallManager.getAudioRouteState()
                )
                result.success(snapshot)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        callEventSink = events

        // Emit current state snapshot immediately upon connection
        sendCallUpdateEvent("initial_snapshot")

        TelecomCallManager.onCallsChangedListener = {
            runOnUiThread {
                sendCallUpdateEvent("calls_changed")
            }
        }

        TelecomCallManager.onAudioStateChangedListener = {
            runOnUiThread {
                sendCallUpdateEvent("audio_changed")
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        callEventSink = null
        TelecomCallManager.onCallsChangedListener = null
        TelecomCallManager.onAudioStateChangedListener = null
    }

    private fun sendCallUpdateEvent(type: String) {
        callEventSink?.success(
            mapOf(
                "type" to type,
                "calls" to TelecomCallManager.getCallSnapshot(),
                "audioState" to TelecomCallManager.getAudioRouteState()
            )
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val number = DialIntentHandler.extractPhoneNumber(intent)
        if (!number.isNullOrBlank()) {
            telecomChannel?.invokeMethod("onDialIntent", number)
        }

        // Notify Flutter if launched from incoming call notification action
        if (IncomingCallNotificationManager.ACTION_INCOMING_CALL == intent.action) {
            sendCallUpdateEvent("incoming_intent")
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (::roleManager.isInitialized) {
            roleManager.handleActivityResult(requestCode, resultCode)
        }
    }

    override fun onDestroy() {
        telecomChannel?.setMethodCallHandler(null)
        callEventChannel?.setStreamHandler(null)
        callEventSink = null
        TelecomCallManager.onCallsChangedListener = null
        TelecomCallManager.onAudioStateChangedListener = null
        super.onDestroy()
    }
}
