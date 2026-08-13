enum PopupAdLinkType { none, category, item, url }

// إعلان منبثق يظهر للعميل عند الدخول — صورة واحدة أو أكثر، وصف اختياري،
// وإمكانية الربط بفئة أو صنف أو رابط خارجي
class PopupAdModel {
  final String id;
  final List<String> imageUrls;
  final String? caption;
  final bool isActive;
  final int sortOrder;
  final bool autoScroll;
  final int autoScrollSeconds;
  final PopupAdLinkType linkType;
  final String? linkId; // معرّف الفئة أو الصنف حسب linkType
  final String? externalUrl;

  const PopupAdModel({
    required this.id,
    this.imageUrls = const [],
    this.caption,
    this.isActive = true,
    this.sortOrder = 0,
    this.autoScroll = true,
    this.autoScrollSeconds = 4,
    this.linkType = PopupAdLinkType.none,
    this.linkId,
    this.externalUrl,
  });

  factory PopupAdModel.fromMap(Map<String, dynamic> map, String id) {
    return PopupAdModel(
      id: id,
      imageUrls: List<String>.from(map['imageUrls'] ?? const []),
      caption: map['caption'],
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
      autoScroll: map['autoScroll'] ?? true,
      autoScrollSeconds: map['autoScrollSeconds'] ?? 4,
      linkType: PopupAdLinkType.values.firstWhere(
        (t) => t.name == (map['linkType'] ?? 'none'),
        orElse: () => PopupAdLinkType.none,
      ),
      linkId: map['linkId'],
      externalUrl: map['externalUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrls': imageUrls,
      'caption': caption,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'autoScroll': autoScroll,
      'autoScrollSeconds': autoScrollSeconds,
      'linkType': linkType.name,
      'linkId': linkId,
      'externalUrl': externalUrl,
    };
  }

  PopupAdModel copyWith({
    String? id,
    List<String>? imageUrls,
    String? caption,
    bool? isActive,
    int? sortOrder,
    bool? autoScroll,
    int? autoScrollSeconds,
    PopupAdLinkType? linkType,
    String? linkId,
    String? externalUrl,
  }) {
    return PopupAdModel(
      id: id ?? this.id,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      autoScroll: autoScroll ?? this.autoScroll,
      autoScrollSeconds: autoScrollSeconds ?? this.autoScrollSeconds,
      linkType: linkType ?? this.linkType,
      linkId: linkId ?? this.linkId,
      externalUrl: externalUrl ?? this.externalUrl,
    );
  }
}
