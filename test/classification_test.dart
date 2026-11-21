import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/symbol_utils.dart';
import 'package:mobile/screens/stock/widgets/investment_thesis_card.dart';

void main() {
  test('a holding row\'s default "General" / "Diversified" never shows as the sector or industry', () {
    expect(SymbolUtils.getSector('ZZUNKNOWN', dbSector: 'General'), isNot('General'));
    expect(SymbolUtils.getIndustry('ZZUNKNOWN', dbIndustry: 'Diversified'), 'Industry not available');
    expect(SymbolUtils.getIndustry('ZZUNKNOWN', dbIndustry: 'General'), 'Industry not available');
    expect(SymbolUtils.getIndustry('ZZUNKNOWN', dbIndustry: 'Luxury Goods'), 'Luxury Goods');
  });

  test('the thesis card shows only a thesis the user wrote', () {
    expect(InvestmentThesisCard.isUserWritten('Added manually via portfolio manager.'), isFalse);
    expect(InvestmentThesisCard.isUserWritten('  '), isFalse);
    expect(InvestmentThesisCard.isUserWritten('Strong brand, watching margins'), isTrue);
  });
}
