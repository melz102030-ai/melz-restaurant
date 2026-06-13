import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _colOrders = 'orders';

  // Place new order
  static Future<String> placeOrder(OrderModel order) async {
    final ref = _db.collection(_colOrders).doc();
    final newOrder = OrderModel(
      id: ref.id,
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
    await ref.set(newOrder.toMap());
    return ref.id;
  }

  // Stream customer orders
  static Stream<List<OrderModel>> streamCustomerOrders(String customerId) {
    return _db
        .collection(_colOrders)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OrderModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Stream single order (for tracking)
  static Stream<OrderModel?> streamOrder(String orderId) {
    return _db
        .collection(_colOrders)
        .doc(orderId)
        .snapshots()
        .map((snap) =>
            snap.exists ? OrderModel.fromMap(snap.data()!, snap.id) : null);
  }

  // Stream all orders (admin)
  static Stream<List<OrderModel>> streamAllOrders({OrderStatus? status}) {
    Query<Map<String, dynamic>> query = _db.collection(_colOrders);
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OrderModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Stream active kitchen orders (pending, confirmed, preparing, ready)
  static Stream<List<OrderModel>> streamKitchenOrders() {
    return _db
        .collection(_colOrders)
        .where('status', whereIn: [
          OrderStatus.pending.name,
          OrderStatus.confirmed.name,
          OrderStatus.preparing.name,
          OrderStatus.ready.name,
        ])
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OrderModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Update order status
  static Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? estimatedTime,
    String? kitchenNotes,
  }) async {
    final update = <String, dynamic>{
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (estimatedTime != null) update['estimatedTime'] = estimatedTime;
    if (kitchenNotes != null) update['kitchenNotes'] = kitchenNotes;
    await _db.collection(_colOrders).doc(orderId).update(update);
  }

  // Cancel order (customer)
  static Future<void> cancelOrder(String orderId) async {
    await _db.collection(_colOrders).doc(orderId).update({
      'status': OrderStatus.cancelled.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Get orders summary for reports
  static Future<Map<String, dynamic>> getOrdersSummary({
    DateTime? from,
    DateTime? to,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(_colOrders);
    if (from != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    if (to != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }

    final snap = await query.get();
    final orders = snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList();

    double totalRevenue = 0;
    int completedOrders = 0;
    int cancelledOrders = 0;
    final itemSales = <String, int>{};

    for (final order in orders) {
      if (order.status == OrderStatus.delivered) {
        totalRevenue += order.total;
        completedOrders++;
        for (final item in order.items) {
          itemSales[item.name] = (itemSales[item.name] ?? 0) + item.quantity;
        }
      } else if (order.status == OrderStatus.cancelled) {
        cancelledOrders++;
      }
    }

    final sortedItems = itemSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalOrders': orders.length,
      'totalRevenue': totalRevenue,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'topItems': sortedItems.take(5).map((e) => {'name': e.key, 'count': e.value}).toList(),
    };
  }

  // Stream daily order counts for the last 7 days
  static Future<List<Map<String, dynamic>>> getDailyStats() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final snap = await _db
        .collection(_colOrders)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .get();

    final orders = snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList();
    final dailyMap = <String, Map<String, dynamic>>{};

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      dailyMap[key] = {'date': key, 'orders': 0, 'revenue': 0.0};
    }

    for (final order in orders) {
      final key = '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}';
      if (dailyMap.containsKey(key)) {
        dailyMap[key]!['orders'] = (dailyMap[key]!['orders'] as int) + 1;
        if (order.status == OrderStatus.delivered) {
          dailyMap[key]!['revenue'] = (dailyMap[key]!['revenue'] as double) + order.total;
        }
      }
    }

    return dailyMap.values.toList();
  }
}
