import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/live_portfolio_provider.dart';
import '../../widgets/portfolio_card.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(livePortfolioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Portfolio"),
        centerTitle: true,
      ),
      body: portfolio.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (stocks) {
          if (stocks.isEmpty) {
            return const Center(
              child: Text(
                "Portfolio is Empty",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          double totalInvested = 0;
          double totalCurrentValue = 0;
          double totalPnL = 0;

          for (final stock in stocks) {
            totalInvested += stock.portfolio.totalInvested;
            totalCurrentValue += stock.currentValue;
            totalPnL += stock.netPL;
          }

          final totalReturn =
              totalInvested == 0
                  ? 0
                  : (totalPnL / totalInvested) * 100;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                //----------------------------------
                // Summary Card
                //----------------------------------

                Card(
                  elevation: 4,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),

                    child: Column(
                      children: [

                        const Text(
                          "Portfolio Summary",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        buildSummaryRow(
                          "Stocks",
                          stocks.length.toString(),
                        ),

                        buildSummaryRow(
                          "Invested",
                          "₹${totalInvested.toStringAsFixed(2)}",
                        ),

                        buildSummaryRow(
                          "Current Value",
                          "₹${totalCurrentValue.toStringAsFixed(2)}",
                        ),

                        buildSummaryRow(
                          "Net P&L",
                          "${totalPnL >= 0 ? "+" : ""}₹${totalPnL.toStringAsFixed(2)}",
                          color: totalPnL >= 0
                              ? Colors.green
                              : Colors.red,
                        ),

                        buildSummaryRow(
                          "Return",
                          "${totalReturn.toStringAsFixed(2)} %",
                          color: totalPnL >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Holdings",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: stocks.length,

                  itemBuilder: (context, index) {
                    return PortfolioCard(
                      stock: stocks[index],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildSummaryRow(
    String title,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6),

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
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}