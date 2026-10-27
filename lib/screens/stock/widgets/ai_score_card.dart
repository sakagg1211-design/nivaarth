import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/stock_score.dart';

class AiScoreCard extends StatelessWidget {
  final StockScore score;

  const AiScoreCard({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {

    final Color scoreColor =
        _scoreColor(score.overallScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.outline.withValues(
            alpha: .25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: .10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "NV Score",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "Quantitative Conviction Score",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _RecommendationChip(
                recommendation: score.recommendation,
              ),
            ],
          ),

          const SizedBox(
            height: 28,
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [

              SizedBox(
                height: 120,
                width: 120,

                child: Stack(
                  alignment:
                      Alignment.center,

                  children: [

                    SizedBox(
                      height: 120,
                      width: 120,

                      child:
                          CircularProgressIndicator(
                        value: score.overallScore != null
                            ? (score.overallScore! / 100)
                            : 0.0,

                        strokeWidth: 11,

                        backgroundColor:
                            AppColors.outline.withValues(
                          alpha: .20,
                        ),

                        valueColor:
                            AlwaysStoppedAnimation(
                          scoreColor,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Text(
                          score.overallScore != null
                              ? "${score.overallScore}"
                              : "N/A",
                          style: AppTypography.displaySmall.copyWith(
                            color: scoreColor,
                            fontWeight: FontWeight.w900,
                            fontSize: score.overallScore != null ? 32 : 24,
                          ),
                        ),

                        Text(
                          score.overallScore != null ? "/100" : "EXCLUDED",
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 24,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      score.companyName.isEmpty
                          ? score.instrument
                          : score.companyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    Text(
                      score.instrument,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    if (score.isExcluded ||
                        score.provisionalCreditPending ||
                        score.provisionalBrokerMTF ||
                        score.debtNotAssessed) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          if (score.isExcluded)
                            _buildInstitutionalBadge(
                              label: "Score Excluded",
                              icon: Icons.block_outlined,
                              color: Colors.amber,
                            ),
                          if (score.provisionalCreditPending)
                            _buildInstitutionalBadge(
                              label: "Credit Pending",
                              icon: Icons.account_balance_outlined,
                              color: Colors.blue,
                            ),
                          if (score.provisionalBrokerMTF)
                            _buildInstitutionalBadge(
                              label: "Broker MTF Leverage",
                              icon: Icons.account_balance_wallet_outlined,
                              color: Colors.purple,
                            ),
                          if (score.debtNotAssessed)
                            _buildInstitutionalBadge(
                              label: "Debt Not Assessed",
                              icon: Icons.warning_amber_rounded,
                              color: Colors.orange,
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    Row(
                      children: [

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(
                              alpha: .12,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            _ratingText(
                              score.overallScore,
                            ),
                            style:
                                AppTypography.bodySmall
                                    .copyWith(
                              color: scoreColor,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const Spacer(),

                        Text(
                          "${score.confidence}% Data coverage",
                          style: AppTypography.bodySmall
                              .copyWith(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.lg,
                      ),
                      child:
                          LinearProgressIndicator(
                        minHeight: 8,
                        value:
                            score.confidence /
                                100,
                        backgroundColor:
                            AppColors.outline
                                .withValues(
                          alpha: .20,
                        ),
                        valueColor:
                            AlwaysStoppedAnimation(
                          scoreColor,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    Text(
                      _summary(),
                      style:
                          AppTypography.bodySmall
                              .copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          Divider(
            color: AppColors.outline.withValues(
              alpha: .30,
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Row(
            children: [
              Text(
                "NV Analytics",
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showExplainableAiSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x1FE5A93C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x33E5A93C)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology_outlined, size: 14, color: Color(0xFFE5A93C)),
                      SizedBox(width: 4),
                      Text(
                        "Methodology ℹ️",
                        style: TextStyle(
                          color: Color(0xFFE5A93C),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          _ScoreTile(
            title: "Business Quality",
            subtitle: "ROCE, ROE, Moat & Operating Margins",
            value: score.businessQuality,
            maxScore: 25,
            color: Colors.blue,
            icon: Icons.business_center_outlined,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Financial Strength",
            subtitle: "Solvency, Debt-to-Equity & Interest Cover",
            value: score.financialStrength,
            maxScore: 25,
            color: AppColors.success,
            icon: Icons.account_balance_wallet_outlined,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Growth",
            subtitle: "3-Yr Sales CAGR & Profit Compounding",
            value: score.growth,
            maxScore: 20,
            color: Colors.orange,
            icon: Icons.trending_up,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Valuation",
            subtitle: "PE vs 5-Yr Avg Multiple & Price-to-Book",
            value: score.valuation,
            maxScore: 15,
            color: Colors.deepPurple,
            icon: Icons.payments_outlined,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Technical",
            subtitle: "50/200 EMA Alignment, RSI & Volume",
            value: score.technical,
            maxScore: 10,
            color: Colors.teal,
            icon: Icons.show_chart,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Risk & Volatility",
            subtitle: "Beta vs Nifty 50 & Drawdown Resilience",
            value: score.risk,
            maxScore: 5,
            color: AppColors.danger,
            icon: Icons.warning_amber_rounded,
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),
        ],
      ),
    );
  }

  void _showExplainableAiSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF131418),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.sheet),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  height: 4,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3138),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x1FE5A93C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        color: Color(0xFFE5A93C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explainable AI Methodology',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '100-Point Quantitative Conviction Matrix',
                            style: TextStyle(
                              color: Color(0xFF8E929B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF23252B), height: 24),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: [
                      _buildPillarExplainer(
                        name: 'Business Quality',
                        pts: '25 Pts (25%)',
                        color: Colors.blue,
                        metrics: 'ROCE > 20%, ROE > 15%, Operating Profit Margin consistency, moat & industry leadership.',
                      ),
                      const SizedBox(height: 12),
                      _buildPillarExplainer(
                        name: 'Financial Strength',
                        pts: '25 Pts (25%)',
                        color: AppColors.success,
                        metrics: 'Debt-to-Equity (< 0.5x), Interest Coverage (> 3.5x), solvency ratios, zero pledging.',
                      ),
                      const SizedBox(height: 12),
                      _buildPillarExplainer(
                        name: 'Growth',
                        pts: '20 Pts (20%)',
                        color: Colors.orange,
                        metrics: '3-Year Compounded Sales CAGR (> 12%), PAT Compounding (> 15%), revenue durability.',
                      ),
                      const SizedBox(height: 12),
                      _buildPillarExplainer(
                        name: 'Valuation',
                        pts: '15 Pts (15%)',
                        color: Colors.deepPurple,
                        metrics: 'Current P/E vs 5-Year Historical Average PE multiple, Price-to-Book & sector discount/premium.',
                      ),
                      const SizedBox(height: 12),
                      _buildPillarExplainer(
                        name: 'Technical Momentum',
                        pts: '10 Pts (10%)',
                        color: Colors.teal,
                        metrics: '50-Day & 200-Day EMA alignment, RSI-14 momentum range (45-65), volume trend confirmation.',
                      ),
                      const SizedBox(height: 12),
                      _buildPillarExplainer(
                        name: 'Risk & Volatility',
                        pts: '5 Pts (5%)',
                        color: AppColors.danger,
                        metrics: '1-Year Beta relative to Nifty 50, maximum peak-to-trough drawdown protection.',
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17191E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF262830)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shield_outlined, size: 16, color: Color(0xFFE5A93C)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'SEBI Compliance Note: Nivaarth scores are computed using rule-based quantitative models. They provide objective mathematical visibility into fundamental & technical strength without human bias or direct investment tips.',
                                style: TextStyle(
                                  color: Color(0xFF8E929B),
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPillarExplainer({
    required String name,
    required String pts,
    required Color color,
    required String metrics,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF17191E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262830)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  pts,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            metrics,
            style: const TextStyle(
              color: Color(0xFF8E929B),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInstitutionalBadge({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int? score) {
    if (score == null) {
      return Colors.amber;
    }

    if (score >= 80) {
      return AppColors.success;
    }

    if (score >= 60) {
      return Colors.orange;
    }

    return AppColors.danger;
  }

  String _ratingText(int? score) {
    if (score == null) {
      return "Excluded";
    }

    if (score >= 85) {
      return "Excellent";
    }

    if (score >= 70) {
      return "Strong";
    }

    if (score >= 55) {
      return "Average";
    }

    return "Weak";
  }

  String _summary() {
    if (score.isExcluded) {
      final rec = score.recommendation.toUpperCase();
      if (rec.contains("INSURANCE")) {
        return "Life and General Insurance firms operate on actuarial float and statutory accounting. Quantitative 1-100 scoring is withheld until dedicated Embedded Value (EV) models are integrated.";
      } else if (rec.contains("HOLDING")) {
        return "Investment holding companies trade at variable net asset value (NAV) discounts. Standard operating multiples (P/E, ROCE) are not applicable; specialized SOTP research is recommended.";
      } else if (rec.contains("REIT") || rec.contains("INVIT")) {
        return "Real Estate & Infrastructure Investment Trusts operate on distribution yield and Net Asset Value (NAV). Standard industrial scoring is withheld.";
      }
      return "Quantitative conviction score withheld: specialized asset-class valuation framework required.";
    }

    final rec = SymbolUtils.toCompliantVerdict(score.recommendation).toUpperCase();
    final bq = score.businessQuality;
    final val = score.valuation;
    final tech = score.technical;
    final risk = score.risk;
    final growth = score.growth;

    // 1. Critical Risk / High Pledging Override (e.g. SEPC, A2ZINFRA)
    if (risk == 0 || rec.contains("HIGH RISK") || rec.contains("FLAG") || rec.contains("AVOID")) {
      return "Critical risk threshold breached (elevated promoter share encumbrance or capital distress). Quant safety framework strictly enforces capital preservation over short-term price swings.";
    }

    // 2. High Quality Business with Premium Valuation Overhang (e.g. TITAN)
    if (bq >= 15 && val <= 5) {
      if (tech <= 4) {
        return "Core business franchise & ROE remain superior, but shares trade at a premium valuation multiple with short-term chart consolidation. Research score reflects valuation overhang rather than business weakness.";
      }
      return "Exceptional industry moat and capital compounding, but current market multiple leaves modest margin of safety for fresh allocation.";
    }

    // 3. High Growth with Low Operating Hurdle / Margin Expansion Awaited (e.g. CCAVENUE)
    if (growth >= 14 && bq < 12) {
      return "Robust top-line revenue expansion, but operating return on capital (ROCE) remains below the 8% cost-of-capital hurdle. Framework awaits operating margin expansion before accumulate eligibility.";
    }

    // 4. Strong Fundamentals awaiting Technical Confirmation
    if (score.overallScore != null && score.overallScore! >= 70 && tech <= 5) {
      return "Business fundamentals demonstrate healthy return on capital. Technical momentum data remains under active tracking; framework awaits moving average base confirmation.";
    }

    // 5. Overvalued with Technical Breakdown (e.g. ASIANPAINT)
    if (rec.contains("TRIM") || rec.contains("ELEVATED VALUATION")) {
      return "Extended valuation multiple coupled with moving average breakdown indicates ongoing consolidation. Framework suggests disciplined portfolio review.";
    }

    // 6. Below Capital Efficiency Hurdle (e.g. TITAGARH)
    if (rec.contains("BELOW HURDLE") || bq < 10) {
      return "Return on capital (ROCE/ROE) remains below institutional hurdle rates against prevailing multiples. Capital allocation efficiency requires quarterly monitoring.";
    }

    // 7. General High Conviction Accumulate
    if (score.overallScore != null && score.overallScore! >= 75) {
      return "Superior capital efficiency, pristine solvency, and attractive risk-reward alignment. Quantitative composite remains in institutional accumulation territory.";
    }

    if (score.overallScore != null && score.overallScore! >= 60) {
      return "Healthy underlying business fundamentals with balanced risk-reward. Monitor quarterly execution and entry valuation before increasing allocation.";
    }

    return "Current conviction score reflects mixed factor balance across valuation, quality, and momentum. Prudent research discipline suggested before fresh capital commitment.";
  }
}

class _ScoreTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final int maxScore;
  final Color color;
  final IconData icon;

  const _ScoreTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.maxScore,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (value / maxScore).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF757A85),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "$value / $maxScore",
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppRadius.lg,
            ),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              backgroundColor:
                  AppColors.outline.withValues(
                alpha: .20,
              ),
              valueColor:
                  AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationChip extends StatelessWidget {
  final String recommendation;

  const _RecommendationChip({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = SymbolUtils.toCompliantVerdict(recommendation);
    final Color color = _color(formatted);

    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .12,
        ),
        borderRadius: BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: color.withValues(alpha: .30),
        ),
      ),
      child: Text(
        formatted,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: .3,
          fontSize: 10.5,
        ),
      ),
    );
  }

  Color _color(String formattedRec) {
    final upper = formattedRec.toUpperCase();
    if (upper.contains("ROBUST") || upper.contains("ACCUMULATE") || upper.contains("OUTPERFORM") || upper == "BUY") {
      return const Color(0xFF4ADE80);
    }
    if (upper.contains("DIP") || upper.contains("WAIT FOR DIP")) {
      return const Color(0xFF38BDF8); // Cyan/blue
    }
    if (upper.contains("HIGH RISK") || upper.contains("FLAG") || upper.contains("AVOID") || upper.contains("SELL")) {
      return AppColors.danger;
    }
    if (upper.contains("TRIM") || upper.contains("BELOW HURDLE") || upper.contains("EXTENDED") || upper.contains("ELEVATED")) {
      return Colors.orange;
    }
    return AppColors.warning;
  }
}