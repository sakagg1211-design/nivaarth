import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/formatters.dart';
import 'package:mobile/screens/stock/widgets/chart_selector.dart';
import 'package:mobile/screens/stock/widgets/stock_header.dart';

double _contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (x > y ? x + .05 : y + .05) / (x > y ? y + .05 : x + .05);
}

void main() {
  group('theme', () {
    final t = AppTheme.darkTheme;

    test('snackbar text can be read on its background', () {
      expect(_contrast(t.snackBarTheme.backgroundColor!, t.snackBarTheme.contentTextStyle!.color!), greaterThan(4.5));
    });
    test('default text is light, because every surface is dark', () {
      expect(t.brightness, Brightness.dark);
      expect(_contrast(t.colorScheme.onSurface, AppColors.surface), greaterThan(4.5));
    });
    test('the faintest text colour still meets 4.5:1 on a card', () {
      expect(_contrast(AppColors.textTertiary, AppColors.surface), greaterThan(4.5));
    });
  });

  test('rupees use Indian grouping', () {
    expect(Formatters.currency(121050), '₹1,21,050.00');
  });

  Widget host(Widget child, {double width = 320}) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: Center(child: SizedBox(width: width, child: child))),
      );

  testWidgets('all six chart ranges fit on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? picked;
    await tester.pumpWidget(host(ChartSelector(selectedRange: '1D', onChanged: (v) => picked = v), width: 280));
    for (final r in ['1D', '1W', '1M', '3M', '1Y', 'ALL']) {
      expect(find.text(r), findsOneWidget);
    }
    await tester.tap(find.text('ALL'));
    expect(picked, 'ALL');
    expect(tester.takeException(), isNull);
  });

  group('stock header in Privacy Mode', () {
    Widget header(bool hide) => host(
          StockHeader(
            instrument: 'TCS',
            companyName: 'TCS',
            status: 'PORTFOLIO',
            currentPrice: 2475.4,
            netPL: 11390,
            returnPercent: 9.41,
            isProfit: true,
            todayPL: 556.25,
            todayReturnPercent: 0.42,
            hideMoney: hide,
          ),
          width: 380,
        );

    testWidgets('profit in rupees is hidden, the public price stays', (tester) async {
      await tester.pumpWidget(header(true));
      expect(find.textContaining('₹11,390'), findsNothing);
      expect(find.textContaining('₹556'), findsNothing);
      expect(find.textContaining('••••'), findsNWidgets(2));
      expect(find.textContaining('₹2,475.40'), findsOneWidget);
    });

    testWidgets('shown normally when Privacy Mode is off', (tester) async {
      await tester.pumpWidget(header(false));
      expect(find.textContaining('₹11,390'), findsOneWidget);
    });
  });
}
