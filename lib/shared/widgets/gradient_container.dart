import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry? padding;

  const GradientContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.gradient,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
      ),
      child: child,
    );
  }
}

class GlassMorphCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? borderColor;

  const GlassMorphCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
