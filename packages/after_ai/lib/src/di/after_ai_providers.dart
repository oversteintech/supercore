import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../capabilities/after_ai_capability.dart';
import '../platform/after_ai_platform.dart';

/// Override in each Super App composition root with a domain [AfterAiProfile].
final afterAiProfileProvider = Provider<AfterAiProfile>((ref) {
  return AfterAiProfile.conversationOnly('after_unset');
});

/// Singleton AfterAI Platform for the running Super App.
final afterAiPlatformProvider = Provider<AfterAiPlatform>((ref) {
  return AfterAiPlatform(profile: ref.watch(afterAiProfileProvider));
});
