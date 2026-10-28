import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Plain-language explanation of how the NV Score is built. Every rule here mirrors
/// backend/ai_scoring_service.py; change both together.
class ScoreMethodologyPage extends StatelessWidget {
  const ScoreMethodologyPage({super.key});

  static const double _maxTextWidth = 860;

  @override
  Widget build(BuildContext context) {
    // Keep lines readable on wide screens; padding (not a box) so the whole page still scrolls.
    final width = MediaQuery.sizeOf(context).width;
    final side = width > _maxTextWidth + 2 * AppSpacing.lg
        ? (width - _maxTextWidth) / 2
        : AppSpacing.lg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('How the NV Score works'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(side, AppSpacing.sm, side, AppSpacing.xxl),
        children: const [
          _Section(
            title: 'What the score is',
            body: 'A 0-100 score built only from published numbers: return on capital, debt, cash flow, '
                'valuation and price trend. The same rules apply to every stock, and no person picks '
                'or adjusts a score. It describes a company\'s financial profile; it is not a forecast '
                'and not a buy or sell call.',
          ),
          _Section(
            title: 'Score bands',
            rows: [
              _Row('85 - 100', 'Excellent: strong on most measures'),
              _Row('70 - 84', 'Strong'),
              _Row('55 - 69', 'Average'),
              _Row('0 - 54', 'Weak: below the quality hurdle, or a risk flag'),
            ],
          ),
          _Section(
            title: 'Three pillars',
            body: 'The overall score is a weighted mix. If a pillar has no data it is left out and '
                'its weight is shared by the others; it is never filled with a guessed value.',
            rows: [
              _Row('Quality  50%', 'Return on capital (ROCE, or ROE for banks) 50, debt to equity 30, '
                  'operating cash flow vs profit 20'),
              _Row('Valuation  30%', 'P/E compared with sector peers 60, earnings yield vs the 10-year '
                  'government bond (7%) 40'),
              _Row('Momentum  20%', 'Price vs 50 and 200 day averages 50, RSI 30, MACD 20'),
            ],
          ),
          _Section(
            title: 'Quality hurdle',
            body: 'When the quality pillar is below 55, the overall score is scaled down in proportion '
                '(never below 40% of its value). A cheap stock with weak returns on capital cannot '
                'score high. If quality data is missing it is currently counted as neutral (50).',
          ),
          _Section(
            title: 'Risk flags',
            body: 'Any of these caps the score at 28 and shows HIGH RISK FLAG, whatever the other '
                'numbers say:',
            rows: [
              _Row('Pledge', '75% or more of promoter shares pledged, or pledged shares at 25% or more '
                  'of the company'),
              _Row('Net worth', 'Zero or negative shareholder equity'),
              _Row('Debt', 'A negative debt-to-equity figure (a data anomaly)'),
            ],
          ),
          _Section(
            title: 'Special cases',
            rows: [
              _Row('Banks, NBFCs, brokers', 'Capped at 75 until loan-quality and credit data are added. '
                  'A "provisional" badge shows on these.'),
              _Row('Insurance, holding companies, REITs / InvITs', 'No score. Their accounts do not fit '
                  'these ratios; they need embedded value, NAV or yield instead.'),
              _Row('ETFs', 'Valuation is set to a neutral 60.'),
              _Row('Data under review', 'No score when our stored fundamentals fail a check against exchange '
                  'data (market cap or price of a different company). It returns once the data is corrected.'),
            ],
          ),
          _Section(
            title: 'Labels',
            rows: [
              _Row('HIGH STRENGTH PROFILE', 'Quality 70+, valuation 65+, positive trend'),
              _Row('CONSOLIDATION', 'Quality 70+, valuation 65+, weak trend'),
              _Row('FAIR VALUE / CORE', 'Quality 70+, valuation 35-64'),
              _Row('EXTENDED VALUE', 'Quality 70+, valuation below 35, positive trend'),
              _Row('ELEVATED VALUATION', 'Quality 70+, valuation below 35, weak trend'),
              _Row('NEUTRAL / WATCH', 'Quality 55-69'),
              _Row('BELOW HURDLE', 'Quality below 55'),
              _Row('NEGATIVE EARNINGS', 'Quality 70+, but the company is loss-making'),
              _Row('MOMENTUM / VALUATION UNAVAILABLE', 'Quality 70+, but price-trend or valuation data is missing'),
              _Row('UNCONFIRMED RISK', 'Pledge data is missing, so the risk check could not run'),
              _Row('DATA PENDING', 'Not enough data to score yet'),
            ],
          ),
          _Section(
            title: 'Data and freshness',
            body: 'Fundamentals come from a dataset compiled from companies\' published results; where a '
                'figure is missing, debt, '
                'cash flow and margin are taken from Yahoo Finance. Prices come from Yahoo Finance and '
                'can be delayed. Scores are recalculated every night. Data can be incomplete or wrong; '
                'check the company\'s filings before relying on any number.',
          ),
          _Section(
            title: 'Important',
            body: 'Nivaarth is a research and education tool. It is not registered with SEBI as an '
                'investment adviser or research analyst, and nothing in the app is a recommendation '
                'to buy, sell or hold any security. Please do your own research or consult a '
                'registered adviser before investing.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? body;
  final List<_Row> rows;

  const _Section({required this.title, this.body, this.rows = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800)),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(body!, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.45)),
          ],
          for (final row in rows) ...[
            const SizedBox(height: AppSpacing.md),
            row,
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String text;

  const _Row(this.label, this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.inkSoft, height: 1.4)),
      ],
    );
  }
}
