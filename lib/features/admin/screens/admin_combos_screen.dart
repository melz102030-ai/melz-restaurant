import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/combo_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/services/combo_service.dart';
import '../../../features/customer/providers/menu_provider.dart';
import '../../../shared/utils/async_utils.dart';
import '../../../shared/widgets/loading_widget.dart';

final _combosProvider = StreamProvider<List<ComboModel>>((ref) {
  return ComboService.streamCombos();
});

class AdminCombosScreen extends ConsumerWidget {
  const AdminCombosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combosAsync = ref.watch(_combosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التركيبات'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'تركيبة جديدة',
            onPressed: () => _showComboDialog(context, ref),
          ),
        ],
      ),
      body: combosAsync.when(
        data: (combos) {
          if (combos.isEmpty) {
            return const EmptyState(
              message: 'لا توجد تركيبات بعد\nاضغط + لإضافة تركيبة',
              icon: Icons.layers_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: combos.length,
            itemBuilder: (_, i) => _ComboTile(
              combo: combos[i],
              onEdit: () => _showComboDialog(context, ref, combo: combos[i]),
              onDelete: () => _confirmDelete(context, combos[i]),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
      ),
    );
  }

  Future<void> _showComboDialog(BuildContext context, WidgetRef ref,
      {ComboModel? combo}) async {
    await showDialog(
      context: context,
      builder: (_) => _ComboDialog(combo: combo, ref: ref),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ComboModel combo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف التركيبة'),
        content: Text('هل تريد حذف "${combo.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            child: Text('حذف', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (ok == true) await ComboService.delete(combo.id);
  }
}

class _ComboTile extends StatelessWidget {
  final ComboModel combo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ComboTile({required this.combo, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.purple.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: combo.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(combo.imageUrl!, fit: BoxFit.cover))
                : Icon(Icons.layers_outlined, color: AppColors.purple, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(combo.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ),
                    if (!combo.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('مخفية',
                            style:
                                TextStyle(color: AppColors.textHint, fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${combo.items.length} صنف · ${combo.price.toStringAsFixed(2)} ر.س',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.surface,
            icon: Icon(Icons.more_vert, color: AppColors.textHint, size: 20),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('تعديل')),
              const PopupMenuItem(value: 'delete', child: Text('حذف')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComboDialog extends ConsumerStatefulWidget {
  final ComboModel? combo;
  final WidgetRef ref;

  const _ComboDialog({this.combo, required this.ref});

  @override
  ConsumerState<_ComboDialog> createState() => _ComboDialogState();
}

class _ComboDialogState extends ConsumerState<_ComboDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _newNameCtrl = TextEditingController();
  bool _isActive = true;
  List<ComboItemRef> _items = [];
  List<String> _linkedItemIds = [];
  List<String> _optionItemIds = [];
  List<String> _includedNames = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.combo;
    if (c != null) {
      _nameCtrl.text = c.name;
      _descCtrl.text = c.description ?? '';
      _priceCtrl.text = c.price.toStringAsFixed(2);
      _isActive = c.isActive;
      _items = List.from(c.items);
      _linkedItemIds = List.from(c.linkedItemIds);
      _optionItemIds = List.from(c.optionItemIds);
      _includedNames = List.from(c.includedNames);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _newNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    if (price <= 0) return;
    if (_items.isEmpty) return;

    setState(() => _saving = true);
    await guardAsync(() async {
      final combo = ComboModel(
        id: widget.combo?.id ?? '',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        imageUrl: widget.combo?.imageUrl,
        price: price,
        isActive: _isActive,
        sortOrder: widget.combo?.sortOrder ?? 0,
        items: _items,
        linkedItemIds: _linkedItemIds,
        optionItemIds: _optionItemIds,
        includedNames: _includedNames,
      );
      await ComboService.save(combo);
    });
    if (mounted) Navigator.pop(context);
  }

  void _addIncludedName() {
    final name = _newNameCtrl.text.trim();
    if (name.isEmpty || _includedNames.contains(name)) return;
    setState(() {
      _includedNames.add(name);
      _newNameCtrl.clear();
    });
  }

  void _addItem(MenuItemModel item) {
    if (_items.any((r) => r.itemId == item.id)) return;
    setState(() => _items.add(ComboItemRef(itemId: item.id)));
  }

  void _removeItem(String itemId) {
    setState(() => _items.removeWhere((r) => r.itemId == itemId));
  }

  @override
  Widget build(BuildContext context) {
    final allItemsAsync = ref.watch(adminMenuItemsProvider);
    final allItems = allItemsAsync.valueOrNull ?? const <MenuItemModel>[];

    return AlertDialog(
      title: Text(widget.combo == null ? 'تركيبة جديدة' : 'تعديل التركيبة'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'اسم التركيبة'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'وصف (اختياري)'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              // ── محتوى الوجبة (أسماء نصية) ─────────────────────────────────
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: AppColors.purple),
                  const SizedBox(width: 6),
                  const Text('محتوى الوجبة',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 8),
                child: Text('تظهر في صفحة الصنف وداخل التركيبة',
                    style: TextStyle(color: AppColors.textHint, fontSize: 11)),
              ),
              if (_includedNames.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _includedNames.map((name) => Chip(
                    label: Text(name, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 15),
                    onDeleted: () => setState(() => _includedNames.remove(name)),
                    backgroundColor: AppColors.purple.withOpacity(0.1),
                    side: BorderSide(color: AppColors.purple.withOpacity(0.4)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'اسم عنصر (مثال: بطاطس)',
                        isDense: true,
                      ),
                      onFieldSubmitted: (_) => _addIncludedName(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: AppColors.purple),
                    onPressed: _addIncludedName,
                    tooltip: 'إضافة',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(labelText: 'السعر (ر.س)', suffixText: 'ر.س'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: const Text('ظاهرة للعملاء'),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              const Text('أصناف التركيبة', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // الأصناف المضافة
              if (_items.isNotEmpty)
                ..._items.map((ref) {
                  final item = allItems.where((i) => i.id == ref.itemId).firstOrNull;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.drag_handle, color: AppColors.textHint),
                    title: Text(item?.name ?? ref.itemId,
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: AppColors.red, size: 20),
                      onPressed: () => _removeItem(ref.itemId),
                    ),
                  );
                }),
              // اختيار صنف لإضافته
              const SizedBox(height: 4),
              DropdownButtonFormField<MenuItemModel>(
                value: null,
                decoration: const InputDecoration(
                  labelText: 'أضف صنفاً',
                  isDense: true,
                ),
                items: allItems
                    .where((i) => !_items.any((r) => r.itemId == i.id))
                    .map((i) => DropdownMenuItem(value: i, child: Text(i.name, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (i) { if (i != null) _addItem(i); },
              ),
              const SizedBox(height: 12),
              const Divider(),
              // ── يظهر على صنف ──────────────────────────────────────────────
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'يظهر على صنف',
                  helperText: 'الصنف الذي ستظهر عليه هذه التركيبة للعميل',
                  prefixIcon: Icon(Icons.link, color: AppColors.purple, size: 20),
                  isDense: true,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_linkedItemIds.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _linkedItemIds.map((id) {
                          final item = allItems.where((i) => i.id == id).firstOrNull;
                          return Chip(
                            label: Text(item?.name ?? id,
                                style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 15),
                            onDeleted: () => setState(() => _linkedItemIds.remove(id)),
                            backgroundColor: AppColors.purple.withOpacity(0.1),
                            side: BorderSide(color: AppColors.purple.withOpacity(0.4)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: null,
                        hint: Text(
                          _linkedItemIds.isEmpty ? '— اختر صنفاً —' : '+ أضف صنفاً آخر',
                          style: TextStyle(fontSize: 13, color: AppColors.textHint),
                        ),
                        isDense: true,
                        isExpanded: true,
                        items: allItems
                            .where((i) => !_linkedItemIds.contains(i.id))
                            .map((i) => DropdownMenuItem(
                                  value: i.id,
                                  child: Text(i.name, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null && !_linkedItemIds.contains(v)) {
                            setState(() => _linkedItemIds.add(v));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              // ── خيارات التركيبة ───────────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.tune, size: 16, color: AppColors.purple),
                  const SizedBox(width: 6),
                  const Text('خيارات التركيبة',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 8),
                child: Text('العميل يختار واحداً منها إجبارياً عند الطلب',
                    style: TextStyle(color: AppColors.textHint, fontSize: 11)),
              ),
              ..._optionItemIds.map((id) {
                final item = allItems.where((i) => i.id == id).firstOrNull;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.radio_button_checked,
                      color: AppColors.purple, size: 18),
                  title: Text(item?.name ?? id,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: AppColors.red, size: 20),
                    onPressed: () => setState(() => _optionItemIds.remove(id)),
                  ),
                );
              }),
              const SizedBox(height: 4),
              DropdownButtonFormField<MenuItemModel>(
                value: null,
                decoration: const InputDecoration(labelText: 'أضف خياراً', isDense: true),
                items: allItems
                    .where((i) => !_optionItemIds.contains(i.id))
                    .map((i) => DropdownMenuItem(
                          value: i,
                          child: Text(i.name, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (i) {
                  if (i != null && !_optionItemIds.contains(i.id)) {
                    setState(() => _optionItemIds.add(i.id));
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'جارٍ الحفظ...' : 'حفظ'),
        ),
      ],
    );
  }
}
