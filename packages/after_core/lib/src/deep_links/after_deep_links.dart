import 'dart:async';

import 'package:app_links/app_links.dart';

import '../errors/after_exception.dart';

/// Parsed deep link for Super App routing.
class AfterDeepLink {
  const AfterDeepLink({
    required this.uri,
    this.host,
    this.path,
    this.queryParameters = const {},
  });

  factory AfterDeepLink.fromUri(Uri uri) {
    return AfterDeepLink(
      uri: uri,
      host: uri.host,
      path: uri.path,
      queryParameters: uri.queryParameters,
    );
  }

  final Uri uri;
  final String? host;
  final String? path;
  final Map<String, String> queryParameters;

  bool get isMagicLink =>
      queryParameters.containsKey('token') ||
      path?.contains('auth') == true ||
      path?.contains('magic') == true;
}

/// Deep link / universal link service.
abstract class AfterDeepLinkService {
  Future<AfterDeepLink?> getInitialLink();
  Stream<AfterDeepLink> get onLink;
  Future<void> dispose();
}

class AppLinksAfterDeepLinkService implements AfterDeepLinkService {
  AppLinksAfterDeepLinkService({AppLinks? appLinks})
      : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  final _controller = StreamController<AfterDeepLink>.broadcast();

  Future<void> start() async {
    _sub ??= _appLinks.uriLinkStream.listen(
      (uri) => _controller.add(AfterDeepLink.fromUri(uri)),
      onError: (Object e, StackTrace st) {
        _controller.addError(
          AfterDeepLinkException('deep_link_stream_error', cause: e),
          st,
        );
      },
    );
  }

  @override
  Future<AfterDeepLink?> getInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) return null;
      return AfterDeepLink.fromUri(uri);
    } catch (e) {
      throw AfterDeepLinkException('deep_link_initial_failed', cause: e);
    }
  }

  @override
  Stream<AfterDeepLink> get onLink => _controller.stream;

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}

class NoOpAfterDeepLinkService implements AfterDeepLinkService {
  const NoOpAfterDeepLinkService();

  @override
  Future<AfterDeepLink?> getInitialLink() async => null;

  @override
  Stream<AfterDeepLink> get onLink => const Stream.empty();

  @override
  Future<void> dispose() async {}
}
