import 'package:flutter/foundation.dart';

class AppConstants {
  // Debug: local dev server. Release: production API.
  static const String baseUrl = 'https://finance-api.nkaujntseeg.com/api';
  // static const String baseUrl = 'http://localhost:7001/api'; // Local (via adb reverse)
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String langKey = 'preferred_language';
  static const String pinKey = 'user_pin';
  static const String biometricKey = 'biometric_enabled';
  static const String defaultWalletKey = 'default_wallet_id';
  static const String pinnedWalletsKey = 'pinned_wallet_ids';
  static const String appVersion = '1.0.1';
}
