import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../models/ai_recommendation.dart';

class AIBriefingCard extends StatelessWidget {
  final AIRecommendation ai;

  const AIBriefingCard({
    super.key,
    required this.ai,
  });

  Color get color {
    switch (ai.recommendation) {
      case RecommendationType.strongBuy:
      case RecommendationType.buy:
        return const Color(0xFF00E676);
      case RecommendationType.accumulate:
        return const Color(0xFF38BDF8);
      case RecommendationType.hold:
        return const Color(0xFFE5A93C);
      case RecommendationType.reduce:
        return const Color(0xFFFF9800);
      case RecommendationType.sell:
        return const Color(0xFFFF5252);
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidence = (ai.confidence / 100).clamp(0.0, 1.0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF282A30), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: AI Verdict + Sparkle icon + 92% Confidence pill
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF23252B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFE5A93C),
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'NV Verdict',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x1FE5A93C),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: const Color(0x33E5A93C)),
                ),
                child: Text(
                  '${ai.confidence}%',
                  style: const TextStyle(
                    color: Color(0xFFE5A93C),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Verdict Title e.g. "Portfolio Needs Attention"
          Text(
            ai.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle e.g. "Risk has increased significantly."
          Text(
            ai.summary,
            style: const TextStyle(
              color: Color(0xFF8E929B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 6,
              color: color,
              backgroundColor: const Color(0xFF23252B),
            ),
          ),

          const SizedBox(height: 18),

          // Reasons Section with lightning icons
          const Text(
            'Reasons',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          ...ai.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: const Color(0x1F38BDF8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        color: Color(0xFFC7CDD6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Actions Section with green check icons
          const Text(
            'Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          ...ai.actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: const Color(0x1F00E676),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Color(0xFF00E676),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(
                        color: Color(0xFFC7CDD6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}