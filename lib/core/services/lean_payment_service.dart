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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
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
      throw Exception(data['error'] ?? 'تعذّر فتح نافذة الدفع، حاول مجدداً');
    }

    return LeanPaymentIntent(
      paymentIntentId: data['paymentIntentId'] as String,
      appToken: data['appToken'] as String,
    );
  }
}
