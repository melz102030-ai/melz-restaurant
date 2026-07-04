import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/services/menu_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../customer/providers/menu_provider.dart';

class KitchenAvailabilityScreen extends ConsumerWidget {
  const KitchenAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(adminMenuItemsProvider);
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('توفر الأصناف'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: itemsAsync.when(
        loading: () => const LoadingWidget(message: 'جاري تحميل الأصناف...'),
        error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
        data: (items) {
          final categories = categoriesAsync.valueOrNull ?? [];

          // Group items by category
          final Map<String, List<MenuItemModel>> grouped = {};
          for (final cat in categories) {
            grouped[cat.id] = items.where((i) => i.categoryId == cat.id).toList();
          }
          // Uncategorized items
          final uncatItems = items
              .where((i) => categories.every((c) => c.id != i.categoryId))
              .toList();

          final sections = <_Section>[];
          for (final cat in categories) {
            final catItems = grouped[cat.id] ?? [];
            if (catItems.isNotEmpty) {
              sections.add(_Section(title: cat.name, items: catItems));
            }
          }
          if (uncatItems.isNotEmpty) {
            sections.add(_Section(title: 'أخرى', items: uncatItems));
          }

          if (sections.isEmpty) {
            return const EmptyState(
              message: 'لا توجد أصناف',
              icon: Icons.restaurant_menu,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
            itemCount: sections.length,
            itemBuilder: (_, i) => _CategorySection(section: sections[i]),
          );
        },
      ),
    );
  }
}

class _Section {
  final String title;
  final List<MenuItemModel> items;
  const _Section({required this.title, required this.items});
}

class _CategorySection extends StatelessWidget {
  final _Section section;
  const _CategorySection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${section.items.length})',
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        ...section.items.map((item) => _ItemTile(item: item)),
      ],
    );
  }
}

class _ItemTile extends StatefulWidget {
  final MenuItemModel item;
  const _ItemTile({required this.item});

  @override
  State<_ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<_ItemTile> {
  bool _loading = false;

  Future<void> _toggle(bool value) async {
    setState(() => _loading = true);
    try {
      await MenuService.toggleItemAvailability(widget.item.id, value);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final available = item.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: available ? AppColors.cardBackground : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: available
              ? AppColors.purple.withOpacity(0.2)
              : AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
            child: Row(
              children: [
                // Image or icon
                if (item.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ColorFiltered(
                      colorFilter: available
                          ? const ColorFilter.mode(
                              Colors.transparent, BlendMode.dst)
                          : const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ]),
                      child: Image.network(
                        item.imageUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _iconBox(),
                      ),
                    ),
                  )
                else
                  _iconBox(),
                const SizedBox(width: 12),

                // Name + price
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
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.finalPrice.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          color: available
                              ? AppColors.purple
                              : AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Toggle
                _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: available,
                        onChanged: _toggle,
                        activeColor: AppColors.success,
                        inactiveThumbColor: AppColors.error,
                        inactiveTrackColor: AppColors.error.withOpacity(0.3),
                      ),
              ],
            ),
          ),

          // Status chip
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: available
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    available ? 'متوفر' : 'نفد من المطعم',
                    style: TextStyle(
                      color: available ? AppColors.success : AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Options summary
                if (item.optionGroups.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.optionGroups
                          .map((g) =>
                              '${g.name}: ${g.options.map((o) => o.name).join('، ')}')
                          .join(' | '),
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.fastfood, color: AppColors.textHint, size: 26),
      );
}
