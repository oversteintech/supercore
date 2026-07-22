import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AfterAiAssistantHeader shows hub and title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AfterAiAssistantHeader(
            title: 'SuperFarm AI',
            hasMessages: false,
            onClearChat: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('SuperFarm AI'), findsOneWidget);
    expect(find.byIcon(Icons.hub_rounded), findsOneWidget);
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
            onToggleRecording: () {},
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

  test('default suggestions are non-empty', () {
    expect(
      AfterAiQuickSuggestionCatalog.defaultsFor('Health AI'),
      isNotEmpty,
    );
  });
}
