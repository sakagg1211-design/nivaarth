import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class StockHeader extends StatelessWidget {
  final String instrument;
  final String companyName;
  final String status;

  final double currentPrice;
  final double netPL;
  final double returnPercent;

  final bool isProfit;
  final String? trend;
  final bool isSaved;
  final VoidCallback? onSaveToggle;

  const StockHeader({
    super.key,
    required this.instrument,
    required this.companyName,
    required this.status,
    required this.currentPrice,
    required this.netPL,
    required this.returnPercent,
    required this.isProfit,
    this.trend,
    this.isSaved = false,
    this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {

    final Color gainColor =
        isProfit
            ? AppColors.success
            : AppColors.danger;

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),

      decoration: BoxDecoration(

        borderRadius:
            BorderRadius.circular(28),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [

            Color(0xff20283B),

            Color(0xff111318),

          ],
        ),

        border: Border.all(
          color: Colors.white.withValues(
            alpha: .05,
          ),
        ),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withValues(
              alpha: .20,
            ),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),

        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                height: 52,
                width: 52,

                decoration: BoxDecoration(

                  color: Colors.white.withValues(
                    alpha: .06,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: Center(

                  child: Text(

                    instrument.isEmpty
                        ? "-"
                        : instrument[0],

                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        instrument,
                        maxLines: 1,
                        style:
                            AppTypography.titleLarge
                                .copyWith(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      companyName.isEmpty
                          ? "Company"
                          : companyName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTypography.bodySmall
                              .copyWith(
                        color:
                            Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success
                          .withValues(
                        alpha: .14,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: const [

                        Icon(
                          Icons.circle,
                          size: 7,
                          color:
                              AppColors.success,
                        ),

                        SizedBox(width: 5),

                        Text(
                          "LIVE",
                          style: TextStyle(
                            color: AppColors
                                .success,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: isSaved
                          ? const Color(0x33E5A93C)
                          : Colors.white.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      onPressed: onSaveToggle,
                      icon: Icon(
                        isSaved ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isSaved ? const Color(0xFFE5A93C) : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              currentPrice > 0 ? _money(currentPrice) : 'Syncing...',
              style: AppTypography
                  .displaySmall
                  .copyWith(
                color: Colors.white,
                fontWeight:
                    FontWeight.w900,
                fontSize: 32,
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color:
                    gainColor.withValues(
                  alpha: .12,
                ),
                borderRadius:
                    BorderRadius.circular(
                  50,
                ),
              ),
              child: Text(
                status == 'WATCHLIST' || status == 'DISCOVERY'
                    ? "Live Market Quote   (NSE)"
                    : "${_money(netPL, signed: true)}   (${_percent(returnPercent, signed: true)})",
                style: AppTypography
                    .bodyMedium
                    .copyWith(
                  color: gainColor,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          Row(
            children: [
              const Expanded(
                child: _HeaderMetric(
                  title: "Exchange",
                  value: "NSE",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderMetric(
                  title: "Trend",
                  value: trend != null && trend!.isNotEmpty
                      ? trend!
                      : (isProfit ? "Bullish" : "Neutral"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderMetric(
                  title: "Status",
                  value: status.isNotEmpty ? status : (isProfit ? "PORTFOLIO" : "WATCHLIST"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _money(
    num value, {
    bool signed = false,
  }) {
    final prefix =
        signed && value >= 0 ? "+" : "";

    return "$prefix₹${value.toStringAsFixed(2)}";
  }

  static String _percent(
    num value, {
    bool signed = false,
  }) {
    final prefix =
        signed && value >= 0 ? "+" : "";

    return "$prefix${value.toStringAsFixed(2)}%";
  }
}

class _HeaderMetric extends StatelessWidget {
  final String title;
  final String value;

  const _HeaderMetric({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: .05,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: .06,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
