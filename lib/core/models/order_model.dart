import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

enum OrderType { delivery, pickup }

extension OrderTypeExt on OrderType {
  String get label => this == OrderType.delivery ? 'توصيل' : 'استلام من المطعم';
}

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.ready:
        return 'جاهز';
      case OrderStatus.outForDelivery:
        return 'في الطريق إليك 🚗';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغى';
    }
  }

  int get step {
    switch (this) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

// Summary of one option group selection (for order storage)
class OrderItemOption {
  final String groupName;
  final List<String> selectedNames;
  final double extra;

  const OrderItemOption({
    required this.groupName,
    required this.selectedNames,
    required this.extra,
  });

  String get summary => selectedNames.join('، ');

  factory OrderItemOption.fromMap(Map<String, dynamic> m) => OrderItemOption(
        groupName: m['groupName'] ?? '',
        selectedNames: List<String>.from(m['selectedNames'] ?? []),
        extra: (m['extra'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'groupName': groupName,
        'selectedNames': selectedNames,
        'extra': extra,
      };
}

class OrderItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final List<OrderItemOption> selectedOptions;

  const OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.selectedOptions = const [],
  });

  double get total => price * quantity;

  String get optionsSummary => selectedOptions
      .where((o) => o.selectedNames.isNotEmpty)
      .map((o) => '${o.groupName}: ${o.summary}')
      .join(' | ');

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItemId: map['menuItemId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'],
      selectedOptions: (map['selectedOptions'] as List? ?? [])
          .map((o) => OrderItemOption.fromMap(o as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'selectedOptions': selectedOptions.map((o) => o.toMap()).toList(),
    };
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? estimatedTime;
  final String? kitchenNotes;
  final int? estimatedMinutes;
  final DateTime? estimatedSetAt;
  final OrderType orderType;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? deliveryAddress;
  final String? deliveryZoneId;
  final String? deliveryZoneName;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedTime,
    this.kitchenNotes,
    this.estimatedMinutes,
    this.estimatedSetAt,
    this.orderType = OrderType.delivery,
    this.deliveryLat,
    this.deliveryLng,
    this.deliveryAddress,
    this.deliveryZoneId,
    this.deliveryZoneName,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.assignedAt,
    this.pickedUpAt,
  });

  bool get hasDeliveryLocation => deliveryLat != null && deliveryLng != null;

  // الوقت المتبقي حتى الجاهزية (سالب = تأخير)
  Duration? get remainingTime {
    if (estimatedMinutes == null || estimatedSetAt == null) return null;
    final endTime = estimatedSetAt!.add(Duration(minutes: estimatedMinutes!));
    return endTime.difference(DateTime.now());
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      notes: map['notes'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      estimatedTime: map['estimatedTime'],
      kitchenNotes: map['kitchenNotes'],
      estimatedMinutes: map['estimatedMinutes'] as int?,
      estimatedSetAt: map['estimatedSetAt'] is Timestamp
          ? (map['estimatedSetAt'] as Timestamp).toDate()
          : null,
      orderType: OrderType.values.firstWhere(
        (t) => t.name == (map['orderType'] ?? 'delivery'),
        orElse: () => OrderType.delivery,
      ),
      deliveryLat: (map['deliveryLat'] as num?)?.toDouble(),
      deliveryLng: (map['deliveryLng'] as num?)?.toDouble(),
      deliveryAddress: map['deliveryAddress'],
      deliveryZoneId: map['deliveryZoneId'],
      deliveryZoneName: map['deliveryZoneName'],
      driverId: map['driverId'],
      driverName: map['driverName'],
      driverPhone: map['driverPhone'],
      assignedAt: map['assignedAt'] is Timestamp
          ? (map['assignedAt'] as Timestamp).toDate()
          : null,
      pickedUpAt: map['pickedUpAt'] is Timestamp
          ? (map['pickedUpAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'estimatedTime': estimatedTime,
      'kitchenNotes': kitchenNotes,
      'estimatedMinutes': estimatedMinutes,
      'estimatedSetAt': estimatedSetAt != null
          ? Timestamp.fromDate(estimatedSetAt!)
          : null,
      'orderType': orderType.name,
      'deliveryLat': deliveryLat,
      'deliveryLng': deliveryLng,
      'deliveryAddress': deliveryAddress,
      'deliveryZoneId': deliveryZoneId,
      'deliveryZoneName': deliveryZoneName,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'pickedUpAt': pickedUpAt != null ? Timestamp.fromDate(pickedUpAt!) : null,
    };
  }

  OrderModel copyWith({
    OrderStatus? status,
    String? estimatedTime,
    String? kitchenNotes,
    int? estimatedMinutes,
    DateTime? estimatedSetAt,
    String? driverId,
    String? driverName,
    String? driverPhone,
    DateTime? assignedAt,
    DateTime? pickedUpAt,
  }) {
    return OrderModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: status ?? this.status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      estimatedTime: estimatedTime ?? this.estimatedTime,
      kitchenNotes: kitchenNotes ?? this.kitchenNotes,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      estimatedSetAt: estimatedSetAt ?? this.estimatedSetAt,
      orderType: orderType,
      deliveryLat: deliveryLat,
      deliveryLng: deliveryLng,
      deliveryAddress: deliveryAddress,
      deliveryZoneId: deliveryZoneId,
      deliveryZoneName: deliveryZoneName,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      assignedAt: assignedAt ?? this.assignedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
    );
  }
}
