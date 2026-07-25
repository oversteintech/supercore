import 'after_community_comment.dart';
import 'after_community_json.dart';
import 'after_community_moderation_status.dart';
import 'after_community_room_scope.dart';

/// Shared community feed post used by every After Super App.
///
/// Vertical apps map [roomKey] to their owned resource (vehicle, clinic, …).
/// JSON accepts legacy Garage keys `vehicleKey` / `vehicleLabel`.
class AfterCommunityPost {
  const AfterCommunityPost({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAtMillis,
    required this.roomKey,
    required this.roomLabel,
    this.countryCode,
    this.roomScope = AfterCommunityRoomScope.privateRoom,
    int? publishedAtMillis,
    this.moderationStatus = AfterCommunityModerationStatus.published,
    this.replyCount = 0,
    this.likes = 0,
    this.likedByUids = const [],
    this.comments = const [],
    this.imageUrls = const [],
    this.imageLocalNames = const [],
    this.audioUrl,
    this.audioLocalName,
  }) : publishedAtMillis = publishedAtMillis ?? createdAtMillis;

  factory AfterCommunityPost.fromJson(Map<String, dynamic> json) {
    final roomKey = json['roomKey']?.toString() ??
        json['vehicleKey']?.toString() ??
        '';
    final roomLabel = json['roomLabel']?.toString() ??
        json['vehicleLabel']?.toString() ??
        '';
    final scopeRaw = json['roomScope']?.toString();
    final scope = scopeRaw == null || scopeRaw.isEmpty
        ? afterCommunityScopeFromRoomKey(roomKey)
        : AfterCommunityRoomScope.values.firstWhere(
            (value) =>
                value.name == scopeRaw ||
                (scopeRaw == 'vehicle' &&
                    value == AfterCommunityRoomScope.privateRoom),
            orElse: () => afterCommunityScopeFromRoomKey(roomKey),
          );
    final createdAtMillis =
        afterCommunityReadJsonIntOr(json['createdAtMillis'], 0);
    final statusRaw = json['moderationStatus']?.toString();
    final moderationStatus = statusRaw == null || statusRaw.isEmpty
        ? AfterCommunityModerationStatus.published
        : AfterCommunityModerationStatus.values.firstWhere(
            (value) => value.name == statusRaw,
            orElse: () => AfterCommunityModerationStatus.published,
          );
    final commentsRaw = json['comments'];
    final comments = commentsRaw is List
        ? commentsRaw
            .whereType<Map>()
            .map(
              (item) => AfterCommunityComment.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <AfterCommunityComment>[];
    final likedBy = afterCommunityReadJsonStringList(json['likedByUids']);
    final likes = afterCommunityReadJsonIntOr(json['likes'], likedBy.length);
    final replyCount =
        afterCommunityReadJsonIntOr(json['replyCount'], comments.length);

    return AfterCommunityPost(
      id: json['id']?.toString() ?? '',
      authorUid: json['authorUid']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'User',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      createdAtMillis: createdAtMillis,
      roomKey: roomKey,
      roomLabel: roomLabel,
      countryCode: json['countryCode']?.toString(),
      roomScope: scope,
      publishedAtMillis:
          afterCommunityReadJsonInt(json['publishedAtMillis']) ??
              createdAtMillis,
      moderationStatus: moderationStatus,
      replyCount: replyCount,
      likes: likes,
      likedByUids: likedBy,
      comments: comments,
      imageUrls: afterCommunityReadJsonStringList(json['imageUrls']),
      imageLocalNames: afterCommunityReadJsonStringList(json['imageLocalNames']),
      audioUrl: json['audioUrl']?.toString(),
      audioLocalName: json['audioLocalName']?.toString(),
    );
  }

  final String id;
  final String authorUid;
  final String authorName;
  final String title;
  final String body;
  final String category;
  final int createdAtMillis;
  final String roomKey;
  final String roomLabel;
  final String? countryCode;
  final AfterCommunityRoomScope roomScope;
  final int publishedAtMillis;
  final AfterCommunityModerationStatus moderationStatus;
  final int replyCount;
  final int likes;
  final List<String> likedByUids;
  final List<AfterCommunityComment> comments;
  final List<String> imageUrls;
  final List<String> imageLocalNames;
  final String? audioUrl;
  final String? audioLocalName;

  /// Garage / legacy alias for [roomKey].
  String get vehicleKey => roomKey;

  /// Garage / legacy alias for [roomLabel].
  String get vehicleLabel => roomLabel;

  bool get isPrivateRoom => roomScope == AfterCommunityRoomScope.privateRoom;

  bool get hasImages => imageLocalNames.isNotEmpty || imageUrls.isNotEmpty;

  bool get hasAudio =>
      (audioLocalName != null && audioLocalName!.isNotEmpty) ||
      (audioUrl != null && audioUrl!.isNotEmpty);

  bool get hasMedia => hasImages || hasAudio;

  bool isLikedBy(String? uid) =>
      uid != null && uid.isNotEmpty && likedByUids.contains(uid);

  bool isActionable({required int nowMillis}) {
    const window = 2 * 60 * 1000;
    return nowMillis - createdAtMillis <= window;
  }

  bool isPublished({required int nowMillis}) => publishedAtMillis <= nowMillis;

  bool isPendingForViewer({
    required int nowMillis,
    required String? viewerUid,
  }) {
    return moderationStatus == AfterCommunityModerationStatus.pending &&
        publishedAtMillis > nowMillis &&
        viewerUid == authorUid;
  }

  AfterCommunityPost copyWith({
    int? publishedAtMillis,
    AfterCommunityModerationStatus? moderationStatus,
    int? replyCount,
    int? likes,
    List<String>? likedByUids,
    List<AfterCommunityComment>? comments,
    List<String>? imageUrls,
    List<String>? imageLocalNames,
    String? audioUrl,
    String? audioLocalName,
  }) {
    return AfterCommunityPost(
      id: id,
      authorUid: authorUid,
      authorName: authorName,
      title: title,
      body: body,
      category: category,
      createdAtMillis: createdAtMillis,
      roomKey: roomKey,
      roomLabel: roomLabel,
      countryCode: countryCode,
      roomScope: roomScope,
      publishedAtMillis: publishedAtMillis ?? this.publishedAtMillis,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      replyCount: replyCount ?? this.replyCount,
      likes: likes ?? this.likes,
      likedByUids: likedByUids ?? this.likedByUids,
      comments: comments ?? this.comments,
      imageUrls: imageUrls ?? this.imageUrls,
      imageLocalNames: imageLocalNames ?? this.imageLocalNames,
      audioUrl: audioUrl ?? this.audioUrl,
      audioLocalName: audioLocalName ?? this.audioLocalName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorUid': authorUid,
        'authorName': authorName,
        'title': title,
        'body': body,
        'category': category,
        'createdAtMillis': createdAtMillis,
        'publishedAtMillis': publishedAtMillis,
        'moderationStatus': moderationStatus.name,
        'roomKey': roomKey,
        'roomLabel': roomLabel,
        // Legacy Garage keys for existing local / Firestore documents.
        'vehicleKey': roomKey,
        'vehicleLabel': roomLabel,
        if (countryCode != null && countryCode!.isNotEmpty)
          'countryCode': countryCode,
        'roomScope': roomScope == AfterCommunityRoomScope.privateRoom
            ? 'vehicle'
            : roomScope.name,
        'replyCount': replyCount,
        'likes': likes,
        if (likedByUids.isNotEmpty) 'likedByUids': likedByUids,
        if (comments.isNotEmpty)
          'comments': comments.map((c) => c.toJson()).toList(),
        if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        if (imageLocalNames.isNotEmpty) 'imageLocalNames': imageLocalNames,
        if (audioUrl != null && audioUrl!.isNotEmpty) 'audioUrl': audioUrl,
        if (audioLocalName != null && audioLocalName!.isNotEmpty)
          'audioLocalName': audioLocalName,
      };
}
