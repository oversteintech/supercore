import 'package:after_core/after_core.dart';

import '../capabilities/after_ai_capability.dart';
import '../mocks/mock_after_ai_services.dart';
import '../ports/after_ai_ports.dart';

/// Unified AfterAI Platform façade.
///
/// Every Super App depends on this — never invents a parallel AI stack.
/// Domain products only choose an [AfterAiProfile] (enable/disable set).
class AfterAiPlatform {
  AfterAiPlatform({
    required this.profile,
    AfterConversationAi? conversation,
    AfterVisionAi? vision,
    AfterOcrAi? ocr,
    AfterSpeechToTextAi? speechToText,
    AfterTextToSpeechAi? textToSpeech,
    AfterTranslationAi? translation,
    AfterRecommendationAi? recommendation,
    AfterPredictionAi? prediction,
    AfterSummarizationAi? summarization,
    AfterSemanticSearchAi? semanticSearch,
    AfterKnowledgeBaseAi? knowledgeBase,
    AfterAutomationAi? automation,
    AfterDecisionSupportAi? decisionSupport,
    AfterAiNotificationAdvisor? notifications,
    AfterWorkflowSuggestionAi? workflowSuggestions,
    AfterContextMemoryAi? contextMemory,
    AfterOfflineAi? offlineAi,
    AfterOnlineAi? onlineAi,
    AfterPromptTemplateStore? promptTemplates,
    AfterToolCallingAi? toolCalling,
    AfterAiPluginRegistry? plugins,
  })  : conversation = conversation ?? MockAfterConversationAi(),
        vision = vision ?? MockAfterVisionAi(),
        ocr = ocr ?? MockAfterOcrAi(),
        speechToText = speechToText ?? MockAfterSpeechToTextAi(),
        textToSpeech = textToSpeech ?? MockAfterTextToSpeechAi(),
        translation = translation ?? MockAfterTranslationAi(),
        recommendation = recommendation ?? MockAfterRecommendationAi(),
        prediction = prediction ?? MockAfterPredictionAi(),
        summarization = summarization ?? MockAfterSummarizationAi(),
        semanticSearch = semanticSearch ?? MockAfterSemanticSearchAi(),
        knowledgeBase = knowledgeBase ?? MockAfterKnowledgeBaseAi(),
        automation = automation ?? MockAfterAutomationAi(),
        decisionSupport = decisionSupport ?? MockAfterDecisionSupportAi(),
        notifications = notifications ?? MockAfterAiNotificationAdvisor(),
        workflowSuggestions =
            workflowSuggestions ?? MockAfterWorkflowSuggestionAi(),
        contextMemory = contextMemory ?? MockAfterContextMemoryAi(),
        offlineAi = offlineAi ?? MockAfterOfflineAi(),
        onlineAi = onlineAi ?? MockAfterOnlineAi(),
        promptTemplates = promptTemplates ?? MockAfterPromptTemplateStore(),
        toolCalling = toolCalling ?? MockAfterToolCallingAi(),
        plugins = plugins ?? MockAfterAiPluginRegistry();

  final AfterAiProfile profile;

  final AfterConversationAi conversation;
  final AfterVisionAi vision;
  final AfterOcrAi ocr;
  final AfterSpeechToTextAi speechToText;
  final AfterTextToSpeechAi textToSpeech;
  final AfterTranslationAi translation;
  final AfterRecommendationAi recommendation;
  final AfterPredictionAi prediction;
  final AfterSummarizationAi summarization;
  final AfterSemanticSearchAi semanticSearch;
  final AfterKnowledgeBaseAi knowledgeBase;
  final AfterAutomationAi automation;
  final AfterDecisionSupportAi decisionSupport;
  final AfterAiNotificationAdvisor notifications;
  final AfterWorkflowSuggestionAi workflowSuggestions;
  final AfterContextMemoryAi contextMemory;
  final AfterOfflineAi offlineAi;
  final AfterOnlineAi onlineAi;
  final AfterPromptTemplateStore promptTemplates;
  final AfterToolCallingAi toolCalling;
  final AfterAiPluginRegistry plugins;

  void ensureEnabled(AfterAiCapability capability) {
    if (!profile.isEnabled(capability)) {
      throw AfterAiCapabilityDisabledException(capability, profile.appId);
    }
  }

  bool get canChat => profile.isEnabled(AfterAiCapability.conversation);

  /// Routes completion through offline/online based on profile preference.
  Future<String> complete(String prompt) async {
    final preferOffline = profile.preferOffline;
    if (preferOffline && profile.isEnabled(AfterAiCapability.offlineAi)) {
      if (await offlineAi.isAvailable) {
        return offlineAi.completeOffline(prompt);
      }
    }
    if (profile.isEnabled(AfterAiCapability.onlineAi) &&
        await onlineAi.isAvailable) {
      return onlineAi.completeOnline(prompt);
    }
    if (profile.isEnabled(AfterAiCapability.offlineAi) &&
        await offlineAi.isAvailable) {
      return offlineAi.completeOffline(prompt);
    }
    throw AfterAiCapabilityDisabledException(
      AfterAiCapability.onlineAi,
      profile.appId,
    );
  }

