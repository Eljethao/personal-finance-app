import 'package:flutter/foundation.dart';

class AppConstants {
  // Fill these in with your Supabase project's URL and anon (public) key —
  // Project Settings > API in the Supabase dashboard.
  static const String supabaseUrl = 'https://hmwgzbihhhqtuzwsdigb.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_unJvPuUOUIf7qcEjaglJqA_aDhhdVzO';

  // Country code prepended to phone numbers entered without one, for
  // Supabase phone-based auth (expects E.164 format, e.g. +8562012345678).
  static const String defaultCountryCode = '+856';

  static const String userKey = 'user_data';
  static const String langKey = 'preferred_language';
  static const String pinKey = 'user_pin';
  static const String biometricKey = 'biometric_enabled';
  static const String appVersion = '1.0.1';
}
