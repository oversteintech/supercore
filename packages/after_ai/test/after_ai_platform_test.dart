import 'package:after_ai/after_ai.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AfterAiProfile', () {
    test('superGarage enables conversation + ocr + tools', () {
      expect(
        AfterAiProfile.superGarage.isEnabled(AfterAiCapability.conversation),
        isTrue,
      );
      expect(
        AfterAiProfile.superGarage.isEnabled(AfterAiCapability.ocr),
        isTrue,
      );
      expect(
        AfterAiProfile.superGarage.isEnabled(AfterAiCapability.toolCalling),
        isTrue,
      );
      expect(
        AfterAiProfile.superGarage.isEnabled(AfterAiCapability.speechToText),
        isFalse,
      );
    });

    test('superHospital enables decision support + workflow suggestions', () {
      expect(
        AfterAiProfile.superHospital
            .isEnabled(AfterAiCapability.decisionSupport),
        isTrue,
      );
      expect(
        AfterAiProfile.superHospital
            .isEnabled(AfterAiCapability.workflowSuggestions),
        isTrue,
      );
    });
  });

  group('AfterAiPlatform', () {
    test('chat works when conversation enabled', () async {
      final ai = AfterAiPlatform(profile: AfterAiProfile.superNews);
      final reply = await ai.chat(message: 'Brief me');
      expect(reply, contains('Brief me'));
    });

    test('chat injects AfterAiContextBlock into system prompt', () async {
      String? capturedSystem;
      final ai = AfterAiPlatform(
        profile: AfterAiProfile.superNews,
        conversation: _CaptureConversationAi((system) {
          capturedSystem = system;
        }),
      );
      await ai.chat(
        message: 'hi',
        systemPrompt: 'base',
        ecosystemContext: const AfterAiContextBlock(
          text: 'After ecosystem context\nafterId: aid_1',
          metadata: {'afterId': 'aid_1'},
        ),
      );
      expect(capturedSystem, contains('base'));
      expect(capturedSystem, contains('After ecosystem context'));
      expect(capturedSystem, contains('aid_1'));
    });

    test('disabled capability throws', () async {
      final ai = AfterAiPlatform(
        profile: AfterAiProfile.conversationOnly('demo'),
      );
      expect(
        () => ai.translate('hello', targetLocale: 'tr'),
        throwsA(isA<AfterAiCapabilityDisabledException>()),
      );
    });

    test('summarize + recommend + predict + memory', () async {
      final ai = AfterAiPlatform(profile: AfterAiProfile.superGarage);
      final summary = await ai.summarize('A long text about oil changes.');
      expect(summary, contains('summary'));

      final recs = await ai.recommend(userId: 'u1', context: 'maintenance');
      expect(recs, isNotEmpty);

      final pred = await ai.predict(
        modelId: 'failure_risk',
        features: {'mileage': 120000},
      );
      expect(pred['score'], isNotNull);

      await ai.remember(sessionId: 's1', key: 'vehicle', value: 'BMW');
      expect(await ai.recall(sessionId: 's1', key: 'vehicle'), 'BMW');
    });

    test('prompt templates + tool calling + plugins', () async {
      final ai = AfterAiPlatform(profile: AfterAiProfile.superGarage);
      final tpl = await ai.prompt('default.system');
      expect(tpl, isNotNull);
      expect(tpl!.render({'appName': 'SuperGarage'}), contains('SuperGarage'));

      final tools = await ai.planTools('please tool:lookup_vin abc');
      expect(tools, isNotEmpty);
      final result = await ai.invokeTool(tools.first);
      expect(result.name, 'lookup_vin');

      await ai.registerPlugin(
        const AfterAiPluginDescriptor(
          id: 'vin_plugin',
          name: 'VIN Lookup',
          capabilities: {'toolCalling'},
        ),
      );
      final plugins = await ai.plugins.list();
      expect(plugins.map((p) => p.id), contains('vin_plugin'));
    });

    test('complete routes online by default', () async {
      final ai = AfterAiPlatform(profile: AfterAiProfile.superNews);
      final out = await ai.complete('hello');
      expect(out, contains('online'));
    });

    test('hospital decision + workflow suggestions', () async {
      final ai = AfterAiPlatform(profile: AfterAiProfile.superHospital);
      final advice = await ai.decide(
        decisionId: 'admit',
        facts: {'triage': 'orange'},
      );
      expect(advice['recommendation'], isNotNull);
      final steps = await ai.suggestWorkflowSteps(
        workflowId: 'admission',
        currentState: 'triage',
      );
      expect(steps, contains('approve'));
    });
  });
}

class _CaptureConversationAi implements AfterConversationAi {
  _CaptureConversationAi(this.onSystem);

  final void Function(String? system) onSystem;

  @override
  Future<String> chat({
    required String message,
    List<({String role, String content})> history = const [],
    String? systemPrompt,
  }) async {
    onSystem(systemPrompt);
    return '[captured] $message';
  }
}
