import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/screens/dashboard/widgets/portfolio_health_card.dart';

void main() {
  test('Live only during the NSE session (IST)', () {
    // 2026-10-29 is a Thursday
    expect(PortfolioHealthCard.isMarketOpenIst(DateTime.utc(2026, 10, 29, 4, 0)), isTrue); // 09:30 IST
    expect(PortfolioHealthCard.isMarketOpenIst(DateTime.utc(2026, 10, 29, 3, 30)), isFalse); // 09:00 IST
    expect(PortfolioHealthCard.isMarketOpenIst(DateTime.utc(2026, 10, 29, 10, 1)), isFalse); // 15:31 IST
    expect(PortfolioHealthCard.isMarketOpenIst(DateTime.utc(2026, 10, 31, 5, 0)), isFalse); // Saturday
  });

  test('status follows the score instead of a fixed placeholder', () {
    expect(PortfolioHealthCard.statusFor(48), 'Weak');
    expect(PortfolioHealthCard.statusFor(65), 'Average');
    expect(PortfolioHealthCard.statusFor(92), 'Excellent');
  });

  testWidgets('card shows the derived status and no monitoring claims', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: PortfolioHealthCard(healthScore: 48, action: '', dataCoverage: 93)),
    ));
    expect(find.text('Status: Weak'), findsOneWidget);
    expect(find.textContaining('Risk hedging'), findsNothing);
    expect(find.textContaining('actively tracking'), findsNothing);
  });
}
