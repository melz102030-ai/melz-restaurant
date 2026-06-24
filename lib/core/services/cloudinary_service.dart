import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // TODO: Replace with your Cloudinary credentials
  static const String cloudName = 'dwbzohzt9';
  static const String uploadPreset = 'melz_upload';
  static const String apiKey = '';
  static const String folder = 'melz_restaurant';

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

  static Future<bool> deleteImage(String publicId) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
      );
      final response = await http.post(url, body: {
        'public_id': publicId,
        'api_key': apiKey,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
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
}
