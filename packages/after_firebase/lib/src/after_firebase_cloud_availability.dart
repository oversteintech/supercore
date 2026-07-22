import 'package:firebase_core/firebase_core.dart';

/// Gate for Firestore / Auth cloud features — never throws.
abstract final class AfterFirebaseCloudAvailability {
  static bool get canUseCloud {
    try {
      return Firebase.apps.isNotEmpty;
    } on Object {
      return false;
    }
  }
}
