class PortfolioHealth {
  final double overall;

  final double business;

  final double financial;

  final double growth;

  final double valuation;

  final double technical;

  final double risk;

  final String status;

  final List<String> strengths;

  final List<String> weaknesses;

  const PortfolioHealth({
    required this.overall,
    required this.business,
    required this.financial,
    required this.growth,
    required this.valuation,
    required this.technical,
    required this.risk,
    required this.status,
    required this.strengths,
    required this.weaknesses,
  });
}