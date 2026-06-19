import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/portfolio_provider.dart';
import '../../widgets/portfolio_card.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Portfolio"),
        centerTitle: true,
      ),
      body: portfolio.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) =>
            Center(child: Text(e.toString())),

        data: (stocks) {
          if (stocks.isEmpty) {
            return const Center(
              child: Text("Portfolio is Empty"),
            );
          }

          double totalInvested = 0;

          for (final stock in stocks) {
            totalInvested += stock.totalInvested;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [

                          Column(
                            children: [
                              const Text("Stocks"),
                              Text(
                                "${stocks.length}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              const Text("Invested"),
                              Text(
                                "₹${totalInvested.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
            ),
          );
        },
      ),
    );
  }
}