import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  final _api = ApiService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  int _totalPages = 1;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  int get totalPages => _totalPages;

  Future<void> fetchTransactions({
    String? type,
    String? categoryId,
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
    bool append = false,
  }) async {
    if (!append) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (type != null) params['type'] = type;
      if (categoryId != null) params['categoryId'] = categoryId;
      if (walletId != null) params['walletId'] = walletId;
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final res = await _api.get('/transactions', params: params);
      final data = res.data['data'] as Map<String, dynamic>;
      final fetched = (data['transactions'] as List)
          .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
          .toList();
      if (append) {
        _transactions = [..._transactions, ...fetched];
      } else {
        _transactions = fetched;
      }
      _totalPages = data['totalPages'] as int? ?? 1;
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTransaction(Map<String, dynamic> data) async {
    try {
      await _api.post('/transactions', data: data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      await _api.put('/transactions/$id', data: data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _api.delete('/transactions/$id');
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> uploadSlip(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'slip': await MultipartFile.fromFile(filePath),
      });
      final res = await _api.postFormData('/transactions/upload-slip', formData);
      return res.data['data']['url'] as String?;
    } catch (_) {
      return null;
    }
  }
}
