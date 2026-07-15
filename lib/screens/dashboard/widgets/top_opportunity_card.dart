import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/stock_score.dart';

class TopOpportunityCard extends StatelessWidget {
  final StockScore stock;

  const TopOpportunityCard({
    super.key,
    required this.stock,
  });

  Color get scoreColor {
    if (stock.overallScore >= 90) return AppColors.success;
    if (stock.overallScore >= 75) return AppColors.mint;
    if (stock.overallScore >= 60) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF23293B),
            Color(0xFF151922),
          ],
        ),
        border: Border.all(
          color: Colors.white12,
          width: .6,
        ),
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
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x183B82F6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -90,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x16A855F7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //------------------------------------------------
                  // Header
                  //------------------------------------------------
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(
                            AppRadius.pill,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 15,
                              color: Color(0xFFF6C453),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Top Opportunity",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(
                            AppRadius.pill,
                          ),
                        ),
                        child: Text(
                          "TODAY",
                          style: TextStyle(
                            color: scoreColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  //------------------------------------------------
                  // Company + Ring
                  //------------------------------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stock.companyName.isEmpty
                                  ? stock.instrument.replaceAll(".NS", "")
                                  : stock.companyName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "NSE : ${stock.instrument.replaceAll(".NS", "")}",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: scoreColor.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                stock.recommendation,
                                style: TextStyle(
                                  color: scoreColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      SizedBox(
                        width: 112,
                        height: 112,
                        child: CustomPaint(
                          painter: _ScoreRingPainter(
                            progress: stock.overallScore / 100,
                            color: scoreColor,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${stock.overallScore}",
                                  style: TextStyle(
                                    color: scoreColor,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "/100",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  //------------------------------------------------
                  // AI Breakdown
                  //------------------------------------------------
                  const Text(
                    "AI Breakdown",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          title: "Business",
                          value: stock.businessQuality,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          title: "Financial",
                          value: stock.financialStrength,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          title: "Growth",
                          value: stock.growth,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          title: "Technical",
                          value: stock.technical,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          title: "Risk",
                          value: stock.risk,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          title: "Confidence",
                          value: stock.confidence,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  //------------------------------------------------
                  // CTA
                  //------------------------------------------------
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .05),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            color: Color(0xFF8B5CF6),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "View Full Analysis",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white54,
                            size: 18,
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

class _MetricTile extends StatelessWidget {
  final String title;
  final int value;

  const _MetricTile({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _metricColor(title, value);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _metricStatus(title, value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Text(
              "$value",
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _metricStatus(String title, int value) {
  switch (title) {
    case "Business":
      return value >= 15 ? "Excellent" : "Average";
    case "Financial":
      return value >= 15 ? "Strong" : "Average";
    case "Growth":
      return value >= 12 ? "Growing" : "Slow";
    case "Technical":
      return value >= 8 ? "Bullish" : "Weak";
    case "Risk":
      return value <= 2 ? "Low Risk" : "High Risk";
    case "Confidence":
      return value >= 70 ? "High AI" : "Medium AI";
    default:
      return "";
  }
}

Color _metricColor(String title, int value) {
  switch (title) {
    case "Risk":
      return value <= 2 ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    case "Technical":
      return value >= 8 ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B);
    default:
      if (value >= 15) {
        return const Color(0xFF22C55E);
      }
      if (value >= 10) {
        return const Color(0xFF3B82F6);
      }
      return const Color(0xFFF59E0B);
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ScoreRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 6;

    //------------------------------------------------------
    // Background Ring
    //------------------------------------------------------
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: .08)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      trackPaint,
    );

    //------------------------------------------------------
    // Progress Ring
    //------------------------------------------------------
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -1.57079632679,
      6.28318530718 * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    //------------------------------------------------------
    // Soft Glow
    //------------------------------------------------------
    final glowPaint = Paint()
      ..color = color.withValues(alpha: .12)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        12,
      )
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -1.57079632679,
      6.28318530718 * progress.clamp(0.0, 1.0),
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _ScoreRingPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}