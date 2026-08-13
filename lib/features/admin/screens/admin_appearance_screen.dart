import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_theme_settings.dart';
import '../../../core/models/splash_image_model.dart';
import '../../../core/providers/app_theme_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/app_theme_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/splash_image_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';

final _adminSplashImagesProvider = StreamProvider<List<SplashImageModel>>((ref) {
  return SplashImageService.streamImages();
});

class AdminAppearanceScreen extends ConsumerStatefulWidget {
  const AdminAppearanceScreen({super.key});

  @override
  ConsumerState<AdminAppearanceScreen> createState() => _AdminAppearanceScreenState();
}

class _AdminAppearanceScreenState extends ConsumerState<AdminAppearanceScreen> {
  AppThemeSettings? _draft;
  bool _isSaving = false;

  Uint8List? _logoBytes;
  Uint8List? _coverBytes;
  bool _isSavingImages = false;

  AppThemeSettings _draftOrCurrent(AppThemeSettings current) => _draft ?? current;

  Future<void> _pickBrandImage(bool isLogo) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        if (isLogo) {
          _logoBytes = result.files.single.bytes;
        } else {
          _coverBytes = result.files.single.bytes;
        }
      });
    }
  }

  // يحفظ الشعار/الغلاف في وثيقة إعدادات المطعم عبر copyWith — منفصل عن حفظ
  // ألوان/خط المظهر لأنهما وثيقتان مختلفتان في Firestore
  Future<void> _saveBrandImages() async {
    setState(() => _isSavingImages = true);
    try {
      final current = await SettingsService.getSettings();
      String? logoUrl = current.logoUrl;
      String? coverUrl = current.coverUrl;
      if (_logoBytes != null) {
        logoUrl = await CloudinaryService.uploadImage(_logoBytes!, 'logo.jpg') ?? logoUrl;
      }
      if (_coverBytes != null) {
        coverUrl = await CloudinaryService.uploadImage(_coverBytes!, 'cover.jpg') ?? coverUrl;
      }
      await SettingsService.updateSettings(
        current.copyWith(logoUrl: logoUrl, coverUrl: coverUrl),
      );
      if (mounted) {
        setState(() {
          _logoBytes = null;
          _coverBytes = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم حفظ الشعار والغلاف'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingImages = false);
    }
  }

  void _update(AppThemeSettings current, AppThemeSettings Function(AppThemeSettings) fn) {
    setState(() => _draft = fn(_draftOrCurrent(current)));
  }

  Future<void> _save(AppThemeSettings settings) async {
    setState(() => _isSaving = true);
    try {
      await AppThemeService.updateTheme(settings);
      if (mounted) {
        setState(() => _draft = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم حفظ المظهر — التطبيق يستخدمه الآن في كل الشاشات'),
          backgroundColor: AppColors.success,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // يحفظ المظهر الحالي كإفتراضي (يستبدل أي إفتراضي محفوظ سابقاً) ويطبّقه أيضاً كمظهر حالي
  Future<void> _setAsDefault(AppThemeSettings settings) async {
    setState(() => _isSaving = true);
    try {
      await AppThemeService.setDefaultTheme(settings);
      await AppThemeService.updateTheme(settings);
      if (mounted) {
        setState(() => _draft = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم تعيين هذا المظهر كإفتراضي — حل محل الإفتراضي السابق'),
          backgroundColor: AppColors.success,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // يرجع للمظهر الذي عيّنه الأدمن كإفتراضي (أو المظهر الأصلي للتطبيق إن لم يُعيَّن أي إفتراضي بعد)
  Future<void> _restoreDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استعادة المظهر الافتراضي'),
        content: const Text('سيتم استبدال المظهر الحالي بالكامل بالمظهر الافتراضي المحفوظ. هل تريد المتابعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('استعادة')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      final defaultTheme = await AppThemeService.getDefaultTheme() ?? const AppThemeSettings();
      await AppThemeService.updateTheme(defaultTheme);
      if (mounted) {
        setState(() => _draft = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم استعادة المظهر الافتراضي'),
          backgroundColor: AppColors.success,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickColor(BuildContext context, Color initial, ValueChanged<Color> onPicked) async {
    Color temp = initial;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر لوناً'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initial,
            onColorChanged: (c) => temp = c,
            enableAlpha: false,
            labelTypes: const [ColorLabelType.hex],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              onPicked(temp);
              Navigator.pop(ctx);
            },
            child: const Text('اختيار'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(appThemeProvider);
    final settings = _draftOrCurrent(current);
    final hasChanges = _draft != null;
    final restaurantSettings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المظهر'),
        automaticallyImplyLeading: false,
        actions: [
          if (hasChanges)
            TextButton(
              onPressed: () => setState(() => _draft = null),
              child: const Text('تراجع'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // معاينة حية
          _PreviewCard(settings: settings),
          const SizedBox(height: 24),

          _SectionTitle('الألوان الأساسية'),
          const SizedBox(height: 10),
          _ColorRow(
            label: 'اللون الأساسي',
            color: Color(settings.primaryColor),
            onTap: () => _pickColor(context, Color(settings.primaryColor),
                (c) => _update(current, (s) => s.copyWith(primaryColor: c.toARGB32()))),
          ),
          _ColorRow(
            label: 'اللون الثانوي',
            color: Color(settings.secondaryColor),
            onTap: () => _pickColor(context, Color(settings.secondaryColor),
                (c) => _update(current, (s) => s.copyWith(secondaryColor: c.toARGB32()))),
          ),
          _ColorRow(
            label: 'لون خلفية التطبيق',
            color: Color(settings.backgroundColor),
            onTap: () => _pickColor(context, Color(settings.backgroundColor),
                (c) => _update(current, (s) => s.copyWith(backgroundColor: c.toARGB32()))),
          ),
          _ColorRow(
            label: 'لون بطاقات الأصناف والواجهات العلوية',
            color: Color(settings.cardColor),
            onTap: () => _pickColor(context, Color(settings.cardColor),
                (c) => _update(current, (s) => s.copyWith(cardColor: c.toARGB32()))),
          ),
          _ColorRow(
            label: 'لون النصوص',
            color: Color(settings.textColor),
            onTap: () => _pickColor(context, Color(settings.textColor),
                (c) => _update(current, (s) => s.copyWith(textColor: c.toARGB32()))),
          ),

          const SizedBox(height: 24),
          _SectionTitle('الخط'),
          const SizedBox(height: 10),
          _FontPicker(
            selected: settings.fontFamily,
            onChanged: (f) => _update(current, (s) => s.copyWith(fontFamily: f)),
          ),

          const SizedBox(height: 24),
          _SectionTitle('شكل البطاقات'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StyleChip(
                  label: 'حواف دائرية',
                  icon: Icons.crop_square,
                  selected: settings.cardStyle == CardStyle.rounded,
                  onTap: () => _update(current, (s) => s.copyWith(cardStyle: CardStyle.rounded)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StyleChip(
                  label: 'حواف حادة',
                  icon: Icons.crop_din,
                  selected: settings.cardStyle == CardStyle.sharp,
                  onTap: () => _update(current, (s) => s.copyWith(cardStyle: CardStyle.sharp)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SectionTitle('طريقة عرض الأصناف للعميل'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StyleChip(
                  label: 'قائمة',
                  icon: Icons.view_list,
                  selected: settings.menuDisplayStyle == MenuDisplayStyle.list,
                  onTap: () =>
                      _update(current, (s) => s.copyWith(menuDisplayStyle: MenuDisplayStyle.list)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StyleChip(
                  label: 'شبكة',
                  icon: Icons.grid_view,
                  selected: settings.menuDisplayStyle == MenuDisplayStyle.grid,
                  onTap: () =>
                      _update(current, (s) => s.copyWith(menuDisplayStyle: MenuDisplayStyle.grid)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SectionTitle('الشعار وصورة الغلاف'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ImagePicker(
                  label: 'شعار المطعم',
                  bytes: _logoBytes,
                  networkUrl: restaurantSettings.logoUrl,
                  onPick: () => _pickBrandImage(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImagePicker(
                  label: 'صورة الغلاف',
                  bytes: _coverBytes,
                  networkUrl: restaurantSettings.coverUrl,
                  onPick: () => _pickBrandImage(false),
                  aspectRatio: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isSavingImages ? null : _saveBrandImages,
            icon: _isSavingImages
                ? const SizedBox(
                    width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: Text(_isSavingImages ? 'جاري الحفظ...' : 'حفظ الشعار والغلاف'),
          ),

          const SizedBox(height: 24),
          _SectionTitle('خلفية شاشة التحميل الأولى'),
          const SizedBox(height: 6),
          Text(
            'صور تُعرض ككولاج متحرك خلف الشعار عند فتح التطبيق لأول مرة — يتمرر تلقائياً وبلا توقف. أضف عدة صور بأحجام مختلفة لأفضل نتيجة.',
            style: TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
          const SizedBox(height: 10),
          const _SplashImagesGrid(),

          const SizedBox(height: 32),
          AppButton(
            label: hasChanges ? 'حفظ المظهر' : 'لا توجد تغييرات',
            icon: Icons.check_circle,
            width: double.infinity,
            isLoading: _isSaving,
            onPressed: hasChanges ? () => _save(settings) : null,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isSaving ? null : () => _setAsDefault(settings),
            icon: const Icon(Icons.bookmark_added_outlined),
            label: const Text('تعيين الحالي كإفتراضي'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _restoreDefault,
            icon: const Icon(Icons.restart_alt),
            label: const Text('استعادة المظهر الافتراضي'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ColorRow({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.1)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ),
            Text(
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_left, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _FontPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _FontPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppThemeSettings.availableFonts.map((font) {
        final isSelected = font == selected;
        TextStyle style;
        try {
          style = GoogleFonts.getFont(font, fontWeight: FontWeight.w600, fontSize: 14);
        } catch (_) {
          style = GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14);
        }
        return GestureDetector(
          onTap: () => onChanged(font),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.purple : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppColors.purple : AppColors.surfaceLight),
            ),
            child: Text(
              font,
              style: style.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StyleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _StyleChip({
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.purple : AppColors.surfaceLight, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.purple : AppColors.textHint),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                  color: selected ? AppColors.purple : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final AppThemeSettings settings;
  const _PreviewCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    final primary = Color(settings.primaryColor);
    final secondary = Color(settings.secondaryColor);
    final background = Color(settings.backgroundColor);
    final card = Color(settings.cardColor);
    final text = Color(settings.textColor);
    final radius = settings.cardStyle == CardStyle.rounded ? 16.0 : 4.0;
    TextStyle font(double size, FontWeight w) {
      try {
        return GoogleFonts.getFont(settings.fontFamily, fontSize: size, fontWeight: w);
      } catch (_) {
        return GoogleFonts.cairo(fontSize: size, fontWeight: w);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('معاينة حية', style: font(13, FontWeight.w600).copyWith(color: text.withOpacity(0.6))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary, secondary]),
                    borderRadius: BorderRadius.circular(radius > 8 ? 10 : 4),
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اسم الصنف', style: font(15, FontWeight.bold).copyWith(color: text)),
                      Text('12 ر.س', style: font(13, FontWeight.w600).copyWith(color: primary)),
                    ],
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary, secondary]),
                    borderRadius: BorderRadius.circular(radius > 8 ? 10 : 4),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── شبكة صور كولاج شاشة التحميل ──────────────────────────────────────────────

class _SplashImagesGrid extends ConsumerStatefulWidget {
  const _SplashImagesGrid();

  @override
  ConsumerState<_SplashImagesGrid> createState() => _SplashImagesGridState();
}

class _SplashImagesGridState extends ConsumerState<_SplashImagesGrid> {
  bool _uploading = false;

  Future<void> _addImages(List<SplashImageModel> current) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _uploading = true);
    try {
      var nextOrder = current.length;
      for (final f in result.files) {
        if (f.bytes == null) continue;
        final url = await CloudinaryService.uploadImage(
            f.bytes!, 'splash_${DateTime.now().millisecondsSinceEpoch}_${f.name}');
        if (url != null) {
          await SplashImageService.addImage(url, nextOrder++);
        }
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(_adminSplashImagesProvider).valueOrNull ?? [];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...images.map((img) => _SplashImageTile(
              image: img,
              onDelete: () => SplashImageService.deleteImage(img.id),
            )),
        GestureDetector(
          onTap: _uploading ? null : () => _addImages(images),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purpleDark),
            ),
            child: _uploading
                ? const Center(
                    child: SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : Icon(Icons.add_photo_alternate, color: AppColors.textHint),
          ),
        ),
      ],
    );
  }
}

class _SplashImageTile extends StatelessWidget {
  final SplashImageModel image;
  final VoidCallback onDelete;
  const _SplashImageTile({required this.image, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            image.imageUrl,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 72, height: 72, color: AppColors.surfaceLight),
          ),
        ),
        Positioned(
          top: -6,
          left: -6,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 13),
            ),
          ),
        ),
      ],
    );
  }
}

// ── منتقي شعار/غلاف المطعم ────────────────────────────────────────────────────

class _ImagePicker extends StatelessWidget {
  final String label;
  final Uint8List? bytes;
  final String? networkUrl;
  final VoidCallback onPick;
  final double aspectRatio;

  const _ImagePicker({
    required this.label,
    this.bytes,
    this.networkUrl,
    required this.onPick,
    this.aspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = bytes != null || networkUrl != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onPick,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasImage ? AppColors.purple : AppColors.purpleDark,
                  width: hasImage ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: bytes != null
                    ? Image.memory(bytes!, fit: BoxFit.cover)
                    : networkUrl != null
                        ? Image.network(
                            networkUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
              ),
            ),
          ),
        ),
        if (hasImage)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              bytes != null ? 'صورة جديدة - اضغط حفظ' : 'محفوظة',
              style: TextStyle(
                color: bytes != null ? AppColors.warning : AppColors.success,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, color: AppColors.textHint, size: 32),
          const SizedBox(height: 4),
          Text('رفع صورة', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        ],
      );
}
