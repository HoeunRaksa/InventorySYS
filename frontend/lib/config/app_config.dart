import 'dart:io';
import 'package:flutter/foundation.dart';

/// Single source of truth for environment configuration.
/// Change baseUrl here only when switching environments.
class AppConfig {
  AppConfig._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://localhost:5000/api';
  }

  static const String appName = 'Inventory Manager';
}
