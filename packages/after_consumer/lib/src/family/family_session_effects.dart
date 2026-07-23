import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_cloud_sync.dart';
import 'family_profile_identity.dart';

/// Runs cloud restore + profile-identity hydrate after auth settles.
///
/// Profile settings in every Super App read [familyProfileIdentityProvider];
/// this keeps that store seeded from [afterAuthSessionProvider].
class FamilySessionEffects extends ConsumerStatefulWidget {
  const FamilySessionEffects({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<FamilySessionEffects> createState() =>
      _FamilySessionEffectsState();
}

class _FamilySessionEffectsState extends ConsumerState<FamilySessionEffects> {
  String? _restoredForUid;
  String? _hydratedForUid;

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
        _hydratedForUid = null;
        return;
      }
      if (_restoredForUid != uid) {
        _restoredForUid = uid;
        unawaited(
          ref.read(familyCloudSyncProvider.notifier).restoreFromCloudIfEmpty(),
        );
      }
      if (_hydratedForUid != uid) {
        _hydratedForUid = uid;
        final user = session.user;
        unawaited(
          ref.read(familyProfileIdentityProvider.notifier).hydrateFromAuthIfEmpty(
                displayName: user?.displayName,
                email: user?.email,
                phoneNumber: user?.phoneNumber,
              ),
        );
      }
    });
    return widget.child;
  }
}
