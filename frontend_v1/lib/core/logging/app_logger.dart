import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(Object? message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void warning(Object? message) {
    if (kDebugMode) {
      debugPrint('[WARN] $message');
    }
  }

  static void error(Object? message, [Object? error]) {
    if (kDebugMode) {
      final suffix = error == null ? '' : ' | error=$error';
      debugPrint('[ERROR] $message$suffix');
    }
  }
}
