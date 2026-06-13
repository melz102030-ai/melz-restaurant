class RestaurantSettings {
  final String restaurantName;
  final String? logoUrl;
  final String? coverUrl;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final double deliveryFee;
  final double minOrderAmount;
  final int estimatedPrepTime;
  final String whatsappNumber;
  final String? address;
  final String? welcomeMessage;
  final bool allowOrders;

  const RestaurantSettings({
    this.restaurantName = 'ميلز',
    this.logoUrl,
    this.coverUrl,
    this.isOpen = true,
    this.openTime = '08:00',
    this.closeTime = '00:00',
    this.deliveryFee = 10,
    this.minOrderAmount = 30,
    this.estimatedPrepTime = 30,
    this.whatsappNumber = '',
    this.address,
    this.welcomeMessage,
    this.allowOrders = true,
  });

  factory RestaurantSettings.fromMap(Map<String, dynamic> map) {
    return RestaurantSettings(
      restaurantName: map['restaurantName'] ?? 'ميلز',
      logoUrl: map['logoUrl'],
      coverUrl: map['coverUrl'],
      isOpen: map['isOpen'] ?? true,
      openTime: map['openTime'] ?? '08:00',
      closeTime: map['closeTime'] ?? '00:00',
      deliveryFee: (map['deliveryFee'] ?? 10).toDouble(),
      minOrderAmount: (map['minOrderAmount'] ?? 30).toDouble(),
      estimatedPrepTime: map['estimatedPrepTime'] ?? 30,
      whatsappNumber: map['whatsappNumber'] ?? '',
      address: map['address'],
      welcomeMessage: map['welcomeMessage'],
      allowOrders: map['allowOrders'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantName': restaurantName,
      'logoUrl': logoUrl,
      'coverUrl': coverUrl,
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
      'deliveryFee': deliveryFee,
      'minOrderAmount': minOrderAmount,
      'estimatedPrepTime': estimatedPrepTime,
      'whatsappNumber': whatsappNumber,
      'address': address,
      'welcomeMessage': welcomeMessage,
      'allowOrders': allowOrders,
    };
  }

  RestaurantSettings copyWith({
    String? restaurantName,
    String? logoUrl,
    String? coverUrl,
    bool? isOpen,
    String? openTime,
    String? closeTime,
    double? deliveryFee,
    double? minOrderAmount,
    int? estimatedPrepTime,
    String? whatsappNumber,
    String? address,
    String? welcomeMessage,
    bool? allowOrders,
  }) {
    return RestaurantSettings(
      restaurantName: restaurantName ?? this.restaurantName,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      estimatedPrepTime: estimatedPrepTime ?? this.estimatedPrepTime,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      address: address ?? this.address,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      allowOrders: allowOrders ?? this.allowOrders,
    );
  }
}
