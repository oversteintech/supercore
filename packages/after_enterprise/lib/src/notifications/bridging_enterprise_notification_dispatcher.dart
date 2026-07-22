import 'package:after_core/after_core.dart';
import 'package:after_ecosystem/after_ecosystem.dart';

import 'enterprise_notifications.dart';

/// Enterprise notifications as a scoped writer into After Notification Center
/// (ADR-001 Phase 2).
///
/// [inner] keeps the tenant inbox; [send] also posts to the ecosystem center.
/// Optional [deviceChannel] is delivery-only (not a second inbox).
class BridgingEnterpriseNotificationDispatcher
    implements EnterpriseNotificationDispatcher {
  BridgingEnterpriseNotificationDispatcher({
    required EnterpriseNotificationDispatcher inner,
    required AfterNotificationCenter notificationCenter,
    required this.sourceProductId,
    this.deviceChannel,
  })  : _inner = inner,
        _center = notificationCenter;

  final EnterpriseNotificationDispatcher _inner;
  final AfterNotificationCenter _center;

  /// Catalog / package id of the writing product (e.g. `super_hospital`).
  final String sourceProductId;

  /// Optional device delivery (local/push). Never replaces Notification Center.
  final AfterLocalNotifications? deviceChannel;

  @override
  Future<EnterpriseNotification> send(
    EnterpriseNotification notification,
  ) async {
    final stored = await _inner.send(notification);
    final afterId = AfterId(stored.recipientId);
    await _center.post(
      AfterEcosystemNotification(
        id: stored.id,
        title: stored.title,
        body: stored.body,
        sourceProductId: sourceProductId,
        createdAt: stored.sentAt ?? DateTime.now().toUtc(),
        afterId: afterId,
        deepLink: stored.data['deepLink'],
      ),
    );
    final device = deviceChannel;
    if (device != null) {
      final hash = stored.id.hashCode & 0x7fffffff;
      await device.show(
        AfterLocalNotification(
          id: hash == 0 ? 1 : hash,
          title: stored.title,
          body: stored.body,
          payload: stored.data['deepLink'],
        ),
      );
    }
    return stored;
  }

  @override
  Future<List<EnterpriseNotification>> inbox({
    required String recipientId,
    required String organizationId,
    bool onlyUnread = false,
  }) =>
      _inner.inbox(
        recipientId: recipientId,
        organizationId: organizationId,
        onlyUnread: onlyUnread,
      );

  @override
  Future<void> markAsRead(String id) async {
    await _inner.markAsRead(id);
    await _center.markRead(id);
  }
}
