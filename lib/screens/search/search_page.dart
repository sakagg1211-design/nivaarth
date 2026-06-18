import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/search_provider.dart';
import '../stock/stock_detail_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(searchProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Stocks"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              decoration: const InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
              ),

              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: result.when(

                loading: () =>
                    const Center(
                      child: CircularProgressIndicator(),
                    ),

                error: (e, _) =>
                    Center(
                      child: Text(e.toString()),
                    ),

                data: (stocks) {

                  if (query.isEmpty) {
                    return const Center(
                      child: Text(
                        "Search any stock",
                      ),
                    );
                  }

                  if (stocks.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Stock Found",
                      ),
                    );
                  }

                  return ListView.builder(

                    itemCount: stocks.length,

                    itemBuilder: (context, index) {

                      final stock = stocks[index];

                      return Card(

                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (_) => StockDetailPage(
                            stock: stock,
        ),
      ),
    );
  },

                          title: Text(stock.instrument),

                          subtitle:
                              Text(stock.recommendation),

                          trailing: Text(
                            "${stock.overallScore}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        ),

                      );

                    },

                  );

                },

              ),
            ),
          ],
        ),
      ),
    );
  }
}