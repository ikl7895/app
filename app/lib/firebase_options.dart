import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'No Web options have been provided yet - configure Firebase for Web first',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'No iOS options have been provided yet - configure Firebase for iOS first',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBwvWnX0h7mVUtDQMZdUqc4glbMDMjWWHY', //  google-services.json "api_key"
    appId: '1:290660603850:android:58a4f85ec693141bfee133', //  google-services.json "mobilesdk_app_id"
    messagingSenderId: '290660603850', //  google-services.json "project_number"
    projectId: 'analytics-5593c', //  google-services.json "project_id"
    storageBucket: 'analytics-5593c.firebasestorage.app', //  google-services.json "storage_bucket"
  );
}
