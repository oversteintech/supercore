import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notification payload.
class AfterLocalNotification {
  const AfterLocalNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.channelId = 'after_default',
    this.channelName = 'General',
  });

  final int id;
  final String title;
  final String body;
  final String? payload;
  final String channelId;
  final String channelName;
}

/// Local notifications port.
abstract class AfterLocalNotifications {
  Future<bool> initialize({
    void Function(String? payload)? onTap,
  });

  Future<void> show(AfterLocalNotification notification);

  Future<void> cancel(int id);

  Future<void> cancelAll();
}

class NoOpAfterLocalNotifications implements AfterLocalNotifications {
  const NoOpAfterLocalNotifications();

  @override
  Future<bool> initialize({void Function(String? payload)? onTap}) async => true;

  @override
  Future<void> show(AfterLocalNotification notification) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}

/// flutter_local_notifications implementation.
class FlutterAfterLocalNotifications implements AfterLocalNotifications {
  FlutterAfterLocalNotifications({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  void Function(String? payload)? _onTap;

  @override
  Future<bool> initialize({void Function(String? payload)? onTap}) async {
    _onTap = onTap;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    final ok = await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _onTap?.call(response.payload);
      },
    );
    return ok ?? false;
  }

  @override
  Future<void> show(AfterLocalNotification notification) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        notification.channelId,
        notification.channelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(
      notification.id,
      notification.title,
      notification.body,
      details,
      payload: notification.payload,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}

/// Remote push registration port (FCM / Huawei injected by Super App).
abstract class AfterRemotePush {
  Future<void> initialize();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
  Stream<Map<String, dynamic>> get onMessage;
}

class NoOpAfterRemotePush implements AfterRemotePush {
  const NoOpAfterRemotePush();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get onMessage => const Stream.empty();
}
