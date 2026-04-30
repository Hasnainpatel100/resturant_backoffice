import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    _log(message, name: 'INFO');
  }

  static void success(String message) {
    _log(message, name: 'SUCCESS');
  }

  static void warning(String message) {
    _log(message, name: 'WARNING');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
  }

  static void _log(String message, {String name = '', Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

// Global helper functions as requested by the user
void logInfo(String msg) => AppLogger.info(msg);
void logSuccess(String msg) => AppLogger.success(msg);
void logWarning(String msg) => AppLogger.warning(msg);
void logError(String msg) => AppLogger.error(msg);
