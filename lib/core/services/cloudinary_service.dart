import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dwbzohzt9';
  static const String uploadPreset = 'melz_upload';
  static const String folder = 'melz_restaurant';

  // رابط Cloudflare Worker الذي ينفّذ الحذف الموقّع (cloudflare/worker.js) —
  // هذا رابط مؤقت غير حقيقي بعد؛ يُستبدَل بالرابط الفعلي الذي يطبعه أول
  // نشر ناجح عبر: npx wrangler deploy (داخل مجلد cloudflare/)، أو من سجلّ
  // GitHub Actions إن نُشر عبر .github/workflows/deploy-cloudflare-worker.yml
  static const String _deleteWorkerUrl =
      'https://REPLACE_AFTER_FIRST_DEPLOY.workers.dev';

  static Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final nameWithoutExt = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    final safeId = '${DateTime.now().millisecondsSinceEpoch}_'
        '${nameWithoutExt.replaceAll(RegExp(r'[^\w\-]'), '_')}';

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..fields['public_id'] = safeId
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return json['secure_url'] as String?;
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
