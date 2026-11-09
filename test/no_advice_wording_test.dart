import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// SEBI guardrail: the app explains data; it must not tell users to buy, sell, hold, add or
/// trim, and must not use made-up "institutional" stories. Scans every string literal in lib/.
const bannedPhrases = [
  'fresh capital',
  'accumulate systematically',
  'accumulation zone',
  'steady accumulation',
  'stop-loss',
  'stop loss',
  'trailing stop',
  'profit booking',
  'book profit',
  'averaging down',
  'aggressive averaging',
  'add incrementally',
  'hold firmly',
  'trim small',
  'reallocat',
  'capital preservation',
  'preserving cash',
  'core compounder',
  'conviction',
  'hedge-fund',
  'market leader',
  'avoid panic',
  'institutional backing',
  'institutional accumulation',
  'consider rebalancing',
  'optimal diversification',
];

const bannedHinglish = ['kharido', 'khareedo', 'khareed lo', 'bech do', 'becho', 'hold karo', 'rakhe raho', 'nikal jao'];

final _stringLiteral = RegExp(r'''(['"])((?:\\.|(?!\1).)*)\1''');

void main() {
  test('the scanner itself finds a banned phrase in a string literal', () {
    const line = "  return 'Accumulate systematically during pullbacks.';";
    final found = _stringLiteral
        .allMatches(line)
        .any((m) => m.group(2)!.toLowerCase().contains('accumulate systematically'));
    expect(found, isTrue);
  });

  test('no buy/sell/hold advice or made-up stories in app text', () {
    final hits = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final code = line.trimLeft();
        if (code.startsWith('//') || code.startsWith('///') || code.startsWith('*')) continue;
        for (final m in _stringLiteral.allMatches(line)) {
          final text = m.group(2)!.toLowerCase();
          for (final phrase in bannedPhrases) {
            if (text.contains(phrase)) hits.add('${file.path}:${i + 1}: "$phrase"');
          }
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('no advice wording in the translated text', () {
    final hits = <String>[];
    for (final name in ['app_en.arb', 'app_en_IN.arb']) {
      final arb = jsonDecode(File('lib/l10n/$name').readAsStringSync()) as Map<String, dynamic>;
      arb.forEach((key, value) {
        if (key.startsWith('@') || value is! String) return;
        final text = value.toLowerCase();
        for (final phrase in [...bannedPhrases, if (name == 'app_en_IN.arb') ...bannedHinglish]) {
          if (text.contains(phrase)) hits.add('$name:$key: "$phrase"');
        }
      });
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}
