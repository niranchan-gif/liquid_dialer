package com.liquid.dialer.liquid_dialer.dialer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.liquid.dialer.liquid_dialer.MainActivity

/**
 * Manages native Android incoming-call notification presentation with full-screen intent,
 * lock-screen visibility, and direct Answer / Reject actions.
 */
object IncomingCallNotificationManager {

    const val CHANNEL_ID = "liquid_dialer_incoming_call_channel"
    private const val CHANNEL_NAME = "Incoming Calls"
    private const val NOTIFICATION_ID = 4001

    const val ACTION_ANSWER = "com.liquid.dialer.ACTION_ANSWER"
    const val ACTION_REJECT = "com.liquid.dialer.ACTION_REJECT"
    const val ACTION_INCOMING_CALL = "com.liquid.dialer.ACTION_INCOMING_CALL"
    const val EXTRA_SESSION_ID = "extra_session_id"

    /**
     * Creates high-priority notification channel for incoming calls on Android 8.0+.
     */
    fun ensureNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            if (notificationManager != null && notificationManager.getNotificationChannel(CHANNEL_ID) == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "High-priority notifications for incoming telephone calls"
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    setBypassDnd(true)
                    enableVibration(true)
                }
                notificationManager.createNotificationChannel(channel)
            }
        }
    }

    /**
     * Displays a system incoming call notification with full-screen intent and Answer/Reject buttons.
     */
    fun showIncomingCallNotification(
        context: Context,
        sessionId: String,
        phoneNumber: String,
        displayName: String?
    ) {
        ensureNotificationChannel(context)

        val callerTitle = if (!displayName.isNullOrBlank()) displayName else phoneNumber.ifBlank { "Unknown Caller" }
        val callerSubtitle = if (!displayName.isNullOrBlank() && phoneNumber.isNotBlank()) phoneNumber else "Incoming call"

        val flag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        // Tap content intent -> opens MainActivity
        val contentIntent = Intent(context, MainActivity::class.java).apply {
            action = ACTION_INCOMING_CALL
            putExtra(EXTRA_SESSION_ID, sessionId)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val contentPendingIntent = PendingIntent.getActivity(context, 1, contentIntent, flag)

        // Full screen intent for locked devices
        val fullScreenIntent = Intent(context, MainActivity::class.java).apply {
            action = ACTION_INCOMING_CALL
            putExtra(EXTRA_SESSION_ID, sessionId)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(context, 2, fullScreenIntent, flag)

        // Answer action intent
        val answerIntent = Intent(context, CallActionReceiver::class.java).apply {
            action = ACTION_ANSWER
            putExtra(EXTRA_SESSION_ID, sessionId)
        }
        val answerPendingIntent = PendingIntent.getBroadcast(context, 3, answerIntent, flag)

        // Decline action intent
        val declineIntent = Intent(context, CallActionReceiver::class.java).apply {
            action = ACTION_REJECT
            putExtra(EXTRA_SESSION_ID, sessionId)
        }
        val declinePendingIntent = PendingIntent.getBroadcast(context, 4, declineIntent, flag)

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_phone_call)
            .setContentTitle(callerTitle)
            .setContentText(callerSubtitle)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setContentIntent(contentPendingIntent)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Decline",
                declinePendingIntent
            )
            .addAction(
                android.R.drawable.ic_menu_call,
                "Answer",
                answerPendingIntent
            )

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        try {
            notificationManager?.notify(NOTIFICATION_ID, builder.build())
        } catch (_: SecurityException) {
            // Handled safely if POST_NOTIFICATIONS was denied
        }
    }

    /**
     * Cancels the active incoming-call notification.
     */
    fun cancelIncomingCallNotification(context: Context) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        try {
            notificationManager?.cancel(NOTIFICATION_ID)
        } catch (_: Exception) {}
    }
}
