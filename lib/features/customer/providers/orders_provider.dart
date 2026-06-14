import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/local_order_provider.dart';

final customerOrdersProvider = Provider<List<OrderModel>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return [];
  return ref
      .watch(localOrderProvider)
      .where((o) => o.customerId == user.id)
      .toList();
});

final activeOrderProvider = Provider<OrderModel?>((ref) {
  final orders = ref.watch(customerOrdersProvider);
  return orders
      .where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .firstOrNull;
});

final trackOrderProvider = Provider.family<OrderModel?, String>((ref, orderId) {
  return ref.watch(localOrderProvider).where((o) => o.id == orderId).firstOrNull;
});
