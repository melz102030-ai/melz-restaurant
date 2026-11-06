package com.kababjik.sunmiprintbridge

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import woyou.aidlservice.jiuiv5.IWoyouService
import java.io.ByteArrayOutputStream
import java.io.InputStream
import java.io.OutputStream
import java.net.InetAddress
import java.net.ServerSocket
import java.net.Socket

/**
 * خدمة خلفية دائمة تستبدل فكرة "فتح تطبيق منفصل لكل طباعة" بالكامل.
 *
 * السبب: كل محاولة سابقة (تطبيق فلاتر، ثم تطبيق أندرويد أصلي يُفتح عبر
 * رابط sunmiprint://) كانت تنقل كروم من المقدّمة للخلفية فعلياً أثناء
 * الطباعة، وعلى جهاز Sunmi V2 (أندرويد 7.1.1، ~890 ميغا رام فقط) كان
 * النظام يقتل عملية كروم في الخلفية لتحرير الذاكرة، فتعود صفحة المطبخ
 * بعد الطباعة بصفحة تحميل كاملة من جديد (فقدان الحالة). هذا يحدث بغض
 * النظر عن خفّة التطبيق الذي يُفتَح، لأن المشكلة هي "مغادرة كروم للمقدّمة"
 * نفسها، لا ثقل التطبيق الآخر.
 *
 * الحل: هذه الخدمة تفتح خادم HTTP محلي صغير جداً على 127.0.0.1:9898،
 * وصفحة /k/ (راجع web_kitchen_lite/app.js) ترسل الفاتورة إليه عبر fetch()
 * عادي من داخل الصفحة نفسها — كروم لا يغادر المقدّمة إطلاقاً، فلا يُقتَل،
 * فلا تُعاد الصفحة من جديد. المتصفحات الحديثة تعامل 127.0.0.1 كـ"سياق
 * آمن" حتى من صفحة HTTPS، فلا مشكلة محتوى مختلط (mixed content).
 */
class PrintBridgeService : Service() {

    companion object {
        const val PORT = 9898
        private const val CHANNEL_ID = "print_bridge"
        private const val NOTIF_ID = 1
    }

    private var printerService: IWoyouService? = null
    private var serverSocket: ServerSocket? = null
    @Volatile private var running = false

    private var lastPrintedData: String? = null
    private var lastPrintedAt: Long = 0

