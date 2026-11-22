import 'package:flutter/material.dart';

import '../../../core/utils/market_hours.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/health_math.dart';
import 'health_breakdown_sheet.dart';
import '../../../core/theme/app_colors.dart';

class PortfolioHealthCard extends StatelessWidget {
  final double healthScore;
  final String action;
  // Share of scoring inputs actually available for scored holdings (0-100); null = none scored
  final double? dataCoverage;
  // When null the status is derived from the score (same bands as PortfolioHealthEngine)
  final String? healthStatus;
  final VoidCallback? onOpenAdvisor;

  /// Each holding's score and value; when present, the score opens what sets it.
  final List<HoldingScore> holdingScores;

  const PortfolioHealthCard({
    super.key,
    required this.healthScore,
    required this.action,
    this.dataCoverage,
    this.healthStatus,
    this.onOpenAdvisor,
    this.holdingScores = const [],
  });

  /// PortfolioHealthEngine's bands, so the card never shows a fixed placeholder status
  static String statusFor(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Strong';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Average';
    return 'Weak';
  }

  @override
  Widget build(BuildContext context) {
    final score = healthScore.round().clamp(0, 100);
    final gaugeColor = AppColors.accent;
    final status = healthStatus ?? statusFor(score);
    final live = isMarketOpenIst(DateTime.now());
    final badgeColor = live ? AppColors.success : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.line,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: title + market badge ("Live" only while NSE is open)
          Row(
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                context.t.healthIndex,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      live ? context.t.commonLive : context.t.commonMarketClosed,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Body: Circular Ring + Analysis Text & data coverage + CTA
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular score gauge
              SizedBox(
                width: 86,
                height: 86,
                child: Semantics(label: context.t.semHealth('$score', status), button: holdingScores.isNotEmpty, onTap: holdingScores.isEmpty ? null : () => showHealthBreakdown(context, holdingScores), excludeSemantics: true, child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: holdingScores.isEmpty ? null : () => showHealthBreakdown(context, holdingScores),
                  child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 86,
                      height: 86,
                      child: CircularProgressIndicator(
                        value: (score / 100).clamp(0.05, 1.0),
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.surfaceSecondary,
                        valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '/100',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                )),
              ),

              const SizedBox(width: 20),

              // Data coverage, status and CTA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          dataCoverage == null
                              ? context.t.healthCoverageNa
                              : context.t.healthCoverage(dataCoverage!.round()),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.t.healthStatus(status),
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.t.healthExplain,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: onOpenAdvisor ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.t.healthOpenAdvisorHint),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.t.healthOpenAdvisor,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Mini AI statement pill strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    live
                        ? context.t.healthMarketOpenNote
                        : context.t.healthMarketClosedNote,
                    style: TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
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