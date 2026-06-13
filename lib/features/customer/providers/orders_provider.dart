import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/order_service.dart';

final customerOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return const Stream.empty();
  return OrderService.streamCustomerOrders(user.id);
});

final activeOrderProvider = Provider<OrderModel?>((ref) {
  final orders = ref.watch(customerOrdersProvider).maybeWhen(
    data: (d) => d,
    orElse: () => <OrderModel>[],
  );
  return orders.where((o) =>
    o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled
  ).firstOrNull;
});

final trackOrderProvider = StreamProvider.family<OrderModel?, String>((ref, orderId) {
  return OrderService.streamOrder(orderId);
});
