import 'after_community_comment.dart';
import 'after_community_post.dart';

/// Pure Instagram-style like / comment mutations for [AfterCommunityPost].
///
/// Apps persist the returned post via their own repository (prefs, Firestore…).
abstract final class AfterCommunityInteractions {
  AfterCommunityInteractions._();

  static AfterCommunityPost togglePostLike({
    required AfterCommunityPost post,
    required String uid,
  }) {
    if (uid.isEmpty) return post;
    final liked = [...post.likedByUids];
    if (liked.contains(uid)) {
      liked.remove(uid);
    } else {
      liked.add(uid);
    }
    return post.copyWith(likedByUids: liked, likes: liked.length);
  }

  static AfterCommunityPost? addComment({
    required AfterCommunityPost post,
    required AfterCommunityComment comment,
    bool Function(String text)? isProfanity,
  }) {
    final body = comment.body.trim();
    if (body.isEmpty) return null;
    if (isProfanity != null && isProfanity(body)) {
      throw const FormatException('profanity_blocked');
    }
    final comments = [...post.comments, comment];
    return post.copyWith(
      comments: comments,
      replyCount: comments.length,
    );
  }

  static AfterCommunityPost toggleCommentLike({
    required AfterCommunityPost post,
    required String commentId,
    required String uid,
  }) {
    if (uid.isEmpty) return post;
    final comments = post.comments.map((comment) {
      if (comment.id != commentId) return comment;
      final liked = [...comment.likedByUids];
      if (liked.contains(uid)) {
        liked.remove(uid);
      } else {
        liked.add(uid);
      }
      return comment.copyWith(likedByUids: liked, likes: liked.length);
    }).toList(growable: false);
    return post.copyWith(comments: comments);
  }
}
