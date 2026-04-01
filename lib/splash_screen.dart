import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:technestx/task_provider.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _nestController;

  @override
  void initState() {
    super.initState();
    _nestController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
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
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
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
              SizedBox(
                width: 280,
                height: 280,
                child: Lottie.asset(
                  'assets/checked.json',
                  repeat: true,
                  errorBuilder: (_, __, ___) =>
                  // Fallback: animated dots if lottie fails to load
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                          (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .fadeIn(
                          duration: 400.ms,
                          delay: Duration(
                              milliseconds: 1200 + i * 200))
                          .then()
                          .fadeOut(duration: 400.ms)
                          .then()
                          .fadeIn(duration: 400.ms),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 1200.ms).scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  delay: 1200.ms,
                  curve: Curves.elasticOut),



              // App name
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFFD23F)],
                ).createShader(bounds),
                child: Text(
                  'TaskNestX',
                  style: GoogleFonts.outfit(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 700.ms)
                  .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  delay: 700.ms,
                  curve: Curves.easeOut),

              const SizedBox(height: 8),

              Text(
                'Nest. Complete. Conquer.',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),

              const SizedBox(height: 48),

              // Lottie checked animation replacing the loading dots

            ],
          ),
        ),
      ),
    );
  }
}