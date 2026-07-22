import 'package:after_core/after_core.dart';
import 'package:after_ecosystem/after_ecosystem.dart';
import 'package:after_enterprise/after_enterprise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BridgingCalendarRepository', () {
    test('createEvent upserts into ecosystem listMerged', () async {
      final fabric = AfterEcosystemFabric.inMemory();
      final bridge = BridgingCalendarRepository(
        inner: InMemoryCalendarRepository(),
        ecosystem: fabric.calendar,
        sourceProductId: 'super_hospital',
      );

      final start = DateTime.utc(2026, 7, 20, 9);
      final end = start.add(const Duration(hours: 1));
      final created = await bridge.createEvent(
        CalendarEvent(
          id: 'evt_bridge_1',
          organizationId: 'org_a',
          title: 'Rounds',
          start: start,
          end: end,
        ),
      );

      expect(created.id, 'evt_bridge_1');
      final merged = await fabric.calendar.listMerged(
        afterId: const AfterId('any_user'),
      );
      expect(merged, hasLength(1));
      expect(merged.single.title, 'Rounds');
      expect(merged.single.sourceProductId, 'super_hospital');
      expect(merged.single.organizationId, 'org_a');
    });

    test('deleteEvent removes from ecosystem calendar', () async {
      final fabric = AfterEcosystemFabric.inMemory();
      final bridge = BridgingCalendarRepository(
        inner: InMemoryCalendarRepository(),
        ecosystem: fabric.calendar,
        sourceProductId: 'super_hospital',
      );
      final start = DateTime.utc(2026, 7, 21, 10);
      await bridge.createEvent(
        CalendarEvent(
          id: 'evt_del',
          organizationId: 'org_a',
          title: 'Temp',
          start: start,
          end: start.add(const Duration(minutes: 30)),
        ),
      );
      await bridge.deleteEvent('evt_del');
      final merged = await fabric.calendar.listMerged(
        afterId: const AfterId('any_user'),
      );
      expect(merged, isEmpty);
    });
  });

  group('BridgingEnterpriseNotificationDispatcher', () {
    test('send posts into After Notification Center inbox', () async {
      final fabric = AfterEcosystemFabric.inMemory();
      final bridge = BridgingEnterpriseNotificationDispatcher(
        inner: InMemoryEnterpriseNotificationDispatcher(),
        notificationCenter: fabric.notifications,
        sourceProductId: 'super_hospital',
      );

      final stored = await bridge.send(
        const EnterpriseNotification(
          id: 'ntf_1',
          organizationId: 'org_a',
          recipientId: 'user_42',
          title: 'Lab ready',
          body: 'CBC results available',
          channel: EnterpriseNotificationChannel.inApp,
          data: {'deepLink': 'after://super_hospital/labs/1'},
        ),
      );

      expect(stored.id, 'ntf_1');
      final inbox = await fabric.notifications.inbox(const AfterId('user_42'));
      expect(inbox, hasLength(1));
      expect(inbox.single.title, 'Lab ready');
      expect(inbox.single.sourceProductId, 'super_hospital');
      expect(inbox.single.deepLink, 'after://super_hospital/labs/1');
    });

    test('send optionally delivers via device channel', () async {
      final fabric = AfterEcosystemFabric.inMemory();
      final device = _RecordingLocalNotifications();
      final bridge = BridgingEnterpriseNotificationDispatcher(
        inner: InMemoryEnterpriseNotificationDispatcher(),
        notificationCenter: fabric.notifications,
        sourceProductId: 'super_hospital',
        deviceChannel: device,
      );

      await bridge.send(
        const EnterpriseNotification(
          id: 'ntf_device',
          organizationId: 'org_a',
          recipientId: 'user_7',
          title: 'Ping',
          body: 'Device delivery',
          channel: EnterpriseNotificationChannel.push,
        ),
      );

      expect(device.shown, hasLength(1));
      expect(device.shown.single.title, 'Ping');
      final inbox = await fabric.notifications.inbox(const AfterId('user_7'));
      expect(inbox, hasLength(1));
    });
  });
}

class _RecordingLocalNotifications implements AfterLocalNotifications {
  final List<AfterLocalNotification> shown = [];

  @override
  Future<bool> initialize({void Function(String? payload)? onTap}) async =>
      true;

  @override
  Future<void> show(AfterLocalNotification notification) async {
    shown.add(notification);
  }

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}
