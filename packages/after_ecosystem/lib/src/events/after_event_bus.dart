import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../identity/after_id.dart';

/// Envelope for every ecosystem event (ADR-004).
@immutable
class AfterEcosystemEvent {
  const AfterEcosystemEvent({
    required this.id,
    required this.type,
    required this.sourceProductId,
    required this.occurredAt,
    this.afterId,
    this.organizationId,
    this.correlationId,
    this.payload = const <String, Object?>{},
    this.schemaVersion = 1,
    this.idempotencyKey,
    this.partitionKey,
    this.signature,
  });

  final String id;

  /// Dotted type, e.g. `garage.maintenance.completed`.
  final String type;
  final String sourceProductId;
  final AfterId? afterId;
  final String? organizationId;
  final DateTime occurredAt;
  final String? correlationId;
  final Map<String, Object?> payload;

  /// Contract version for durable adapters.
  final int schemaVersion;

  /// Deduplicate at-least-once delivery.
  final String? idempotencyKey;

  /// Partition hint (afterId or orgId) for ordered consumers.
  final String? partitionKey;

  /// Optional HMAC / signed proof of [sourceProductId].
  final String? signature;

  bool matches(String typePrefix) =>
      type == typePrefix || type.startsWith('$typePrefix.');

  String get resolvedPartitionKey =>
      partitionKey ?? afterId?.value ?? organizationId ?? sourceProductId;

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type,
        'sourceProductId': sourceProductId,
        if (afterId != null) 'afterId': afterId!.value,
        if (organizationId != null) 'organizationId': organizationId,
        'occurredAt': occurredAt.toIso8601String(),
        if (correlationId != null) 'correlationId': correlationId,
        'payload': payload,
        'schemaVersion': schemaVersion,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
        if (partitionKey != null) 'partitionKey': partitionKey,
        if (signature != null) 'signature': signature,
      };

  factory AfterEcosystemEvent.fromJson(Map<String, Object?> json) {
    return AfterEcosystemEvent(
      id: '${json['id'] ?? ''}',
      type: '${json['type'] ?? ''}',
      sourceProductId: '${json['sourceProductId'] ?? ''}',
      afterId: json['afterId'] == null ? null : AfterId('${json['afterId']}'),
      organizationId: json['organizationId'] as String?,
      occurredAt: DateTime.tryParse('${json['occurredAt'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      correlationId: json['correlationId'] as String?,
      payload: json['payload'] is Map
          ? (json['payload']! as Map).map(
              (k, v) => MapEntry('$k', v as Object?),
            )
          : const {},
      schemaVersion: json['schemaVersion'] is int
          ? json['schemaVersion']! as int
          : int.tryParse('${json['schemaVersion'] ?? 1}') ?? 1,
      idempotencyKey: json['idempotencyKey'] as String?,
      partitionKey: json['partitionKey'] as String?,
      signature: json['signature'] as String?,
    );
  }
}

/// Well-known event type prefixes — products extend with their domain.
abstract final class AfterEventTypes {
  static const garageMaintenanceScheduled = 'garage.maintenance.scheduled';
  static const garageMaintenanceCompleted = 'garage.maintenance.completed';
  static const financeExpenseRecorded = 'finance.expense.recorded';
  static const financeBudgetThreshold = 'finance.budget.threshold';
  static const calendarEventCreated = 'calendar.event.created';
  static const calendarEventUpdated = 'calendar.event.updated';
  static const travelTripPlanned = 'travel.trip.planned';
  static const healthVitalsLogged = 'health.vitals.logged';
  static const familyMemberUpdated = 'family.member.updated';
  static const kidsVaccineDue = 'kids.vaccine.due';
  static const kidsAppointmentScheduled = 'kids.appointment.scheduled';
  static const kidsMilestoneReached = 'kids.milestone.reached';
  static const kidsAllowanceUpdated = 'kids.allowance.updated';
  static const sportsWorkoutCompleted = 'sports.workout.completed';
  static const sportsMatchKickoff = 'sports.match.kickoff';
  static const sportsMatchFinished = 'sports.match.finished';
  static const sportsFantasyUpdated = 'sports.fantasy.updated';
  static const gamesWishlistUpdated = 'games.wishlist.updated';
  static const gamesAchievementUnlocked = 'games.achievement.unlocked';
  static const gamesLibrarySynced = 'games.library.synced';
  static const findPresenceUpdated = 'find.presence.updated';
  static const findShareStarted = 'find.share.started';
  static const findShareEnded = 'find.share.ended';
  static const findSafeZoneEntered = 'find.safezone.entered';
  static const findSafeZoneExited = 'find.safezone.exited';
  static const findSosTriggered = 'find.sos.triggered';
  static const findSosResolved = 'find.sos.resolved';
  static const findEtaUpdated = 'find.eta.updated';
  static const findPlaceRecognized = 'find.place.recognized';
  static const findAnomalyDetected = 'find.anomaly.detected';
  static const findVehicleForgotten = 'find.vehicle.forgotten';
  static const findChildSchoolArrival = 'find.child.school_arrival';
  static const findHomeArrival = 'find.home.arrival';
  static const findEmergencyLocation = 'find.emergency.location';
  static const documentsShared = 'documents.document.shared';
  static const notificationPosted = 'notifications.notification.posted';
  static const enterpriseWorkflowTransitioned =
      'enterprise.workflow.transitioned';
}

