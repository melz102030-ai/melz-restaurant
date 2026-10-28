import 'option_group_model.dart';

// قائمة ثابتة شاملة لمسبّبات الحساسية الشائعة (مطابقة لقائمة الاتحاد
// الأوروبي/الهيئة العامة للغذاء والدواء السعودية المكوّنة من ١٤ مسبّباً) —
// يختار الأدمن منها بدل كتابة نص حر يختلف بين صنف وآخر
const Map<String, String> kAllergens = {
  'gluten': 'الغلوتين (يشمل القمح والشعير والشوفان)',
  'crustaceans': 'القشريات (روبيان، كابوريا، جراد بحر)',
  'eggs': 'البيض',
  'fish': 'الأسماك',
  'peanuts': 'الفول السوداني',
  'soy': 'الصويا',
  'milk': 'الألبان (يشمل اللاكتوز)',
  'nuts': 'المكسرات (لوز، بندق، جوز، كاجو، فستق)',
  'celery': 'الكرفس',
  'mustard': 'الخردل',
  'sesame': 'السمسم',
  'sulphites': 'ثاني أكسيد الكبريت / الكبريتات',
  'lupin': 'الترمس',
  'molluscs': 'الرخويات (محار، حلزون، أخطبوط)',
};

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int sortOrder;
  final List<String> tags;
  final double? discountPercent;
  final List<OptionGroup> optionGroups;
  final bool isBestSeller;
  final bool isNew;
  // تركيبات اختيار جاهزة (اختيارية) تملأ كل مجموعات الخيارات دفعة واحدة
  final List<ItemPreset> presets;
  // معرّفات أصناف أخرى يقترحها الأدمن كـ"غالباً ما يُطلب معه"
  final List<String> suggestedItemIds;
  final int? calories;
  // معرّفات من kAllergens أعلاه
  final List<String> allergens;
  // مفتاح إظهار قسم السعرات/الحساسية للعميل — منفصل عن تعبئة البيانات نفسها،
  // حتى يستطيع الأدمن تجهيزها مسبقاً بلا إظهارها قبل اكتمالها/مراجعتها.
  // افتراضياً معطّل فلا يظهر قسم فارغ للأصناف التي لم تُعبَّأ بياناتها بعد.
  final bool showNutritionInfo;
  // معرّفات القوالب المرتبطة بهذا الصنف — يُستخدَم للاستعلام عنه في Firestore
  // عند تعديل قالب لتحديث مجموعات خياراته في الصنف تلقائياً
  final List<String> linkedTemplateIds;

  // ── إعدادات الصورة الشفافة ──────────────────────────────────────────────────
  // يمكّن للأصناف ذات صور PNG شفافة وضع لون خلفية خلفها بدل الخلفية الافتراضية
  final bool useTransparentBg;
  // اللون بصيغة hex بلا # (مثلاً: 'FFFFFF')
  final String imageBgColor;
  // مقياس الصورة داخل الإطار (1.0 = الحجم الطبيعي)
  final double imageScale;
  // إزاحة أفقية (موجبة = يمين)
  final double imageOffsetX;
  // إزاحة عمودية (موجبة = أسفل)
  final double imageOffsetY;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.sortOrder = 0,
    this.tags = const [],
    this.discountPercent,
    this.optionGroups = const [],
    this.isBestSeller = false,
    this.isNew = false,
    this.presets = const [],
    this.suggestedItemIds = const [],
    this.calories,
    this.allergens = const [],
    this.showNutritionInfo = false,
    this.linkedTemplateIds = const [],
    this.useTransparentBg = false,
    this.imageBgColor = 'FFFFFF',
    this.imageScale = 1.0,
    this.imageOffsetX = 0.0,
    this.imageOffsetY = 0.0,
  });

  double get finalPrice {
    if (discountPercent != null && discountPercent! > 0) {
      return price * (1 - discountPercent! / 100);
    }
    return price;
  }

  bool get hasDiscount => discountPercent != null && discountPercent! > 0;
  bool get hasOptions => optionGroups.isNotEmpty;

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      isAvailable: map['isAvailable'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      discountPercent: map['discountPercent']?.toDouble(),
      // Map<String, dynamic>.from(...) بدل (as Map<String, dynamic>) مباشرة
      // — راجع التعليق في OptionGroup.fromMap لسبب أهمية هذا على الويب
      optionGroups: (map['optionGroups'] as List? ?? [])
          .map((g) => OptionGroup.fromMap(Map<String, dynamic>.from(g as Map)))
          .toList(),
      isBestSeller: map['isBestSeller'] ?? false,
      isNew: map['isNew'] ?? false,
      presets: (map['presets'] as List? ?? [])
          .map((p) => ItemPreset.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList(),
      suggestedItemIds: List<String>.from(map['suggestedItemIds'] ?? []),
      // (map['calories'] as num?)?.toInt() بدل تحويل مباشر — Firestore على
      // الويب قد يعيد الأرقام كـdouble حتى لو كُتبت أصلاً كـint، فيكسر أي
      // تحويل ضمني مباشر إلى int؟ ويُسقط الصنف كاملاً من القائمة بصمت
      calories: (map['calories'] as num?)?.toInt(),
      allergens: List<String>.from(map['allergens'] ?? []),
      showNutritionInfo: map['showNutritionInfo'] ?? false,
      linkedTemplateIds: List<String>.from(map['linkedTemplateIds'] ?? []),
      useTransparentBg: map['useTransparentBg'] ?? false,
      imageBgColor: map['imageBgColor'] ?? 'FFFFFF',
      imageScale: (map['imageScale'] as num?)?.toDouble() ?? 1.0,
      imageOffsetX: (map['imageOffsetX'] as num?)?.toDouble() ?? 0.0,
      imageOffsetY: (map['imageOffsetY'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'sortOrder': sortOrder,
      'tags': tags,
      'discountPercent': discountPercent,
      'optionGroups': optionGroups.map((g) => g.toMap()).toList(),
      'isBestSeller': isBestSeller,
      'isNew': isNew,
      'presets': presets.map((p) => p.toMap()).toList(),
      'suggestedItemIds': suggestedItemIds,
      'calories': calories,
      'allergens': allergens,
      'showNutritionInfo': showNutritionInfo,
      'linkedTemplateIds': linkedTemplateIds,
      'useTransparentBg': useTransparentBg,
      'imageBgColor': imageBgColor,
      'imageScale': imageScale,
      'imageOffsetX': imageOffsetX,
      'imageOffsetY': imageOffsetY,
    };
  }

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    int? sortOrder,
    List<String>? tags,
    double? discountPercent,
    List<OptionGroup>? optionGroups,
    bool? isBestSeller,
    bool? isNew,
    List<ItemPreset>? presets,
    List<String>? suggestedItemIds,
    int? calories,
    List<String>? allergens,
    bool? showNutritionInfo,
    List<String>? linkedTemplateIds,
    bool? useTransparentBg,
    String? imageBgColor,
    double? imageScale,
    double? imageOffsetX,
    double? imageOffsetY,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      sortOrder: sortOrder ?? this.sortOrder,
      tags: tags ?? this.tags,
      discountPercent: discountPercent ?? this.discountPercent,
      optionGroups: optionGroups ?? this.optionGroups,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isNew: isNew ?? this.isNew,
      presets: presets ?? this.presets,
      suggestedItemIds: suggestedItemIds ?? this.suggestedItemIds,
      calories: calories ?? this.calories,
      allergens: allergens ?? this.allergens,
      showNutritionInfo: showNutritionInfo ?? this.showNutritionInfo,
      linkedTemplateIds: linkedTemplateIds ?? this.linkedTemplateIds,
      useTransparentBg: useTransparentBg ?? this.useTransparentBg,
      imageBgColor: imageBgColor ?? this.imageBgColor,
      imageScale: imageScale ?? this.imageScale,
      imageOffsetX: imageOffsetX ?? this.imageOffsetX,
      imageOffsetY: imageOffsetY ?? this.imageOffsetY,
    );
  }
}
