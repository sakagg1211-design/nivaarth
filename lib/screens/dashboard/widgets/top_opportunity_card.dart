import 'package:flutter/material.dart';

import '../../../models/stock_score.dart';

class TopOpportunityCard extends StatelessWidget {
  final StockScore stock;

  const TopOpportunityCard({
    super.key,
    required this.stock,
  });

  Color get scoreColor {
    if (stock.overallScore >= 90) {
      return Colors.green;
    }

    if (stock.overallScore >= 75) {
      return Colors.lightGreen;
    }

    if (stock.overallScore >= 60) {
      return Colors.orange;
    }

    return Colors.red;
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
              "⭐ Top Opportunity",
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

            const SizedBox(height: 10),

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
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: infoTile(
                    "Business",
                    stock.businessQuality,
                  ),
                ),

                Expanded(
                  child: infoTile(
                    "Financial",
                    stock.financialStrength,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: infoTile(
                    "Growth",
                    stock.growth,
                  ),
                ),

                Expanded(
                  child: infoTile(
                    "Technical",
                    stock.technical,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: infoTile(
                    "Risk",
                    stock.risk,
                  ),
                ),

                Expanded(
                  child: infoTile(
                    "Confidence",
                    stock.confidence,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: scoreColor.withValues(
                  alpha: 0.12,
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

  Widget infoTile(
    String title,
    int value,
  ) {
    return Column(
      children: [

        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "$value",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

      ],
    );
  }
}