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
    final s = stock.overallScore;
    if (s == null) return AppColors.warning;
    if (s >= 90) return AppColors.success;
    if (s >= 75) return AppColors.mint;
    if (s >= 60) return AppColors.warning;
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
                            progress: (stock.overallScore ?? 0) / 100,
                            color: scoreColor,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  stock.overallScore != null
                                      ? "${stock.overallScore}"
                                      : "N/A",
                                  style: TextStyle(
                                    color: scoreColor,
                                    fontSize: stock.overallScore != null ? 34 : 26,
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
                    "NV Analytics",
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
                        child: _MetricTile.pillar("Quality", stock.pillarScore("quality")),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile.pillar("Valuation", stock.pillarScore("valuation")),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile.pillar("Momentum", stock.pillarScore("momentum")),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile.coverage(stock.qualityCoverage),
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
  final String display;
  final String status;
  final Color accent;

  const _MetricTile({
    required this.title,
    required this.display,
    required this.status,
    required this.accent,
  });

  /// A pillar of the NV Score (0-100) from the score breakdown; facts only
  factory _MetricTile.pillar(String title, int? value) {
    return _MetricTile(
      title: title,
      display: value == null ? "—" : "$value",
      status: value == null ? "No data" : (value >= 70 ? "High" : (value >= 50 ? "Middle" : "Low")),
      accent: value == null
          ? Colors.white38
          : (value >= 70 ? const Color(0xFF22C55E) : (value >= 50 ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B))),
    );
  }

  /// How many quality inputs had data (v2.7: fewer than 3 of 4 limits the score)
  factory _MetricTile.coverage((int, int)? c) {
    return _MetricTile(
      title: "Quality data",
      display: c == null ? "—" : "${c.$1}/${c.$2}",
      status: c == null ? "Not shown" : (c.$1 >= 3 ? "Enough inputs" : "Limited inputs"),
      accent: c == null || c.$1 < 3 ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  status,
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
              display,
              style: TextStyle(
                color: accent,
                fontSize: display.length > 3 ? 12 : 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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