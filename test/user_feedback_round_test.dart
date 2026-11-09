import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/allocation_math.dart';
import 'package:mobile/core/utils/risk_math.dart';
import 'package:mobile/repositories/portfolio_repository.dart';

void main() {
  group('portfolio P/E', () {
    test('is total value over total earnings, not an average of P/Es', () {
      // 100 at P/E 10 earns 10; 100 at P/E 50 earns 2; so 200 / 12
      final r = RiskMath.portfolioPe(const [
        RiskHolding('A', 100, 1, 'T', pe: 10),
        RiskHolding('B', 100, 1, 'T', pe: 50),
      ]);
      expect(r.pe, closeTo(16.67, 0.01));
      expect(r.excluded, 0);
      expect(r.coveragePct, 100);
    });
    test('loss-makers and ETFs are left out and counted', () {
      final r = RiskMath.portfolioPe(const [
        RiskHolding('A', 100, 1, 'T', pe: 20),
        RiskHolding('LOSS', 50, 1, 'T', pe: -4),
        RiskHolding('ETF', 50, 1, 'ETF'),
      ]);
      expect(r.pe, 20);
      expect(r.excluded, 2);
      expect(r.coveragePct, 50);
    });
    test('no earnings data gives no number', () {
      expect(RiskMath.portfolioPe(const [RiskHolding('A', 100, 1, 'T')]).pe, isNull);
      expect(RiskMath.portfolioPe(const []).pe, isNull);
    });
  });

  group('diversification score', () {
    List<AllocationSlice> sectors(List<double> values) =>
        AllocationMath.slices([for (var i = 0; i < values.length; i++) (group: 'S$i', value: values[i])]);

    test('money piled in one sector scores low however many sectors are held', () {
      expect(AllocationMath.diversificationScore(sectors([90, ...List.filled(9, 10 / 9)])), 15);
      expect(AllocationMath.diversificationScore(sectors([100])), 13);
    });
    test('an even spread over 8 sectors is full marks, and more does not exceed it', () {
      expect(AllocationMath.diversificationScore(sectors(List.filled(8, 1))), 100);
      expect(AllocationMath.diversificationScore(sectors(List.filled(12, 1))), 100);
    });
    test('four equal sectors is half way', () {
      expect(AllocationMath.diversificationScore(sectors(List.filled(4, 1))), 50);
    });
    test('the same sectors with a more even spread score higher', () {
      final skewed = AllocationMath.diversificationScore(sectors([70, 10, 10, 10]))!;
      final even = AllocationMath.diversificationScore(sectors([25, 25, 25, 25]))!;
      expect(even, greaterThan(skewed));
    });
    test('nothing held gives no score', () {
      expect(AllocationMath.diversificationScore(const []), isNull);
    });
  });

  group('company names', () {
    Map<String, dynamic> row(String sym, String? name) => {'Instrument': sym, 'Company_name': name};

    test('a blank name or a bare ticker counts as missing', () {
      expect(PortfolioRepository.missingName(row('UJJIVANSFB', null)), isTrue);
      expect(PortfolioRepository.missingName(row('UJJIVANSFB', '  ')), isTrue);
      expect(PortfolioRepository.missingName(row('TCS', 'tcs')), isTrue);
      expect(PortfolioRepository.missingName(row('TCS', 'Tata Consultancy')), isFalse);
    });
    test('fills only missing names and keeps a name the user has', () {
      final out = PortfolioRepository.withCompanyNames(
        [row('UJJIVANSFB', null), row('TCS', 'My TCS'), row('NEW', null)],
        {'UJJIVANSFB': 'Ujjivan Small Finance Bank Ltd.', 'TCS': 'Other'},
      );
      expect(out[0]['Company_name'], 'Ujjivan Small Finance Bank Ltd.');
      expect(out[1]['Company_name'], 'My TCS');
      expect(out[2]['Company_name'], isNull);
    });
  });
}
