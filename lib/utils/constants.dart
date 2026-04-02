import 'package:flutter/foundation.dart';

class AppConstants {
  // Debug: local dev server. Release: production API.
  static const String baseUrl = kReleaseMode
      ? 'https://finance-api.nkaujntseeg.com/api'
      : 'http://172.20.10.2:7001/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String langKey = 'preferred_language';
  static const String pinKey = 'user_pin';
  static const String biometricKey = 'biometric_enabled';
}
