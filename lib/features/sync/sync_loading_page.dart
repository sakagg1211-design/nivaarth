import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/live_portfolio_provider.dart';
import '../../screens/home/home_page.dart';

class SyncLoadingPage extends ConsumerStatefulWidget {
  const SyncLoadingPage({super.key});

  @override
  ConsumerState<SyncLoadingPage> createState() => _SyncLoadingPageState();
}

class _SyncLoadingPageState extends ConsumerState<SyncLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double progress = 0.2;
  String currentStep = "Loading Portfolio...";

  final List<_SyncStep> steps = [
    _SyncStep(
      title: "Verifying Authentication",
      completed: true,
    ),
    _SyncStep(
      title: "Loading Portfolio Holdings",
      completed: false,
    ),
    _SyncStep(
      title: "Syncing Latest Prices & Health",
      completed: false,
    ),
    _SyncStep(
      title: "Portfolio Ready",
      completed: false,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSync();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startSync() async {
    try {
      if (!mounted) return;
      setState(() {
        steps[1].completed = true;
        currentStep = "Fetching Latest Market Prices...";
        progress = 0.50;
      });

      // Genuine live data fetch via Riverpod provider (No backend pipeline hammer)
      await ref.read(livePortfolioProvider.future);

      if (!mounted) return;
      setState(() {
        steps[2].completed = true;
        steps[3].completed = true;
        currentStep = "Portfolio Ready";
        progress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Notice: Using cached portfolio ($e)"),
          backgroundColor: AppColors.surfaceSecondary,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  const Text(
                    "NIVAARTH",
                    style: AppTypography.heading1,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  const Text(
                    "Preparing your portfolio intelligence",
                    style: AppTypography.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  RotationTransition(
                    turns: _controller,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    currentStep,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(
                    AppRadius.lg,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${(progress * 100).toInt()}%",
                    style: AppTypography.caption,
                  ),

                  const SizedBox(height: 40),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.line,
                      ),
                    ),
                    child: Column(
                      children: steps
                          .map(
                            (step) => _StepTile(step: step),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Please don't close the app.\nWe're preparing the latest market intelligence.",
                    textAlign: TextAlign.center,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} // <--- YEH BRACE MISSING THA (State class ko close karne ke liye)

class _SyncStep {
  final String title;
  bool completed;

  _SyncStep({
    required this.title,
    required this.completed,
  });
}

class _StepTile extends StatelessWidget {
  final _SyncStep step;

  const _StepTile({
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: step.completed
                  ? Colors.green
                  : AppColors.surfaceSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.completed
                  ? Icons.check
                  : Icons.circle_outlined,
              size: 14,
              color: step.completed
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              step.title,
              style: AppTypography.body.copyWith(
                color: step.completed
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}