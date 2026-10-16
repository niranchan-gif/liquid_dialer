package com.liquid.dialer.liquid_dialer.dialer

import android.content.Intent
import android.telecom.Call
import android.telecom.CallAudioState
import android.telecom.InCallService
import com.liquid.dialer.liquid_dialer.MainActivity

/**
 * Native InCallService managing Android Telecom call lifecycles, incoming call presentations,
 * audio routing states, and active call event dispatching.
 */
class LiquidInCallService : InCallService() {

    companion object {
        var currentCall: Call? = null
            private set

        var callStateListener: ((Int) -> Unit)? = null

        /**
         * Backward-compatible helper to disconnect the active call.
         */
        fun disconnectActiveCall() {
            TelecomCallManager.disconnectCall(null)
        }

        /**
         * Backward-compatible helper to answer an incoming audio call.
         */
        fun answerActiveCall() {
            TelecomCallManager.answerCall(null)
        }
    }

    override fun onCreate() {
        super.onCreate()
        TelecomCallManager.activeService = this
    }

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)
        currentCall = call

        val sessionId = TelecomCallManager.registerCall(call)
        callStateListener?.invoke(call.state)

        // If the call is an incoming ringing call, present notification & full-screen UI
        if (call.state == Call.STATE_RINGING) {
            val details = call.details
            val handle = details?.handle
            val rawNumber = handle?.schemeSpecificPart ?: ""
            val displayName = details?.callerDisplayName

            IncomingCallNotificationManager.showIncomingCallNotification(
                this,
                sessionId,
                rawNumber,
                displayName
            )
        }
    }

    override fun onCallRemoved(call: Call) {
        if (currentCall == call) {
            currentCall = null
        }
        IncomingCallNotificationManager.cancelIncomingCallNotification(this)
        TelecomCallManager.unregisterCall(call)
        callStateListener?.invoke(Call.STATE_DISCONNECTED)

        super.onCallRemoved(call)
    }

    override fun onCallAudioStateChanged(audioState: CallAudioState) {
        super.onCallAudioStateChanged(audioState)
        TelecomCallManager.onAudioStateChangedListener?.invoke()
    }

    override fun onBringToForeground(showDialpad: Boolean) {
        super.onBringToForeground(showDialpad)
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(intent)
    }

    override fun onDestroy() {
        TelecomCallManager.activeService = null
        currentCall = null
        super.onDestroy()
    }
}
