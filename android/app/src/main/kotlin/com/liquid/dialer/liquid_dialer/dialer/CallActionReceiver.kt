package com.liquid.dialer.liquid_dialer.dialer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.liquid.dialer.liquid_dialer.MainActivity

/**
 * BroadcastReceiver processing Answer and Decline actions from incoming call system notifications.
 */
class CallActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return

        val sessionId = intent.getStringExtra(IncomingCallNotificationManager.EXTRA_SESSION_ID)

        when (intent.action) {
            IncomingCallNotificationManager.ACTION_ANSWER -> {
                TelecomCallManager.answerCall(sessionId)
                IncomingCallNotificationManager.cancelIncomingCallNotification(context)

                // Launch main activity to present the active call interface
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    action = IncomingCallNotificationManager.ACTION_INCOMING_CALL
                    putExtra(IncomingCallNotificationManager.EXTRA_SESSION_ID, sessionId)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                }
                context.startActivity(launchIntent)
            }
            IncomingCallNotificationManager.ACTION_REJECT -> {
                TelecomCallManager.rejectCall(sessionId)
                IncomingCallNotificationManager.cancelIncomingCallNotification(context)
            }
        }
    }
}
