import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// نتيجة فتح نية دفع عند لين — تُمرَّر مباشرة إلى Lean.pay() في واجهة العميل
class LeanPaymentIntent {
  final String paymentIntentId;
  final String appToken;
  const LeanPaymentIntent({required this.paymentIntentId, required this.appToken});
}

/// الطبقة الوسيطة بين تطبيق العميل و Cloudflare Worker الخاص بدفعات لين
/// (cloudflare/lean-payments) — لا سرّ من أسرار لين يمر عبر هذا التطبيق؛
/// كل ما يصل هنا هو appToken (آمن للتضمين، مصمَّم من لين لهذا الاستخدام
/// تحديداً) ومعرّف نية الدفع.
class LeanPaymentService {
  static const String _workerUrl = 'https://melz-lean-payments.melz102030.workers.dev';

  static Future<LeanPaymentIntent> createPaymentIntent(String orderId) async {
    // FirebaseAuth.instance.currentUser قد لا يكون مستعاداً بعد فور تحميل
    // التطبيق (سباق توقيت) — ننتظر أول حدث حالة مصادقة فعلي بدل الاعتماد
    // على قيمته الفورية فقط
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      user = await FirebaseAuth.instance
          .authStateChanges()
          .timeout(const Duration(seconds: 5), onTimeout: (sink) => sink.close())
          .firstWhere((u) => u != null, orElse: () => null);
    }
    if (user == null) {
      throw Exception(
          'لا توجد جلسة دخول حقيقية (Firebase Auth) — إن كنت استخدمت "دخول تجريبي سريع" '
          'فقد لا تُنشئ جلسة فعلية؛ سجّل دخولك برقم الجوال وكلمة المرور وحاول مجدداً');
    }
    // TODO تشخيصي مؤقت: للتأكد من مطابقة هوية الجلسة مع صاحب الطلب
    // ignore: avoid_print
    print(
        'Lean: uid=${user.uid} isAnonymous=${user.isAnonymous} email=${user.email}');
    final idToken = await user.getIdToken();

    final res = await http.post(
      Uri.parse(_workerUrl),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'orderId': orderId}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || data['paymentIntentId'] == null) {
      // TODO تشخيصي مؤقت: نُظهر تفاصيل رفض لين نفسها (data['detail']) بدل
      // رمز الخطأ العام فقط، للتعرّف على السبب الحقيقي من رسالة لين مباشرة
      throw Exception('${data['error']} — ${jsonEncode(data['detail'] ?? {})}');
    }

    return LeanPaymentIntent(
      paymentIntentId: data['paymentIntentId'] as String,
      appToken: data['appToken'] as String,
    );
  }
}
