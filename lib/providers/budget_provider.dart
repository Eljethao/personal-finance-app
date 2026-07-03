import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/supabase_service.dart';

class BudgetProvider extends ChangeNotifier {
  final _supabase = SupabaseService().client;
  List<BudgetModel> _budgets = [];
  List<BudgetStatus> _budgetStatuses = [];
  bool _isLoading = false;

  List<BudgetModel> get budgets => _budgets;
  List<BudgetStatus> get budgetStatuses => _budgetStatuses;
  bool get isLoading => _isLoading;

  static const _select = '*, category:categories(name,icon,color)';

  Future<void> fetchBudgets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data =
          await _supabase.from('budgets').select(_select).order('created_at');
      _budgets = (data as List)
          .map((b) => BudgetModel.fromJson(b as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBudgetStatus() async {
    try {
      final data = await _supabase.rpc('get_budget_status');
      _budgetStatuses = (data as List)
          .map((b) => BudgetStatus.fromJson(b as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createBudget(Map<String, dynamic> data) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final res = await _supabase
          .from('budgets')
          .insert({
            'user_id': userId,
            'category_id': data['categoryId'],
            'amount': data['amount'],
            'month': data['month'],
            'year': data['year'],
          })
          .select(_select)
          .single();
      _budgets.add(BudgetModel.fromJson(res));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateBudget(String id, Map<String, dynamic> data) async {
    try {
      final update = <String, dynamic>{
        if (data.containsKey('amount')) 'amount': data['amount'],
        if (data.containsKey('month')) 'month': data['month'],
        if (data.containsKey('year')) 'year': data['year'],
      };
      final res = await _supabase
          .from('budgets')
          .update(update)
          .eq('id', id)
          .select(_select)
          .single();
      final idx = _budgets.indexWhere((b) => b.id == id);
      if (idx != -1) {
        _budgets[idx] = BudgetModel.fromJson(res);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    try {
      await _supabase.from('budgets').delete().eq('id', id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
