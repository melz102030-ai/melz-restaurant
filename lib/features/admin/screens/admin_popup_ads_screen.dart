import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/popup_ad_model.dart';
import '../../../core/providers/popup_ad_provider.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/popup_ad_service.dart';
import '../../../features/customer/providers/menu_provider.dart';
import '../../../shared/utils/async_utils.dart';
import '../../../shared/widgets/admin_action_widgets.dart';
import '../../../shared/widgets/loading_widget.dart';

const _uuid = Uuid();

// إدارة الإعلانات المنبثقة التي تظهر للعميل عند الدخول — صورة واحدة أو أكثر،
// وصف اختياري، وربط بفئة/صنف/رابط خارجي
class AdminPopupAdsScreen extends ConsumerWidget {
  const AdminPopupAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(adminPopupAdsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('الإعلانات المنبثقة')),
      body: adsAsync.when(
        data: (ads) {
          if (ads.isEmpty) {
            return const EmptyState(
              message: 'لا توجد إعلانات منبثقة\nاضغط + لإضافة إعلان جديد',
              icon: Icons.campaign_outlined,
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final reordered = List<PopupAdModel>.from(ads);
              final a = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, a);
              PopupAdService.reorderAds(reordered);
            },
            itemCount: ads.length,
            itemBuilder: (_, i) => _AdTile(key: ValueKey(ads[i].id), ad: ads[i], index: i),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _PopupAdDialogEditor(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AdTile extends StatelessWidget {
  final PopupAdModel ad;
  final int index;
  const _AdTile({super.key, required this.ad, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ad.isActive
              ? Colors.black.withValues(alpha: 0.06)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ad.imageUrls.isEmpty
                ? Container(
                    width: 60,
                    height: 60,
                    color: AppColors.surfaceLight,
                    child: Icon(Icons.image_not_supported, color: AppColors.textHint, size: 20),
                  )
                : Image.network(
                    ad.imageUrls.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.surfaceLight,
                      child: Icon(Icons.image_not_supported, color: AppColors.textHint, size: 20),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _badge('${ad.imageUrls.length} صورة'),
                    const SizedBox(width: 6),
                    _badge(_linkLabel()),
                  ],
                ),
                if (!ad.isActive) ...[
                  const SizedBox(height: 4),
                  Text('غير مفعّل', style: TextStyle(color: AppColors.error, fontSize: 11)),
                ],
              ],
            ),
          ),
          Switch(
            value: ad.isActive,
            onChanged: (v) =>
                runOrShowError(context, () => PopupAdService.toggleAdActive(ad.id, v)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          ActionIcon(
            icon: Icons.edit,
            color: AppColors.textSecondary,
            tooltip: 'تعديل',
            onTap: () => showDialog(
              context: context,
              builder: (_) => _PopupAdDialogEditor(ad: ad),
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
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn();
  }

  String _linkLabel() => switch (ad.linkType) {
        PopupAdLinkType.category => 'مرتبط بفئة',
        PopupAdLinkType.item => 'مرتبط بصنف',
        PopupAdLinkType.url => 'رابط خارجي',
        PopupAdLinkType.none => 'بدون رابط',
      };

  Widget _badge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.purple.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text,
            style: TextStyle(color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الإعلان'),
        content: const Text('هل تريد حذف هذا الإعلان؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              runOrShowError(context, () => PopupAdService.deleteAd(ad.id));
              for (final url in ad.imageUrls) {
                CloudinaryService.deleteImage(url);
              }
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── محرّر الإعلان ────────────────────────────────────────────────────────────

class _PopupAdDialogEditor extends ConsumerStatefulWidget {
  final PopupAdModel? ad;
  const _PopupAdDialogEditor({this.ad});

  @override
  ConsumerState<_PopupAdDialogEditor> createState() => _PopupAdDialogEditorState();
}

class _PopupAdDialogEditorState extends ConsumerState<_PopupAdDialogEditor> {
  final List<String> _existingImageUrls = [];
  // صور أُزيلت من القائمة أثناء التعديل — تُحذف من Cloudinary فقط بعد نجاح
  // الحفظ فعلياً، حتى لا تُفقد إن أغلق الأدمن النافذة دون حفظ
  final List<String> _removedImageUrls = [];
  final List<Uint8List> _newImageBytes = [];
  final _captionCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _isActive = true;
  bool _autoScroll = true;
  int _autoScrollSeconds = 4;
  PopupAdLinkType _linkType = PopupAdLinkType.none;
  String? _linkId;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final ad = widget.ad;
    if (ad != null) {
      _existingImageUrls.addAll(ad.imageUrls);
      _captionCtrl.text = ad.caption ?? '';
      _urlCtrl.text = ad.externalUrl ?? '';
      _isActive = ad.isActive;
      _autoScroll = ad.autoScroll;
      _autoScrollSeconds = ad.autoScrollSeconds;
      _linkType = ad.linkType;
      _linkId = ad.linkId;
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _newImageBytes.add(result.files.single.bytes!));
    }
  }

  Future<void> _save() async {
    final totalImages = _existingImageUrls.length + _newImageBytes.length;
    if (totalImages == 0) {
      setState(() => _error = 'أضف صورة واحدة على الأقل');
      return;
    }
    if ((_linkType == PopupAdLinkType.category || _linkType == PopupAdLinkType.item) &&
        _linkId == null) {
      setState(() => _error = 'اختر الفئة أو الصنف المرتبط بالإعلان');
      return;
    }
    if (_linkType == PopupAdLinkType.url && _urlCtrl.text.trim().isEmpty) {
      setState(() => _error = 'أدخل الرابط الخارجي');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final uploadedUrls = <String>[];
      for (final bytes in _newImageBytes) {
        final url = await CloudinaryService.uploadImage(bytes, 'popup_ad_${_uuid.v4()}.jpg');
        if (url != null) uploadedUrls.add(url);
      }
      final ad = PopupAdModel(
        id: widget.ad?.id ?? '',
        imageUrls: [..._existingImageUrls, ...uploadedUrls],
        caption: _captionCtrl.text.trim().isEmpty ? null : _captionCtrl.text.trim(),
        isActive: _isActive,
        sortOrder: widget.ad?.sortOrder ?? 0,
        autoScroll: _autoScroll,
        autoScrollSeconds: _autoScrollSeconds,
        linkType: _linkType,
        linkId: (_linkType == PopupAdLinkType.category || _linkType == PopupAdLinkType.item)
            ? _linkId
            : null,
        externalUrl: _linkType == PopupAdLinkType.url ? _urlCtrl.text.trim() : null,
      );
      if (widget.ad != null) {
        await PopupAdService.updateAd(ad);
      } else {
        await PopupAdService.addAd(ad);
      }
      for (final url in _removedImageUrls) {
        CloudinaryService.deleteImage(url);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(adminCategoriesProvider).valueOrNull ?? [];
    final items = ref.watch(adminMenuItemsProvider).valueOrNull ?? [];

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 700),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    widget.ad != null ? 'تعديل إعلان' : 'إضافة إعلان منبثق',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('صور الإعلان (واحدة أو أكثر) *',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._existingImageUrls.asMap().entries.map((e) => _ImageThumb(
                              child: Image.network(e.value, fit: BoxFit.cover),
                              onRemove: () => setState(() {
                                _removedImageUrls.add(e.value);
                                _existingImageUrls.removeAt(e.key);
                              }),
                            )),
                        ..._newImageBytes.asMap().entries.map((e) => _ImageThumb(
                              child: Image.memory(e.value, fit: BoxFit.cover),
                              onRemove: () => setState(() => _newImageBytes.removeAt(e.key)),
                            )),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.purpleDark),
                            ),
                            child: Icon(Icons.add_photo_alternate,
                                color: AppColors.textHint, size: 26),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _captionCtrl,
                      maxLines: 2,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'وصف أسفل الصور (اختياري)',
                        prefixIcon: Icon(Icons.short_text),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('تمرير تلقائي بين الصور:',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const Spacer(),
                        Switch(
                          value: _autoScroll,
                          onChanged: (v) => setState(() => _autoScroll = v),
                        ),
                      ],
                    ),
                    if (_autoScroll) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('مدة عرض كل صورة:',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const Spacer(),
                          DropdownButton<int>(
                            value: _autoScrollSeconds,
                            dropdownColor: AppColors.surface,
                            items: [3, 4, 5, 6, 8, 10]
                                .map((s) => DropdownMenuItem(value: s, child: Text('$s ث')))
                                .toList(),
                            onChanged: (v) => setState(() => _autoScrollSeconds = v ?? 4),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text('عند الضغط على الإعلان، الانتقال إلى:',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TypeChip(
                          label: 'لا شيء',
                          icon: Icons.block,
                          selected: _linkType == PopupAdLinkType.none,
                          onTap: () => setState(() {
                            _linkType = PopupAdLinkType.none;
                            _linkId = null;
                          }),
                        ),
                        TypeChip(
                          label: 'فئة',
                          icon: Icons.category_outlined,
                          selected: _linkType == PopupAdLinkType.category,
                          onTap: () => setState(() {
                            _linkType = PopupAdLinkType.category;
                            _linkId = null;
                          }),
                        ),
                        TypeChip(
                          label: 'صنف',
                          icon: Icons.fastfood_outlined,
                          selected: _linkType == PopupAdLinkType.item,
                          onTap: () => setState(() {
                            _linkType = PopupAdLinkType.item;
                            _linkId = null;
                          }),
                        ),
                        TypeChip(
                          label: 'رابط خارجي',
                          icon: Icons.link,
                          selected: _linkType == PopupAdLinkType.url,
                          onTap: () => setState(() => _linkType = PopupAdLinkType.url),
                        ),
                      ],
                    ),
                    if (_linkType == PopupAdLinkType.category) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _linkId,
                        dropdownColor: AppColors.surface,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'اختر الفئة *'),
                        items: categories
                            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _linkId = v),
                      ),
                    ],
                    if (_linkType == PopupAdLinkType.item) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _linkId,
                        dropdownColor: AppColors.surface,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'اختر الصنف *'),
                        items: items
                            .map((i) => DropdownMenuItem(value: i.id, child: Text(i.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _linkId = v),
                      ),
                    ],
                    if (_linkType == PopupAdLinkType.url) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _urlCtrl,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'الرابط الخارجي *',
                          prefixIcon: Icon(Icons.link),
                          hintText: 'https://...',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('نشط:', style: TextStyle(color: AppColors.textSecondary)),
                        const Spacer(),
                        Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                  ),
                  child: Text(_error!, style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.ad != null ? AppStrings.save : AppStrings.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  const _ImageThumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 76, height: 76, child: child),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

