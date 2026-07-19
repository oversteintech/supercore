import '../utils/after_utils.dart';

/// App-agnostic analytics surface.
abstract class AfterAnalytics {
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  });

  Future<void> setUserId(String? userId);

  Future<void> setUserProperty(String name, String? value);

  Future<void> logScreenView(String screenName, {String? screenClass}) =>
      logEvent(
        'screen_view',
        parameters: {
          'screen_name': screenName,
          if (screenClass != null) 'screen_class': screenClass,
        },
      );
}

class NoOpAfterAnalytics implements AfterAnalytics {
  const NoOpAfterAnalytics();

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {}
}

/// In-memory analytics for tests / debug inspection.
class MemoryAfterAnalytics implements AfterAnalytics {
  final List<({String name, Map<String, Object?> params})> events = [];
  String? userId;
  final Map<String, String?> properties = {};

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    events.add((name: name, params: AfterUtils.scrubExtras(parameters)));
  }

  @override
  Future<void> setUserId(String? userId) async {
    this.userId = userId;
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    properties[name] = value;
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) =>
      logEvent(
        'screen_view',
        parameters: {
          'screen_name': screenName,
          if (screenClass != null) 'screen_class': screenClass,
        },
      );
}

/// Product funnel helpers (optional convenience).
extension AfterAnalyticsProduct on AfterAnalytics {
  Future<void> logSignUp(String method) =>
      logEvent('sign_up', parameters: {'method': method});

  Future<void> logLogin(String method) =>
      logEvent('login', parameters: {'method': method});

  Future<void> logPurchase({
    required String productId,
    required String plan,
    String? currency,
    double? value,
  }) =>
      logEvent(
        'purchase',
        parameters: {
          'product_id': productId,
          'plan': plan,
          if (currency != null) 'currency': currency,
          if (value != null) 'value': value,
        },
      );

  Future<void> logFeatureGate({
    required String feature,
    required String planRequired,
  }) =>
      logEvent(
        'feature_gate',
        parameters: {
          'feature': feature,
          'plan_required': planRequired,
        },
      );
}
