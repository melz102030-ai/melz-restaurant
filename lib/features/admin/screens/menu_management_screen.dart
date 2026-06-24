import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/option_group_model.dart';
import '../../../core/services/menu_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../features/customer/providers/menu_provider.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'إضافة عنصر',
          ),
          IconButton(
            onPressed: () => MenuService.seedInitialData(),
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'تحميل بيانات أولية',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MenuItemsTab(),
          _CategoriesTab(),
        ],
      ),
    );
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

class _MenuItemsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(adminMenuItemsProvider);
    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            message: 'لا توجد عناصر في القائمة\nاضغط + لإضافة عنصر جديد',
            icon: Icons.restaurant_menu,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) => _MenuItemTile(item: items[i], index: i),
        );
      },
      loading: () => const LoadingWidget(message: 'تحميل القائمة...'),
      error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error_outline),
    );
  }
}

class _MenuItemTile extends ConsumerWidget {
  final MenuItemModel item;
  final int index;
  const _MenuItemTile({required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isAvailable
              ? AppColors.purpleDark.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.imageUrl != null
                ? Image.network(item.imageUrl!,
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (item.hasOptions)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${item.optionGroups.length} خيارات',
                          style: const TextStyle(color: AppColors.purple, fontSize: 10),
                        ),
                      ),
                    if (!item.isAvailable)
                      const Icon(Icons.block, color: AppColors.error, size: 16),
                  ],
                ),
                Text(item.categoryName,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                Text('${item.price.toStringAsFixed(2)} ${AppStrings.sar}',
                    style: const TextStyle(
                        color: AppColors.purple, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: item.isAvailable,
                onChanged: (v) => MenuService.toggleItemAvailability(item.id, v),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => _MenuItemDialog(item: item),
                    ),
                    icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _confirmDelete(context, item),
                    icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn();
  }

  Widget _placeholder() => Container(
        width: 60, height: 60, color: AppColors.surfaceLight,
        child: const Icon(Icons.restaurant, color: AppColors.textHint, size: 24),
      );

  void _confirmDelete(BuildContext context, MenuItemModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف العنصر'),
        content: Text('هل تريد حذف "${item.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              MenuService.deleteMenuItem(item.id);
              Navigator.pop(context);
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cats.length,
            itemBuilder: (_, i) => _CategoryTile(cat: cats[i], index: i),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel cat;
  final int index;
  const _CategoryTile({required this.cat, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.purpleDark.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (cat.icon != null) Text(cat.icon!, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(cat.name,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Switch(
            value: cat.isActive,
            onChanged: (v) => MenuService.updateCategory(cat.copyWith(isActive: v)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _CategoryDialog(cat: cat),
            ),
            icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 18),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الفئة'),
        content: Text('سيتم حذف الفئة "${cat.name}" وجميع عناصرها. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              MenuService.deleteCategory(cat.id);
              Navigator.pop(context);
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
  const _MenuItemDialog({this.item});

  @override
  ConsumerState<_MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends ConsumerState<_MenuItemDialog>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _isAvailable = true;
  bool _isSaving = false;
  String? _imageUrl;
  Uint8List? _imageBytes;
  List<OptionGroup> _optionGroups = [];
  String? _saveError;

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    if (widget.item != null) {
      final item = widget.item!;
      _nameCtrl.text = item.name;
      _descCtrl.text = item.description;
      _priceCtrl.text = item.price.toString();
      _discountCtrl.text = item.discountPercent?.toString() ?? '';
      _selectedCategoryId = item.categoryId;
      _selectedCategoryName = item.categoryName;
      _isAvailable = item.isAvailable;
      _imageUrl = item.imageUrl;
      _optionGroups = List.from(item.optionGroups);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')));
      return;
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
        price: double.tryParse(_priceCtrl.text) ?? 0,
        imageUrl: finalImageUrl,
        isAvailable: _isAvailable,
        sortOrder: widget.item?.sortOrder ?? 0,
        discountPercent: _discountCtrl.text.isEmpty
            ? null
            : double.tryParse(_discountCtrl.text),
        optionGroups: _optionGroups,
      );
      if (widget.item != null) {
        await MenuService.updateMenuItem(newItem);
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
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.item != null ? AppStrings.editItem : AppStrings.addItem,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabCtrl,
                tabs: const [
                  Tab(text: 'التفاصيل'),
                  Tab(text: 'الخيارات'),
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
                        style: const TextStyle(color: Colors.red, fontSize: 12)),
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
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, color: AppColors.textHint, size: 36),
                            SizedBox(height: 6),
                            Text('اضغط لرفع صورة',
                                style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                          ],
                        ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'اسم العنصر *'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            maxLines: 2,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'الوصف'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary),
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
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                      labelText: 'السعر *', suffix: Text(AppStrings.sar)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _discountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'الخصم %', hintText: '10'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('متوفر:', style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              Switch(
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
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
              const Text(
                'مجموعات الخيارات',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addOptionGroup,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة مجموعة'),
              ),
            ],
          ),
        ),
        if (_optionGroups.isEmpty)
          const Expanded(
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
              onReorderItem: (oldIdx, newIdx) {
                setState(() {
                  final g = _optionGroups.removeAt(oldIdx);
                  _optionGroups.insert(newIdx, g);
                });
              },
              children: _optionGroups.asMap().entries.map((e) {
                final i = e.key;
                final group = e.value;
                return _OptionGroupTile(
                  key: ValueKey(group.id),
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
}

// ── Option group tile ─────────────────────────────────────────────────────────

class _OptionGroupTile extends StatelessWidget {
  final OptionGroup group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OptionGroupTile({
    super.key,
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
        border: Border.all(color: AppColors.purpleDark.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(group.name,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ),
            _badge(
              group.required ? 'إجباري' : 'اختياري',
              group.required ? AppColors.manjawi : AppColors.textHint,
            ),
            const SizedBox(width: 6),
            _badge(
              group.type == OptionGroupType.single ? 'واحد' : 'متعدد',
              AppColors.purple,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const Icon(Icons.drag_handle, color: AppColors.textHint, size: 20),
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
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            trailing: opt.priceAdjustment != 0
                ? Text(
                    '${opt.priceAdjustment > 0 ? '+' : ''}${opt.priceAdjustment.toStringAsFixed(0)} ر',
                    style: const TextStyle(color: AppColors.success, fontSize: 12),
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أضف اسم المجموعة وخياراً واحداً على الأقل')));
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
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    widget.group != null ? 'تعديل مجموعة خيارات' : 'إضافة مجموعة خيارات',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
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
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                          labelText: 'اسم المجموعة *',
                          hintText: 'مثال: الصوص، الحجم، الإضافات'),
                    ),
                    const SizedBox(height: 14),
                    // Type selector
                    const Text('نوع الاختيار:',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeChip(
                            label: 'اختيار واحد',
                            icon: Icons.radio_button_checked,
                            selected: _type == OptionGroupType.single,
                            onTap: () => setState(() => _type = OptionGroupType.single),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TypeChip(
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
                        const Text('إجباري:',
                            style: TextStyle(color: AppColors.textSecondary)),
                        const Spacer(),
                        Switch(
                          value: _required,
                          onChanged: (v) => setState(() => _required = v),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.surfaceLight),
                    // Options list
                    Row(
                      children: [
                        const Text('الخيارات:',
                            style: TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addOption,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('إضافة'),
                        ),
                      ],
                    ),
                    ..._options.asMap().entries.map((e) => _OptionRow(
                          opt: e.value,
                          onEdit: () => _editOption(e.key),
                          onDelete: () => setState(() => _options.removeAt(e.key)),
                        )),
                    if (_options.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('لا توجد خيارات بعد',
                              style: TextStyle(color: AppColors.textHint)),
                        ),
                      ),
                  ],
                ),
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

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple.withValues(alpha: 0.15) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.surfaceLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppColors.purple : AppColors.textHint, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.purple : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final ItemOption opt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OptionRow({required this.opt, required this.onEdit, required this.onDelete});

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
          Expanded(
            child: Text(opt.name,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ),
          if (opt.priceAdjustment != 0)
            Text(
              '${opt.priceAdjustment > 0 ? '+' : ''}${opt.priceAdjustment.toStringAsFixed(0)} ر',
              style: const TextStyle(color: AppColors.success, fontSize: 13),
            ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, color: AppColors.error, size: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(),
          ),
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
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
                labelText: 'اسم الخيار *', hintText: 'مثال: كاتشب، جبنة إضافية'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            style: const TextStyle(color: AppColors.textPrimary),
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

  @override
  void initState() {
    super.initState();
    if (widget.cat != null) {
      _nameCtrl.text = widget.cat!.name;
      _iconCtrl.text = widget.cat!.icon ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final cat = CategoryModel(
        id: widget.cat?.id ?? '',
        name: _nameCtrl.text.trim(),
        icon: _iconCtrl.text.trim().isEmpty ? null : _iconCtrl.text.trim(),
        sortOrder: widget.cat?.sortOrder ?? 0,
        isActive: widget.cat?.isActive ?? true,
      );
      if (widget.cat != null) {
        await MenuService.updateCategory(cat);
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
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'اسم الفئة *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _iconCtrl,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 24),
            decoration: const InputDecoration(labelText: 'الأيقونة (إيموجي)', hintText: '🍔'),
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
