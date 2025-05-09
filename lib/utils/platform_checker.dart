import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:io' if (dart.library.html) 'dart:io_unavailable.dart';

class PlatformChecker {
  static bool get isAndroid {
    if (kIsWeb) {
      return false;
    }

    return Platform.isAndroid;
  }

  static String get operatingSystem {
    if (kIsWeb) {
      return 'web';
    }

    return Platform.operatingSystem;
  }

  static String get operatingSystemVersion {
    if (kIsWeb) {
      return 'N/A';
    }

    return Platform.operatingSystemVersion;
  }
}
