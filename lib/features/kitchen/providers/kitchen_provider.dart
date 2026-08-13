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

final deliveringKitchenOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(kitchenOrdersProvider).maybeWhen(
    data: (d) => d,
    orElse: () => <OrderModel>[],
  );
  return orders.where((o) => o.status == OrderStatus.outForDelivery).toList();
});

final deliveredKitchenOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(kitchenOrdersProvider).maybeWhen(
    data: (d) => d,
    orElse: () => <OrderModel>[],
  );
  return orders.where((o) => o.status == OrderStatus.delivered).toList();
});

// عدد الطلبات النشطة (بانتظار تأكيد المندوب أو في الطريق) لكل مندوب — لتحديد "متاح" أو "مشغول"
final driverActiveOrderCountsProvider = Provider<Map<String, int>>((ref) {
  final orders = ref.watch(kitchenOrdersProvider).maybeWhen(
    data: (d) => d,
    orElse: () => <OrderModel>[],
  );
  final counts = <String, int>{};
  for (final o in orders) {
    final driverId = o.driverId;
    if (driverId == null) continue;
    if (o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled) {
      counts[driverId] = (counts[driverId] ?? 0) + 1;
    }
  }
  return counts;
});
