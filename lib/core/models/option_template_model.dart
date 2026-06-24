import 'option_group_model.dart';

class OptionTemplateModel {
  final String id;
  final String name;
  final List<OptionGroup> groups;

  const OptionTemplateModel({
    required this.id,
    required this.name,
    required this.groups,
  });

  factory OptionTemplateModel.fromMap(Map<String, dynamic> map, String id) {
    return OptionTemplateModel(
      id: id,
      name: map['name'] as String? ?? '',
      groups: (map['groups'] as List? ?? [])
          .map((g) => OptionGroup.fromMap(g as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'groups': groups.map((g) => g.toMap()).toList(),
      };
}
