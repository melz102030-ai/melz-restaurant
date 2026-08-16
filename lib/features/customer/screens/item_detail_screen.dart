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
// العريضة. تعرض نفس محتوى اختيار الخيارات (ItemOptionsView) بتخطيط صفحة كاملة،
// مع تمرير الصورة والتفاصيل كرأس (header) يتمرّر مع قائمة الخيارات بدل أن
// يبقى ثابتاً بمعزل عنها ويسرق مساحة دائمة من الشاشة.
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
    final header = _ItemHeader(item: item);

    return Scaffold(
      body: available
          ? ItemOptionsView(item: item, asPage: true, header: header)
          : Column(
              children: [
                header,
                Expanded(
                  child: Center(
                    child: Text('هذا الصنف غير متوفر حالياً',
                        style: TextStyle(color: AppColors.textHint)),
                  ),
                ),
              ],
            ),
    );
  }
}

// صورة الصنف بعرض الشاشة الكامل (بلا فراغ جانبي) + الاسم والوصف والسعر
class _ItemHeader extends StatelessWidget {
  final MenuItemModel item;
  const _ItemHeader({required this.item});

  @override
  Widget build(BuildContext context) {
    final available = item.isAvailable;
    final hasBadges = available && (item.isBestSeller || item.isNew || item.hasDiscount);

    return Column(
      children: [
        Stack(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ClipRect(
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: _CircleIconButton(
                icon: Icons.arrow_back_ios,
                onTap: () => context.pop(),
              ),
            ),
            if (!available)
              Positioned(
                top: 14,
                left: 14,
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
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (hasBadges) ...[
                    const SizedBox(width: 8),
                    Flexible(child: _Badges(item: item)),
                  ],
                ],
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
              if (item.showNutritionInfo &&
                  (item.calories != null || item.allergens.isNotEmpty)) ...[
                const SizedBox(height: 12),
                _NutritionInfo(item: item),
              ],
            ],
          ),
        ),
        const Divider(height: 16),
      ],
    );
  }

  Widget _placeholder() => Container(
        width: double.infinity,
        height: 220,
        color: AppColors.surfaceLight,
        child: Icon(Icons.restaurant, color: AppColors.textHint, size: 48),
      );
}

// شارات الأكثر مبيعاً/جديد/الخصم — أفقياً بجوار اسم الصنف بدل فوق الصورة
class _Badges extends StatelessWidget {
  final MenuItemModel item;
  const _Badges({required this.item});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (item.isBestSeller) _badge('الأكثر مبيعاً', AppColors.manjawi),
        if (item.isNew) _badge('جديد', AppColors.red),
        if (item.hasDiscount)
          _badge('خصم ${item.discountPercent!.toStringAsFixed(0)}٪', AppColors.success),
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

// السعرات الحرارية ومسبّبات الحساسية — تظهر فقط إن فعّلها الأدمن صراحةً
// لهذا الصنف (item.showNutritionInfo) وعبّأ بيانات فعلية فيها
class _NutritionInfo extends StatelessWidget {
  final MenuItemModel item;
  const _NutritionInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.calories != null)
          Row(
            children: [
              Icon(Icons.local_fire_department_outlined, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 6),
              Text('${item.calories} سعرة حرارية',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        if (item.allergens.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'يحتوي على: ${item.allergens.map((id) => kAllergens[id] ?? id).join('، ')}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// زر رجوع دائري شبه شفاف يطفو فوق صورة الصنف مباشرة بدل شريط علوي (AppBar)
// تقليدي، ليتيح للصورة مساحة أكبر وحضوراً بصرياً أقوى
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
