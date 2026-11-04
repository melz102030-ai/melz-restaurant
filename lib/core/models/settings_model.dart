import 'work_shift_model.dart';

// سياسة قبول الدفع النقدي — الدفع الإلكتروني (بطاقة/آبل باي/مدى) غير مفعّل
// بعد في الواجهة، لذا "both/deliveryOnly/pickupOnly" تعني عملياً "الدفع
// النقدي مسموح" لنوع الاستلام المذكور. عند تفعيل بوابة دفع إلكتروني لاحقاً،
// هذا الحقل يبقى مستقلاً ويتحكم بالنقد تحديداً بلا تغيير في معناه.
enum CashPaymentPolicy { disabled, both, deliveryOnly, pickupOnly }

extension CashPaymentPolicyExt on CashPaymentPolicy {
  String get label {
    switch (this) {
      case CashPaymentPolicy.disabled:
        return 'الدفع نقداً غير متاح';
      case CashPaymentPolicy.both:
        return 'الدفع نقداً متاح للتوصيل والاستلام';
      case CashPaymentPolicy.deliveryOnly:
        return 'الدفع نقداً للتوصيل فقط';
      case CashPaymentPolicy.pickupOnly:
        return 'الدفع نقداً للاستلام من المطعم فقط';
    }
  }
}

