import 'package:uuid/uuid.dart';

enum OptionGroupType { single, multiple }

class ItemOption {
  final String id;
  final String name;
  final double priceAdjustment;
  final bool isAvailable;

  const ItemOption({
    required this.id,
    required this.name,
    this.priceAdjustment = 0,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'priceAdjustment': priceAdjustment,
        'isAvailable': isAvailable,
      };

  factory ItemOption.fromMap(Map<String, dynamic> m) => ItemOption(
        id: m['id'] ?? const Uuid().v4(),
        name: m['name'] ?? '',
        priceAdjustment: (m['priceAdjustment'] ?? 0).toDouble(),
        isAvailable: m['isAvailable'] ?? true,
      );

  ItemOption copyWith({String? name, double? priceAdjustment, bool? isAvailable}) =>
      ItemOption(
        id: id,
        name: name ?? this.name,
        priceAdjustment: priceAdjustment ?? this.priceAdjustment,
        isAvailable: isAvailable ?? this.isAvailable,
      );
}

class OptionGroup {
  final String id;
  final String name;
  final OptionGroupType type;
  final bool required;
  final List<ItemOption> options;
  // يسمح للعميل بزيادة عدد الخيار المختار (مثل: جبن إضافي ×2) بعدّاد +/−
  // بدل الاكتفاء بتحديده مرة واحدة — يتضاعف فرق سعره حسب العدد
  final bool allowQuantity;
  // يظهر هذا القسم في شاشة توفر الأصناف بالمطبخ ليوقف خياراته ويعيدها. بدونه
  // لا يراه المطبخ ولا يستطيع تغييره (والخادم يرفض ذلك أيضاً)
  final bool kitchenControl;

  const OptionGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.required,
    required this.options,
    this.allowQuantity = false,
    this.kitchenControl = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'required': required,
        'options': options.map((o) => o.toMap()).toList(),
        'allowQuantity': allowQuantity,
        'kitchenControl': kitchenControl,
      };

  factory OptionGroup.fromMap(Map<String, dynamic> m) => OptionGroup(
        id: m['id'] ?? const Uuid().v4(),
        name: m['name'] ?? '',
        type: OptionGroupType.values.firstWhere(
          (t) => t.name == (m['type'] ?? 'single'),
          orElse: () => OptionGroupType.single,
        ),
        required: m['required'] ?? false,
        // Map<String, dynamic>.from(...) بدل (as Map<String, dynamic>)
        // مباشرة — فايربيس على الويب يعيد خرائط متداخلة داخل القوائم بنوع
        // لا يُقبَل بالتحويل المباشر (JSLinkedHashMap)، فيفشل التحويل
        // بصمت ويختفي الخيار المحفوظ فعلياً فور إعادة فتح الصنف
        options: (m['options'] as List? ?? [])
            .map((o) => ItemOption.fromMap(Map<String, dynamic>.from(o as Map)))
            .toList(),
        allowQuantity: m['allowQuantity'] ?? false,
        kitchenControl: m['kitchenControl'] == true,
      );

  // الخيارات المفعَّلة فقط — تُستخدَم في واجهة العميل حتى لا يرى/يختار
  // خياراً أوقفه المطبخ مؤقتاً (مثلاً نفدت مكوّناته)
  List<ItemOption> get availableOptions =>
      options.where((o) => o.isAvailable).toList();

  OptionGroup copyWith({
    String? name,
    OptionGroupType? type,
    bool? required,
    List<ItemOption>? options,
    bool? allowQuantity,
    bool? kitchenControl,
  }) =>
      OptionGroup(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        required: required ?? this.required,
        options: options ?? this.options,
        allowQuantity: allowQuantity ?? this.allowQuantity,
        kitchenControl: kitchenControl ?? this.kitchenControl,
      );
}

// Holds customer's selections for one group
class SelectedOptionGroup {
  final String groupId;
  final String groupName;
  final List<String> selectedIds;
  final List<String> selectedNames;
  final double totalExtra;

  const SelectedOptionGroup({
    required this.groupId,
    required this.groupName,
    required this.selectedIds,
    required this.selectedNames,
    required this.totalExtra,
  });

  String get summary => selectedNames.join('، ');

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'groupName': groupName,
        'selectedNames': selectedNames,
        'totalExtra': totalExtra,
      };
}
