import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/option_group_model.dart';
import '../../../core/providers/cart_provider.dart';

// ── List card (used in CustomerHomeScreen) ────────────────────────────────────

class MenuItemListCard extends ConsumerWidget {
  final MenuItemModel item;
  const MenuItemListCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.watch(cartProvider.notifier);
    final totalQty = ref.watch(cartProvider.select(
      (c) => c
          .where((i) => i.item.id == item.id)
          .fold(0, (s, c) => s + c.quantity),
    ));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: totalQty > 0
              ? AppColors.purple.withValues(alpha: 0.4)
              : AppColors.surfaceLight,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: item.hasOptions
            ? () => _showOptionsSheet(context, ref)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (item.hasDiscount) ...[
                          Text(
                            '${item.price.toStringAsFixed(0)} ${AppStrings.sar}',
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          '${item.finalPrice.toStringAsFixed(0)} ${AppStrings.sar}',
                          style: const TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (item.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${item.discountPercent!.toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (item.hasOptions) ...[
                          const SizedBox(width: 6),
                          const Text(
                            'قابل للتخصيص',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Add control
              if (!item.hasOptions)
                totalQty == 0
                    ? _AddBtn(onTap: () => cartNotifier.addItem(item))
                    : _QtyRow(
                        qty: totalQty,
                        onAdd: () => cartNotifier.addItem(item),
                        onRemove: () {
                          final entry = ref.read(cartProvider).firstWhere(
                              (c) => c.item.id == item.id,
                              orElse: () =>
                                  CartItem(item: item, quantity: 0));
                          cartNotifier.removeItem(entry.cartKey);
                        },
                      )
              else
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _AddBtn(
                      onTap: () => _showOptionsSheet(context, ref),
                      icon: Icons.tune,
                    ),
                    if (totalQty > 0)
                      Positioned(
                        top: -5,
                        left: -5,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$totalQty',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(item: item, ref: ref),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceLight,
        child: const Icon(Icons.restaurant, color: AppColors.textHint, size: 32),
      );
}

// ── Small reusable controls ───────────────────────────────────────────────────

class _AddBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _AddBtn({required this.onTap, this.icon = Icons.add});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _QtyRow extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _QtyRow({required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleBtn(icon: Icons.remove, color: AppColors.red, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$qty',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          _CircleBtn(icon: Icons.add, color: AppColors.purple, onTap: onAdd),
        ],
      );
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      );
}

// ── Options bottom sheet ──────────────────────────────────────────────────────

class _OptionsSheet extends StatefulWidget {
  final MenuItemModel item;
  final WidgetRef ref;
  const _OptionsSheet({required this.item, required this.ref});

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  final Map<String, Set<String>> _selections = {};
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    for (final group in widget.item.optionGroups) {
      if (group.type == OptionGroupType.single &&
          group.required &&
          group.options.isNotEmpty) {
        _selections[group.id] = {group.options.first.id};
      } else {
        _selections[group.id] = {};
      }
    }
  }

  bool get _canAdd {
    for (final group in widget.item.optionGroups) {
      if (group.required && (_selections[group.id]?.isEmpty ?? true)) return false;
    }
    return true;
  }

  double get _extraTotal {
    double extra = 0;
    for (final group in widget.item.optionGroups) {
      final selected = _selections[group.id] ?? {};
      for (final opt in group.options) {
        if (selected.contains(opt.id)) extra += opt.priceAdjustment;
      }
    }
    return extra;
  }

  double get _unitPrice => widget.item.finalPrice + _extraTotal;
  double get _totalPrice => _unitPrice * _qty;

  void _addToCart() {
    final selectedGroups = <SelectedOptionGroup>[];
    for (final group in widget.item.optionGroups) {
      final selectedIds = _selections[group.id] ?? {};
      if (selectedIds.isEmpty) continue;
      final selectedOpts =
          group.options.where((o) => selectedIds.contains(o.id)).toList();
      selectedGroups.add(SelectedOptionGroup(
        groupId: group.id,
        groupName: group.name,
        selectedIds: selectedOpts.map((o) => o.id).toList(),
        selectedNames: selectedOpts.map((o) => o.name).toList(),
        totalExtra: selectedOpts.fold(0.0, (s, o) => s + o.priceAdjustment),
      ));
    }

    final notifier = widget.ref.read(cartProvider.notifier);
    for (int i = 0; i < _qty; i++) {
      notifier.addItem(widget.item, selectedGroups);
    }

    final messenger = ScaffoldMessenger.of(context);
    final name = widget.item.name;
    final qty = _qty;
    Navigator.pop(context);

    messenger.showSnackBar(SnackBar(
      content: Text('تمت إضافة $qty $name للسلة'),
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.item.finalPrice.toStringAsFixed(0)} ${AppStrings.sar}',
                        style: const TextStyle(
                          color: AppColors.purple,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textHint),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.surfaceLight, height: 16),

          // Options
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              children: widget.item.optionGroups.map((group) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: group.required
                                ? AppColors.manjawi.withValues(alpha: 0.15)
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            group.required ? 'إجباري' : 'اختياري',
                            style: TextStyle(
                              color: group.required
                                  ? AppColors.manjawi
                                  : AppColors.textHint,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...group.options.map((opt) {
                      final selected =
                          _selections[group.id]?.contains(opt.id) ?? false;
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (group.type == OptionGroupType.single) {
                            _selections[group.id] = selected ? {} : {opt.id};
                          } else {
                            final s =
                                Set<String>.from(_selections[group.id] ?? {});
                            selected ? s.remove(opt.id) : s.add(opt.id);
                            _selections[group.id] = s;
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.purple.withValues(alpha: 0.1)
                                : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppColors.purple
                                  : AppColors.surfaceLight,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                group.type == OptionGroupType.single
                                    ? (selected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked)
                                    : (selected
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank),
                                color: selected
                                    ? AppColors.purple
                                    : AppColors.textHint,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  opt.name,
                                  style: TextStyle(
                                    color: selected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (opt.priceAdjustment != 0)
                                Text(
                                  '${opt.priceAdjustment > 0 ? '+' : ''}${opt.priceAdjustment.toStringAsFixed(0)} ${AppStrings.sar}',
                                  style: TextStyle(
                                    color: opt.priceAdjustment > 0
                                        ? AppColors.success
                                        : AppColors.textHint,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),

          // Footer: qty + add button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -3))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Qty selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CircleBtn(
                      icon: Icons.remove,
                      color: AppColors.red,
                      onTap: () {
                        if (_qty > 1) setState(() => _qty--);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '$_qty',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _CircleBtn(
                      icon: Icons.add,
                      color: AppColors.purple,
                      onTap: () => setState(() => _qty++),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canAdd ? _addToCart : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor:
                          _canAdd ? AppColors.purple : AppColors.textHint,
                    ),
                    child: Text(
                      _canAdd
                          ? 'أضف للسلة — ${_totalPrice.toStringAsFixed(0)} ${AppStrings.sar}'
                          : 'اختر الخيارات الإجبارية',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
