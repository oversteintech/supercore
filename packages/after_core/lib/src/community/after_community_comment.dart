import 'after_community_json.dart';

/// A single comment on a community post (Instagram-style likes supported).
class AfterCommunityComment {
  const AfterCommunityComment({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.body,
    required this.createdAtMillis,
    this.likes = 0,
    this.likedByUids = const [],
  });

  factory AfterCommunityComment.fromJson(Map<String, dynamic> json) {
    final likedBy = afterCommunityReadJsonStringList(json['likedByUids']);
    return AfterCommunityComment(
      id: json['id']?.toString() ?? '',
      authorUid: json['authorUid']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'User',
      body: json['body']?.toString() ?? '',
      createdAtMillis: afterCommunityReadJsonIntOr(json['createdAtMillis'], 0),
      likes: afterCommunityReadJsonIntOr(json['likes'], likedBy.length),
      likedByUids: likedBy,
    );
  }

  final String id;
  final String authorUid;
  final String authorName;
  final String body;
  final int createdAtMillis;
  final int likes;
  final List<String> likedByUids;

  bool isLikedBy(String? uid) =>
      uid != null && uid.isNotEmpty && likedByUids.contains(uid);

  AfterCommunityComment copyWith({
    int? likes,
    List<String>? likedByUids,
  }) {
    return AfterCommunityComment(
      id: id,
      authorUid: authorUid,
      authorName: authorName,
      body: body,
      createdAtMillis: createdAtMillis,
      likes: likes ?? this.likes,
      likedByUids: likedByUids ?? this.likedByUids,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorUid': authorUid,
        'authorName': authorName,
        'body': body,
        'createdAtMillis': createdAtMillis,
        'likes': likes,
        if (likedByUids.isNotEmpty) 'likedByUids': likedByUids,
      };
}
