import 'dart:io';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';

class TransactionProvider extends ChangeNotifier {
  final _supabase = SupabaseService().client;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  int _totalPages = 1;
  double _total = 0;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  int get totalPages => _totalPages;
  double get total => _total;

  // Filters from the most recent non-paginated fetch, kept so [deleteTransaction]
  // can recompute [total] for whichever screen/filter last queried.
  String? _lastType;
  String? _lastCategoryId;
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;

  static const _select = '*, category:categories(name,icon,color)';

  Future<TransactionModel> _hydrate(Map<String, dynamic> raw) async {
    final row = Map<String, dynamic>.from(raw);
    final path = row['slip_image_url'] as String?;
    if (path != null && path.isNotEmpty) {
      try {
        row['slip_image_url'] =
            await _supabase.storage.from('slips').createSignedUrl(path, 3600);
      } catch (_) {}
    }
    return TransactionModel.fromJson(row);
  }

  Future<double> _computeTotal({
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('transactions').select('amount');
      if (type != null) query = query.eq('type', type);
      if (categoryId != null) query = query.eq('category_id', categoryId);
      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }
      if (endDate != null) query = query.lte('date', endDate.toIso8601String());
      final rows = await query;
      return (rows as List)
          .fold<double>(0, (s, r) => s + ((r['amount'] as num?)?.toDouble() ?? 0));
    } catch (_) {
      return 0;
    }
  }

  Future<void> fetchTransactions({
    String? type,
    String? categoryId,
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
      var query = _supabase.from('transactions').select(_select);
      if (type != null) query = query.eq('type', type);
      if (categoryId != null) query = query.eq('category_id', categoryId);
      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }
      if (endDate != null) query = query.lte('date', endDate.toIso8601String());

      final from = (page - 1) * limit;
      final to = from + limit - 1;
      final rows =
          await query.order('date', ascending: false).range(from, to);

      final fetched = await Future.wait(
          (rows as List).map((r) => _hydrate(Map<String, dynamic>.from(r as Map))));

      _transactions = append ? [..._transactions, ...fetched] : fetched;
      // No exact total count round-trip — a short page means we've reached the end.
      _totalPages = fetched.length < limit ? page : page + 1;

      if (!append) {
        _lastType = type;
        _lastCategoryId = categoryId;
        _lastStartDate = startDate;
        _lastEndDate = endDate;
        _total = await _computeTotal(
            type: type, categoryId: categoryId, startDate: startDate, endDate: endDate);
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> _toRow(Map<String, dynamic> data) => {
        if (data.containsKey('type')) 'type': data['type'],
        if (data.containsKey('amount')) 'amount': data['amount'],
        if (data.containsKey('categoryId')) 'category_id': data['categoryId'],
        if (data.containsKey('date')) 'date': data['date'],
        if (data.containsKey('note')) 'note': data['note'],
        if (data.containsKey('slipImageUrl'))
          'slip_image_url': data['slipImageUrl'],
      };

  Future<bool> createTransaction(Map<String, dynamic> data) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase
          .from('transactions')
          .insert({..._toRow(data), 'user_id': userId});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      final row = await _supabase
          .from('transactions')
          .update(_toRow(data))
          .eq('id', id)
          .select(_select)
          .single();
      final updated = await _hydrate(row);
      final idx = _transactions.indexWhere((t) => t.id == id);
      if (idx != -1) _transactions[idx] = updated;
      _total = await _computeTotal(
          type: _lastType,
          categoryId: _lastCategoryId,
          startDate: _lastStartDate,
          endDate: _lastEndDate);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _supabase.from('transactions').delete().eq('id', id);
      _transactions.removeWhere((t) => t.id == id);
      _total = await _computeTotal(
          type: _lastType,
          categoryId: _lastCategoryId,
          startDate: _lastStartDate,
          endDate: _lastEndDate);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Uploads to the private "slips" bucket under the user's own folder and
  /// returns the object PATH (not a URL) — callers store this path on the
  /// transaction; a signed URL is resolved on read in [fetchTransactions].
  Future<String?> uploadSlip(String filePath) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final ext = filePath.contains('.') ? filePath.split('.').last : 'jpg';
      final path =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _supabase.storage.from('slips').upload(path, File(filePath));
      return path;
    } catch (_) {
      return null;
    }
  }
}
