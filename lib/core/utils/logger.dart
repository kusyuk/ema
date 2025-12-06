import 'dart:developer' as developer;

/// Simple logger utility
class Logger {
  Logger._();

  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? 'EMA',
      level: 800, // Debug level
    );
  }

  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? 'EMA',
      level: 700, // Info level
    );
  }

  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? 'EMA',
      level: 900, // Warning level
    );
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'EMA',
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
}

