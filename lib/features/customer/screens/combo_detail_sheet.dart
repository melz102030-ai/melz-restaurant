import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/combo_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/option_group_model.dart';
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
  // itemId → {groupId → Set<optionId>}
  late Map<String, Map<String, Set<String>>> _selections;
  // groupId that failed validation
  String? _invalidGroup;
  final _scrollCtrl = ScrollController();
  final Map<String, GlobalKey> _groupKeys = {};

  @override
  void initState() {
    super.initState();
    _selections = {};
    for (final ref in widget.combo.items) {
      _selections[ref.itemId] = {};
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<SelectedOptionGroup> _getSelections(MenuItemModel item) {
    final itemSel = _selections[item.id] ?? {};
    final result = <SelectedOptionGroup>[];
    for (final group in item.optionGroups) {
      final selectedIds = itemSel[group.id] ?? {};
      if (selectedIds.isEmpty) continue;
      final selectedOpts = group.options.where((o) => selectedIds.contains(o.id)).toList();
      result.add(SelectedOptionGroup(
        groupId: group.id,
        groupName: group.name,
        selectedIds: selectedOpts.map((o) => o.id).toList(),
        selectedNames: selectedOpts.map((o) => o.name).toList(),
        totalExtra: 0, // السعر ثابت للتركيبة — لا إضافات سعرية
      ));
    }
    return result;
  }

  bool _validate(List<MenuItemModel> items) {
    for (final item in items) {
      final itemSel = _selections[item.id] ?? {};
      for (final group in item.optionGroups) {
        if (group.required && (itemSel[group.id]?.isEmpty ?? true)) {
          setState(() => _invalidGroup = group.id);
          final ctx = _groupKeys[group.id]?.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(ctx,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                alignment: 0.1);
          }
          return false;
        }
      }
    }
    return true;
  }

  void _addToCart(List<MenuItemModel> items) {
    if (!_validate(items)) return;

    final subs = items.map((item) => ComboSubSelection(
          item: item,
          selectedOptions: _getSelections(item),
        )).toList();

    ref.read(comboCartProvider.notifier).add(ComboCartEntry(
          combo: widget.combo,
          subSelections: subs,
        ));

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('تمت إضافة ${widget.combo.name} للسلة'),
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(menuItemsStreamProvider(null)).valueOrNull ?? const <MenuItemModel>[];

    // حل معرّفات الأصناف بترتيبها في التركيبة
    final resolvedItems = widget.combo.items
        .map((r) => allItems.where((i) => i.id == r.itemId).firstOrNull)
        .whereType<MenuItemModel>()
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // مقبض السحب
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // رأس التركيبة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.combo.name,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        if (widget.combo.description != null)
                          Text(widget.combo.description!,
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.combo.price.toStringAsFixed(2)} ${AppStrings.sar}',
                      style: TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            // محتوى الأصناف + خياراتها
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: resolvedItems.map((item) {
                  final itemSel = _selections.putIfAbsent(item.id, () => {});
                  return _ItemSection(
                    item: item,
                    selections: itemSel,
                    groupKeys: _groupKeys,
                    invalidGroup: _invalidGroup,
                    onChanged: (groupId, selectedIds) {
                      setState(() {
                        itemSel[groupId] = selectedIds;
                        _invalidGroup = null;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            // زر الإضافة
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _addToCart(resolvedItems),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'أضف للسلة · ${widget.combo.price.toStringAsFixed(2)} ${AppStrings.sar}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemSection extends StatelessWidget {
  final MenuItemModel item;
  final Map<String, Set<String>> selections;
  final Map<String, GlobalKey> groupKeys;
  final String? invalidGroup;
  final void Function(String groupId, Set<String> selectedIds) onChanged;

  const _ItemSection({
    required this.item,
    required this.selections,
    required this.groupKeys,
    required this.invalidGroup,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(item.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
        if (item.optionGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('بدون خيارات إضافية',
                style: TextStyle(color: AppColors.textHint, fontSize: 12)),
          )
        else
          ...item.optionGroups.map((group) {
            groupKeys.putIfAbsent(group.id, () => GlobalKey());
            final selected = selections[group.id] ?? {};
            final isInvalid = group.required && invalidGroup == group.id;

            return Container(
              key: groupKeys[group.id],
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isInvalid
                        ? AppColors.red
                        : AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(group.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontSize: 13)),
                      ),
                      if (group.required)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isInvalid ? AppColors.red : AppColors.purple)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text('إجباري',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: isInvalid ? AppColors.red : AppColors.purple,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: group.availableOptions.map((opt) {
                      final isSelected = selected.contains(opt.id);
                      return GestureDetector(
                        onTap: () {
                          final newSel = Set<String>.from(selected);
                          if (group.type == OptionGroupType.single) {
                            newSel
                              ..clear()
                              ..add(opt.id);
                          } else {
                            isSelected ? newSel.remove(opt.id) : newSel.add(opt.id);
                          }
                          onChanged(group.id, newSel);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.purple
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.purple
                                    : AppColors.divider),
                          ),
                          child: Text(opt.name,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
