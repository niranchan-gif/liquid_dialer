package com.liquid.dialer.liquid_dialer.dialer

import android.app.Activity
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telecom.TelecomManager

/**
 * Manages detection and requests for the Android Default Phone (ROLE_DIALER) role.
 */
class DialerRoleManager(private val context: Context) {

    companion object {
        const val REQUEST_CODE_ROLE_DIALER = 1001
    }

    private var pendingRoleCallback: ((Boolean) -> Unit)? = null

    /**
     * Checks if the Default Phone role is available on this system.
     */
    fun isRoleAvailable(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = context.getSystemService(Context.ROLE_SERVICE) as? RoleManager
            roleManager?.isRoleAvailable(RoleManager.ROLE_DIALER) ?: false
        } else {
            true
        }
    }

    /**
     * Checks if this application currently holds the Default Phone role.
     */
    fun isRoleHeld(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = context.getSystemService(Context.ROLE_SERVICE) as? RoleManager
            roleManager?.isRoleHeld(RoleManager.ROLE_DIALER) ?: false
        } else {
            val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as? TelecomManager
            telecomManager?.defaultDialerPackage == context.packageName
        }
    }

    /**
     * Initiates the system role-request flow.
     *
     * Invokes [callback] with true if granted, or false if denied/canceled/unsupported.
     */
    fun requestRole(activity: Activity, callback: (Boolean) -> Unit) {
        if (isRoleHeld()) {
            callback(true)
            return
        }

        if (!isRoleAvailable()) {
            callback(false)
            return
        }

        pendingRoleCallback = callback

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val roleManager = activity.getSystemService(Context.ROLE_SERVICE) as? RoleManager
                if (roleManager != null && roleManager.isRoleAvailable(RoleManager.ROLE_DIALER)) {
                    val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
                    activity.startActivityForResult(intent, REQUEST_CODE_ROLE_DIALER)
                } else {
                    notifyPendingCallback(false)
                }
            } else {
                @Suppress("DEPRECATION")
                val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER).apply {
                    putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, activity.packageName)
                }
                activity.startActivityForResult(intent, REQUEST_CODE_ROLE_DIALER)
            }
        } catch (e: Exception) {
            notifyPendingCallback(false)
        }
    }

    /**
     * Processes activity result from [REQUEST_CODE_ROLE_DIALER].
     */
    fun handleActivityResult(requestCode: Int, resultCode: Int): Boolean {
        if (requestCode == REQUEST_CODE_ROLE_DIALER) {
            // Re-verify with Android OS whether the role is now held
            val granted = (resultCode == Activity.RESULT_OK) || isRoleHeld()
            notifyPendingCallback(granted)
            return true
        }
        return false
    }

    private fun notifyPendingCallback(granted: Boolean) {
        val cb = pendingRoleCallback
        pendingRoleCallback = null
        cb?.invoke(granted)
    }
}
