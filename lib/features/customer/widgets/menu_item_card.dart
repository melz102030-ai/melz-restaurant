import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final available = item.isAvailable;
    final glowColor = available ? _badgeGlowColor(item) : null;

    final card = Container(
      decoration: BoxDecoration(
        color: available ? AppColors.cardBackground : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: totalQty > 0
            ? Border.all(color: AppColors.purple.withValues(alpha: 0.45), width: 1.4)
            : null,
        boxShadow: [
          BoxShadow(
            color: totalQty > 0
                ? AppColors.purple.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: available && item.hasOptions
            ? () => _showOptionsSheet(context)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColorFiltered(
                        colorFilter: available
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                            : const ColorFilter.matrix([
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ]),
                        child: item.imageUrl != null
                            ? Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholder(),
                              )
                            : _placeholder(),
                      ),
                      if (available && (item.isBestSeller || item.isNew))
                        Positioned(
                          top: 4,
                          left: 4,
                          child: _ItemBadges(item: item),
                        ),
                    ],
                  ),
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
                      style: TextStyle(
                        color: available
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (!available)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'نفدت الكمية',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          if (item.hasDiscount) ...[
                            Text(
                              '${item.price.toStringAsFixed(0)} ${AppStrings.sar}',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            '${item.finalPrice.toStringAsFixed(0)} ${AppStrings.sar}',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (item.hasOptions) ...[
                            const SizedBox(width: 6),
                            Text(
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
              if (!available)
                const SizedBox.shrink()
              else if (!item.hasOptions)
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
                      onTap: () => _showOptionsSheet(context),
                      icon: Icons.tune,
                    ),
                    if (totalQty > 0)
                      Positioned(
                        top: -5,
                        left: -5,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$totalQty',
                              style: TextStyle(
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: glowColor != null
          ? _GlowBorder(color: glowColor, borderRadius: 20, child: card)
          : card,
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(item: item),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceLight,
        child: Icon(Icons.restaurant, color: AppColors.textHint, size: 32),
      );
}

// ── Grid card (طريقة عرض الأصناف: شبكة) ────────────────────────────────────────

class MenuItemGridCard extends ConsumerWidget {
  final MenuItemModel item;
  const MenuItemGridCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalQty = ref.watch(cartProvider.select(
      (c) => c
          .where((i) => i.item.id == item.id)
          .fold(0, (s, c) => s + c.quantity),
    ));
    final available = item.isAvailable;
    final glowColor = available ? _badgeGlowColor(item) : null;

    final card = Container(
      decoration: BoxDecoration(
        color: available ? AppColors.cardBackground : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: totalQty > 0
            ? Border.all(color: AppColors.purple.withValues(alpha: 0.45), width: 1.4)
            : null,
        boxShadow: [
          BoxShadow(
            color: totalQty > 0
                ? AppColors.purple.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        // البطاقة المضغوطة لا تتّسع لأزرار كمية كاملة، فأي تفاعل (لمس البطاقة،
        // زر الإضافة، أو شارة الكمية) يفتح صفحة الصنف الكاملة لإتمام/تعديل
        // الاختيار — بدل نافذة سفلية أو إضافة صامتة بلا وسيلة تعديل لاحقة
        onTap: available ? () => _openItemDetail(context) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: available
                          ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                          : const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ]),
                      child: item.imageUrl != null
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                    if (!available)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'نفدت الكمية',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    if (available && (item.isBestSeller || item.isNew))
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _ItemBadges(item: item),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: available ? AppColors.textPrimary : AppColors.textHint,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: available
                            ? Text(
                                '${item.finalPrice.toStringAsFixed(0)} ${AppStrings.sar}',
                                style: TextStyle(
                                  color: AppColors.purple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (available)
                        totalQty == 0
                            ? _MiniAddBtn(onTap: () => _openItemDetail(context))
                            : _MiniQtyBadge(
                                qty: totalQty,
                                onTap: () => _openItemDetail(context),
                              ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return glowColor != null
        ? _GlowBorder(color: glowColor, borderRadius: 18, child: card)
        : card;
  }

  void _openItemDetail(BuildContext context) {
    context.push('/item/${item.id}');
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceLight,
        child: Icon(Icons.restaurant, color: AppColors.textHint, size: 32),
      );
}

// لون الإطار المتحرك حول البطاقة يطابق لون شارتها — الأحمر لـ"جديد" له الأولوية عند اجتماع الشارتين
Color? _badgeGlowColor(MenuItemModel item) {
  if (item.isNew) return AppColors.red;
  if (item.isBestSeller) return AppColors.manjawi;
  return null;
}

// إطار متحرك ولامع يلتف حول بطاقة "الأكثر مبيعاً"/"جديد" بلون شارتها
class _GlowBorder extends StatefulWidget {
  final Color color;
  final double borderRadius;
  final Widget child;
  const _GlowBorder({
    required this.color,
    required this.borderRadius,
    required this.child,
  });

  @override
  State<_GlowBorder> createState() => _GlowBorderState();
}

class _GlowBorderState extends State<_GlowBorder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(2.2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius + 2.2),
            gradient: SweepGradient(
              transform: GradientRotation(_controller.value * 2 * math.pi),
              colors: [
                widget.color.withValues(alpha: 0.15),
                widget.color,
                widget.color.withValues(alpha: 0.2),
                widget.color,
                widget.color.withValues(alpha: 0.15),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
            boxShadow: [
              BoxShadow(color: widget.color.withValues(alpha: 0.35), blurRadius: 10),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

// شارات "الأكثر مبيعاً"/"جديد" أعلى-يسار صورة الصنف — لا تتعارض مع شارة "نفدت الكمية" أعلى-اليمين
class _ItemBadges extends StatelessWidget {
  final MenuItemModel item;
  const _ItemBadges({required this.item});

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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      );
}

class _MiniAddBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _MiniAddBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.purple, width: 1.6),
          ),
          child: Icon(Icons.add, color: AppColors.purple, size: 16),
        ),
      );
}

class _MiniQtyBadge extends StatelessWidget {
  final int qty;
  final VoidCallback onTap;
  const _MiniQtyBadge({required this.qty, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '×$qty',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.purple, width: 1.8),
          ),
          child: Icon(icon, color: AppColors.purple, size: 21),
        ),
      );
}

// حبة (pill) موحّدة للتحكم بالكمية — بنفس تصميم شاشة السلة، بدل زرّين دائريين منفصلين
class _QtyRow extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _QtyRow({required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PillIconButton(icon: Icons.remove, onTap: onRemove),
            SizedBox(
              width: 24,
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            _PillIconButton(icon: Icons.add, onTap: onAdd),
          ],
        ),
      );
}

class _PillIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PillIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Icon(icon, color: AppColors.textPrimary, size: 15),
      ),
    );
  }
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

