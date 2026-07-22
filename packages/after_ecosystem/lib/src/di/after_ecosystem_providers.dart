import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/after_product_api.dart';
import '../context/after_ecosystem_ai_context.dart';
import '../events/after_event_bus.dart';
import '../fabric/after_ecosystem_fabric.dart';
import '../identity/after_id.dart';
import '../services/after_shared_services.dart';
import '../subscription/after_plus.dart';

/// Bootstrap mode for ecosystem composition (ADR-007).
final afterEcosystemBootstrapModeProvider = Provider<AfterBootstrapMode>((ref) {
  return AfterBootstrapMode.scaffold;
});

/// App-wide ecosystem fabric. Override with a cloud-backed implementation
/// at composition root — products never invent private identity/calendar/AI.
final afterEcosystemProvider = Provider<AfterEcosystemFabric>((ref) {
  final mode = ref.watch(afterEcosystemBootstrapModeProvider);
  if (mode == AfterBootstrapMode.production) {
    throw StateError(
      'afterEcosystemProvider: in-memory fabric is not allowed in production '
      'bootstrap mode. Override with durable adapters (ADR-007).',
    );
  }
  return AfterEcosystemFabric.inMemory();
});

final afterIdRepositoryProvider = Provider<AfterIdRepository>((ref) {
  return ref.watch(afterEcosystemProvider).identity;
});

final afterPlusRepositoryProvider = Provider<AfterPlusRepository>((ref) {
  return ref.watch(afterEcosystemProvider).plus;
});

final afterEventBusProvider = Provider<AfterEventBus>((ref) {
  return ref.watch(afterEcosystemProvider).events;
});

final afterProductApiRegistryProvider = Provider<AfterProductApiRegistry>((ref) {
  return ref.watch(afterEcosystemProvider).apis;
});

final afterSecureInteropBridgeProvider =
    Provider<AfterSecureInteropBridge>((ref) {
  return ref.watch(afterEcosystemProvider).interop;
});

final afterEcosystemCalendarProvider = Provider<AfterEcosystemCalendar>((ref) {
  return ref.watch(afterEcosystemProvider).calendar;
});

final afterNotificationCenterProvider =
    Provider<AfterNotificationCenter>((ref) {
  return ref.watch(afterEcosystemProvider).notifications;
});

final afterEcosystemSearchProvider = Provider<AfterEcosystemSearchIndex>((ref) {
  return ref.watch(afterEcosystemProvider).search;
});

final afterEcosystemAiContextBuilderProvider =
    Provider<AfterEcosystemAiContextBuilder>((ref) {
  return ref.watch(afterEcosystemProvider).aiContextBuilder;
});
