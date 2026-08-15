import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/order_model.dart';
import '../../core/providers/auth_provider.dart';
import '../customer/providers/orders_provider.dart';

/// لعبة بسيطة لا نهائية: احمِ القلب من الاصطدام بالعقبات القادمة، تسرّع
/// اللعبة كلما تقدمت نقاطك. تظهر حالة الطلب بشكل حي أعلى الشاشة، وأعلى
/// نتيجة محفوظة محلياً بشكل دائم لكل مستخدم.
class HeartDodgeGameScreen extends ConsumerStatefulWidget {
  final String orderId;
  const HeartDodgeGameScreen({super.key, required this.orderId});

  @override
  ConsumerState<HeartDodgeGameScreen> createState() =>
      _HeartDodgeGameScreenState();
}

class _Obstacle {
  double x; // 0..1 fraction of field width — starts just off-screen right
  final double y; // 0..1 fraction of field height — fixed per obstacle
  bool passed = false;
  _Obstacle({required this.x, required this.y});
}

class _HeartDodgeGameScreenState extends ConsumerState<HeartDodgeGameScreen>
    with SingleTickerProviderStateMixin {
  static const double _heartXFrac = 0.16;
  static const double _baseSpeed = 0.16; // fraction of width / second
  static const double _maxSpeed = 0.50;
  static const double _speedGrowth = 0.006; // per point
  static const double _baseSpawnEvery = 1.25; // seconds
  static const double _minSpawnEvery = 0.55;
  static const double _spawnDecay = 0.02; // per point

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  double _heartY = 0.5;
  final List<_Obstacle> _obstacles = [];
  final math.Random _rand = math.Random();
  double _spawnTimer = 0;
  int _score = 0;
  int _bestScore = 0;
  bool _playing = false;
  bool _gameOver = false;
  Size _fieldSize = Size.zero;

  String get _prefsKey =>
      'heart_game_best_${ref.read(authProvider)?.id ?? 'guest'}';

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _ticker = createTicker(_onTick)..start();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _bestScore = prefs.getInt(_prefsKey) ?? 0);
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, _bestScore);
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (!_playing || _gameOver) return;
    if (dt <= 0 || dt > 0.25 || _fieldSize.isEmpty) return;
    _update(dt);
  }

  void _update(double dt) {
    final speed =
        (_baseSpeed + _score * _speedGrowth).clamp(_baseSpeed, _maxSpeed);
    final spawnEvery = (_baseSpawnEvery - _score * _spawnDecay)
        .clamp(_minSpawnEvery, _baseSpawnEvery);

    _spawnTimer += dt;
    if (_spawnTimer >= spawnEvery) {
      _spawnTimer = 0;
      _obstacles.add(_Obstacle(x: 1.05, y: 0.12 + _rand.nextDouble() * 0.76));
    }

    for (final o in _obstacles) {
      o.x -= speed * dt;
    }

    for (final o in _obstacles) {
      if (!o.passed && o.x < _heartXFrac) {
        o.passed = true;
        _score++;
      }
    }

    _obstacles.removeWhere((o) => o.x < -0.08);

    final w = _fieldSize.width;
    final h = _fieldSize.height;
    final heartRadius = math.min(w, h) * 0.075;
    final obstacleRadius = math.min(w, h) * 0.055;
    for (final o in _obstacles) {
      final dx = (o.x - _heartXFrac) * w;
      final dy = (o.y - _heartY) * h;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < (heartRadius + obstacleRadius) * 0.8) {
        _gameOver = true;
        _playing = false;
        if (_score > _bestScore) {
          _bestScore = _score;
          _saveBestScore();
        }
        break;
      }
    }

    if (mounted) setState(() {});
  }

  void _handleDrag(DragUpdateDetails details) {
    if (!_playing || _fieldSize.height == 0) return;
    setState(() {
      _heartY =
          (_heartY + details.delta.dy / _fieldSize.height).clamp(0.05, 0.95);
    });
  }

  void _startGame() {
    setState(() {
      _obstacles.clear();
      _score = 0;
      _spawnTimer = 0;
      _heartY = 0.5;
      _gameOver = false;
      _playing = true;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(trackOrderProvider(widget.orderId));

    ref.listen<AsyncValue<OrderModel?>>(trackOrderProvider(widget.orderId),
        (prev, next) {
      final prevStatus = prev?.valueOrNull?.status;
      final nextStatus = next.valueOrNull?.status;
      if (nextStatus == OrderStatus.ready && prevStatus != OrderStatus.ready) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('طلبك جاهز للاستلام!'),
          backgroundColor: AppColors.success,
        ));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.purpleDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.favorite, size: 20),
            SizedBox(width: 8),
            Text('احمِ القلب'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _OrderStatusStrip(order: orderAsync.valueOrNull),
            const SizedBox(height: 10),
            _ScoreRow(score: _score, best: _bestScore),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: LayoutBuilder(builder: (context, constraints) {
                    _fieldSize =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: _handleDrag,
                      onTap: () {
                        if (!_playing) _startGame();
                      },
                      child: Container(
                        decoration:
                            BoxDecoration(gradient: AppColors.heroGradient),
                        child: Stack(
                          children: [
                            ..._obstacles.map((o) => _ObstacleWidget(
                                obstacle: o, fieldSize: _fieldSize)),
                            _HeartWidget(
                              yFrac: _heartY,
                              xFrac: _heartXFrac,
                              fieldSize: _fieldSize,
                            ),
                            if (!_playing)
                              _StartOverlay(
                                gameOver: _gameOver,
                                score: _score,
                                best: _bestScore,
                                onStart: _startGame,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── القلب (اللاعب) ─────────────────────────────────────────────────────────

class _HeartWidget extends StatelessWidget {
  final double yFrac;
  final double xFrac;
  final Size fieldSize;
  const _HeartWidget(
      {required this.yFrac, required this.xFrac, required this.fieldSize});

  @override
  Widget build(BuildContext context) {
    if (fieldSize.isEmpty) return const SizedBox.shrink();
    final radius = math.min(fieldSize.width, fieldSize.height) * 0.075;
    final size = radius * 2;
    return Positioned(
      left: xFrac * fieldSize.width - radius,
      top: yFrac * fieldSize.height - radius,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
              colors: [Color(0xFFFF6B9D), Color(0xFFCC1155)]),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4488).withOpacity(0.6),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(Icons.favorite, color: Colors.white, size: size * 0.6),
      ),
    );
  }
}

// ── العقبات ────────────────────────────────────────────────────────────────

class _ObstacleWidget extends StatelessWidget {
  final _Obstacle obstacle;
  final Size fieldSize;
  const _ObstacleWidget({required this.obstacle, required this.fieldSize});

  @override
  Widget build(BuildContext context) {
    if (fieldSize.isEmpty) return const SizedBox.shrink();
    final radius = math.min(fieldSize.width, fieldSize.height) * 0.055;
    final size = radius * 2;
    return Positioned(
      left: obstacle.x * fieldSize.width - radius,
      top: obstacle.y * fieldSize.height - radius,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A0030),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
          ],
        ),
        child: Icon(Icons.close_rounded,
            color: Colors.white.withOpacity(0.85), size: size * 0.55),
      ),
    );
  }
}

// ── شريط حالة الطلب — أنيق ومصغّر أعلى اللعبة ─────────────────────────────

class _OrderStatusStrip extends StatelessWidget {
  final OrderModel? order;
  const _OrderStatusStrip({required this.order});

  List<({OrderStatus status, IconData icon, String label})> get _steps => [
    (status: OrderStatus.pending, icon: Icons.hourglass_empty, label: 'انتظار'),
    (status: OrderStatus.confirmed, icon: Icons.thumb_up, label: 'تأكيد'),
    (status: OrderStatus.preparing, icon: Icons.restaurant, label: 'تحضير'),
    (status: OrderStatus.ready, icon: Icons.delivery_dining, label: 'جاهز'),
    if (order!.orderType == OrderType.delivery)
      (status: OrderStatus.outForDelivery, icon: Icons.two_wheeler, label: 'توصيل'),
    (status: OrderStatus.delivered, icon: Icons.check_circle, label: 'تسليم'),
  ];

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return const SizedBox(height: 64);
    }

    if (order!.status == OrderStatus.cancelled) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('تم إلغاء هذا الطلب',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      );
    }

    final currentStep = order!.status.step;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _steps.asMap().entries.map((e) {
          final i = e.key;
          final step = e.value;
          final isDone = currentStep > i;
          final isCurrent = currentStep == i;
          final color = isDone
              ? AppColors.success
              : isCurrent
                  ? Colors.white
                  : Colors.white.withOpacity(0.3);
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isCurrent ? Colors.white.withOpacity(0.15) : Colors.transparent,
                    border: Border.all(color: color, width: isCurrent ? 2 : 1),
                  ),
                  child: Icon(isDone ? Icons.check : step.icon,
                      color: color, size: 14),
                ),
                const SizedBox(height: 3),
                Text(step.label,
                    style: TextStyle(color: color, fontSize: 9),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── صف النقاط ──────────────────────────────────────────────────────────────

class _ScoreRow extends StatelessWidget {
  final int score;
  final int best;
  const _ScoreRow({required this.score, required this.best});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _ScoreChip(
              label: 'النقاط',
              value: score,
              icon: Icons.favorite,
              color: const Color(0xFFFF6B9D),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ScoreChip(
              label: 'أفضل نتيجة',
              value: best,
              icon: Icons.emoji_events,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _ScoreChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text('$value',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── شاشة البداية / نهاية اللعبة ────────────────────────────────────────────

class _StartOverlay extends StatelessWidget {
  final bool gameOver;
  final int score;
  final int best;
  final VoidCallback onStart;
  const _StartOverlay({
    required this.gameOver,
    required this.score,
    required this.best,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (gameOver) ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.red.withOpacity(0.2),
                    border: Border.all(color: AppColors.red, width: 2),
                  ),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 14),
                const Text('انتهت اللعبة!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('نقاطك: $score',
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
                if (score > 0 && score >= best) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                      SizedBox(width: 6),
                      Text('رقم قياسي جديد!',
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ] else ...[
                Icon(Icons.favorite, color: Color(0xFFFF6B9D), size: 56),
                const SizedBox(height: 14),
                const Text('احمِ القلب من الاصطدام',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('اسحب لأعلى وأسفل لتفادي العقبات',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onStart,
                icon: Icon(gameOver ? Icons.replay : Icons.play_arrow),
                label: Text(gameOver ? 'العب مرة أخرى' : 'ابدأ اللعب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.purpleDark,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
