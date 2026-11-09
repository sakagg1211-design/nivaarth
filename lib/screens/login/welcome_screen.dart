import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import '../../core/l10n/l10n_ext.dart';

/// Premium Nivaarth Welcome Screen
///
/// Designed with inspiration from Linear, Arc, and Mercury:
/// - Crisp typography & spacious layout
/// - Clear value propositions for focused investors
/// - Fast direct access to Login and Create Account
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Brand Emblem
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE5A93C).withValues(alpha: 0.20),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Headline
                  const Text(
                    'NIVAARTH',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Subtitle
                  Text(
                    context.t.welcomeTagline,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Value Pillars
                  _PillarTile(
                    icon: Icons.shield_outlined,
                    title: context.t.welcomePrivateTitle,
                    description:
                        context.t.welcomePrivateBody,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _PillarTile(
                    icon: Icons.auto_awesome_rounded,
                    title: context.t.welcomeScoringTitle,
                    description:
                        context.t.welcomeScoringBody,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _PillarTile(
                    icon: Icons.timeline_rounded,
                    title: context.t.welcomeCockpitTitle,
                    description:
                        context.t.welcomeCockpitBody,
                  ),

                  const SizedBox(height: 40),

                  // Actions Container
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.line),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Login Action (Primary)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(
                                    initialMode: LoginViewMode.signIn,
                                  ),
                                ),
                              );
                            },
                            child: Text(context.t.authSignIn),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Create Account Action (Secondary Outline)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(color: AppColors.lineStrong),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                              foregroundColor: AppColors.textPrimary,
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpPage(),
                                ),
                              );
                            },
                            child: Text(context.t.authCreateAnAccount),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Beta Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Text(
                        'Closed Friends Beta',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillarTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PillarTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
