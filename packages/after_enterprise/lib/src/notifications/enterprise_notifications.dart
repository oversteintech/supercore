import 'package:meta/meta.dart';

enum EnterpriseNotificationChannel { push, email, sms, inApp }

@immutable
class EnterpriseNotification {
  const EnterpriseNotification({
    required this.id,
    required this.organizationId,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.channel,
    this.data = const {},
    this.sentAt,
    this.readAt,
  });

  final String id;
  final String organizationId;
  final String recipientId;
  final String title;
  final String body;
  final EnterpriseNotificationChannel channel;
  final Map<String, String> data;
  final DateTime? sentAt;
  final DateTime? readAt;

  EnterpriseNotification markRead(DateTime at) {
    return EnterpriseNotification(
      id: id,
      organizationId: organizationId,
      recipientId: recipientId,
      title: title,
      body: body,
      channel: channel,
      data: data,
      sentAt: sentAt,
      readAt: at,
    );
  }
}

/// Enterprise notification port. Bridges to `after_core` push / local notif
/// providers at composition time — this layer only owns tenant-scoped
/// business notifications (workflow updates, mentions, approvals).
abstract class EnterpriseNotificationDispatcher {
  Future<EnterpriseNotification> send(EnterpriseNotification notification);
  Future<List<EnterpriseNotification>> inbox({
    required String recipientId,
    String? organizationId,
    bool onlyUnread = false,
  });
  Future<void> markAsRead(String id);
}

class InMemoryEnterpriseNotificationDispatcher
    implements EnterpriseNotificationDispatcher {
  final Map<String, EnterpriseNotification> _all = {};
  var _nextId = 1;

  @override
  Future<EnterpriseNotification> send(
    EnterpriseNotification notification,
  ) async {
    final id = notification.id.isEmpty
        ? 'ntf_${_nextId++}'
        : notification.id;
    final stored = EnterpriseNotification(
      id: id,
      organizationId: notification.organizationId,
      recipientId: notification.recipientId,
      title: notification.title,
      body: notification.body,
      channel: notification.channel,
      data: notification.data,
      sentAt: notification.sentAt ?? DateTime.now().toUtc(),
      readAt: notification.readAt,
    );
    _all[id] = stored;
    return stored;
  }

  @override
  Future<List<EnterpriseNotification>> inbox({
    required String recipientId,
    String? organizationId,
    bool onlyUnread = false,
  }) async {
    return _all.values.where((n) {
      if (n.recipientId != recipientId) return false;
      if (organizationId != null && n.organizationId != organizationId) {
        return false;
      }
      if (onlyUnread && n.readAt != null) return false;
      return true;
    }).toList(growable: false);
  }

  @override
  Future<void> markAsRead(String id) async {
    final current = _all[id];
    if (current == null) return;
    _all[id] = current.markRead(DateTime.now().toUtc());
  }
}
