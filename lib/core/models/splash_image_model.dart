class SplashImageModel {
  final String id;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;

  const SplashImageModel({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory SplashImageModel.fromMap(Map<String, dynamic> map, String id) {
    return SplashImageModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      sortOrder: map['sortOrder'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }
}
