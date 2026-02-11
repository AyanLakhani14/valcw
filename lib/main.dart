import 'dart:async';
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
    with SingleTickerProviderStateMixin {
  // Feature 1: emoji selection
  final List<String> emojiOptions = const ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  // Feature 2: pulse control
  bool pulseEnabled = true;
  double pulseIntensity = 0.08; // 0.00 - 0.20
  double pulseSpeed = 1.0; // 0.5x - 2.5x
  late final AnimationController _controller;

  // Feature 3: dynamic drawing (assets inside CustomPainter)
  ui.Image? confettiImg;
  ui.Image? arrowImg;
  ui.Image? heartIconImg;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _loadAssets();
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
    _controller.dispose();
    super.dispose();
  }

  void _applyPulsePlayback() {
    if (!pulseEnabled) {
      _controller.stop();
      return;
    }
    final ms = (900 / pulseSpeed).clamp(250, 2000).round();
    _controller.duration = Duration(milliseconds: ms);

    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  bool get _assetsReady =>
      confettiImg != null && arrowImg != null && heartIconImg != null;

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withOpacity(0.55),
              Colors.white,
            ],
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
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                selectedEmoji == 'Party Heart'
                    ? 'Dynamic: hat + arrow + confetti'
                    : 'Dynamic: shine + heart icon',
                style: TextStyle(color: Colors.black.withOpacity(0.65)),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Center(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: Colors.black.withOpacity(0.08)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: _assetsReady
                          ? AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                final t = _controller.value; // 0..1
                                final base = 1.0;
                                final amp = pulseEnabled ? pulseIntensity : 0.0;
                                final scale = base - amp + (2 * amp * t);

                                return Transform.scale(
                                  scale: scale,
                                  child: child,
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
                            )
                          : const SizedBox(
                              width: 320,
                              height: 320,
                              child: Center(child: CircularProgressIndicator()),
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
    // ✅ Make the entire emoji smaller
    const scaleFactor = 0.88;
    canvas.save();
    canvas.scale(scaleFactor, scaleFactor);

    final center = Offset(
      (size.width / 2) / scaleFactor,
      (size.height / 2) / scaleFactor,
    );

    // ✅ Move Party Heart down to reduce clustering
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
      ..color = const Color(0xFFE91E63).withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    canvas.drawCircle(center, 110, glowPaint);
  }

  void _drawSweet(Canvas canvas, Offset center) {
    final heartPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE91E63);

    canvas.drawPath(_buildHeart(center), heartPaint);

    // Shine highlight
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.20);
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
    final heartPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF48FB1);

    canvas.drawPath(_buildHeart(center), heartPaint);

    _drawFace(canvas, center, cheeks: false);
    _drawPartyHat(canvas, center);

    // Cupid arrow across heart
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

    // ✅ Confetti ABOVE hat (less clustered)
    for (int i = 0; i < 9; i++) {
      final dx = (i * 25) % 210 - 105;
      final dy = -180 + ((i * 19) % 70); // moved higher
      final p = Offset(center.dx + dx.toDouble(), center.dy + dy.toDouble());

      final w = 30 + (i % 3) * 6;
      final h = 30 + ((i + 1) % 3) * 6;

      _drawImageContained(
        canvas,
        confetti,
        Rect.fromCenter(center: p, width: w.toDouble(), height: h.toDouble()),
        opacity: 0.92,
      );
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
