import 'package:flutter/foundation.dart';

class AppConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for Web
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:5000';
    return 'http://10.0.2.2:5000';
  }
  
  static const String appName = 'Student Score Management';
}
