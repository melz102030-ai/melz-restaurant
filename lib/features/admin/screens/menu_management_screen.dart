import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/option_group_model.dart';
import '../../../core/models/option_template_model.dart';
import '../../../core/services/menu_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/excel_import_service.dart';
import '../../../features/customer/providers/menu_provider.dart';
import '../../../core/providers/app_theme_provider.dart';
import '../../../shared/utils/async_utils.dart';
import '../../../shared/widgets/admin_action_widgets.dart';
import '../../../shared/widgets/loading_widget.dart';

const _uuid = Uuid();

class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  ConsumerState<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.menuManagement),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'عناصر القائمة'),
            Tab(text: 'الفئات'),
            Tab(text: 'القوالب'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ExcelImportService.downloadTemplate(),
            icon: Icon(Icons.download),
            tooltip: 'تنزيل قالب Excel',
          ),
          IconButton(
            onPressed: () => _importFromExcel(context),
            icon: Icon(Icons.upload_file),
            tooltip: 'استيراد من Excel',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MenuItemsTab(),
          _CategoriesTab(),
          const _TemplatesTab(),
        ],
      ),
    );
  }

  Future<void> _importFromExcel(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('جاري الاستيراد...'),
        ]),
      ),
    );

    try {
      final importResult =
          await ExcelImportService.importFromBytes(result.files.single.bytes!);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('اكتمل الاستيراد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أصناف مضافة: ${importResult.itemsAdded}'),
              Text('فئات جديدة: ${importResult.catsAdded}'),
              if (importResult.errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('تحذيرات:', style: TextStyle(color: Colors.orange)),
                ...importResult.errors.map((e) => Text('• $e',
                    style: TextStyle(fontSize: 12, color: Colors.orange))),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('خطأ في الاستيراد'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _MenuItemDialog(),
    );
  }
}

// ── Items tab ─────────────────────────────────────────────────────────────────

class _MenuItemsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MenuItemsTab> createState() => _MenuItemsTabState();
}

