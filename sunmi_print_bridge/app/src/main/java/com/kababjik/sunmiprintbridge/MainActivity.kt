package com.kababjik.sunmiprintbridge

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Base64
import android.view.Gravity
import android.widget.TextView
import woyou.aidlservice.jiuiv5.IWoyouService

/**
 * جسر مرافق صغير جداً — أندرويد أصلي خالص، بلا فلاتر إطلاقاً، بلا أي
 * محرك واجهة ثقيل — يستقبل رابط sunmiprint://print?data=<base64> من
 * متصفح كروم (تطبيق Meals، نسخة kitchen-lite على /k/)، يطبع النص مباشرة
 * عبر خدمة طابعة Sunmi الداخلية (woyou.aidlservice.jiuiv5)، ثم يغلق
 * نفسه فوراً ويعيد التركيز لكروم.
 *
 * السطر الأول من النص المُستقبَل يُفترض دائماً اسم المطعم (راجع
 * buildReceiptPlainText في web_kitchen_lite/app.js) — يُطبع وسط الصفحة
 * بحجم أكبر، وبقية الأسطر محاذاة يمين بحجم عادي. "البولد" يُرسَل كأمر
 * ESC/POS خام (sendRAWData) قبل كل سطر وبعده — الواجهة الرسمية
 * (IWoyouService) لا تملك دالة بولد مباشرة.
 */
class MainActivity : Activity() {

    private var printerService: IWoyouService? = null
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var statusView: TextView
    private var finished = false

    private val boldOn = byteArrayOf(0x1B, 0x45, 0x01)
    private val boldOff = byteArrayOf(0x1B, 0x45, 0x00)

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            printerService = IWoyouService.Stub.asInterface(binder)
            doPrint()
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            printerService = null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        statusView = TextView(this).apply {
            text = "جارٍ الطباعة..."
            setTextColor(Color.WHITE)
            textSize = 18f
            gravity = Gravity.CENTER
        }
        setContentView(statusView)

        val serviceIntent = Intent("woyou.aidlservice.jiuiv5.IWoyouService")
        serviceIntent.setPackage("woyou.aidlservice.jiuiv5")
        val bound = try {
            bindService(serviceIntent, connection, Context.BIND_AUTO_CREATE)
        } catch (e: Exception) {
            false
        }
        if (!bound) {
            finishWith("تعذّر الاتصال بخدمة الطابعة — تأكد من تفعيلها على هذا الجهاز")
        }
    }

    private fun doPrint() {
        val svc = printerService
        if (svc == null) {
            finishWith("خدمة الطابعة غير متاحة")
            return
        }
        try {
            val data = intent?.data
            val raw = data?.getQueryParameter("data")
            if (raw.isNullOrEmpty()) {
                finishWith("لا توجد بيانات طباعة في الرابط")
                return
            }
            val text = String(Base64.decode(raw, Base64.DEFAULT), Charsets.UTF_8)

            var isFirstLine = true
            for (line in text.split("\n")) {
                if (line.isBlank()) {
                    svc.lineWrap(1, null)
                    continue
                }
                svc.sendRAWData(boldOn, null)
                if (isFirstLine) {
                    svc.setAlignment(1, null) // 1 = وسط
                    svc.setFontSize(38f, null)
                    svc.printText(line + "\n", null)
                    isFirstLine = false
                } else {
                    svc.setAlignment(2, null) // 2 = يمين
                    svc.setFontSize(28f, null)
                    svc.printText(line + "\n", null)
                }
                svc.sendRAWData(boldOff, null)
            }
            svc.lineWrap(4, null)
            finishWith("تمت الطباعة بنجاح")
        } catch (e: Exception) {
            finishWith("فشلت الطباعة: ${e.message}")
        }
    }

    private fun finishWith(message: String) {
        statusView.text = message
        if (finished) return
        finished = true
        handler.postDelayed({
            try { unbindService(connection) } catch (e: Exception) { /* تجاهل */ }
            finishAndRemoveTask()
        }, 350)
    }

    override fun onDestroy() {
        try { unbindService(connection) } catch (e: Exception) { /* تجاهل */ }
        super.onDestroy()
    }
}
