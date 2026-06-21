import '../models/live_portfolio.dart';
import '../models/portfolio_health.dart';
import '../models/stock_score.dart';
import '../core/utils/symbol_utils.dart';

class PortfolioHealthEngine {
  const PortfolioHealthEngine();

  PortfolioHealth calculate(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    double overallWeighted = 0;
    double totalInvestment = 0;
    

    double business = 0;
    double financial = 0;
    double growth = 0;
    double valuation = 0;
    double technical = 0;
    double risk = 0;

    // Build lookup map once
    final Map<String, StockScore> scoreMap = {};

    for (final score in scores) {
      scoreMap[
        SymbolUtils.normalize(score.instrument)
      ] = score;
    }

    // Calculate weighted averages
    for (final holding in portfolio) {
      final investment = holding.portfolio.totalInvested;

      final StockScore? score = scoreMap[
        SymbolUtils.normalize(
          holding.portfolio.instrument,
        )
      ];

      if (score == null) {
        continue;
      }
      overallWeighted += score.overallScore * investment;
      totalInvestment += investment;

      business += score.businessQuality * investment;
      financial += score.financialStrength * investment;
      growth += score.growth * investment;
      valuation += score.valuation * investment;
      technical += score.technical * investment;
      risk += score.risk * investment;
    }

    if (totalInvestment == 0) {
      return const PortfolioHealth(
        overall: 0,
        business: 0,
        financial: 0,
        growth: 0,
        valuation: 0,
        technical: 0,
        risk: 0,
        status: "Unknown",
        strengths: [],
        weaknesses: [],
      );
    }
    business /= totalInvestment;
    financial /= totalInvestment;
    growth /= totalInvestment;
    valuation /= totalInvestment;
    technical /= totalInvestment;
    risk /= totalInvestment;

// Portfolio Health comes from weighted OverallScore
    final double overall =
    overallWeighted / totalInvestment;
    print("Overall Health : $overall");
    String status;

    if (overall >= 90) {
      status = "Excellent";
    } else if (overall >= 80) {
      status = "Strong";
    } else if (overall >= 70) {
      status = "Good";
    } else if (overall >= 60) {
      status = "Average";
    } else {
      status = "Weak";
    }

    final List<String> strengths = [];
    final List<String> weaknesses = [];

    if (business >= 20) {
      strengths.add("High quality businesses");
    }

    if (financial >= 20) {
      strengths.add("Strong financial position");
    }

    if (growth >= 16) {
      strengths.add("Healthy earnings growth");
    }

    if (valuation < 8) {
      weaknesses.add("Portfolio looks expensive");
    }

    if (technical < 5) {
      weaknesses.add("Weak technical momentum");
    }

    if (risk < 3) {
      weaknesses.add("Risk profile needs improvement");
    }

    return PortfolioHealth(
      overall: overall,
      business: business,
      financial: financial,
      growth: growth,
      valuation: valuation,
      technical: technical,
      risk: risk,
      status: status,
      strengths: strengths,
      weaknesses: weaknesses,
    );
  }
}