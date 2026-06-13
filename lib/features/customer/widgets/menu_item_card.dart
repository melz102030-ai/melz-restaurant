import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/option_group_model.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../shared/widgets/gradient_container.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItemModel item;
  final int index;

  const MenuItemCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.watch(cartProvider.notifier);
    final totalQty = ref.watch(cartProvider.select(
      (c) => c.where((i) => i.item.id == item.id).fold(0, (s, c) => s + c.quantity),
    ));

    return GlassMorphCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                  if (item.hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${item.discountPercent!.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (item.hasOptions)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'قابل للتخصيص',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Spacer(),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.hasDiscount)
                            Text(
                              '${item.price.toStringAsFixed(0)} ${AppStrings.sar}',
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '${item.finalPrice.toStringAsFixed(0)} ${AppStrings.sar}',
                            style: const TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Add button / quantity badge
                      if (!item.hasOptions) ...[
                        // Simple +/- for items without options
                        if (totalQty == 0)
                          _AddButton(onTap: () => cartNotifier.addItem(item))
                        else
                          _SimpleQtyControl(
                            qty: totalQty,
                            onAdd: () => cartNotifier.addItem(item),
                            onRemove: () {
                              final entry = ref.read(cartProvider).firstWhere(
                                  (c) => c.item.id == item.id,
                                  orElse: () => CartItem(item: item, quantity: 0));
                              cartNotifier.removeItem(entry.cartKey);
                            },
                          ),
                      ] else ...[
                        // Open options sheet
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _AddButton(
                              onTap: () => _showOptionsSheet(context, ref),
                              icon: Icons.tune,
                            ),
                            if (totalQty > 0)
                              Positioned(
                                top: -6,
                                left: -6,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$totalQty',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn()
        .slideY(begin: 0.2);
  }

  void _showOptionsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(item: item, ref: ref),
    );
  }

  Widget _placeholderImage() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cardGradient),
      child: const Center(
        child: Icon(Icons.restaurant, size: 48, color: AppColors.textHint),
      ),
    );
  }
}

// ── Simple +/- for items without options ──────────────────────────────────────

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _AddButton({required this.onTap, this.icon = Icons.add});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SimpleQtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _SimpleQtyControl({required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove, color: AppColors.red, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$qty',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: AppColors.purple, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── Options bottom sheet ───────────────────────────────────────────────────────

class _OptionsSheet extends StatefulWidget {
  final MenuItemModel item;
  final WidgetRef ref;

  const _OptionsSheet({required this.item, required this.ref});

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  // groupId → selected option ids
  final Map<String, Set<String>> _selections = {};

  @override
  void initState() {
    super.initState();
    // Pre-select first option for single required groups
    for (final group in widget.item.optionGroups) {
      if (group.type == OptionGroupType.single && group.required && group.options.isNotEmpty) {
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

  void _addToCart() {
    final selectedGroups = <SelectedOptionGroup>[];
    for (final group in widget.item.optionGroups) {
      final selectedIds = _selections[group.id] ?? {};
      if (selectedIds.isEmpty) continue;
      final selectedOpts = group.options.where((o) => selectedIds.contains(o.id)).toList();
      selectedGroups.add(SelectedOptionGroup(
        groupId: group.id,
        groupName: group.name,
        selectedIds: selectedOpts.map((o) => o.id).toList(),
        selectedNames: selectedOpts.map((o) => o.name).toList(),
        totalExtra: selectedOpts.fold(0.0, (s, o) => s + o.priceAdjustment),
      ));
    }
    widget.ref.read(cartProvider.notifier).addItem(widget.item, selectedGroups);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت الإضافة: ${widget.item.name}'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.item.finalPrice + _extraTotal;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.item.description.isNotEmpty)
                        Text(
                          widget.item.description,
                          style: const TextStyle(color: AppColors.textHint, fontSize: 13),
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

          const Divider(color: AppColors.surfaceLight, height: 1),

          // Option groups
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shrinkWrap: true,
              children: widget.item.optionGroups.map((group) {
                return _OptionGroupWidget(
                  group: group,
                  selections: _selections[group.id] ?? {},
                  onChanged: (id, selected) {
                    setState(() {
                      if (group.type == OptionGroupType.single) {
                        _selections[group.id] = selected ? {id} : {};
                      } else {
                        final set = Set<String>.from(_selections[group.id] ?? {});
                        selected ? set.add(id) : set.remove(id);
                        _selections[group.id] = set;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -4))],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الإجمالي', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                    Text(
                      '${totalPrice.toStringAsFixed(0)} ${AppStrings.sar}',
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _canAdd ? _addToCart : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('أضف للسلة'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: _canAdd ? AppColors.purple : AppColors.textHint,
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

class _OptionGroupWidget extends StatelessWidget {
  final OptionGroup group;
  final Set<String> selections;
  final void Function(String id, bool selected) onChanged;

  const _OptionGroupWidget({
    required this.group,
    required this.selections,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                group.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: group.required
                    ? AppColors.manjawi.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                group.required ? 'إجباري' : 'اختياري',
                style: TextStyle(
                  color: group.required ? AppColors.manjawi : AppColors.textHint,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                group.type == OptionGroupType.single ? 'اختر واحداً' : 'اختر متعدد',
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...group.options.map((opt) {
          final selected = selections.contains(opt.id);
          return GestureDetector(
            onTap: () => onChanged(opt.id, !selected),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.purple.withValues(alpha: 0.15) : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.purple : AppColors.surfaceLight,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    group.type == OptionGroupType.single
                        ? (selected ? Icons.radio_button_checked : Icons.radio_button_unchecked)
                        : (selected ? Icons.check_box : Icons.check_box_outline_blank),
                    color: selected ? AppColors.purple : AppColors.textHint,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      opt.name,
                      style: TextStyle(
                        color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (opt.priceAdjustment != 0)
                    Text(
                      opt.priceAdjustment > 0
                          ? '+${opt.priceAdjustment.toStringAsFixed(0)} ${AppStrings.sar}'
                          : '${opt.priceAdjustment.toStringAsFixed(0)} ${AppStrings.sar}',
                      style: TextStyle(
                        color: opt.priceAdjustment > 0 ? AppColors.success : AppColors.textHint,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        const Divider(color: AppColors.surfaceLight),
      ],
    );
  }
}
