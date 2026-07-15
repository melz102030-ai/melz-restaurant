import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/phone_password_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? returnTo;
  const LoginScreen({super.key, this.returnTo});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  void _onLoginSuccess(UserModel user) {
    switch (user.role) {
      case UserRole.admin:
        context.go('/admin');
        break;
      case UserRole.kitchen:
        context.go('/kitchen');
        break;
      case UserRole.customer:
        context.go(widget.returnTo ?? '/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 768;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: Row(
        children: [
          // Left panel (shown on wide screens) — dark gradient + floating bubbles
          if (isWide)
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(child: Container(
                    decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                  )),
                  const Positioned.fill(child: _AnimatedBubbles(isDark: true)),
                  Positioned.fill(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(large: true),
                      const SizedBox(height: 20),
                      Text(
                        settings.welcomeMessage ?? AppStrings.appTagline,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 18,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 60),
                      _buildFeatureRow(Icons.restaurant_menu, 'قائمة طعام متنوعة'),
                      const SizedBox(height: 16),
                      _buildFeatureRow(Icons.delivery_dining, 'توصيل سريع'),
                      const SizedBox(height: 16),
                      _buildFeatureRow(Icons.track_changes, 'تتبع طلبك لحظة بلحظة'),
                    ],
                  )),
                ],
              ),
            ),

          // Right panel - login form (subtle bubbles on mobile)
          Expanded(
            flex: isWide ? 4 : 10,
            child: Stack(
              children: [
                Positioned.fill(child: Container(color: AppColors.background)),
                if (!isWide) const Positioned.fill(child: _AnimatedBubbles(isDark: false)),
                Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isWide) ...[
                          Center(child: _buildLogo()),
                          const SizedBox(height: 40),
                        ],
                        PhonePasswordForm(onSuccess: _onLoginSuccess)
                            .animate()
                            .fadeIn(delay: 100.ms),

                        const SizedBox(height: 40),
                        const Divider(color: AppColors.surfaceLight),
                        const SizedBox(height: 20),

                        // Admin/Kitchen login hint
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'هل أنت من فريق العمل؟',
                                style: TextStyle(color: AppColors.textHint),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => context.push('/staff-login'),
                                icon: const Icon(Icons.admin_panel_settings),
                                label: const Text('دخول الإدارة والمطبخ'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.manjawi,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ─── أزرار معاينة مؤقتة (DEV ONLY) ───────────
                        const SizedBox(height: 24),
                        const _DevLoginButtons(),
                      ],
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo({bool large = false}) {
    final size = large ? 220.0 : 130.0;
    final settingsAsync = ref.watch(settingsStreamProvider);
    final logoUrl = settingsAsync.valueOrNull?.logoUrl;
    final isLoading = settingsAsync.isLoading;

    if (isLoading) return SizedBox(width: size, height: size);

    if (logoUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(large ? 28 : 20),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.55),
              blurRadius: large ? 48 : 28,
              spreadRadius: large ? 8 : 4,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(large ? 28 : 20),
          child: Image.network(
            logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _logoFallback(large, size),
          ),
        ),
      ).animate().scale(duration: 700.ms, curve: Curves.elasticOut);
    }

    return _logoFallback(large, size)
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _logoFallback(bool large, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(large ? 28 : 20),
          gradient: AppColors.heroGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.restaurant,
            color: Colors.white,
            size: large ? 80 : 48,
          ),
        ),
      );

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2);
  }
}

// ─── أزرار الدخول السريع للمعاينة ─────────────────────────────────────────────
class _DevLoginButtons extends ConsumerStatefulWidget {
  const _DevLoginButtons();

  @override
  ConsumerState<_DevLoginButtons> createState() => _DevLoginButtonsState();
}

class _DevLoginButtonsState extends ConsumerState<_DevLoginButtons> {
  UserRole? _loadingRole;

