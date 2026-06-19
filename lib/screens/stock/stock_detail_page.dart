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
    final bool isProfit = (stock.netPL ?? 0) >= 0;

    final double returnPercent =
        stock.totalInvested == 0
            ? 0
            : ((stock.netPL ?? 0) / stock.totalInvested) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.instrument),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //--------------------------
            // HEADER
            //--------------------------

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
                      radius: 38,
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
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      stock.companyName.isEmpty
                          ? "Company Name Coming Soon"
                          : stock.companyName,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),

                    Chip(
                      label: Text(stock.status),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //--------------------------
            // HOLDING DETAILS
            //--------------------------

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
                      "Holding Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

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
                      stock.currentValue == null
                          ? "--"
                          : "₹${stock.currentValue!.toStringAsFixed(2)}",
                    ),

                    buildRow(
                      "Net P&L",
                      stock.netPL == null
                          ? "--"
                          : "${isProfit ? "+" : ""}₹${stock.netPL!.toStringAsFixed(2)}",
                      color: isProfit
                          ? Colors.green
                          : Colors.red,
                    ),

                    buildRow(
                      "Return",
                      "${returnPercent.toStringAsFixed(2)} %",
                      color: isProfit
                          ? Colors.green
                          : Colors.red,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //--------------------------
            // COMPANY INFO
            //--------------------------

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

            //--------------------------
            // INVESTMENT THESIS
            //--------------------------

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

            //--------------------------
            // AI SECTION
            //--------------------------

            Card(
              color: Colors.blue.withOpacity(.08),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: const Padding(
                padding: EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "🤖 AI Analysis",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      "Coming in Sprint 8",
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