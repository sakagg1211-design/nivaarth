import 'package:flutter/material.dart';

import '../../../models/ai_recommendation.dart';

class AIVerdictCard extends StatelessWidget {
  final AIRecommendation ai;

  const AIVerdictCard({
    super.key,
    required this.ai,
  });

  Color get color {
    switch (ai.recommendation) {
      case RecommendationType.strongBuy:
        return Colors.green;

      case RecommendationType.buy:
        return Colors.green;

      case RecommendationType.accumulate:
        return Colors.blue;

      case RecommendationType.hold:
        return Colors.orange;

      case RecommendationType.reduce:
        return Colors.deepOrange;

      case RecommendationType.sell:
        return Colors.red;
    }
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
              "🤖 AI Verdict",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              ai.title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 10),

            Text(ai.summary),

            const SizedBox(height: 15),

            Row(
              children: [

                const Text(
                  "Confidence",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const Spacer(),

                Text(
                  "${ai.confidence}%",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 18),

            const Text(
              "Reasons",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...ai.reasons.map(
              (e) => Padding(
                padding:
                    const EdgeInsets.only(
                        bottom: 6),
                child: Text("• $e"),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...ai.actions.map(
              (e) => Padding(
                padding:
                    const EdgeInsets.only(
                        bottom: 6),
                child: Text("✓ $e"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}