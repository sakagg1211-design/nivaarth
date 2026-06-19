import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/portfolio_provider.dart';

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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stocks.length,

            itemBuilder: (context, index) {
              final stock = stocks[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),

                child: ListTile(
                  contentPadding:
                      const EdgeInsets.all(16),

                  title: Text(
                    stock.instrument,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Qty : ${stock.qty}",
                        ),

                        Text(
                          "Avg Price : ₹${stock.avgPrice.toStringAsFixed(2)}",
                        ),

                        Text(
                          "Invested : ₹${stock.totalInvested.toStringAsFixed(2)}",
                        ),

                      ],
                    ),
                  ),

                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}