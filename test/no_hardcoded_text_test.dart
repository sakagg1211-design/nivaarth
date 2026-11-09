import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Screen text must come from the ARB files, or the language switch silently misses it.
final _sites = RegExp(
  r'''(?:\bText\(\s*|\b(?:label|title|tooltip|hintText|labelText|helpText|message|subtitle)\s*:\s*(?:const\s+Text\(\s*)?)(['"])((?:\\.|(?!\1).)+)\1''',
);

// Product names and finance words kept the same in both languages.
const _sameInBoth = {
  'NIVAARTH', 'Beta', 'English', 'Hinglish', 'Qty', 'Avg', 'Value', 'Total P&L', 'Total', 'Stock', 'Growth',
  'NV Score', 'NV Advisor', 'NV Verdict', 'NV Briefing', 'India VIX', 'LIVE', 'LIVE AI', 'Portfolio', 'Live NSE',
  'Offline', 'Portfolio vs Nifty', 'Sector heatmap', 'Investment style', 'Friends Beta', 'Private Beta',
  'Closed Friends Beta', 'Private Portfolio Intelligence', 'NV Quantitative Engine', 'NSE Real-time',
  'Portfolio beta', 'Portfolio P/E', 'Loading…', 'Unavailable', 'Trades', 'Share',
  'BENCHMARK', 'Secure', 'NV Scored', 'Live view', 'Details ↗', 'Holdings', 'MY SAVED LIST', 'ARCHETYPE', 'DELAYED', 'ACTIVE',
};

// Legal wording stays English in both languages.
const _legalFiles = ['legal_disclaimer_sheet.dart'];
const _legalStart = ['Nivaarth is an educational', 'Nivaarth is a research', 'Regulatory Notice', 'I agree that stock', 'Read Terms of Service', 'Important'];

List<String> scan(String source, String name) => [
      for (final m in _sites.allMatches(source))
        if (RegExp('[A-Za-z]{2}').hasMatch(m.group(2)!) &&
            !RegExp(r'^(\$[\w{]|[HLQ]: \$|Score \$)').hasMatch(m.group(2)!) &&
            !_sameInBoth.contains(m.group(2)!) &&
            !_legalStart.any(m.group(2)!.startsWith))
          '$name: ${m.group(2)}',
    ];

void main() {
  test('the guard catches a planted string', () {
    expect(scan("child: Text('Test text')", 'x'), isNotEmpty);
    expect(scan("title: const Text(\n  'Test text',\n)", 'x'), isNotEmpty);
    expect(scan('child: Text(context.t.commonOk)', 'x'), isEmpty);
    expect(scan("child: Text('Qty')", 'x'), isEmpty);
  });

  test('no screen text outside the ARB files', () {
    final hits = <String>[];
    for (final dir in ['lib/screens', 'lib/widgets', 'lib/features']) {
      for (final f in Directory(dir).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart') || _legalFiles.any(f.path.endsWith)) continue;
        hits.addAll(scan(f.readAsStringSync(), f.path));
      }
    }
    expect(hits, isEmpty, reason: '${hits.length} found:\n${hits.join('\n')}');
  });
}
