import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/promo_banner_model.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/promo_banner_service.dart';
import '../../../features/customer/providers/menu_provider.dart';
import '../../../shared/utils/async_utils.dart';
import '../../../shared/widgets/admin_action_widgets.dart';
import '../../../shared/widgets/loading_widget.dart';

const _uuid = Uuid();

// بانرات عروض الصفحة الرئيسية للعميل — كانت سابقاً تبويباً داخل شاشة إدارة
// القائمة، نُقلت لتكون وجهة مستقلة ضمن مجموعة "المحتوى الترويجي" في القائمة
// الجانبية، لأنها محتوى عرض بصري وليست جزءاً من بنية القائمة نفسها
class AdminBannersScreen extends ConsumerWidget {
  const AdminBannersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(adminBannersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('البانرات'),
        automaticallyImplyLeading: false,
      ),
      body: bannersAsync.when(
        data: (banners) {
          if (banners.isEmpty) {
            return const EmptyState(
              message: 'لا توجد بانرات عروض\nاضغط + لإضافة بانر جديد',
              icon: Icons.view_carousel_outlined,
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final reordered = List<PromoBannerModel>.from(banners);
              final b = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, b);
              PromoBannerService.reorderBanners(reordered);
            },
            itemCount: banners.length,
            itemBuilder: (_, i) =>
                _BannerTile(key: ValueKey(banners[i].id), banner: banners[i], index: i),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _BannerDialog(),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  final PromoBannerModel banner;
  final int index;
  const _BannerTile({super.key, required this.banner, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: banner.isActive
              ? Colors.black.withValues(alpha: 0.06)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_handle, color: AppColors.textHint, size: 18),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              banner.imageUrl,
              width: 80,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 50,
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
                _linkBadge(),
                if (!banner.isActive) ...[
                  const SizedBox(height: 4),
                  Text('غير مفعّل', style: TextStyle(color: AppColors.error, fontSize: 11)),
                ],
              ],
            ),
          ),
          Switch(
            value: banner.isActive,
            onChanged: (v) => runOrShowError(
                context, () => PromoBannerService.toggleBannerActive(banner.id, v)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          ActionIcon(
            icon: Icons.edit,
            color: AppColors.textSecondary,
            tooltip: 'تعديل',
            onTap: () => showDialog(
              context: context,
              builder: (_) => _BannerDialog(banner: banner),
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

  Widget _linkBadge() {
    final text = switch (banner.linkType) {
      BannerLinkType.category => 'مرتبط بفئة',
      BannerLinkType.item => 'مرتبط بصنف',
      BannerLinkType.none => 'بدون رابط',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text,
          style: TextStyle(color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  // البانر بلا اسم نصي — صورة مصغّرة في نافذة التأكيد تساعد على التأكد من
  // حذف العنصر الصحيح وسط قائمة بانرات قد تتشابه بصرياً
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف البانر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                banner.imageUrl,
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  color: AppColors.surfaceLight,
                  child: Icon(Icons.image_not_supported, color: AppColors.textHint),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('هل تريد حذف هذا البانر؟'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              runOrShowError(context, () => PromoBannerService.deleteBanner(banner.id));
              CloudinaryService.deleteImage(banner.imageUrl);
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Banner Dialog ────────────────────────────────────────────────────────────

class _BannerDialog extends ConsumerStatefulWidget {
  final PromoBannerModel? banner;
  const _BannerDialog({this.banner});

  @override
  ConsumerState<_BannerDialog> createState() => _BannerDialogState();
}

class _BannerDialogState extends ConsumerState<_BannerDialog> {
  bool _isActive = true;
  bool _isSaving = false;
  String? _imageUrl;
  Uint8List? _imageBytes;
  BannerLinkType _linkType = BannerLinkType.none;
  String? _linkId;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      _imageUrl = widget.banner!.imageUrl;
      _isActive = widget.banner!.isActive;
      _linkType = widget.banner!.linkType;
      _linkId = widget.banner!.linkId;
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _imageBytes = result.files.single.bytes);
    }
  }

  Future<void> _save() async {
    if (_imageBytes == null && _imageUrl == null) {
      setState(() => _error = 'أضف صورة البانر');
      return;
    }
    if (_linkType != BannerLinkType.none && _linkId == null) {
      setState(() => _error = 'اختر الفئة أو الصنف المرتبط بالبانر');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      String finalImageUrl = _imageUrl ?? '';
      if (_imageBytes != null) {
        finalImageUrl = await CloudinaryService.uploadImage(
                _imageBytes!, 'banner_${_uuid.v4()}.jpg') ??
            finalImageUrl;
      }
      final banner = PromoBannerModel(
        id: widget.banner?.id ?? '',
        imageUrl: finalImageUrl,
        sortOrder: widget.banner?.sortOrder ?? 0,
        isActive: _isActive,
        linkType: _linkType,
        linkId: _linkType == BannerLinkType.none ? null : _linkId,
      );
      if (widget.banner != null) {
        await PromoBannerService.updateBanner(banner);
        if (_imageBytes != null && widget.banner!.imageUrl != finalImageUrl) {
          CloudinaryService.deleteImage(widget.banner!.imageUrl);
        }
      } else {
        await PromoBannerService.addBanner(banner);
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
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 660),
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
                    widget.banner != null ? 'تعديل بانر' : 'إضافة بانر',
                    style:
                        TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 130,
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
                                      Icon(Icons.add_photo_alternate,
                                          color: AppColors.textHint, size: 36),
                                      const SizedBox(height: 6),
                                      Text('اضغط لرفع صورة البانر *',
                                          style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('ربط البانر بـ:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TypeChip(
                            label: 'لا شيء',
                            icon: Icons.block,
                            selected: _linkType == BannerLinkType.none,
                            onTap: () => setState(() {
                              _linkType = BannerLinkType.none;
                              _linkId = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TypeChip(
                            label: 'فئة',
                            icon: Icons.category_outlined,
                            selected: _linkType == BannerLinkType.category,
                            onTap: () => setState(() {
                              _linkType = BannerLinkType.category;
                              _linkId = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TypeChip(
                            label: 'صنف',
                            icon: Icons.fastfood_outlined,
                            selected: _linkType == BannerLinkType.item,
                            onTap: () => setState(() {
                              _linkType = BannerLinkType.item;
                              _linkId = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                    if (_linkType == BannerLinkType.category) ...[
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
                    if (_linkType == BannerLinkType.item) ...[
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
                    : Text(widget.banner != null ? AppStrings.save : AppStrings.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
