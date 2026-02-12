import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ValentinesApp());

class ValentinesApp extends StatelessWidget {
  const ValentinesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cupid's Canvas",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E63)),
      ),
      home: const IntroPage(),
    );
  }
}

/// ✅ Intro page that fades in, then cleanly transitions (no mid-transition errors)
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _navTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _navTimer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted || _navigated) return;
      _navigated = true;
      _controller.stop();
      Navigator.of(context).pushReplacement(_fadeRoute(const ValentineHome()));
    });
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 650),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.65),
            radius: 1.15,
            colors: [
              Color(0xFFFFE1EA),
              Color(0xFFFFB3C5),
              Color(0xFFFF7A98),
              Color(0xFFF24B6A),
            ],
            stops: [0.0, 0.45, 0.75, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;

              final fadeIn =
                  Curves.easeOut.transform((t * 1.2).clamp(0.0, 1.0));
              final fadeOut = 1.0 -
                  Curves.easeIn
                      .transform(((t - 0.7) / 0.3).clamp(0.0, 1.0));
              final opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);

              final scale = 0.96 + 0.06 * Curves.easeOut.transform(t);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Card(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.78),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(color: Colors.black.withOpacity(0.08)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite,
                                size: 44, color: Color(0xFFE91E63)),
                            const SizedBox(height: 10),
                            const Text(
                              "Who will you show your love to?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Pick a heart. Add sparkle. Celebrate.",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black.withOpacity(0.65)),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: 180,
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: t.clamp(0.0, 1.0),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with TickerProviderStateMixin {
  final List<String> emojiOptions = const ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  bool pulseEnabled = true;
  double pulseIntensity = 0.08;
  double pulseSpeed = 1.0;
  late final AnimationController _pulseController;

  late final AnimationController _sparkleController;

  ui.Image? confettiImg;
  ui.Image? arrowImg;
  ui.Image? heartIconImg;

  bool balloonsActive = false;
  late final AnimationController _balloonsController;
  late final List<_Balloon> _balloons;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _balloonsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) setState(() => balloonsActive = false);
        }
      });

    _balloons = _makeBalloons(18);
    _loadAssets();
  }

  List<_Balloon> _makeBalloons(int count) {
    final r = Random(42);
    final colors = <Color>[
      const Color(0xFFFF5252),
      const Color(0xFFFFC107),
      const Color(0xFF4CAF50),
      const Color(0xFF03A9F4),
      const Color(0xFF7E57C2),
      const Color(0xFFFF80AB),
    ];

    return List.generate(count, (i) {
      return _Balloon(
        x: r.nextDouble(),
        size: 34 + r.nextInt(28).toDouble(),
        drift: (r.nextDouble() * 2 - 1) * 18,
        wobble: 0.8 + r.nextDouble() * 1.6,
        phase: r.nextDouble() * pi * 2,
        color: colors[i % colors.length],
      );
    });
  }

  Future<void> _loadAssets() async {
    final c = await _loadUiImage('assets/images/confetti.png');
    final a = await _loadUiImage('assets/images/cupidsarrow.png');
    final h = await _loadUiImage('assets/images/hearticon.png');

    if (!mounted) return;
    setState(() {
      confettiImg = c;
      arrowImg = a;
      heartIconImg = h;
    });
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    _balloonsController.dispose();
    super.dispose();
  }

  void _applyPulsePlayback() {
    if (!pulseEnabled) {
      _pulseController.stop();
      return;
    }

    final ms = (900 / pulseSpeed).clamp(250, 2000).round();
    _pulseController.duration = Duration(milliseconds: ms);

    if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  bool get _assetsReady =>
      confettiImg != null && arrowImg != null && heartIconImg != null;

  void _startBalloons() {
    setState(() => balloonsActive = true);
    _balloonsController.reset();
    _balloonsController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    _applyPulsePlayback();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cupid's Canvas"),
        centerTitle: true,
        backgroundColor: scheme.primaryContainer,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.75),
            radius: 1.2,
            colors: [
              Color(0xFFFFE1EA),
              Color(0xFFFFB3C5),
              Color(0xFFFF7A98),
              Color(0xFFF24B6A),
            ],
            stops: [0.0, 0.45, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0,
                  color: Colors.white.withOpacity(0.78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.black.withOpacity(0.08)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              selectedEmoji == 'Party Heart'
                                  ? Icons.celebration
                                  : Icons.favorite,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Emoji style',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedEmoji,
                                items: emojiOptions
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => selectedEmoji = value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(color: Colors.black.withOpacity(0.08)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.favorite_border, color: scheme.primary),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Pulse',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Switch(
                              value: pulseEnabled,
                              onChanged: (v) => setState(() => pulseEnabled = v),
                            ),
                          ],
                        ),
                        Opacity(
                          opacity: pulseEnabled ? 1.0 : 0.45,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(child: Text('Intensity')),
                                  Text(
                                    '${(pulseIntensity * 100).round()}%',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.65),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: pulseIntensity,
                                min: 0.0,
                                max: 0.20,
                                divisions: 20,
                                onChanged: pulseEnabled
                                    ? (v) => setState(() => pulseIntensity = v)
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Expanded(child: Text('Speed')),
                                  Text(
                                    '${pulseSpeed.toStringAsFixed(1)}x',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.65),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: pulseSpeed,
                                min: 0.5,
                                max: 2.5,
                                divisions: 20,
                                onChanged: pulseEnabled
                                    ? (v) => setState(() => pulseSpeed = v)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(color: Colors.black.withOpacity(0.08)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: balloonsActive ? null : _startBalloons,
                            icon: const Icon(Icons.air),
                            label: Text(
                              balloonsActive
                                  ? 'Celebration running...'
                                  : 'Balloon Celebration 🎈',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedEmoji == 'Party Heart'
                    ? 'Gradients + sparkles + love trail + festive confetti'
                    : 'Gradients + sparkles + love trail + heart stamp',
                style: TextStyle(color: Colors.black.withOpacity(0.75)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 0,
                    color: Colors.white.withOpacity(0.72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: Colors.black.withOpacity(0.08)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: SizedBox(
                        width: 320,
                        height: 320,
                        child: _assetsReady
                            ? Stack(
                                children: [
                                  AnimatedBuilder(
                                    animation: Listenable.merge(
                                        [_pulseController, _sparkleController]),
                                    builder: (context, child) {
                                      final pulseT = _pulseController.value;
                                      final sparkleT = _sparkleController.value;

                                      final amp =
                                          pulseEnabled ? pulseIntensity : 0.0;
                                      final scale =
                                          (1.0 - amp) + (2 * amp * pulseT);

                                      return Center(
                                        child: Transform.scale(
                                          scale: scale,
                                          child: CustomPaint(
                                            size: const Size(320, 320),
                                            painter: HeartEmojiPainter(
                                              type: selectedEmoji,
                                              confetti: confettiImg!,
                                              arrow: arrowImg!,
                                              heartIcon: heartIconImg!,
                                              sparkleT: sparkleT,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (balloonsActive)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: AnimatedBuilder(
                                          animation: _balloonsController,
                                          builder: (context, _) {
                                            return CustomPaint(
                                              painter: BalloonPainter(
                                                t: _balloonsController.value,
                                                balloons: _balloons,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({
    required this.type,
    required this.confetti,
    required this.arrow,
    required this.heartIcon,
    required this.sparkleT,
  });

  final String type;
  final ui.Image confetti;
  final ui.Image arrow;
  final ui.Image heartIcon;
  final double sparkleT;

  @override
  void paint(Canvas canvas, Size size) {
    const scaleFactor = 0.88;
    canvas.save();
    canvas.scale(scaleFactor, scaleFactor);

    final canvasW = size.width / scaleFactor;
    final canvasH = size.height / scaleFactor;
    final baseCenter = Offset(canvasW / 2, canvasH / 2);

    final heartCenter =
        type == 'Party Heart' ? Offset(baseCenter.dx, baseCenter.dy + 52) : baseCenter;

    final decoTopCenter =
        type == 'Party Heart' ? Offset(baseCenter.dx, 62) : Offset(baseCenter.dx, 72);

    _drawLoveTrail(canvas, heartCenter);

    _drawSparkles(
      canvas,
      type == 'Party Heart' ? Offset(heartCenter.dx, heartCenter.dy - 60) : heartCenter,
      sparkleT,
    );

    if (type == 'Sweet Heart') {
      _drawSweet(canvas, heartCenter);
    } else {
      _drawParty(canvas, heartCenter, decoTopCenter, canvasW);
    }

    canvas.restore();
  }

  void _drawLoveTrail(Canvas canvas, Offset center) {
    final baseHeart = _buildHeart(center);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.06, 1.06);
    canvas.translate(-center.dx, -center.dy);

    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = const Color(0xFFFF5C8A).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawPath(baseHeart, trailPaint);

    final trailPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFFFF8FB1).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(baseHeart, trailPaint2);

    canvas.restore();
  }

  void _drawSparkles(Canvas canvas, Offset center, double t) {
    final sparklePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..style = PaintingStyle.fill;

    final spots = <Offset>[
      Offset(center.dx - 115, center.dy - 95),
      Offset(center.dx - 90, center.dy - 145),
      Offset(center.dx - 25, center.dy - 165),
      Offset(center.dx + 55, center.dy - 155),
      Offset(center.dx + 110, center.dy - 105),
      Offset(center.dx + 90, center.dy - 45),
      Offset(center.dx - 95, center.dy - 35),
    ];

    for (int i = 0; i < spots.length; i++) {
      final p = spots[i];
      final phase = i * 0.9;

      final flicker =
          (sin((t * 2 * pi) + phase) * 0.5 + 0.5).clamp(0.0, 1.0);

      final opacity = 0.15 + 0.55 * flicker;
      final len = 5 + 5 * flicker;

      sparklePaint
        ..color = Colors.white.withOpacity(opacity)
        ..strokeWidth = 2.0;

      canvas.drawLine(Offset(p.dx - len, p.dy), Offset(p.dx + len, p.dy),
          sparklePaint);
      canvas.drawLine(Offset(p.dx, p.dy - len), Offset(p.dx, p.dy + len),
          sparklePaint);

      final d = len * 0.7;
      canvas.drawLine(Offset(p.dx - d, p.dy - d), Offset(p.dx + d, p.dy + d),
          sparklePaint);
      canvas.drawLine(Offset(p.dx - d, p.dy + d), Offset(p.dx + d, p.dy - d),
          sparklePaint);

      dotPaint.color = const Color(0xFFFFF4F8).withOpacity(0.12 + 0.45 * flicker);
      canvas.drawCircle(Offset(p.dx + 16, p.dy - 8), 2.0 + 0.8 * flicker, dotPaint);
      canvas.drawCircle(Offset(p.dx - 14, p.dy + 10), 1.4 + 0.7 * flicker, dotPaint);
    }
  }

  void _drawSweet(Canvas canvas, Offset center) {
    final heartPath = _buildHeart(center);
    final bounds = heartPath.getBounds();

    final heartPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF6B8F),
          Color(0xFFE91E63),
          Color(0xFFB3124B),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(bounds);

    canvas.drawPath(heartPath, heartPaint);

    final shinePaint = Paint()..color = Colors.white.withOpacity(0.18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 26, center.dy - 36),
        width: 92,
        height: 56,
      ),
      shinePaint,
    );

    _drawFace(canvas, center, cheeks: true);

    _drawImageContained(
      canvas,
      heartIcon,
      Rect.fromCenter(
        center: Offset(center.dx + 70, center.dy + 62),
        width: 66,
        height: 66,
      ),
      opacity: 0.95,
    );
  }

  void _drawParty(Canvas canvas, Offset heartCenter, Offset decoTopCenter, double canvasW) {
    final heartPath = _buildHeart(heartCenter);
    final bounds = heartPath.getBounds();

    final heartPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFC1D8),
          Color(0xFFFF6FA8),
          Color(0xFFE91E63),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(bounds);

    canvas.drawPath(heartPath, heartPaint);

    _drawFace(canvas, heartCenter, cheeks: false);
    _drawPartyHat(canvas, Offset(heartCenter.dx, heartCenter.dy - 10));

    _drawImageContained(
      canvas,
      arrow,
      Rect.fromCenter(
        center: Offset(heartCenter.dx + 8, heartCenter.dy + 16),
        width: 210,
        height: 78,
      ),
      opacity: 0.95,
    );

    _drawFestiveConfetti(canvas, decoTopCenter);

    _drawImageContained(
      canvas,
      confetti,
      Rect.fromCenter(center: const Offset(36, 52), width: 26, height: 26),
      opacity: 0.80,
    );
    _drawImageContained(
      canvas,
      confetti,
      Rect.fromCenter(center: Offset(canvasW - 36, 58), width: 26, height: 26),
      opacity: 0.80,
    );
    _drawImageContained(
      canvas,
      confetti,
      Rect.fromCenter(center: Offset(canvasW * 0.80, 90), width: 22, height: 22),
      opacity: 0.70,
    );
  }

  void _drawFestiveConfetti(Canvas canvas, Offset topCenter) {
    final colors = <Color>[
      const Color(0xFFFF5252),
      const Color(0xFFFFC107),
      const Color(0xFF4CAF50),
      const Color(0xFF03A9F4),
      const Color(0xFF7E57C2),
      const Color(0xFFFF80AB),
    ];

    final points = <Offset>[
      Offset(topCenter.dx - 120, topCenter.dy + 20),
      Offset(topCenter.dx - 85, topCenter.dy + 5),
      Offset(topCenter.dx - 45, topCenter.dy + 18),
      Offset(topCenter.dx - 5, topCenter.dy + 0),
      Offset(topCenter.dx + 35, topCenter.dy + 16),
      Offset(topCenter.dx + 75, topCenter.dy + 4),
      Offset(topCenter.dx + 115, topCenter.dy + 18),
      Offset(topCenter.dx - 95, topCenter.dy + 50),
      Offset(topCenter.dx - 40, topCenter.dy + 58),
      Offset(topCenter.dx + 10, topCenter.dy + 48),
      Offset(topCenter.dx + 70, topCenter.dy + 56),
      Offset(topCenter.dx + 110, topCenter.dy + 46),
    ];

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final c = colors[i % colors.length];

      if (i % 3 == 0) {
        final triPaint = Paint()..color = c.withOpacity(0.95);
        final path = Path()
          ..moveTo(p.dx, p.dy)
          ..lineTo(p.dx - 7, p.dy + 12)
          ..lineTo(p.dx + 9, p.dy + 10)
          ..close();
        canvas.drawPath(path, triPaint);
      } else if (i % 3 == 1) {
        final circPaint = Paint()..color = c.withOpacity(0.95);
        canvas.drawCircle(p, 5.0, circPaint);
      } else {
        final linePaint = Paint()
          ..color = c.withOpacity(0.90)
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final wave = Path()
          ..moveTo(p.dx - 9, p.dy + 5)
          ..cubicTo(
            p.dx - 2,
            p.dy - 4,
            p.dx + 2,
            p.dy + 16,
            p.dx + 10,
            p.dy + 6,
          );

        canvas.drawPath(wave, linePaint);
      }
    }
  }

  Path _buildHeart(Offset center) {
    return Path()
      ..moveTo(center.dx, center.dy + 70)
      ..cubicTo(
        center.dx + 120,
        center.dy - 10,
        center.dx + 70,
        center.dy - 130,
        center.dx,
        center.dy - 45,
      )
      ..cubicTo(
        center.dx - 70,
        center.dy - 130,
        center.dx - 120,
        center.dy - 10,
        center.dx,
        center.dy + 70,
      )
      ..close();
  }

  void _drawFace(Canvas canvas, Offset center, {required bool cheeks}) {
    final eyeWhite = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyeWhite);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyeWhite);

    final pupil = Paint()..color = Colors.black.withOpacity(0.7);
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 4.5, pupil);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 4.5, pupil);

    final mouthPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 22), radius: 28),
      0,
      3.14,
      false,
      mouthPaint,
    );

    if (cheeks) {
      final cheekPaint = Paint()..color = Colors.pinkAccent.withOpacity(0.35);
      canvas.drawCircle(Offset(center.dx - 55, center.dy + 10), 10, cheekPaint);
      canvas.drawCircle(Offset(center.dx + 55, center.dy + 10), 10, cheekPaint);
    }
  }

  void _drawPartyHat(Canvas canvas, Offset center) {
    final hatPaint = Paint()..color = const Color(0xFFFFD54F);
    final hatPath = Path()
      ..moveTo(center.dx, center.dy - 128)
      ..lineTo(center.dx - 55, center.dy - 48)
      ..lineTo(center.dx + 55, center.dy - 48)
      ..close();
    canvas.drawPath(hatPath, hatPaint);

    final stripePaint = Paint()..color = const Color(0xFF7E57C2);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 60),
        width: 90,
        height: 10,
      ),
      stripePaint,
    );

    final pomPaint = Paint()..color = const Color(0xFF26C6DA);
    canvas.drawCircle(Offset(center.dx, center.dy - 132), 10, pomPaint);
  }

  void _drawImageContained(
    Canvas canvas,
    ui.Image image,
    Rect dst, {
    double opacity = 1.0,
  }) {
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.confetti != confetti ||
        oldDelegate.arrow != arrow ||
        oldDelegate.heartIcon != heartIcon ||
        oldDelegate.sparkleT != sparkleT;
  }
}

