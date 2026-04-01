import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/jwt_utils.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiService();
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

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _preferredLanguage = prefs.getString(AppConstants.langKey) ?? 'lo';
    _biometricEnabled = prefs.getBool(AppConstants.biometricKey) ?? false;
    final token = prefs.getString(AppConstants.tokenKey);

    if (token != null && !JwtUtils.isTokenExpired(token)) {
      _isAuthenticated = true;
      
      final userDataStr = prefs.getString(AppConstants.userKey);
      if (userDataStr != null) {
        try {
          _user = UserModel.fromJson(jsonDecode(userDataStr));
        } catch (_) {}
      }

      _api.get('/auth/me').then((res) {
        final data = res.data['data'] as Map<String, dynamic>;
        _user = UserModel.fromJson(data);
        prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));
        notifyListeners();
      }).catchError((_) {});
    } else {
      await _api.clearToken();
      await prefs.remove(AppConstants.userKey);
    }
    notifyListeners();
  }

  Future<bool> register(String name, String phone, String pin) async {
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint("url: ${AppConstants.baseUrl}/auth/register");
      final res = await _api.post('/auth/register', data: {
        'name': name,
        'phone': phone,
        'pin': pin,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      debugPrint('Registration response:---> $data');
      await _api.saveToken(data['token'] as String);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      _isAuthenticated = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));
      return true;
    } catch (_) {
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
      final res = await _api
          .post('/auth/login', data: {'phone': phone, 'pin': pin});
      final data = res.data['data'] as Map<String, dynamic>;
      await _api.saveToken(data['token'] as String);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      _isAuthenticated = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));
      return true;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
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
