import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/core/models/combo_model.dart';

void main() {
  const combo = ComboModel(
    id: 'c1',
    name: 'وجبة',
    price: 30,
    items: [ComboItemRef(itemId: 'burger')],
    optionItemIds: ['cola', 'juice'],
  );

  bool Function(String) onlyAvailable(Set<String> ids) => ids.contains;

  test('تُطلب إذا توفر الصنف الثابت وخيار واحد على الأقل', () {
    expect(combo.canBeOrdered(onlyAvailable({'burger', 'juice'})), isTrue);
  });

  test('لا تُطلب إذا توقف صنف ثابت', () {
    expect(combo.canBeOrdered(onlyAvailable({'cola', 'juice'})), isFalse);
  });

  test('لا تُطلب إذا توقفت كل خياراتها', () {
    expect(combo.canBeOrdered(onlyAvailable({'burger'})), isFalse);
  });

  test('تركيبة بلا خيارات تعتمد على أصنافها الثابتة فقط', () {
    const fixedOnly = ComboModel(
      id: 'c2',
      name: 'ثابتة',
      price: 20,
      items: [ComboItemRef(itemId: 'burger')],
    );
    expect(fixedOnly.canBeOrdered(onlyAvailable({'burger'})), isTrue);
    expect(fixedOnly.canBeOrdered(onlyAvailable({})), isFalse);
  });
}
