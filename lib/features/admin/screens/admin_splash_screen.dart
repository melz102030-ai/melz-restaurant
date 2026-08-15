import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/splash_image_model.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/splash_image_service.dart';

final _adminSplashImagesProvider = StreamProvider<List<SplashImageModel>>((ref) {
  return SplashImageService.streamImages();
});

// صور الكولاج المتحركة خلف الشعار عند فتح التطبيق لأول مرة — كانت سابقاً
// قسماً داخل شاشة المظهر، نُقلت لتكون وجهة مستقلة ضمن مجموعة "المحتوى
// الترويجي" لأنها محتوى عرض بصري مماثل للبانرات والإعلانات المنبثقة
class AdminSplashScreen extends ConsumerWidget {
  const AdminSplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كولاج شاشة البداية'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'صور تُعرض ككولاج متحرك خلف الشعار عند فتح التطبيق لأول مرة — يتمرر '
              'تلقائياً وبلا توقف. أضف عدة صور بأحجام مختلفة لأفضل نتيجة.',
              style: TextStyle(color: AppColors.textHint, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            const _SplashImagesGrid(),
          ],
        ),
      ),
    );
  }
}

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
              onDelete: () {
                SplashImageService.deleteImage(img.id);
                CloudinaryService.deleteImage(img.imageUrl);
              },
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
