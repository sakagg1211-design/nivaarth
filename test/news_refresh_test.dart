import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/providers/news_provider.dart';

void main() {
  test('holdings news refreshes at most every 15 minutes with the dashboard', () {
    final t = DateTime(2026, 11, 20, 10, 0);
    expect(newsRefreshDue(t, t.add(const Duration(minutes: 2))), isFalse);
    expect(newsRefreshDue(t, t.add(const Duration(minutes: 15))), isTrue);
  });
}
