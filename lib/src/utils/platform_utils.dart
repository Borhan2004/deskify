import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

/// A utility class for web-safe platform checks.
class DeskPlatform {
  /// Returns `true` if the app is running on macOS.
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Returns `true` if the app is running on Windows.
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Returns `true` if the app is running on Linux.
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Returns `true` if the app is running on a desktop platform (macOS, Windows, Linux).
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  /// Returns `true` if the app is running on a mobile platform (iOS, Android).
  static bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Returns `true` if the app is running on the web.
  static bool get isWeb => kIsWeb;
}
