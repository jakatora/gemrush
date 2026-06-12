import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/routes.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      final seen = await OnboardingScreen.wasSeen();
      if (!mounted) return;
      context.go(seen ? Routes.menu : Routes.onboarding);
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.cardGradient1, AppColors.background],
            radius: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _logoCtrl,
                  curve: Curves.elasticOut,
                ),
                child: AnimatedBuilder(
                  animation: _shimmerCtrl,
                  builder: (context, _) => _Logo(shimmer: _shimmerCtrl.value),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _logoCtrl,
                  curve: const Interval(0.5, 1.0),
                ),
                child: Text(
                  'Gem Rush Saga',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                ),
              ),
              const SizedBox(height: 4),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _logoCtrl,
                  curve: const Interval(0.7, 1.0),
                ),
                child: const Text(
                  'Match. Smash. Win.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.shimmer});
  final double shimmer; // 0..1

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.6 + shimmer * 0.3),
            AppColors.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3 + shimmer * 0.3),
            blurRadius: 30 + shimmer * 10,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Transform.rotate(
        angle: shimmer * 6.28,
        child: const Icon(Icons.auto_awesome, size: 70, color: Colors.white),
      ),
    );
  }
}
