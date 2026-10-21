import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../home/home_page.dart';
import '../login/welcome_screen.dart';

/// Premium Nivaarth Splash Screen
///
/// Handles:
/// - Nivaarth branding & animated emblem
/// - Asynchronous initialization & session verification
/// - Smooth animated transition to [HomePage] or [LoginPage]
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _handleRouting();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRouting() async {
    // Provide adequate brand immersion time while checking session
    final stopwatch = Stopwatch()..start();

    // Session check via Supabase
    final session = Supabase.instance.client.auth.currentSession;

    final elapsed = stopwatch.elapsedMilliseconds;
    const minSplashDuration = 1400; // milliseconds
    if (elapsed < minSplashDuration) {
      await Future.delayed(
        Duration(milliseconds: minSplashDuration - elapsed),
      );
    }

    if (!mounted) return;

    final targetScreen =
        session != null ? const HomePage() : const WelcomeScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // App Logo Badge
                Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE5A93C).withValues(alpha: 0.25),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Brand Title
                const Text(
                  'NIVAARTH',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Tagline / Subtitle
                const Text(
                  'Private Portfolio Intelligence',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),

                const Spacer(),

                // Subtle Progress Indicator
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Version Tag
                Text(
                  'Friends Beta',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
