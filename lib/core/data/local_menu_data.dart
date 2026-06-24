import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/option_group_model.dart';

// بيانات محلية للمعاينة — تُستخدم عند عدم توفر Firebase
class LocalMenuData {
  static OptionGroup _sauce() => OptionGroup(
        id: 'sauce',
        name: 'الصوص',
        type: OptionGroupType.multiple,
        required: false,
        options: [
          ItemOption(id: 's1', name: 'كاتشب'),
          ItemOption(id: 's2', name: 'مايونيز'),
          ItemOption(id: 's3', name: 'ثوم'),
          ItemOption(id: 's4', name: 'حار'),
        ],
      );

  static OptionGroup _remove() => OptionGroup(
        id: 'remove',
        name: 'استبعاد',
        type: OptionGroupType.multiple,
        required: false,
        options: [
          ItemOption(id: 'r1', name: 'خيار'),
          ItemOption(id: 'r2', name: 'طماطم'),
          ItemOption(id: 'r3', name: 'بصل'),
          ItemOption(id: 'r4', name: 'بيكل'),
        ],
      );

  static OptionGroup _meal() => OptionGroup(
        id: 'meal',
        name: 'ترقية لوجبة',
        type: OptionGroupType.single,
        required: false,
        options: [
          ItemOption(id: 'm1', name: 'بدون وجبة'),
          ItemOption(id: 'm2', name: 'وجبة كاملة (بطاطس + مشروب)', priceAdjustment: 5),
        ],
      );

  static OptionGroup _extras() => OptionGroup(
        id: 'extras',
        name: 'الإضافات',
        type: OptionGroupType.multiple,
        required: false,
        options: [
          ItemOption(id: 'e1', name: 'شريحة جبنة', priceAdjustment: 1),
        ],
      );

  static OptionGroup _drinkType() => OptionGroup(
        id: 'drink',
        name: 'نوع المشروب',
        type: OptionGroupType.single,
        required: true,
        options: [
          ItemOption(id: 'd1', name: 'بيبسي'),
          ItemOption(id: 'd2', name: 'سفن أب'),
          ItemOption(id: 'd3', name: 'ميرندا'),
          ItemOption(id: 'd4', name: 'بيبسي دايت'),
        ],
      );

  static OptionGroup _juiceFlavor() => OptionGroup(
        id: 'juice',
        name: 'النكهة',
        type: OptionGroupType.single,
        required: true,
        options: [
          ItemOption(id: 'j1', name: 'توت'),
          ItemOption(id: 'j2', name: 'مانجو'),
          ItemOption(id: 'j3', name: 'فراولة'),
          ItemOption(id: 'j4', name: 'أناناس'),
        ],
      );

  static OptionGroup _friesType() => OptionGroup(
        id: 'fries',
        name: 'نوع البطاطس',
        type: OptionGroupType.single,
        required: true,
        options: [
          ItemOption(id: 'f1', name: 'بهارات'),
          ItemOption(id: 'f2', name: 'عادية'),
          ItemOption(id: 'f3', name: 'حارة'),
        ],
      );

  static List<CategoryModel> get categories => [
        const CategoryModel(id: 'cat1', name: 'الساندوتشات', icon: null, sortOrder: 0, isActive: true),
        const CategoryModel(id: 'cat2', name: 'البرجر', icon: null, sortOrder: 1, isActive: true),
        const CategoryModel(id: 'cat3', name: 'الصحون', icon: null, sortOrder: 2, isActive: true),
        const CategoryModel(id: 'cat4', name: 'الطلبات الجانبية', icon: null, sortOrder: 3, isActive: true),
        const CategoryModel(id: 'cat5', name: 'المشروبات', icon: null, sortOrder: 4, isActive: true),
      ];

