import 'package:flutter/material.dart';

import '../models/portfolio.dart';

class PortfolioCard extends StatelessWidget {
  final Portfolio stock;

  const PortfolioCard({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final returnPercent = stock.totalInvested == 0
        ? 0
        : ((stock.netPL ?? 0) / stock.totalInvested) * 100;

    final isProfit = (stock.netPL ?? 0) >= 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Stock Name
            Text(
              stock.instrument,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (stock.companyName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  stock.companyName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [

                if (stock.sector.isNotEmpty)
                  Chip(
                    label: Text(stock.sector),
                  ),

                if (stock.status.isNotEmpty)
                  Chip(
                    backgroundColor: Colors.green.withOpacity(.15),
                    label: Text(stock.status),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            _row(
              "Quantity",
              stock.qty.toString(),
            ),

            _row(
              "Avg Price",
              "₹${stock.avgPrice.toStringAsFixed(2)}",
            ),

            _row(
              "Invested",
              "₹${stock.totalInvested.toStringAsFixed(2)}",
            ),

            const Divider(height: 28),
Text(
  "DEBUG: ${stock.currentValue} | ${stock.netPL}",
),
            _row(
              "Current Value",
              stock.currentValue == null
                  ? "--"
                  : "₹${stock.currentValue!.toStringAsFixed(2)}",
            ),

            _row(
              "Net P&L",
              stock.netPL == null
                  ? "--"
                  : "${isProfit ? "+" : ""}₹${stock.netPL!.toStringAsFixed(2)}",
              valueColor:
                  isProfit ? Colors.green : Colors.red,
            ),

            _row(
              "Return",
              stock.netPL == null
                  ? "--"
                  : "${returnPercent.toStringAsFixed(2)}%",
              valueColor:
                  isProfit ? Colors.green : Colors.red,
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  // Next Sprint
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}