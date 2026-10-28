import 'package:flutter/material.dart';

class PortfolioHealthCard extends StatelessWidget {
  final double healthScore;
  final String action;
  // Share of scoring inputs actually available for scored holdings (0-100); null = none scored
  final double? dataCoverage;
  // When null the status is derived from the score (same bands as PortfolioHealthEngine)
  final String? healthStatus;
  final VoidCallback? onOpenAdvisor;

  const PortfolioHealthCard({
    super.key,
    required this.healthScore,
    required this.action,
    this.dataCoverage,
    this.healthStatus,
    this.onOpenAdvisor,
  });

  /// PortfolioHealthEngine's bands, so the card never shows a fixed placeholder status
  static String statusFor(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Strong';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Average';
    return 'Weak';
  }

  /// NSE cash session, Mon-Fri 09:15-15:30 IST (exchange holidays are not known here)
  static bool isMarketOpenIst(DateTime nowUtc) {
    final ist = nowUtc.toUtc().add(const Duration(hours: 5, minutes: 30));
    if (ist.weekday == DateTime.saturday || ist.weekday == DateTime.sunday) return false;
    final minutes = ist.hour * 60 + ist.minute;
    return minutes >= 9 * 60 + 15 && minutes <= 15 * 60 + 30;
  }

  @override
  Widget build(BuildContext context) {
    final score = healthScore.round().clamp(0, 100);
    const gaugeColor = Color(0xFFE5A93C);
    final status = healthStatus ?? statusFor(score);
    final live = isMarketOpenIst(DateTime.now());
    final badgeColor = live ? const Color(0xFF00E676) : const Color(0xFF8E929B);

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
          // Header: title + market badge ("Live" only while NSE is open)
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
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      live ? 'Live' : 'Market closed',
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
                      'Status: $status',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Average NV Score of your scored holdings, weighted by value.',
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
                                content: Text('Open NV Advisor from the bottom bar.'),
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
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF8E929B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    live
                        ? 'Market open: prices refresh every few minutes. NV Scores update every evening.'
                        : 'Market closed: prices are the last close. NV Scores update every evening.',
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