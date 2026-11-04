import 'order_model.dart';

// ملخص الطلبات لفترة: الإيرادات من المسلَّم فقط، مفصولة عن رسوم التوصيل.
// «الأكثر مبيعاً» يعد ما طلبه العميل: الصنف أو التركيبة نفسها، بدون أصنافها الداخلية،
// ويجمع بمعرّف الصنف فلا يتفرق إذا تغير اسمه، ويعرض أحدث اسم له.
//
// الأيام المنتهية تُحفظ ملخصاتها (DaySummary)، فلا يقرأ التقرير كل طلب في كل مرة.
class DaySummary {
  int totalOrders = 0;
  int completedOrders = 0;
  int cancelledOrders = 0;
  double totalRevenue = 0;
  double deliveryFees = 0;
  final Map<String, ItemSales> items = {};

  DaySummary();

  void addOrder(OrderModel order) {
    totalOrders++;
    if (order.status == OrderStatus.cancelled) {
      cancelledOrders++;
      return;
    }
    if (order.status != OrderStatus.delivered) return;

    completedOrders++;
    totalRevenue += order.total;
    deliveryFees += order.deliveryFee;
    for (final item in order.items) {
      if (item.name.startsWith('↳')) continue;
      final key = item.menuItemId.isEmpty ? item.name : item.menuItemId;
      (items[key] ??= ItemSales()).add(
        item.name,
        item.shownQuantity,
        order.createdAt.millisecondsSinceEpoch,
      );
    }
  }

  void merge(DaySummary other) {
    totalOrders += other.totalOrders;
    completedOrders += other.completedOrders;
    cancelledOrders += other.cancelledOrders;
    totalRevenue += other.totalRevenue;
    deliveryFees += other.deliveryFees;
    other.items.forEach((key, sales) {
      (items[key] ??= ItemSales()).add(sales.name, sales.count, sales.lastOrderMs);
    });
  }

  Map<String, dynamic> toMap() => {
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'totalRevenue': totalRevenue,
        'deliveryFees': deliveryFees,
        'items': items.map((key, sales) => MapEntry(key, sales.toMap())),
      };

  factory DaySummary.fromMap(Map<String, dynamic> map) {
    final summary = DaySummary()
      ..totalOrders = (map['totalOrders'] as num?)?.toInt() ?? 0
      ..completedOrders = (map['completedOrders'] as num?)?.toInt() ?? 0
      ..cancelledOrders = (map['cancelledOrders'] as num?)?.toInt() ?? 0
      ..totalRevenue = (map['totalRevenue'] as num?)?.toDouble() ?? 0
      ..deliveryFees = (map['deliveryFees'] as num?)?.toDouble() ?? 0;
    Map<String, dynamic>.from(map['items'] as Map? ?? const {}).forEach((key, value) {
      summary.items[key] = ItemSales.fromMap(Map<String, dynamic>.from(value as Map));
    });
    return summary;
  }

  // النتيجة بالشكل الذي تعرضه شاشات التقارير
  Map<String, dynamic> toReport() {
    final ranked = items.values.toList()..sort((a, b) => b.count.compareTo(a.count));
    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'salesTotal': totalRevenue - deliveryFees,
      'deliveryFees': deliveryFees,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'topItems': ranked.take(5).map((s) => {'name': s.name, 'count': s.count}).toList(),
    };
  }
}

class ItemSales {
  String name = '';
  int count = 0;
  int lastOrderMs = -1;

  ItemSales();

  void add(String itemName, int quantity, int orderedAtMs) {
    count += quantity;
    if (orderedAtMs > lastOrderMs) {
      name = itemName;
      lastOrderMs = orderedAtMs;
    }
  }

  Map<String, dynamic> toMap() => {'name': name, 'count': count, 'lastOrderMs': lastOrderMs};

  factory ItemSales.fromMap(Map<String, dynamic> map) => ItemSales()
    ..name = map['name'] as String? ?? ''
    ..count = (map['count'] as num?)?.toInt() ?? 0
    ..lastOrderMs = (map['lastOrderMs'] as num?)?.toInt() ?? -1;
}

Map<String, dynamic> summarizeOrders(List<OrderModel> orders) {
  final summary = DaySummary();
  orders.forEach(summary.addOrder);
  return summary.toReport();
}

// ملخص لكل يوم عمل، بالمفتاح الذي تعطيه keyOf
Map<String, DaySummary> summarizeByDay(
  List<OrderModel> orders,
  String Function(DateTime createdAt) keyOf,
) {
  final days = <String, DaySummary>{};
  for (final order in orders) {
    (days[keyOf(order.createdAt)] ??= DaySummary()).addOrder(order);
  }
  return days;
}
