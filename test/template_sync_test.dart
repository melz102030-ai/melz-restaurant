import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/core/models/menu_item_model.dart';
import 'package:melz_restaurant/core/models/option_group_model.dart';

OptionGroup _group(String id, {String? source, List<ItemOption>? options, double price = 1}) =>
    OptionGroup(
      id: id,
      name: id,
      type: OptionGroupType.multiple,
      required: false,
      sourceTemplateId: source,
      options: options ?? [ItemOption(id: 'o', name: 'خيار', priceAdjustment: price)],
    );

MenuItemModel _item(List<OptionGroup> groups) => MenuItemModel(
      id: 'i',
      name: 'صنف',
      description: '',
      categoryId: 'c',
      categoryName: 'c',
      price: 1,
      optionGroups: groups,
    );

List<String> _ids(List<OptionGroup> groups) => groups.map((g) => g.id).toList();

void main() {
  test('المجموعة تبقى في مكانها بين مجموعات الصنف وتأخذ قيم القالب الجديدة', () {
    final item = _item([_group('a'), _group('t1', source: 'T'), _group('b')]);
    final result = item.optionGroupsWithTemplate('T', [_group('t1', price: 9)]);
    expect(_ids(result), ['a', 't1', 'b']);
    expect(result[1].options.single.priceAdjustment, 9);
    expect(result[1].sourceTemplateId, 'T');
  });

  test('الخيار الموقوف يبقى موقوفاً، والخيار الجديد متوفر', () {
    final item = _item([
      _group('t1', source: 'T', options: const [ItemOption(id: 'o', name: 'ثوم', isAvailable: false)]),
    ]);
    final result = item.optionGroupsWithTemplate('T', [
      _group('t1', options: const [
        ItemOption(id: 'o', name: 'ثوم جديد'),
        ItemOption(id: 'n', name: 'حار'),
      ]),
    ]);
    expect(result.single.options.first.isAvailable, isFalse);
    expect(result.single.options.first.name, 'ثوم جديد');
    expect(result.single.options.last.isAvailable, isTrue);
  });

  test('مجموعة جديدة في القالب تأتي بعد مجموعاته، والمحذوفة تُزال', () {
    final item = _item([_group('t1', source: 'T'), _group('t2', source: 'T'), _group('b')]);
    final result = item.optionGroupsWithTemplate('T', [_group('t1'), _group('t3')]);
    expect(_ids(result), ['t1', 't3', 'b']);
  });

  test('تكرار نفس مجموعة القالب يزول، ومجموعات القوالب الأخرى تبقى', () {
    final item = _item([
      _group('t1', source: 'T'),
      _group('t1', source: 'T'),
      _group('x', source: 'OTHER'),
    ]);
    expect(_ids(item.optionGroupsWithTemplate('T', [_group('t1')])), ['t1', 'x']);
  });

  test('صنف مربوط بلا مجموعات من القالب تُضاف له في الآخر', () {
    final item = _item([_group('a')]);
    expect(_ids(item.optionGroupsWithTemplate('T', [_group('t1')])), ['a', 't1']);
  });
}
