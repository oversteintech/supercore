import 'package:meta/meta.dart';

// ── Shared value types ─────────────────────────────────────────────────────

@immutable
class AfterAiText {
  const AfterAiText(this.value, {this.locale});
  final String value;
  final String? locale;
}

@immutable
class AfterAiBinary {
  const AfterAiBinary(this.bytes, {this.mimeType = 'application/octet-stream'});
  final List<int> bytes;
  final String mimeType;
}

@immutable
class AfterAiToolCall {
  const AfterAiToolCall({
    required this.name,
    required this.arguments,
    this.id,
  });
  final String? id;
  final String name;
  final Map<String, Object?> arguments;
}

@immutable
class AfterAiToolResult {
  const AfterAiToolResult({
    required this.name,
    required this.output,
    this.id,
  });
  final String? id;
  final String name;
  final Object? output;
}

@immutable
class AfterAiSearchHit {
  const AfterAiSearchHit({
    required this.id,
    required this.title,
    required this.snippet,
    this.score = 0,
    this.metadata = const {},
  });
  final String id;
  final String title;
  final String snippet;
  final double score;
  final Map<String, Object?> metadata;
}

@immutable
class AfterAiKnowledgeDoc {
  const AfterAiKnowledgeDoc({
    required this.id,
    required this.title,
    required this.body,
    this.tags = const [],
  });
  final String id;
  final String title;
  final String body;
  final List<String> tags;
}

@immutable
class AfterAiPromptTemplate {
  const AfterAiPromptTemplate({
    required this.id,
    required this.template,
    this.description = '',
    this.variables = const [],
  });
  final String id;
  final String template;
  final String description;
  final List<String> variables;

  String render(Map<String, String> values) {
    var out = template;
    for (final entry in values.entries) {
      out = out.replaceAll('{{${entry.key}}}', entry.value);
    }
    return out;
  }
}

@immutable
class AfterAiPluginDescriptor {
  const AfterAiPluginDescriptor({
    required this.id,
    required this.name,
    required this.capabilities,
    this.version = '1.0.0',
  });
  final String id;
  final String name;
  final String version;
  final Set<String> capabilities;
}

// ── Capability ports ───────────────────────────────────────────────────────

abstract class AfterConversationAi {
  Future<String> chat({
    required String message,
    List<({String role, String content})> history = const [],
    String? systemPrompt,
  });
}

abstract class AfterVisionAi {
  Future<String> describe(AfterAiBinary image, {String? prompt});
}

abstract class AfterOcrAi {
  Future<String> extractText(AfterAiBinary image, {String? locale});
}

abstract class AfterSpeechToTextAi {
  Future<String> transcribe(AfterAiBinary audio, {String? locale});
}

abstract class AfterTextToSpeechAi {
  Future<AfterAiBinary> synthesize(String text, {String? locale, String? voice});
}

abstract class AfterTranslationAi {
  Future<String> translate(
    String text, {
    required String targetLocale,
    String? sourceLocale,
  });
}

abstract class AfterRecommendationAi {
  Future<List<String>> recommend({
    required String userId,
    required String context,
    int limit = 5,
  });
}

abstract class AfterPredictionAi {
  Future<Map<String, Object?>> predict({
    required String modelId,
    required Map<String, Object?> features,
  });
}

abstract class AfterSummarizationAi {
  Future<String> summarize(
    String text, {
    int maxSentences = 3,
    String? locale,
  });
}

abstract class AfterSemanticSearchAi {
  Future<List<AfterAiSearchHit>> search(
    String query, {
    int limit = 10,
    Map<String, Object?> filters = const {},
  });
}

abstract class AfterKnowledgeBaseAi {
  Future<void> upsert(AfterAiKnowledgeDoc doc);
  Future<void> delete(String id);
  Future<List<AfterAiKnowledgeDoc>> query(String query, {int limit = 10});
}

abstract class AfterAutomationAi {
  Future<String> runPlaybook({
    required String playbookId,
    Map<String, Object?> input = const {},
  });
}

abstract class AfterDecisionSupportAi {
  Future<Map<String, Object?>> advise({
    required String decisionId,
    required Map<String, Object?> facts,
  });
}

abstract class AfterAiNotificationAdvisor {
  Future<List<String>> suggestNotifications({
    required String userId,
    required String context,
  });
}

abstract class AfterWorkflowSuggestionAi {
  Future<List<String>> suggestNextSteps({
    required String workflowId,
    required String currentState,
  });
}

abstract class AfterContextMemoryAi {
  Future<void> remember({
    required String sessionId,
    required String key,
    required String value,
  });
  Future<String?> recall({required String sessionId, required String key});
  Future<Map<String, String>> snapshot(String sessionId);
  Future<void> clear(String sessionId);
}

abstract class AfterOfflineAi {
  Future<bool> get isAvailable;
  Future<String> completeOffline(String prompt);
}

abstract class AfterOnlineAi {
  Future<bool> get isAvailable;
  Future<String> completeOnline(String prompt);
}

abstract class AfterPromptTemplateStore {
  Future<void> save(AfterAiPromptTemplate template);
  Future<AfterAiPromptTemplate?> get(String id);
  Future<List<AfterAiPromptTemplate>> list();
}

abstract class AfterToolCallingAi {
  Future<List<AfterAiToolCall>> planTools(String userMessage);
  Future<AfterAiToolResult> invoke(AfterAiToolCall call);
}

abstract class AfterAiPluginRegistry {
  Future<void> register(AfterAiPluginDescriptor plugin);
  Future<void> unregister(String pluginId);
  Future<List<AfterAiPluginDescriptor>> list();
}
