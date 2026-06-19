import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../portfolio/portfolio_page.dart';

import '../../providers/stock_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../login/login_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocks = ref.watch(stockScoresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("NIVAARTH"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: stocks.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Text("No Data Found"),
            );
          }

          final top = data.first;

          final averageScore =
              data.map((e) => e.overallScore).reduce((a, b) => a + b) /
                  data.length;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SearchBarWidget(),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: "Stocks",
                        value: "${data.length}",
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: DashboardCard(
                        title: "Top Score",
                        value: "${top.overallScore}",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                DashboardCard(
                  title: "Portfolio Health",
                  value:
                      "${averageScore.toStringAsFixed(1)}/100",
                ),
                const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.account_balance_wallet),
    label: const Text("Open Portfolio"),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PortfolioPage(),
        ),
      );
    },
  ),
),
                const SizedBox(height: 30),

                const Text(
                  "Top Ranked Stock",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(18),

                    title: Text(
                      top.instrument,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding:
                          const EdgeInsets.only(top: 8),
                      child: Text(
                        top.recommendation,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),

                    trailing: CircleAvatar(
                      radius: 28,
                      child: Text(
                        "${top.overallScore}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}