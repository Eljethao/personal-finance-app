class AppConstants {
  // Android emulator: use 10.0.2.2 instead of localhost
  // Physical device: use your machine's LAN IP (e.g. http://192.168.x.x:7001/api)
  // iOS Simulator / Web: localhost works fine
  static const String baseUrl = 'http://172.20.10.2:7001/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String langKey = 'preferred_language';
  static const String pinKey = 'user_pin';
  static const String biometricKey = 'biometric_enabled';
}
