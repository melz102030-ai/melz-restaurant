import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';

class AuthenticaService {
  static const String _base = 'https://api.authentica.sa/api/v2';

  /// يحوّل أشكال أرقام الجوال السعودية إلى صيغة E.164 الدولية
  static String normalizePhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (phone.startsWith('05') && phone.length == 10) return '+966${phone.substring(1)}';
    if (phone.startsWith('5') && phone.length == 9) return '+966$phone';
    if (phone.startsWith('966') && !phone.startsWith('+')) return '+$phone';
    return phone;
  }

  static Map<String, String> get _headers => {
        'X-Authorization': kAuthenticaKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  static Future<void> sendOtp(String phone) async {
    final normalized = normalizePhone(phone);
    final res = await http.post(
      Uri.parse('$_base/send-otp'),
      headers: _headers,
      body: jsonEncode({'method': 'sms', 'phone': normalized}),
    );
    if (res.statusCode == 401) throw Exception('مفتاح OTP غير صحيح، تواصل مع الدعم');
    if (res.statusCode != 200) throw Exception('فشل إرسال رمز التحقق (${ res.statusCode})');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['success'] != true) throw Exception('فشل إرسال رمز التحقق');
  }

  /// يُعيد true إذا كان الرمز صحيحاً، false إذا كان خاطئاً
  static Future<bool> verifyOtp(String phone, String otp) async {
    final normalized = normalizePhone(phone);
    final res = await http.post(
      Uri.parse('$_base/verify-otp'),
      headers: _headers,
      body: jsonEncode({'phone': normalized, 'otp': otp}),
    );
    if (res.statusCode == 401) throw Exception('خطأ في الاتصال بخدمة التحقق');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['status'] == true;
  }
}
