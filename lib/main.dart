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
      home: const ValentineHome(),
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
  // Feature 1: emoji selection
  final List<String> emojiOptions = const ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  // Feature 2: pulse control
  bool pulseEnabled = true;
  double pulseIntensity = 0.08; // 0.00 - 0.20
  double pulseSpeed = 1.0; // 0.5x - 2.5x
  late final AnimationController _pulseController;

  // Feature 3: dynamic drawing (assets inside CustomPainter)
  ui.Image? confettiImg;
  ui.Image? arrowImg;
  ui.Image? heartIconImg;

  // Feature 4: balloon celebration
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

    _balloonsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => balloonsActive = false);
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
        // ✅ Gradients requirement: soft pink-to-red RADIAL background
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [
              Color(0xFFFFF1F6), // very light pink
              Color(0xFFFFC1D6), // light pink
              Color(0xFFFF8FB1), // deeper pink
              Color(0xFFF06292), // pink-red
            ],
            stops: [0.0, 0.45, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Controls card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0,
                  color: Colors.white.withOpacity(0.72),
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
                                    ? (v) =>
                                        setState(() => pulseIntensity = v)
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
                    ? 'Gradients: radial background + heart fill gradient'
                    : 'Gradients: radial background + heart fill gradient',
                style: TextStyle(color: Colors.black.withOpacity(0.70)),
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
                                  // Heart canvas (pulsing)
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      final t = _pulseController.value;
                                      final base = 1.0;
                                      final amp =
                                          pulseEnabled ? pulseIntensity : 0.0;
                                      final scale =
                                          base - amp + (2 * amp * t);

                                      return Center(
                                        child: Transform.scale(
                                          scale: scale,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: CustomPaint(
                                      size: const Size(320, 320),
                                      painter: HeartEmojiPainter(
                                        type: selectedEmoji,
                                        confetti: confettiImg!,
                                        arrow: arrowImg!,
                                        heartIcon: heartIconImg!,
                                      ),
                                    ),
                                  ),

                                  // Balloons overlay
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
  });

  final String type;
  final ui.Image confetti;
  final ui.Image arrow;
  final ui.Image heartIcon;

  @override
  void paint(Canvas canvas, Size size) {
    // Smaller emoji overall
    const scaleFactor = 0.88;
    canvas.save();
    canvas.scale(scaleFactor, scaleFactor);

    final center = Offset(
      (size.width / 2) / scaleFactor,
      (size.height / 2) / scaleFactor,
    );

    // Party heart moved down
    final Offset adjustedCenter =
        type == 'Party Heart' ? Offset(center.dx, center.dy + 30) : center;

    _drawGlow(canvas, adjustedCenter);

    if (type == 'Sweet Heart') {
      _drawSweet(canvas, adjustedCenter);
    } else {
      _drawParty(canvas, adjustedCenter);
    }

    canvas.restore();
  }

  void _drawGlow(Canvas canvas, Offset center) {
    final glowPaint = Paint()
      ..color = const Color(0xFFE91E63).withOpacity(0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(center, 112, glowPaint);
  }

  // ✅ Heart fill gradient (linear)
  Paint _heartGradientPaint(Rect bounds, {required bool party}) {
    final colors = party
        ? const [Color(0xFFFFB3C7), Color(0xFFF06292), Color(0xFFD81B60)]
        : const [Color(0xFFFF5A8A), Color(0xFFE91E63), Color(0xFFC2185B)];

    return Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(bounds.left, bounds.top),
        Offset(bounds.right, bounds.bottom),
        colors,
      );
  }

  void _drawSweet(Canvas canvas, Offset center) {
    final heartPath = _buildHeart(center);
    final bounds = heartPath.getBounds();

    // ✅ Gradient fill instead of solid color
    final heartPaint = _heartGradientPaint(bounds, party: false);
    canvas.drawPath(heartPath, heartPaint);

    // Shine
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

    // Heart icon stamp
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

  void _drawParty(Canvas canvas, Offset center) {
    final heartPath = _buildHeart(center);
    final bounds = heartPath.getBounds();

    // ✅ Gradient fill for party heart too
    final heartPaint = _heartGradientPaint(bounds, party: true);
    canvas.drawPath(heartPath, heartPaint);

    _drawFace(canvas, center, cheeks: false);
    _drawPartyHat(canvas, center);

    // Cupid arrow
    _drawImageContained(
      canvas,
      arrow,
      Rect.fromCenter(
        center: Offset(center.dx + 10, center.dy + 6),
        width: 230,
        height: 86,
      ),
      opacity: 0.95,
    );

    // Festive details shapes
    _drawFestiveConfetti(canvas, center);

    // optional accent: a few confetti PNGs
    for (int i = 0; i < 4; i++) {
      final dx = (i * 60) - 90;
      final dy = -195 + (i % 2) * 18;
      final p = Offset(center.dx + dx.toDouble(), center.dy + dy.toDouble());

      _drawImageContained(
        canvas,
        confetti,
        Rect.fromCenter(center: p, width: 34, height: 34),
        opacity: 0.82,
      );
    }
  }

  void _drawFestiveConfetti(Canvas canvas, Offset center) {
    final colors = <Color>[
      const Color(0xFFFF5252),
      const Color(0xFFFFC107),
      const Color(0xFF4CAF50),
      const Color(0xFF03A9F4),
      const Color(0xFF7E57C2),
      const Color(0xFFFF80AB),
    ];

    final points = <Offset>[
      Offset(center.dx - 95, center.dy - 175),
      Offset(center.dx - 55, center.dy - 185),
      Offset(center.dx - 15, center.dy - 170),
      Offset(center.dx + 25, center.dy - 190),
      Offset(center.dx + 65, center.dy - 175),
      Offset(center.dx + 95, center.dy - 188),
      Offset(center.dx - 85, center.dy - 145),
      Offset(center.dx - 35, center.dy - 150),
      Offset(center.dx + 10, center.dy - 152),
      Offset(center.dx + 55, center.dy - 145),
      Offset(center.dx + 90, center.dy - 155),
    ];

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final c = colors[i % colors.length];

      if (i % 3 == 0) {
        // Triangle
        final triPaint = Paint()..color = c.withOpacity(0.95);
        final path = Path()
          ..moveTo(p.dx, p.dy)
          ..lineTo(p.dx - 8, p.dy + 14)
          ..lineTo(p.dx + 10, p.dy + 12)
          ..close();
        canvas.drawPath(path, triPaint);
      } else if (i % 3 == 1) {
        // Circle
        final circPaint = Paint()..color = c.withOpacity(0.95);
        canvas.drawCircle(p, 5.5, circPaint);
      } else {
        // Streamer
        final linePaint = Paint()
          ..color = c.withOpacity(0.90)
          ..strokeWidth = 3.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final wave = Path()
          ..moveTo(p.dx - 10, p.dy + 6)
          ..cubicTo(
            p.dx - 2,
            p.dy - 4,
            p.dx + 2,
            p.dy + 18,
            p.dx + 12,
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
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.confetti != confetti ||
        oldDelegate.arrow != arrow ||
        oldDelegate.heartIcon != heartIcon;
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
