/// Scope of a community / forum room shared across Super Apps.
enum AfterCommunityRoomScope {
  /// Worldwide public room.
  worldGlobal,

  /// Country-wide public room.
  countryGlobal,

  /// Private room for an owned resource (vehicle, clinic, account, …).
  /// Only the owner and invited friends can see posts.
  privateRoom,
}

/// Resolves scope from a conventional room key (`global`, `tr_global`, …).
AfterCommunityRoomScope afterCommunityScopeFromRoomKey(String roomKey) {
  if (roomKey == 'global') {
    return AfterCommunityRoomScope.worldGlobal;
  }
  if (RegExp(r'^[a-z]{2}_global$').hasMatch(roomKey)) {
    return AfterCommunityRoomScope.countryGlobal;
  }
  return AfterCommunityRoomScope.privateRoom;
}
