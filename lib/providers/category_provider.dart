import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/supabase_service.dart';

class CategoryProvider extends ChangeNotifier {
  final _supabase = SupabaseService().client;
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
      final data = await _supabase.from('categories').select().order('created_at');
      _categories = (data as List)
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final res = await _supabase
          .from('categories')
          .insert({
            'user_id': userId,
            'name': data['name'],
            'icon': data['icon'],
            'color': data['color'],
            'type': data['type'],
          })
          .select()
          .single();
      _categories.add(CategoryModel.fromJson(res));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final update = <String, dynamic>{
        if (data.containsKey('name')) 'name': data['name'],
        if (data.containsKey('icon')) 'icon': data['icon'],
        if (data.containsKey('color')) 'color': data['color'],
      };
      final res =
          await _supabase.from('categories').update(update).eq('id', id).select().single();
      final idx = _categories.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _categories[idx] = CategoryModel.fromJson(res);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
