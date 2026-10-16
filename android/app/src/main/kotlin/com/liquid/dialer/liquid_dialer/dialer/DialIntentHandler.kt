package com.liquid.dialer.liquid_dialer.dialer

import android.content.Intent
import android.net.Uri

/**
 * Utility responsible for extracting, validating, and formatting telephone numbers from Android intents.
 */
object DialIntentHandler {

    /**
     * Extracts a telephone number from an incoming Intent (ACTION_DIAL or ACTION_VIEW).
     *
     * Returns null if the intent does not contain a dial payload or represents an empty dial action.
     */
    fun extractPhoneNumber(intent: Intent?): String? {
        if (intent == null) return null

        val action = intent.action
        val isDialAction = Intent.ACTION_DIAL == action ||
                Intent.ACTION_VIEW == action ||
                Intent.ACTION_CALL == action

        if (!isDialAction) return null

        val data: Uri? = intent.data
        if (data != null && "tel".equals(data.scheme, ignoreCase = true)) {
            val part = data.schemeSpecificPart
            if (!part.isNullOrBlank()) {
                val decoded = Uri.decode(part)
                return sanitizePhoneNumber(decoded)
            }
        }

        // Fallback for extras
        val extraNumber = intent.getStringExtra(Intent.EXTRA_PHONE_NUMBER)
        if (!extraNumber.isNullOrBlank()) {
            return sanitizePhoneNumber(extraNumber)
        }

        return null
    }

    /**
     * Strips non-dialable symbols and harmless whitespace while preserving +, *, and #.
     */
    fun sanitizePhoneNumber(raw: String?): String {
        if (raw == null) return ""
        // Keep valid telephone digits, leading plus, and dialer characters (*, #)
        return raw.filter { char ->
            char.isDigit() || char == '+' || char == '*' || char == '#' || char == ',' || char == ';'
        }
    }

    /**
     * Validates whether an input represents a callable phone number.
     *
     * Requires at least one dialable character, digits, or USSD syntax.
     */
    fun isValidPhoneNumber(raw: String?): Boolean {
        val sanitized = sanitizePhoneNumber(raw)
        if (sanitized.isBlank()) return false

        // Check if contains at least one digit or valid USSD format
        val hasDigit = sanitized.any { it.isDigit() }
        val isUssd = (sanitized.startsWith("*") || sanitized.startsWith("#")) && sanitized.length >= 2

        return hasDigit || isUssd
    }

    /**
     * Constructs a safe standard tel: URI for Android Telecom.
     */
    fun createTelUri(phoneNumber: String): Uri {
        val clean = sanitizePhoneNumber(phoneNumber)
        return Uri.fromParts("tel", clean, null)
    }
}
