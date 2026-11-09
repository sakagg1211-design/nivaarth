import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/verdict_narrative_engine.dart';
import 'package:mobile/l10n/app_localizations.dart';

import 'helpers/narrative_samples.dart';

final en = lookupAppLocalizations(const Locale('en'));
final hi = lookupAppLocalizations(const Locale('en', 'IN'));

Map<String, dynamic> run(AppLocalizations t) => {
      for (final e in narrativeSamples.entries)
        for (final owned in [false, true])
          '${e.key}/$owned': dumpNarrative(VerdictNarrativeEngine.generate(score: e.value, isOwned: owned, t: t)),
    };

// The same figures in the same quantity, whatever the sentence order
List<String> numbers(Object v) => (RegExp(r'\d+(\.\d+)?').allMatches(jsonEncode(v)).map((m) => m.group(0)!).toList())..sort();

void main() {
  final golden = jsonDecode(File('test/fixtures/narrative_golden.json').readAsStringSync()) as Map<String, dynamic>;

  test('English output is word for word what it was before translation', () {
    final out = run(en);
    for (final k in golden.keys) {
      expect(out[k], golden[k], reason: k);
    }
  });

  test('the same inputs give the same numbers in both languages', () {
    final a = run(en), b = run(hi);
    for (final k in a.keys) {
      expect(numbers(b[k]!), numbers(a[k]!), reason: k);
    }
  });

  test('Hinglish really is different text', () {
    expect(run(hi)['scored/false']['analystBriefing'], isNot(run(en)['scored/false']['analystBriefing']));
  });
}
