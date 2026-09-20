import 'package:shared_preferences/shared_preferences.dart';

import 'after_durable_sync_outbox.dart';
import 'after_sync_operation.dart';

/// Community listing / post outbox — same durable prefs store, scoped keys.
class AfterCommunitySyncOutbox extends AfterDurableSyncOutbox {
  AfterCommunitySyncOutbox(
    SharedPreferences preferences, {
    super.scope,
    super.cloudMirror,
    super.uidProvider,
  }) : super(preferences, baseKey: 'community_sync_outbox_v1');

  static const entityListing = 'listing';
  static const entityPost = 'post';

  Future<void> enqueuePostUpsert(Map<String, Object?> json) {
    return enqueuePayload(
      entityType: entityPost,
      entityId: json['id']?.toString() ?? '',
      operationType: AfterSyncOperationType.update,
      payload: Map<String, dynamic>.from(json),
    );
  }

  Future<void> enqueuePostDelete({
    required String postId,
    required String roomKey,
  }) {
    return enqueuePayload(
      entityType: entityPost,
      entityId: postId,
      operationType: AfterSyncOperationType.delete,
      payload: {'roomKey': roomKey},
    );
  }

  Future<void> enqueueListingUpsert(Map<String, Object?> json) {
    return enqueuePayload(
      entityType: entityListing,
      entityId: json['id']?.toString() ?? '',
      operationType: AfterSyncOperationType.update,
      payload: Map<String, dynamic>.from(json),
    );
  }

  Future<void> enqueueListingDelete(String listingId) {
    return enqueuePayload(
      entityType: entityListing,
      entityId: listingId,
      operationType: AfterSyncOperationType.delete,
      payload: const {},
    );
  }
}
