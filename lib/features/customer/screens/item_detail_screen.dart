import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/menu_item_model.dart';
import '../providers/menu_provider.dart';
import '../widgets/menu_item_card.dart';

// صفحة صنف كاملة — تُفتح من بطاقات العرض المضغوطة (شبكي/أفقي) التي لا تتّسع
// لأزرار كمية كاملة، بدل النافذة السفلية المختصرة المستخدمة في بطاقة القائمة
// العريضة. تعرض نفس محتوى اختيار الخيارات (ItemOptionsView) بتخطيط صفحة كاملة.
class ItemDetailScreen extends ConsumerWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(menuItemByIdProvider(itemId));

    if (item == null) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        )),
        body: Center(
          child: Text('هذا الصنف غير متوفر', style: TextStyle(color: AppColors.textHint)),
        ),
      );
    }

    final available = item.isAvailable;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Text(item.name),
      ),
      body: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                  if (!available)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('نفدت الكمية',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  if (available && (item.isBestSeller || item.isNew))
                    Positioned(top: 14, left: 14, child: _Badges(item: item)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.5),
                  ),
                ],
                const SizedBox(height: 10),
                if (available)
                  Row(
                    children: [
                      if (item.hasDiscount) ...[
                        Text(
                          '${item.price.toStringAsFixed(0)} ${AppStrings.sar}',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${item.finalPrice.toStringAsFixed(0)} ${AppStrings.sar}',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(height: 16),
          if (available)
            Expanded(child: ItemOptionsView(item: item, asPage: true))
          else
            Expanded(
              child: Center(
                child: Text('هذا الصنف غير متوفر حالياً', style: TextStyle(color: AppColors.textHint)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceLight,
        child: Icon(Icons.restaurant, color: AppColors.textHint, size: 48),
      );
}

class _Badges extends StatelessWidget {
  final MenuItemModel item;
  const _Badges({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.isBestSeller) _badge('الأكثر مبيعاً', AppColors.manjawi),
        if (item.isBestSeller && item.isNew) const SizedBox(height: 4),
        if (item.isNew) _badge('جديد', AppColors.red),
      ],
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      );
}
