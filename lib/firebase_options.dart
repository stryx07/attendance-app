import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDf28ZslEOMSA5WfNKv-FRwLxsu68vCooA',
    appId: '1:886649676896:android:1a4a505e484c50d6788f05', // Using Android appId as fallback
    messagingSenderId: '886649676896',
    projectId: 'attendance-app-b5ef4',
    storageBucket: 'attendance-app-b5ef4.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDf28ZslEOMSA5WfNKv-FRwLxsu68vCooA',
    appId: '1:886649676896:android:1a4a505e484c50d6788f05',
    messagingSenderId: '886649676896',
    projectId: 'attendance-app-b5ef4',
    storageBucket: 'attendance-app-b5ef4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDf28ZslEOMSA5WfNKv-FRwLxsu68vCooA',
    appId: '1:886649676896:ios:fake_fallback', // Placeholder
    messagingSenderId: '886649676896',
    projectId: 'attendance-app-b5ef4',
    storageBucket: 'attendance-app-b5ef4.firebasestorage.app',
    iosBundleId: 'com.attendance.version1',
  );
}
