package com.liquid.dialer.liquid_dialer.dialer

import android.telecom.Call
import android.telecom.CallAudioState
import android.telecom.DisconnectCause

/**
 * Pure mapping utility converting native Android Telecom states, disconnect causes,
 * and audio routes to normalized string representations for Flutter event communication.
 */
object CallStateMapper {

    /**
     * Converts native [Call.STATE_*] integers to normalized string constants.
     */
    fun mapStateToString(state: Int): String {
        return when (state) {
            Call.STATE_RINGING -> "incoming"
            Call.STATE_DIALING -> "dialing"
            Call.STATE_CONNECTING -> "connecting"
            Call.STATE_ACTIVE -> "active"
            Call.STATE_HOLDING -> "holding"
            Call.STATE_DISCONNECTED -> "disconnected"
            Call.STATE_DISCONNECTING -> "disconnecting"
            Call.STATE_SELECT_PHONE_ACCOUNT -> "connecting"
            Call.STATE_NEW -> "connecting"
            else -> "unknown"
        }
    }

    /**
     * Converts call direction to string constant ("incoming" vs "outgoing").
     */
    fun mapDirectionToString(direction: Int, state: Int): String {
        if (state == Call.STATE_RINGING) return "incoming"
        return when (direction) {
            0 -> "incoming" // Call.Details.DIRECTION_INCOMING
            1 -> "outgoing" // Call.Details.DIRECTION_OUTGOING
            else -> if (state == Call.STATE_DIALING || state == Call.STATE_CONNECTING) "outgoing" else "incoming"
        }
    }

    /**
     * Maps native [CallAudioState.ROUTE_*] integer to route string constant.
     */
    fun mapAudioRouteToString(route: Int): String {
        return when (route) {
            CallAudioState.ROUTE_SPEAKER -> "speaker"
            CallAudioState.ROUTE_BLUETOOTH -> "bluetooth"
            CallAudioState.ROUTE_WIRED_HEADSET -> "wiredHeadset"
            CallAudioState.ROUTE_EARPIECE -> "earpiece"
            else -> "earpiece"
        }
    }

    /**
     * Converts string representation back to native [CallAudioState.ROUTE_*] integer.
     */
    fun mapAudioRouteFromString(name: String): Int {
        return when (name.lowercase()) {
            "speaker" -> CallAudioState.ROUTE_SPEAKER
            "bluetooth" -> CallAudioState.ROUTE_BLUETOOTH
            "wiredheadset" -> CallAudioState.ROUTE_WIRED_HEADSET
            "earpiece" -> CallAudioState.ROUTE_EARPIECE
            else -> CallAudioState.ROUTE_EARPIECE
        }
    }

    /**
     * Evaluates bitmask of available routes on the device.
     */
    fun mapSupportedRoutesToList(mask: Int): List<String> {
        val routes = mutableListOf<String>()
        if ((mask and CallAudioState.ROUTE_EARPIECE) != 0) {
            routes.add("earpiece")
        }
        if ((mask and CallAudioState.ROUTE_SPEAKER) != 0) {
            routes.add("speaker")
        }
        if ((mask and CallAudioState.ROUTE_WIRED_HEADSET) != 0) {
            routes.add("wiredHeadset")
        }
        if ((mask and CallAudioState.ROUTE_BLUETOOTH) != 0) {
            routes.add("bluetooth")
        }
        if (routes.isEmpty()) {
            routes.add("earpiece")
        }
        return routes
    }

    /**
     * Extracts human-readable disconnect reason from DisconnectCause.
     */
    fun mapDisconnectReason(cause: DisconnectCause?): String? {
        if (cause == null) return null
        return when (cause.code) {
            DisconnectCause.LOCAL -> "Call ended"
            DisconnectCause.REMOTE -> "Call ended by remote party"
            DisconnectCause.REJECTED -> "Call declined"
            DisconnectCause.MISSED -> "Missed call"
            DisconnectCause.BUSY -> "Line busy"
            DisconnectCause.ERROR -> "Call failed"
            DisconnectCause.CANCELED -> "Call canceled"
            else -> cause.description?.toString() ?: "Call ended"
        }
    }
}
