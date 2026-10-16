package com.liquid.dialer.liquid_dialer.dialer

import android.telecom.CallAudioState
import android.telecom.InCallService

/**
 * Manages audio routing and microphone mute operations through the active [InCallService].
 */
object AudioRouteManager {

    /**
     * Serializes the current audio route, mute state, and supported routes from [InCallService].
     */
    fun getCurrentAudioRouteState(service: InCallService?): Map<String, Any?> {
        val audioState = service?.callAudioState
        if (audioState == null) {
            return mapOf(
                "currentRoute" to "earpiece",
                "isMuted" to false,
                "supportedRoutes" to listOf("earpiece", "speaker")
            )
        }

        return mapOf(
            "currentRoute" to CallStateMapper.mapAudioRouteToString(audioState.route),
            "isMuted" to audioState.isMuted,
            "supportedRoutes" to CallStateMapper.mapSupportedRoutesToList(audioState.supportedRouteMask)
        )
    }

    /**
     * Changes the audio route (earpiece, speaker, bluetooth, wired headset).
     */
    fun setAudioRoute(service: InCallService?, routeName: String): Boolean {
        if (service == null) return false
        val nativeRoute = CallStateMapper.mapAudioRouteFromString(routeName)
        return try {
            service.setAudioRoute(nativeRoute)
            true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Toggles microphone mute state in the Telecom subsystem.
     */
    fun setMuted(service: InCallService?, muted: Boolean): Boolean {
        if (service == null) return false
        return try {
            service.setMuted(muted)
            true
        } catch (e: Exception) {
            false
        }
    }
}
