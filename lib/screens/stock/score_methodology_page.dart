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
                'growth, valuation and the 12-month price return. The same rules apply to every stock, and no person picks '
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
            body: 'The overall score is a weighted mix. If valuation or momentum has no data it is left '
                'out and its weight is shared by the others; it is never filled with a guessed value.',
            rows: [
              _Row('Quality  55%', 'Return on capital (ROCE) 40, debt to equity 25, operating cash flow '
                  'vs profit 15, 5-year sales and profit growth 20 (full marks at 20% a year sales and 25% '
                  'profit; shrinking scores 0). ROCE and debt count half on a fixed scale and half on the '
                  'rank among companies in the same industry (15 or more), else the same sector.'),
              _Row('Valuation  30%', 'P/E compared with companies in the same industry 50, P/E compared '
                  'with its own 5-year average 30 (0.6x or lower full marks, 0.85x half, 1.3x or higher none), '
                  'and P/E against 5-year profit growth (PEG) 20 (1 or lower full marks, 3 or higher none; growth '
                  'counted between 5% and 40% a year). A part with no data is left out. A loss-making company '
                  'scores 0. Companies that demerged a large business, or have no 5-year average, use the '
                  'earnings yield vs the 10-year government bond instead of their own average. Banks and NBFCs '
                  'use P/B: rank within banks or NBFCs 60, against their own 5-year average 40.'),
              _Row('Momentum  15%', 'Price return over the last 12 months, leaving out the latest month, '
                  'ranked against every scored stock (6 months for stocks listed under a year). RSI, '
                  'MACD and moving averages are shown for information and are not scored.'),
            ],
          ),
          _Section(
            title: 'Quality hurdle',
            body: 'When the quality pillar is below 55, the overall score is capped at 54. From quality 55 '
                'to 65 the cap rises step by step (about 4.6 points per quality point) and disappears at '
                '65, so a small change in quality never makes the score jump. A cheap stock or a strong '
                'price run cannot lift a weak business into the strong bands.',
          ),
          _Section(
            title: 'Minimum data',
            body: 'Quality needs at least 3 of its 4 inputs (return on capital, debt, cash flow, growth). '
                'With 2 inputs the overall score is capped at 60; with fewer, or without return on capital, '
                'no score is shown and the stock reads DATA PENDING. Missing inputs are never assumed.',
          ),
          _Section(
            title: 'Risk flags',
            body: 'Any of these caps the score at 28 and shows HIGH RISK FLAG, whatever the other '
                'numbers say:',
            rows: [
              _Row('Pledge', '75% or more of promoter shares pledged, or pledged shares at 25% or more '
                  'of the company'),
              _Row('Net worth', 'Zero or negative shareholder equity (held for review instead when the '
                  'price-to-book in the fundamentals dataset is positive)'),
              _Row('Debt', 'A negative debt-to-equity figure (a data anomaly)'),
            ],
          ),
          _Section(
            title: 'Reviewed pledges',
            body: 'Some large pledges are checked against exchange filings. When the promoter is a '
                'private-equity owner that pledged its stake for its own holding-company loan, the pledge '
                'is shown as a note and does not trigger the flag. Every other pledge follows the rule above.',
          ),
          _Section(
            title: 'Special cases',
            rows: [
              _Row('Banks and NBFCs', 'Quality is return on equity 30, return on assets 25, net interest '
                  'margin 15 (banks only), leverage 10 and growth 20. Loan quality (NPA) is not assessed yet, '
                  'so the score is capped at 75 and shows a "provisional" badge.'),
              _Row('Brokers', 'Debt is not scored (margin funding borrowings); capped at 75 with a '
                  '"provisional" badge.'),
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
              _Row('Positive trend', 'Momentum rank 50+. A stock already on the positive side keeps it '
                  'until the rank falls below 45; one on the weak side needs 55 to cross, so a label does '
                  'not flip on small daily moves.'),
              _Row('HIGH STRENGTH PROFILE', 'Quality 70+, valuation 65+, positive trend'),
              _Row('CONSOLIDATION', 'Quality 70+, valuation 65+, weak trend'),
              _Row('FAIR VALUE / CORE', 'Quality 70+, valuation 35-64'),
              _Row('EXTENDED VALUE', 'Quality 70+, valuation below 35, positive trend'),
              _Row('ELEVATED VALUATION', 'Quality 70+, valuation below 35, weak trend'),
              _Row('NEUTRAL / WATCH', 'Quality 55-69'),
              _Row('BELOW HURDLE', 'Quality below 55'),
              _Row('NEGATIVE EARNINGS', 'Quality 70+, but the company is loss-making'),
              _Row('MOMENTUM / VALUATION UNAVAILABLE', 'Quality 70+, but under 6 months of price history '
                  'or no valuation data'),
              _Row('UNCONFIRMED RISK', 'Pledge data is missing, so the risk check could not run'),
              _Row('DATA PENDING', 'Not enough data to score yet'),
            ],
          ),
          _Section(
            title: 'Data and freshness',
            body: 'Fundamentals come from a dataset compiled from companies\' published results; where a '
                'figure is missing, debt and '
                'cash flow are taken from Yahoo Finance; net worth, margins and bank balance-sheet figures '
                'come from Yahoo Finance. Closing prices come from the NSE '
                'daily bhavcopy; prices during market hours come from Yahoo Finance and can be delayed. '
                'Scores are recalculated after each trading day\'s close. Data can be incomplete or wrong; '
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
