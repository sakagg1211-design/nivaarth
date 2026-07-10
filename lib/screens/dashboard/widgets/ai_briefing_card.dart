import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class AIBriefingCard extends StatelessWidget {
  final String verdict;
  final double confidence;
  final List<String> reasons;
  final String recommendation;
  final VoidCallback? onTap;

  const AIBriefingCard({
    super.key,
    required this.verdict,
    required this.confidence,
    required this.reasons,
    required this.recommendation,
    this.onTap,
  });

  bool get _isPositive =>
      verdict.toLowerCase().contains("strong") ||
      verdict.toLowerCase().contains("bull") ||
      verdict.toLowerCase().contains("buy");

  @override
  Widget build(BuildContext context) {
    final accent =
        _isPositive ? AppColors.success : AppColors.warning;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff23293B),
            Color(0xff151922),
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
            // Blue Ambient Glow
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
            // Purple Ambient Glow
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  //------------------------------------------------
                  // Header
                  //------------------------------------------------

                  Row(
                    children: [

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: .08,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.pill,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [

                            Icon(
                              Icons.auto_awesome,
                              size: 15,
                              color:
                                  Color(0xFFF6C453),
                            ),

                            SizedBox(width: 8),

                            Text(
                              "AI Briefing",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF8B5CF6,
                          ).withValues(alpha: .15),
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.pill,
                          ),
                        ),
                        child: const Text(
                          "LIVE AI",
                          style: TextStyle(
                            color:
                                Color(0xFF8B5CF6),
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    verdict,
                    style: TextStyle(
                      color: accent,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "AI Confidence",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      Text(
                        "${confidence.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            100,
                          ),
                          child: LinearProgressIndicator(
                            value: confidence / 100,
                            minHeight: 8,
                            color:
                                const Color(
                              0xFF8B5CF6,
                            ),
                            backgroundColor:
                                Colors.white10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),
                                    //------------------------------------------------
                  // Why AI thinks this
                  //------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
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

                        const Text(
                          "Why AI thinks this",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ...reasons.take(3).map(
                          (reason) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 14,
                            ),
                            child: _ReasonRow(
                              text: reason,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  //------------------------------------------------
                  // Recommendation
                  //------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: accent.withValues(alpha: .20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Recommended Action",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          recommendation,
                          style: TextStyle(
                            color: accent,
                            fontSize: 18,
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
                    onTap: onTap,
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
                            Icons.auto_awesome,
                            color: Color(0xFF8B5CF6),
                            size: 18,
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Open AI Copilot",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white38,
                            size: 14,
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

class _ReasonRow extends StatelessWidget {
  final String text;

  const _ReasonRow({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.check_circle_rounded;
    Color color = AppColors.success;

    if (text.toLowerCase().contains("risk") ||
        text.toLowerCase().contains("weak") ||
        text.toLowerCase().contains("warning")) {
      icon = Icons.warning_amber_rounded;
      color = AppColors.warning;
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          color: color,
          size: 18,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}