class _MenuItemsTabState extends ConsumerState<_MenuItemsTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _categoryFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(adminMenuItemsProvider);
    final categories = ref.watch(adminCategoriesProvider).valueOrNull ?? [];

    return Scaffold(
      body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.trim()),
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'ابحث عن صنف...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _searchCtrl.clear();
                        _query = '';
                      }),
                    ),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
          ),
        ),
        if (categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CatChip(
                  label: 'الكل',
                  selected: _categoryFilter == null,
                  onTap: () => setState(() => _categoryFilter = null),
                ),
                for (final cat in categories)
                  _CatChip(
                    label: cat.name,
                    selected: _categoryFilter == cat.id,
                    onTap: () => setState(
                        () => _categoryFilter = _categoryFilter == cat.id ? null : cat.id),
                  ),
              ],
            ),
          ),
          ),
        const SizedBox(height: 4),
        Expanded(
          child: itemsAsync.when(
            data: (allItems) {
              if (allItems.isEmpty) {
                return const EmptyState(
                  message: 'لا توجد عناصر في القائمة\nاضغط + لإضافة عنصر جديد',
                  icon: Icons.restaurant_menu,
                );
              }
              final items = allItems.where((i) {
                if (_categoryFilter != null && i.categoryId != _categoryFilter) return false;
                if (_query.isNotEmpty &&
                    !i.name.toLowerCase().contains(_query.toLowerCase())) {
                  return false;
                }
                return true;
              }).toList();

              if (items.isEmpty) {
                return const EmptyState(
                  message: 'لا توجد نتائج مطابقة',
                  icon: Icons.search_off,
                );
              }

              // السحب معطّل فقط أثناء البحث النصي: البحث قد يُخفي جزءاً من
              // عناصر نفس الفئة، فإعادة ترتيب الجزء الظاهر فقط بأرقام
              // sortOrder المتسلسلة تُربك ترتيب العناصر المخفية من نفس
              // الفئة. أما فلتر الفئة فيعرض كامل عناصرها دون إخفاء أي
              // منها، فالسحب ضمنه آمن تماماً.
              if (_query.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _MenuItemTile(key: ValueKey(items[i].id), item: items[i], index: i),
                );
              }

              if (_categoryFilter == null) {
                // نجمّع العناصر بحسب ترتيب فئاتها قبل عرضها — sortOrder حقل
                // مسطّح مشترك بين كل الأصناف بغضّ النظر عن الفئة، فبدون هذا
                // التجميع تظهر أصناف الفئات المختلفة متداخلة عشوائياً في "الكل"
                final categoryOrder = {
                  for (var i = 0; i < categories.length; i++) categories[i].id: i,
                };
                items.sort((a, b) {
                  final catCompare = (categoryOrder[a.categoryId] ?? categories.length)
                      .compareTo(categoryOrder[b.categoryId] ?? categories.length);
                  if (catCompare != 0) return catCompare;
                  return a.sortOrder.compareTo(b.sortOrder);
                });
              }

              return ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final reordered = List<MenuItemModel>.from(items);
                  final item = reordered.removeAt(oldIndex);
                  reordered.insert(newIndex, item);
                  MenuService.reorderMenuItems(reordered);
                },
                itemCount: items.length,
                itemBuilder: (_, i) => _MenuItemTile(key: ValueKey(items[i].id), item: items[i], index: i),
              );
            },
            loading: () => const LoadingWidget(message: 'تحميل القائمة...'),
            error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error_outline),
          ),
        ),
      ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _MenuItemDialog(),
        ),
        backgroundColor: AppColors.purple,
        tooltip: 'إضافة صنف',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MenuItemTile extends ConsumerWidget {
  final MenuItemModel item;
  final int index;
  const _MenuItemTile({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isAvailable
              ? Colors.black.withValues(alpha: 0.06)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle, color: AppColors.textHint, size: 16),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl != null
                ? Image.network(item.imageUrl!,
                    width: 48, height: 48, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                    if (!item.isAvailable)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.block, color: AppColors.error, size: 13),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.categoryName} · ${item.price.toStringAsFixed(2)} ${AppStrings.sar}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
                if (item.hasOptions) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.optionGroups.length} خيارات',
                      style: TextStyle(color: AppColors.purple, fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 2),
          Transform.scale(
            scale: 0.78,
            alignment: Alignment.centerLeft,
            child: Switch(
              value: item.isAvailable,
              onChanged: (v) =>
                  runOrShowError(context, () => MenuService.toggleItemAvailability(item.id, v)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18, color: AppColors.textHint),
            padding: EdgeInsets.zero,
            onSelected: (v) {
              if (v == 'edit') {
                showDialog(context: context, builder: (_) => _MenuItemDialog(item: item));
              } else if (v == 'copy') {
                showDialog(
                  context: context,
                  builder: (_) => _MenuItemDialog(
                    item: MenuItemModel(
                      id: '',
                      name: '${item.name} (نسخة)',
                      description: item.description,
                      categoryId: item.categoryId,
                      categoryName: item.categoryName,
                      price: item.price,
                      isAvailable: item.isAvailable,
                      sortOrder: item.sortOrder,
                      tags: item.tags,
                      discountPercent: item.discountPercent,
                      optionGroups: item.optionGroups,
                      isBestSeller: item.isBestSeller,
                      isNew: item.isNew,
                    ),
                    isDuplicate: true,
                  ),
                );
              } else if (v == 'delete') {
                _confirmDelete(context, item);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: ListTile(
                dense: true, contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_outlined, size: 18),
                title: Text('تعديل'),
              )),
              const PopupMenuItem(value: 'copy', child: ListTile(
                dense: true, contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.copy_outlined, size: 18),
                title: Text('نسخ'),
              )),
              const PopupMenuItem(value: 'delete', child: ListTile(
                dense: true, contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                title: Text('حذف', style: TextStyle(color: AppColors.error)),
              )),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn();
  }

  Widget _placeholder() => Container(
        width: 48, height: 48, color: AppColors.surfaceLight,
        child: Icon(Icons.restaurant, color: AppColors.textHint, size: 20),
      );

  void _confirmDelete(BuildContext context, MenuItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العنصر'),
        content: Text('هل تريد حذف "${item.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              runOrShowError(context, () => MenuService.deleteMenuItem(item.id),
                  successMessage: 'تم حذف الصنف');
              CloudinaryService.deleteImage(item.imageUrl);
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Categories tab ────────────────────────────────────────────────────────────

class _CategoriesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(adminCategoriesProvider);
    return Scaffold(
      body: catsAsync.when(
        data: (cats) {
          if (cats.isEmpty) {
            return const EmptyState(message: 'لا توجد فئات\nاضغط + لإضافة فئة', icon: Icons.category);
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final reordered = List<CategoryModel>.from(cats);
              final cat = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, cat);
              MenuService.reorderCategories(reordered);
            },
            itemCount: cats.length,
            itemBuilder: (_, i) => _CategoryTile(key: ValueKey(cats[i].id), cat: cats[i], index: i),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _CategoryDialog(),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel cat;
  final int index;
  const _CategoryTile({super.key, required this.cat, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_handle, color: AppColors.textHint, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cat.imageUrl != null
                ? Image.network(cat.imageUrl!,
                    width: 36, height: 36, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.label_outline, color: AppColors.purple, size: 24))
                : Icon(Icons.label_outline, color: AppColors.purple, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(cat.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 6),
          // مكدَّسة عمودياً (مفتاح فوق، أزرار تحته) بدل صف أفقي واحد —
          // كانت تضغط عرض الاسم المتاح لدرجة التفافه بعد حرفين فقط
          Column(
            children: [
              Switch(
                value: cat.isActive,
                onChanged: (v) => MenuService.updateCategory(cat.copyWith(isActive: v)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionIcon(
                    icon: Icons.edit,
                    color: AppColors.textSecondary,
                    tooltip: 'تعديل',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => _CategoryDialog(cat: cat),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ActionIcon(
                    icon: Icons.delete,
                    color: AppColors.error,
                    tooltip: 'حذف',
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الفئة'),
        content: Text('سيتم حذف الفئة "${cat.name}" وجميع عناصرها. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              runOrShowError(context, () => MenuService.deleteCategory(cat.id),
                  successMessage: 'تم حذف الفئة');
              CloudinaryService.deleteImage(cat.imageUrl);
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Menu Item Dialog ──────────────────────────────────────────────────────────

class _MenuItemDialog extends ConsumerStatefulWidget {
  final MenuItemModel? item;
  final bool isDuplicate;
  const _MenuItemDialog({this.item, this.isDuplicate = false});

  @override
  ConsumerState<_MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends ConsumerState<_MenuItemDialog>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _isAvailable = true;
  bool _isBestSeller = false;
  bool _isNew = false;
  bool _showNutritionInfo = false;
  List<String> _allergens = [];
  bool _isSaving = false;
  String? _imageUrl;
  Uint8List? _imageBytes;
  List<OptionGroup> _optionGroups = [];
  List<ItemPreset> _presets = [];
  List<String> _suggestedItemIds = [];
  List<String> _linkedTemplateIds = [];
  String? _saveError;
  // إعدادات الصورة الشفافة
  bool _useTransparentBg = false;
  double _imageScale = 1.0;
  double _imageOffsetX = 0.0;
  double _imageOffsetY = 0.0;

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    if (widget.item != null) {
      final item = widget.item!;
      _nameCtrl.text = item.name;
      _descCtrl.text = item.description;
      _priceCtrl.text = item.price.toString();
      _discountCtrl.text = item.discountPercent?.toString() ?? '';
      _selectedCategoryId = item.categoryId;
      _selectedCategoryName = item.categoryName;
      _isAvailable = item.isAvailable;
      _isBestSeller = item.isBestSeller;
      _isNew = item.isNew;
      _imageUrl = item.imageUrl;
      _useTransparentBg = item.useTransparentBg;
      _imageScale = item.imageScale;
      _imageOffsetX = item.imageOffsetX;
      _imageOffsetY = item.imageOffsetY;
      _optionGroups = List.from(item.optionGroups);
      _presets = List.from(item.presets);
      _suggestedItemIds = List.from(item.suggestedItemIds);
      _caloriesCtrl.text = item.calories?.toString() ?? '';
      _allergens = List.from(item.allergens);
      _showNutritionInfo = item.showNutritionInfo;
      _linkedTemplateIds = List.from(item.linkedTemplateIds);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _caloriesCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _imageBytes = result.files.single.bytes);
    }
  }

  Future<void> _save(List<CategoryModel> categories) async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _selectedCategoryId == null) {
      setState(() => _saveError = 'يرجى ملء جميع الحقول المطلوبة');
      return;
    }
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price < 0) {
      setState(() => _saveError = 'السعر المُدخل غير صحيح');
      return;
    }
    double? discount;
    if (_discountCtrl.text.trim().isNotEmpty) {
      discount = double.tryParse(_discountCtrl.text.trim());
      if (discount == null || discount < 0 || discount > 100) {
        setState(() => _saveError = 'نسبة الخصم يجب أن تكون رقماً بين 0 و100');
        return;
      }
    }
    int? calories;
    if (_caloriesCtrl.text.trim().isNotEmpty) {
      calories = int.tryParse(_caloriesCtrl.text.trim());
      if (calories == null || calories < 0) {
        setState(() => _saveError = 'عدد السعرات المُدخل غير صحيح');
        return;
      }
    }
    setState(() => _isSaving = true);
    try {
      String? finalImageUrl = _imageUrl;
      if (_imageBytes != null) {
        finalImageUrl = await CloudinaryService.uploadImage(
            _imageBytes!, '${_nameCtrl.text.trim()}.jpg');
      }
      final newItem = MenuItemModel(
        id: widget.item?.id ?? '',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName!,
        price: price,
        imageUrl: finalImageUrl,
        isAvailable: _isAvailable,
        sortOrder: widget.item?.sortOrder ?? 0,
        discountPercent: discount,
        optionGroups: _optionGroups,
        isBestSeller: _isBestSeller,
        isNew: _isNew,
        presets: _presets,
        suggestedItemIds: _suggestedItemIds,
        calories: calories,
        allergens: _allergens,
        showNutritionInfo: _showNutritionInfo,
        linkedTemplateIds: _linkedTemplateIds,
        useTransparentBg: _useTransparentBg,
        imageScale: _imageScale,
        imageOffsetX: _imageOffsetX,
        imageOffsetY: _imageOffsetY,
      );
      if (widget.item != null && !widget.isDuplicate) {
        await MenuService.updateMenuItem(newItem);
        // حذف الصورة القديمة من Cloudinary بعد نجاح استبدالها فعلياً (وليس عند
        // التكرار — النسخة المكرَّرة تشارك نفس الصورة حتى تُغيَّر لاحقاً)
        if (_imageBytes != null && widget.item!.imageUrl != null && widget.item!.imageUrl != finalImageUrl) {
          CloudinaryService.deleteImage(widget.item!.imageUrl);
        }
      } else {
        await MenuService.addMenuItem(newItem);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _saveError = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(adminCategoriesProvider);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 780),
        child: catsAsync.when(
          data: (categories) => Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.isDuplicate ? 'نسخة صنف' : widget.item != null ? AppStrings.editItem : AppStrings.addItem,
                      style: TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabCtrl,
                tabs: const [
                  Tab(text: 'التفاصيل'),
                  Tab(text: 'الخيارات'),
                  Tab(text: 'الاقتراحات'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // ── Tab 1: details ──
                    _buildDetailsTab(categories),
                    // ── Tab 2: option groups ──
                    _buildOptionsTab(),
                    // ── Tab 3: suggestions (presets + frequently ordered with) ──
                    _buildSuggestionsTab(),
                  ],
                ),
              ),
              // Error message
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Text(_saveError!,
                        style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ),
              // Save button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _save(categories),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48)),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.item != null ? AppStrings.save : AppStrings.add),
                ),
              ),
            ],
          ),
          loading: () => const LoadingWidget(),
          error: (e, _) => Text('خطأ: $e'),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(List<CategoryModel> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.purpleDark),
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover))
                  : _imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(_imageUrl!, fit: BoxFit.cover))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, color: AppColors.textHint, size: 36),
                            const SizedBox(height: 6),
                            Text('اضغط لرفع صورة',
                                style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                          ],
                        ),
            ),
          ),
          // ── إعدادات الصورة الشفافة ──────────────────────────────────────────
          if (_imageUrl != null || _imageBytes != null) ...[
            const SizedBox(height: 10),
            _ImageBgSection(
              imageUrl: _imageUrl,
              imageBytes: _imageBytes,
              useTransparentBg: _useTransparentBg,
              scale: _imageScale,
              offsetX: _imageOffsetX,
              offsetY: _imageOffsetY,
              onToggle: (v) => setState(() => _useTransparentBg = v),
              onScaleChanged: (v) => setState(() => _imageScale = v),
              onOffsetChanged: (x, y) => setState(() {
                _imageOffsetX = x;
                _imageOffsetY = y;
              }),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'اسم العنصر *'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            maxLines: 2,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'الوصف'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            dropdownColor: AppColors.surface,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'الفئة *'),
            items: categories
                .where((c) => c.isActive)
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedCategoryId = v;
                _selectedCategoryName =
                    categories.firstWhere((c) => c.id == v).name;
              });
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                      labelText: 'السعر *', suffix: Text(AppStrings.sar)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _discountCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'الخصم %', hintText: '10'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('متوفر:', style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              Switch(
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
            ],
          ),
          Row(
            children: [
              Text('الأكثر مبيعاً:', style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              Switch(
                value: _isBestSeller,
                onChanged: (v) => setState(() => _isBestSeller = v),
              ),
            ],
          ),
          Row(
            children: [
              Text('جديد:', style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              Switch(
                value: _isNew,
                onChanged: (v) => setState(() => _isNew = v),
              ),
            ],
          ),
          const Divider(height: 28),
          Text('السعرات الحرارية ومسبّبات الحساسية',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          TextField(
            controller: _caloriesCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'السعرات الحرارية', hintText: '450'),
          ),
          const SizedBox(height: 12),
          Text('مسبّبات الحساسية',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kAllergens.entries.map((entry) {
              final selected = _allergens.contains(entry.key);
              return FilterChip(
                label: Text(entry.value),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _allergens = [..._allergens, entry.key];
                  } else {
                    _allergens = _allergens.where((a) => a != entry.key).toList();
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text('إظهار هذه المعلومات للعميل',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              Switch(
                value: _showNutritionInfo,
                onChanged: (v) => setState(() => _showNutritionInfo = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                'مجموعات الخيارات',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _applyTemplate(context),
                icon: Icon(Icons.library_books_outlined, size: 20),
                tooltip: 'تطبيق قالب',
                color: AppColors.purple,
              ),
              if (_optionGroups.isNotEmpty)
                IconButton(
                  onPressed: () => _saveAsTemplate(context),
                  icon: Icon(Icons.bookmark_add_outlined, size: 20),
                  tooltip: 'حفظ كقالب',
                  color: AppColors.purple,
                ),
              TextButton.icon(
                onPressed: _addOptionGroup,
                icon: Icon(Icons.add, size: 18),
                label: const Text('إضافة مجموعة'),
              ),
            ],
          ),
        ),
        if (_optionGroups.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'لا توجد خيارات\nاضغط "إضافة مجموعة" لإضافة خيارات',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
          )
        else
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              buildDefaultDragHandles: false,
              onReorder: (oldIdx, newIdx) {
                setState(() {
                  if (newIdx > oldIdx) newIdx--;
                  final g = _optionGroups.removeAt(oldIdx);
                  _optionGroups.insert(newIdx, g);
                });
              },
              children: _optionGroups.asMap().entries.map((e) {
                final i = e.key;
                final group = e.value;
                return _OptionGroupTile(
                  key: ValueKey(group.id),
                  index: i,
                  group: group,
                  onEdit: () => _editOptionGroup(i),
                  onDelete: () => setState(() => _optionGroups.removeAt(i)),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _addOptionGroup() async {
    final result = await showDialog<OptionGroup>(
      context: context,
      builder: (_) => const _OptionGroupDialog(),
    );
    if (result != null) setState(() => _optionGroups.add(result));
  }

  void _editOptionGroup(int index) async {
    final result = await showDialog<OptionGroup>(
      context: context,
      builder: (_) => _OptionGroupDialog(group: _optionGroups[index]),
    );
    if (result != null) setState(() => _optionGroups[index] = result);
  }

  Future<void> _applyTemplate(BuildContext context) async {
    final templates = await MenuService.streamOptionTemplates().first;
    if (!context.mounted) return;
    if (templates.isEmpty) {
      setState(() => _saveError = 'لا توجد قوالب محفوظة بعد');
      return;
    }
    final selected = await showDialog<OptionTemplateModel>(
      context: context,
      builder: (_) => _PickTemplateDialog(templates: templates),
    );
    if (selected != null) {
      setState(() {
        for (final g in selected.groups) {
          // أضف مجموعات القالب مع تسجيل معرّف القالب فيها (sourceTemplateId)
          // حتى يمكن تحديثها لاحقاً عند تعديل القالب بدل إعادة التطبيق يدوياً
          final linked = OptionGroup(
            id: g.id,
            name: g.name,
            type: g.type,
            required: g.required,
            options: g.options,
            sourceTemplateId: selected.id,
          );
          final existing = _optionGroups.indexWhere((e) => e.id == g.id);
          if (existing == -1) {
            _optionGroups.add(linked);
          } else {
            _optionGroups[existing] = linked;
          }
        }
        if (!_linkedTemplateIds.contains(selected.id)) {
          _linkedTemplateIds.add(selected.id);
        }
      });
    }
  }

  Future<void> _saveAsTemplate(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حفظ كقالب'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'اسم القالب',
            hintText: 'مثال: مشروبات + إضافات',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (confirmed == true && nameCtrl.text.trim().isNotEmpty && context.mounted) {
      await MenuService.addOptionTemplate(OptionTemplateModel(
        id: '',
        name: nameCtrl.text.trim(),
        groups: List.from(_optionGroups),
      ));
      setState(() => _saveError = null); // clear any previous error on success
    }
  }

  Widget _buildSuggestionsTab() {
    final itemsAsync = ref.watch(adminMenuItemsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('غالباً ما يُطلب معه',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text('أصناف تُقترح للعميل عند عرض هذا الصنف',
              style: TextStyle(color: AppColors.textHint, fontSize: 12.5)),
          const SizedBox(height: 10),
          itemsAsync.when(
            data: (items) {
              final others = items.where((i) => i.id != widget.item?.id).toList();
              if (others.isEmpty) {
                return Text('لا توجد أصناف أخرى بعد',
                    style: TextStyle(color: AppColors.textHint));
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: others.map((i) {
                  final selected = _suggestedItemIds.contains(i.id);
                  return FilterChip(
                    label: Text(i.name),
                    selected: selected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _suggestedItemIds = [..._suggestedItemIds, i.id];
                      } else {
                        _suggestedItemIds =
                            _suggestedItemIds.where((id) => id != i.id).toList();
                      }
                    }),
                  );
                }).toList(),
              );
            },
            loading: () => const LoadingWidget(),
            error: (e, _) => Text('خطأ: $e'),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Text('اختيارات سريعة جاهزة',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              TextButton.icon(
                onPressed: _optionGroups.isEmpty ? null : _addPreset,
                icon: Icon(Icons.add, size: 18),
                label: const Text('إضافة تركيبة'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('يختار العميل تركيبة جاهزة فتُملأ كل الخيارات دفعة واحدة، ويبقى بإمكانه تعديلها بعدها',
              style: TextStyle(color: AppColors.textHint, fontSize: 12.5)),
          const SizedBox(height: 10),
          if (_optionGroups.isEmpty)
            Text('أضف مجموعات خيارات أولاً من تبويب "الخيارات" لتتمكن من إنشاء اختيارات سريعة',
                style: TextStyle(color: AppColors.textHint))
          else if (_presets.isEmpty)
            Text('لا توجد تركيبات بعد', style: TextStyle(color: AppColors.textHint))
          else
            Column(
              children: _presets
                  .asMap()
                  .entries
                  .map((e) => _buildPresetCard(e.key, e.value))
                  .toList(),
            ),
        ],
      ),
    );
  }

  void _addPreset() {
    setState(() {
      _presets = [..._presets, ItemPreset(id: _uuid.v4(), label: '', selections: {})];
    });
  }

  Widget _buildPresetCard(int index, ItemPreset preset) {
    return Container(
      key: ValueKey(preset.id),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('${preset.id}_label'),
                  initialValue: preset.label,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                      labelText: 'اسم التركيبة', hintText: 'مثال: الأشهر', isDense: true),
                  onChanged: (v) =>
                      setState(() => _presets[index] = preset.copyWith(label: v)),
                ),
              ),
              ActionIcon(
                icon: Icons.delete_outline,
                color: AppColors.error,
                tooltip: 'حذف',
                onTap: () => setState(() => _presets = List.from(_presets)..removeAt(index)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final group in _optionGroups) ...[
            Text(group.name,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: group.options.map((opt) {
                final currentSel = preset.selections[group.id] ?? const [];
                final selected = currentSel.contains(opt.id);
                return ChoiceChip(
                  label: Text(opt.name, style: const TextStyle(fontSize: 12.5)),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    final sel = Map<String, List<String>>.from(preset.selections);
                    var groupSel = List<String>.from(sel[group.id] ?? const []);
                    if (group.type == OptionGroupType.single) {
                      groupSel = v ? [opt.id] : [];
                    } else if (v) {
                      groupSel.add(opt.id);
                    } else {
                      groupSel.remove(opt.id);
                    }
                    sel[group.id] = groupSel;
                    _presets[index] = preset.copyWith(selections: sel);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

// ── Option group tile ─────────────────────────────────────────────────────────

class _OptionGroupTile extends StatelessWidget {
  final int index;
  final OptionGroup group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OptionGroupTile({
    super.key,
    required this.index,
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: ExpansionTile(
        // الاسم والشارتان كانتا بصف أفقي واحد مع أزرار تعديل/حذف/سحب على
        // الطرف الآخر — في نافذة ضيقة (مثل حوار إضافة الصنف) كان هذا يضغط
        // عرض الاسم المتاح لدرجة التفافه بعد حرفين فقط. الاسم الآن سطر
        // كامل والشارتان تحته بدل مزاحمته
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _badge(
                  group.required ? 'إجباري' : 'اختياري',
                  group.required ? AppColors.manjawi : AppColors.textHint,
                ),
                _badge(
                  group.type == OptionGroupType.single ? 'واحد' : 'متعدد',
                  AppColors.purple,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionIcon(icon: Icons.edit, color: AppColors.textSecondary, tooltip: 'تعديل', onTap: onEdit),
            const SizedBox(width: 8),
            ActionIcon(icon: Icons.delete, color: AppColors.error, tooltip: 'حذف', onTap: onDelete),
            const SizedBox(width: 8),
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_handle, color: AppColors.textHint, size: 20),
            ),
          ],
        ),
        children: group.options.map((opt) {
          return ListTile(
            dense: true,
            leading: Icon(
              group.type == OptionGroupType.single
                  ? Icons.radio_button_unchecked
                  : Icons.check_box_outline_blank,
              color: AppColors.textHint,
              size: 18,
            ),
            title: Text(opt.name,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            trailing: opt.priceAdjustment != 0
                ? Text(
                    '${opt.priceAdjustment > 0 ? '+' : ''}${opt.priceAdjustment.toStringAsFixed(0)} ر',
                    style: TextStyle(color: AppColors.success, fontSize: 12),
                  )
                : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      );
}

// ── Option Group Dialog ───────────────────────────────────────────────────────

class _OptionGroupDialog extends StatefulWidget {
  final OptionGroup? group;
  const _OptionGroupDialog({this.group});

  @override
  State<_OptionGroupDialog> createState() => _OptionGroupDialogState();
}

class _OptionGroupDialogState extends State<_OptionGroupDialog> {
  final _nameCtrl = TextEditingController();
  OptionGroupType _type = OptionGroupType.single;
  bool _required = false;
  List<ItemOption> _options = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameCtrl.text = widget.group!.name;
      _type = widget.group!.type;
      _required = widget.group!.required;
      _options = List.from(widget.group!.options);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.isEmpty || _options.isEmpty) {
      setState(() => _error = 'أضف اسم المجموعة وخياراً واحداً على الأقل');
      return;
    }
    Navigator.pop(
      context,
      OptionGroup(
        id: widget.group?.id ?? _uuid.v4(),
        name: _nameCtrl.text.trim(),
        type: _type,
        required: _required,
        options: _options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 620),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    widget.group != null ? 'تعديل مجموعة خيارات' : 'إضافة مجموعة خيارات',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      autofocus: true,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                          labelText: 'اسم المجموعة *',
                          hintText: 'مثال: الصوص، الحجم، الإضافات'),
                    ),
                    const SizedBox(height: 14),
                    // Type selector
                    Text('نوع الاختيار:',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TypeChip(
                            label: 'اختيار واحد',
                            icon: Icons.radio_button_checked,
                            selected: _type == OptionGroupType.single,
                            onTap: () => setState(() => _type = OptionGroupType.single),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TypeChip(
                            label: 'اختيار متعدد',
                            icon: Icons.check_box,
                            selected: _type == OptionGroupType.multiple,
                            onTap: () => setState(() => _type = OptionGroupType.multiple),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Required toggle
                    Row(
                      children: [
                        Text('إجباري:',
                            style: TextStyle(color: AppColors.textSecondary)),
                        const Spacer(),
                        Switch(
                          value: _required,
                          onChanged: (v) => setState(() => _required = v),
                        ),
                      ],
                    ),
                    Divider(color: AppColors.surfaceLight),
                    // Options list
                    Row(
                      children: [
                        Text('الخيارات:',
                            style: TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addOption,
                          icon: Icon(Icons.add, size: 16),
                          label: const Text('إضافة'),
                        ),
                      ],
                    ),
                    if (_options.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('لا توجد خيارات بعد',
                              style: TextStyle(color: AppColors.textHint)),
                        ),
                      )
                    else
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        onReorder: (oldIdx, newIdx) {
                          setState(() {
                            if (newIdx > oldIdx) newIdx--;
                            final opt = _options.removeAt(oldIdx);
                            _options.insert(newIdx, opt);
                          });
                        },
                        children: _options.asMap().entries.map((e) => _OptionRow(
                              key: ValueKey(e.value.id),
                              index: e.key,
                              opt: e.value,
                              onEdit: () => _editOption(e.key),
                              onDelete: () => setState(() => _options.removeAt(e.key)),
                            )).toList(),
                      ),
                  ],
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
                  ),
                  child: Text(_error!,
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44)),
                child: const Text('حفظ المجموعة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addOption() async {
    final result = await showDialog<ItemOption>(
      context: context,
      builder: (_) => const _ItemOptionDialog(),
    );
    if (result != null) setState(() => _options.add(result));
  }

  void _editOption(int index) async {
    final result = await showDialog<ItemOption>(
      context: context,
      builder: (_) => _ItemOptionDialog(option: _options[index]),
    );
    if (result != null) setState(() => _options[index] = result);
  }
}

class _OptionRow extends StatelessWidget {
  final int index;
  final ItemOption opt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OptionRow({
    super.key,
    required this.index,
    required this.opt,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle, color: AppColors.textHint, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(opt.name,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ),
          if (opt.priceAdjustment != 0)
            Text(
              '${opt.priceAdjustment > 0 ? '+' : ''}${opt.priceAdjustment.toStringAsFixed(0)} ر',
              style: TextStyle(color: AppColors.success, fontSize: 13),
            ),
          ActionIcon(icon: Icons.edit, color: AppColors.textSecondary, tooltip: 'تعديل', onTap: onEdit),
          const SizedBox(width: 4),
          ActionIcon(icon: Icons.close, color: AppColors.error, tooltip: 'حذف', onTap: onDelete),
        ],
      ),
    );
  }
}

// ── Single option dialog ───────────────────────────────────────────────────────

class _ItemOptionDialog extends StatefulWidget {
  final ItemOption? option;
  const _ItemOptionDialog({this.option});

  @override
  State<_ItemOptionDialog> createState() => _ItemOptionDialogState();
}

class _ItemOptionDialogState extends State<_ItemOptionDialog> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.option != null) {
      _nameCtrl.text = widget.option!.name;
      _priceCtrl.text = widget.option!.priceAdjustment == 0
          ? ''
          : widget.option!.priceAdjustment.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.option != null ? 'تعديل خيار' : 'إضافة خيار'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
                labelText: 'اسم الخيار *', hintText: 'مثال: كاتشب، جبنة إضافية'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'فرق السعر (ريال)',
              hintText: '0 = مجاني · 5 = يُضاف · -2 = يُخصم',
              suffix: Text(AppStrings.sar),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.isEmpty) return;
            Navigator.pop(
              context,
              ItemOption(
                id: widget.option?.id ?? _uuid.v4(),
                name: _nameCtrl.text.trim(),
                priceAdjustment: double.tryParse(_priceCtrl.text) ?? 0,
              ),
            );
          },
          child: Text(widget.option != null ? AppStrings.save : AppStrings.add),
        ),
      ],
    );
  }
}

// ── Category Dialog ───────────────────────────────────────────────────────────

class _CategoryDialog extends ConsumerStatefulWidget {
  final CategoryModel? cat;
  const _CategoryDialog({this.cat});

  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  final _nameCtrl = TextEditingController();
  final _iconCtrl = TextEditingController();
  bool _isSaving = false;
  String? _imageUrl;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.cat != null) {
      _nameCtrl.text = widget.cat!.name;
      _iconCtrl.text = widget.cat!.icon ?? '';
      _imageUrl = widget.cat!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _imageBytes = result.files.single.bytes);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      String? finalImageUrl = _imageUrl;
      if (_imageBytes != null) {
        finalImageUrl = await CloudinaryService.uploadImage(
            _imageBytes!, 'cat_${_nameCtrl.text.trim()}.jpg');
      }
      final cat = CategoryModel(
        id: widget.cat?.id ?? '',
        name: _nameCtrl.text.trim(),
        icon: _iconCtrl.text.trim().isEmpty ? null : _iconCtrl.text.trim(),
        imageUrl: finalImageUrl,
        sortOrder: widget.cat?.sortOrder ?? 0,
        isActive: widget.cat?.isActive ?? true,
      );
      if (widget.cat != null) {
        await MenuService.updateCategory(cat);
        if (_imageBytes != null &&
            widget.cat!.imageUrl != null &&
            widget.cat!.imageUrl != finalImageUrl) {
          CloudinaryService.deleteImage(widget.cat!.imageUrl);
        }
      } else {
        await MenuService.addCategory(cat);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cat != null ? 'تعديل الفئة' : 'إضافة فئة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: AppColors.purpleDark),
              ),
              child: _imageBytes != null
                  ? ClipOval(child: Image.memory(_imageBytes!, fit: BoxFit.contain))
                  : _imageUrl != null
                      ? ClipOval(child: Image.network(_imageUrl!, fit: BoxFit.contain))
                      : Icon(Icons.add_photo_alternate, color: AppColors.textHint, size: 28),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'اسم الفئة *'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: Text(widget.cat != null ? AppStrings.save : AppStrings.add),
        ),
      ],
    );
  }
}

