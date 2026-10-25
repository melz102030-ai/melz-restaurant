package com.kababjik.sunmiprintbridge

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.widget.TextView

/**
 * الآن مجرد شاشة تشغيل بسيطة — كل منطق الطباعة الفعلي انتقل إلى
 * PrintBridgeService (خدمة خلفية دائمة + خادم HTTP محلي)، راجع التعليق
 * هناك لتفاصيل سبب هذا التغيير. هذه الشاشة فقط تبدأ الخدمة وتعرض حالتها؛
 * يمكن إغلاقها بعد ذلك بأمان لأن الخدمة تستمر بالعمل في الخلفية، وتُعاد
 * تلقائياً بعد إعادة تشغيل الجهاز (راجع BootReceiver).
 */
class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val view = TextView(this).apply {
            text = "جسر الطباعة يعمل في الخلفية\n\nيمكنك إغلاق هذا التطبيق الآن —\nسيستمر العمل تلقائياً"
            setTextColor(Color.WHITE)
            textSize = 18f
            gravity = Gravity.CENTER
        }
        setContentView(view)

        val intent = Intent(this, PrintBridgeService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
}
