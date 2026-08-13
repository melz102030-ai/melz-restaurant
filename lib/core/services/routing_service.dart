import 'dart:convert';
import 'package:http/http.dart' as http;

// يحسب مدة القيادة الفعلية عبر شبكة الطرق باستخدام خادم OSRM العام
// (بدل التقدير بالخط المستقيم) للحصول على وقت وصول أقرب للواقع.
class RoutingService {
  static const _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  // يرجع مدة القيادة بالدقائق، أو null عند فشل الطلب
  static Future<int?> drivingDurationMinutes({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/$fromLng,$fromLat;$toLng,$toLat?overview=false',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') return null;

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final durationSeconds = (routes[0]['duration'] as num).toDouble();
      return (durationSeconds / 60).ceil();
    } catch (_) {
      return null;
    }
  }
}