CashPaymentPolicy _cashPolicyFromMap(dynamic raw) {
  return CashPaymentPolicy.values.firstWhere(
    (e) => e.name == raw,
    orElse: () => CashPaymentPolicy.both,
  );
}

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
  final String restaurantPhone;
  final String? googleReviewUrl;
  final String? address;
  final String? welcomeMessage;
  final bool allowOrders;
  final bool deliveryEnabled;
  final double? restaurantLat;
  final double? restaurantLng;
  final bool useDeliveryZones;
  // جدول عمل تفصيلي: مفتاح اليوم (sun..sat) → قائمة شفتات ذلك اليوم (فارغة = عطلة)
  final Map<String, List<WorkShift>> workingHours;
  final CashPaymentPolicy cashPaymentPolicy;
  // أيقونتا لعبة "احمِ القلب" (اللعب أثناء الانتظار) — تصميم مخصَّص من
  // الأدمن بدل الشكل الافتراضي (قلب Material + علامة X)؛ null = الافتراضي
  final String? gameHeartImageUrl;
  final String? gameObstacleImageUrl;
  // بيانات التحويل البنكي اليدوي — تُعرض للعميل عند اختيار "تحويل بنكي"
  final bool bankTransferEnabled;
  final String? bankIban;
  final String? bankAccountHolderName;
  final String? bankName;
  // نظام المناديب: 'full' = النظام الكامل داخل التطبيق (تعيين/قبول/تتبع حي)،
  // 'whatsapp' = المطعم يرسل بيانات الطلب يدوياً لمندوب عبر واتساب خارج
  // التطبيق — شاشة المطبخ تستبدل زر "تعيين مندوب" بزر "نسخ بيانات الطلب"
  final String driverSystemMode;
  // الدعم الفني: 'app' = تذاكر دعم داخل التطبيق يراجعها الأدمن من لوحة
  // التحكم، 'whatsapp' = يفتح العميل محادثة واتساب مباشرة لرقم يحدّده
  // الأدمن (supportWhatsappNumber)، بدل whatsappNumber العام للتواصل
  final String supportMode;
  final String? supportWhatsappNumber;
  // تفعيل/إيقاف كولاج الصور المتحركة في شاشة التحميل الأولى — يُقرأ مباشرة
  // من web/index.html (جافاسكربت عادي، قبل تحميل فلاتر) لا من كود Dart
  final bool splashCollageEnabled;

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
    this.restaurantPhone = '',
    this.googleReviewUrl,
    this.address,
    this.welcomeMessage,
    this.allowOrders = true,
    this.deliveryEnabled = true,
    this.restaurantLat,
    this.restaurantLng,
    this.useDeliveryZones = false,
    this.workingHours = const {},
    this.cashPaymentPolicy = CashPaymentPolicy.both,
    this.gameHeartImageUrl,
    this.gameObstacleImageUrl,
    this.bankTransferEnabled = true,
    this.bankIban,
    this.bankAccountHolderName,
    this.bankName,
    this.driverSystemMode = 'full',
    this.supportMode = 'app',
    this.supportWhatsappNumber,
    this.splashCollageEnabled = true,
  });

  bool get isWhatsappDriverMode => driverSystemMode == 'whatsapp';
  bool get isWhatsappSupportMode => supportMode == 'whatsapp';
  // الرقم الفعلي لواتساب الدعم — يسقط على رقم التواصل العام إن لم يُحدَّد
  // رقم مخصَّص للدعم تحديداً
  String get effectiveSupportWhatsapp =>
      (supportWhatsappNumber ?? '').trim().isNotEmpty
          ? supportWhatsappNumber!.trim()
          : whatsappNumber;

  // هل الدفع نقداً مسموح لنوع استلام معيّن (توصيل/استلام من المطعم)؟
  bool cashAllowedFor({required bool isDelivery}) {
    switch (cashPaymentPolicy) {
      case CashPaymentPolicy.disabled:
        return false;
      case CashPaymentPolicy.both:
        return true;
      case CashPaymentPolicy.deliveryOnly:
        return isDelivery;
      case CashPaymentPolicy.pickupOnly:
        return !isDelivery;
    }
  }

  bool get hasRestaurantLocation => restaurantLat != null && restaurantLng != null;

  bool get hasBankTransferInfo => (bankIban ?? '').trim().isNotEmpty;

  // هل الجدول التفصيلي (شفتات لكل يوم) مُفعَّل؟ — يُفعَّل تلقائياً بمجرد أول حفظ
  // من شاشة "ساعات العمل"، ويأخذ الأولوية على openTime/closeTime القديمة
  bool get hasDetailedHours => workingHours.isNotEmpty;

  // هل المطعم مفتوح فعلياً الآن؟ (الوقت الحالي ضمن الجدول + المفتاح اليدوي)
  bool get effectivelyOpen {
    if (!isOpen || !allowOrders) return false;

    // يشمل فترة بدأت أمس وتمتد لبعد منتصف الليل حتى لو كان اليوم عطلة
    if (hasDetailedHours) return _currentOpenShift != null;

    // نمط قديم: نطاق ساعات واحد يومي (قبل تفعيل الجدول التفصيلي)
    if (openTime.isEmpty || closeTime.isEmpty) return true;
    final now = _riyadhNow();
    final open = _parseHHMM(openTime, now);
    final close = _parseHHMM(closeTime, now);
    if (open == null || close == null) return true;
    if (close.isBefore(open) || close.isAtSameMomentAs(open)) {
      return now.isAfter(open) || now.isBefore(close);
    }
    return now.isAfter(open) && now.isBefore(close);
  }

  // ─── يوم العمل ─────────────────────────────────────────────────────────────
  // يوم العمل يبدأ عند آخر إغلاق يمتد بعد منتصف الليل، لا عند الساعة 12: طلب
  // الساعة 1 ليلاً تابع لوردية الأمس. بلا فترات ليلية يبدأ من منتصف الليل.
  int get businessDayStartMinutes {
    int minutesOf(String hhmm) {
      final parts = hhmm.trim().split(':');
      if (parts.length != 2) return -1;
      final h = int.tryParse(parts[0].trim());
      final m = int.tryParse(parts[1].trim());
      return h == null || m == null ? -1 : h * 60 + m;
    }

    final shifts = hasDetailedHours
        ? workingHours.values.expand((s) => s).map((s) => (s.open, s.close))
        : [(openTime, closeTime)];
    var start = 0;
    for (final (open, close) in shifts) {
      final o = minutesOf(open);
      final c = minutesOf(close);
      if (o < 0 || c < 0 || c >= o) continue; // لا تمتد بعد منتصف الليل
      if (c > start) start = c;
    }
    return start;
  }

  // بداية يوم العمل الذي تقع فيه هذه اللحظة، بتوقيت عالمي، بتوقيت الرياض دائماً
  DateTime businessDayStartOf(DateTime instant) {
    final shifted = instant
        .toUtc()
        .add(const Duration(hours: 3))
        .subtract(Duration(minutes: businessDayStartMinutes));
    return DateTime.utc(shifted.year, shifted.month, shifted.day)
        .add(Duration(minutes: businessDayStartMinutes))
        .subtract(const Duration(hours: 3));
  }

  DateTime get currentBusinessDayStart => businessDayStartOf(DateTime.now());

  // مفتاح يوم العمل YYYY-MM-DD لتجميع الطلبات في التقارير
  String businessDayKeyOf(DateTime instant) {
    final d = businessDayStartOf(instant).add(const Duration(hours: 3));
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  // أوقات العمل بتوقيت المطعم دائماً، لا بساعة جهاز العميل أو منطقته الزمنية
  static DateTime _riyadhNow() {
    final t = DateTime.now().toUtc().add(const Duration(hours: 3));
    return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
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

  // الفترة المفتوحة فعلياً الآن من الجدول التفصيلي — تشمل فترة بدأت أمس
  // وتمتد لبعد منتصف الليل (مثال: 4 م - 4 ص) ولا تزال سارية؛ null إن كان
  // المطعم مغلقاً حالياً حسب الجدول
  WorkShift? get _currentOpenShift {
    if (!hasDetailedHours) return null;
    final now = _riyadhNow();
    final todayShifts = workingHours[dayKeyForWeekday(now.weekday)] ?? const [];
    for (final s in todayShifts) {
      final open = _parseHHMM(s.open, now);
      final close = _parseHHMM(s.close, now);
      if (open == null || close == null) continue;
      if (close.isBefore(open) || close.isAtSameMomentAs(open)) {
        if (now.isAfter(open)) return s;
      } else if (now.isAfter(open) && now.isBefore(close)) {
        return s;
      }
    }
    // فترة بدأت أمس وتمتد لبعد منتصف الليل ولا تزال سارية الآن
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayShifts = workingHours[dayKeyForWeekday(yesterday.weekday)] ?? const [];
    for (final s in yesterdayShifts) {
      final open = _parseHHMM(s.open, yesterday);
      final closeYesterday = _parseHHMM(s.close, yesterday);
      if (open == null || closeYesterday == null) continue;
      if (closeYesterday.isBefore(open) || closeYesterday.isAtSameMomentAs(open)) {
        final closeToday =
            DateTime(now.year, now.month, now.day, closeYesterday.hour, closeYesterday.minute);
        if (now.isBefore(closeToday)) return s;
      }
    }
    return null;
  }

  // أقرب فترة قادمة سيُفتح فيها المطعم (يبحث حتى 7 أيام قدماً) — لعرض وقت
  // الفتح الصحيح للعميل عندما يكون مغلقاً حالياً
  WorkShift? get _nextOpeningShift {
    if (!hasDetailedHours) return null;
    final now = _riyadhNow();
    for (var dayOffset = 0; dayOffset < 8; dayOffset++) {
      final day = now.add(Duration(days: dayOffset));
      final shifts = workingHours[dayKeyForWeekday(day.weekday)] ?? const [];
      WorkShift? best;
      DateTime? bestOpen;
      for (final s in shifts) {
        final open = _parseHHMM(s.open, day);
        if (open == null) continue;
        if (dayOffset == 0 && !open.isAfter(now)) continue; // فات وقتها اليوم
        if (bestOpen == null || open.isBefore(bestOpen)) {
          bestOpen = open;
          best = s;
        }
      }
      if (best != null) return best;
    }
    return null;
  }

  // عند تفعيل الجدول التفصيلي، تُحسب هذه التسميات من الفترة الفعلية
  // الحالية/القادمة (تفهم الفترات الليلية الممتدة لما بعد منتصف الليل)
  // بدل openTime/closeTime القديمين اللذين لا علاقة لهما بالجدول التفصيلي
  String get openTimeLabel {
    if (hasDetailedHours) {
      final shift = _nextOpeningShift;
      if (shift != null) return fmtHHMM(shift.open);
    }
    return fmtHHMM(openTime);
  }

  String get closeTimeLabel {
    if (hasDetailedHours) {
      final shift = _currentOpenShift;
      if (shift != null) return fmtHHMM(shift.close);
    }
    return fmtHHMM(closeTime);
  }

  String get scheduleLabel => '$openTimeLabel - $closeTimeLabel';

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
      restaurantPhone: map['restaurantPhone'] ?? '',
      googleReviewUrl: map['googleReviewUrl'],
      address: map['address'],
      welcomeMessage: map['welcomeMessage'],
      allowOrders: map['allowOrders'] ?? true,
      deliveryEnabled: map['deliveryEnabled'] ?? true,
      restaurantLat: (map['restaurantLat'] as num?)?.toDouble(),
      restaurantLng: (map['restaurantLng'] as num?)?.toDouble(),
      useDeliveryZones: map['useDeliveryZones'] ?? false,
      workingHours: _workingHoursFromMap(map['workingHours']),
      cashPaymentPolicy: _cashPolicyFromMap(map['cashPaymentPolicy']),
      gameHeartImageUrl: map['gameHeartImageUrl'],
      gameObstacleImageUrl: map['gameObstacleImageUrl'],
      bankTransferEnabled: map['bankTransferEnabled'] ?? true,
      bankIban: map['bankIban'],
      bankAccountHolderName: map['bankAccountHolderName'],
      bankName: map['bankName'],
      driverSystemMode: map['driverSystemMode'] ?? 'full',
      supportMode: map['supportMode'] ?? 'app',
      supportWhatsappNumber: map['supportWhatsappNumber'],
      splashCollageEnabled: map['splashCollageEnabled'] ?? true,
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
      'restaurantPhone': restaurantPhone,
      'googleReviewUrl': googleReviewUrl,
      'address': address,
      'welcomeMessage': welcomeMessage,
      'allowOrders': allowOrders,
      'deliveryEnabled': deliveryEnabled,
      'restaurantLat': restaurantLat,
      'restaurantLng': restaurantLng,
      'useDeliveryZones': useDeliveryZones,
      'workingHours': _workingHoursToMap(workingHours),
      'cashPaymentPolicy': cashPaymentPolicy.name,
      'gameHeartImageUrl': gameHeartImageUrl,
      'gameObstacleImageUrl': gameObstacleImageUrl,
      'bankTransferEnabled': bankTransferEnabled,
      'bankIban': bankIban,
      'bankAccountHolderName': bankAccountHolderName,
      'bankName': bankName,
      'driverSystemMode': driverSystemMode,
      'supportMode': supportMode,
      'supportWhatsappNumber': supportWhatsappNumber,
      'splashCollageEnabled': splashCollageEnabled,
    };
  }

  // للحقول النصية الاختيارية: عدم تمرير القيمة يبقيها، والنص الفارغ يمسحها
  static String? _keepOrClear(String? value, String? current) {
    if (value == null) return current;
    return value.trim().isEmpty ? null : value;
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
    String? restaurantPhone,
    String? googleReviewUrl,
    String? address,
    String? welcomeMessage,
    bool? allowOrders,
    bool? deliveryEnabled,
    double? restaurantLat,
    double? restaurantLng,
    bool? useDeliveryZones,
    Map<String, List<WorkShift>>? workingHours,
    CashPaymentPolicy? cashPaymentPolicy,
    String? gameHeartImageUrl,
    String? gameObstacleImageUrl,
    bool? bankTransferEnabled,
    String? bankIban,
    String? bankAccountHolderName,
    String? bankName,
    String? driverSystemMode,
    String? supportMode,
    String? supportWhatsappNumber,
    bool? splashCollageEnabled,
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
      restaurantPhone: restaurantPhone ?? this.restaurantPhone,
      googleReviewUrl: _keepOrClear(googleReviewUrl, this.googleReviewUrl),
      address: _keepOrClear(address, this.address),
      welcomeMessage: _keepOrClear(welcomeMessage, this.welcomeMessage),
      allowOrders: allowOrders ?? this.allowOrders,
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
      restaurantLat: restaurantLat ?? this.restaurantLat,
      restaurantLng: restaurantLng ?? this.restaurantLng,
      useDeliveryZones: useDeliveryZones ?? this.useDeliveryZones,
      workingHours: workingHours ?? this.workingHours,
      cashPaymentPolicy: cashPaymentPolicy ?? this.cashPaymentPolicy,
      gameHeartImageUrl: gameHeartImageUrl ?? this.gameHeartImageUrl,
      gameObstacleImageUrl: gameObstacleImageUrl ?? this.gameObstacleImageUrl,
      bankTransferEnabled: bankTransferEnabled ?? this.bankTransferEnabled,
      bankIban: _keepOrClear(bankIban, this.bankIban),
      bankAccountHolderName: _keepOrClear(bankAccountHolderName, this.bankAccountHolderName),
      bankName: _keepOrClear(bankName, this.bankName),
      driverSystemMode: driverSystemMode ?? this.driverSystemMode,
      supportMode: supportMode ?? this.supportMode,
      supportWhatsappNumber: _keepOrClear(supportWhatsappNumber, this.supportWhatsappNumber),
      splashCollageEnabled: splashCollageEnabled ?? this.splashCollageEnabled,
    );
  }
}
