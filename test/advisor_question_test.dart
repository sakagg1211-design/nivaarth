import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/providers/advisor_question_provider.dart';
import 'package:mobile/screens/advisor/advisor_chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/localized_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a pending question is sent once and cleared', (tester) async {
    final container = ProviderContainer(overrides: [advisorQuestionProvider.overrideWith((ref) => 'Why did my portfolio fall today?')]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: localizedApp(home: const AdvisorChatPage())));
    await tester.pumpAndSettle();
    expect(find.text('Why did my portfolio fall today?'), findsOneWidget);
    expect(container.read(advisorQuestionProvider), isNull);
    await tester.pumpAndSettle();
    expect(find.text('Why did my portfolio fall today?'), findsOneWidget);
  });

  testWidgets('a question set while the page is open is sent', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: localizedApp(home: const AdvisorChatPage())));
    await tester.pumpAndSettle();
    container.read(advisorQuestionProvider.notifier).state = 'Why did my portfolio rise today?';
    await tester.pumpAndSettle();
    expect(find.text('Why did my portfolio rise today?'), findsOneWidget);
    expect(container.read(advisorQuestionProvider), isNull);
  });

  testWidgets('opening the page without a question sends nothing', (tester) async {
    await tester.pumpWidget(ProviderScope(child: localizedApp(home: const AdvisorChatPage())));
    await tester.pumpAndSettle();
    expect(find.textContaining('Why did my portfolio'), findsNothing);
  });
}
