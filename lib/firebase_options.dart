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
        return macos;
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
    apiKey: 'AIzaSyBm8NgzpirV2nmVg8hz6YB2fBIuI48Kzf8',
    appId: '1:782733110223:web:b63204462ee9f8ab23c0ba',
    messagingSenderId: '782733110223',
    projectId: 'netrai-fa408',
    authDomain: 'netrai-fa408.firebaseapp.com',
    storageBucket: 'netrai-fa408.firebasestorage.app',
    measurementId: 'G-0X98EEDH76',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFywFfhvTVhT8CjeMWXRG_FN7VVLfIeVA',
    appId: '1:782733110223:android:7a1cfe28e981ccb823c0ba',
    messagingSenderId: '782733110223',
    projectId: 'netrai-fa408',
    storageBucket: 'netrai-fa408.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWHeP7MN2VXXe6ts85anCO3A7HCv-O0f0',
    appId: '1:782733110223:ios:bfa9da6cc85528d323c0ba',
    messagingSenderId: '782733110223',
    projectId: 'netrai-fa408',
    storageBucket: 'netrai-fa408.firebasestorage.app',
    iosClientId:
        '782733110223-1tke7s7d7l8d5l93ncl18nohu4uosudd.apps.googleusercontent.com',
    iosBundleId: 'com.example.voiceAssistant',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWHeP7MN2VXXe6ts85anCO3A7HCv-O0f0',
    appId: '1:782733110223:ios:3d0e69cb4086427123c0ba',
    messagingSenderId: '782733110223',
    projectId: 'netrai-fa408',
    storageBucket: 'netrai-fa408.firebasestorage.app',
    iosClientId:
        '782733110223-0k53e1v1hcep7a9552le1qvs9vc1ld31.apps.googleusercontent.com',
    iosBundleId: 'com.livekit.example.VoiceAssistantFlutter',
  );
}
