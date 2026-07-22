import 'dart:convert';
import 'dart:typed_data';

import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local profile identity — Garage-parity avatar + photos + editable fields.
class FamilyProfileIdentity {
  const FamilyProfileIdentity({
    this.avatarId = 'avatar_1',
    this.photoIds = const [],
    this.activePhotoId,
    this.photosBase64 = const {},
    this.displayName,
    this.email,
    this.phoneNumber,
    this.username,
    this.firstName,
    this.lastName,
    this.birthDate,
  });

  static const maxProfilePhotos = 5;

  final String avatarId;
  final List<String> photoIds;
  final String? activePhotoId;
  final Map<String, String> photosBase64;
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? username;
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;

  String? get activePhotoBase64 {
    final id = activePhotoId ?? (photoIds.isEmpty ? null : photoIds.first);
    if (id == null) return null;
    return photosBase64[id];
  }

  Uint8List? get activePhotoBytes {
    final b64 = activePhotoBase64;
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } on FormatException {
      return null;
    }
  }

  bool get canAddPhoto => photoIds.length < maxProfilePhotos;

  String resolvedDisplayName({String? authDisplayName, String? authEmail}) {
    final local = displayName?.trim();
    if (local != null && local.isNotEmpty) return local;
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final combined = '$first $last'.trim();
    if (combined.isNotEmpty) return combined;
    final auth = authDisplayName?.trim();
    if (auth != null && auth.isNotEmpty) return auth;
    final email = (this.email ?? authEmail)?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'Guest';
  }

  FamilyProfileIdentity copyWith({
    String? avatarId,
    List<String>? photoIds,
    String? activePhotoId,
    Map<String, String>? photosBase64,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? username,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    bool clearActivePhoto = false,
    bool clearPhotos = false,
    bool clearDisplayName = false,
    bool clearEmail = false,
    bool clearPhone = false,
    bool clearUsername = false,
    bool clearBirthDate = false,
  }) {
    return FamilyProfileIdentity(
      avatarId: avatarId ?? this.avatarId,
      photoIds: clearPhotos ? const [] : (photoIds ?? this.photoIds),
      activePhotoId: clearPhotos || clearActivePhoto
          ? null
          : (activePhotoId ?? this.activePhotoId),
      photosBase64:
          clearPhotos ? const {} : (photosBase64 ?? this.photosBase64),
      displayName:
          clearDisplayName ? null : (displayName ?? this.displayName),
      email: clearEmail ? null : (email ?? this.email),
      phoneNumber: clearPhone ? null : (phoneNumber ?? this.phoneNumber),
      username: clearUsername ? null : (username ?? this.username),
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
    );
  }
}

class FamilyProfilePhotoThumb {
  const FamilyProfilePhotoThumb({
    required this.id,
    required this.bytes,
  });

  final String id;
  final Uint8List bytes;
}

final familyProfileIdentityProvider =
    NotifierProvider<FamilyProfileIdentityController, FamilyProfileIdentity>(
  FamilyProfileIdentityController.new,
);

final familyActiveProfilePhotoBytesProvider = Provider<Uint8List?>((ref) {
  return ref.watch(familyProfileIdentityProvider).activePhotoBytes;
});

final familyProfilePhotoThumbnailsProvider =
    Provider<List<FamilyProfilePhotoThumb>>((ref) {
  final identity = ref.watch(familyProfileIdentityProvider);
  final thumbs = <FamilyProfilePhotoThumb>[];
  for (final id in identity.photoIds) {
    final b64 = identity.photosBase64[id];
    if (b64 == null || b64.isEmpty) continue;
    try {
      thumbs.add(
        FamilyProfilePhotoThumb(id: id, bytes: base64Decode(b64)),
      );
    } on FormatException {
      // skip corrupt entries
    }
  }
  return thumbs;
});

