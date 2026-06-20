import 'package:flutter/material.dart';

import '../../../models/stock_score.dart';

class WeakestHoldingCard extends StatelessWidget {
  final StockScore stock;

  const WeakestHoldingCard({
    super.key,
    required this.stock,
  });

  Color get scoreColor {
    if (stock.overallScore < 40) {
      return Colors.red;
    }

    if (stock.overallScore < 60) {
      return Colors.orange;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              "⚠ Weakest Holding",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              stock.companyName.isEmpty
                  ? stock.instrument
                  : stock.companyName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              stock.instrument,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                const Text("Overall Score"),

                const Spacer(),

                Text(
                  "${stock.overallScore}",
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: stock.overallScore / 100,
              borderRadius:
                  BorderRadius.circular(12),
              color: scoreColor,
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                chip(
                  "Business",
                  stock.businessQuality,
                ),

                chip(
                  "Financial",
                  stock.financialStrength,
                ),

                chip(
                  "Growth",
                  stock.growth,
                ),

                chip(
                  "Technical",
                  stock.technical,
                ),

                chip(
                  "Risk",
                  stock.risk,
                ),

                chip(
                  "Confidence",
                  stock.confidence,
                ),

              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: scoreColor.withValues(
                  alpha: .12,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  stock.recommendation,
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget chip(
    String title,
    int value,
  ) {
    return Chip(
      label: Text(
        "$title : $value",
      ),
    );
  }
}