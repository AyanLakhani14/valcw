import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asset Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const AssetTestPage(),
    );
  }
}

class AssetTestPage extends StatelessWidget {
  const AssetTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets Loaded ✅'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'If you can see all 3 images, your assets + pubspec.yaml are correct.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              _assetCard(
                label: 'confetti.png',
                path: 'assets/images/confetti.png',
                size: 220,
              ),
              const SizedBox(height: 18),

              _assetCard(
                label: 'cupidsarrow.png',
                path: 'assets/images/cupidsarrow.png',
                size: 220,
              ),
              const SizedBox(height: 18),

              _assetCard(
                label: 'hearticon.png',
                path: 'assets/images/hearticon.png',
                size: 220,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _assetCard({
    required String label,
    required String path,
    double size = 200,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Image.asset(
            path,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: Text(
                    'FAILED:\n$path',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
