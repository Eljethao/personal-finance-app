import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/api_service.dart';

class WalletProvider extends ChangeNotifier {
  final _api = ApiService();
  List<WalletModel> _wallets = [];
  bool _isLoading = false;

  List<WalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;

  Future<void> fetchWallets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/wallets');
      _wallets = (res.data['data'] as List)
          .map((w) => WalletModel.fromJson(w as Map<String, dynamic>))
          .toList();
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
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
