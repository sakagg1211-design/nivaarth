import 'package:flutter/material.dart';

import '../../models/live_portfolio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stock_score.dart';
import '../../providers/stock_score_provider.dart';
class StockDetailPage extends ConsumerWidget {
  final LivePortfolio stock;

  const StockDetailPage({
    super.key,
    required this.stock,
  });

  @override
  Widget build(
  BuildContext context,
  WidgetRef ref,
) {
    final portfolio = stock.portfolio;

final double currentValue = stock.currentValue;
final double netPL = stock.netPL;
final bool isProfit = netPL >= 0;
    final scoreAsync = ref.watch(
  stockScoreProvider(
    portfolio.instrument,
)
);

    final double returnPercent = portfolio.totalInvested == 0
        ? 0.0
        : (netPL / portfolio.totalInvested) * 100.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(portfolio.instrument),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            //-----------------------------------
            // HEADER
            //-----------------------------------

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    CircleAvatar(
                      radius: 35,
                      child: Text(
                        portfolio.instrument.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      portfolio.instrument,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      portfolio.companyName.isEmpty
                          ? "Company Name Coming Soon"
                          : portfolio.companyName,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Chip(
                      label: Text(portfolio.status),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //-----------------------------------
            // HOLDING DETAILS
            //-----------------------------------

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Holding Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    buildRow(
                      "Quantity",
                      portfolio.qty.toString(),
                    ),

                    buildRow(
                      "Average Price",
                      "₹${portfolio.avgPrice.toStringAsFixed(2)}",
                    ),

                    buildRow(
                      "Invested",
                      "₹${portfolio.totalInvested.toStringAsFixed(2)}",
                    ),

                    buildRow(
                      "Current Value",
                      "₹${currentValue.toStringAsFixed(2)}",
                    ),

                    buildRow(
                      "Net P&L",
                      "${isProfit ? "+" : ""}₹${netPL.toStringAsFixed(2)}",
                      color:
                          isProfit ? Colors.green : Colors.red,
                    ),

                    buildRow(
                      "Return",
                      "${returnPercent.toStringAsFixed(2)} %",
                      color:
                          isProfit ? Colors.green : Colors.red,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //-----------------------------------
            // COMPANY
            //-----------------------------------

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Company Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    buildRow(
                      "Sector",
                      portfolio.sector.isEmpty
                          ? "--"
                          : portfolio.sector,
                    ),

                    buildRow(
                      "Industry",
                      portfolio.industry.isEmpty
                          ? "--"
                          : portfolio.industry,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //-----------------------------------
            // THESIS
            //-----------------------------------

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Investment Thesis",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      portfolio.investmentThesis.isEmpty
                          ? "No investment thesis available."
                          : portfolio.investmentThesis,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //-----------------------------------
            // AI
            //-----------------------------------

            Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  child: Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Row(
          children: [

            Icon(
              Icons.psychology,
              color: Colors.blue,
            ),

            SizedBox(width: 8),

            Text(
              "AI Analysis",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),

        const SizedBox(height: 20),

        scoreAsync.when(
  data: (score) {
    if (score == null) {
      return buildRow(
        "AI Score",
        "N/A",
      );
    }

    Color scoreColor;

if (score.overallScore >= 80) {
  scoreColor = Colors.green;
} else if (score.overallScore >= 60) {
  scoreColor = Colors.lightBlue;
} else if (score.overallScore >= 40) {
  scoreColor = Colors.orange;
} else {
  scoreColor = Colors.red;
}

return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    buildRow(
      "AI Score",
      "${score.overallScore}/100",
      color: scoreColor,
    ),

    const SizedBox(height: 8),

    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: score.overallScore / 100,
        minHeight: 6,
        valueColor: AlwaysStoppedAnimation(scoreColor),
        backgroundColor: Colors.grey.shade800,
      ),
    ),

  ],
);
  },
  loading: () => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: LinearProgressIndicator(),
  ),
  error: (_, __) => buildRow(
    "AI Score",
    "Error",
  ),
),

        scoreAsync.when(
  data: (score) {
    if (score == null) {
      return buildRow(
        "Recommendation",
        "N/A",
      );
    }

    Color color = Colors.orange;

    switch (score.recommendation.toUpperCase()) {
      case "STRONG BUY":
      case "BUY":
        color = Colors.green;
        break;

      case "SELL":
      case "REDUCE":
        color = Colors.red;
        break;

      default:
        color = Colors.orange;
    }

    return Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [

    const Text(
      "Recommendation",
      style: TextStyle(
        fontSize: 16,
      ),
    ),

    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
        ),
      ),
      child: Text(
        score.recommendation,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

  ],
);
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => buildRow(
    "Recommendation",
    "Error",
  ),
),

        scoreAsync.when(
  data: (score) {
    if (score == null) {
      return buildRow(
        "Confidence",
        "N/A",
      );
    }

    return buildRow(
      "Confidence",
      "${score.confidence}%",
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => buildRow(
    "Confidence",
    "Error",
  ),
),

        const Divider(height: 30),
        scoreAsync.when(
  data: (score) {
    if (score == null) {
      return buildRow(
        "Business Quality",
        "N/A",
      );
    }

    return buildRow(
      "Business Quality",
      "${score.businessQuality}/25",
      color: metricColor(
        score.businessQuality,
        25,
      ),
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => buildRow(
    "Business Quality",
    "Error",
  ),
),

        scoreAsync.when(
  data: (score) {
    if (score == null) {
      return buildRow(
        "Financial Strength",
        "N/A",
      );
    }

    return buildRow(
      "Financial Strength",
      "${score.financialStrength}/25",
      color: metricColor(
        score.financialStrength,
        25,
      ),
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => buildRow(
    "Financial Strength",
    "Error",
  ),
),

       scoreAsync.when(
  data: (score) {
    if (score == null) {
      return buildRow(
        "Growth",
        "N/A",
      );
    }

    return buildRow(
      "Growth",
      "${score.growth}/20",
      color: metricColor(
        score.growth,
        20,
      ),
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => buildRow(
    "Growth",
    "Error",
  ),
),

        scoreAsync.when(
  data: (score) {
    if (score == null) {
      return buildRow(
        "Valuation",
        "N/A",
      );
    }

    return buildRow(
      "Valuation",
      "${score.valuation}/15",
      color: metricColor(
        score.valuation,
        15,
      ),
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => buildRow(
    "Valuation",
    "Error",
  ),
),

        scoreAsync.when(
  data: (score) {
    if (score == null) {
      return buildRow(
        "Technical",
        "N/A",
      );
    }

    return buildRow(
      "Technical",
      "${score.technical}/10",
      color: metricColor(
        score.technical,
        10,
      ),
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => buildRow(
    "Technical",
    "Error",
  ),
),

        scoreAsync.when(
  data: (score) {
    if (score == null) {
      return buildRow(
        "Risk",
        "N/A",
      );
    }

    return buildRow(
      "Risk",
      "${score.risk}/5",
      color: metricColor(
        score.risk,
        5,
      ),
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => buildRow(
    "Risk",
    "Error",
  ),
),
        const SizedBox(height: 25),

        const Text(
          "Suggested Actions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),

        const SizedBox(height: 12),

        scoreAsync.when(
  data: (score) {
    if (score == null) {
      return const Text("No AI recommendation available.");
    }

    List<String> actions;

    switch (score.recommendation.toUpperCase()) {
      case "BUY":
      case "STRONG BUY":
        actions = [
          "Accumulate on market dips",
          "Hold for long term",
          "Review after quarterly results",
        ];
        break;

      case "HOLD":
        actions = [
          "Continue holding",
          "Monitor quarterly results",
          "Avoid emotional selling",
        ];
        break;

      case "REDUCE":
        actions = [
          "Avoid fresh buying",
          "Review business performance",
          "Reduce on strong rallies",
        ];
        break;

      case "SELL":
        actions = [
          "Exit on strength",
          "Reallocate capital",
          "Avoid averaging down",
        ];
        break;

      default:
        actions = [
          "Review latest financials",
        ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text("• $e"),
            ),
          )
          .toList(),
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => const SizedBox.shrink(),
),

      ],
    ),
  ),
),

          ],
        ),
      ),
    );
  }

  Color metricColor(int value, int max) {
    final percent = value / max;
    if (percent >= 0.80) return Colors.green;
    if (percent >= 0.60) return Colors.lightBlue;
    if (percent >= 0.40) return Colors.orange;
    return Colors.red;
  }


  Widget buildRow(
    String title,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }
}