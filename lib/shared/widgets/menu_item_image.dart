import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/menu_item_model.dart';
import '../../core/providers/app_theme_provider.dart';
import '../../core/services/cloudinary_service.dart';

/// ويدجت موحَّد لعرض صورة الصنف.
/// — عند تفعيل useTransparentBg: يضع خلفها اللون العالمي من AppThemeSettings
///   مع تطبيق الإزاحة والمقياس المحدَّدَين لهذا الصنف تحديداً.
/// — بدون تفعيل: يعرض الصورة بـ BoxFit.cover كالمعتاد.
class MenuItemImage extends ConsumerWidget {
  final MenuItemModel item;
  final bool available;
  final int optimizeWidth;

  const MenuItemImage({
    super.key,
    required this.item,
    this.available = true,
    this.optimizeWidth = 500,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.imageUrl == null) return _placeholder();

    final url = CloudinaryService.optimized(item.imageUrl, width: optimizeWidth);

    Widget imageWidget;
    if (item.useTransparentBg) {
      final theme = ref.watch(appThemeProvider);
      final bgColor = Color(theme.transparentItemBgColor);
      imageWidget = Container(
        color: bgColor,
        child: ClipRect(
          child: Transform.translate(
            offset: Offset(item.imageOffsetX, item.imageOffsetY),
            child: Transform.scale(
              scale: item.imageScale,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
            ),
          ),
        ),
      );
    } else {
      imageWidget = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    if (!available) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceLight,
        child: Icon(Icons.restaurant, color: AppColors.textHint, size: 32),
      );
}
