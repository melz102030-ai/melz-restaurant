import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/admin_provider.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminOrderStatsProvider);
    final dailyAsync = ref.watch(dailyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reportsAnalytics),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(adminOrderStatsProvider);
              ref.invalidate(dailyStatsProvider);
            },
            icon: const Icon(Icons.refresh),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary cards
              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _SummaryCard(
                          title: 'إجمالي الطلبات',
                          value: '${stats['totalOrders']}',
                          icon: Icons.receipt_long,
                          color: AppColors.purple,
                        ),
                        _SummaryCard(
                          title: 'إجمالي الإيرادات',
                          value: '${(stats['totalRevenue'] as double).toStringAsFixed(2)}',
                          subtitle: AppStrings.sar,
                          icon: Icons.monetization_on,
                          color: AppColors.manjawi,
                        ),
                        _SummaryCard(
                          title: 'مكتملة',
                          value: '${stats['completedOrders']}',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                        _SummaryCard(
                          title: 'ملغاة',
                          value: '${stats['cancelledOrders']}',
                          icon: Icons.cancel,
                          color: AppColors.error,
                        ),
                      ],
                    ),

                    // Completion rate
                    const SizedBox(height: 16),
                    GlassMorphCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معدل الإكمال',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Builder(builder: (_) {
                            final total = stats['totalOrders'] as int;
                            final completed = stats['completedOrders'] as int;
                            final rate = total == 0 ? 0.0 : completed / total;
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${(rate * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$completed من $total',
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: rate,
                                    backgroundColor: AppColors.surfaceLight,
                                    valueColor: const AlwaysStoppedAnimation(AppColors.success),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                loading: () => const LoadingWidget(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Revenue chart
              dailyAsync.when(
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الإيرادات اليومية',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassMorphCard(
                      child: SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            gridData: FlGridData(
                              show: true,
                              getDrawingHorizontalLine: (_) => const FlLine(
                                color: AppColors.surfaceLight,
                                strokeWidth: 1,
                              ),
                              drawVerticalLine: false,
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (v, _) {
                                    final idx = v.toInt();
                                    if (idx < 0 || idx >= data.length) {
                                      return const SizedBox();
                                    }
                                    final date = data[idx]['date'] as String;
                                    final parts = date.split('-');
                                    return Text(
                                      '${parts[2]}/${parts[1]}',
                                      style: const TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 9,
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
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: data.asMap().entries.map((e) {
                                  return FlSpot(
                                    e.key.toDouble(),
                                    (e.value['revenue'] as double),
                                  );
                                }).toList(),
                                isCurved: true,
                                gradient: AppColors.primaryGradient,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.purple.withOpacity(0.3),
                                      AppColors.purple.withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'عدد الطلبات اليومي',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassMorphCard(
                      child: SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => AppColors.surface,
                                getTooltipItem: (group, _, rod, __) {
                                  return BarTooltipItem(
                                    '${rod.toY.toInt()} طلب',
                                    const TextStyle(color: AppColors.manjawi),
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
                                    if (idx < 0 || idx >= data.length) return const SizedBox();
                                    final date = data[idx]['date'] as String;
                                    final parts = date.split('-');
                                    return Text(
                                      '${parts[2]}/${parts[1]}',
                                      style: const TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 9,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: data.asMap().entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: (e.value['orders'] as int).toDouble(),
                                    gradient: const LinearGradient(
                                      colors: [AppColors.manjawiDark, AppColors.manjawiLight],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
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
                    ),
                  ],
                ),
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
                            final count = item['count'] as int;
                            final maxCount = (topItems.first as Map)['count'] as int;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    '#$rank',
                                    style: TextStyle(
                                      color: rank == 1
                                          ? const Color(0xFFFFD700)
                                          : AppColors.textHint,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] as String,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: maxCount == 0 ? 0 : count / maxCount,
                                            backgroundColor: AppColors.surfaceLight,
                                            valueColor: AlwaysStoppedAnimation(
                                              rank == 1
                                                  ? const Color(0xFFFFD700)
                                                  : AppColors.purple,
                                            ),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$count',
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 2),
                  child: Text(
                    subtitle!,
                    style: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
                  ),
                ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
