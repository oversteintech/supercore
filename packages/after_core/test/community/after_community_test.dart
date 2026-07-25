import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AfterRoomInviteStore', () {
    late AfterRoomInviteStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = AfterRoomInviteStore(await SharedPreferences.getInstance());
    });

    test('invite adds uid and reverse room index', () async {
      await store.invite('room_a', 'friend_1');
      expect(store.invitedUids('room_a'), {'friend_1'});
      expect(store.invitedRoomKeysFor('friend_1'), {'room_a'});
    });

    test('revoke removes uid and reverse index', () async {
      await store.invite('room_a', 'friend_1');
      await store.revoke('room_a', 'friend_1');
      expect(store.invitedUids('room_a'), isEmpty);
      expect(store.invitedRoomKeysFor('friend_1'), isEmpty);
    });

    test('owner and invitee can view; stranger cannot', () async {
      await store.invite('room_a', 'friend_1');
      expect(
        store.canViewRoom(
          roomKey: 'room_a',
          viewerUid: 'owner',
          ownerUid: 'owner',
        ),
        isTrue,
      );
      expect(
        store.canViewRoom(
          roomKey: 'room_a',
          viewerUid: 'friend_1',
          ownerUid: 'owner',
        ),
        isTrue,
      );
      expect(
        store.canViewRoom(
          roomKey: 'room_a',
          viewerUid: 'stranger',
          ownerUid: 'owner',
        ),
        isFalse,
      );
    });

    test('reads legacy garage invite keys', () async {
      SharedPreferences.setMockInitialValues({
        'vehicle_forum_invites_v1_legacy_room': '["buddy"]',
        'vehicle_forum_my_invites_v1_buddy': '["legacy_room"]',
      });
      store = AfterRoomInviteStore(await SharedPreferences.getInstance());
      expect(store.invitedUids('legacy_room'), {'buddy'});
      expect(store.invitedRoomKeysFor('buddy'), {'legacy_room'});
    });
  });

  group('AfterCommunityInteractions', () {
    AfterCommunityPost basePost() => const AfterCommunityPost(
          id: 'p1',
          authorUid: 'a',
          authorName: 'A',
          title: 't',
          body: 'b',
          category: 'general',
          createdAtMillis: 1,
          roomKey: 'global',
          roomLabel: 'Global',
          roomScope: AfterCommunityRoomScope.worldGlobal,
        );

    test('togglePostLike adds and removes', () {
      final liked = AfterCommunityInteractions.togglePostLike(
        post: basePost(),
        uid: 'u2',
      );
      expect(liked.isLikedBy('u2'), isTrue);
      expect(liked.likes, 1);
      final unliked = AfterCommunityInteractions.togglePostLike(
        post: liked,
        uid: 'u2',
      );
      expect(unliked.isLikedBy('u2'), isFalse);
    });

    test('addComment and toggleCommentLike', () {
      final withComment = AfterCommunityInteractions.addComment(
        post: basePost(),
        comment: const AfterCommunityComment(
          id: 'c1',
          authorUid: 'u2',
          authorName: 'B',
          body: 'nice',
          createdAtMillis: 2,
        ),
      )!;
      expect(withComment.replyCount, 1);
      final liked = AfterCommunityInteractions.toggleCommentLike(
        post: withComment,
        commentId: 'c1',
        uid: 'u3',
      );
      expect(liked.comments.single.likes, 1);
    });

    test('addComment blocks profanity', () {
      expect(
        () => AfterCommunityInteractions.addComment(
          post: basePost(),
          comment: const AfterCommunityComment(
            id: 'c1',
            authorUid: 'u2',
            authorName: 'B',
            body: 'bad',
            createdAtMillis: 2,
          ),
          isProfanity: (text) => text == 'bad',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('AfterCommunityPost JSON', () {
    test('accepts legacy vehicleKey fields', () {
      final post = AfterCommunityPost.fromJson({
        'id': '1',
        'authorUid': 'a',
        'authorName': 'A',
        'title': 't',
        'body': 'b',
        'category': 'general',
        'createdAtMillis': 1,
        'vehicleKey': 'tr_car_x_y',
        'vehicleLabel': 'X Y',
        'roomScope': 'vehicle',
      });
      expect(post.roomKey, 'tr_car_x_y');
      expect(post.vehicleKey, 'tr_car_x_y');
      expect(post.roomScope, AfterCommunityRoomScope.privateRoom);
      expect(post.toJson()['vehicleKey'], 'tr_car_x_y');
      expect(post.toJson()['roomKey'], 'tr_car_x_y');
    });
  });

  group('AfterCommunityModeration', () {
    test('canViewPrivatePost allows invitee', () async {
      SharedPreferences.setMockInitialValues({});
      final invites =
          AfterRoomInviteStore(await SharedPreferences.getInstance());
      await invites.invite('room_x', 'friend');
      final post = AfterCommunityPost(
        id: 'p',
        authorUid: 'owner',
        authorName: 'O',
        title: 't',
        body: 'b',
        category: 'general',
        createdAtMillis: 1,
        roomKey: 'room_x',
        roomLabel: 'X',
      );
      expect(
        AfterCommunityModeration.canViewPrivatePost(
          post: post,
          viewerUid: 'friend',
          viewerOwnsRoom: (_) => false,
          invites: invites,
        ),
        isTrue,
      );
      expect(
        AfterCommunityModeration.canViewPrivatePost(
          post: post,
          viewerUid: 'stranger',
          viewerOwnsRoom: (_) => false,
          invites: invites,
        ),
        isFalse,
      );
    });
  });
}
