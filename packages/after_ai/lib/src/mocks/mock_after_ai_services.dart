import 'package:uuid/uuid.dart';

import '../ports/after_ai_ports.dart';

/// Deterministic mocks for every AfterAI capability — scaffolds run offline.
class MockAfterConversationAi implements AfterConversationAi {
  @override
  Future<String> chat({
    required String message,
    List<({String role, String content})> history = const [],
    String? systemPrompt,
  }) async {
    return '[afterai:conversation] $message';
  }
}

class MockAfterVisionAi implements AfterVisionAi {
  @override
  Future<String> describe(AfterAiBinary image, {String? prompt}) async {
    return '[afterai:vision] ${image.bytes.length} bytes'
        '${prompt == null ? '' : ' · $prompt'}';
  }
}

class MockAfterOcrAi implements AfterOcrAi {
  @override
  Future<String> extractText(AfterAiBinary image, {String? locale}) async {
    return '[afterai:ocr] extracted text (${image.bytes.length} bytes)';
  }
}

class MockAfterSpeechToTextAi implements AfterSpeechToTextAi {
  @override
  Future<String> transcribe(AfterAiBinary audio, {String? locale}) async {
    return '[afterai:stt] transcript';
  }
}

class MockAfterTextToSpeechAi implements AfterTextToSpeechAi {
  @override
  Future<AfterAiBinary> synthesize(
    String text, {
    String? locale,
    String? voice,
  }) async {
    return AfterAiBinary(text.codeUnits, mimeType: 'audio/mock');
  }
}

class MockAfterTranslationAi implements AfterTranslationAi {
  @override
  Future<String> translate(
    String text, {
    required String targetLocale,
    String? sourceLocale,
  }) async {
    return '[$targetLocale] $text';
  }
}

class MockAfterRecommendationAi implements AfterRecommendationAi {
  @override
  Future<List<String>> recommend({
    required String userId,
    required String context,
    int limit = 5,
  }) async {
    return List.generate(
      limit,
      (i) => 'recommendation_${i + 1}_for_$userId',
    );
  }
}

class MockAfterPredictionAi implements AfterPredictionAi {
  @override
  Future<Map<String, Object?>> predict({
    required String modelId,
    required Map<String, Object?> features,
  }) async {
    return {
      'modelId': modelId,
      'score': 0.72,
      'label': 'mock_positive',
      'features': features.length,
    };
  }
}

class MockAfterSummarizationAi implements AfterSummarizationAi {
  @override
  Future<String> summarize(
    String text, {
    int maxSentences = 3,
    String? locale,
  }) async {
    final clipped = text.length <= 160 ? text : '${text.substring(0, 157)}…';
    return '[summary/$maxSentences] $clipped';
  }
}

class MockAfterSemanticSearchAi implements AfterSemanticSearchAi {
  MockAfterSemanticSearchAi([this._seed = const []]);

  final List<AfterAiSearchHit> _seed;

  @override
  Future<List<AfterAiSearchHit>> search(
    String query, {
    int limit = 10,
    Map<String, Object?> filters = const {},
  }) async {
    final q = query.toLowerCase();
    final hits = _seed
        .where(
          (h) =>
              h.title.toLowerCase().contains(q) ||
              h.snippet.toLowerCase().contains(q),
        )
        .take(limit)
        .toList();
    if (hits.isNotEmpty) return hits;
    return [
      AfterAiSearchHit(
        id: 'mock-1',
        title: 'Match for "$query"',
        snippet: 'Semantic mock hit',
        score: 0.5,
      ),
    ];
  }
}

class MockAfterKnowledgeBaseAi implements AfterKnowledgeBaseAi {
  final _docs = <String, AfterAiKnowledgeDoc>{};

  @override
  Future<void> upsert(AfterAiKnowledgeDoc doc) async {
    _docs[doc.id] = doc;
  }

  @override
  Future<void> delete(String id) async {
    _docs.remove(id);
  }

  @override
  Future<List<AfterAiKnowledgeDoc>> query(String query, {int limit = 10}) async {
    final q = query.toLowerCase();
    return _docs.values
        .where(
          (d) =>
              d.title.toLowerCase().contains(q) ||
              d.body.toLowerCase().contains(q) ||
              d.tags.any((t) => t.toLowerCase().contains(q)),
        )
        .take(limit)
        .toList();
  }
}

class MockAfterAutomationAi implements AfterAutomationAi {
  @override
  Future<String> runPlaybook({
    required String playbookId,
    Map<String, Object?> input = const {},
  }) async {
    return '[automation:$playbookId] ran with ${input.length} inputs';
  }
}

