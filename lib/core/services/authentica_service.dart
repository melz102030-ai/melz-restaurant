import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';

class OtpRateLimitException implements Exception {
  final int retryAfter; // ثواني
  OtpRateLimitException(this.retryAfter);

  @override
  String toString() {
    final m = retryAfter ~/ 60;
    return m > 0 ? 'انتظر $m دقيقة قبل إعادة الإرسال' : 'انتظر $retryAfter ثانية قبل إعادة الإرسال';
  }
}

class AuthenticaService {
  static Map<String, String> get _headers => {'Content-Type': 'application/json'};

  /// يحوّل أشكال أرقام الجوال السعودية إلى صيغة E.164 الدولية
  static String normalizePhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (phone.startsWith('05') && phone.length == 10) return '+966${phone.substring(1)}';
    if (phone.startsWith('5') && phone.length == 9) return '+966$phone';
    if (phone.startsWith('966') && !phone.startsWith('+')) return '+$phone';
    return phone;
  }

  /// يُرسل OTP ويُعيد عدد الثواني قبل السماح بالإرسال التالي.
  /// يرمي [OtpRateLimitException] إذا كان الإرسال مقيّداً بعد وقت.
  static Future<int> sendOtp(String phone) async {
    final normalized = normalizePhone(phone);
    final res = await http.post(
      Uri.parse('$kWorkerUrl/otp/send'),
      headers: _headers,
      body: jsonEncode({'phone': normalized}),
    );
    if (res.statusCode == 429) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      throw OtpRateLimitException((data['retryAfter'] as num?)?.toInt() ?? 1800);
    }
    if (res.statusCode == 503) throw Exception('خدمة التحقق غير متاحة حالياً');
    if (res.statusCode != 200) throw Exception('فشل إرسال رمز التحقق');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['ok'] != true) throw Exception('فشل إرسال رمز التحقق');
    return (data['retryAfter'] as num?)?.toInt() ?? 60;
  }

  /// يُعيد true إذا كان الرمز صحيحاً، false إذا كان خاطئاً
  static Future<bool> verifyOtp(String phone, String otp) async {
    final normalized = normalizePhone(phone);
    final res = await http.post(
      Uri.parse('$kWorkerUrl/otp/verify'),
      headers: _headers,
      body: jsonEncode({'phone': normalized, 'otp': otp}),
    );
    if (res.statusCode >= 500) throw Exception('خطأ في الاتصال بخدمة التحقق');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['verified'] == true;
  }
}
