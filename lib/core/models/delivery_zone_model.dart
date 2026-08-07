class DeliveryZone {
  final String id;
  final String name;
  final double maxDistanceKm;
  final double fee;
  final int order;

  const DeliveryZone({
    required this.id,
    required this.name,
    required this.maxDistanceKm,
    required this.fee,
    this.order = 0,
  });

  factory DeliveryZone.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryZone(
      id: id,
      name: map['name'] ?? '',
      maxDistanceKm: (map['maxDistanceKm'] ?? 0).toDouble(),
      fee: (map['fee'] ?? 0).toDouble(),
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'maxDistanceKm': maxDistanceKm,
      'fee': fee,
      'order': order,
    };
  }

  DeliveryZone copyWith({
    String? name,
    double? maxDistanceKm,
    double? fee,
    int? order,
  }) {
    return DeliveryZone(
      id: id,
      name: name ?? this.name,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      fee: fee ?? this.fee,
      order: order ?? this.order,
    );
  }
}
