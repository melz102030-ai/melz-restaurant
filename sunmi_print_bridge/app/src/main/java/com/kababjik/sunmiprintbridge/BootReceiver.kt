package com.kababjik.sunmiprintbridge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/** يعيد تشغيل خدمة جسر الطباعة تلقائياً بعد إعادة تشغيل جهاز Sunmi. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        val serviceIntent = Intent(context, PrintBridgeService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}
