package com.liquid.dialer.liquid_dialer.dialer

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.telecom.TelecomManager
import androidx.core.content.ContextCompat

/**
 * Result model representing the outcome of an outgoing call attempt.
 */
data class OutgoingCallResult(
    val success: Boolean,
    val message: String,
    val errorCode: String? = null
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "success" to success,
        "message" to message,
        "errorCode" to errorCode
    )
}

/**
 * Manages outgoing call requests via Android TelecomManager APIs.
 */
class OutgoingCallManager(
    private val context: Context,
    private val roleManager: DialerRoleManager
) {

    /**
     * Attempts to initiate an outgoing call via TelecomManager.placeCall.
     *
     * Validates input, confirms permissions/role eligibility, and constructs
     * safe extras without overriding preferred SIM configurations.
     */
    fun placeCall(phoneNumber: String): OutgoingCallResult {
        val sanitized = DialIntentHandler.sanitizePhoneNumber(phoneNumber)

        if (sanitized.isBlank()) {
            return OutgoingCallResult(
                success = false,
                message = "Please enter a phone number to call.",
                errorCode = "EMPTY_NUMBER"
            )
        }

        if (!DialIntentHandler.isValidPhoneNumber(sanitized)) {
            return OutgoingCallResult(
                success = false,
                message = "The entered number is not a valid dialable telephone number.",
                errorCode = "INVALID_NUMBER"
            )
        }

        val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as? TelecomManager
            ?: return OutgoingCallResult(
                success = false,
                message = "Android Telecom service is unavailable on this device.",
                errorCode = "TELECOM_UNAVAILABLE"
            )

        val hasCallPermission = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.CALL_PHONE
        ) == PackageManager.PERMISSION_GRANTED
        val isDefaultDialer = roleManager.isRoleHeld()

        if (!hasCallPermission && !isDefaultDialer) {
            return OutgoingCallResult(
                success = false,
                message = "Call permission not granted. Please allow Phone permissions or set Liquid Dialer as default.",
                errorCode = "PERMISSION_DENIED"
            )
        }

        val uri = DialIntentHandler.createTelUri(sanitized)
        val extras = Bundle().apply {
            putBoolean(TelecomManager.EXTRA_START_CALL_WITH_SPEAKERPHONE, false)
        }

        return try {
            telecomManager.placeCall(uri, extras)
            val feedback = if (isDefaultDialer) {
                "Outgoing call initiated."
            } else {
                "Outgoing call initiated. (Set Liquid Dialer as default phone for the full in-call screen)."
            }
            OutgoingCallResult(
                success = true,
                message = feedback,
                errorCode = null
            )
        } catch (se: SecurityException) {
            OutgoingCallResult(
                success = false,
                message = "Security exception placing call: ${se.localizedMessage ?: "Permission required"}",
                errorCode = "SECURITY_EXCEPTION"
            )
        } catch (e: Exception) {
            OutgoingCallResult(
                success = false,
                message = "Failed to place call: ${e.localizedMessage ?: "Unknown error"}",
                errorCode = "CALL_FAILED"
            )
        }
    }
}