  Future<void> _loginAs(UserRole role) async {
    if (_loadingRole != null) return;
    setState(() => _loadingRole = role);

    const names = {
      UserRole.customer: 'عميل تجريبي',
      UserRole.admin: 'مدير النظام',
      UserRole.kitchen: 'موظف مطبخ',
    };

    try {
      // محاولة تسجيل الدخول المجهول للحصول على Firebase Auth token
      String uid = 'dev_${role.name}';
      try {
        final anonResult = await FirebaseAuth.instance.signInAnonymously();
        if (anonResult.user != null) uid = anonResult.user!.uid;
      } catch (_) {
        // Anonymous Auth غير مفعّل — نكمل بـ uid ثابت
      }

      final user = UserModel(
        id: uid,
        phone: 'dev_${role.name}',
        name: names[role]!,
        role: role,
        createdAt: DateTime.now(),
      );

      // حفظ في Firestore حتى يُعرف الدور بعد إعادة التحميل
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(user.toMap(), SetOptions(merge: true));
      } catch (_) {}

      await ref.read(authProvider.notifier).login(user);

      if (!mounted) return;
      switch (role) {
        case UserRole.customer:
          context.go('/home');
          break;
        case UserRole.admin:
          context.go('/admin');
          break;
        case UserRole.kitchen:
          context.go('/kitchen');
          break;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('خطأ في الدخول التجريبي: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _loadingRole = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.developer_mode, color: Colors.amber, size: 16),
              const SizedBox(width: 6),
              const Text(
                'معاينة سريعة',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DEV',
                  style: TextStyle(color: Colors.amber, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _DevBtn(
                label: 'عميل',
                icon: Icons.person,
                color: AppColors.purple,
                isLoading: _loadingRole == UserRole.customer,
                onTap: () => _loginAs(UserRole.customer),
              ),
              const SizedBox(width: 8),
              _DevBtn(
                label: 'مطبخ',
                icon: Icons.restaurant,
                color: AppColors.manjawi,
                isLoading: _loadingRole == UserRole.kitchen,
                onTap: () => _loginAs(UserRole.kitchen),
              ),
              const SizedBox(width: 8),
              _DevBtn(
                label: 'إدارة',
                icon: Icons.admin_panel_settings,
                color: AppColors.red,
                isLoading: _loadingRole == UserRole.admin,
                onTap: () => _loginAs(UserRole.admin),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

class _DevBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _DevBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.08),
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: color),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 15),
                  const SizedBox(width: 4),
                  Text(label, style: const TextStyle(fontSize: 13)),
                ],
              ),
      ),
    );
  }
}

// ── Floating ambient bubbles ─────────────────────────────────────────────────
class _AnimatedBubbles extends StatefulWidget {
  final bool isDark;
  const _AnimatedBubbles({required this.isDark});

  @override
  State<_AnimatedBubbles> createState() => _AnimatedBubblesState();
}

class _AnimatedBubblesState extends State<_AnimatedBubbles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // مدة قصيرة جداً فقط لتحريك إطارات الرسم بسلاسة (60fps)
    // المواضع تُحسب من الوقت الحقيقي لا من t، فلا تقطع عند الدورة
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _BubblesPainter(_ctrl.value, widget.isDark),
        size: Size.infinite,
      ),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  final double t;
  final bool isDark;

  // [x_fraction, diameter, speed, phase_offset]
  static const _defs = <List<double>>[
    [0.08, 28, 0.55, 0.00],
    [0.22, 16, 0.80, 0.12],
    [0.38, 40, 0.45, 0.28],
    [0.53, 22, 0.70, 0.42],
    [0.67, 14, 0.90, 0.57],
    [0.81, 32, 0.60, 0.68],
    [0.15, 18, 0.75, 0.80],
    [0.46, 12, 0.50, 0.35],
    [0.72, 36, 0.65, 0.15],
    [0.92, 20, 0.85, 0.90],
    [0.30, 24, 0.55, 0.55],
    [0.60, 10, 0.95, 0.73],
  ];

  _BubblesPainter(this.t, this.isDark);

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final cx = center.dx;
    final cy = center.dy;
    final s = size;

    // الطرف السفلي المدبب
    path.moveTo(cx, cy + s * 0.85);

    // صعود الجانب الأيسر إلى الحافة اليسرى
    path.cubicTo(
      cx - s * 0.1, cy + s * 0.55,
      cx - s,       cy + s * 0.10,
      cx - s,       cy - s * 0.15,
    );
    // الانتفاخ الأيسر العلوي ← إلى المنتصف (الوادي)
    path.cubicTo(
      cx - s,       cy - s * 0.75,
      cx - s * 0.3, cy - s * 0.95,
      cx,           cy - s * 0.55,
    );
    // من المنتصف ← الانتفاخ الأيمن العلوي
    path.cubicTo(
      cx + s * 0.3, cy - s * 0.95,
      cx + s,       cy - s * 0.75,
      cx + s,       cy - s * 0.15,
    );
    // نزول الجانب الأيمن إلى الطرف السفلي
    path.cubicTo(
      cx + s,       cy + s * 0.10,
      cx + s * 0.1, cy + s * 0.55,
      cx,           cy + s * 0.85,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final colors = isDark
        ? [Colors.white, const Color(0xFFFFD700), const Color(0xFFFF69B4)]
        : [const Color(0xFF6A0DAD), const Color(0xFF800040), const Color(0xFF9C4DCA)];
    final maxOpacity = isDark ? 0.22 : 0.07;

    // الوقت الحقيقي بالثواني — يزداد باستمرار بلا انقطاع
    final seconds = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (int i = 0; i < _defs.length; i++) {
      final d = _defs[i];
      final x = d[0];
      final heartSize = d[1] / 2;
      final speed = d[2];
      final phase = d[3];

      // speed / 12.0 يحافظ على نفس السرعة الأصلية (12 ث = دورة كاملة بسرعة 1.0)
      final y = 1.0 - ((seconds * speed / 12.0 + phase) % 1.0);

      double opacity = maxOpacity;
      if (y > 0.85) opacity *= (1.0 - y) / 0.15;
      else if (y < 0.10) opacity *= y / 0.10;

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      _drawHeart(
        canvas,
        Offset(x * size.width, y * size.height),
        heartSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter old) => true;
}
