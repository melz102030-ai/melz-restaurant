import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/orders_provider.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(trackOrderProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.trackOrder),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: orderAsync.when(
        loading: () => const LoadingWidget(message: 'جاري تحميل الطلب...'),
        error: (e, _) => EmptyState(
          message: 'خطأ في تحميل الطلب',
          icon: Icons.error_outline,
          actionLabel: 'عودة',
          onAction: () => context.go('/home'),
        ),
        data: (order) {
          if (order == null) {
            return EmptyState(
              message: 'الطلب غير موجود',
              icon: Icons.search_off,
              actionLabel: 'عودة',
              onAction: () => context.go('/home'),
            );
          }
          return _OrderTrackingContent(order: order);
        },
      ),
    );
  }
}

class _OrderTrackingContent extends StatelessWidget {
  final OrderModel order;
  const _OrderTrackingContent({required this.order});

  Color _getStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.ready:
        return AppColors.statusReady;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final isDelivered = order.status == OrderStatus.delivered;
    final statusColor = _getStatusColor(order.status);

    final steps = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.delivered,
    ];

    final currentStep = isCancelled ? -1 : order.status.step;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          GlassMorphCard(
            borderColor: statusColor.withOpacity(0.5),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(order.status),
                    color: statusColor,
                    size: 48,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 12),
                Text(
                  order.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(),
                if (order.estimatedTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'الوقت المتوقع: ${order.estimatedTime}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'رقم الطلب: #${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress stepper (only if not cancelled)
          if (!isCancelled)
            GlassMorphCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تتبع الطلب',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...steps.asMap().entries.map((e) {
                    final stepIndex = e.key;
                    final stepStatus = e.value;
                    final isDone = currentStep > stepIndex;
                    final isCurrent = currentStep == stepIndex;
                    final color = isDone || isCurrent ? AppColors.purple : AppColors.textHint;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? AppColors.success
                                    : isCurrent
                                        ? AppColors.purple
                                        : AppColors.surfaceLight,
                                shape: BoxShape.circle,
                                border: isCurrent
                                    ? Border.all(color: AppColors.purple, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: isDone
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : isCurrent
                                        ? const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            '${stepIndex + 1}',
                                            style: TextStyle(
                                              color: AppColors.textHint,
                                              fontSize: 12,
                                            ),
                                          ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              stepStatus.label,
                              style: TextStyle(
                                color: color,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        if (stepIndex < steps.length - 1)
                          Container(
                            margin: const EdgeInsets.only(right: 16, top: 2, bottom: 2),
                            height: 24,
                            width: 2,
                            color: isDone ? AppColors.success : AppColors.surfaceLight,
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),

          if (isCancelled)
            GlassMorphCard(
              borderColor: AppColors.error.withOpacity(0.5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cancel, color: AppColors.error, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'تم إلغاء هذا الطلب',
                      style: TextStyle(color: AppColors.error, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Kitchen notes
          if (order.kitchenNotes != null && order.kitchenNotes!.isNotEmpty)
            GlassMorphCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.restaurant, color: AppColors.textSecondary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'ملاحظة من المطبخ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.kitchenNotes!,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Order Items
          GlassMorphCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'العناصر المطلوبة',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '×${item.quantity}',
                            style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          '${item.total.toStringAsFixed(2)} ${AppStrings.sar}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppColors.surfaceLight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(AppStrings.subtotal, style: TextStyle(color: AppColors.textSecondary)),
                    Text('${order.subtotal.toStringAsFixed(2)} ${AppStrings.sar}',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(AppStrings.deliveryFee, style: TextStyle(color: AppColors.textSecondary)),
                    Text('${order.deliveryFee.toStringAsFixed(2)} ${AppStrings.sar}',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const Divider(color: AppColors.surfaceLight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.total,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Date
          GlassMorphCard(
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'وقت الطلب: ${DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(order.createdAt)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Back to home
          AppButton(
            label: 'العودة للرئيسية',
            onPressed: () => context.go('/home'),
            isOutlined: true,
            icon: Icons.home_outlined,
            width: double.infinity,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.thumb_up;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}
