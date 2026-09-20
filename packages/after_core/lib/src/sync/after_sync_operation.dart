import 'package:meta/meta.dart';

enum AfterSyncOperationType { create, update, delete }

enum AfterSyncOperationStatus { pending, sending, completed, failed, conflict }

/// Durable outbox row shared by Super Apps.
@immutable
class AfterSyncOperation {
  AfterSyncOperation({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
    this.status = AfterSyncOperationStatus.pending,
    this.attempts = 0,
    int? retryCount,
    this.lastError,
    DateTime? createdAt,
    this.completedAt,
  })  : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        retryCount = retryCount ?? attempts;

  factory AfterSyncOperation.fromJson(Map<String, Object?> json) {
    final typeRaw = json['operationType']?.toString() ?? 'update';
    final statusRaw = json['status']?.toString() ?? 'pending';
    final payloadRaw = json['payload'];
    return AfterSyncOperation(
      operationId: json['operationId']?.toString() ?? '',
      entityType: json['entityType']?.toString() ?? '',
      entityId: json['entityId']?.toString() ?? '',
      operationType: AfterSyncOperationType.values.firstWhere(
        (value) => value.name == typeRaw,
        orElse: () => AfterSyncOperationType.update,
      ),
      payload: payloadRaw is Map
          ? Map<String, dynamic>.from(payloadRaw)
          : <String, dynamic>{},
      status: AfterSyncOperationStatus.values.firstWhere(
        (value) => value.name == statusRaw,
        orElse: () => AfterSyncOperationStatus.pending,
      ),
      attempts: (json['attempts'] as num?)?.toInt() ??
          (json['retryCount'] as num?)?.toInt() ??
          0,
      retryCount: (json['retryCount'] as num?)?.toInt() ??
          (json['attempts'] as num?)?.toInt() ??
          0,
      lastError: json['lastError']?.toString(),
      createdAt: _readDate(json['createdAt'] ?? json['createdAtMillis']),
      completedAt: _readDate(json['completedAt'] ?? json['completedAtMillis']),
    );
  }

  static DateTime? _readDate(Object? raw) {
    if (raw is DateTime) return raw;
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt(), isUtc: true);
    }
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  final String operationId;
  final String entityType;
  final String entityId;
  final AfterSyncOperationType operationType;
  final Map<String, dynamic> payload;
  final AfterSyncOperationStatus status;
  final int attempts;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? completedAt;

  static const int maxAttempts = 5;
  static const int maxRetries = maxAttempts;

  bool get canRetry =>
      status != AfterSyncOperationStatus.completed && attempts < maxAttempts;

  AfterSyncOperation copyWith({
    AfterSyncOperationStatus? status,
    int? attempts,
    int? retryCount,
    String? lastError,
    DateTime? completedAt,
  }) {
    final nextAttempts = retryCount ?? attempts ?? this.attempts;
    return AfterSyncOperation(
      operationId: operationId,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payload: payload,
      status: status ?? this.status,
      attempts: nextAttempts,
      retryCount: nextAttempts,
      lastError: lastError,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'operationId': operationId,
        'entityType': entityType,
        'entityId': entityId,
        'operationType': operationType.name,
        'payload': payload,
        'status': status.name,
        'attempts': attempts,
        'retryCount': retryCount,
        if (lastError != null) 'lastError': lastError,
        if (createdAt != null) 'createdAtMillis': createdAt!.millisecondsSinceEpoch,
        if (completedAt != null)
          'completedAtMillis': completedAt!.millisecondsSinceEpoch,
      };
}
