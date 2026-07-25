import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'after_community_moderation.dart';

/// Private-room access control: owner + invited friend uids can see posts.
///
/// Invite lists are stored per room (not user-scoped) so invitees on the same
/// device can resolve access. Each invitee also gets a reverse index of rooms.
///
/// Used by Garage vehicle rooms, and any Super App private room (clinic,
/// family vault share, etc.).
class AfterRoomInviteStore implements AfterRoomInviteLookup {
  AfterRoomInviteStore(this._preferences);

  final SharedPreferences _preferences;

  static const roomPrefix = 'after_room_invites_v1';
  static const viewerPrefix = 'after_room_my_invites_v1';

  /// Legacy Garage keys — still read so existing installs keep invites.
  static const _legacyRoomPrefix = 'vehicle_forum_invites_v1';
  static const _legacyViewerPrefix = 'vehicle_forum_my_invites_v1';

  String _roomKey(String roomKey) => '${roomPrefix}_$roomKey';

  String _viewerKey(String uid) => '${viewerPrefix}_$uid';

  String _legacyRoomKey(String roomKey) => '${_legacyRoomPrefix}_$roomKey';

  String _legacyViewerKey(String uid) => '${_legacyViewerPrefix}_$uid';

  Set<String> invitedUids(String roomKey) {
    final modern = _decodeStringSet(_preferences.getString(_roomKey(roomKey)));
    if (modern.isNotEmpty) return modern;
    return _decodeStringSet(_preferences.getString(_legacyRoomKey(roomKey)));
  }

  Set<String> invitedRoomKeysFor(String uid) {
    if (uid.isEmpty) return {};
    final modern = _decodeStringSet(_preferences.getString(_viewerKey(uid)));
    if (modern.isNotEmpty) return modern;
    return _decodeStringSet(_preferences.getString(_legacyViewerKey(uid)));
  }

  Future<void> setInvitedUids(String roomKey, Set<String> uids) async {
    final previous = invitedUids(roomKey);
    final cleaned = uids.where((e) => e.trim().isNotEmpty).toSet();
    if (cleaned.isEmpty) {
      await _preferences.remove(_roomKey(roomKey));
      await _preferences.remove(_legacyRoomKey(roomKey));
    } else {
      final encoded = jsonEncode(cleaned.toList());
      await _preferences.setString(_roomKey(roomKey), encoded);
      // Keep legacy key in sync while Garage migrates.
      await _preferences.setString(_legacyRoomKey(roomKey), encoded);
    }

    final removed = previous.difference(cleaned);
    final added = cleaned.difference(previous);
    for (final uid in removed) {
      await _removeRoomFromViewer(uid, roomKey);
    }
    for (final uid in added) {
      await _addRoomToViewer(uid, roomKey);
    }
  }

  Future<void> invite(String roomKey, String friendUid) async {
    final next = invitedUids(roomKey)..add(friendUid);
    await setInvitedUids(roomKey, next);
  }

  Future<void> revoke(String roomKey, String friendUid) async {
    final next = invitedUids(roomKey)..remove(friendUid);
    await setInvitedUids(roomKey, next);
  }

  Future<void> _addRoomToViewer(String uid, String roomKey) async {
    final next = invitedRoomKeysFor(uid)..add(roomKey);
    final encoded = jsonEncode(next.toList());
    await _preferences.setString(_viewerKey(uid), encoded);
    await _preferences.setString(_legacyViewerKey(uid), encoded);
  }

  Future<void> _removeRoomFromViewer(String uid, String roomKey) async {
    final next = invitedRoomKeysFor(uid)..remove(roomKey);
    if (next.isEmpty) {
      await _preferences.remove(_viewerKey(uid));
      await _preferences.remove(_legacyViewerKey(uid));
      return;
    }
    final encoded = jsonEncode(next.toList());
    await _preferences.setString(_viewerKey(uid), encoded);
    await _preferences.setString(_legacyViewerKey(uid), encoded);
  }

  @override
  bool canViewRoom({
    required String roomKey,
    required String? viewerUid,
    required String? ownerUid,
  }) {
    if (viewerUid == null || viewerUid.isEmpty) return false;
    if (ownerUid != null && ownerUid == viewerUid) return true;
    return invitedUids(roomKey).contains(viewerUid);
  }

  Set<String> _decodeStringSet(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {};
      return decoded.map((e) => e.toString()).where((e) => e.isNotEmpty).toSet();
    } on Object {
      return {};
    }
  }
}
