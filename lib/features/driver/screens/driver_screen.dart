import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/drivers_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/order_service.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/app_button.dart';

class DriverScreen extends ConsumerStatefulWidget {
  const DriverScreen({super.key});

  @override
  ConsumerState<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends ConsumerState<DriverScreen> {
  bool _togglingAvailability = false;

  Future<void> _toggleAvailability(String driverId, bool value) async {
    setState(() => _togglingAvailability = true);
    try {
      await AuthService.setDriverAvailability(driverId, value);
    } finally {
      if (mounted) setState(() => _togglingAvailability = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox.shrink();

    final currentOrder = ref.watch(currentDriverOrderProvider(user.id));
    final queued = ref.watch(queuedDriverOrdersProvider(user.id));
    final ordersAsync = ref.watch(driverActiveOrdersProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('لوحة المندوب'),
            Text(
              user.name,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: Icon(Icons.logout),
            tooltip: 'خروج',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Availability toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (user.isAvailable ? AppColors.success : AppColors.textHint)
                      .withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (user.isAvailable ? AppColors.success : AppColors.textHint)
                          .withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      user.isAvailable ? Icons.check_circle : Icons.pause_circle_outline,
                      color: user.isAvailable ? AppColors.success : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.isAvailable ? 'متاح لاستلام طلبات جديدة' : 'غير متاح حالياً',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'الطلبات النشطة: ${(ordersAsync.valueOrNull ?? const []).length}',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _togglingAvailability
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Switch(
                          value: user.isAvailable,
                          activeColor: AppColors.success,
                          onChanged: (v) => _toggleAvailability(user.id, v),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'الطلب الحالي',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            ordersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: LoadingWidget(),
              ),
              error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
              data: (_) => currentOrder == null
                  ? const EmptyState(
                      message: 'لا يوجد طلب حالي — سيصلك إشعار عند إسناد طلب جديد',
                      icon: Icons.local_shipping_outlined,
                    )
                  : _CurrentOrderCard(order: currentOrder),
            ),

            if (queued.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'طابور الانتظار (${queued.length})',
                style: TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ...queued.asMap().entries.map(
                    (e) => _QueuedOrderTile(order: e.value, position: e.key + 2),
                  ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CurrentOrderCard extends StatefulWidget {
  final OrderModel order;
  const _CurrentOrderCard({required this.order});

  @override
  State<_CurrentOrderCard> createState() => _CurrentOrderCardState();
}

class _CurrentOrderCardState extends State<_CurrentOrderCard> {
  bool _isUpdating = false;

  Future<void> _confirmPickup() async {
    setState(() => _isUpdating = true);
    try {
      await OrderService.confirmPickup(widget.order.id);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _markDelivered() async {
    setState(() => _isUpdating = true);
    try {
      await OrderService.updateOrderStatus(widget.order.id, OrderStatus.delivered);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _openMap() {
    final order = widget.order;
    if (!order.hasDeliveryLocation) return;
    launchUrl(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=${order.deliveryLat},${order.deliveryLng}'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final awaitingConfirm = order.status == OrderStatus.ready;

    return GlassMorphCard(
      borderColor: (awaitingConfirm ? AppColors.warning : AppColors.statusOutForDelivery)
          .withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (awaitingConfirm ? AppColors.warning : AppColors.statusOutForDelivery)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  awaitingConfirm ? 'بانتظار تأكيدك' : 'في الطريق',
                  style: TextStyle(
                    color: awaitingConfirm ? AppColors.warning : AppColors.statusOutForDelivery,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '#${order.id.substring(0, 6).toUpperCase()}',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      order.customerPhone,
                      style: TextStyle(color: AppColors.textHint, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    launchUrl(Uri(scheme: 'tel', path: order.customerPhone)),
                icon: Icon(Icons.call, color: AppColors.success),
                tooltip: 'اتصل بالعميل',
              ),
            ],
          ),
          if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.note_alt_outlined, color: AppColors.textHint, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.deliveryAddress!,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
          if (order.hasDeliveryLocation) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _openMap,
              icon: Icon(Icons.map_outlined, size: 18),
              label: const Text('فتح الموقع في خرائط جوجل'),
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: AppColors.surfaceLight),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Text('×${item.quantity}',
                      style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.name,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.surfaceLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              Text('${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
                  style: TextStyle(
                      color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(
            label: awaitingConfirm ? 'تأكيد استلام الطلب' : 'تم التسليم ✅',
            icon: awaitingConfirm ? Icons.task_alt : Icons.done_all,
            isLoading: _isUpdating,
            width: double.infinity,
            color: awaitingConfirm ? AppColors.warning : AppColors.success,
            onPressed: awaitingConfirm ? _confirmPickup : _markDelivered,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

class _QueuedOrderTile extends StatelessWidget {
  final OrderModel order;
  final int position;
  const _QueuedOrderTile({required this.order, required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.textHint.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Text('$position',
                style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customerName,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text(
                  order.status == OrderStatus.ready ? 'بانتظار تأكيدك' : 'في الطريق',
                  style: TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('hh:mm a').format(order.createdAt),
            style: TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
