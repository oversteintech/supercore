import 'package:after_core/after_core.dart';

import '../api/after_product_api.dart';
import '../context/after_ecosystem_ai_context.dart';
import '../events/after_event_bus.dart';
import '../identity/after_id.dart';
import '../services/after_shared_services.dart';
import '../subscription/after_plus.dart';

/// Single façade — every product depends on this, not on sibling apps.
class AfterEcosystemFabric {
  AfterEcosystemFabric({
    required this.identity,
    required this.plus,
    required this.events,
    required this.apis,
    required this.interop,
    required this.cloud,
    required this.calendar,
    required this.notifications,
    required this.search,
    required this.wallet,
    required this.family,
    required this.marketplace,
    required this.documents,
    required this.analytics,
    required this.settings,
    required this.personalization,
    this.mode = AfterBootstrapMode.scaffold,
  }) : aiContextBuilder = AfterEcosystemAiContextBuilder(
          eventBus: events,
          calendar: calendar,
          notifications: notifications,
          family: family,
          plus: plus,
        ) {
    if (mode == AfterBootstrapMode.production) {
      if (events is InMemoryAfterEventBus) {
        throw StateError(
          'AfterEcosystemFabric: InMemoryAfterEventBus is not allowed in '
          'production bootstrap mode (ADR-007).',
        );
      }
    }
  }

  /// Default in-memory fabric for scaffolds / tests (ADR-007 scaffold).
  factory AfterEcosystemFabric.inMemory({
    AfterInteropAuditHook? onAudited,
    List<Map<String, Object?>>? auditLog,
  }) {
    final apis = InMemoryAfterProductApiRegistry();
    final log = auditLog ?? <Map<String, Object?>>[];
    final hook = onAudited ??
        (AfterProductApiCall call, {required bool allowed, Object? error}) {
          log.add({
            'target': call.targetProductId,
            'endpoint': call.endpoint,
            'caller': call.callerProductId,
            'allowed': allowed,
            if (error != null) 'error': '$error',
          });
        };
    return AfterEcosystemFabric(
      mode: AfterBootstrapMode.scaffold,
      identity: InMemoryAfterIdRepository(),
      plus: InMemoryAfterPlusRepository(),
      events: InMemoryAfterEventBus(),
      apis: apis,
      interop: PolicyAfterSecureInteropBridge(
        registry: apis,
        onAudited: hook,
      ),
      cloud: InMemoryAfterCloudStore(),
      calendar: InMemoryAfterEcosystemCalendar(),
      notifications: InMemoryAfterNotificationCenter(),
      search: InMemoryAfterEcosystemSearchIndex(),
      wallet: InMemoryAfterWallet(),
      family: InMemoryAfterFamilyGraph(),
      marketplace: InMemoryAfterMarketplace(),
      documents: InMemoryAfterEcosystemDocuments(),
      analytics: InMemoryAfterEcosystemAnalytics(),
      settings: InMemoryAfterEcosystemSettings(),
      personalization: InMemoryAfterPersonalization(),
    );
  }

  final AfterBootstrapMode mode;
  final AfterIdRepository identity;
  final AfterPlusRepository plus;
  final AfterEventBus events;
  final AfterProductApiRegistry apis;
  final AfterSecureInteropBridge interop;
  final AfterCloudStore cloud;
  final AfterEcosystemCalendar calendar;
  final AfterNotificationCenter notifications;
  final AfterEcosystemSearchIndex search;

  /// Ledger-only wallet façade (ADR-010) — not payment rails.
  final AfterWallet wallet;
  final AfterFamilyGraph family;
  final AfterMarketplace marketplace;
  final AfterEcosystemDocuments documents;
  final AfterEcosystemAnalytics analytics;
  final AfterEcosystemSettings settings;
  final AfterPersonalization personalization;
  final AfterEcosystemAiContextBuilder aiContextBuilder;

  /// Public invoke path — always audited via [interop] (ADR-006).
  Future<Object?> invoke({
    required AfterProductApiCall call,
    required AfterEcosystemLine callerLine,
  }) =>
      interop.call(call: call, callerLine: callerLine);
}
