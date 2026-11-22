import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Colours that stay fixed on purpose in both modes, with the reason.
const _exceptions = <String>{
  // file:literal
  // Blue / pink series and info colours read on both backgrounds; the advisor avatar gradient is brand.
  'screens/advisor/advisor_chat_page.dart:Color(0xFFB87B18)',
  'screens/dashboard/widgets/allocation_card.dart:Color(0xFF3987E5)',
  'screens/dashboard/widgets/allocation_card.dart:Color(0xFFD95926)',
  'screens/dashboard/widgets/allocation_card.dart:Color(0xFF199E70)',
  'screens/dashboard/widgets/allocation_card.dart:Color(0xFFC98500)',
  'screens/dashboard/widgets/allocation_card.dart:Color(0xFFD55181)',
  'screens/dashboard/widgets/allocation_card.dart:Color(0xFF008300)',
  'screens/dashboard/widgets/allocation_card.dart:Color(0xFF9085E9)',
  'screens/dashboard/widgets/allocation_card.dart:Color(0xFFE66767)',
  'screens/dashboard/widgets/dashboard_header.dart:Color(0x1F3B82F6)',
  'screens/dashboard/widgets/dashboard_header.dart:Color(0xFF3B82F6)',
  'screens/portfolio/widgets/investment_style_card.dart:Color(0xFF3987E5)',
  'screens/stock/widgets/stock_radar_card.dart:Color(0xFF3987E5)',
  'widgets/legal_disclaimer_sheet.dart:Color(0xFF3B82F6)',
  // Heatmap and breadth fills keep their original fixed colours; text on them reads in both modes.
  'screens/portfolio/portfolio_page.dart:Color(0xFF0C9F6E)',
  'screens/portfolio/portfolio_page.dart:Color(0xFF10B981)',
  'screens/portfolio/portfolio_page.dart:Color(0xFF064E3B)',
  'screens/portfolio/portfolio_page.dart:Color(0xFF6EE7B7)',
  'screens/portfolio/portfolio_page.dart:Color(0xFFDC2626)',
  'screens/portfolio/portfolio_page.dart:Color(0xFFEF4444)',
  'screens/portfolio/portfolio_page.dart:Color(0xFF450A0A)',
  'screens/portfolio/portfolio_page.dart:Color(0xFFFCA5A5)',
  'screens/portfolio/widgets/today_moves_card.dart:Color(0xFF0C9F6E)',
  'screens/portfolio/widgets/today_moves_card.dart:Color(0xFFD64545)',
  'screens/dashboard/widgets/macro_card.dart:Color(0xFF199E70)',
  'screens/dashboard/widgets/macro_card.dart:Color(0xFFD95926)',
  'screens/dashboard/widgets/allocation_card.dart:Color(0xFF6B6F78)',
};

void main() {
  test('no hard-coded colours outside the palette', () {
    final hits = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final p = f.path.replaceAll(r'\', '/');
      if (!p.endsWith('.dart') || p.contains('/l10n/') || p.endsWith('core/theme/app_colors.dart') ||
          p.endsWith('stock/widgets/share_card.dart')) {
        continue;
      }
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final m in RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)').allMatches(lines[i])) {
          final key = '${p.replaceFirst(RegExp(r'^.*?lib/'), '')}:${m.group(0)}';
          if (!_exceptions.contains(key)) hits.add('$p:${i + 1} ${m.group(0)}');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.take(40).join('\n'));
  });
}
