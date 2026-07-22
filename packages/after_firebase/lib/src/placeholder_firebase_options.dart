import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Placeholder Firebase options until `flutterfire configure` is run per app.
///
/// [isPlaceholder] must stay true until real google-services / plist land —
/// cold start then uses PrefsGoogle + Prefs blob fallback (no crash).
abstract final class AfterPlaceholderFirebaseOptions {
  static const isPlaceholder = true;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      TargetPlatform.macOS => macos,
      _ => android,
    };
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:web:replace',
    messagingSenderId: '000000000000',
    projectId: 'afterartificial-placeholder',
    authDomain: 'afterartificial-placeholder.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:android:replace',
    messagingSenderId: '000000000000',
    projectId: 'afterartificial-placeholder',
    storageBucket: 'afterartificial-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:ios:replace',
    messagingSenderId: '000000000000',
    projectId: 'afterartificial-placeholder',
    storageBucket: 'afterartificial-placeholder.appspot.com',
    iosBundleId: 'com.overstein.placeholder',
  );

  static const FirebaseOptions macos = ios;
}
