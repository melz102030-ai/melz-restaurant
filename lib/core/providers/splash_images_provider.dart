import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/splash_image_service.dart';

// روابط صور كولاج الخلفية النشطة — يشترك فيها كولاج شاشة الدخول/إنشاء الحساب
final activeSplashImagesProvider = StreamProvider<List<String>>((ref) {
  return SplashImageService.streamActiveImageUrls();
});
