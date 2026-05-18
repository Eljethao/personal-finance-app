import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class WalletProvider extends ChangeNotifier {
  final _api = ApiService();
  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  String? _defaultWalletId;
  List<String> _pinnedWalletIds = [];

  List<WalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get defaultWalletId => _defaultWalletId;
  List<String> get pinnedWalletIds => _pinnedWalletIds;

  List<WalletModel> get pinnedWallets {
    if (_pinnedWalletIds.isEmpty) return _wallets.take(2).toList();
    return _pinnedWalletIds
        .map((id) => _wallets.where((w) => w.id == id).firstOrNull)
        .whereType<WalletModel>()
        .toList();
  }

  bool isPinned(String id) => _pinnedWalletIds.contains(id);

  WalletProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _defaultWalletId = prefs.getString(AppConstants.defaultWalletKey);
    _pinnedWalletIds = prefs.getStringList(AppConstants.pinnedWalletsKey) ?? [];
    notifyListeners();
  }

  Future<void> setDefaultWallet(String id) async {
    _defaultWalletId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.defaultWalletKey, id);
  }

  Future<void> togglePin(String id) async {
    if (_pinnedWalletIds.contains(id)) {
      _pinnedWalletIds.remove(id);
    } else {
      if (_pinnedWalletIds.length >= 2) _pinnedWalletIds.removeAt(0);
      _pinnedWalletIds.add(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.pinnedWalletsKey, _pinnedWalletIds);
  }

  Future<void> fetchWallets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/wallets');
      _wallets = (res.data['data'] as List)
          .map((w) => WalletModel.fromJson(w as Map<String, dynamic>))
          .toList();
      if (_defaultWalletId == null && _wallets.isNotEmpty) {
        await setDefaultWallet(_wallets.first.id);
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createWallet(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/wallets', data: data);
      _wallets.add(WalletModel.fromJson(res.data['data'] as Map<String, dynamic>));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateWallet(String id, Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/wallets/$id', data: data);
      final idx = _wallets.indexWhere((w) => w.id == id);
      if (idx != -1) {
        _wallets[idx] = WalletModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteWallet(String id) async {
    try {
      await _api.delete('/wallets/$id');
      _wallets.removeWhere((w) => w.id == id);
      _pinnedWalletIds.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
