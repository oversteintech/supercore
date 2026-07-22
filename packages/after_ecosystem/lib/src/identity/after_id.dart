import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:meta/meta.dart';

/// Stable ecosystem identity — one account across every After product.
@immutable
class AfterId {
  const AfterId(this.value);

  final String value;

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is AfterId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Session bound to After ID (SSO across modules).
@immutable
class AfterIdentitySession {
  const AfterIdentitySession({
    required this.afterId,
    required this.user,
    required this.issuedAt,
    this.accessToken,
    this.refreshToken,
    this.organizationIds = const <String>[],
  });

  final AfterId afterId;
  final AfterAuthUser user;
  final DateTime issuedAt;
  final String? accessToken;
  final String? refreshToken;

  /// Enterprise orgs this identity may act within.
  final List<String> organizationIds;

  bool get isAnonymous => user.isAnonymous;
}

/// Port — single sign-on / account for the ecosystem.
abstract class AfterIdRepository {
  Stream<AfterIdentitySession?> watchSession();

  Future<AfterIdentitySession?> currentSession();

  Future<AfterIdentitySession> signInWithAuthUser(AfterAuthUser user);

  Future<void> signOut();

  /// Link an existing per-app auth user into the ecosystem After ID.
  Future<AfterId> ensureAfterId(AfterAuthUser user);
}

/// In-memory After ID — scaffolds and tests.
class InMemoryAfterIdRepository implements AfterIdRepository {
  AfterIdentitySession? _session;
  final _controller = StreamController<AfterIdentitySession?>.broadcast();

  @override
  Stream<AfterIdentitySession?> watchSession() async* {
    yield _session;
    yield* _controller.stream;
  }

  @override
  Future<AfterIdentitySession?> currentSession() async => _session;

  @override
  Future<AfterId> ensureAfterId(AfterAuthUser user) async {
    final existing = user.claims['afterId'];
    if (existing is String && existing.isNotEmpty) {
      return AfterId(existing);
    }
    return AfterId('aid_${user.uid}');
  }

  @override
  Future<AfterIdentitySession> signInWithAuthUser(AfterAuthUser user) async {
    final id = await ensureAfterId(user);
    final linked = user.copyWith(
      claims: {...user.claims, 'afterId': id.value},
    );
    _session = AfterIdentitySession(
      afterId: id,
      user: linked,
      issuedAt: DateTime.now().toUtc(),
      accessToken: 'tok_${id.value}',
    );
    _controller.add(_session);
    return _session!;
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _controller.add(null);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
