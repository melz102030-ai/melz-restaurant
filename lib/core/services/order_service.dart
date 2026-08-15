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
      orderType: order.orderType,
      deliveryLat: order.deliveryLat,
      deliveryLng: order.deliveryLng,
      deliveryAddress: order.deliveryAddress,
      deliveryZoneId: order.deliveryZoneId,
      deliveryZoneName: order.deliveryZoneName,
    );
    await ref.set(newOrder.toMap());
    return ref.id;
  }

  // Stream customer orders — sort in Dart to avoid composite index
  static Stream<List<OrderModel>> streamCustomerOrders(String customerId) {
    return _db
        .collection(_colOrders)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((d) => OrderModel.fromMap(d.data(), d.id))
              .toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
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

  // Stream all orders (admin) — الترتيب في Dart لتجنب Composite Index
  static Stream<List<OrderModel>> streamAllOrders({OrderStatus? status}) {
    Query<Map<String, dynamic>> query = _db.collection(_colOrders);
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map((snap) {
      final orders = snap.docs
          .map((d) => OrderModel.fromMap(d.data(), d.id))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  // Stream kitchen orders — active + delivered in last 4 hours
  static Stream<List<OrderModel>> streamKitchenOrders() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 4));
    return _db
        .collection(_colOrders)
        .where('status', whereIn: [
          OrderStatus.pending.name,
          OrderStatus.confirmed.name,
          OrderStatus.preparing.name,
          OrderStatus.ready.name,
          OrderStatus.outForDelivery.name,
          OrderStatus.delivered.name,
        ])
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((d) => OrderModel.fromMap(d.data(), d.id))
              .toList();
          // Keep delivered only from last 4 hours
          final filtered = orders.where((o) =>
              o.status != OrderStatus.delivered ||
              o.updatedAt.isAfter(cutoff)).toList();
          filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return filtered;
        });
  }

  // بث حالة الاتصال بالخادم لنفس استعلام طلبات المطبخ — true يعني أن البيانات
  // المعروضة حالياً من الكاش المحلي فقط (لا اتصال فعلي)، لتنبيه المطبخ بدل
  // استمرار الشاشة بالعمل بصمت وكأن كل شيء محدَّث فعلياً
  static Stream<bool> streamKitchenConnectivity() {
    return _db
        .collection(_colOrders)
        .where('status', whereIn: [
          OrderStatus.pending.name,
          OrderStatus.confirmed.name,
          OrderStatus.preparing.name,
          OrderStatus.ready.name,
          OrderStatus.outForDelivery.name,
          OrderStatus.delivered.name,
        ])
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.metadata.isFromCache);
  }

  // دعوات تعيين لم يردّ عليها المندوب بعد — تُعرض له كـ"قبول/رفض" بغض النظر عن
  // مرحلة تجهيز الطلب (قد يُسنَد المندوب من لحظة وصول الطلب للمطبخ)
  // فلترة واحدة فقط في Firestore (driverId) والباقي في Dart لتجنب Composite Index
  static Stream<List<OrderModel>> streamDriverInvitations(String driverId) {
    return _db
        .collection(_colOrders)
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((d) => OrderModel.fromMap(d.data(), d.id))
              .where((o) =>
                  o.isAwaitingDriverAcceptance &&
                  o.status != OrderStatus.delivered &&
                  o.status != OrderStatus.cancelled)
              .toList();
          orders.sort((a, b) =>
              (a.assignedAt ?? a.createdAt).compareTo(b.assignedAt ?? b.createdAt));
          return orders;
        });
  }

  // الطلبات التي وافق عليها المندوب — جاهزة للاستلام أو في الطريق بالفعل
  // تبقى ظاهرة للمندوب من لحظة قبوله وحتى التسليم — تشمل مراحل التحضير في
  // المطبخ (قيد الانتظار/مؤكد/قيد التحضير)، لا فقط "جاهز"/"في الطريق"
  static Stream<List<OrderModel>> streamDriverOrders(String driverId) {
    return _db
        .collection(_colOrders)
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((d) => OrderModel.fromMap(d.data(), d.id))
              .where((o) =>
                  o.driverAcceptedAt != null &&
                  o.status != OrderStatus.delivered &&
                  o.status != OrderStatus.cancelled)
              .toList();
          // الطلب الجاهز فعلياً (أو الذي يحمله المندوب بالفعل) يُعتبر "الحالي"
          // بغض النظر عن ترتيب الإسناد الزمني — قبله كان طلب أُسنِد أولاً لكن
          // لا يزال قيد التحضير في المطبخ يحجب طلباً آخر جاهزاً فعلاً للاستلام
          int readinessRank(OrderModel o) {
            switch (o.status) {
              case OrderStatus.ready:
              case OrderStatus.outForDelivery:
                return 0;
              default:
                return 1;
            }
          }

          orders.sort((a, b) {
            final rankDiff = readinessRank(a).compareTo(readinessRank(b));
            if (rankDiff != 0) return rankDiff;
            return (a.assignedAt ?? a.createdAt).compareTo(b.assignedAt ?? b.createdAt);
          });
          return orders;
        });
  }

  // Assign a driver to a delivery order — من أي مرحلة تجهيز (حتى لحظة وصول الطلب)،
  // بانتظار موافقة المندوب قبل اعتباره مسؤولاً فعلياً عنه
  static Future<void> assignDriver(
      String orderId, String driverId, String driverName, String? driverPhone) async {
    await _db.collection(_colOrders).doc(orderId).update({
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'assignedAt': Timestamp.fromDate(DateTime.now()),
      'driverAcceptedAt': null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Kitchen/admin cancels a driver assignment (سواء بانتظار الموافقة أو بعدها) —
  // ممنوع بعد أن يكون المندوب قد استلم الطلب فعلياً وخرج للتوصيل، حتى لو
  // استُدعيت هذه الدالة من مكان لا يخفي الزر في تلك الحالة
  static Future<void> unassignDriver(String orderId) async {
    final doc = await _db.collection(_colOrders).doc(orderId).get();
    if (doc.data()?['status'] == OrderStatus.outForDelivery.name) {
      throw Exception('لا يمكن إلغاء تعيين المندوب بعد استلامه الطلب وخروجه للتوصيل');
    }
    await _db.collection(_colOrders).doc(orderId).update({
      'driverId': null,
      'driverName': null,
      'driverPhone': null,
      'assignedAt': null,
      'driverAcceptedAt': null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // المندوب يردّ على دعوة تعيين: قبول (يثبّت driverAcceptedAt) أو رفض (يُلغي إسناده بالكامل)
  static Future<void> respondToDriverAssignment(String orderId, {required bool accepted}) async {
    if (!accepted) {
      await unassignDriver(orderId);
      return;
    }
    await _db.collection(_colOrders).doc(orderId).update({
      'driverAcceptedAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Driver confirms pickup of an assigned order — moves it to "out for delivery"
  static Future<void> confirmPickup(String orderId) async {
    final now = DateTime.now();
    await _db.collection(_colOrders).doc(orderId).update({
      'status': OrderStatus.outForDelivery.name,
      'pickedUpAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  // Driver broadcasts live GPS position while an order is active
  static Future<void> updateDriverLocation(
    String orderId,
    double lat,
    double lng,
  ) async {
    await _db.collection(_colOrders).doc(orderId).update({
      'driverLat': lat,
      'driverLng': lng,
      'driverLocationUpdatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Update order status
  static Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? estimatedTime,
    String? kitchenNotes,
    int? estimatedMinutes,
  }) async {
    final now = DateTime.now();
    final update = <String, dynamic>{
      'status': status.name,
      'updatedAt': Timestamp.fromDate(now),
    };
    if (estimatedTime != null) update['estimatedTime'] = estimatedTime;
    if (kitchenNotes != null) update['kitchenNotes'] = kitchenNotes;
    if (estimatedMinutes != null) {
      update['estimatedMinutes'] = estimatedMinutes;
      update['estimatedSetAt'] = Timestamp.fromDate(now);
    }
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
