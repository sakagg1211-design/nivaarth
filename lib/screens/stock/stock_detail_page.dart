import 'package:flutter/material.dart';

import '../../models/stock_score.dart';

class StockDetailPage extends StatelessWidget {
  final StockScore stock;

  const StockDetailPage({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stock.instrument),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              CircleAvatar(
                radius: 45,
                child: Text(
                  "${stock.overallScore}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                stock.instrument,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                stock.recommendation,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}