import 'package:flutter/material.dart';

class PortfolioHealthCard extends StatelessWidget {
  final double healthScore;
  final String action;
  // Share of scoring inputs actually available for scored holdings (0-100); null = none scored
  final double? dataCoverage;
  final String healthStatus;
  final VoidCallback? onOpenAdvisor;

  const PortfolioHealthCard({
    super.key,
    required this.healthScore,
    required this.action,
    this.dataCoverage,
    this.healthStatus = 'Needs Attention',
    this.onOpenAdvisor,
  });

  @override
  Widget build(BuildContext context) {
    final score = healthScore.round().clamp(0, 100);
    const gaugeColor = Color(0xFFE5A93C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF282A30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Sparkle + "AI PORTFOLIO HEALTH" + "Live" badge
          Row(
            children: [
              const Icon(
                Icons.health_and_safety_rounded,
                size: 14,
                color: Color(0xFFE5A93C),
              ),
              const SizedBox(width: 8),
              const Text(
                'NV HEALTH INDEX',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE5A93C),
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x1F00E676),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: Color(0xFF00E676)),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00E676),
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
                        backgroundColor: const Color(0xFF23252B),
                        valueColor: const AlwaysStoppedAnimation<Color>(gaugeColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '/100',
                          style: TextStyle(
                            color: Color(0xFF757A85),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                              ? 'Data coverage: —'
                              : 'Data coverage: ${dataCoverage!.round()}%',
                          style: const TextStyle(
                            color: Color(0xFF8E929B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: $healthStatus',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Nivaarth engine actively tracking risk & quality.',
                      style: TextStyle(
                        color: Color(0xFF8E929B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: onOpenAdvisor ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nivaarth Advisor is monitoring portfolio risk.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Open Advisor',
                              style: TextStyle(
                                color: Color(0xFFE5A93C),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Color(0xFFE5A93C),
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
              color: const Color(0xFF1E2024),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF282A30)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF00E676)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Multi-factor balance active • Risk hedging monitored',
                    style: TextStyle(
                      color: Color(0xFFC7CDD6),
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