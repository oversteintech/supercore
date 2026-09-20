# Shared cloud backup (Firebase / Google Cloud)

Every Super App uses the same ports — product codecs own payload shape only.

## Ports (`after_core`)

| Type | Role |
|------|------|
| `AfterUserBlobSyncPort` | Firestore JSON blob `users/{uid}/apps/{appId}/blob/data` |
| `AfterUserMediaSyncPort` | Firebase Storage / GCS bytes put/get/delete |
| `AfterStorageManifestEntry` | Media manifest row (kind, path, localId, …) |
| `AfterCloudBackupSnapshot` | Portable export format `after.cloud_backup.v1` |
| `AfterPrefsMigration` | Legacy prefs → `AfterSettingsKeys` on cold start |

## Adapters (`after_firebase`)

`AfterFirebaseBootstrap.overrides(...)` binds:

- Auth → `FirebaseAfterAuthRepository`
- Blob → `FirestoreAfterUserBlobSync`
- Media → `FirebaseAfterUserMediaSync`

Fallback (no Firebase options): prefs auth + prefs blob + in-memory media.

## UX (`after_consumer`)

| API | Role |
|-----|------|
| `AfterCloudBackupController` / `afterCloudBackupProvider` | sync / restore / export / import |
| `afterCloudBackupCodecProvider` | product collect/apply (Garage vehicles, etc.) |
| `FamilyCloudSyncController` | family prefs CRUD blob (unchanged) |
| Settings → Cloud sync / Export data | shared affordances |

## SuperGarage

- Composition root overrides blob + media ports in `AfterFramework`.
- `StorageManifestEntry` is a typedef of `AfterStorageManifestEntry`.
- Vehicle photo paths stay product-owned; uploads still go through Garage storage helpers that speak the shared manifest shape.

## Rule

Do not copy Firebase Storage / Firestore sync into a vertical. Extend the shared ports or supply an `AfterCloudBackupCodec`.
