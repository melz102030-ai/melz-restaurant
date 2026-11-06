import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/combo_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/combo_cart_provider.dart';
import '../providers/menu_provider.dart';

// وجبة عامة غير مرتبطة بصنف: تُضاف للسلة سطراً مستقلاً
Future<void> showComboSheet(BuildContext context, ComboModel combo) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ComboSheet(combo: combo),
  );
}

/// نتيجة اختيار وجبة على صنف: اختيار (بالصنف المختار من خياراتها) أو إلغاء
class ComboPick {
  final String? optionItemId;
  final bool removed;
  const ComboPick.chosen(this.optionItemId) : removed = false;
  const ComboPick.removed()
      : optionItemId = null,
        removed = true;
}

// وجبة مرتبطة بصنف: لا تذهب للسلة، بل تعود لصفحة الصنف لتُضاف معه كأنها من
// خياراته. null يعني أن العميل أغلق النافذة بلا تغيير
Future<ComboPick?> pickComboForItem(
  BuildContext context,
  ComboModel combo, {
  bool selected = false,
  String? optionItemId,
}) {
  return showModalBottomSheet<ComboPick>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ComboSheet(
      combo: combo,
      pickMode: true,
      pickedSelected: selected,
      pickedOptionId: optionItemId,
    ),
  );
}

class _ComboSheet extends ConsumerStatefulWidget {
  final ComboModel combo;
  final bool pickMode;
  final bool pickedSelected;
  final String? pickedOptionId;
  const _ComboSheet({
    required this.combo,
    this.pickMode = false,
    this.pickedSelected = false,
    this.pickedOptionId,
  });

  @override
  ConsumerState<_ComboSheet> createState() => _ComboSheetState();
}

class _ComboSheetState extends ConsumerState<_ComboSheet> {
  String? _selectedOptionId;

  // الوجبة المختارة سابقاً تُفتح باختيارها، ليعدّله العميل أو يلغيها
  ComboCartEntry? get _existing =>
      ref.read(comboCartProvider).where((e) => e.combo.id == widget.combo.id).firstOrNull;

  @override
  void initState() {
    super.initState();
    _selectedOptionId =
        widget.pickMode ? widget.pickedOptionId : _existing?.chosenOptionId;
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(text),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ));
  }

  void _removeFromCart() {
    if (widget.pickMode) {
      Navigator.pop(context, const ComboPick.removed());
      return;
    }
    ref.read(comboCartProvider.notifier).deleteCombo(widget.combo.id);
    Navigator.pop(context);
    _showMessage('تم إلغاء ${widget.combo.name}');
  }

  void _addToCart(List<MenuItemModel> allItems) {
    if (widget.pickMode) {
      Navigator.pop(context, ComboPick.chosen(_selectedOptionId));
      return;
    }
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

    final notifier = ref.read(comboCartProvider.notifier);
    final existing = _existing;
    if (existing != null) {
      notifier.replace(
        existing.cartKey,
        ComboCartEntry(combo: combo, subSelections: allSubs, quantity: existing.quantity),
      );
    } else {
      notifier.add(ComboCartEntry(combo: combo, subSelections: allSubs));
    }
    Navigator.pop(context);
    _showMessage(existing != null ? 'تم تعديل ${combo.name}' : 'تمت إضافة ${combo.name} للسلة');
  }

  @override
  Widget build(BuildContext context) {
    final combo = widget.combo;
    final loadedItems = ref.watch(menuItemsStreamProvider(null)).valueOrNull;
    final allItems = loadedItems ?? const <MenuItemModel>[];
    final isLoaded = loadedItems != null;

    final resolvedItems = combo.items
        .map((r) => allItems.where((i) => i.id == r.itemId).firstOrNull)
        .whereType<MenuItemModel>()
        .toList();

    final optionItems = combo.optionItemIds
        .map((id) => allItems.where((i) => i.id == id).firstOrNull)
        .whereType<MenuItemModel>()
        .where((item) => item.isAvailable)
        .toList();

    final hasOptions = optionItems.isNotEmpty;
    final canBeOrdered = isLoaded &&
        combo.canBeOrdered(
            (id) => allItems.any((item) => item.id == id && item.isAvailable));
    // الخيار المختار قد يتوقف والنافذة مفتوحة، فيختفي ويُلغى اختياره
    final hasSelection = optionItems.any((item) => item.id == _selectedOptionId);
    final canAdd = canBeOrdered && (!hasOptions || hasSelection);
    final inCart = ref.watch(comboCartProvider).any((e) => e.combo.id == combo.id);
    final isSelected = widget.pickMode ? widget.pickedSelected : inCart;
    final price = combo.price.toStringAsFixed(2);
    final chooseLabel = widget.pickMode
        ? 'اختيار · +$price ${AppStrings.sar}'
        : 'أضف للسلة · $price ${AppStrings.sar}';

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
          // الأصناف الثابتة والأسماء اليدوية
          if (resolvedItems.isNotEmpty || combo.includedNames.isNotEmpty) ...[
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
                        child: Text(
                            item.isAvailable
                                ? item.name
                                : '${item.name} (غير متوفر حالياً)',
                            style: TextStyle(
                                color: item.isAvailable
                                    ? AppColors.textPrimary
                                    : AppColors.error,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )),
            ...combo.includedNames.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: AppColors.purple, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(name,
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
          // المختارة بلا خيارات لا يُعدَّل فيها شيء، فيبقى زر الإلغاء وحده
          if (!isSelected || hasOptions)
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
              !isLoaded
                  ? 'جارٍ التحميل...'
                  : !canBeOrdered
                      ? 'غير متوفرة حالياً'
                      : hasOptions && !hasSelection
                          ? 'اختر خياراً أولاً'
                          : isSelected
                              ? 'حفظ التعديل'
                              : chooseLabel,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _removeFromCart,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.6)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.close, size: 18),
              label: Text('إلغاء ${combo.name}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
