import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemoryAfterAnalytics', () {
    late MemoryAfterAnalytics analytics;

    setUp(() {
      analytics = MemoryAfterAnalytics();
    });

    test('logEvent adds to list', () async {
      await analytics.logEvent('test_event', parameters: {'foo': 'bar'});
      expect(analytics.events, hasLength(1));
      expect(analytics.events.first.name, 'test_event');
      expect(analytics.events.first.params['foo'], 'bar');
    });

    test('setUserId stores value', () async {
      await analytics.setUserId('user-123');
      expect(analytics.userId, 'user-123');
    });

    test('setUserProperty stores value', () async {
      await analytics.setUserProperty('theme', 'dark');
      expect(analytics.properties['theme'], 'dark');
    });

    test('logScreenView logs correct event', () async {
      await analytics.logScreenView('Home', screenClass: 'HomeScreen');
      expect(analytics.events.first.name, 'screen_view');
      expect(analytics.events.first.params['screen_name'], 'Home');
      expect(analytics.events.first.params['screen_class'], 'HomeScreen');
    });
  });

  group('AfterAnalyticsProduct extension', () {
    late MemoryAfterAnalytics analytics;

    setUp(() {
      analytics = MemoryAfterAnalytics();
    });

    test('logSignUp logs sign_up event', () async {
      await analytics.logSignUp('google');
      expect(analytics.events.first.name, 'sign_up');
      expect(analytics.events.first.params['method'], 'google');
    });

    test('logPurchase logs purchase event', () async {
      await analytics.logPurchase(
        productId: 'pro_monthly',
        plan: 'pro',
        currency: 'USD',
        value: 9.99,
      );
      expect(analytics.events.first.name, 'purchase');
      expect(analytics.events.first.params['product_id'], 'pro_monthly');
      expect(analytics.events.first.params['value'], 9.99);
    });
  });
}
