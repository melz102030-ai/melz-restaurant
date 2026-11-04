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
  // سعر الصنف يُعرض فقط ولا يُحتسب — المبلغ الفعلي يأتي من الخيارات وحدها
  // (مثال: صنف الصوصات يُعرض بـ 3 ريال، وكل صوص يختاره العميل يضيف 3 ريال)
  final bool excludeBasePrice;

  // ── إعدادات الصورة الشفافة ──────────────────────────────────────────────────
  // يمكّن وضع لون خلفية خلف صورة PNG شفافة — اللون نفسه عالمي من AppThemeSettings
  final bool useTransparentBg;
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
    this.suggestedItemIds = const [],
    this.calories,
    this.allergens = const [],
    this.showNutritionInfo = false,
    this.linkedTemplateIds = const [],
    this.excludeBasePrice = false,
    this.useTransparentBg = false,
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

  // السعر الأساسي الداخل فعلياً في حساب السلة والطلب (صفر إن كان مستثنى)
  double get chargedBasePrice => excludeBasePrice ? 0 : finalPrice;

  // نافذة التعديل قد تبقى مفتوحة بينما يوقف المطبخ صنفاً أو خياراً نفد. عند الحفظ
  // تؤخذ حالة التوفر من أحدث نسخة، إلا ما غيّره المدير بنفسه في النافذة. هذا الصنف
  // هو نسخة المدير، وoriginal ما فتح به النافذة، وlatest الموجود الآن في القاعدة.
  MenuItemModel withLatestAvailability({
    required MenuItemModel original,
    required MenuItemModel latest,
  }) {
    ItemOption? findOption(MenuItemModel item, String groupId, String optionId) {
      final group = item.optionGroups.where((g) => g.id == groupId).firstOrNull;
      return group?.options.where((o) => o.id == optionId).firstOrNull;
    }

    return copyWith(
      isAvailable: isAvailable == original.isAvailable ? latest.isAvailable : isAvailable,
      optionGroups: [
        for (final group in optionGroups)
          group.copyWith(
            options: [
              for (final option in group.options)
                () {
                  final before = findOption(original, group.id, option.id);
                  final now = findOption(latest, group.id, option.id);
                  final changedByAdmin =
                      before == null || before.isAvailable != option.isAvailable;
                  return changedByAdmin || now == null
                      ? option
                      : option.copyWith(isAvailable: now.isAvailable);
                }(),
            ],
          ),
      ],
    );
  }

  // مجموعات الصنف بعد تعديل قالبها: تبقى في مكانها بين مجموعات الصنف، ويبقى الخيار
  // الموقوف موقوفاً، وتُزال المجموعة المكررة من نفس القالب
  List<OptionGroup> optionGroupsWithTemplate(String templateId, List<OptionGroup> templateGroups) {
    OptionGroup linked(OptionGroup fresh, OptionGroup? existing) => fresh.copyWith(
          sourceTemplateId: templateId,
          options: [
            for (final option in fresh.options)
              option.copyWith(
                isAvailable: existing?.options
                        .where((o) => o.id == option.id)
                        .firstOrNull
                        ?.isAvailable ??
                    option.isAvailable,
              ),
          ],
        );

    final placed = <String>{};
    final result = <OptionGroup>[];
    var insertAt = -1;
    for (final group in optionGroups) {
      if (group.sourceTemplateId != templateId) {
        result.add(group);
        continue;
      }
      final fresh = templateGroups.where((g) => g.id == group.id).firstOrNull;
      if (fresh != null && placed.add(group.id)) result.add(linked(fresh, group));
      insertAt = result.length;
    }
    final added = [
      for (final g in templateGroups)
        if (!placed.contains(g.id)) linked(g, null),
    ];
    result.insertAll(insertAt < 0 ? result.length : insertAt, added);
    return result;
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
      suggestedItemIds: List<String>.from(map['suggestedItemIds'] ?? []),
      // (map['calories'] as num?)?.toInt() بدل تحويل مباشر — Firestore على
      // الويب قد يعيد الأرقام كـdouble حتى لو كُتبت أصلاً كـint، فيكسر أي
      // تحويل ضمني مباشر إلى int؟ ويُسقط الصنف كاملاً من القائمة بصمت
      calories: (map['calories'] as num?)?.toInt(),
      allergens: List<String>.from(map['allergens'] ?? []),
      showNutritionInfo: map['showNutritionInfo'] ?? false,
      linkedTemplateIds: List<String>.from(map['linkedTemplateIds'] ?? []),
      excludeBasePrice: map['excludeBasePrice'] ?? false,
      useTransparentBg: map['useTransparentBg'] ?? false,
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
      'suggestedItemIds': suggestedItemIds,
      'calories': calories,
      'allergens': allergens,
      'showNutritionInfo': showNutritionInfo,
      'linkedTemplateIds': linkedTemplateIds,
      'excludeBasePrice': excludeBasePrice,
      'useTransparentBg': useTransparentBg,
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
    List<String>? suggestedItemIds,
    int? calories,
    List<String>? allergens,
    bool? showNutritionInfo,
    List<String>? linkedTemplateIds,
    bool? excludeBasePrice,
    bool? useTransparentBg,
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
      suggestedItemIds: suggestedItemIds ?? this.suggestedItemIds,
      calories: calories ?? this.calories,
      allergens: allergens ?? this.allergens,
      showNutritionInfo: showNutritionInfo ?? this.showNutritionInfo,
      linkedTemplateIds: linkedTemplateIds ?? this.linkedTemplateIds,
      excludeBasePrice: excludeBasePrice ?? this.excludeBasePrice,
      useTransparentBg: useTransparentBg ?? this.useTransparentBg,
      imageScale: imageScale ?? this.imageScale,
      imageOffsetX: imageOffsetX ?? this.imageOffsetX,
      imageOffsetY: imageOffsetY ?? this.imageOffsetY,
    );
  }
}
