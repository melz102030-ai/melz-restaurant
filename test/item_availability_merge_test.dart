import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/core/models/menu_item_model.dart';
import 'package:melz_restaurant/core/models/option_group_model.dart';

MenuItemModel _item({
  bool available = true,
  bool garlicAvailable = true,
  double price = 5,
  bool withHot = false,
}) =>
    MenuItemModel(
      id: 'sauces',
      name: 'صوصات',
      description: '',
      categoryId: 'c',
      categoryName: 'c',
      price: price,
      isAvailable: available,
      optionGroups: [
        OptionGroup(
          id: 'g',
          name: 'الصوص',
          type: OptionGroupType.multiple,
          required: false,
          allowQuantity: true,
          options: [
            ItemOption(id: 'garlic', name: 'ثوم', isAvailable: garlicAvailable),
            if (withHot) const ItemOption(id: 'hot', name: 'حار'),
          ],
        ),
      ],
    );

bool _garlic(MenuItemModel item) => item.optionGroups.first.options.first.isAvailable;

void main() {
  test('توقيف المطبخ أثناء فتح النافذة لا يُلغى، وتعديلات المدير تبقى', () {
    final merged = _item(price: 9).withLatestAvailability(
      original: _item(),
      latest: _item(available: false, garlicAvailable: false),
    );
    expect(merged.isAvailable, isFalse);
    expect(_garlic(merged), isFalse);
    expect(merged.price, 9);
    expect(merged.optionGroups.first.allowQuantity, isTrue);
  });

  test('ما غيّره المدير بنفسه هو الذي يُحفظ', () {
    final merged = _item(available: false).withLatestAvailability(
      original: _item(),
      latest: _item(),
    );
    expect(merged.isAvailable, isFalse);

    final enabled = _item(available: true).withLatestAvailability(
      original: _item(available: false),
      latest: _item(available: false),
    );
    expect(enabled.isAvailable, isTrue);
  });

  test('إعادة تشغيل من المطبخ تبقى، وخيار أضافه المدير يبقى كما هو', () {
    final merged = _item(garlicAvailable: false, withHot: true).withLatestAvailability(
      original: _item(garlicAvailable: false),
      latest: _item(),
    );
    expect(_garlic(merged), isTrue);
    expect(merged.optionGroups.first.options.map((o) => o.id), ['garlic', 'hot']);
    expect(merged.optionGroups.first.options.last.isAvailable, isTrue);
  });
}
