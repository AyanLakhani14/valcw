import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ValentineHome(),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome> {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cupid's Canvas")),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ✅ Core Feature 1: Emoji selection dropdown
          DropdownButton<String>(
            value: selectedEmoji,
            items: emojiOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => selectedEmoji = value);
            },
          ),

          const SizedBox(height: 16),

          // (Optional) shows what’s selected for clarity
          Text('Selected: $selectedEmoji'),

          const SizedBox(height: 16),

          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: HeartEmojiPainter(type: selectedEmoji),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal painter just to prove selection is wired correctly.
// (Sweet Heart = solid pink heart, Party Heart = different pink heart + hat)
class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Heart base (same shape, different color to prove selection works)
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60,
          center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110,
          center.dy - 10, center.dx, center.dy + 60)
      ..close();

    paint.color =
        type == 'Party Heart' ? const Color(0xFFF48FB1) : const Color(0xFFE91E63);
    canvas.drawPath(heartPath, paint);

    // Party hat (only for Party Heart)
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type;
}
