import 'package:flutter/foundation.dart';

/// Centralized logger for ScriptBridge production services.
class AppLogger {
  /// Log general debug logs.
  static void d(String message) {
    if (kDebugMode) {
      print('💡 [DEBUG] ${DateTime.now().toIso8601String()}: $message');
    }
  }

  /// Log error information.
  static void e(String message, [dynamic error, StackTrace? stack]) {
    print('🚨 [ERROR] ${DateTime.now().toIso8601String()}: $message');
    if (error != null) {
      print('   Reason: $error');
    }
    if (stack != null && kDebugMode) {
      print(stack);
    }
  }

  /// Log warning logs.
  static void w(String message) {
    print('⚠️ [WARN] ${DateTime.now().toIso8601String()}: $message');
  }
}
