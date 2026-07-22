# AfterAI Platform (`after_ai`)

Modular AI operating layer for **every** AfterArtificial Super App.

Super Apps do **not** invent AI stacks. They select an [`AfterAiProfile`](lib/src/capabilities/after_ai_capability.dart) that enables/disables capabilities for their domain.

## Capabilities

| Capability | Port |
|------------|------|
| Conversation AI | `AfterConversationAi` |
| Vision AI | `AfterVisionAi` |
| OCR | `AfterOcrAi` |
| Speech → Text | `AfterSpeechToTextAi` |
| Text → Speech | `AfterTextToSpeechAi` |
| Translation | `AfterTranslationAi` |
| Recommendation | `AfterRecommendationAi` |
| Prediction | `AfterPredictionAi` |
| Summarization | `AfterSummarizationAi` |
| Semantic Search | `AfterSemanticSearchAi` |
| Knowledge Base | `AfterKnowledgeBaseAi` |
| Automation | `AfterAutomationAi` |
| Decision Support | `AfterDecisionSupportAi` |
| Notifications (AI) | `AfterAiNotificationAdvisor` |
| Workflow Suggestions | `AfterWorkflowSuggestionAi` |
| Context Memory | `AfterContextMemoryAi` |
| Offline AI | `AfterOfflineAi` |
| Online AI | `AfterOnlineAi` |
| Prompt Templates | `AfterPromptTemplateStore` |
| Tool Calling | `AfterToolCallingAi` |
| AI Plugins | `AfterAiPluginRegistry` |

All ship with **mock adapters** so scaffolds run without cloud keys. Production apps override individual ports (or bridge `OnlineAi` to `after_core` BYOK clients).

## Wire in a Super App

```dart
// after_framework.dart
afterAiProfileProvider.overrideWithValue(AfterAiProfile.superGarage),
// or a custom set:
// AfterAiProfile(appId: 'super_news', enabled: { ... }),
```

```dart
final ai = ref.watch(afterAiPlatformProvider);
if (ai.canChat) {
  final reply = await ai.chat(message: input);
}
```

## Profiles

| Profile | App |
|---------|-----|
| `AfterAiProfile.superGarage` | Consumer reference |
| `AfterAiProfile.superHospital` | Enterprise reference |
| `AfterAiProfile.superNews` | News / briefing |
| `AfterAiProfile.conversationOnly(appId)` | Minimal scaffold |

Docs: [`docs/AFTER_AI_PLATFORM.md`](../../docs/AFTER_AI_PLATFORM.md)
