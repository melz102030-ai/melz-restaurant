enum BannerLinkType { none, category, item }

class PromoBannerModel {
  final String id;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;
  final BannerLinkType linkType;
  final String? linkId; // معرّف الفئة أو الصنف حسب linkType

  const PromoBannerModel({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.linkType = BannerLinkType.none,
    this.linkId,
  });

  factory PromoBannerModel.fromMap(Map<String, dynamic> map, String id) {
    return PromoBannerModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      sortOrder: map['sortOrder'] ?? 0,
      isActive: map['isActive'] ?? true,
      linkType: BannerLinkType.values.firstWhere(
        (t) => t.name == (map['linkType'] ?? 'none'),
        orElse: () => BannerLinkType.none,
      ),
      linkId: map['linkId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'linkType': linkType.name,
      'linkId': linkId,
    };
  }

  PromoBannerModel copyWith({
    String? id,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    BannerLinkType? linkType,
    String? linkId,
  }) {
    return PromoBannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      linkType: linkType ?? this.linkType,
      linkId: linkId ?? this.linkId,
    );
  }
}
