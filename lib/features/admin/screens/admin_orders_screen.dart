import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../providers/admin_provider.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    (label: 'الكل', status: null),
    (label: 'انتظار', status: OrderStatus.pending),
    (label: 'تأكيد', status: OrderStatus.confirmed),
    (label: 'تحضير', status: OrderStatus.preparing),
    (label: 'جاهز', status: OrderStatus.ready),
    (label: 'تسليم', status: OrderStatus.delivered),
    (label: 'ملغى', status: OrderStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.orders),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((t) => _OrdersList(status: t.status)).toList(),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final OrderStatus? status;
  const _OrdersList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider(status));

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const EmptyState(
            message: 'لا توجد طلبات',
            icon: Icons.receipt_long_outlined,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (_, i) => _AdminOrderCard(order: orders[i], index: i),
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final int index;
  const _AdminOrderCard({required this.order, required this.index});

  static const _statusColors = {
    OrderStatus.pending: AppColors.statusPending,
    OrderStatus.confirmed: AppColors.statusConfirmed,
    OrderStatus.preparing: AppColors.statusPreparing,
    OrderStatus.ready: AppColors.statusReady,
    OrderStatus.delivered: AppColors.statusDelivered,
    OrderStatus.cancelled: AppColors.statusCancelled,
  };

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[order.status] ?? AppColors.textHint;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_long, color: color, size: 22),
        ),
        title: Text(
          '${order.customerName} · #${order.id.substring(0, 8).toUpperCase()}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.customerPhone,
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            Text(
              DateFormat('dd/MM/yyyy - hh:mm a').format(order.createdAt),
              style: const TextStyle(color: AppColors.textHint, fontSize: 11),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status.label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
              style: const TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        children: [
          // Items
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '×${item.quantity}',
                    style: const TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    '${item.total.toStringAsFixed(2)} ${AppStrings.sar}',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const Divider(color: AppColors.surfaceLight),
            Row(
              children: [
                const Icon(Icons.note, color: AppColors.textHint, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.notes!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],

          const Divider(color: AppColors.surfaceLight),

          // Status actions
          if (order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled)
            _StatusActionButtons(order: order),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 50)).fadeIn();
  }
}

class _StatusActionButtons extends StatelessWidget {
  final OrderModel order;
  const _StatusActionButtons({required this.order});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (order.status == OrderStatus.pending)
          _ActionButton(
            label: 'تأكيد',
            icon: Icons.thumb_up,
            color: AppColors.statusConfirmed,
            onTap: () => OrderService.updateOrderStatus(order.id, OrderStatus.confirmed),
          ),
        if (order.status == OrderStatus.confirmed)
          _ActionButton(
            label: 'بدء التحضير',
            icon: Icons.restaurant,
            color: AppColors.statusPreparing,
            onTap: () => OrderService.updateOrderStatus(order.id, OrderStatus.preparing),
          ),
        if (order.status == OrderStatus.preparing)
          _ActionButton(
            label: 'جاهز',
            icon: Icons.check_circle,
            color: AppColors.statusReady,
            onTap: () => OrderService.updateOrderStatus(order.id, OrderStatus.ready),
          ),
        if (order.status == OrderStatus.ready)
          _ActionButton(
            label: 'تم التسليم',
            icon: Icons.done_all,
            color: AppColors.statusDelivered,
            onTap: () => OrderService.updateOrderStatus(order.id, OrderStatus.delivered),
          ),
        _ActionButton(
          label: 'إلغاء',
          icon: Icons.cancel,
          color: AppColors.error,
          onTap: () => OrderService.updateOrderStatus(order.id, OrderStatus.cancelled),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
