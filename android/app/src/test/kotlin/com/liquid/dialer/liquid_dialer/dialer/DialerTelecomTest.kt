package com.liquid.dialer.liquid_dialer.dialer

import android.telecom.Call
import android.telecom.CallAudioState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Unit tests verifying native Kotlin Telecom components:
 * - Phone number sanitization and validation
 * - USSD and international telephone pattern support
 * - Outgoing call result data model and map transformations
 * - Call state mapping and audio route bitmask decoding
 * - TelecomCallManager error handling and safe fallbacks
 */
class DialerTelecomTest {

    @Test
    fun testSanitizePhoneNumberStripsNonDialableCharacters() {
        val raw = "(555) 123-4567 Ext. 89"
        val sanitized = DialIntentHandler.sanitizePhoneNumber(raw)
        assertEquals("555123456789", sanitized)
    }

    @Test
    fun testSanitizePhoneNumberPreservesInternationalPlusAndDialerSymbols() {
        val raw = "+1 (800) 555-0199"
        val sanitized = DialIntentHandler.sanitizePhoneNumber(raw)
        assertEquals("+18005550199", sanitized)

        val ussd = "*#06#"
        val sanitizedUssd = DialIntentHandler.sanitizePhoneNumber(ussd)
        assertEquals("*#06#", sanitizedUssd)
    }

    @Test
    fun testSanitizeNullAndEmptyString() {
        assertEquals("", DialIntentHandler.sanitizePhoneNumber(null))
        assertEquals("", DialIntentHandler.sanitizePhoneNumber(""))
        assertEquals("", DialIntentHandler.sanitizePhoneNumber("    "))
    }

    @Test
    fun testIsValidPhoneNumberValidatesStandardAndInternational() {
        assertTrue(DialIntentHandler.isValidPhoneNumber("1234567"))
        assertTrue(DialIntentHandler.isValidPhoneNumber("+15551234567"))
        assertTrue(DialIntentHandler.isValidPhoneNumber("+919876543210"))
        assertTrue(DialIntentHandler.isValidPhoneNumber("911"))
    }

    @Test
    fun testIsValidPhoneNumberValidatesUssdCodes() {
        assertTrue(DialIntentHandler.isValidPhoneNumber("*#06#"))
        assertTrue(DialIntentHandler.isValidPhoneNumber("*123#"))
        assertTrue(DialIntentHandler.isValidPhoneNumber("#31#"))
    }

    @Test
    fun testIsValidPhoneNumberRejectsEmptyAndInvalidText() {
        assertFalse(DialIntentHandler.isValidPhoneNumber(null))
        assertFalse(DialIntentHandler.isValidPhoneNumber(""))
        assertFalse(DialIntentHandler.isValidPhoneNumber("   "))
        assertFalse(DialIntentHandler.isValidPhoneNumber("abcde"))
        assertFalse(DialIntentHandler.isValidPhoneNumber("---()"))
    }

    @Test
    fun testOutgoingCallResultSerialization() {
        val successResult = OutgoingCallResult(
            success = true,
            message = "Call initiated",
            errorCode = null
        )
        val successMap = successResult.toMap()
        assertEquals(true, successMap["success"])
        assertEquals("Call initiated", successMap["message"])
        assertEquals(null, successMap["errorCode"])

        val failureResult = OutgoingCallResult(
            success = false,
            message = "Permission denied",
            errorCode = "PERMISSION_DENIED"
        )
        val failureMap = failureResult.toMap()
        assertEquals(false, failureMap["success"])
        assertEquals("Permission denied", failureMap["message"])
        assertEquals("PERMISSION_DENIED", failureMap["errorCode"])
    }

    @Test
    fun testMapStateToString() {
        assertEquals("incoming", CallStateMapper.mapStateToString(Call.STATE_RINGING))
        assertEquals("dialing", CallStateMapper.mapStateToString(Call.STATE_DIALING))
        assertEquals("connecting", CallStateMapper.mapStateToString(Call.STATE_CONNECTING))
        assertEquals("active", CallStateMapper.mapStateToString(Call.STATE_ACTIVE))
        assertEquals("holding", CallStateMapper.mapStateToString(Call.STATE_HOLDING))
        assertEquals("disconnected", CallStateMapper.mapStateToString(Call.STATE_DISCONNECTED))
        assertEquals("disconnecting", CallStateMapper.mapStateToString(Call.STATE_DISCONNECTING))
        assertEquals("unknown", CallStateMapper.mapStateToString(999))
    }

    @Test
    fun testMapDirectionToString() {
        assertEquals("incoming", CallStateMapper.mapDirectionToString(0, Call.STATE_RINGING))
        assertEquals("outgoing", CallStateMapper.mapDirectionToString(1, Call.STATE_DIALING))
        assertEquals("incoming", CallStateMapper.mapDirectionToString(-1, Call.STATE_RINGING))
    }

    @Test
    fun testMapAudioRouteToStringAndBack() {
        assertEquals("speaker", CallStateMapper.mapAudioRouteToString(CallAudioState.ROUTE_SPEAKER))
        assertEquals("earpiece", CallStateMapper.mapAudioRouteToString(CallAudioState.ROUTE_EARPIECE))
        assertEquals("bluetooth", CallStateMapper.mapAudioRouteToString(CallAudioState.ROUTE_BLUETOOTH))
        assertEquals("wiredHeadset", CallStateMapper.mapAudioRouteToString(CallAudioState.ROUTE_WIRED_HEADSET))

        assertEquals(CallAudioState.ROUTE_SPEAKER, CallStateMapper.mapAudioRouteFromString("speaker"))
        assertEquals(CallAudioState.ROUTE_EARPIECE, CallStateMapper.mapAudioRouteFromString("earpiece"))
        assertEquals(CallAudioState.ROUTE_BLUETOOTH, CallStateMapper.mapAudioRouteFromString("bluetooth"))
        assertEquals(CallAudioState.ROUTE_WIRED_HEADSET, CallStateMapper.mapAudioRouteFromString("wiredHeadset"))
    }

    @Test
    fun testMapSupportedRoutesToList() {
        val standardMask = CallAudioState.ROUTE_EARPIECE or CallAudioState.ROUTE_SPEAKER
        val routes = CallStateMapper.mapSupportedRoutesToList(standardMask)
        assertTrue(routes.contains("earpiece"))
        assertTrue(routes.contains("speaker"))
        assertFalse(routes.contains("bluetooth"))

        val bluetoothMask = standardMask or CallAudioState.ROUTE_BLUETOOTH
        val routesWithBt = CallStateMapper.mapSupportedRoutesToList(bluetoothMask)
        assertTrue(routesWithBt.contains("bluetooth"))
    }

    @Test
    fun testTelecomCallManagerSafeFallbacksWithNoActiveCalls() {
        assertFalse(TelecomCallManager.answerCall("invalid_session"))
        assertFalse(TelecomCallManager.rejectCall("invalid_session"))
        assertFalse(TelecomCallManager.disconnectCall("invalid_session"))
        assertFalse(TelecomCallManager.holdCall("invalid_session"))
        assertFalse(TelecomCallManager.unholdCall("invalid_session"))
        assertFalse(TelecomCallManager.setMuted(true))
        assertFalse(TelecomCallManager.setAudioRoute("speaker"))

        val snapshot = TelecomCallManager.getCallSnapshot()
        assertNotNull(snapshot)

        val audioState = TelecomCallManager.getAudioRouteState()
        assertNotNull(audioState)
        assertEquals("earpiece", audioState["currentRoute"])
        assertEquals(false, audioState["isMuted"])
    }
}
