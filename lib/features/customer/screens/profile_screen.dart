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
  bool _isEditingName = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final ordersAsync = ref.watch(customerOrdersProvider);

    if (user == null) {
      return Scaffold(
        body: EmptyState(
          message: 'يرجى تسجيل الدخول أولاً',
          icon: Icons.person_off,
          actionLabel: 'تسجيل الدخول',
          onAction: () => context.go('/login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
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
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'E',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),

                  if (_isEditingName)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController..text = user.name,
                            autofocus: true,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'الاسم',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final name = _nameController.text.trim();
                            if (name.isNotEmpty) {
                              await ref.read(authProvider.notifier).updateName(name);
                            }
                            setState(() => _isEditingName = false);
                          },
                          icon: const Icon(Icons.check, color: AppColors.success),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _isEditingName = false),
                          icon: const Icon(Icons.close, color: AppColors.error),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _isEditingName = true),
                          icon: const Icon(Icons.edit, color: AppColors.textHint, size: 18),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),
                  Text(
                    user.phone,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            Builder(builder: (_) {
              final orders = ordersAsync;
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
            const Text(
              'سجل الطلبات',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            Builder(builder: (_) {
              final orders = ordersAsync;
              if (orders.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'لا توجد طلبات سابقة',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ),
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

            // Logout
            AppButton(
              label: AppStrings.logout,
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
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
            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
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
    final statusColors = {
      OrderStatus.pending: AppColors.statusPending,
      OrderStatus.confirmed: AppColors.statusConfirmed,
      OrderStatus.preparing: AppColors.statusPreparing,
      OrderStatus.ready: AppColors.statusReady,
      OrderStatus.delivered: AppColors.statusDelivered,
      OrderStatus.cancelled: AppColors.statusCancelled,
    };
    final color = statusColors[order.status] ?? AppColors.textHint;

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
                    '#${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${order.items.length} عنصر · ${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(order.createdAt),
                    style: const TextStyle(color: AppColors.textHint, fontSize: 11),
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
