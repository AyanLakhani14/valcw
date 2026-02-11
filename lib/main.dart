import 'package:flutter/material.dart';

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
  double pulseIntensity = 0.08; // scale delta: 0.00 - 0.20
  double pulseSpeed = 1.0; // 0.5x - 2.5x

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
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

    // Base 900ms scaled by speed.
    // Higher speed = shorter duration = faster pulsing.
    final ms = (900 / pulseSpeed).clamp(250, 2000).round();

    _controller.duration = Duration(milliseconds: ms);

    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // keep controller behavior in sync with UI settings
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

              // Controls card (Feature 1 + Feature 2)
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
                        // Feature 1: dropdown
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

                        // Feature 2: pulse enable switch
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
                              onChanged: (v) {
                                setState(() => pulseEnabled = v);
                              },
                            ),
                          ],
                        ),

                        // Pulse intensity slider
                        Opacity(
                          opacity: pulseEnabled ? 1.0 : 0.45,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text('Intensity'),
                                  ),
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

                              // Pulse speed slider
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

              const SizedBox(height: 14),

              Text(
                selectedEmoji == 'Party Heart'
                    ? 'Party mode selected'
                    : 'Sweet mode selected',
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

                      // Pulse effect wraps the CustomPaint
                      child: AnimatedBuilder(
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
                          painter: HeartEmojiPainter(type: selectedEmoji),
                        ),
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
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    _drawGlow(canvas, center);

    if (type == 'Sweet Heart') {
      _drawSweetHeart(canvas, center);
    } else {
      _drawPartyHeart(canvas, center);
    }
  }

  void _drawGlow(Canvas canvas, Offset center) {
    final glowPaint = Paint()
      ..color = const Color(0xFFE91E63).withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    canvas.drawCircle(center, 110, glowPaint);
  }

  void _drawSweetHeart(Canvas canvas, Offset center) {
    final heartPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE91E63);

    final heartPath = _buildHeart(center);
    canvas.drawPath(heartPath, heartPaint);

    // Shine highlight
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 28, center.dy - 35),
        width: 80,
        height: 50,
      ),
      shinePaint,
    );

    _drawFace(canvas, center, cheeks: true);
  }

  void _drawPartyHeart(Canvas canvas, Offset center) {
    final heartPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF48FB1);

    final heartPath = _buildHeart(center);
    canvas.drawPath(heartPath, heartPaint);

    _drawFace(canvas, center, cheeks: false);
    _drawPartyHat(canvas, center);
    _drawConfetti(canvas, center);
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
    // Eyes
    final eyeWhite = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyeWhite);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyeWhite);

    // Pupils
    final pupil = Paint()..color = Colors.black.withOpacity(0.7);
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 4.5, pupil);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 4.5, pupil);

    // Smile
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

    // Cheeks
    if (cheeks) {
      final cheekPaint = Paint()..color = Colors.pinkAccent.withOpacity(0.35);
      canvas.drawCircle(Offset(center.dx - 55, center.dy + 10), 10, cheekPaint);
      canvas.drawCircle(Offset(center.dx + 55, center.dy + 10), 10, cheekPaint);
    }
  }

  void _drawPartyHat(Canvas canvas, Offset center) {
    // Hat
    final hatPaint = Paint()..color = const Color(0xFFFFD54F);
    final hatPath = Path()
      ..moveTo(center.dx, center.dy - 128)
      ..lineTo(center.dx - 55, center.dy - 48)
      ..lineTo(center.dx + 55, center.dy - 48)
      ..close();
    canvas.drawPath(hatPath, hatPaint);

    // Stripe
    final stripePaint = Paint()..color = const Color(0xFF7E57C2);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 60),
        width: 90,
        height: 10,
      ),
      stripePaint,
    );

    // Pom-pom
    final pomPaint = Paint()..color = const Color(0xFF26C6DA);
    canvas.drawCircle(Offset(center.dx, center.dy - 132), 10, pomPaint);
  }

  void _drawConfetti(Canvas canvas, Offset center) {
    final colors = [
      const Color(0xFF26C6DA),
      const Color(0xFFFF7043),
      const Color(0xFF7E57C2),
      const Color(0xFF66BB6A),
      const Color(0xFFFFD54F),
    ];

    for (int i = 0; i < 22; i++) {
      final dx = (i * 13) % 180 - 90;
      final dy = -120 + ((i * 17) % 70);
      final p = Offset(center.dx + dx.toDouble(), center.dy + dy.toDouble());

      final paint = Paint()..color = colors[i % colors.length].withOpacity(0.95);

      if (i % 2 == 0) {
        canvas.drawCircle(p, 4.5, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: p, width: 9, height: 6),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