    private val boldOn = byteArrayOf(0x1B, 0x45, 0x01, 0x1B, 0x47, 0x01)
    private val boldOff = byteArrayOf(0x1B, 0x45, 0x00, 0x1B, 0x47, 0x00)

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            printerService = IWoyouService.Stub.asInterface(binder)
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            printerService = null
        }
    }

    override fun onCreate() {
        super.onCreate()
        startForeground(NOTIF_ID, buildNotification())
        bindPrinterService()
        startServer()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        running = false
        try { serverSocket?.close() } catch (e: Exception) { /* تجاهل */ }
        try { unbindService(connection) } catch (e: Exception) { /* تجاهل */ }
        super.onDestroy()
    }

    private fun bindPrinterService() {
        val intent = Intent("woyou.aidlservice.jiuiv5.IWoyouService")
        intent.setPackage("woyou.aidlservice.jiuiv5")
        try {
            bindService(intent, connection, Context.BIND_AUTO_CREATE)
        } catch (e: Exception) { /* سيُعاد ربطها تلقائياً عند إعادة تشغيل الخدمة */ }
    }

    private fun buildNotification(): android.app.Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mgr = getSystemService(NotificationManager::class.java)
            val channel = NotificationChannel(CHANNEL_ID, "جسر الطباعة", NotificationManager.IMPORTANCE_MIN)
            mgr.createNotificationChannel(channel)
        }
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("جسر طباعة Meals يعمل")
            .setContentText("جاهز لاستقبال أوامر الطباعة من صفحة المطبخ")
            .setSmallIcon(android.R.drawable.ic_menu_edit)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .build()
    }

    private fun startServer() {
        running = true
        Thread {
            try {
                val socket = ServerSocket(PORT, 50, InetAddress.getByName("127.0.0.1"))
                serverSocket = socket
                while (running) {
                    try {
                        val client = socket.accept()
                        Thread { handleClient(client) }.start()
                    } catch (e: Exception) {
                        if (running) { /* تجاهل أخطاء اتصال عابرة */ }
                    }
                }
            } catch (e: Exception) { /* فشل فتح المنفذ — لا شيء يمكن فعله هنا */ }
        }.start()
    }

    private fun handleClient(socket: Socket) {
        try {
            socket.soTimeout = 5000
            val input = socket.getInputStream()
            val output = socket.getOutputStream()

            val requestLine = readLine(input)
            val headers = StringBuilder()
            var contentLength = 0
            while (true) {
                val line = readLine(input) ?: break
                if (line.isEmpty()) break
                headers.append(line).append('\n')
                val lower = line.lowercase()
                if (lower.startsWith("content-length:")) {
                    contentLength = line.substringAfter(':').trim().toIntOrNull() ?: 0
                }
            }

            val method = requestLine?.split(" ")?.getOrNull(0) ?: ""
            val path = requestLine?.split(" ")?.getOrNull(1) ?: ""

            if (method == "OPTIONS") {
                writeResponse(output, 204, "", corsOnly = true)
                return
            }

            if (method == "POST" && path == "/print") {
                val bodyBytes = readExact(input, contentLength)
                val text = String(bodyBytes, Charsets.UTF_8)
                val result = tryPrint(text)
                writeResponse(output, 200, result)
                return
            }

            if (method == "GET" && path == "/ping") {
                writeResponse(output, 200, "OK")
                return
            }

            writeResponse(output, 404, "Not found")
        } catch (e: Exception) {
            /* تجاهل — لا يوجد طرف آخر بانتظار رد في حالة الخطأ المبكر */
        } finally {
            try { socket.close() } catch (e: Exception) { /* تجاهل */ }
        }
    }

    private fun tryPrint(text: String): String {
        val svc = printerService ?: return "خدمة الطابعة غير متاحة بعد — حاول خلال ثوانٍ"
        val now = System.currentTimeMillis()
        if (text == lastPrintedData && now - lastPrintedAt < 5000) {
            return "طُبعت هذه الفاتورة للتو — تم تجاهل الطلب المكرَّر"
        }
        lastPrintedData = text
        lastPrintedAt = now
        return try {
            // جرَّبنا printColumnsText لمحاذاة الصنف والسعر بسطر واحد — في كل
            // محاولة اختفى اسم الصنف بالكامل من الطباعة الفعلية (لا تحسب
            // الدالة عرض النص العربي بشكل صحيح على هذه الطابعة)، فرجعنا
            // لطباعة كل سطر نصاً عادياً فقط — الطريقة الوحيدة المؤكَّدة
            var isFirstLine = true
            for (line in text.split("\n")) {
                if (line.isBlank()) { svc.lineWrap(1, null); continue }
                if (isFirstLine) {
                    svc.setAlignment(1, null)
                    svc.setFontSize(38f, null)
                    isFirstLine = false
                } else {
                    svc.setAlignment(2, null)
                    svc.setFontSize(28f, null)
                }
                svc.sendRAWData(boldOn, null)
                svc.printText(line + "\n", null)
                svc.sendRAWData(boldOff, null)
            }
            svc.lineWrap(4, null)
            "تمت الطباعة بنجاح"
        } catch (e: Exception) {
            "فشلت الطباعة: ${e.message}"
        }
    }

    private fun readLine(input: InputStream): String? {
        val buf = ByteArrayOutputStream()
        var readAny = false
        while (true) {
            val b = input.read()
            if (b == -1) return if (readAny) buf.toString("ISO-8859-1") else null
            readAny = true
            if (b == '\n'.code) return buf.toString("ISO-8859-1")
            if (b != '\r'.code) buf.write(b)
        }
    }

    private fun readExact(input: InputStream, length: Int): ByteArray {
        if (length <= 0) return ByteArray(0)
        val out = ByteArray(length)
        var read = 0
        while (read < length) {
            val n = input.read(out, read, length - read)
            if (n == -1) break
            read += n
        }
        return out
    }

    private fun writeResponse(output: OutputStream, status: Int, body: String, corsOnly: Boolean = false) {
        val statusText = when (status) { 200 -> "OK"; 204 -> "No Content"; 404 -> "Not Found"; else -> "Error" }
        val bodyBytes = if (corsOnly) ByteArray(0) else body.toByteArray(Charsets.UTF_8)
        val headers = StringBuilder()
        headers.append("HTTP/1.1 $status $statusText\r\n")
        headers.append("Access-Control-Allow-Origin: *\r\n")
        headers.append("Access-Control-Allow-Methods: POST, GET, OPTIONS\r\n")
        headers.append("Access-Control-Allow-Headers: Content-Type\r\n")
        headers.append("Content-Type: text/plain; charset=utf-8\r\n")
        headers.append("Content-Length: ${bodyBytes.size}\r\n")
        headers.append("Connection: close\r\n\r\n")
        output.write(headers.toString().toByteArray(Charsets.ISO_8859_1))
        output.write(bodyBytes)
        output.flush()
    }
}
