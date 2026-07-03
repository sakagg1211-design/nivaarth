import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class StockHeader extends StatelessWidget {
  final String instrument;
  final String companyName;
  final String status;

  final double currentPrice;
  final double netPL;
  final double returnPercent;

  final bool isProfit;

  const StockHeader({
    super.key,
    required this.instrument,
    required this.companyName,
    required this.status,
    required this.currentPrice,
    required this.netPL,
    required this.returnPercent,
    required this.isProfit,
  });

  @override
  Widget build(BuildContext context) {

    final Color gainColor =
        isProfit
            ? AppColors.success
            : AppColors.danger;

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(26),

      decoration: BoxDecoration(

        borderRadius:
            BorderRadius.circular(30),

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

                height: 68,
                width: 68,

                decoration: BoxDecoration(

                  color: Colors.white.withValues(
                    alpha: .06,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),

                child: Center(

                  child: Text(

                    instrument.isEmpty
                        ? "-"
                        : instrument[0],

                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 18,
              ),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      instrument,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTypography.titleLarge
                              .copyWith(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      companyName.isEmpty
                          ? "Company"
                          : companyName,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTypography.bodySmall
                              .copyWith(
                        color:
                            Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
                            Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
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
                          size: 8,
                          color:
                              AppColors.success,
                        ),

                        SizedBox(width: 6),

                        Text(
                          "LIVE",
                          style: TextStyle(
                            color: AppColors
                                .success,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: .06,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: IconButton(
                      splashRadius: 20,
                      padding:
                          EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.star_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 28,
          ),

          Text(
            _money(currentPrice),
            style: AppTypography
                .displaySmall
                .copyWith(
              color: Colors.white,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
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
              "${_money(netPL, signed: true)}   (${_percent(returnPercent, signed: true)})",
              style: AppTypography
                  .bodyMedium
                  .copyWith(
                color: gainColor,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          Row(
            children: [
                            Expanded(
                child: _HeaderMetric(
                  title: "Exchange",
                  value: status.isEmpty
                      ? "NSE"
                      : status,
                ),
              ),

              Expanded(
                child: _HeaderMetric(
                  title: "Trend",
                  value: isProfit
                      ? "Bullish"
                      : "Bearish",
                ),
              ),

              Expanded(
                child: _HeaderMetric(
                  title: "Portfolio",
                  value: "Holding",
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
      margin: const EdgeInsets.only(
        right: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: .05,
        ),
        borderRadius: BorderRadius.circular(
          16,
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

          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white60,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}