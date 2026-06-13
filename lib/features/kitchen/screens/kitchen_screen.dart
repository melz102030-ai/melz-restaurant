import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/order_service.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/kitchen_provider.dart';

class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newOrders = ref.watch(newKitchenOrdersProvider);
    final inProgress = ref.watch(inProgressKitchenOrdersProvider);
    final ready = ref.watch(readyKitchenOrdersProvider);
    final ordersAsync = ref.watch(kitchenOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.kitchenDisplay),
            Text(
              'مجموع النشط: ${ordersAsync.maybeWhen(data: (d) => d.length, orElse: () => 0)} طلب',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          // Logout
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'خروج',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: _TabLabel(
                label: AppStrings.newOrders,
                count: newOrders.length,
                color: AppColors.statusPending,
              ),
            ),
            Tab(
              child: _TabLabel(
                label: AppStrings.inProgress,
                count: inProgress.length,
                color: AppColors.statusPreparing,
              ),
            ),
            Tab(
              child: _TabLabel(
                label: AppStrings.completed,
                count: ready.length,
                color: AppColors.statusReady,
              ),
            ),
          ],
        ),
      ),
      body: ordersAsync.when(
        loading: () => const LoadingWidget(message: 'جاري تحميل الطلبات...'),
        error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
        data: (_) => TabBarView(
          controller: _tabController,
          children: [
            // New orders
            _OrdersColumn(
              orders: newOrders,
              emptyMessage: 'لا توجد طلبات جديدة',
            ),
            // In progress
            _OrdersColumn(
              orders: inProgress,
              emptyMessage: 'لا توجد طلبات قيد التنفيذ',
            ),
            // Ready
            _OrdersColumn(
              orders: ready,
              emptyMessage: 'لا توجد طلبات جاهزة',
            ),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _TabLabel({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrdersColumn extends ConsumerWidget {
  final List<OrderModel> orders;
  final String emptyMessage;
  const _OrdersColumn({required this.orders, required this.emptyMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return EmptyState(
        message: emptyMessage,
        icon: Icons.check_circle_outline,
      );
    }

    final isWide = MediaQuery.of(context).size.width > 900;

    if (isWide) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: orders.length,
        itemBuilder: (_, i) => _KitchenOrderCard(order: orders[i], index: i),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (_, i) => _KitchenOrderCard(order: orders[i], index: i),
    );
  }
}

class _KitchenOrderCard extends StatefulWidget {
  final OrderModel order;
  final int index;
  const _KitchenOrderCard({required this.order, required this.index});

  @override
  State<_KitchenOrderCard> createState() => _KitchenOrderCardState();
}

class _KitchenOrderCardState extends State<_KitchenOrderCard> {
  final _notesCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  bool _isUpdating = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _timeCtrl.text = widget.order.estimatedTime ?? '';
    _notesCtrl.text = widget.order.kitchenNotes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await OrderService.updateOrderStatus(
        widget.order.id,
        newStatus,
        estimatedTime: _timeCtrl.text.trim().isEmpty ? null : _timeCtrl.text.trim(),
        kitchenNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Color get _statusColor {
    switch (widget.order.status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.ready:
        return AppColors.statusReady;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final elapsed = DateTime.now().difference(order.createdAt);
    final isUrgent = elapsed.inMinutes > 15 && order.status == OrderStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? AppColors.error : _statusColor.withOpacity(0.4),
          width: isUrgent ? 2 : 1,
        ),
        boxShadow: isUrgent
            ? [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _statusColor.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Order number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${order.id.substring(0, 6).toUpperCase()}',
                    style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        order.customerPhone,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Time elapsed
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? AppColors.error.withOpacity(0.15)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: isUrgent ? AppColors.error : AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${elapsed.inMinutes} د',
                            style: TextStyle(
                              color: isUrgent ? AppColors.error : AppColors.textHint,
                              fontSize: 12,
                              fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('hh:mm a').format(order.createdAt),
                      style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '×${item.quantity}',
                            style: const TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Notes
          if (order.notes != null && order.notes!.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.notes!,
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Expandable section
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _timeCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'الوقت المتوقع (للعميل)',
                      hintText: 'مثال: 20-30 دقيقة',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'ملاحظة للعميل',
                      hintText: 'مثال: تأخير بسيط...',
                      prefixIcon: Icon(Icons.message),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expand button
                    TextButton.icon(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                      label: Text(_expanded ? 'إخفاء' : 'تفاصيل'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textHint,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),

                    // Status buttons
                    if (_isUpdating)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Row(
                        children: [
                          if (order.status == OrderStatus.pending)
                            _ActionBtn(
                              label: AppStrings.confirm,
                              color: AppColors.statusConfirmed,
                              icon: Icons.thumb_up,
                              onTap: () => _updateStatus(OrderStatus.confirmed),
                            ),
                          if (order.status == OrderStatus.confirmed)
                            _ActionBtn(
                              label: AppStrings.startPreparing,
                              color: AppColors.statusPreparing,
                              icon: Icons.restaurant,
                              onTap: () => _updateStatus(OrderStatus.preparing),
                            ),
                          if (order.status == OrderStatus.preparing)
                            _ActionBtn(
                              label: AppStrings.markReady,
                              color: AppColors.statusReady,
                              icon: Icons.check_circle,
                              onTap: () => _updateStatus(OrderStatus.ready),
                            ),
                          if (order.status == OrderStatus.ready)
                            _ActionBtn(
                              label: AppStrings.markDelivered,
                              color: AppColors.statusDelivered,
                              icon: Icons.done_all,
                              onTap: () => _updateStatus(OrderStatus.delivered),
                            ),
                          const SizedBox(width: 8),
                          // Cancel
                          if (order.status != OrderStatus.ready)
                            _ActionBtn(
                              label: 'إلغاء',
                              color: AppColors.error,
                              icon: Icons.cancel,
                              onTap: () => _updateStatus(OrderStatus.cancelled),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 60))
        .fadeIn()
        .slideY(begin: 0.1);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