  static List<MenuItemModel> get items => [
        // ── الساندوتشات ──
        MenuItemModel(
          id: 'i1', name: 'ساندوتش زنجر', description: 'دجاج زنجر مقرمش بخبز التورتيا',
          categoryId: 'cat1', categoryName: 'الساندوتشات', price: 7,
          optionGroups: [_sauce(), _remove(), _meal()],
        ),
        MenuItemModel(
          id: 'i2', name: 'ساندوتش صاروخ', description: 'ساندوتش صاروخ بخبز التورتيا',
          categoryId: 'cat1', categoryName: 'الساندوتشات', price: 10,
          optionGroups: [_sauce(), _remove(), _meal()],
        ),
        // ── البرجر ──
        MenuItemModel(
          id: 'i3', name: 'برجر زنجر', description: 'برجر دجاج زنجر مقرمش',
          categoryId: 'cat2', categoryName: 'البرجر', price: 7,
          optionGroups: [_extras(), _sauce(), _remove(), _meal()],
        ),
        MenuItemModel(
          id: 'i4', name: 'برجر لحم', description: 'برجر لحم بقري طازج',
          categoryId: 'cat2', categoryName: 'البرجر', price: 7,
          optionGroups: [_extras(), _sauce(), _remove(), _meal()],
        ),
        MenuItemModel(
          id: 'i5', name: 'برجر دجاج', description: 'برجر دجاج طري ولذيذ',
          categoryId: 'cat2', categoryName: 'البرجر', price: 7,
          optionGroups: [_extras(), _sauce(), _remove(), _meal()],
        ),
        // ── الصحون ──
        MenuItemModel(
          id: 'i6', name: 'صحن كلوب', description: 'دجاج بطبق التوست',
          categoryId: 'cat3', categoryName: 'الصحون', price: 12,
          optionGroups: [_sauce()],
        ),
        MenuItemModel(
          id: 'i7', name: 'صحن حربي', description: 'خبز التورتيا مع جبنة',
          categoryId: 'cat3', categoryName: 'الصحون', price: 12,
          optionGroups: [_sauce()],
        ),
        MenuItemModel(
          id: 'i8', name: 'صحن مسحب', description: 'لفائف دجاج مسحب',
          categoryId: 'cat3', categoryName: 'الصحون', price: 12,
          optionGroups: [_sauce()],
        ),
        // ── الطلبات الجانبية ──
        MenuItemModel(
          id: 'i9', name: 'بطاطس بهارات', description: 'بطاطس مقلية بتتبيلة البهارات',
          categoryId: 'cat4', categoryName: 'الطلبات الجانبية', price: 3,
          optionGroups: [_friesType()],
        ),
        MenuItemModel(
          id: 'i10', name: 'بطاطس صوص', description: 'بطاطس مقلية مع كاتشب وجبنة',
          categoryId: 'cat4', categoryName: 'الطلبات الجانبية', price: 5,
          optionGroups: [_friesType()],
        ),
        MenuItemModel(
          id: 'i11', name: 'بطاطس زنجر', description: 'بطاطس مع لحم دجاج زنجر وجبنة',
          categoryId: 'cat4', categoryName: 'الطلبات الجانبية', price: 7,
          optionGroups: [_friesType()],
        ),
        MenuItemModel(
          id: 'i12', name: 'حلية صوص', description: 'كاتشب، مايونيز، ثوم، جبنة',
          categoryId: 'cat4', categoryName: 'الطلبات الجانبية', price: 1,
        ),
        MenuItemModel(
          id: 'i13', name: 'شريحة جبنة', description: 'شريحة جبنة إضافية',
          categoryId: 'cat4', categoryName: 'الطلبات الجانبية', price: 1,
        ),
        // ── المشروبات ──
        MenuItemModel(
          id: 'i14', name: 'مشروب غازي', description: 'بيبسي، سفن أب، ميرندا',
          categoryId: 'cat5', categoryName: 'المشروبات', price: 2,
          optionGroups: [_drinkType()],
        ),
        MenuItemModel(
          id: 'i15', name: 'عصير موف', description: 'عصير طازج متنوع النكهات',
          categoryId: 'cat5', categoryName: 'المشروبات', price: 6,
          optionGroups: [_juiceFlavor()],
        ),
        MenuItemModel(
          id: 'i16', name: 'ماء', description: 'ماء معدني',
          categoryId: 'cat5', categoryName: 'المشروبات', price: 1,
        ),
      ];

  static List<MenuItemModel> itemsByCategory(String? categoryId) {
    if (categoryId == null) return items;
    return items.where((i) => i.categoryId == categoryId).toList();
  }
}