class MockAfterDecisionSupportAi implements AfterDecisionSupportAi {
  @override
  Future<Map<String, Object?>> advise({
    required String decisionId,
    required Map<String, Object?> facts,
  }) async {
    return {
      'decisionId': decisionId,
      'recommendation': 'proceed_with_review',
      'confidence': 0.64,
      'factsConsidered': facts.length,
    };
  }
}

class MockAfterAiNotificationAdvisor implements AfterAiNotificationAdvisor {
  @override
  Future<List<String>> suggestNotifications({
    required String userId,
    required String context,
  }) async {
    return ['Reminder for $userId: $context'];
  }
}

class MockAfterWorkflowSuggestionAi implements AfterWorkflowSuggestionAi {
  @override
  Future<List<String>> suggestNextSteps({
    required String workflowId,
    required String currentState,
  }) async {
    return ['review', 'approve', 'escalate'];
  }
}

class MockAfterContextMemoryAi implements AfterContextMemoryAi {
  final _store = <String, Map<String, String>>{};

  @override
  Future<void> remember({
    required String sessionId,
    required String key,
    required String value,
  }) async {
    (_store[sessionId] ??= {})[key] = value;
  }

  @override
  Future<String?> recall({
    required String sessionId,
    required String key,
  }) async {
    return _store[sessionId]?[key];
  }

  @override
  Future<Map<String, String>> snapshot(String sessionId) async {
    return Map<String, String>.from(_store[sessionId] ?? const {});
  }

  @override
  Future<void> clear(String sessionId) async {
    _store.remove(sessionId);
  }
}

class MockAfterOfflineAi implements AfterOfflineAi {
  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<String> completeOffline(String prompt) async {
    return '[offline] $prompt';
  }
}

class MockAfterOnlineAi implements AfterOnlineAi {
  MockAfterOnlineAi({this.delegate});

  /// Optional bridge to after_core AfterAiClient / orchestrator.
  final Future<String> Function(String prompt)? delegate;

  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<String> completeOnline(String prompt) async {
    if (delegate != null) return delegate!(prompt);
    return '[online] $prompt';
  }
}

class MockAfterPromptTemplateStore implements AfterPromptTemplateStore {
  final _templates = <String, AfterAiPromptTemplate>{
    'default.system': const AfterAiPromptTemplate(
      id: 'default.system',
      description: 'Default Mate system prompt',
      template:
          'You are Mate, the AI assistant for {{appName}}. Be concise and safe.',
      variables: ['appName'],
    ),
  };

  @override
  Future<void> save(AfterAiPromptTemplate template) async {
    _templates[template.id] = template;
  }

  @override
  Future<AfterAiPromptTemplate?> get(String id) async => _templates[id];

  @override
  Future<List<AfterAiPromptTemplate>> list() async =>
      _templates.values.toList(growable: false);
}

class MockAfterToolCallingAi implements AfterToolCallingAi {
  MockAfterToolCallingAi({
    Map<String, Future<Object?> Function(Map<String, Object?>)>? handlers,
  }) : _handlers = handlers ?? const {};

  final Map<String, Future<Object?> Function(Map<String, Object?>)> _handlers;

  @override
  Future<List<AfterAiToolCall>> planTools(String userMessage) async {
    if (userMessage.toLowerCase().contains('tool:')) {
      final name = userMessage.split('tool:').last.trim().split(' ').first;
      return [
        AfterAiToolCall(
          id: const Uuid().v4(),
          name: name,
          arguments: {'raw': userMessage},
        ),
      ];
    }
    return const [];
  }

  @override
  Future<AfterAiToolResult> invoke(AfterAiToolCall call) async {
    final handler = _handlers[call.name];
    final output = handler == null
        ? {'ok': true, 'echo': call.arguments}
        : await handler(call.arguments);
    return AfterAiToolResult(id: call.id, name: call.name, output: output);
  }
}

class MockAfterAiPluginRegistry implements AfterAiPluginRegistry {
  final _plugins = <String, AfterAiPluginDescriptor>{};

  @override
  Future<void> register(AfterAiPluginDescriptor plugin) async {
    _plugins[plugin.id] = plugin;
  }

  @override
  Future<void> unregister(String pluginId) async {
    _plugins.remove(pluginId);
  }

  @override
  Future<List<AfterAiPluginDescriptor>> list() async =>
      _plugins.values.toList(growable: false);
}
