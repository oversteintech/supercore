import 'package:meta/meta.dart';

/// Enterprise AI request context. Wraps [after_core] AI ports with tenant +
/// permission awareness so responses can be scoped, audited, and redacted.
@immutable
class EnterpriseAiContext {
  const EnterpriseAiContext({
    required this.organizationId,
    required this.userId,
    this.roleIds = const [],
    this.locale = 'en',
    this.attributes = const {},
  });

  final String organizationId;
  final String userId;
  final List<String> roleIds;
  final String locale;
  final Map<String, String> attributes;
}

@immutable
class EnterpriseAiResponse {
  const EnterpriseAiResponse({
    required this.text,
    this.citations = const [],
    this.usedTools = const [],
  });

  final String text;
  final List<String> citations;
  final List<String> usedTools;
}

/// Enterprise-scoped assistant port. Wraps the shared `after_core` AI SDK
/// with organization + role plumbing so each vertical can add its own
/// tools without changing the OS layer.
abstract class EnterpriseAiAssistant {
  Future<EnterpriseAiResponse> ask({
    required String prompt,
    required EnterpriseAiContext context,
  });
}

/// Deterministic mock used by scaffolds & tests. Echoes tenant + prompt so
/// UI wiring can be verified without a real LLM key.
class MockEnterpriseAiAssistant implements EnterpriseAiAssistant {
  const MockEnterpriseAiAssistant();

  @override
  Future<EnterpriseAiResponse> ask({
    required String prompt,
    required EnterpriseAiContext context,
  }) async {
    final text =
        '[mock ai][org:${context.organizationId}][user:${context.userId}] '
        '$prompt';
    return EnterpriseAiResponse(text: text);
  }
}
