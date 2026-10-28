import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/menu_item_model.dart';
import '../../core/services/cloudinary_service.dart';

/// ويدجت موحَّد لعرض صورة الصنف مع دعم الخلفية الشفافة والتحريك والتكبير.
/// يُستخدَم في بطاقة العميل، صفحة التفاصيل، ولوحة الإدارة على حدٍّ سواء.
class MenuItemImage extends StatelessWidget {
  final MenuItemModel item;
  final bool available;
  // الحجم المطلوب لتحسين Cloudinary — يُرسَل إليه ليختار الدقة المناسبة
  final int optimizeWidth;

  const MenuItemImage({
    super.key,
    required this.item,
    this.available = true,
    this.optimizeWidth = 500,
  });

  @override
  Widget build(BuildContext context) {
    if (item.imageUrl == null) return _placeholder();

    final url = CloudinaryService.optimized(item.imageUrl, width: optimizeWidth);

    Widget imageWidget;
    if (item.useTransparentBg) {
      final bgColor = _hexToColor(item.imageBgColor);
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

Color _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '').padLeft(6, '0');
  try {
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return Colors.white;
  }
}
