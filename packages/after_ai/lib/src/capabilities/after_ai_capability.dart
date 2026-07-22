/// Every AI capability offered by the AfterAI Platform.
///
/// Super Apps never invent AI stacks — they enable/disable these capabilities
/// via [AfterAiProfile] according to their business domain.
enum AfterAiCapability {
  conversation,
  vision,
  ocr,
  speechToText,
  textToSpeech,
  translation,
  recommendation,
  prediction,
  summarization,
  semanticSearch,
  knowledgeBase,
  automation,
  decisionSupport,
  notifications,
  workflowSuggestions,
  contextMemory,
  offlineAi,
  onlineAi,
  promptTemplates,
  toolCalling,
  plugins,
}

/// Immutable enable/disable map for a Super App.
class AfterAiProfile {
  const AfterAiProfile({
    required this.appId,
    required this.enabled,
    this.defaultLocale = 'en',
    this.preferOffline = false,
  });

  /// Product appId (e.g. `super_garage`, `super_hospital`).
  final String appId;

  /// Enabled capabilities for this product.
  final Set<AfterAiCapability> enabled;

  final String defaultLocale;

  /// When true, offline adapters are preferred before online.
  final bool preferOffline;

  bool isEnabled(AfterAiCapability capability) => enabled.contains(capability);

  AfterAiProfile copyWith({
    Set<AfterAiCapability>? enabled,
    String? defaultLocale,
    bool? preferOffline,
  }) {
    return AfterAiProfile(
      appId: appId,
      enabled: enabled ?? this.enabled,
      defaultLocale: defaultLocale ?? this.defaultLocale,
      preferOffline: preferOffline ?? this.preferOffline,
    );
  }

  /// Consumer garage reference — vehicle/ops Mate skills.
  static const superGarage = AfterAiProfile(
    appId: 'super_garage',
    enabled: {
      AfterAiCapability.conversation,
      AfterAiCapability.ocr,
      AfterAiCapability.vision,
      AfterAiCapability.summarization,
      AfterAiCapability.recommendation,
      AfterAiCapability.prediction,
      AfterAiCapability.semanticSearch,
      AfterAiCapability.knowledgeBase,
      AfterAiCapability.contextMemory,
      AfterAiCapability.offlineAi,
      AfterAiCapability.onlineAi,
      AfterAiCapability.promptTemplates,
      AfterAiCapability.toolCalling,
      AfterAiCapability.notifications,
      AfterAiCapability.plugins,
    },
  );

  /// Enterprise hospital reference — clinical decision + ops.
  static const superHospital = AfterAiProfile(
    appId: 'super_hospital',
    enabled: {
      AfterAiCapability.conversation,
      AfterAiCapability.ocr,
      AfterAiCapability.vision,
      AfterAiCapability.speechToText,
      AfterAiCapability.textToSpeech,
      AfterAiCapability.translation,
      AfterAiCapability.summarization,
      AfterAiCapability.semanticSearch,
      AfterAiCapability.knowledgeBase,
      AfterAiCapability.decisionSupport,
      AfterAiCapability.automation,
      AfterAiCapability.workflowSuggestions,
      AfterAiCapability.contextMemory,
      AfterAiCapability.offlineAi,
      AfterAiCapability.onlineAi,
      AfterAiCapability.promptTemplates,
      AfterAiCapability.toolCalling,
      AfterAiCapability.notifications,
      AfterAiCapability.plugins,
      AfterAiCapability.recommendation,
      AfterAiCapability.prediction,
    },
  );

  /// News — briefing / summary / translate / search heavy.
  static const superNews = AfterAiProfile(
    appId: 'super_news',
    enabled: {
      AfterAiCapability.conversation,
      AfterAiCapability.summarization,
      AfterAiCapability.translation,
      AfterAiCapability.recommendation,
      AfterAiCapability.semanticSearch,
      AfterAiCapability.knowledgeBase,
      AfterAiCapability.textToSpeech,
      AfterAiCapability.contextMemory,
      AfterAiCapability.onlineAi,
      AfterAiCapability.offlineAi,
      AfterAiCapability.promptTemplates,
      AfterAiCapability.notifications,
    },
  );

  /// Minimal chat-only profile for early scaffolds.
  static AfterAiProfile conversationOnly(String appId) => AfterAiProfile(
        appId: appId,
        enabled: {
          AfterAiCapability.conversation,
          AfterAiCapability.onlineAi,
          AfterAiCapability.offlineAi,
          AfterAiCapability.promptTemplates,
          AfterAiCapability.contextMemory,
        },
      );
}

/// Thrown when a Super App calls a capability that is disabled in its profile.
class AfterAiCapabilityDisabledException implements Exception {
  AfterAiCapabilityDisabledException(this.capability, this.appId);

  final AfterAiCapability capability;
  final String appId;

  @override
  String toString() =>
      'AfterAI capability "${capability.name}" is disabled for app "$appId". '
      'Enable it in AfterAiProfile.';
}
