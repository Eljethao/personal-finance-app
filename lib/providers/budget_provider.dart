import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/api_service.dart';

class BudgetProvider extends ChangeNotifier {
  final _api = ApiService();
  List<BudgetModel> _budgets = [];
  List<BudgetStatus> _budgetStatuses = [];
  bool _isLoading = false;

  List<BudgetModel> get budgets => _budgets;
  List<BudgetStatus> get budgetStatuses => _budgetStatuses;
  bool get isLoading => _isLoading;

  Future<void> fetchBudgets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/budgets');
      _budgets = (res.data['data'] as List)
          .map((b) => BudgetModel.fromJson(b as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBudgetStatus() async {
    try {
      final res = await _api.get('/budgets/status');
      _budgetStatuses = (res.data['data'] as List)
          .map((b) => BudgetStatus.fromJson(b as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createBudget(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/budgets', data: data);
      _budgets.add(BudgetModel.fromJson(res.data['data'] as Map<String, dynamic>));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateBudget(String id, Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/budgets/$id', data: data);
      final idx = _budgets.indexWhere((b) => b.id == id);
      if (idx != -1) {
        _budgets[idx] = BudgetModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    try {
      await _api.delete('/budgets/$id');
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
