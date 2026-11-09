import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/l10n/l10n_ext.dart';

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
        title: Text(context.t.aiHowWorks),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(side, AppSpacing.sm, side, AppSpacing.xxl),
        children: [
          _Section(
            title: context.t.mWhatTitle,
            body: context.t.mWhatBody,
          ),
          _Section(
            title: context.t.mBands,
            rows: [
              _Row('85 - 100', context.t.mBandExcellent),
              _Row('70 - 84', context.t.mBandStrong),
              _Row('55 - 69', context.t.mBandAverage),
              _Row('0 - 54', context.t.mBandWeak),
            ],
          ),
          _Section(
            title: context.t.mPillars,
            body: context.t.mPillarsBody,
            rows: [
              _Row('Quality  55%', context.t.mQualityBody),
              _Row('Valuation  30%', context.t.mValuationBody),
              _Row('Momentum  15%', context.t.mMomentumBody),
            ],
          ),
          _Section(
            title: context.t.breakdownHurdle,
            body: context.t.mHurdleBody,
          ),
          _Section(
            title: context.t.mMinData,
            body: context.t.mMinDataBody,
          ),
          _Section(
            title: context.t.mRiskFlags,
            body: context.t.mRiskBody,
            rows: [
              _Row(context.t.mPledge, context.t.mPledgeBody),
              _Row(context.t.mNetWorth, context.t.mNetWorthBody),
              _Row(context.t.mDebt, context.t.mDebtBody),
            ],
          ),
          _Section(
            title: context.t.mReviewed,
            body: context.t.mReviewedBody,
          ),
          _Section(
            title: context.t.mSpecial,
            rows: [
              _Row(context.t.mBanks, context.t.mBanksBody),
              _Row(context.t.mBrokers, context.t.mBrokersBody),
              _Row(context.t.mInsurance, context.t.mInsuranceBody),
              _Row('ETFs', context.t.mEtfsBody),
              _Row(context.t.mReview, context.t.mReviewBody),
            ],
          ),
          _Section(
            title: context.t.mLabels,
            rows: [
              _Row(context.t.mPositiveTrend, context.t.mPositiveBody),
              _Row('HIGH STRENGTH PROFILE', context.t.mHighStrength),
              _Row('CONSOLIDATION', context.t.mConsolidation),
              _Row('FAIR VALUE / CORE', context.t.mFair),
              _Row('EXTENDED VALUE', context.t.mExtended),
              _Row('ELEVATED VALUATION', context.t.mElevated),
              _Row('NEUTRAL / WATCH', context.t.mNeutral),
              _Row('BELOW HURDLE', context.t.mBelow),
              _Row('NEGATIVE EARNINGS', context.t.mNegative),
              _Row('MOMENTUM / VALUATION UNAVAILABLE', context.t.mUnavailable),
              _Row('UNCONFIRMED RISK', context.t.mUnconfirmed),
              _Row('DATA PENDING', context.t.mDataPending),
            ],
          ),
          _Section(
            title: context.t.mFreshness,
            body: context.t.mFreshnessBody,
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
