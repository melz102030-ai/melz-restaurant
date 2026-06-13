class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final int sortOrder;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    required this.sortOrder,
    this.isActive = true,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'],
      sortOrder: map['sortOrder'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  CategoryModel copyWith({
    String? name,
    String? icon,
    int? sortOrder,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
