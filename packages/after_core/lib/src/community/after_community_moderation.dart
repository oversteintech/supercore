import 'after_community_moderation_status.dart';
import 'after_community_post.dart';
import 'after_community_room_scope.dart';

enum AfterCommunityModerationBlockReason {
  profanity,
  superAdminRateLimit,
  tooManyPending,
}

class AfterCommunityModerationResult {
  const AfterCommunityModerationResult._({
    required this.allowed,
    this.reason,
    this.publishedAtMillis,
    this.moderationStatus = AfterCommunityModerationStatus.published,
  });

  const AfterCommunityModerationResult.allowed({
    required int publishedAtMillis,
    AfterCommunityModerationStatus moderationStatus =
        AfterCommunityModerationStatus.published,
  }) : this._(
          allowed: true,
          publishedAtMillis: publishedAtMillis,
          moderationStatus: moderationStatus,
        );

  const AfterCommunityModerationResult.blocked(
    AfterCommunityModerationBlockReason reason,
  ) : this._(allowed: false, reason: reason);

  final bool allowed;
  final AfterCommunityModerationBlockReason? reason;
  final int? publishedAtMillis;
  final AfterCommunityModerationStatus moderationStatus;

  bool get isDelayed =>
      moderationStatus == AfterCommunityModerationStatus.pending;
}

/// Shared new-post moderation rules (profanity + super-admin rate limits).
abstract final class AfterCommunityModeration {
  AfterCommunityModeration._();

  static const superAdminGlobalDelay = Duration(hours: 2);
  static const superAdminGlobalWindow = Duration(hours: 2);
  static const superAdminMaxGlobalPostsPerWindow = 3;
  static const superAdminMaxPendingGlobalPosts = 2;

  static AfterCommunityModerationResult validateNewPost({
    required String title,
    required String body,
    required AfterCommunityRoomScope roomScope,
    required bool isSuperAdmin,
    required String authorUid,
    required List<AfterCommunityPost> existingPosts,
    required int nowMillis,
    required bool Function(String text) containsBannedContent,
  }) {
    if (containsBannedContent(title) || containsBannedContent(body)) {
      return const AfterCommunityModerationResult.blocked(
        AfterCommunityModerationBlockReason.profanity,
      );
    }

    final needsDelay = isSuperAdmin &&
        (roomScope == AfterCommunityRoomScope.worldGlobal ||
            roomScope == AfterCommunityRoomScope.countryGlobal);

    if (!needsDelay) {
      return AfterCommunityModerationResult.allowed(
        publishedAtMillis: nowMillis,
      );
    }

    final windowStart = nowMillis - superAdminGlobalWindow.inMilliseconds;
    final recentGlobalPosts = existingPosts.where((post) {
      if (post.authorUid != authorUid) return false;
      if (post.roomScope != AfterCommunityRoomScope.worldGlobal &&
          post.roomScope != AfterCommunityRoomScope.countryGlobal) {
        return false;
      }
      return post.createdAtMillis >= windowStart;
    }).length;

    if (recentGlobalPosts >= superAdminMaxGlobalPostsPerWindow) {
      return const AfterCommunityModerationResult.blocked(
        AfterCommunityModerationBlockReason.superAdminRateLimit,
      );
    }

    final pendingGlobalPosts = existingPosts.where((post) {
      if (post.authorUid != authorUid) return false;
      if (post.roomScope != AfterCommunityRoomScope.worldGlobal &&
          post.roomScope != AfterCommunityRoomScope.countryGlobal) {
        return false;
      }
      return post.moderationStatus == AfterCommunityModerationStatus.pending &&
          post.publishedAtMillis > nowMillis;
    }).length;

    if (pendingGlobalPosts >= superAdminMaxPendingGlobalPosts) {
      return const AfterCommunityModerationResult.blocked(
        AfterCommunityModerationBlockReason.tooManyPending,
      );
    }

    return AfterCommunityModerationResult.allowed(
      publishedAtMillis: nowMillis + superAdminGlobalDelay.inMilliseconds,
      moderationStatus: AfterCommunityModerationStatus.pending,
    );
  }

  static bool isVisibleToViewer(
    AfterCommunityPost post, {
    required String? viewerUid,
    required int nowMillis,
  }) {
    if (post.moderationStatus == AfterCommunityModerationStatus.rejected) {
      return false;
    }
    if (post.isPublished(nowMillis: nowMillis)) {
      return true;
    }
    return post.isPendingForViewer(
      nowMillis: nowMillis,
      viewerUid: viewerUid,
    );
  }

  static bool canViewPrivatePost({
    required AfterCommunityPost post,
    required String? viewerUid,
    required bool Function(String roomKey) viewerOwnsRoom,
    required AfterRoomInviteLookup invites,
  }) {
    if (post.roomScope != AfterCommunityRoomScope.privateRoom) return true;
    if (viewerUid != null && viewerUid == post.authorUid) return true;
    if (viewerOwnsRoom(post.roomKey)) return true;
    return invites.canViewRoom(
      roomKey: post.roomKey,
      viewerUid: viewerUid,
      ownerUid: post.authorUid,
    );
  }
}

/// Narrow invite lookup so moderation stays free of prefs coupling in tests.
abstract interface class AfterRoomInviteLookup {
  bool canViewRoom({
    required String roomKey,
    required String? viewerUid,
    required String? ownerUid,
  });
}
