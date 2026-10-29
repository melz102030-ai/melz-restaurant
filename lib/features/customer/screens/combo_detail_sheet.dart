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

class _ComboSheet extends ConsumerStatefulWidget {
  final ComboModel combo;
  const _ComboSheet({required this.combo});

  @override
  ConsumerState<_ComboSheet> createState() => _ComboSheetState();
}

class _ComboSheetState extends ConsumerState<_ComboSheet> {
  String? _selectedOptionId;

  void _addToCart(List<MenuItemModel> allItems) {
    final combo = widget.combo;
    final fixedItems = combo.items
        .map((r) => allItems.where((i) => i.id == r.itemId).firstOrNull)
        .whereType<MenuItemModel>()
        .map((item) => ComboSubSelection(item: item, selectedOptions: const []))
        .toList();

    // إضافة الخيار المختار كـ sub-selection إضافي
    final List<ComboSubSelection> allSubs;
    if (_selectedOptionId != null) {
      final optItem =
          allItems.where((i) => i.id == _selectedOptionId).firstOrNull;
      allSubs = [
        ...fixedItems,
        if (optItem != null)
          ComboSubSelection(item: optItem, selectedOptions: const []),
      ];
    } else {
      allSubs = fixedItems;
    }

    ref.read(comboCartProvider.notifier).add(ComboCartEntry(
          combo: combo,
          subSelections: allSubs,
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

  @override
  Widget build(BuildContext context) {
    final combo = widget.combo;
    final allItems =
        ref.watch(menuItemsStreamProvider(null)).valueOrNull ?? const <MenuItemModel>[];

    final resolvedItems = combo.items
        .map((r) => allItems.where((i) => i.id == r.itemId).firstOrNull)
        .whereType<MenuItemModel>()
        .toList();

    final optionItems = combo.optionItemIds
        .map((id) => allItems.where((i) => i.id == id).firstOrNull)
        .whereType<MenuItemModel>()
        .toList();

    final hasOptions = optionItems.isNotEmpty;
    final canAdd = !hasOptions || _selectedOptionId != null;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
          // الأصناف الثابتة
          if (resolvedItems.isNotEmpty) ...[
            Text('الوجبة تشمل:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...resolvedItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
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
          ],
          // خيارات الاختيار الإجباري
          if (hasOptions) ...[
            const SizedBox(height: 12),
            Divider(color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.tune, size: 16, color: AppColors.purple),
                const SizedBox(width: 6),
                Text('اختر واحداً:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('إجباري',
                      style: TextStyle(
                          color: AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...optionItems.map((item) => InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _selectedOptionId = item.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedOptionId == item.id
                          ? AppColors.purple.withOpacity(0.1)
                          : AppColors.inputField,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedOptionId == item.id
                            ? AppColors.purple
                            : AppColors.divider,
                        width: _selectedOptionId == item.id ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedOptionId == item.id
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _selectedOptionId == item.id
                              ? AppColors.purple
                              : AppColors.textHint,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item.name,
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: _selectedOptionId == item.id
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: canAdd ? () => _addToCart(allItems) : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              disabledBackgroundColor: AppColors.purple.withOpacity(0.35),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              hasOptions && _selectedOptionId == null
                  ? 'اختر خياراً أولاً'
                  : 'أضف للسلة · ${combo.price.toStringAsFixed(2)} ${AppStrings.sar}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
