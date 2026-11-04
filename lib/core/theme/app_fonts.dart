import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// خطوط لوحة المظهر (AppThemeSettings.availableFonts) تُستدعى هنا مباشرة. طلب الخط
// باسمه عبر GoogleFonts.getFont يُدخل جدول كل خطوط Google في الملف الذي يحمّله العميل.
TextStyle appFont(String family, {FontWeight? fontWeight, double? fontSize}) {
  return switch (family) {
    'Tajawal' => GoogleFonts.tajawal(fontWeight: fontWeight, fontSize: fontSize),
    'Almarai' => GoogleFonts.almarai(fontWeight: fontWeight, fontSize: fontSize),
    'Changa' => GoogleFonts.changa(fontWeight: fontWeight, fontSize: fontSize),
    'ElMessiri' => GoogleFonts.elMessiri(fontWeight: fontWeight, fontSize: fontSize),
    'Markazi Text' => GoogleFonts.markaziText(fontWeight: fontWeight, fontSize: fontSize),
    'Reem Kufi' => GoogleFonts.reemKufi(fontWeight: fontWeight, fontSize: fontSize),
    'IBM Plex Sans Arabic' =>
      GoogleFonts.ibmPlexSansArabic(fontWeight: fontWeight, fontSize: fontSize),
    _ => GoogleFonts.cairo(fontWeight: fontWeight, fontSize: fontSize),
  };
}

TextTheme appFontTextTheme(String family, TextTheme base) {
  return switch (family) {
    'Tajawal' => GoogleFonts.tajawalTextTheme(base),
    'Almarai' => GoogleFonts.almaraiTextTheme(base),
    'Changa' => GoogleFonts.changaTextTheme(base),
    'ElMessiri' => GoogleFonts.elMessiriTextTheme(base),
    'Markazi Text' => GoogleFonts.markaziTextTextTheme(base),
    'Reem Kufi' => GoogleFonts.reemKufiTextTheme(base),
    'IBM Plex Sans Arabic' => GoogleFonts.ibmPlexSansArabicTextTheme(base),
    _ => GoogleFonts.cairoTextTheme(base),
  };
}
