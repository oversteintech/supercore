import 'package:dio/dio.dart';

import '../errors/after_exception.dart';
import '../network/after_http_client.dart';
import '../storage/secure_storage.dart';

/// Supported LLM providers (BYOK model).
enum AfterAiProviderKind {
  openai,
  claude,
  gemini,
  deepseek,
  grok,
  qwen,
  mistral,
  custom,
}

enum AfterAiProtocol {
  openAiCompatible,
  anthropic,
  googleGemini,
}

extension AfterAiProviderKindX on AfterAiProviderKind {
  String get defaultName => switch (this) {
        AfterAiProviderKind.openai => 'OpenAI',
        AfterAiProviderKind.claude => 'Claude',
        AfterAiProviderKind.gemini => 'Gemini',
        AfterAiProviderKind.deepseek => 'DeepSeek',
        AfterAiProviderKind.grok => 'Grok',
        AfterAiProviderKind.qwen => 'Qwen',
        AfterAiProviderKind.mistral => 'Mistral',
        AfterAiProviderKind.custom => 'Custom',
      };

  AfterAiProtocol get protocol => switch (this) {
        AfterAiProviderKind.claude => AfterAiProtocol.anthropic,
        AfterAiProviderKind.gemini => AfterAiProtocol.googleGemini,
        _ => AfterAiProtocol.openAiCompatible,
      };

  String get defaultBaseUrl => switch (this) {
        AfterAiProviderKind.openai => 'https://api.openai.com/v1',
        AfterAiProviderKind.claude => 'https://api.anthropic.com',
        AfterAiProviderKind.gemini =>
          'https://generativelanguage.googleapis.com',
        AfterAiProviderKind.deepseek => 'https://api.deepseek.com',
        AfterAiProviderKind.grok => 'https://api.x.ai/v1',
        AfterAiProviderKind.qwen =>
          'https://dashscope.aliyuncs.com/compatible-mode/v1',
        AfterAiProviderKind.mistral => 'https://api.mistral.ai/v1',
        AfterAiProviderKind.custom => '',
      };
}

class AfterAiMessage {
  const AfterAiMessage({required this.role, required this.content});

  final String role; // system | user | assistant
  final String content;
}

class AfterAiCompletionRequest {
  const AfterAiCompletionRequest({
    required this.messages,
    this.model,
    this.temperature = 0.4,
    this.maxTokens = 1024,
  });

  final List<AfterAiMessage> messages;
  final String? model;
  final double temperature;
  final int maxTokens;
}

class AfterAiCompletionResult {
  const AfterAiCompletionResult({
    required this.text,
    this.provider = AfterAiProviderKind.custom,
    this.model,
    this.raw,
  });

  final String text;
  final AfterAiProviderKind provider;
  final String? model;
  final Map<String, Object?>? raw;
}

/// Credential vault for BYOK keys — never log values.
class AfterAiCredentialVault {
  AfterAiCredentialVault(this._secure, {this.keyPrefix = 'after_ai_key_'});

  final AfterSecureStorage _secure;
  final String keyPrefix;

  Future<void> save(AfterAiProviderKind provider, String apiKey) =>
      _secure.write('$keyPrefix${provider.name}', apiKey.trim());

  Future<String?> read(AfterAiProviderKind provider) =>
      _secure.read('$keyPrefix${provider.name}');

  Future<void> delete(AfterAiProviderKind provider) =>
      _secure.delete('$keyPrefix${provider.name}');

  Future<bool> hasKey(AfterAiProviderKind provider) async {
    final v = await read(provider);
    return v != null && v.isNotEmpty;
  }
}

/// Minimal AI client port.
abstract class AfterAiClient {
  Future<AfterAiCompletionResult> complete(AfterAiCompletionRequest request);
}

/// OpenAI-compatible chat completions client.
class OpenAiCompatibleAfterAiClient implements AfterAiClient {
  OpenAiCompatibleAfterAiClient({
    required Dio dio,
    required this.apiKey,
    required this.baseUrl,
    this.provider = AfterAiProviderKind.openai,
    this.defaultModel = 'gpt-4o-mini',
  }) : _dio = dio;

  final Dio _dio;
  final String apiKey;
  final String baseUrl;
  final AfterAiProviderKind provider;
  final String defaultModel;

  @override
  Future<AfterAiCompletionResult> complete(
    AfterAiCompletionRequest request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/chat/completions',
        data: {
          'model': request.model ?? defaultModel,
          'temperature': request.temperature,
          'max_tokens': request.maxTokens,
          'messages': [
            for (final m in request.messages)
              {'role': m.role, 'content': m.content},
          ],
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data ?? const <String, dynamic>{};
      final choices = data['choices'];
      var text = '';
      if (choices is List && choices.isNotEmpty) {
        final first = choices.first;
        if (first is Map) {
          final message = first['message'];
          if (message is Map) {
            text = '${message['content'] ?? ''}';
          }
        }
      }
      return AfterAiCompletionResult(
        text: text.trim(),
        provider: provider,
        model: request.model ?? defaultModel,
        raw: data.map((k, v) => MapEntry(k, v as Object?)),
      );
    } on DioException catch (e) {
      throw AfterAiException(
        'ai_completion_failed',
        cause: mapDioException(e),
        code: provider.name,
      );
    }
  }
}

/// Intent routing stub — Super Apps plug product classifiers here.
abstract class AfterAiOrchestrator {
  Future<AfterAiCompletionResult> handle({
    required String userMessage,
    List<AfterAiMessage> history = const [],
    String? systemPrompt,
  });
}

/// Simple single-provider orchestrator with optional local fallback.
class SimpleAfterAiOrchestrator implements AfterAiOrchestrator {
  SimpleAfterAiOrchestrator({
    required this.client,
    this.systemPrompt =
        'You are Mate, a helpful AI assistant inside an AfterArtificial Super App.',
    this.localFallback,
  });

  final AfterAiClient? client;
  final String systemPrompt;
  final String Function(String message)? localFallback;

  @override
  Future<AfterAiCompletionResult> handle({
    required String userMessage,
    List<AfterAiMessage> history = const [],
    String? systemPrompt,
  }) async {
    final active = client;
    if (active == null) {
      final fallback = localFallback?.call(userMessage) ??
          'Connect an API key in Settings to unlock Mate AI.';
      return AfterAiCompletionResult(text: fallback);
    }
    return active.complete(
      AfterAiCompletionRequest(
        messages: [
          AfterAiMessage(
            role: 'system',
            content: systemPrompt ?? this.systemPrompt,
          ),
          ...history,
          AfterAiMessage(role: 'user', content: userMessage),
        ],
      ),
    );
  }
}
