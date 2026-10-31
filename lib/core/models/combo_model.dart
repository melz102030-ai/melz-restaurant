class ComboItemRef {
  final String itemId;
  final int qty;

  const ComboItemRef({required this.itemId, this.qty = 1});

  factory ComboItemRef.fromMap(Map<String, dynamic> m) =>
      ComboItemRef(itemId: m['itemId'] as String, qty: (m['qty'] as num?)?.toInt() ?? 1);

  Map<String, dynamic> toMap() => {'itemId': itemId, 'qty': qty};
}

class ComboModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final bool isActive;
  final int sortOrder;
  final List<ComboItemRef> items;
  // الأصناف التي تظهر عليها هذه التركيبة (كزر "خليها وجبة!")
  final List<String> linkedItemIds;
  // أصناف يختار العميل واحداً منها إجبارياً عند طلب التركيبة
  final List<String> optionItemIds;
  // أسماء عناصر الوجبة (نص حر يدخله الأدمن) — تظهر في صفحة الصنف وشيت التركيبة
  final List<String> includedNames;

  const ComboModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    this.isActive = true,
    this.sortOrder = 0,
    this.items = const [],
    this.linkedItemIds = const [],
    this.optionItemIds = const [],
    this.includedNames = const [],
  });

  factory ComboModel.fromMap(Map<String, dynamic> map, String id) => ComboModel(
        id: id,
        name: map['name'] ?? '',
        description: map['description'],
        imageUrl: map['imageUrl'],
        price: (map['price'] ?? 0).toDouble(),
        isActive: map['isActive'] ?? true,
        sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
        items: (map['items'] as List? ?? [])
            .map((e) => ComboItemRef.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        linkedItemIds: _parseLinkedItemIds(map),
        optionItemIds: List<String>.from(map['optionItemIds'] ?? const []),
        includedNames: List<String>.from(map['includedNames'] ?? const []),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'price': price,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'items': items.map((e) => e.toMap()).toList(),
        'linkedItemIds': linkedItemIds,
        'optionItemIds': optionItemIds,
        'includedNames': includedNames,
      };

  ComboModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    bool? isActive,
    int? sortOrder,
    List<ComboItemRef>? items,
    List<String>? linkedItemIds,
    List<String>? optionItemIds,
    List<String>? includedNames,
  }) =>
      ComboModel(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        price: price ?? this.price,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
        items: items ?? this.items,
        linkedItemIds: linkedItemIds ?? this.linkedItemIds,
        optionItemIds: optionItemIds ?? this.optionItemIds,
        includedNames: includedNames ?? this.includedNames,
      );
}

// هجرة من linkedItemId (string قديم) إلى linkedItemIds (list جديد)
List<String> _parseLinkedItemIds(Map<String, dynamic> map) {
  final newList = map['linkedItemIds'];
  if (newList is List) return List<String>.from(newList);
  final oldId = map['linkedItemId'] as String?;
  if (oldId != null && oldId.isNotEmpty) return [oldId];
  return const [];
}
