import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:technestx/task_provider.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _nestController;

  @override
  void initState() {
    super.initState();
    _nestController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      await context.read<TaskProvider>().init();
    }
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1A1A2E), Color(0xFF0D0D14)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated nest logo
              AnimatedBuilder(
                animation: _nestController,
                builder: (_, __) => Transform.scale(
                  scale: 1.0 + _nestController.value * 0.08,
                  child: const Text('🪺', style: TextStyle(fontSize: 90)),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .scale(begin: const Offset(0.3, 0.3), end: const Offset(1.0, 1.0), duration: 700.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              // App name
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFFD23F)],
                ).createShader(bounds),
                child: const Text(
                  'TaskNestX',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 700.ms)
                  .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 700.ms, curve: Curves.easeOut),

              const SizedBox(height: 8),

              Text(
                'Nest. Complete. Conquer.',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Outfit',
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 1000.ms),

              const SizedBox(height: 60),

              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 1200 + i * 200))
                    .then()
                    .fadeOut(duration: 400.ms)
                    .then()
                    .fadeIn(duration: 400.ms)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}