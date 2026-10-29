import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/combo_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/combo_cart_provider.dart';
import '../providers/menu_provider.dart';

Future<void> showComboSheet(BuildContext context, ComboModel combo) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ComboSheet(combo: combo),
  );
}

class _ComboSheet extends ConsumerWidget {
  final ComboModel combo;
  const _ComboSheet({required this.combo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(menuItemsStreamProvider(null)).valueOrNull ?? const <MenuItemModel>[];
    final resolvedItems = combo.items
        .map((r) => allItems.where((i) => i.id == r.itemId).firstOrNull)
        .whereType<MenuItemModel>()
        .toList();

    void addToCart() {
      // تُضاف التركيبة للسلة كـ header بالسعر الكامل + sub-items بسعر صفر
      final subSelections = resolvedItems.map((item) => ComboSubSelection(
            item: item,
            selectedOptions: const [],
          )).toList();
      ref.read(comboCartProvider.notifier).add(ComboCartEntry(
            combo: combo,
            subSelections: subSelections,
          ));
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('تمت إضافة ${combo.name} للسلة'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // مقبض السحب
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.textHint.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // اسم التركيبة + السعر
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      combo.name,
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    if (combo.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(combo.description!,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${combo.price.toStringAsFixed(2)} ${AppStrings.sar}',
                  style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.divider),
          const SizedBox(height: 10),
          // عناوين "ما تشمله الوجبة"
          Text('الوجبة تشمل:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          ...resolvedItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.purple, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item.name,
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              )),
          if (resolvedItems.isEmpty)
            Text('لا توجد أصناف مضافة',
                style:
                    TextStyle(color: AppColors.textHint, fontSize: 13)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: addToCart,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'أضف للسلة · ${combo.price.toStringAsFixed(2)} ${AppStrings.sar}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