  Future<String> chat({
    required String message,
    List<({String role, String content})> history = const [],
    String? systemPrompt,
    AfterAiContextBlock? ecosystemContext,
  }) {
    ensureEnabled(AfterAiCapability.conversation);
    final mergedSystem = _mergeSystemPrompt(systemPrompt, ecosystemContext);
    return conversation.chat(
      message: message,
      history: history,
      systemPrompt: mergedSystem,
    );
  }

  static String? _mergeSystemPrompt(
    String? systemPrompt,
    AfterAiContextBlock? ecosystemContext,
  ) {
    final ctx = ecosystemContext;
    if (ctx == null || ctx.isEmpty) return systemPrompt;
    if (systemPrompt == null || systemPrompt.trim().isEmpty) return ctx.text;
    return '$systemPrompt\n\n${ctx.text}';
  }

  Future<String> describeImage(AfterAiBinary image, {String? prompt}) {
    ensureEnabled(AfterAiCapability.vision);
    return vision.describe(image, prompt: prompt);
  }

  Future<String> ocrExtract(AfterAiBinary image, {String? locale}) {
    ensureEnabled(AfterAiCapability.ocr);
    return ocr.extractText(image, locale: locale);
  }

  Future<String> transcribe(AfterAiBinary audio, {String? locale}) {
    ensureEnabled(AfterAiCapability.speechToText);
    return speechToText.transcribe(audio, locale: locale);
  }

  Future<AfterAiBinary> speak(String text, {String? locale, String? voice}) {
    ensureEnabled(AfterAiCapability.textToSpeech);
    return textToSpeech.synthesize(text, locale: locale, voice: voice);
  }

  Future<String> translate(
    String text, {
    required String targetLocale,
    String? sourceLocale,
  }) {
    ensureEnabled(AfterAiCapability.translation);
    return translation.translate(
      text,
      targetLocale: targetLocale,
      sourceLocale: sourceLocale,
    );
  }

  Future<List<String>> recommend({
    required String userId,
    required String context,
    int limit = 5,
  }) {
    ensureEnabled(AfterAiCapability.recommendation);
    return recommendation.recommend(
      userId: userId,
      context: context,
      limit: limit,
    );
  }

  Future<Map<String, Object?>> predict({
    required String modelId,
    required Map<String, Object?> features,
  }) {
    ensureEnabled(AfterAiCapability.prediction);
    return prediction.predict(modelId: modelId, features: features);
  }

  Future<String> summarize(String text, {int maxSentences = 3}) {
    ensureEnabled(AfterAiCapability.summarization);
    return summarization.summarize(text, maxSentences: maxSentences);
  }

  Future<List<AfterAiSearchHit>> searchSemantic(
    String query, {
    int limit = 10,
  }) {
    ensureEnabled(AfterAiCapability.semanticSearch);
    return semanticSearch.search(query, limit: limit);
  }

  Future<List<AfterAiKnowledgeDoc>> queryKnowledge(
    String query, {
    int limit = 10,
  }) {
    ensureEnabled(AfterAiCapability.knowledgeBase);
    return knowledgeBase.query(query, limit: limit);
  }

  Future<String> runAutomation(
    String playbookId, {
    Map<String, Object?> input = const {},
  }) {
    ensureEnabled(AfterAiCapability.automation);
    return automation.runPlaybook(playbookId: playbookId, input: input);
  }

  Future<Map<String, Object?>> decide({
    required String decisionId,
    required Map<String, Object?> facts,
  }) {
    ensureEnabled(AfterAiCapability.decisionSupport);
    return decisionSupport.advise(decisionId: decisionId, facts: facts);
  }

  Future<List<String>> suggestNotifications({
    required String userId,
    required String context,
  }) {
    ensureEnabled(AfterAiCapability.notifications);
    return notifications.suggestNotifications(
      userId: userId,
      context: context,
    );
  }

  Future<List<String>> suggestWorkflowSteps({
    required String workflowId,
    required String currentState,
  }) {
    ensureEnabled(AfterAiCapability.workflowSuggestions);
    return workflowSuggestions.suggestNextSteps(
      workflowId: workflowId,
      currentState: currentState,
    );
  }

  Future<void> remember({
    required String sessionId,
    required String key,
    required String value,
  }) {
    ensureEnabled(AfterAiCapability.contextMemory);
    return contextMemory.remember(
      sessionId: sessionId,
      key: key,
      value: value,
    );
  }

  Future<String?> recall({required String sessionId, required String key}) {
    ensureEnabled(AfterAiCapability.contextMemory);
    return contextMemory.recall(sessionId: sessionId, key: key);
  }

  Future<AfterAiPromptTemplate?> prompt(String id) {
    ensureEnabled(AfterAiCapability.promptTemplates);
    return promptTemplates.get(id);
  }

  Future<List<AfterAiToolCall>> planTools(String message) {
    ensureEnabled(AfterAiCapability.toolCalling);
    return toolCalling.planTools(message);
  }

  Future<AfterAiToolResult> invokeTool(AfterAiToolCall call) {
    ensureEnabled(AfterAiCapability.toolCalling);
    return toolCalling.invoke(call);
  }

  Future<void> registerPlugin(AfterAiPluginDescriptor plugin) {
    ensureEnabled(AfterAiCapability.plugins);
    return plugins.register(plugin);
  }
}
