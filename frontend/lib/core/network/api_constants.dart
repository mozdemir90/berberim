import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        // Android emulator connects to host machine via 10.0.2.2
        return 'http://10.0.2.2:8000/api/v1';
      }
    } catch (e) {
      // Platform.isAndroid can throw if not on a mobile platform in some edge cases
    }
    return 'http://localhost:8000/api/v1';
  }
}
