import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dwbzohzt9';

  // رابط Cloudflare Worker الذي ينفّذ الحذف الموقّع (cloudflare/worker.js)
  static const String _deleteWorkerUrl =
      'https://melz-delete-image.melz102030.workers.dev';

  // ضغط/تحسين تلقائي عبر تحويلات Cloudinary وقت العرض — لا يمسّ الملف
  // الأصلي المخزَّن إطلاقاً (رابط مختلف فقط)، فيشمل تلقائياً كل الصور
  // الموجودة حالياً وكل صورة تُرفع مستقبلاً بلا أي خطوة إضافية:
  // f_auto يختار الصيغة الأخف حسب المتصفح (WebP/AVIF بدل JPEG/PNG الثقيلة)،
  // q_auto يضغط الجودة تلقائياً بأقل فقدان ملحوظ، وwidth يمنع تنزيل صورة
  // بدقة أكبر من حجم عرضها الفعلي على الشاشة (أكبر سبب تضخّم غير ملحوظ).
  // نفس المنطق مطبَّق مسبقاً في web/index.html (دالة _cdnSmall) لشاشة
  // التحميل الأولى تحديداً — هذه النسخة لبقية التطبيق (Dart).
  static String optimized(String? url, {int? width}) {
    if (url == null || !url.contains('res.cloudinary.com') || !url.contains('/upload/')) {
      return url ?? '';
    }
    final transform = width != null ? 'f_auto,q_auto,w_$width' : 'f_auto,q_auto';
    return url.replaceFirst('/upload/', '/upload/$transform/');
  }

  // الرفع يتم من المتصفح مباشرة لكن بتوقيع من الخادم (cloudflare/worker.js)، فلا
  // يستطيع أحد الرفع على الحساب بلا صلاحية: المدير للصور، والعميل لإيصال طلبه
  static Future<Map<String, String>> _signUpload(Map<String, String> body) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('تعذّر رفع الملف، سجّل الدخول وحاول مجدداً');
    final response = await http.post(
      Uri.parse('$_deleteWorkerUrl/sign-upload'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('تعذّر رفع الملف (${response.statusCode})');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v.toString()));
  }

  static Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    final nameWithoutExt = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    final safeId = '${DateTime.now().millisecondsSinceEpoch}_'
        '${nameWithoutExt.replaceAll(RegExp(r'[^\w\-]'), '_')}';
    final uploaded = await _upload(imageBytes, fileName, {'publicId': safeId});
    return uploaded['secure_url'] as String?;
  }

  // إيصال تحويل بنكي لطلب العميل: يُخزن خاصاً، ويرجع ما يُحفظ في الطلب (صيغة الملف
  // فقط). لا تفتحه الإدارة إلا برابط مؤقت من receiptUrl
  static Future<String> uploadReceipt(
    Uint8List bytes,
    String fileName,
    String orderId,
  ) async {
    final uploaded = await _upload(bytes, fileName, {'receiptOrderId': orderId});
    return 'receipt.${uploaded['format']}';
  }

  static Future<String> receiptUrl(String orderId) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('سجّل الدخول وحاول مجدداً');
    final response = await http.post(
      Uri.parse('$_deleteWorkerUrl/receipt-url'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'orderId': orderId}),
    );
    if (response.statusCode != 200) {
      throw Exception('تعذّر فتح الإيصال (${response.statusCode})');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['url'] as String;
  }

  static Future<Map<String, dynamic>> _upload(
    Uint8List imageBytes,
    String fileName,
    Map<String, String> signBody,
  ) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final signed = await _signUpload(signBody);

    final request = http.MultipartRequest('POST', url)
      ..fields.addAll(signed)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    }

    final errorJson = jsonDecode(responseBody) as Map<String, dynamic>?;
    final msg = errorJson?['error']?['message'] ?? 'HTTP ${response.statusCode}';
    throw Exception('Cloudinary: $msg');
  }

  // Extract public_id from Cloudinary URL
  static String? extractPublicId(String? imageUrl) {
    if (imageUrl == null) return null;
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return null;
      final parts = pathSegments.sublist(uploadIndex + 2);
      final fileName = parts.last;
      final nameWithoutExt = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
      return [...parts.sublist(0, parts.length - 1), nameWithoutExt].join('/');
    } catch (e) {
      return null;
    }
  }

  // يحذف صورة من Cloudinary فعلياً عبر Cloud Function موقّعة من جهة الخادم
  // (cloudflare/worker.js) — لا يمكن تنفيذ حذف موقّع وآمن من كود العميل مباشرة
  // بلا كشف المفتاح السري لأي شخص يفتح أدوات المطوّر. تُستدعى عند استبدال أو
  // إزالة أي صورة حتى لا تبقى صور قديمة يتيمة في الحساب. فشلها لا يمنع إكمال
  // العملية الأساسية (حفظ/حذف السجل) — يُتجاهل بصمت مع إرجاع false.
  static Future<bool> deleteImage(String? imageUrl) async {
    final publicId = extractPublicId(imageUrl);
    if (publicId == null) return false;
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse(_deleteWorkerUrl),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'publicId': publicId}),
      );
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['result'] == 'ok' || data['result'] == 'not found';
    } catch (_) {
      return false;
    }
  }
}
