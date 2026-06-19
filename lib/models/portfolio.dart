class Portfolio {
  final String id;
  final String instrument;
  final String companyName;
  final String yahooSymbol;

  final int qty;
  final double avgPrice;
  final double totalInvested;

  final String sector;
  final String industry;
  final String status;
  final String investmentThesis;

  Portfolio({
    required this.id,
    required this.instrument,
    required this.companyName,
    required this.yahooSymbol,
    required this.qty,
    required this.avgPrice,
    required this.totalInvested,
    required this.sector,
    required this.industry,
    required this.status,
    required this.investmentThesis,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json["id"]?.toString() ?? "",

      instrument: json["Instrument"]?.toString() ?? "",

      companyName: json["Company_name"]?.toString() ?? "",

      yahooSymbol: json["YahooSymbol"]?.toString() ?? "",

      qty: (json["Qty"] as num?)?.toInt() ?? 0,

      avgPrice: (json["Avg Price"] as num?)?.toDouble() ?? 0,

      totalInvested:
          (json["Total Invested"] as num?)?.toDouble() ?? 0,

      sector: json["Sector"]?.toString() ?? "",

      industry: json["Industry"]?.toString() ?? "",

      status: json["Status"]?.toString() ?? "",

      investmentThesis:
          json["Investment_thesis"]?.toString() ?? "",
    );
  }
}