import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';

class LocalOrderNotifier extends StateNotifier<List<OrderModel>> {
  LocalOrderNotifier() : super([]);
  static const _uuid = Uuid();

  String addOrder(OrderModel order) {
    final id = _uuid.v4();
    final newOrder = OrderModel(
      id: id,
      customerId: order.customerId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      items: order.items,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      total: order.total,
      status: OrderStatus.pending,
      notes: order.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [newOrder, ...state];
    return id;
  }

  void updateStatus(String orderId, OrderStatus status, {String? estimatedTime, String? kitchenNotes}) {
    state = state.map((o) {
      if (o.id != orderId) return o;
      return OrderModel(
        id: o.id,
        customerId: o.customerId,
        customerName: o.customerName,
        customerPhone: o.customerPhone,
        items: o.items,
        subtotal: o.subtotal,
        deliveryFee: o.deliveryFee,
        total: o.total,
        status: status,
        notes: o.notes,
        createdAt: o.createdAt,
        updatedAt: DateTime.now(),
        estimatedTime: estimatedTime ?? o.estimatedTime,
        kitchenNotes: kitchenNotes ?? o.kitchenNotes,
      );
    }).toList();
  }

  OrderModel? getById(String id) =>
      state.where((o) => o.id == id).firstOrNull;

  List<OrderModel> getByCustomer(String customerId) =>
      state.where((o) => o.customerId == customerId).toList();
}

final localOrderProvider =
    StateNotifierProvider<LocalOrderNotifier, List<OrderModel>>(
  (ref) => LocalOrderNotifier(),
);
