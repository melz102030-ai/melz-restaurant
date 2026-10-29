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
  // الصنف الرئيسي الذي تظهر عليه هذه التركيبة (كزر "خليها وجبة!")
  final String? linkedItemId;
  // أصناف يختار العميل واحداً منها إجبارياً عند طلب التركيبة
  final List<String> optionItemIds;

  const ComboModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    this.isActive = true,
    this.sortOrder = 0,
    this.items = const [],
    this.linkedItemId,
    this.optionItemIds = const [],
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
        linkedItemId: map['linkedItemId'] as String?,
        optionItemIds: List<String>.from(map['optionItemIds'] ?? const []),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'price': price,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'items': items.map((e) => e.toMap()).toList(),
        'linkedItemId': linkedItemId,
        'optionItemIds': optionItemIds,
      };

  ComboModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    bool? isActive,
    int? sortOrder,
    List<ComboItemRef>? items,
    Object? linkedItemId = _sentinel,
    List<String>? optionItemIds,
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
        linkedItemId: linkedItemId == _sentinel
            ? this.linkedItemId
            : linkedItemId as String?,
        optionItemIds: optionItemIds ?? this.optionItemIds,
      );
}

const _sentinel = Object();
