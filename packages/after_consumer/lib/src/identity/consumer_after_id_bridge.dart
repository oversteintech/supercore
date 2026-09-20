import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Links the local [afterAuthSessionProvider] user into the ecosystem After ID.
///
/// Products pass an [ensureAfterId] callback that talks to
/// `after_ecosystem`'s AfterIdRepository (or a durable adapter). The bridge
/// itself stays in `after_consumer` so apps never invent private SSO wiring.
///
/// Place under the authenticated shell (e.g. wrap [FamilyAuthGate] home or
/// MainShell). No-ops when signed out.
class ConsumerAfterIdBridge extends ConsumerStatefulWidget {
  const ConsumerAfterIdBridge({
    required this.child,
    required this.ensureAfterId,
    super.key,
  });

  final Widget child;

  /// Called once per authenticated uid that is not yet linked.
  final Future<void> Function(AfterAuthUser user) ensureAfterId;

  @override
  ConsumerState<ConsumerAfterIdBridge> createState() =>
      _ConsumerAfterIdBridgeState();
}

class _ConsumerAfterIdBridgeState extends ConsumerState<ConsumerAfterIdBridge> {
  String? _linkedUid;

  Future<void> _linkIfNeeded(AfterAuthSession session) async {
    final user = session.user;
    if (user == null || !session.isAuthenticated || user.isAnonymous) {
      _linkedUid = null;
      return;
    }
    if (_linkedUid == user.uid) return;
    _linkedUid = user.uid;
    try {
      await widget.ensureAfterId(user);
    } on Object {
      // Soft-fail: product shell must stay usable if ecosystem ID is offline.
      _linkedUid = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AfterAuthSession>>(afterAuthSessionProvider, (
      previous,
      next,
    ) {
      next.whenData(_linkIfNeeded);
    });
    final session = ref.watch(afterAuthSessionProvider).asData?.value;
    if (session != null) {
      unawaited(_linkIfNeeded(session));
    }
    return widget.child;
  }
}
