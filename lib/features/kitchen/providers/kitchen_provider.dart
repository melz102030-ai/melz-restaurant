import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';

final kitchenOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return OrderService.streamKitchenOrders();
});

final newKitchenOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(kitchenOrdersProvider).maybeWhen(
    data: (d) => d,
    orElse: () => <OrderModel>[],
  );
  return orders.where((o) => o.status == OrderStatus.pending).toList();
});

final inProgressKitchenOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(kitchenOrdersProvider).maybeWhen(
    data: (d) => d,
    orElse: () => <OrderModel>[],
  );
  return orders.where((o) =>
    o.status == OrderStatus.confirmed || o.status == OrderStatus.preparing
  ).toList();
});

final readyKitchenOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(kitchenOrdersProvider).maybeWhen(
    data: (d) => d,
    orElse: () => <OrderModel>[],
  );
  return orders.where((o) => o.status == OrderStatus.ready).toList();
});
