import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/orders_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final orders = ref.watch(customerOrdersStreamProvider).valueOrNull ?? [];

    if (user == null) {
      // لا يوجد نظام تسجيل دخول للعملاء — حساب الضيف المجهول يُنشأ تلقائياً
      // فقط لحظة إرسال أول طلب، فمن لم يطلب بعد على هذا الجهاز ببساطة لا
      // يملك سجلاً بعد، لا "تسجيل دخول" ناقصاً يحتاج إتمامه
      return Scaffold(
        body: EmptyState(
          message: 'لا يوجد سجل طلبات بعد على هذا الجهاز\nابدأ بتصفح القائمة واطلب!',
          icon: Icons.receipt_long_outlined,
          actionLabel: 'تصفّح القائمة',
          onAction: () => context.go('/home'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile header
            GlassMorphCard(
              child: Column(
                children: [
                  GradientContainer(
                    borderRadius: 50,
                    padding: const EdgeInsets.all(24),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),

                  Text(
                    user.phone,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'عميل مسجّل على هذا الجهاز',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            Builder(builder: (_) {
              final completed = orders.where((o) => o.status == OrderStatus.delivered).length;
              final totalSpent = orders
                  .where((o) => o.status == OrderStatus.delivered)
                  .fold(0.0, (sum, o) => sum + o.total);
              return Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'إجمالي الطلبات',
                      value: '${orders.length}',
                      icon: Icons.receipt_long,
                      color: AppColors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'طلبات مكتملة',
                      value: '$completed',
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'إجمالي الإنفاق',
                      value: '${totalSpent.toStringAsFixed(0)} ${AppStrings.sar}',
                      icon: Icons.attach_money,
                      color: AppColors.manjawi,
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            // Order history
            Text(
              'سجل الطلبات',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            Builder(builder: (_) {
              if (orders.isEmpty) {
                return const EmptyState(
                  message: 'لا توجد طلبات سابقة بعد\nابدأ بتصفح القائمة!',
                  icon: Icons.receipt_long_outlined,
                );
              }
              return Column(
                children: orders
                    .take(10)
                    .map((order) => _OrderHistoryTile(order: order))
                    .toList(),
              );
            }),

            const SizedBox(height: 24),

            // Support
            AppButton(
              label: 'الدعم الفني',
              onPressed: () => context.push('/support'),
              isOutlined: true,
              icon: Icons.support_agent_outlined,
              width: double.infinity,
            ),
            const SizedBox(height: 12),

            AppButton(
              label: 'تسجيل الخروج',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تسجيل الخروج'),
                    content: const Text(
                        'سيُمسح سجل طلباتك من هذا الجهاز، ولن تتمكن من رؤيتها هنا بعد ذلك.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('تراجع')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('خروج'),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/order-type');
              },
              isOutlined: true,
              icon: Icons.logout,
              color: AppColors.error,
              width: double.infinity,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassMorphCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: AppColors.textHint, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryTile extends StatelessWidget {
  final OrderModel order;
  const _OrderHistoryTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = order.status.color;

    return GestureDetector(
      onTap: () => context.push('/track/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.receipt_long, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.orderNumberLabel}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${order.items.length} عنصر · ${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(order.createdAt),
                    style: TextStyle(color: AppColors.textHint, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status.label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}
