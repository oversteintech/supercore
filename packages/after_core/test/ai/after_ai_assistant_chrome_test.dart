import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AfterAiComposerBar + menu embeds clear chat', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var cleared = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AfterAiComposerBar(
            controller: controller,
            isBusy: false,
            onSend: () {},
            onAttach: () {},
            hasMessages: true,
            onClearChat: () => cleared = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Clear chat'), findsOneWidget);
    await tester.tap(find.text('Clear chat'));
    await tester.pumpAndSettle();
    expect(cleared, isTrue);
  });

  testWidgets('AfterAiComposerBar shows attach and mic when empty', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AfterAiComposerBar(
            controller: controller,
            isBusy: false,
            onSend: () {},
            onAttach: () {},
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
  });

  testWidgets('AfterAiComposerBar shows send when text present', (tester) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AfterAiComposerBar(
            controller: controller,
            isBusy: false,
            onSend: () {},
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
  });

  testWidgets('AfterAiComposerBar dismisses keyboard focus on send', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    var sent = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AfterAiComposerBar(
            controller: controller,
            isBusy: false,
            onSend: () => sent = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    final composerFocus = tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode;
    expect(composerFocus.hasFocus, isTrue);

    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump();

    expect(sent, isTrue);
    expect(composerFocus.hasFocus, isFalse);
  });

  test('default suggestions are non-empty', () {
    expect(
      AfterAiQuickSuggestionCatalog.defaultsFor('Health AI'),
      isNotEmpty,
    );
  });
}
