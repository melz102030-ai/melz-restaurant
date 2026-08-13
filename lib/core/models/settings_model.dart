import 'work_shift_model.dart';

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
  final bool deliveryEnabled;
  final double? restaurantLat;
  final double? restaurantLng;
  final bool useDeliveryZones;
  // جدول عمل تفصيلي: مفتاح اليوم (sun..sat) → قائمة شفتات ذلك اليوم (فارغة = عطلة)
  final Map<String, List<WorkShift>> workingHours;

  const RestaurantSettings({
    this.restaurantName = 'Meals',
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
    this.deliveryEnabled = true,
    this.restaurantLat,
    this.restaurantLng,
    this.useDeliveryZones = false,
    this.workingHours = const {},
  });

  bool get hasRestaurantLocation => restaurantLat != null && restaurantLng != null;

  // هل الجدول التفصيلي (شفتات لكل يوم) مُفعَّل؟ — يُفعَّل تلقائياً بمجرد أول حفظ
  // من شاشة "ساعات العمل"، ويأخذ الأولوية على openTime/closeTime القديمة
  bool get hasDetailedHours => workingHours.isNotEmpty;

  // هل المطعم مفتوح فعلياً الآن؟ (الوقت الحالي ضمن الجدول + المفتاح اليدوي)
  bool get effectivelyOpen {
    if (!isOpen || !allowOrders) return false;

    if (hasDetailedHours) {
      final now = DateTime.now();
      final shifts = workingHours[dayKeyForWeekday(now.weekday)] ?? const [];
      if (shifts.isEmpty) return false; // اليوم عطلة
      for (final s in shifts) {
        final open = _parseHHMM(s.open, now);
        final close = _parseHHMM(s.close, now);
        if (open == null || close == null) continue;
        // معالجة تجاوز منتصف الليل (مثال: 22:00 - 02:00)
        if (close.isBefore(open) || close.isAtSameMomentAs(open)) {
          if (now.isAfter(open) || now.isBefore(close)) return true;
        } else if (now.isAfter(open) && now.isBefore(close)) {
          return true;
        }
      }
      return false;
    }

    // نمط قديم: نطاق ساعات واحد يومي (قبل تفعيل الجدول التفصيلي)
    if (openTime.isEmpty || closeTime.isEmpty) return true;
    final now = DateTime.now();
    final open = _parseHHMM(openTime, now);
    final close = _parseHHMM(closeTime, now);
    if (open == null || close == null) return true;
    if (close.isBefore(open) || close.isAtSameMomentAs(open)) {
      return now.isAfter(open) || now.isBefore(close);
    }
    return now.isAfter(open) && now.isBefore(close);
  }

  static DateTime? _parseHHMM(String hhmm, DateTime date) {
    final parts = hhmm.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    if (h == null || m == null) return null;
    return DateTime(date.year, date.month, date.day, h, m);
  }

  static String fmtHHMM(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final isPm = h >= 12;
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:${m.toString().padLeft(2, '0')} ${isPm ? 'م' : 'ص'}';
  }

  String get openTimeLabel => fmtHHMM(openTime);
  String get closeTimeLabel => fmtHHMM(closeTime);
  String get scheduleLabel => '${fmtHHMM(openTime)} - ${fmtHHMM(closeTime)}';

  static Map<String, List<WorkShift>> _workingHoursFromMap(dynamic raw) {
    if (raw is! Map) return const {};
    final result = <String, List<WorkShift>>{};
    raw.forEach((key, value) {
      if (value is List) {
        result[key as String] = value
            .whereType<Map>()
            .map((m) => WorkShift.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }
    });
    return result;
  }

  static Map<String, dynamic> _workingHoursToMap(Map<String, List<WorkShift>> hours) {
    return hours.map((key, shifts) => MapEntry(key, shifts.map((s) => s.toMap()).toList()));
  }

  factory RestaurantSettings.fromMap(Map<String, dynamic> map) {
    return RestaurantSettings(
      restaurantName: map['restaurantName'] ?? 'Meals',
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
      deliveryEnabled: map['deliveryEnabled'] ?? true,
      restaurantLat: (map['restaurantLat'] as num?)?.toDouble(),
      restaurantLng: (map['restaurantLng'] as num?)?.toDouble(),
      useDeliveryZones: map['useDeliveryZones'] ?? false,
      workingHours: _workingHoursFromMap(map['workingHours']),
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
      'deliveryEnabled': deliveryEnabled,
      'restaurantLat': restaurantLat,
      'restaurantLng': restaurantLng,
      'useDeliveryZones': useDeliveryZones,
      'workingHours': _workingHoursToMap(workingHours),
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
    bool? deliveryEnabled,
    double? restaurantLat,
    double? restaurantLng,
    bool? useDeliveryZones,
    Map<String, List<WorkShift>>? workingHours,
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
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
      restaurantLat: restaurantLat ?? this.restaurantLat,
      restaurantLng: restaurantLng ?? this.restaurantLng,
      useDeliveryZones: useDeliveryZones ?? this.useDeliveryZones,
      workingHours: workingHours ?? this.workingHours,
    );
  }
}
