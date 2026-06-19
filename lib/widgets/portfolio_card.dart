import 'package:flutter/material.dart';

import '../models/portfolio.dart';
import '../screens/stock/stock_detail_page.dart';

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

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

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

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              //--------------------
              // Header
              //--------------------

              Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          stock.instrument,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        if (stock.companyName.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(
                                    top: 4),
                            child: Text(
                              stock.companyName,
                              style: TextStyle(
                                color: Colors
                                    .grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                ],
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 8,
                children: [

                  if (stock.status.isNotEmpty)
                    Chip(
                      label: Text(stock.status),
                    ),

                  if (stock.sector.isNotEmpty)
                    Chip(
                      label: Text(stock.sector),
                    ),

                ],
              ),

              const SizedBox(height: 15),

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

              const Divider(height: 30),

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
    );
  }

  Widget buildRow(
    String title,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 5),

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