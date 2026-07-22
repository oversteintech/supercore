# Google Sign-In + Cloud Sync setup (consumer Super Apps)

## Option A — Firebase Auth + Firestore (recommended)

Composition root uses `after_firebase`:

1. Dependency: `after_firebase` path `../supercore/packages/after_firebase`
2. Placeholder `lib/app/platform/firebase_options.dart` until `flutterfire configure`
3. Cold start / `AppRuntimeBootstrap.load()` calls:

```dart
await AfterFirebaseBootstrap.ensureInitialized(
  options: DefaultFirebaseOptions.currentPlatform,
  preferLocalFallback: DefaultFirebaseOptions.isPlaceholder,
);
```

4. `AfterFramework` spreads (and sets `includeUserBlobSync: false` on
   `AfterStandardOverrides.create` so blob sync is not double-overridden):

```dart
...AfterStandardOverrides.create(
  preferences: preferences,
  userAgent: '...',
  includeUserBlobSync: false,
),
...AfterFirebaseBootstrap.overrides(
  preferences: preferences,
  appId: <manifest>.appId,
  mockGoogleEmailForTests: mockGoogleEmailForTests,
),
```

While `isPlaceholder` / init fails: **PrefsGoogleAuthRepository** + **PrefsAfterUserBlobSync** (no crash).

When real Firebase options + platform config land: **FirebaseAfterAuthRepository** + **FirestoreAfterUserBlobSync**.

### Ops cutover checklist

- Create Firebase project / apps with package `com.overstein.<appid>`
- Run `flutterfire configure` → replace `firebase_options.dart`
- Drop real `android/app/google-services.json` (replace `.placeholder`) and enable Google Services Gradle plugin only then
- Google Cloud Console: OAuth Android + iOS (+ Web server client id for Android id tokens); SHA-1 of signing key
- Optional: `googleServerClientId` / `googleIosClientId` on `AfterFirebaseBootstrap.overrides`
- CI / widget tests: `mockGoogleEmailForTests` skips Google UI; or `AfterFirebaseBootstrap.resetForTests()` + `ensureInitialized(preferLocalFallback: true)`

### SuperGarage note

Garage keeps domain `FirebaseAuthRepository` / `AuthService`. AfterAuth adapter wraps that Firebase path. Blob sync: `FirestoreAfterUserBlobSync` when `AuthService.isAvailable`, else `PrefsAfterUserBlobSync`.

## Option B — Prefs-only (legacy / offline skeleton)

Wire `PrefsGoogleAuthRepository` via `familyPrefsGoogleAuthOverride` and rely on `AfterStandardOverrides` for `PrefsAfterUserBlobSync`. Prefer Option A for new work.

## Sync ports

- Port: `AfterUserBlobSyncPort` (`after_core`)
- Prefs adapter: `PrefsAfterUserBlobSync`
- Firestore adapter: `FirestoreAfterUserBlobSync` (`after_firebase`) — path `users/{uid}/apps/{appId}/blob/data`
- Controller: `FamilyCloudSyncController` (`after_consumer`) — debounced push/pull, restore-on-login
- Do not import Firebase from domain layers

## Settings

Family Settings includes **Sync now** and a 20-language picker (`AfterSupportedLocales`).

## Verification

```bash
flutter analyze
flutter test --coverage
dart tool/check_coverage.dart 50 coverage/lcov.info
```
