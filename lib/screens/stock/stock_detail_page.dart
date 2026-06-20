import 'package:flutter/material.dart';

import '../../models/portfolio.dart';

class StockDetailPage extends StatelessWidget {
  final Portfolio stock;

  const StockDetailPage({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final double currentValue = stock.currentValue ?? 0.0;
    final double netPL = stock.netPL ?? 0.0;

    final bool isProfit = netPL >= 0;

    final double returnPercent = stock.totalInvested == 0
        ? 0.0
        : (netPL / stock.totalInvested) * 100.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.instrument),
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
                        stock.instrument.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      stock.instrument,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      stock.companyName.isEmpty
                          ? "Company Name Coming Soon"
                          : stock.companyName,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Chip(
                      label: Text(stock.status),
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
                      stock.qty.toString(),
                    ),

                    buildRow(
                      "Average Price",
                      "₹${stock.avgPrice.toStringAsFixed(2)}",
                    ),

                    buildRow(
                      "Invested",
                      "₹${stock.totalInvested.toStringAsFixed(2)}",
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
                      stock.sector.isEmpty
                          ? "--"
                          : stock.sector,
                    ),

                    buildRow(
                      "Industry",
                      stock.industry.isEmpty
                          ? "--"
                          : stock.industry,
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
                      stock.investmentThesis.isEmpty
                          ? "No investment thesis available."
                          : stock.investmentThesis,
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

        buildRow(
          "AI Score",
          "-- /100",
        ),

        buildRow(
          "Recommendation",
          "HOLD",
          color: Colors.orange,
        ),

        buildRow(
          "Confidence",
          "-- %",
        ),

        const Divider(height: 30),

        buildRow(
          "Business Quality",
          "-- /25",
        ),

        buildRow(
          "Financial Strength",
          "-- /25",
        ),

        buildRow(
          "Growth",
          "-- /20",
        ),

        buildRow(
          "Valuation",
          "-- /15",
        ),

        buildRow(
          "Technical",
          "-- /10",
        ),

        buildRow(
          "Risk",
          "-- /5",
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

        const Text("• Hold existing position"),

        const SizedBox(height: 6),

        const Text("• Buy on correction"),

        const SizedBox(height: 6),

        const Text("• Review after quarterly results"),

      ],
    ),
  ),
),

          ],
        ),
      ),
    );
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