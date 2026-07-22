/// After Firebase — composition-root adapters for Auth + blob sync.
library;

export 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

export 'src/after_firebase_bootstrap.dart';
export 'src/after_firebase_cloud_availability.dart';
export 'src/firebase_after_auth_repository.dart';
export 'src/firestore_after_user_blob_sync.dart';
export 'src/placeholder_firebase_options.dart';
export 'src/registration_index_client.dart';
