import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = SupabaseService().client;
  final _storage = const FlutterSecureStorage();

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String _preferredLanguage = 'lo';
  bool _biometricEnabled = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String get preferredLanguage => _preferredLanguage;
  bool get biometricEnabled => _biometricEnabled;

  /// Supabase phone auth expects E.164 (e.g. +8562012345678). Numbers typed
  /// without a country code are assumed local and get the default prefixed.
  String _normalizePhone(String raw) {
    var p = raw.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (p.startsWith('+')) return p;
    if (p.startsWith('0')) p = p.substring(1);
    return '${AppConstants.defaultCountryCode}$p';
  }

  UserModel _userFromSupabase(User u) => UserModel(
        id: u.id,
        name: (u.userMetadata?['name'] as String?) ?? '',
        phone: u.phone ?? '',
        preferredLanguage: _preferredLanguage,
      );

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _preferredLanguage = prefs.getString(AppConstants.langKey) ?? 'lo';
    _biometricEnabled = prefs.getBool(AppConstants.biometricKey) ?? false;

    final currentUser = _supabase.auth.currentUser;
    if (_supabase.auth.currentSession != null && currentUser != null) {
      _isAuthenticated = true;
      _user = _userFromSupabase(currentUser);
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<bool> register(String name, String phone, String pin) async {
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('[Auth] Register attempt: phone=$phone, name=$name');
      final res = await _supabase.auth.signUp(
        phone: _normalizePhone(phone),
        password: pin,
        data: {'name': name},
      );
      debugPrint('[Auth] Register response: user=${res.user?.id}');
      if (res.user == null || res.session == null) return false;
      _user = _userFromSupabase(res.user!);
      _isAuthenticated = true;
      debugPrint('[Auth] Register successful: user=${_user?.name}');
      return true;
    } catch (e, stack) {
      debugPrint('[Auth] Register failed: $e');
      debugPrint('[Auth] Stack trace: $stack');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String phone, String pin) async {
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('[Auth] Login attempt: phone=$phone');
      final res = await _supabase.auth.signInWithPassword(
        phone: _normalizePhone(phone),
        password: pin,
      );
      debugPrint('[Auth] Login response: user=${res.user?.id}');
      if (res.user == null) return false;
      _user = _userFromSupabase(res.user!);
      _isAuthenticated = true;
      debugPrint('[Auth] Login successful: user=${_user?.name}');
      return true;
    } catch (e, stack) {
      debugPrint('[Auth] Login failed: $e');
      debugPrint('[Auth] Stack trace: $stack');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> savePin(String pin) async {
    await _storage.write(key: AppConstants.pinKey, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: AppConstants.pinKey);
    return stored == pin;
  }

  Future<void> setLanguage(String lang) async {
    _preferredLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.langKey, lang);
    notifyListeners();
  }

  Future<void> setBiometric(bool enabled) async {
    _biometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.biometricKey, enabled);
    notifyListeners();
  }
}
