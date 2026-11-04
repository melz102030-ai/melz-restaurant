import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/closing_report.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/menu_service.dart';

// اتصال واحد مشترك لكل شاشات الإدارة وتبويباتها: لكل قراءة ثمن، فلا يفتح كل تبويب
// اتصالاً خاصاً به، ولا تُقرأ طلبات قديمة إلا إذا طلبها المدير
const int adminOrdersPageSize = 100;

final recentOrdersLimitProvider = StateProvider<int>((ref) => adminOrdersPageSize);

final recentOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return OrderService.streamRecentOrders(ref.watch(recentOrdersLimitProvider));
});

final allOrdersProvider = Provider.family<AsyncValue<List<OrderModel>>, OrderStatus?>((ref, status) {
  return ref.watch(recentOrdersProvider).whenData(
        (orders) => status == null ? orders : orders.where((o) => o.status == status).toList(),
      );
});

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return AuthService.streamAllUsers();
});

// مدى زمني اختياري (from/to) — بلا تمرير أي منهما يعني كل الوقت منذ بداية
// التشغيل. الشاشات المستخدمة فيها تُحدِّد النطاق بوضوح بنفسها (اليوم للوحة
// التحكم كملخص سريع يومي، ونطاق قابل للاختيار في شاشة التقارير)
final adminOrderStatsProvider = FutureProvider.family<
    Map<String, dynamic>, ({DateTime? from, DateTime? to})>((ref, range) async {
  return OrderService.getOrdersSummary(ref.watch(settingsProvider), from: range.from);
});

final closingReportProvider =
    FutureProvider.autoDispose.family<ClosingReport, DateTime>((ref, dayStart) {
  return OrderService.getClosingReport(dayStart);
});

final dailyStatsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return OrderService.getDailyStats(ref.watch(settingsProvider));
});

final categoryItemCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  return MenuService.getCategoryItemCounts();
});
