import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/core/models/menu_item_model.dart';
import 'package:melz_restaurant/core/models/option_group_model.dart';
import 'package:melz_restaurant/core/providers/cart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _garlic = ItemOption(id: 'garlic', name: 'ثوم', priceAdjustment: 1);
const _hot = ItemOption(id: 'hot', name: 'حار', priceAdjustment: 1);

MenuItemModel _sauces({
  double garlicPrice = 1,
  bool hotAvailable = true,
  bool available = true,
  List<OptionGroup>? groups,
}) =>
    MenuItemModel(
      id: 'sauces',
      name: 'صوصات',
      description: '',
      categoryId: 'c',
      categoryName: 'c',
      price: 1,
      excludeBasePrice: true,
      isAvailable: available,
      optionGroups: groups ??
          [
            OptionGroup(
              id: 'g',
              name: 'الصوص',
              type: OptionGroupType.multiple,
              required: true,
              allowQuantity: true,
              options: [
                _garlic.copyWith(priceAdjustment: garlicPrice),
                _hot.copyWith(isAvailable: hotAvailable),
              ],
            ),
          ],
    );

const _selection = SelectedOptionGroup(
  groupId: 'g',
  groupName: 'الصوص',
  selectedIds: ['garlic*5', 'hot'],
  selectedNames: ['×5 ثوم', '×1 حار'],
  totalExtra: 6,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('حساب عنصر السلة', () {
    test('الصنف غير المحتسب سعره: المبلغ من خياراته فقط', () {
      final item = CartItem(item: _sauces(), quantity: 1, selectedOptions: const [_selection]);
      expect(item.unitPrice, 6);
      expect(item.total, 6);
    });

    test('الكمية الظاهرة مجموع الخيارات وتتضاعف مع تكرار نفس الاختيار', () {
      final once = CartItem(item: _sauces(), quantity: 1, selectedOptions: const [_selection]);
      expect(once.shownQuantity, 6);
      expect(once.optionLines, ['×5 ثوم', '×1 حار']);

      final twice = once.copyWith(quantity: 2);
      expect(twice.shownQuantity, 12);
      expect(twice.total, 12);
      expect(twice.optionLines, ['×10 ثوم', '×2 حار']);
    });

    test('سلة محفوظة بالصيغة الأقدم لا يتكرر فيها الرقم', () {
      const old = SelectedOptionGroup(
        groupId: 'g',
        groupName: 'الصوص',
        selectedIds: ['garlic*5'],
        selectedNames: ['ثوم ×5'],
        totalExtra: 5,
      );
      final item = CartItem(item: _sauces(), quantity: 1, selectedOptions: const [old]);
      expect(item.optionLines, ['×5 ثوم']);
    });

    test('الصنف العادي: السعر الأساسي والخصم والكمية', () {
      const burger = MenuItemModel(
        id: 'b',
        name: 'برجر',
        description: '',
        categoryId: 'c',
        categoryName: 'c',
        price: 20,
        discountPercent: 10,
      );
      final item = CartItem(item: burger, quantity: 3);
      expect(item.unitPrice, 18);
      expect(item.total, 54);
      expect(item.shownQuantity, 3);
    });

    test('ما يُرسل للخادم لا يحتوي أي سعر', () {
      final item = CartItem(item: _sauces(), quantity: 2, selectedOptions: const [_selection]);
      expect(item.toOrderRequest(), {
        'itemId': 'sauces',
        'quantity': 2,
        'options': [
          {
            'groupId': 'g',
            'selectedIds': ['garlic*5', 'hot'],
          },
        ],
      });
    });
  });

  group('مطابقة السلة مع القائمة الحية', () {
    CartNotifier cartWithSauces() {
      final cart = CartNotifier();
      cart.addItem(_sauces(), const [_selection]);
      return cart;
    }

    test('تغيّر سعر الخيار يحدّث السلة ويُبلَّغ العميل', () {
      final cart = cartWithSauces();
      final result = cart.syncWithMenu([_sauces(garlicPrice: 2)]);
      expect(result.pricesChanged, isTrue);
      expect(result.removedNames, isEmpty);
      expect(cart.state.single.total, 11);
    });

    test('بلا تغيير: لا يُبلَّغ العميل بشيء', () {
      final cart = cartWithSauces();
      final result = cart.syncWithMenu([_sauces()]);
      expect(result.pricesChanged, isFalse);
      expect(result.removedNames, isEmpty);
      expect(cart.state, hasLength(1));
    });

    test('صنف توقف أو حُذف يخرج من السلة', () {
      final stopped = cartWithSauces();
      expect(stopped.syncWithMenu([_sauces(available: false)]).removedNames, ['صوصات']);
      expect(stopped.state, isEmpty);

      final deleted = cartWithSauces();
      expect(deleted.syncWithMenu(const []).removedNames, ['صوصات']);
      expect(deleted.state, isEmpty);
    });

    test('خيار توقف يخرج الصنف من السلة', () {
      final cart = cartWithSauces();
      expect(cart.syncWithMenu([_sauces(hotAvailable: false)]).removedNames, ['صوصات']);
    });

    test('مجموعة إجبارية جديدة تخرج الصنف من السلة', () {
      final cart = cartWithSauces();
      final extra = _sauces().optionGroups.first;
      final withRequired = _sauces(groups: [
        extra,
        const OptionGroup(
          id: 'new',
          name: 'جديدة',
          type: OptionGroupType.single,
          required: true,
          options: [_hot],
        ),
      ]);
      expect(cart.syncWithMenu([withRequired]).removedNames, ['صوصات']);
    });
  });
}
