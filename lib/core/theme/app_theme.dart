import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/app_theme_settings.dart';

class AppTheme {
  // يُبنى من AppColors الحالية (المحدَّثة مسبقاً عبر AppColors.applyTheme) + خط الأدمن المختار
  static ThemeData buildTheme(AppThemeSettings settings) {
    final textTheme = TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.textPrimary),
      titleSmall: TextStyle(color: AppColors.textSecondary),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      bodySmall: TextStyle(color: AppColors.textHint),
      labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    );

    final cardRadius = settings.cardStyle == CardStyle.rounded ? 16.0 : 4.0;
    final fieldRadius = settings.cardStyle == CardStyle.rounded ? 12.0 : 4.0;

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.purple,
        secondary: AppColors.manjawi,
        tertiary: AppColors.red,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _googleFontsTextTheme(settings.fontFamily, textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: AppColors.purple.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: AppColors.surfaceLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(fieldRadius)),
          textStyle: _googleFont(settings.fontFamily, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purple,
          side: BorderSide(color: AppColors.purple),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(fieldRadius)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: AppColors.inputFieldBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: AppColors.purple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textHint),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.surfaceLight,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.purple,
        labelStyle: TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.purple,
        unselectedLabelColor: AppColors.textHint,
        indicatorColor: AppColors.purple,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      iconTheme: IconThemeData(color: AppColors.textSecondary),
      primaryIconTheme: IconThemeData(color: AppColors.textPrimary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.purple : AppColors.textHint),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.purpleLight.withValues(alpha: 0.5)
                : AppColors.surfaceLight),
      ),
    );
  }

  static TextTheme _googleFontsTextTheme(String fontFamily, TextTheme base) {
    try {
      return GoogleFonts.getTextTheme(fontFamily, base);
    } catch (_) {
      return GoogleFonts.cairoTextTheme(base);
    }
  }

  static TextStyle _googleFont(String fontFamily, {FontWeight? fontWeight, double? fontSize}) {
    try {
      return GoogleFonts.getFont(fontFamily, fontWeight: fontWeight, fontSize: fontSize);
    } catch (_) {
      return GoogleFonts.cairo(fontWeight: fontWeight, fontSize: fontSize);
    }
  }
}
