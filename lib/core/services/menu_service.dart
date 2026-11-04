import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/option_group_model.dart';
import '../models/option_template_model.dart';
import 'cloudinary_service.dart';

class MenuService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _colCategories = 'categories';
  static const String _colItems = 'menu_items';
  static const String _colTemplates = 'option_templates';
  static const _uuid = Uuid();

  // ─── Categories ───────────────────────────────────────────────
  static Stream<List<CategoryModel>> streamCategories() {
    return _db
        .collection(_colCategories)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CategoryModel.fromMap(d.data(), d.id)).toList());
  }

  static Future<String> addCategory(CategoryModel cat) async {
    final ref = _db.collection(_colCategories).doc();
    await ref.set(CategoryModel(
      id: ref.id,
      name: cat.name,
      icon: cat.icon,
      imageUrl: cat.imageUrl,
      sortOrder: cat.sortOrder,
      isActive: cat.isActive,
    ).toMap());
    return ref.id;
  }

  static Future<void> updateCategory(CategoryModel cat) async {
    await _db.collection(_colCategories).doc(cat.id).update(cat.toMap());
  }

  // لا تُحذف فئة فيها أصناف، لأن الحذف نهائي ولا نسخة احتياطية للرجوع إليها
  static Future<void> deleteCategory(String catId) async {
    final items = await _db
        .collection(_colItems)
        .where('categoryId', isEqualTo: catId)
        .limit(1)
        .get();
    if (items.docs.isNotEmpty) {
      throw Exception('الفئة فيها أصناف. انقلها لفئة أخرى أو احذفها أولاً، أو أوقف الفئة لإخفائها');
    }
    await _db.collection(_colCategories).doc(catId).delete();
  }

  // ─── Menu Items ───────────────────────────────────────────────
  static Stream<List<MenuItemModel>> streamMenuItems({String? categoryId}) {
    Query<Map<String, dynamic>> q = _db.collection(_colItems);
    if (categoryId != null) q = q.where('categoryId', isEqualTo: categoryId);
    return q.orderBy('sortOrder').snapshots().map((snap) =>
        snap.docs.map((d) => MenuItemModel.fromMap(d.data(), d.id)).toList());
  }

  static Stream<List<MenuItemModel>> streamAvailableItems({String? categoryId}) {
    Query<Map<String, dynamic>> q =
        _db.collection(_colItems).where('isAvailable', isEqualTo: true);
    if (categoryId != null) q = q.where('categoryId', isEqualTo: categoryId);
    return q.orderBy('sortOrder').snapshots().map((snap) =>
        snap.docs.map((d) => MenuItemModel.fromMap(d.data(), d.id)).toList());
  }

  // الصنف المنسوخ يشارك صورة الأصلي. عند الحذف أو الاستبدال لا تُحذف الصورة من
  // Cloudinary إن كان صنف آخر يستخدمها، ويُحتفظ بها أيضاً إن تعذّر التأكد.
  static Future<void> deleteItemImageIfUnused(String? imageUrl, String itemId) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    try {
      final snap = await _db
          .collection(_colItems)
          .where('imageUrl', isEqualTo: imageUrl)
          .limit(2)
          .get();
      if (snap.docs.any((d) => d.id != itemId)) return;
    } catch (_) {
      return;
    }
    await CloudinaryService.deleteImage(imageUrl);
  }

  static Future<String> addMenuItem(MenuItemModel item) async {
    final ref = _db.collection(_colItems).doc();
    final newItem = item.copyWith();
    final map = newItem.toMap();
    await ref.set({...map, 'id': ref.id});
    return ref.id;
  }

  // original هو الصنف كما فُتحت به نافذة التعديل، حتى لا يلغي الحفظ توقيفات المطبخ
  static Future<void> updateMenuItem(MenuItemModel item, {required MenuItemModel original}) {
    final ref = _db.collection(_colItems).doc(item.id);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final latest = MenuItemModel.fromMap(snap.data() ?? const {}, item.id);
      final merged = snap.exists
          ? item.withLatestAvailability(original: original, latest: latest)
          : item;
      tx.update(ref, merged.toMap());
    });
  }

  static Future<void> deleteMenuItem(String itemId) async {
    await _db.collection(_colItems).doc(itemId).delete();
  }

  static Future<void> toggleItemAvailability(String itemId, bool available) async {
    await _db.collection(_colItems).doc(itemId).update({'isAvailable': available});
  }

  static Future<Map<String, int>> getCategoryItemCounts() async {
    final snap = await _db.collection(_colItems).get();
    final counts = <String, int>{};
    for (final doc in snap.docs) {
      final catId = doc.data()['categoryId'] as String? ?? '';
      counts[catId] = (counts[catId] ?? 0) + 1;
    }
    return counts;
  }

  // ─── Reorder ──────────────────────────────────────────────────
  static Future<void> reorderMenuItems(List<MenuItemModel> items) async {
    final batch = _db.batch();
    for (int i = 0; i < items.length; i++) {
      batch.update(_db.collection(_colItems).doc(items[i].id), {'sortOrder': i});
    }
    await batch.commit();
  }

  static Future<void> reorderCategories(List<CategoryModel> cats) async {
    final batch = _db.batch();
    for (int i = 0; i < cats.length; i++) {
      batch.update(_db.collection(_colCategories).doc(cats[i].id), {'sortOrder': i});
    }
    await batch.commit();
  }

  // ─── Option Templates ─────────────────────────────────────────
  static Stream<List<OptionTemplateModel>> streamOptionTemplates() {
    return _db
        .collection(_colTemplates)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs
            .map((d) => OptionTemplateModel.fromMap(d.data(), d.id))
            .toList());
  }

  static Future<String> addOptionTemplate(OptionTemplateModel t) async {
    final ref = _db.collection(_colTemplates).doc();
    await ref.set(t.toMap());
    return ref.id;
  }

  static Future<void> updateOptionTemplate(OptionTemplateModel t) async {
    await _db.collection(_colTemplates).doc(t.id).update(t.toMap());
    await _propagateTemplateToItems(t);
  }

  // عند تعديل قالب — يُحدِّث مجموعات خياراته في كل الأصناف المرتبطة به
  // (تلك التي حُفظ فيها linkedTemplateIds يحتوي على معرّف هذا القالب)
  static Future<void> _propagateTemplateToItems(OptionTemplateModel t) async {
    final snap = await _db
        .collection(_colItems)
        .where('linkedTemplateIds', arrayContains: t.id)
        .get();
    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      final item = MenuItemModel.fromMap(doc.data(), doc.id);
      batch.update(doc.reference, {
        'optionGroups':
            item.optionGroupsWithTemplate(t.id, t.groups).map((g) => g.toMap()).toList(),
      });
    }
    await batch.commit();
  }

  // حذف القالب لا يمس خيارات الأصناف، لكنها تصبح مستقلة عنه
  static Future<void> deleteOptionTemplate(String id) async {
    final snap = await _db
        .collection(_colItems)
        .where('linkedTemplateIds', arrayContains: id)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      final item = MenuItemModel.fromMap(doc.data(), doc.id);
      batch.update(doc.reference, {
        'linkedTemplateIds': FieldValue.arrayRemove([id]),
        'optionGroups': item.optionGroups
            .map((g) => (g.sourceTemplateId == id ? g.copyWith(sourceTemplateId: null) : g).toMap())
            .toList(),
      });
    }
    batch.delete(_db.collection(_colTemplates).doc(id));
    await batch.commit();
  }

  // ─── Seed real Melz menu data ─────────────────────────────────
  static Future<void> seedInitialData() async {
    final catSnap = await _db.collection(_colCategories).limit(1).get();
    if (catSnap.docs.isNotEmpty) return;

    // Option group helpers
    OptionGroup sauceGroup({bool required = false}) => OptionGroup(
          id: _uuid.v4(),
          name: 'الصوص',
          type: OptionGroupType.multiple,
          required: required,
          options: [
            ItemOption(id: _uuid.v4(), name: 'كاتشب', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'مايونيز', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'ثوم', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'حار', priceAdjustment: 0),
          ],
        );

    OptionGroup removeGroup() => OptionGroup(
          id: _uuid.v4(),
          name: 'استبعاد',
          type: OptionGroupType.multiple,
          required: false,
          options: [
            ItemOption(id: _uuid.v4(), name: 'خيار', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'طماطم', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'بصل', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'بيكل', priceAdjustment: 0),
          ],
        );

    OptionGroup mealUpgradeGroup() => OptionGroup(
          id: _uuid.v4(),
          name: 'ترقية لوجبة',
          type: OptionGroupType.single,
          required: false,
          options: [
            ItemOption(id: _uuid.v4(), name: 'بدون وجبة', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'وجبة كاملة (بطاطس + مشروب)', priceAdjustment: 5),
          ],
        );

    OptionGroup drinkTypeGroup() => OptionGroup(
          id: _uuid.v4(),
          name: 'نوع المشروب',
          type: OptionGroupType.single,
          required: true,
          options: [
            ItemOption(id: _uuid.v4(), name: 'بيبسي', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'سفن أب', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'ميرندا', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'بيبسي دايت', priceAdjustment: 0),
          ],
        );

    OptionGroup juiceFlavorGroup() => OptionGroup(
          id: _uuid.v4(),
          name: 'النكهة',
          type: OptionGroupType.single,
          required: true,
          options: [
            ItemOption(id: _uuid.v4(), name: 'توت', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'مانجو', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'فراولة', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'أناناس', priceAdjustment: 0),
          ],
        );

    OptionGroup friesSpiceGroup() => OptionGroup(
          id: _uuid.v4(),
          name: 'نوع البطاطس',
          type: OptionGroupType.single,
          required: true,
          options: [
            ItemOption(id: _uuid.v4(), name: 'بهارات', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'عادية', priceAdjustment: 0),
            ItemOption(id: _uuid.v4(), name: 'حارة', priceAdjustment: 0),
          ],
        );

    // ── Categories ──
    final categories = [
      {'name': 'الساندوتشات', 'icon': null, 'sortOrder': 0},
      {'name': 'البرجر', 'icon': null, 'sortOrder': 1},
      {'name': 'الصحون', 'icon': null, 'sortOrder': 2},
      {'name': 'الطلبات الجانبية', 'icon': null, 'sortOrder': 3},
      {'name': 'المشروبات', 'icon': null, 'sortOrder': 4},
    ];

    final batch = _db.batch();
    final catIds = <String>[];

    for (final cat in categories) {
      final ref = _db.collection(_colCategories).doc();
      catIds.add(ref.id);
      batch.set(ref, {
        'name': cat['name'],
        'icon': cat['icon'],
        'sortOrder': cat['sortOrder'],
        'isActive': true,
      });
    }

    // ── Items ── (catIndex: 0=ساندوتشات, 1=برجر, 2=صحون, 3=جانبية, 4=مشروبات)
    final items = <Map<String, dynamic>>[
      // الساندوتشات
      {
        'name': 'ساندوتش زنجر',
        'desc': 'دجاج زنجر مقرمش بخبز التورتيا',
        'cat': 0, 'price': 7.0,
        'options': [sauceGroup(), removeGroup(), mealUpgradeGroup()],
      },
      {
        'name': 'ساندوتش صاروخ',
        'desc': 'ساندوتش صاروخ بخبز التورتيا',
        'cat': 0, 'price': 10.0,
        'options': [sauceGroup(), removeGroup(), mealUpgradeGroup()],
      },
      // البرجر
      {
        'name': 'برجر زنجر',
        'desc': 'برجر دجاج زنجر مقرمش',
        'cat': 1, 'price': 7.0,
        'options': [
          OptionGroup(
            id: _uuid.v4(),
            name: 'الإضافات',
            type: OptionGroupType.multiple,
            required: false,
            options: [
              ItemOption(id: _uuid.v4(), name: 'شريحة جبنة', priceAdjustment: 1),
            ],
          ),
          sauceGroup(),
          removeGroup(),
          mealUpgradeGroup(),
        ],
      },
      {
        'name': 'برجر لحم',
        'desc': 'برجر لحم بقري طازج',
        'cat': 1, 'price': 7.0,
        'options': [
          OptionGroup(
            id: _uuid.v4(),
            name: 'الإضافات',
            type: OptionGroupType.multiple,
            required: false,
            options: [
              ItemOption(id: _uuid.v4(), name: 'شريحة جبنة', priceAdjustment: 1),
            ],
          ),
          sauceGroup(),
          removeGroup(),
          mealUpgradeGroup(),
        ],
      },
      {
        'name': 'برجر دجاج',
        'desc': 'برجر دجاج طري ولذيذ',
        'cat': 1, 'price': 7.0,
        'options': [
          OptionGroup(
            id: _uuid.v4(),
            name: 'الإضافات',
            type: OptionGroupType.multiple,
            required: false,
            options: [
              ItemOption(id: _uuid.v4(), name: 'شريحة جبنة', priceAdjustment: 1),
            ],
          ),
          sauceGroup(),
          removeGroup(),
          mealUpgradeGroup(),
        ],
      },
      // الصحون
      {
        'name': 'صحن كلوب',
        'desc': 'دجاج بطبق التوست',
        'cat': 2, 'price': 12.0,
        'options': [sauceGroup()],
      },
      {
        'name': 'صحن حربي',
        'desc': 'خبز التورتيا مع جبنة',
        'cat': 2, 'price': 12.0,
        'options': [sauceGroup()],
      },
      {
        'name': 'صحن مسحب',
        'desc': 'لفائف دجاج مسحب',
        'cat': 2, 'price': 12.0,
        'options': [sauceGroup()],
      },
      // الطلبات الجانبية
      {
        'name': 'بطاطس بهارات',
        'desc': 'بطاطس مقلية بتتبيلة البهارات',
        'cat': 3, 'price': 3.0,
        'options': [friesSpiceGroup()],
      },
      {
        'name': 'بطاطس صوص',
        'desc': 'بطاطس مقلية مع كاتشب وجبنة',
        'cat': 3, 'price': 5.0,
        'options': [friesSpiceGroup()],
      },
      {
        'name': 'بطاطس زنجر',
        'desc': 'بطاطس مع لحم دجاج زنجر وجبنة',
        'cat': 3, 'price': 7.0,
        'options': [friesSpiceGroup()],
      },
      {
        'name': 'حلية صوص',
        'desc': 'كاتشب، مايونيز، ثوم، جبنة',
        'cat': 3, 'price': 1.0,
        'options': [],
      },
      {
        'name': 'شريحة جبنة',
        'desc': 'شريحة جبنة إضافية',
        'cat': 3, 'price': 1.0,
        'options': [],
      },
      // المشروبات
      {
        'name': 'مشروب غازي',
        'desc': 'بيبسي، سفن أب، ميرندا',
        'cat': 4, 'price': 2.0,
        'options': [drinkTypeGroup()],
      },
      {
        'name': 'عصير موف',
        'desc': 'عصير طازج متنوع النكهات',
        'cat': 4, 'price': 6.0,
        'options': [juiceFlavorGroup()],
      },
      {
        'name': 'ماء',
        'desc': 'ماء معدني',
        'cat': 4, 'price': 1.0,
        'options': [],
      },
    ];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final catIdx = item['cat'] as int;
      final optGroups = item['options'] as List<OptionGroup>;
      final ref = _db.collection(_colItems).doc();
      batch.set(ref, {
        'name': item['name'],
        'description': item['desc'],
        'categoryId': catIds[catIdx],
        'categoryName': categories[catIdx]['name'],
        'price': item['price'],
        'imageUrl': null,
        'isAvailable': true,
        'sortOrder': i,
        'tags': <String>[],
        'discountPercent': null,
        'optionGroups': optGroups.map((g) => g.toMap()).toList(),
      });
    }

    await batch.commit();
  }
}
