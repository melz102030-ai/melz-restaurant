import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/splash_images_provider.dart';

// خلفية كولاج صور متحرك لا نهائي — نفس فكرة شاشة التحميل الأولى (web/index.html)
// لكن كمكوّن Flutter أصلي يُستخدم داخل شاشات التطبيق (الدخول/إنشاء الحساب).
// الأعمدة تتمرر للأعلى إلى ما لا نهاية عبر Ticker (بدون تكرار/قفزة)، والصور
// تُعرض بارتفاعات متفاوتة تلقائياً بغض النظر عن حجمها الأصلي، متلاصقة بلا فراغات.
class AnimatedPhotoCollageBackground extends ConsumerWidget {
  final int columns;
  const AnimatedPhotoCollageBackground({super.key, this.columns = 3});

  static const _speeds = [14.0, 22.0, 18.0, 26.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(activeSplashImagesProvider).valueOrNull ?? const <String>[];
    if (images.isEmpty) return const SizedBox.shrink();

    final cols = MediaQuery.of(context).size.width < 480 ? 2 : columns;
    final buckets = List.generate(cols, (_) => <String>[]);
    for (var i = 0; i < images.length; i++) {
      buckets[i % cols].add(images[i]);
    }

    return ClipRect(
      child: Row(
        children: List.generate(cols, (i) {
          if (buckets[i].isEmpty) return const SizedBox.shrink();
          return Expanded(
            child: _CollageColumn(
              images: buckets[i],
              speed: _speeds[i % _speeds.length],
              heightPhase: i * 2,
            ),
          );
        }),
      ),
    );
  }
}

// تعتيم متدرّج فوق الكولاج بلون يمتزج مع خلفية الشاشة — بدون أي تمويه (blur)
// حتى تبقى الصور واضحة الدقة خلف المحتوى.
class CollageScrim extends StatelessWidget {
  final Color color;
  const CollageScrim({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.55),
            color.withValues(alpha: 0.82),
            color.withValues(alpha: 0.94),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

class _CollageColumn extends StatefulWidget {
  final List<String> images;
  final double speed; // بكسل/ثانية
  final int heightPhase;
  const _CollageColumn({required this.images, required this.speed, required this.heightPhase});

  @override
  State<_CollageColumn> createState() => _CollageColumnState();
}

class _CollageColumnState extends State<_CollageColumn> with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final Ticker _ticker;

  static const _heights = [170.0, 230.0, 190.0, 250.0, 210.0, 180.0];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(elapsed.inMilliseconds / 1000.0 * widget.speed);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) {
        final url = widget.images[i % widget.images.length];
        final h = _heights[(i + widget.heightPhase) % _heights.length];
        return Image.network(
          url,
          height: h,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => SizedBox(height: h),
        );
      },
    );
  }
}