class _OptionsSheet extends StatelessWidget {
  final MenuItemModel item;
  const _OptionsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: BoxDecoration(
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
                        item.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${item.finalPrice.toStringAsFixed(0)} ${AppStrings.sar}',
                        style: TextStyle(
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
                  icon: Icon(Icons.close, color: AppColors.textHint),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.surfaceLight, height: 16),

          Flexible(child: ItemOptionsView(item: item)),
        ],
      ),
    );
  }
}

// محتوى اختيار الخيارات + عداد الكمية + زر الإضافة — مشترك بين النافذة
// السفلية المختصرة (_OptionsSheet) وصفحة تفاصيل الصنف الكاملة
// (ItemDetailScreen)، لتفادي تكرار منطق الحالة والتسعير بينهما
class ItemOptionsView extends ConsumerStatefulWidget {
  final MenuItemModel item;
  // true لصفحة كاملة (تملأ الارتفاع المتاح)، false لنافذة سفلية (تتقلّص حسب المحتوى)
  final bool asPage;
  const ItemOptionsView({super.key, required this.item, this.asPage = false});

  @override
  ConsumerState<ItemOptionsView> createState() => _ItemOptionsViewState();
}

class _ItemOptionsViewState extends ConsumerState<ItemOptionsView> {
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

    final notifier = ref.read(cartProvider.notifier);
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
    final optionsList = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: !widget.asPage,
      children: widget.item.optionGroups.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: group.required
                        ? AppColors.manjawi.withValues(alpha: 0.15)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    group.required ? 'إجباري' : 'اختياري',
                    style: TextStyle(
                      color: group.required ? AppColors.manjawi : AppColors.textHint,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...group.options.map((opt) {
              final selected = _selections[group.id]?.contains(opt.id) ?? false;
              return GestureDetector(
                onTap: () => setState(() {
                  if (group.type == OptionGroupType.single) {
                    _selections[group.id] = selected ? {} : {opt.id};
                  } else {
                    final s = Set<String>.from(_selections[group.id] ?? {});
                    selected ? s.remove(opt.id) : s.add(opt.id);
                    _selections[group.id] = s;
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.purple.withValues(alpha: 0.1)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.purple : AppColors.surfaceLight,
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
                        color: selected ? AppColors.purple : AppColors.textHint,
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
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
    );

    final footer = Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  style: TextStyle(
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canAdd ? _addToCart : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: _canAdd ? AppColors.purple : AppColors.textHint,
              ),
              child: Text(
                _canAdd
                    ? 'أضف للسلة — ${_totalPrice.toStringAsFixed(0)} ${AppStrings.sar}'
                    : 'اختر الخيارات الإجبارية',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: widget.asPage ? MainAxisSize.max : MainAxisSize.min,
      children: [
        widget.asPage ? Expanded(child: optionsList) : Flexible(child: optionsList),
        footer,
      ],
    );
  }
}
