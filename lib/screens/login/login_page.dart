import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/sync/sync_loading_page.dart';
import '../../services/auth_service.dart';
import 'forgot_password_page.dart';
import 'sign_up_page.dart';
import '../../widgets/legal_disclaimer_sheet.dart';

enum LoginViewMode {
  signIn,
  signUp,
}

class LoginPage extends StatefulWidget {
  final LoginViewMode initialMode;

  const LoginPage({
    super.key,
    this.initialMode = LoginViewMode.signIn,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool loading = false;
  bool obscurePassword = true;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      await authService.signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SyncLoadingPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final rawMessage = e.toString().toLowerCase();
      String userFriendlyMessage;

      if (rawMessage.contains('invalid login credentials') ||
          rawMessage.contains('invalid_credentials')) {
        userFriendlyMessage = 'Incorrect email or password.';
      } else if (rawMessage.contains('network') ||
          rawMessage.contains('connection') ||
          rawMessage.contains('socketexception')) {
        userFriendlyMessage =
            'Network issue. Please check your internet connection.';
      } else if (rawMessage.contains('rate limit')) {
        userFriendlyMessage = 'Too many attempts. Please try again shortly.';
      } else {
        userFriendlyMessage =
            'Unable to sign in. Please verify your details.';
      }

      setState(() {
        errorMessage = userFriendlyMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE5A93C).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5A93C).withValues(alpha: 0.15),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.5),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF16171B),
                            child: const Center(
                              child: Text(
                                'N',
                                style: TextStyle(
                                  color: Color(0xFFE5A93C),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text('NIVAARTH', style: AppTypography.heading1),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Private portfolio intelligence for focused investors.',
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.line),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ink.withValues(alpha: 0.04),
                            blurRadius: 28,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.alternate_email_rounded),
                            ),
                            onChanged: (_) {
                              if (errorMessage != null) {
                                setState(() => errorMessage = null);
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textTertiary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                            onChanged: (_) {
                              if (errorMessage != null) {
                                setState(() => errorMessage = null);
                              }
                            },
                            onSubmitted: (_) {
                              if (!loading) login();
                            },
                          ),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: loading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ForgotPasswordPage(
                                            initialEmail:
                                                emailController.text.trim(),
                                          ),
                                        ),
                                      );
                                    },
                              child: Text(
                                'Forgot password?',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          // Error Banner
                          if (errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.dangerSoft,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: AppColors.danger.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 16,
                                    color: AppColors.danger,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMessage!,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          const SizedBox(height: AppSpacing.sm),

                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading ? null : login,
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Create Account Link
                          Center(
                            child: TextButton(
                              onPressed: loading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignUpPage(),
                                        ),
                                      );
                                    },
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: AppTypography.bodySmall,
                                  children: const [
                                    TextSpan(
                                      text: 'Create Account',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _TrustStrip(),
                    const SizedBox(height: AppSpacing.md),
                    GestureDetector(
                      onTap: () => LegalDisclaimerSheet.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131418),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF23252B)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF757A85)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Nivaarth is an educational & analytical technology platform. Not registered with SEBI as an Investment Adviser.',
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF757A85),
                                  fontSize: 10.5,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Details ↗',
                              style: TextStyle(
                                color: Color(0xFFE5A93C),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _TrustItem(icon: Icons.shield_outlined, label: 'Secure'),
        SizedBox(width: AppSpacing.sm),
        _TrustItem(icon: Icons.auto_awesome_rounded, label: 'NV Scored'),
        SizedBox(width: AppSpacing.sm),
        _TrustItem(icon: Icons.timeline_rounded, label: 'Live view'),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
