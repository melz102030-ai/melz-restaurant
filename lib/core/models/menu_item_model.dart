import 'option_group_model.dart';

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
      optionGroups: (map['optionGroups'] as List? ?? [])
          .map((g) => OptionGroup.fromMap(g as Map<String, dynamic>))
          .toList(),
      isBestSeller: map['isBestSeller'] ?? false,
      isNew: map['isNew'] ?? false,
      presets: (map['presets'] as List? ?? [])
          .map((p) => ItemPreset.fromMap(p as Map<String, dynamic>))
          .toList(),
      suggestedItemIds: List<String>.from(map['suggestedItemIds'] ?? []),
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
    );
  }
}