class BalloonPainter extends CustomPainter {
  BalloonPainter({required this.t, required this.balloons});

  final double t;
  final List<_Balloon> balloons;

  @override
  void paint(Canvas canvas, Size size) {
    final travel = size.height + 140;

    for (final b in balloons) {
      final x = b.x * size.width;
      final y = size.height + 60 - (t * travel);

      final wobbleX = sin(t * 2 * pi * b.wobble + b.phase) * 10;
      final driftX = b.drift * t;

      final center = Offset(x + wobbleX + driftX, y + sin(b.phase) * 10);
      _drawBalloon(canvas, center, b.size, b.color);
    }
  }

  void _drawBalloon(Canvas canvas, Offset c, double r, Color color) {
    final balloonPaint = Paint()..color = color.withOpacity(0.95);

    final rect = Rect.fromCenter(
      center: Offset(c.dx, c.dy),
      width: r * 1.25,
      height: r * 1.55,
    );
    canvas.drawOval(rect, balloonPaint);

    final shine = Paint()..color = Colors.white.withOpacity(0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - r * 0.18, c.dy - r * 0.25),
        width: r * 0.30,
        height: r * 0.55,
      ),
      shine,
    );

    final knot = Path()
      ..moveTo(c.dx, c.dy + r * 0.78)
      ..lineTo(c.dx - r * 0.10, c.dy + r * 0.95)
      ..lineTo(c.dx + r * 0.10, c.dy + r * 0.95)
      ..close();
    canvas.drawPath(knot, balloonPaint);

    final stringPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stringPath = Path()
      ..moveTo(c.dx, c.dy + r * 0.95)
      ..cubicTo(
        c.dx + r * 0.10,
        c.dy + r * 1.35,
        c.dx - r * 0.10,
        c.dy + r * 1.85,
        c.dx,
        c.dy + r * 2.25,
      );

    canvas.drawPath(stringPath, stringPaint);
  }

  @override
  bool shouldRepaint(covariant BalloonPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.balloons != balloons;
  }
}

class _Balloon {
  _Balloon({
    required this.x,
    required this.size,
    required this.drift,
    required this.wobble,
    required this.phase,
    required this.color,
  });

  final double x;
  final double size;
  final double drift;
  final double wobble;
  final double phase;
  final Color color;
}
