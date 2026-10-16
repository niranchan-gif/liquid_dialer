package com.liquid.dialer.liquid_dialer.dialer

import android.os.Build
import android.telecom.Call
import android.telecom.InCallService
import android.telecom.VideoProfile
import java.util.concurrent.ConcurrentHashMap

/**
 * Authoritative manager maintaining active Telecom [Call] objects and mediating
 * actions and state broadcasts between Android Telecom and Flutter.
 */
object TelecomCallManager {

    private val calls = ConcurrentHashMap<String, Call>()
    private val callStartTimes = ConcurrentHashMap<String, Long>()
    private val callbacks = ConcurrentHashMap<String, Call.Callback>()

    var activeService: InCallService? = null

    var onCallsChangedListener: (() -> Unit)? = null
    var onAudioStateChangedListener: (() -> Unit)? = null

    /**
     * Registers a new Telecom call into the session repository.
     */
    fun registerCall(call: Call): String {
        val sessionId = generateSessionId(call)
        calls[sessionId] = call
        if (!callStartTimes.containsKey(sessionId)) {
            callStartTimes[sessionId] = System.currentTimeMillis()
        }

        val callback = object : Call.Callback() {
            override fun onStateChanged(targetCall: Call, state: Int) {
                super.onStateChanged(targetCall, state)
                onCallsChangedListener?.invoke()
            }

            override fun onDetailsChanged(targetCall: Call, details: Call.Details) {
                super.onDetailsChanged(targetCall, details)
                onCallsChangedListener?.invoke()
            }
        }

        callbacks[sessionId] = callback
        call.registerCallback(callback)

        onCallsChangedListener?.invoke()
        return sessionId
    }

    /**
     * Unregisters a removed call and cleans up listeners.
     */
    fun unregisterCall(call: Call) {
        val sessionId = generateSessionId(call)
        val cb = callbacks.remove(sessionId)
        if (cb != null) {
            try {
                call.unregisterCallback(cb)
            } catch (_: Exception) {}
        }
        calls.remove(sessionId)
        callStartTimes.remove(sessionId)

        onCallsChangedListener?.invoke()
    }

    /**
     * Resolves a Call session by ID or returns the foremost active/ringing call.
     */
    fun findCall(sessionId: String?): Call? {
        if (!sessionId.isNullOrBlank()) {
            val call = calls[sessionId]
            if (call != null) return call
        }
        // Fallback: search for incoming ringing call, then active call
        return calls.values.firstOrNull { it.state == Call.STATE_RINGING }
            ?: calls.values.firstOrNull { it.state == Call.STATE_ACTIVE }
            ?: calls.values.firstOrNull()
    }

    /**
     * Answers an incoming call.
     */
    fun answerCall(sessionId: String?): Boolean {
        val call = findCall(sessionId) ?: return false
        return try {
            call.answer(VideoProfile.STATE_AUDIO_ONLY)
            true
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Rejects an incoming call.
     */
    fun rejectCall(sessionId: String?): Boolean {
        val call = findCall(sessionId) ?: return false
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                call.reject(Call.REJECT_REASON_DECLINED)
            } else {
                @Suppress("DEPRECATION")
                call.reject(false, null)
            }
            true
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Disconnects / terminates a call session.
     */
    fun disconnectCall(sessionId: String?): Boolean {
        val call = findCall(sessionId) ?: return false
        return try {
            call.disconnect()
            true
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Places an active call on hold.
     */
    fun holdCall(sessionId: String?): Boolean {
        val call = findCall(sessionId) ?: return false
        return try {
            call.hold()
            true
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Resumes a held call session.
     */
    fun unholdCall(sessionId: String?): Boolean {
        val call = findCall(sessionId) ?: return false
        return try {
            call.unhold()
            true
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Toggles microphone mute.
     */
    fun setMuted(muted: Boolean): Boolean {
        return AudioRouteManager.setMuted(activeService, muted)
    }

    /**
     * Changes current audio route.
     */
    fun setAudioRoute(routeName: String): Boolean {
        return AudioRouteManager.setAudioRoute(activeService, routeName)
    }

    /**
     * Serializes all currently tracked calls into a list of maps.
     */
    fun getCallSnapshot(): List<Map<String, Any?>> {
        val snapshot = mutableListOf<Map<String, Any?>>()
        for ((sessionId, call) in calls) {
            val details = call.details
            val handle = details?.handle
            val rawNumber = handle?.schemeSpecificPart ?: ""
            val displayName = details?.callerDisplayName

            val state = call.state
            val directionInt = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                details?.callDirection ?: -1
            } else {
                -1
            }

            val connectTime = if (details != null && details.connectTimeMillis > 0) {
                details.connectTimeMillis
            } else {
                callStartTimes[sessionId] ?: System.currentTimeMillis()
            }

            val disconnectReason = CallStateMapper.mapDisconnectReason(details?.disconnectCause)

            snapshot.add(
                mapOf(
                    "sessionId" to sessionId,
                    "phoneNumber" to rawNumber,
                    "displayName" to displayName,
                    "state" to CallStateMapper.mapStateToString(state),
                    "direction" to CallStateMapper.mapDirectionToString(directionInt, state),
                    "connectTimeMillis" to connectTime,
                    "disconnectReason" to disconnectReason
                )
            )
        }
        return snapshot
    }

    /**
     * Serializes current audio route and mute status.
     */
    fun getAudioRouteState(): Map<String, Any?> {
        return AudioRouteManager.getCurrentAudioRouteState(activeService)
    }

    fun hasActiveCalls(): Boolean {
        return calls.isNotEmpty()
    }

    private fun generateSessionId(call: Call): String {
        return "call_${call.hashCode()}"
    }
}