// ── Templates Tab ─────────────────────────────────────────────────────────────

class _TemplatesTab extends ConsumerWidget {
  const _TemplatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(adminOptionTemplatesProvider);
    return Scaffold(
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return const EmptyState(
              message: 'لا توجد قوالب خيارات\nاضغط + لإضافة قالب جديد',
              icon: Icons.library_books_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (_, i) => _TemplateTile(template: templates[i]),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _TemplateEditorDialog(),
        ),
        backgroundColor: AppColors.purple,
        tooltip: 'قالب جديد',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final OptionTemplateModel template;
  const _TemplateTile({required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        leading: Icon(Icons.library_books, color: AppColors.purple),
        title: Text(template.name, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        subtitle: Text('${template.groups.length} مجموعة خيارات',
            style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionIcon(
              icon: Icons.edit,
              color: AppColors.textSecondary,
              tooltip: 'تعديل',
              onTap: () => showDialog(
                context: context,
                builder: (_) => _TemplateEditorDialog(template: template),
              ),
            ),
            const SizedBox(width: 6),
            ActionIcon(
              icon: Icons.delete,
              color: AppColors.error,
              tooltip: 'حذف',
              onTap: () => _confirmDelete(context),
            ),
          ],
        ),
        onTap: () => showDialog(
          context: context,
          builder: (_) => _TemplateGroupsPreview(template: template),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف القالب'),
        content: Text('هل تريد حذف قالب "${template.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              runOrShowError(context, () => MenuService.deleteOptionTemplate(template.id),
                  successMessage: 'تم حذف القالب');
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _TemplateGroupsPreview extends StatelessWidget {
  final OptionTemplateModel template;
  const _TemplateGroupsPreview({required this.template});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(template.name),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: template.groups.map((g) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(g.name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.purple)),
              const SizedBox(height: 4),
              ...g.options.map((o) => Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 2),
                child: Text(
                  '• ${o.name}${o.priceAdjustment != 0 ? ' (+${o.priceAdjustment.toStringAsFixed(0)} ر.س)' : ''}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              )),
              Divider(),
            ],
          )).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
      ],
    );
  }
}

