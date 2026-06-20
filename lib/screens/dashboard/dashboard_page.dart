import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard_provider.dart';
import 'widgets/ai_verdict_card.dart';
import 'widgets/top_opportunity_card.dart';
import 'widgets/weakest_holding_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("NIVAARTH"),
        centerTitle: true,
      ),
      body: dashboard.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(e.toString()),
        ),
        data: (data) {
          final isProfit = data.totalPnL >= 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                //----------------------------------
                // Portfolio Health
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
                          "Portfolio Health",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          "${data.portfolioHealth.toStringAsFixed(0)}/100",
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                            data.aiRecommendation.summary,
                           textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //----------------------------------
                // Summary
                //----------------------------------

                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        buildRow(
                          "Stocks",
                          data.totalStocks.toString(),
                        ),

                        buildRow(
                          "Invested",
                          "₹${data.totalInvested.toStringAsFixed(2)}",
                        ),

                        buildRow(
                          "Current Value",
                          "₹${data.currentValue.toStringAsFixed(2)}",
                        ),

                        buildRow(
                          "Net P&L",
                          "${isProfit ? "+" : ""}₹${data.totalPnL.toStringAsFixed(2)}",
                          color: isProfit
                              ? Colors.green
                              : Colors.red,
                        ),

                        buildRow(
                          "Return",
                          "${data.returnPercent.toStringAsFixed(2)} %",
                          color: isProfit
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //----------------------------------
                // Biggest Winner
                //----------------------------------

                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.trending_up),
                    ),
                    title: const Text(
                      "Biggest Winner",
                    ),
                    subtitle: Text(
                      data.biggestWinner
                          .portfolio.instrument,
                    ),
                    trailing: Text(
                      "${data.biggestWinner.returnPercent.toStringAsFixed(2)}%",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                //----------------------------------
                // Biggest Loser
                //----------------------------------

                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child:
                          Icon(Icons.trending_down),
                    ),
                    title: const Text(
                      "Biggest Loser",
                    ),
                    subtitle: Text(
                      data.biggestLoser
                          .portfolio.instrument,
                    ),
                    trailing: Text(
                      "${data.biggestLoser.returnPercent.toStringAsFixed(2)}%",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                 //----------------------------------
                // AI Section
                //----------------------------------

                const SizedBox(height: 20),

                AIVerdictCard(
                  ai: data.aiRecommendation,
                ),

                const SizedBox(height: 20),

                TopOpportunityCard(
                  stock: data.topOpportunity,
                ),

                const SizedBox(height: 20),

                WeakestHoldingCard(
                  stock: data.weakestHolding,
                ),
                 ],
            ),
          );
        },
      ),
    );
  }

  Widget buildRow(
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
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}