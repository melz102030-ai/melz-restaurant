import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/menu_service.dart';

final allOrdersProvider = StreamProvider.family<List<OrderModel>, OrderStatus?>((ref, status) {
  return OrderService.streamAllOrders(status: status);
});

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return AuthService.streamAllUsers();
});

final adminOrderStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return OrderService.getOrdersSummary();
});

final dailyStatsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return OrderService.getDailyStats();
});

final categoryItemCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  return MenuService.getCategoryItemCounts();
});