/// Publish / subscribe fabric — Kafka / PubSub adapters later.
abstract class AfterEventBus {
  Future<void> publish(AfterEcosystemEvent event);

  /// Convenience factory for publishers.
  Future<void> emit({
    required String type,
    required String sourceProductId,
    AfterId? afterId,
    String? organizationId,
    String? correlationId,
    Map<String, Object?> payload = const {},
    DateTime? occurredAt,
    int schemaVersion = 1,
    String? idempotencyKey,
    String? partitionKey,
    String? signature,
  });

  Stream<AfterEcosystemEvent> subscribe({String? typePrefix});

  List<AfterEcosystemEvent> recent({int limit = 50});

  /// Cursor history (ADR-004) — preferred over [recent] for scale.
  Page<AfterEcosystemEvent> historyPage(PageQuery query);
}

/// In-memory bus for **scaffold / tests only** (ADR-004, ADR-007).
///
/// Do not use in [AfterBootstrapMode.production].
class InMemoryAfterEventBus implements AfterEventBus {
  InMemoryAfterEventBus({
    Uuid? uuid,
    this.requireSignature = false,
    this.allowedSourceProductIds,
  }) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  /// When true, [publish] rejects events without [AfterEcosystemEvent.signature].
  final bool requireSignature;

  /// Optional allow-list to reduce spoofed [sourceProductId] in scaffold.
  final Set<String>? allowedSourceProductIds;

  final _controller = StreamController<AfterEcosystemEvent>.broadcast();
  final List<AfterEcosystemEvent> _history = [];
  final Set<String> _seenIdempotency = {};

  @override
  Future<void> publish(AfterEcosystemEvent event) async {
    if (requireSignature &&
        (event.signature == null || event.signature!.isEmpty)) {
      throw StateError(
        'AfterEventBus: signature required for source '
        '"${event.sourceProductId}"',
      );
    }
    final allowed = allowedSourceProductIds;
    if (allowed != null && !allowed.contains(event.sourceProductId)) {
      throw StateError(
        'AfterEventBus: sourceProductId "${event.sourceProductId}" not allowed',
      );
    }
    final key = event.idempotencyKey;
    if (key != null && key.isNotEmpty) {
      if (_seenIdempotency.contains(key)) return;
      _seenIdempotency.add(key);
    }
    _history.add(event);
    _controller.add(event);
  }

  @override
  Future<void> emit({
    required String type,
    required String sourceProductId,
    AfterId? afterId,
    String? organizationId,
    String? correlationId,
    Map<String, Object?> payload = const {},
    DateTime? occurredAt,
    int schemaVersion = 1,
    String? idempotencyKey,
    String? partitionKey,
    String? signature,
  }) {
    final id = 'evt_${_uuid.v4()}';
    return publish(
      AfterEcosystemEvent(
        id: id,
        type: type,
        sourceProductId: sourceProductId,
        afterId: afterId,
        organizationId: organizationId,
        correlationId: correlationId,
        payload: payload,
        occurredAt: occurredAt ?? DateTime.now().toUtc(),
        schemaVersion: schemaVersion,
        idempotencyKey: idempotencyKey ?? id,
        partitionKey: partitionKey ?? afterId?.value ?? organizationId,
        signature: signature,
      ),
    );
  }

  @override
  Stream<AfterEcosystemEvent> subscribe({String? typePrefix}) {
    if (typePrefix == null || typePrefix.isEmpty) {
      return _controller.stream;
    }
    return _controller.stream.where((e) => e.matches(typePrefix));
  }

  @override
  List<AfterEcosystemEvent> recent({int limit = 50}) {
    if (_history.length <= limit) {
      return List.unmodifiable(_history);
    }
    return List.unmodifiable(
      _history.sublist(_history.length - limit),
    );
  }

  @override
  Page<AfterEcosystemEvent> historyPage(PageQuery query) =>
      Page.fromList(List<AfterEcosystemEvent>.unmodifiable(_history), query);

  Future<void> dispose() async => _controller.close();
}
