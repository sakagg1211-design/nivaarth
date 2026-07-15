import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';

class PortfolioHeroCard extends StatelessWidget {
  final double currentValue;
  final double investedValue;
  final double netPnL;
  final double returnPercent;
  final int holdings;
  final double aiConfidence;

  const PortfolioHeroCard({
    super.key,
    required this.currentValue,
    required this.investedValue,
    required this.netPnL,
    required this.returnPercent,
    required this.holdings,
    required this.aiConfidence,
  });

  bool get isProfit => netPnL >= 0;

  @override
  Widget build(BuildContext context) {
    final tone =
        isProfit ? AppColors.success : AppColors.danger;

    return Container(
  width: double.infinity,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(28),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xff23293B),
        Color(0xff141821),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .22),
        blurRadius: 42,
        offset: const Offset(0, 18),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: Stack(
      children: [

        // Blue Glow
        Positioned(
          top: -105,
          right: -90,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x223B82F6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Purple Glow
        Positioned(
          bottom: -120,
          left: -100,
          child: Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x22A855F7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Ring
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: .04),
                width: 1.5,
              ),
            ),
          ),
        ),

        // Ring
        Positioned(
          bottom: -80,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: .03),
                width: 1.2,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Portfolio",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const _LiveBadge(),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                "Current Value",
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 8),

              Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        _money(currentValue),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 42,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    ),

    const SizedBox(height: 4),

    Text(
  Formatters.currency0(currentValue),
  style: const TextStyle(
    color: Color(0x73FFFFFF),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  ),
),
  ],
),
             const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  "${_money(netPnL, signed: true)}   (${_percent(returnPercent)})",
                  style: TextStyle(
                    color: tone,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      icon: Icons.payments_outlined,
                      title: "Invested",
                      value: _money(investedValue),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _HeroMetric(
                      icon: Icons.account_balance_outlined,
                      title: "Holdings",
                      value: holdings.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      icon: Icons.auto_awesome,
                      title: "AI Confidence",
                      value: "${aiConfidence.toStringAsFixed(0)}%",
                      valueColor: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _HeroMetric(
                      icon: Icons.trending_up,
                      title: "Return",
                      value: _percent(returnPercent),
                      valueColor: tone,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .06),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
      BoxShadow(
        color: const Color(0xFF8B5CF6).withValues(alpha: .35),
        blurRadius: 24,
        spreadRadius: 2,
                              ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF8B5CF6),
                      ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's AI Insight",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                         const SizedBox(height: 4),
                          Text(
                            isProfit
                                ? "Portfolio momentum remains positive."
                                : "Market volatility remains elevated.\n"
                                  "Current drawdown appears manageable.",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

const Icon(
 Icons.arrow_forward_rounded,
  size: 20,
  color: Colors.white38,
),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
}
}
  class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _HeroMetric({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = valueColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: .08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 17,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(
          alpha: .15,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.pill,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 8),

          const Text(
            "LIVE",
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}
String _money(
  num value, {
  bool signed = false,
}) {
  final prefix =
      signed && value >= 0 ? "+" : "";

  final abs = value.abs();

  if (abs >= 10000000) {
    return "$prefix₹${(value / 10000000).toStringAsFixed(2)} Cr";
  }

  if (abs >= 100000) {
    return "$prefix₹${(value / 100000).toStringAsFixed(2)} L";
  }

  return "$prefix₹${value.toStringAsFixed(0)}";
}

String _percent(
  num value, {
  bool signed = true,
}) {
  final prefix =
      signed && value >= 0 ? "+" : "";

  return "$prefix${value.toStringAsFixed(2)}%";
}