class FamilyProfileIdentityController
    extends Notifier<FamilyProfileIdentity> {
  static const _avatarKey = 'family_profile_avatar_id';
  static const _photosKey = 'family_profile_photos_json';
  static const _activePhotoKey = 'family_profile_active_photo';
  static const _displayNameKey = 'family_profile_display_name';
  static const _emailKey = 'family_profile_email';
  static const _phoneKey = 'family_profile_phone';
  static const _usernameKey = 'family_profile_username';
  static const _firstNameKey = 'family_profile_first_name';
  static const _lastNameKey = 'family_profile_last_name';
  static const _birthDateKey = 'family_profile_birth_date';

  SharedPreferences get _prefs => ref.read(afterSharedPreferencesProvider);

  @override
  FamilyProfileIdentity build() => _read();

  FamilyProfileIdentity _read() {
    final prefs = _prefs;
    Map<String, String> photos = const {};
    List<String> ids = const [];
    final raw = prefs.getString(_photosKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          photos = {
            for (final e in decoded.entries)
              if (e.key is String && e.value is String)
                e.key as String: e.value as String,
          };
          ids = photos.keys.toList(growable: false);
        } else if (decoded is List) {
          // ordered list of {id, b64}
          final next = <String, String>{};
          final order = <String>[];
          for (final item in decoded) {
            if (item is! Map) continue;
            final id = item['id']?.toString();
            final b64 = item['b64']?.toString();
            if (id == null || b64 == null || b64.isEmpty) continue;
            next[id] = b64;
            order.add(id);
          }
          photos = next;
          ids = order;
        }
      } on Object {
        photos = const {};
        ids = const [];
      }
    }

    var active = prefs.getString(_activePhotoKey);
    if (active != null && !photos.containsKey(active)) {
      active = ids.isEmpty ? null : ids.first;
    } else if (active == null && ids.isNotEmpty) {
      active = ids.first;
    }

    DateTime? birthDate;
    final birthRaw = prefs.getString(_birthDateKey);
    if (birthRaw != null && birthRaw.isNotEmpty) {
      birthDate = DateTime.tryParse(birthRaw);
    }

    return FamilyProfileIdentity(
      avatarId: prefs.getString(_avatarKey) ?? 'avatar_1',
      photoIds: ids,
      activePhotoId: active,
      photosBase64: photos,
      displayName: prefs.getString(_displayNameKey),
      email: prefs.getString(_emailKey),
      phoneNumber: prefs.getString(_phoneKey),
      username: prefs.getString(_usernameKey),
      firstName: prefs.getString(_firstNameKey),
      lastName: prefs.getString(_lastNameKey),
      birthDate: birthDate,
    );
  }

  Future<void> _persistPhotos(FamilyProfileIdentity next) async {
    final list = [
      for (final id in next.photoIds)
        if (next.photosBase64[id] != null)
          {'id': id, 'b64': next.photosBase64[id]},
    ];
    await _prefs.setString(_photosKey, jsonEncode(list));
    final active = next.activePhotoId;
    if (active == null || active.isEmpty) {
      await _prefs.remove(_activePhotoKey);
    } else {
      await _prefs.setString(_activePhotoKey, active);
    }
  }

  Future<void> setAvatarId(String avatarId) async {
    await _prefs.setString(_avatarKey, avatarId);
    state = state.copyWith(avatarId: avatarId);
  }

  Future<bool> addProfilePhoto(Uint8List bytes) async {
    if (!state.canAddPhoto || bytes.isEmpty) return false;
    final id = 'photo_${DateTime.now().millisecondsSinceEpoch}';
    final b64 = base64Encode(bytes);
    final nextPhotos = Map<String, String>.from(state.photosBase64)..[id] = b64;
    final nextIds = [...state.photoIds, id];
    final next = state.copyWith(
      photoIds: nextIds,
      photosBase64: nextPhotos,
      activePhotoId: id,
    );
    await _persistPhotos(next);
    state = next;
    return true;
  }

  Future<void> setActiveProfilePhoto(String photoId) async {
    if (!state.photosBase64.containsKey(photoId)) return;
    await _prefs.setString(_activePhotoKey, photoId);
    state = state.copyWith(activePhotoId: photoId);
  }

  Future<void> removeProfilePhotoAt(int index) async {
    if (index < 0 || index >= state.photoIds.length) return;
    final removed = state.photoIds[index];
    final nextIds = [...state.photoIds]..removeAt(index);
    final nextPhotos = Map<String, String>.from(state.photosBase64)
      ..remove(removed);
    var nextActive = state.activePhotoId;
    if (nextActive == removed) {
      nextActive = nextIds.isEmpty ? null : nextIds.first;
    }
    final next = state.copyWith(
      photoIds: nextIds,
      photosBase64: nextPhotos,
      activePhotoId: nextActive,
      clearActivePhoto: nextActive == null,
    );
    await _persistPhotos(next);
    state = next;
  }

  Future<void> clearProfilePhotos() async {
    final next = state.copyWith(clearPhotos: true);
    await _persistPhotos(next);
    state = next;
  }

  Future<void> updateFields({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? username,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    bool clearBirthDate = false,
  }) async {
    final prefs = _prefs;
    if (displayName != null) {
      await prefs.setString(_displayNameKey, displayName.trim());
    }
    if (email != null) {
      await prefs.setString(_emailKey, email.trim().toLowerCase());
    }
    if (phoneNumber != null) {
      await prefs.setString(_phoneKey, phoneNumber.trim());
    }
    if (username != null) {
      await prefs.setString(_usernameKey, username.trim());
    }
    if (firstName != null) {
      await prefs.setString(_firstNameKey, firstName.trim());
    }
    if (lastName != null) {
      await prefs.setString(_lastNameKey, lastName.trim());
    }
    if (clearBirthDate) {
      await prefs.remove(_birthDateKey);
    } else if (birthDate != null) {
      final iso =
          '${birthDate.year.toString().padLeft(4, '0')}-'
          '${birthDate.month.toString().padLeft(2, '0')}-'
          '${birthDate.day.toString().padLeft(2, '0')}';
      await prefs.setString(_birthDateKey, iso);
    }
    state = state.copyWith(
      displayName: displayName?.trim(),
      email: email?.trim().toLowerCase(),
      phoneNumber: phoneNumber?.trim(),
      username: username?.trim(),
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      birthDate: birthDate,
      clearBirthDate: clearBirthDate,
    );
  }

  /// Seeds identity after registration wizard completes.
  Future<void> seedFromRegistration({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? phoneNumber,
  }) async {
    final display = '$firstName $lastName'.trim();
    await updateFields(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      displayName: display,
    );
  }

  Future<void> clearAll() async {
    final prefs = _prefs;
    await prefs.remove(_avatarKey);
    await prefs.remove(_photosKey);
    await prefs.remove(_activePhotoKey);
    await prefs.remove(_displayNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_birthDateKey);
    state = const FamilyProfileIdentity();
  }
}
