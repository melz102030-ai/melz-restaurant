import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - ألوان المطعم الرسمية
  static const Color purple = Color(0xFF6A0DAD);
  static const Color purpleLight = Color(0xFF9C4DCA);
  static const Color purpleDark = Color(0xFF4A0080);

  static const Color manjawi = Color(0xFF800040); // المنجاوي
  static const Color manjawiLight = Color(0xFFB0005A);
  static const Color manjawiDark = Color(0xFF560028);

  static const Color red = Color(0xFFCC1100);
  static const Color redLight = Color(0xFFFF4433);
  static const Color redDark = Color(0xFF8B0000);

  // Background Colors
  static const Color background = Color(0xFF0D0010);
  static const Color surface = Color(0xFF1A0025);
  static const Color surfaceLight = Color(0xFF2A0038);
  static const Color cardBackground = Color(0xFF200030);

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F0FF);
  static const Color textSecondary = Color(0xFFB39DCA);
  static const Color textHint = Color(0xFF7B6B8D);

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
  static const Color statusDelivered = Color(0xFF1B5E20);
  static const Color statusCancelled = Color(0xFFF44336);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [purpleDark, manjawi],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2A0038), Color(0xFF1A0025)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4A0080), Color(0xFF800040), Color(0xFF8B0000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
