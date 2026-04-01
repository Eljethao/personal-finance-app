import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final _api = ApiService();
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();
  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();
  List<CategoryModel> get investmentCategories =>
      _categories.where((c) => c.type == 'investment').toList();

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/categories');
      _categories = (res.data['data'] as List)
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/categories', data: data);
      _categories.add(CategoryModel.fromJson(res.data['data'] as Map<String, dynamic>));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/categories/$id', data: data);
      final idx = _categories.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _categories[idx] =
            CategoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _api.delete('/categories/$id');
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
