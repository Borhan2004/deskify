import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

/// A utility class for web-safe platform checks.
class DeskPlatform {
  /// Allows setting a dynamic platform override for testing and development.
  static TargetPlatform? overridePlatform;

  /// Returns `true` if the app is running on macOS.
  static bool get isMacOS {
    if (overridePlatform != null) {
      return overridePlatform == TargetPlatform.macOS;
    }
    return !kIsWeb && Platform.isMacOS;
  }

  /// Returns `true` if the app is running on Windows.
  static bool get isWindows {
    if (overridePlatform != null) {
      return overridePlatform == TargetPlatform.windows;
    }
    return !kIsWeb && Platform.isWindows;
  }

  /// Returns `true` if the app is running on Linux.
  static bool get isLinux {
    if (overridePlatform != null) {
      return overridePlatform == TargetPlatform.linux;
    }
    return !kIsWeb && Platform.isLinux;
  }

  /// Returns `true` if the app is running on a desktop platform (macOS, Windows, Linux).
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  /// Returns `true` if the app is running on a mobile platform (iOS, Android).
  static bool get isMobile {
    if (overridePlatform != null) {
      return overridePlatform == TargetPlatform.iOS ||
          overridePlatform == TargetPlatform.android;
    }
    return !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  }

  /// Returns `true` if the app is running on the web.
  static bool get isWeb => kIsWeb && overridePlatform == null;
}

