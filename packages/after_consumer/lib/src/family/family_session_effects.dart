import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_cloud_sync.dart';

/// Runs cloud restore once after the user becomes authenticated.
class FamilySessionEffects extends ConsumerStatefulWidget {
  const FamilySessionEffects({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<FamilySessionEffects> createState() =>
      _FamilySessionEffectsState();
}

class _FamilySessionEffectsState extends ConsumerState<FamilySessionEffects> {
  String? _restoredForUid;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AfterAuthSession>>(afterAuthSessionProvider, (
      previous,
      next,
    ) {
      final session = next.asData?.value;
      final uid = session?.user?.uid;
      if (session == null || !session.isAuthenticated || uid == null) {
        _restoredForUid = null;
        return;
      }
      if (_restoredForUid == uid) return;
      _restoredForUid = uid;
      unawaited(
        ref.read(familyCloudSyncProvider.notifier).restoreFromCloudIfEmpty(),
      );
    });
    return widget.child;
  }
}