class _TemplateEditorDialog extends StatefulWidget {
  final OptionTemplateModel? template; // null = قالب جديد
  const _TemplateEditorDialog({this.template});

  @override
  State<_TemplateEditorDialog> createState() => _TemplateEditorDialogState();
}

class _TemplateEditorDialogState extends State<_TemplateEditorDialog> {
  late TextEditingController _nameCtrl;
  late List<OptionGroup> _groups;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.template?.name ?? '');
    _groups = List.from(widget.template?.groups ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addGroup() async {
    final result = await showDialog<OptionGroup>(
      context: context,
      builder: (_) => const _OptionGroupDialog(),
    );
    if (result != null) setState(() => _groups.add(result));
  }

  void _editGroup(int index) async {
    final result = await showDialog<OptionGroup>(
      context: context,
      builder: (_) => _OptionGroupDialog(group: _groups[index]),
    );
    if (result != null) setState(() => _groups[index] = result);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'أدخل اسم القالب');
      return;
    }
    if (_groups.isEmpty) {
      setState(() => _error = 'أضف مجموعة خيارات واحدة على الأقل');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final t = OptionTemplateModel(
      id: widget.template?.id ?? '',
      name: _nameCtrl.text.trim(),
      groups: _groups,
    );
    if (widget.template != null) {
      await MenuService.updateOptionTemplate(t);
    } else {
      await MenuService.addOptionTemplate(t);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.template != null;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit ? 'تعديل القالب' : 'قالب جديد',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'اسم القالب *'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text('مجموعات الخيارات',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addGroup,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('إضافة'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _groups.isEmpty
                  ? Center(
                      child: Text('لا توجد مجموعات بعد',
                          style: TextStyle(color: AppColors.textHint)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _groups.length,
                      itemBuilder: (_, i) {
                        final g = _groups[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                          ),
                          child: ListTile(
                            dense: true,
                            title: Text(g.name,
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${g.options.length} خيار • ${g.required ? "إجباري" : "اختياري"}',
                                style: TextStyle(
                                    color: AppColors.textHint, fontSize: 11)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ActionIcon(
                                    icon: Icons.edit,
                                    color: AppColors.textSecondary,
                                    onTap: () => _editGroup(i)),
                                const SizedBox(width: 4),
                                ActionIcon(
                                    icon: Icons.delete,
                                    color: AppColors.error,
                                    onTap: () =>
                                        setState(() => _groups.removeAt(i))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44)),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'حفظ القالب' : 'إضافة القالب'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pick Template Dialog ──────────────────────────────────────────────────────

class _PickTemplateDialog extends StatelessWidget {
  final List<OptionTemplateModel> templates;
  const _PickTemplateDialog({required this.templates});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر قالباً'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: templates.length,
          itemBuilder: (_, i) {
            final t = templates[i];
            return ListTile(
              leading: Icon(Icons.library_books, color: AppColors.purple),
              title: Text(t.name),
              subtitle: Text('${t.groups.length} مجموعة'),
              onTap: () => Navigator.pop(context, t),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
      ],
    );
  }
}

// ── قسم إعدادات الخلفية الشفافة للصورة ───────────────────────────────────────

class _ImageBgSection extends ConsumerStatefulWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final bool useTransparentBg;
  final double scale;
  final double offsetX;
  final double offsetY;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onScaleChanged;
  final void Function(double x, double y) onOffsetChanged;

  const _ImageBgSection({
    required this.imageUrl,
    required this.imageBytes,
    required this.useTransparentBg,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    required this.onToggle,
    required this.onScaleChanged,
    required this.onOffsetChanged,
  });

  @override
  ConsumerState<_ImageBgSection> createState() => _ImageBgSectionState();
}

class _ImageBgSectionState extends ConsumerState<_ImageBgSection> {
  static const double _previewSize = 140.0;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final bgColor = Color(theme.transparentItemBgColor);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high, size: 16, color: AppColors.purple),
              const SizedBox(width: 6),
              Text('خلفية شفافة',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Switch(
                value: widget.useTransparentBg,
                onChanged: widget.onToggle,
                activeColor: AppColors.purple,
              ),
            ],
          ),
          if (widget.useTransparentBg) ...[
            // تلميح: اللون يُعدَّل من شاشة المظهر
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('لون الخلفية يُضبط من شاشة المظهر (موحَّد لجميع الأصناف)',
                      style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معاينة تفاعلية
                Column(
                  children: [
                    Text('معاينة — اسحب لضبط الموضع',
                        style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onPanUpdate: (d) => widget.onOffsetChanged(
                        widget.offsetX + d.delta.dx,
                        widget.offsetY + d.delta.dy,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: _previewSize,
                          height: _previewSize,
                          child: Container(
                            color: bgColor,
                            child: ClipRect(
                              child: Transform.translate(
                                offset: Offset(widget.offsetX, widget.offsetY),
                                child: Transform.scale(
                                  scale: widget.scale,
                                  child: widget.imageBytes != null
                                      ? Image.memory(widget.imageBytes!, fit: BoxFit.contain)
                                      : Image.network(widget.imageUrl!, fit: BoxFit.contain),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: () {
                        widget.onOffsetChanged(0, 0);
                        widget.onScaleChanged(1.0);
                      },
                      icon: Icon(Icons.refresh, size: 14, color: AppColors.textHint),
                      label: Text('إعادة ضبط',
                          style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                      style: TextButton.styleFrom(
                          minimumSize: Size.zero, padding: EdgeInsets.zero),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // شريط التكبير
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('حجم الصورة  ×${widget.scale.toStringAsFixed(1)}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      SliderTheme(
                        data: SliderThemeData(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: AppColors.purple,
                          thumbColor: AppColors.purple,
                          inactiveTrackColor: AppColors.surfaceLight,
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: widget.scale.clamp(0.3, 3.0),
                          min: 0.3,
                          max: 3.0,
                          divisions: 27,
                          onChanged: widget.onScaleChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── شريحة فئة مدمجة وأنيقة ────────────────────────────────────────────────────

class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [AppColors.purpleDark, AppColors.purple],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          color: selected ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

