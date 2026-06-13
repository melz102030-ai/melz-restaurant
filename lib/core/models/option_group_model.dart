import 'package:uuid/uuid.dart';

enum OptionGroupType { single, multiple }

class ItemOption {
  final String id;
  final String name;
  final double priceAdjustment;

  const ItemOption({
    required this.id,
    required this.name,
    this.priceAdjustment = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'priceAdjustment': priceAdjustment,
      };

  factory ItemOption.fromMap(Map<String, dynamic> m) => ItemOption(
        id: m['id'] ?? const Uuid().v4(),
        name: m['name'] ?? '',
        priceAdjustment: (m['priceAdjustment'] ?? 0).toDouble(),
      );

  ItemOption copyWith({String? name, double? priceAdjustment}) => ItemOption(
        id: id,
        name: name ?? this.name,
        priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      );
}

class OptionGroup {
  final String id;
  final String name;
  final OptionGroupType type;
  final bool required;
  final List<ItemOption> options;

  const OptionGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.required,
    required this.options,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'required': required,
        'options': options.map((o) => o.toMap()).toList(),
      };

  factory OptionGroup.fromMap(Map<String, dynamic> m) => OptionGroup(
        id: m['id'] ?? const Uuid().v4(),
        name: m['name'] ?? '',
        type: OptionGroupType.values.firstWhere(
          (t) => t.name == (m['type'] ?? 'single'),
          orElse: () => OptionGroupType.single,
        ),
        required: m['required'] ?? false,
        options: (m['options'] as List? ?? [])
            .map((o) => ItemOption.fromMap(o as Map<String, dynamic>))
            .toList(),
      );

  OptionGroup copyWith({
    String? name,
    OptionGroupType? type,
    bool? required,
    List<ItemOption>? options,
  }) =>
      OptionGroup(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        required: required ?? this.required,
        options: options ?? this.options,
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
