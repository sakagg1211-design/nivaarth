import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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

            //------------------------------------------------
            // Blue Glow
            //------------------------------------------------

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

            //------------------------------------------------
            // Purple Glow
            //------------------------------------------------

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
                              Icons.auto_awesome,
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
                  // Company + Score
                  //------------------------------------------------

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              stock.companyName.isEmpty
                                  ? stock.instrument
                                  : stock.companyName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              stock.instrument,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 18),

                      SizedBox(
  width: 94,
  height: 94,
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
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "/100",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  ),
),
],
),

              const SizedBox(height: 24),

              const Text(
                "AI Breakdown",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [

                      _MetricTile(
                        title: "Business",
                        value: stock.businessQuality,
                      ),

                      _MetricTile(
                        title: "Financial",
                        value: stock.financialStrength,
                      ),

                      _MetricTile(
                        title: "Growth",
                        value: stock.growth,
                      ),

                      _MetricTile(
                        title: "Technical",
                        value: stock.technical,
                      ),

                      _MetricTile(
                        title: "Risk",
                        value: stock.risk,
                      ),

                      _MetricTile(
                        title: "Confidence",
                        value: stock.confidence,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  //------------------------------------------------
                  // Recommendation
                  //------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: scoreColor.withValues(alpha: .22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "AI Recommendation",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          stock.recommendation,
                          style: TextStyle(
                            color: scoreColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  //------------------------------------------------
                  // CTA
                  //------------------------------------------------

                  InkWell(
                    borderRadius:
                        BorderRadius.circular(18),
                    onTap: () {},

                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: .05,
                        ),
                        borderRadius:
                            BorderRadius.circular(18),
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
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.white38,
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
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 84) / 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: .06),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "$value",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
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

    final track = Paint()
      ..color = Colors.white.withValues(alpha: .08)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      track,
    );

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -1.5708,
      6.28318 * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}