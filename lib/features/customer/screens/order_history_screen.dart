import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/option_group_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/menu_provider.dart';
import '../providers/orders_provider.dart';

// سجل طلبات العميل بالكامل — مع إمكانية تكرار أي طلب سابق بضغطة واحدة
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(message: 'تعذّر تحميل الطلبات', icon: Icons.error_outline),
        data: (orders) => orders.isEmpty
            ? const EmptyState(
                message: 'لا توجد طلبات سابقة بعد\nابدأ بتصفح القائمة!',
                icon: Icons.receipt_long_outlined,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OrderHistoryCard(order: orders[i], index: i),
                ),
              ),
      ),
    );
  }
}

class _OrderHistoryCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final int index;
  const _OrderHistoryCard({required this.order, required this.index});

  @override
  ConsumerState<_OrderHistoryCard> createState() => _OrderHistoryCardState();
}

class _OrderHistoryCardState extends ConsumerState<_OrderHistoryCard> {
  bool _reordering = false;

  Future<void> _reorder() async {
    if (_reordering) return;
    setState(() => _reordering = true);
    try {
      final catalog = await ref.read(menuItemsStreamProvider(null).future);
      final cartNotifier = ref.read(cartProvider.notifier);
      int added = 0;
      final skippedNames = <String>[];

      for (final oi in widget.order.items) {
        MenuItemModel? current;
        for (final m in catalog) {
          if (m.id == oi.menuItemId && m.isAvailable) {
            current = m;
            break;
          }
        }
        if (current == null) {
          skippedNames.add(oi.name);
          continue;
        }

        // مطابقة أفضل-جهد لخيارات الطلب القديم مع الخيارات الحالية للصنف (بالاسم)
        final selectedGroups = <SelectedOptionGroup>[];
        for (final opt in oi.selectedOptions) {
          OptionGroup? group;
          for (final g in current.optionGroups) {
            if (g.name == opt.groupName) {
              group = g;
              break;
            }
          }
          if (group == null) continue;
          final matched = group.options.where((o) => opt.selectedNames.contains(o.name)).toList();
          if (matched.isEmpty) continue;
          selectedGroups.add(SelectedOptionGroup(
            groupId: group.id,
            groupName: group.name,
            selectedIds: matched.map((o) => o.id).toList(),
            selectedNames: matched.map((o) => o.name).toList(),
            totalExtra: matched.fold(0.0, (s, o) => s + o.priceAdjustment),
          ));
        }

        for (int i = 0; i < oi.quantity; i++) {
          cartNotifier.addItem(current, selectedGroups);
        }
        added++;
      }

      if (!mounted) return;
      if (added == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('عذراً، أصناف هذا الطلب لم تعد متوفرة حالياً'),
          backgroundColor: AppColors.error,
        ));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(skippedNames.isEmpty
            ? 'تمت إضافة أصناف الطلب إلى السلة'
            : 'تمت إضافة $added صنفاً — لم يعد متوفراً: ${skippedNames.join('، ')}'),
        backgroundColor: AppColors.success,
        duration: skippedNames.isEmpty
            ? const Duration(seconds: 4)
            : const Duration(seconds: 6),
      ));
      context.push('/cart');
    } finally {
      if (mounted) setState(() => _reordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final color = order.status.color;
    final isActive = order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled;
    final itemsSummary = order.items.map((i) => '${i.name} ×${i.quantity}').join('، ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(order.createdAt),
                style: TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            itemsSummary,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
                style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Row(
                children: [
                  if (isActive) ...[
                    OutlinedButton.icon(
                      onPressed: () => context.push('/track/${order.id}'),
                      icon: const Icon(Icons.local_shipping_outlined, size: 16),
                      label: const Text('تتبع', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: _reordering ? null : _reorder,
                    icon: _reordering
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.replay, size: 16),
                    label: const Text('إعادة الطلب', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: widget.index * 40)).fadeIn().slideY(begin: 0.05);
  }
}
