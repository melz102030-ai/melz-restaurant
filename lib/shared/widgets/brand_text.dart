import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// اسم المطعم بخط Pacifico المشابه لشعار Meals
class BrandText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const BrandText({
    super.key,
    required this.text,
    this.fontSize = 32,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.pacifico(
        fontSize: fontSize,
        color: color,
        letterSpacing: 0.5,
      ),
    );
  }
}
