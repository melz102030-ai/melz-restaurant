import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/order_service.dart';

final customerOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return const Stream.empty();
  return OrderService.streamCustomerOrders(user.id);
});

final activeOrderProvider = Provider<OrderModel?>((ref) {
  final orders = ref.watch(customerOrdersStreamProvider).valueOrNull ?? [];
  return orders
      .where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .firstOrNull;
});

final trackOrderProvider =
    StreamProvider.family<OrderModel?, String>((ref, orderId) {
  final user = ref.watch(authProvider);
  // بينما تُستعاد الجلسة من IndexedDB، نبقى في حالة loading حتى لا تظهر
  // رسالة "الطلب غير موجود" بسبب رفض Firestore لغياب auth مؤقتاً
  if (user == null) {
    final ctrl = StreamController<OrderModel?>();
    ref.onDispose(ctrl.close);
    return ctrl.stream;
  }
  return OrderService.streamOrder(orderId);
});
