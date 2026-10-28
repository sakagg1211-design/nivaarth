import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/screens/dashboard/widgets/portfolio_hero_card.dart';

void main() {
  // 28 Oct 2026, 3:13 PM IST = 09:43 UTC
  final lastRefresh = DateTime.utc(2026, 10, 28, 9, 43);

  test('during the session it shows the refresh time', () {
    expect(
      PortfolioHeroCard.asOfLabel(lastRefresh, isMarketOpen: true, now: DateTime.utc(2026, 10, 28, 9, 50)),
      'Prices as of 3:13 PM',
    );
  });

  test('after 3:30 PM it says market closed, not 3:13', () {
    expect(
      PortfolioHeroCard.asOfLabel(lastRefresh, isMarketOpen: false, now: DateTime.utc(2026, 10, 28, 12, 0)),
      "Market closed · today's closing prices",
    );
  });

  test('next morning before the open it names the closing day', () {
    expect(
      PortfolioHeroCard.asOfLabel(lastRefresh, isMarketOpen: false, now: DateTime.utc(2026, 10, 29, 2, 0)),
      'Market closed · closing prices of 28 Oct',
    );
  });

  test('no prices, no label', () {
    expect(PortfolioHeroCard.asOfLabel(null, isMarketOpen: false), isNull);
  });
}
