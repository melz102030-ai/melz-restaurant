import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/settings_service.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/admin_provider.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminOrderStatsProvider);
    final dailyAsync = ref.watch(dailyStatsProvider);
    final settings = ref.watch(settingsProvider);
    final activeOrdersAsync = ref.watch(allOrdersProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        automaticallyImplyLeading: false,
        actions: [
          // Toggle open/closed
          Row(
            children: [
              Text(
                settings.isOpen ? AppStrings.isOpen : AppStrings.isClosed,
                style: TextStyle(
                  color: settings.isOpen ? AppColors.success : AppColors.error,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Switch(
                value: settings.isOpen,
                onChanged: (v) => SettingsService.toggleRestaurantOpen(v),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminOrderStatsProvider);
          ref.invalidate(dailyStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              Text(
                'مرحباً بك في لوحة التحكم',
                style: Theme.of(context).textTheme.headlineSmall,
              ).animate().fadeIn(),
              const SizedBox(height: 4),
              const Text(
                'إدارة مطعمك من هنا',
                style: TextStyle(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),

              // Stats cards
              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: AppStrings.totalOrders,
                            value: '${stats['totalOrders']}',
                            icon: Icons.receipt_long,
                            gradient: AppColors.primaryGradient,
                            index: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: AppStrings.totalRevenue,
                            value: '${(stats['totalRevenue'] as double).toStringAsFixed(0)} ${AppStrings.sar}',
                            icon: Icons.attach_money,
                            gradient: const LinearGradient(
                              colors: [AppColors.manjawiDark, AppColors.manjawi],
                            ),
                            index: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'طلبات مكتملة',
                            value: '${stats['completedOrders']}',
                            icon: Icons.check_circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                            ),
                            index: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'طلبات ملغاة',
                            value: '${stats['cancelledOrders']}',
                            icon: Icons.cancel,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B0000), AppColors.red],
                            ),
                            index: 3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => const LoadingWidget(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Daily revenue chart
              dailyAsync.when(
                data: (dailyData) {
                  if (dailyData.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.purpleDark.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الإيرادات - آخر 7 أيام',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: dailyData
                                  .map((d) => (d['revenue'] as double))
                                  .fold(0.0, (a, b) => a > b ? a : b) * 1.2,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => AppColors.surface,
                                  getTooltipItem: (group, _, rod, __) {
                                    return BarTooltipItem(
                                      '${rod.toY.toStringAsFixed(0)} ر.س',
                                      const TextStyle(color: AppColors.purple),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      final idx = v.toInt();
                                      if (idx >= dailyData.length) return const SizedBox();
                                      final date = dailyData[idx]['date'] as String;
                                      final parts = date.split('-');
                                      return Text(
                                        '${parts[2]}/${parts[1]}',
                                        style: const TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: dailyData.asMap().entries.map((e) {
                                return BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (e.value['revenue'] as double),
                                      gradient: AppColors.primaryGradient,
                                      width: 20,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms);
                },
                loading: () => const LoadingWidget(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Active orders
              Row(
                children: [
                  const Text(
                    'الطلبات النشطة',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/admin/orders'),
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              activeOrdersAsync.when(
                data: (orders) {
                  final active = orders.where((o) =>
                    o.status != OrderStatus.delivered &&
                    o.status != OrderStatus.cancelled
                  ).take(5).toList();

                  if (active.isEmpty) {
                    return const GlassMorphCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'لا توجد طلبات نشطة حالياً',
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: active.map((o) => _ActiveOrderTile(order: o)).toList(),
                  );
                },
                loading: () => const LoadingWidget(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Top items
              statsAsync.when(
                data: (stats) {
                  final topItems = stats['topItems'] as List;
                  if (topItems.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الأكثر مبيعاً',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassMorphCard(
                        child: Column(
                          children: topItems.asMap().entries.map((e) {
                            final rank = e.key + 1;
                            final item = e.value as Map;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: rank == 1
                                          ? const Color(0xFFFFD700)
                                          : rank == 2
                                              ? const Color(0xFFC0C0C0)
                                              : rank == 3
                                                  ? const Color(0xFFCD7F32)
                                                  : AppColors.surfaceLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#$rank',
                                        style: TextStyle(
                                          color: rank <= 3 ? Colors.black : AppColors.textHint,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['name'] as String,
                                      style: const TextStyle(color: AppColors.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    '${item['count']} طلب',
                                    style: const TextStyle(
                                      color: AppColors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final int index;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100)).fadeIn().slideY(begin: 0.3);
  }
}

class _ActiveOrderTile extends StatelessWidget {
  final OrderModel order;
  const _ActiveOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      OrderStatus.pending: AppColors.statusPending,
      OrderStatus.confirmed: AppColors.statusConfirmed,
      OrderStatus.preparing: AppColors.statusPreparing,
      OrderStatus.ready: AppColors.statusReady,
    };
    final color = statusColors[order.status] ?? AppColors.textHint;

    return Container(
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
                  order.customerName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${order.items.length} عنصر · ${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
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
    );
  }
}
