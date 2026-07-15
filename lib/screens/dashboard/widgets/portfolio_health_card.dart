import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class PortfolioHealthCard extends StatelessWidget {
  final double healthScore;
  final String action;

  const PortfolioHealthCard({
    super.key,
    required this.healthScore,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _tone(healthScore);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF23293B), Color(0xFF151922)],
        ),
        border: Border.all(color: Colors.white12, width: .6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .20),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            //--------------------------------------------------
            // Blue Ambient Glow
            //--------------------------------------------------
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x183B82F6), Colors.transparent],
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // Purple Ambient Glow
            //--------------------------------------------------
            Positioned(
              bottom: -120,
              left: -90,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x16A855F7), Colors.transparent],
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // Decorative Ring
            //--------------------------------------------------
            Positioned(
              top: -60,
              right: -35,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .04),
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // Content
            //--------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(
  horizontal: 22,
  vertical: 20,
),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //--------------------------------------------------
                  // Header
                  //--------------------------------------------------
                  Row(
  children: [

    //----------------------------------------
    // AI Icon
    //----------------------------------------

    Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF34D399),
            Color(0xFF10B981),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: .35),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: 26,
      ),
    ),

    const SizedBox(width: 16),

    //----------------------------------------
    // Title
    //----------------------------------------

    const Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "AI Portfolio Health",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          SizedBox(height: 4),

          Text(
            "Updated 2 mins ago",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),

    //----------------------------------------
    // Score Badge
    //----------------------------------------

    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _healthColor(healthScore).withValues(alpha: .15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "${healthScore.toInt()}/100",
        style: TextStyle(
          color: _healthColor(healthScore),
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    ),
  ],
),

                  const SizedBox(height: 28),

                  //--------------------------------------------------
                  // Health Gauge Section
                  //--------------------------------------------------
                 Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [

    //-------------------------------------------------
    // Premium Health Ring
    //-------------------------------------------------

    SizedBox(
      width: 138,
      height: 138,
      child: Stack(
        alignment: Alignment.center,
        children: [

          SizedBox(
            width: 138,
            height: 138,
            child: CircularProgressIndicator(
              value: healthScore / 100,
              strokeWidth: 12,
              backgroundColor: Colors.white.withValues(alpha: .08),
              valueColor: AlwaysStoppedAnimation(
                _healthColor(healthScore),
              ),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                healthScore.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                "/100",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .45),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ),

    const SizedBox(width: 24),

    //-------------------------------------------------
    // Health Summary
    //-------------------------------------------------

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
  _healthStatus(healthScore),
  style: TextStyle(
    color: _healthColor(healthScore),
    fontWeight: FontWeight.w900,
    fontSize: 30,
    letterSpacing: -.3,
  ),
),

          const SizedBox(height: 18),

          Text(
            "AI Confidence",
            style: TextStyle(
              color: Colors.white.withValues(alpha: .55),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "91%",
            style: TextStyle(
              color: Color(0xFF8B5CF6),
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 4),

Text(
  "High Confidence",
  style: TextStyle(
    color: Colors.white.withValues(alpha: .55),
    fontSize: 13,
    fontWeight: FontWeight.w500,
  ),
),
          const SizedBox(height: 18),

          Row(
            children: [

              Icon(
                Icons.trending_up_rounded,
                size: 20,
                color: Colors.greenAccent.shade400,
              ),

              const SizedBox(width: 6),

              Text(
                "+4 This Week",
                style: TextStyle(
                  color: Colors.greenAccent.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "Portfolio quality improved",
            style: TextStyle(
              color: Colors.white.withValues(alpha: .55),
            ),
          ),
        ],
      ),
    ),
  ],
),

                  const SizedBox(height: 24),

                  //--------------------------------------------------
                  // AI Insights
                  //--------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 18,
),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .05),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .06),
                      ),
                    ),
                    child: Column(
                      children: [
                        _InsightRow(
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                          text: "Strong Business Quality",
                        ),

                        const SizedBox(height: 18),

                        _InsightRow(
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF60A5FA),
                          text: "Healthy Balance Sheet",
                        ),

                        const SizedBox(height: 18),

                        _InsightRow(
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          text: "Technical Momentum Needs Attention",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  //--------------------------------------------------
                  // CTA
                  //--------------------------------------------------
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .05),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF8B5CF6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "View Full AI Analysis",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Detailed portfolio diagnosis",
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: Colors.white54,
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
      ),
    );
  }
}

Color _tone(double score) {
  if (score >= 80) return AppColors.success;
  if (score >= 60) return AppColors.accent;
  if (score >= 40) return AppColors.warning;
  return AppColors.danger;
}
Color _healthColor(double score) {
  if (score >= 80) {
    return const Color(0xFF22C55E);
  }

  if (score >= 60) {
    return const Color(0xFF3B82F6);
  }

  if (score >= 40) {
    return const Color(0xFFF59E0B);
  }

  return const Color(0xFFEF4444);
}
String _healthStatus(double score) {
  if (score >= 80) return "Excellent";
  if (score >= 60) return "Healthy";
  if (score >= 40) return "Needs Attention";
  return "High Risk";
}
String _status(double score) {
  if (score >= 80) return "Strong portfolio";
  if (score >= 60) return "Good portfolio";
  if (score >= 40) return "Needs attention";
  return "High risk";
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: color.withValues(alpha: .25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InsightRow({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
  text,
  style: const TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.2,
  ),
),
        ),
      ],
    );
  }
}