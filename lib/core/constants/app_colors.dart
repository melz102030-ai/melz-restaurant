import 'package:flutter/material.dart';
import '../models/app_theme_settings.dart';

// ألوان قابلة للتغيير من لوحة تحكم الأدمن (المظهر) — راجع AppThemeSettings/AppThemeService.
// القيم الافتراضية هنا تُستخدم قبل وصول الإعدادات من Firestore ولا تُعتبر ثوابت نهائية.
class AppColors {
  // Primary Colors - ألوان المطعم (قابلة للتخصيص)
  static Color purple = const Color(0xFF6A0DAD);
  static Color purpleLight = const Color(0xFF9C4DCA);
  static Color purpleDark = const Color(0xFF4A0080);

  static Color manjawi = const Color(0xFF800040); // المنجاوي
  static Color manjawiLight = const Color(0xFFB0005A);
  static Color manjawiDark = const Color(0xFF560028);

  static const Color red = Color(0xFFCC1100);
  static const Color redLight = Color(0xFFFF4433);
  static const Color redDark = Color(0xFF8B0000);

  // Background Colors (قابلة للتخصيص) — عائلة بيج دافئة موحّدة افتراضياً
  static Color background = const Color(0xFFF5EEDC);
  static Color surface = const Color(0xFFFFFFFF);
  static Color surfaceLight = const Color(0xFFEADFC8);
  static Color cardBackground = const Color(0xFFFFFFFF);

  // خلفية وحدود مربعات الكتابة — قابلة للتخصيص المباشر من لوحة المظهر، لا
  // تُشتق من لون الخلفية تلقائياً كما كان معمولاً به سابقاً
  static Color inputField = const Color(0xFFEADFC8);
  static Color inputFieldBorder = const Color(0xFFEADFC8);

  // Text Colors (قابلة للتخصيص)
  static Color textPrimary = const Color(0xFF1A0030);
  static Color textSecondary = const Color(0xFF5B4A75);
  static Color textHint = const Color(0xFF9B8BAD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Order Status Colors
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusConfirmed = Color(0xFF2196F3);
  static const Color statusPreparing = Color(0xFF9C4DCA);
  static const Color statusReady = Color(0xFF4CAF50);
  static const Color statusOutForDelivery = Color(0xFF00838F);
  static const Color statusDelivered = Color(0xFF1B5E20);
  static const Color statusCancelled = Color(0xFFF44336);

  // Gradient (getters — تُعاد حسابها من القيم الحالية في كل استخدام)
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [purpleDark, manjawi],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get cardGradient => LinearGradient(
        colors: [background, surface],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get heroGradient => LinearGradient(
        colors: [purpleDark, manjawi, manjawiDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // يُستدعى عند تحميل/تحديث إعدادات المظهر من الأدمن — يعيد حساب كل الدرجات المشتقة
  static void applyTheme(AppThemeSettings settings) {
    purple = Color(settings.primaryColor);
    purpleLight = Color.lerp(purple, Colors.white, 0.28)!;
    purpleDark = Color.lerp(purple, Colors.black, 0.28)!;

    manjawi = Color(settings.secondaryColor);
    manjawiLight = Color.lerp(manjawi, Colors.white, 0.28)!;
    manjawiDark = Color.lerp(manjawi, Colors.black, 0.28)!;

    background = Color(settings.backgroundColor);
    cardBackground = Color(settings.cardColor);
    surface = cardBackground;
    surfaceLight = Color.lerp(background, Colors.black, 0.06)!;

    inputField = Color(settings.inputFieldColor);
    inputFieldBorder = Color.lerp(inputField, Colors.black, 0.14)!;

    textPrimary = Color(settings.textColor);
    textSecondary = Color.lerp(textPrimary, background, 0.4)!;
    textHint = Color.lerp(textPrimary, background, 0.62)!;
  }
}
