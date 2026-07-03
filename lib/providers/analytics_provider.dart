import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final _supabase = SupabaseService().client;
  Map<String, dynamic>? _summary;
  List<dynamic> _byCategory = [];
  List<dynamic> _monthly = [];
  bool _isLoading = false;

  Map<String, dynamic>? get summary => _summary;
  List<dynamic> get byCategory => _byCategory;
  List<dynamic> get monthly => _monthly;
  bool get isLoading => _isLoading;

  Future<void> fetchSummary({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _supabase.rpc('analytics_summary', params: {
        if (startDate != null) 'p_start': startDate.toIso8601String(),
        if (endDate != null) 'p_end': endDate.toIso8601String(),
      });
      final row = (data as List).isNotEmpty
          ? data.first as Map<String, dynamic>
          : <String, dynamic>{};
      _summary = {
        'income': row['income'] ?? 0,
        'expense': row['expense'] ?? 0,
        'investment': row['investment'] ?? 0,
        'netBalance': row['net_balance'] ?? 0,
      };
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchByCategory(
      {DateTime? startDate, DateTime? endDate, String? type}) async {
    try {
      final data = await _supabase.rpc('analytics_by_category', params: {
        if (startDate != null) 'p_start': startDate.toIso8601String(),
        if (endDate != null) 'p_end': endDate.toIso8601String(),
        if (type != null) 'p_type': type,
      });
      _byCategory = (data as List)
          .map((row) => {
                'total': row['total'],
                'count': row['count'],
                'category': {
                  '_id': row['category_id'],
                  'name': row['category_name'],
                  'icon': row['category_icon'],
                  'color': row['category_color'],
                  'type': row['category_type'],
                },
              })
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchMonthly({int? year}) async {
    try {
      final data = await _supabase.rpc('analytics_monthly', params: {
        if (year != null) 'p_year': year,
      });
      final byMonth = <int, List<Map<String, dynamic>>>{};
      for (final row in (data as List)) {
        final month = row['month'] as int;
        byMonth.putIfAbsent(month, () => []).add({
          'type': row['type'],
          'total': row['total'],
        });
      }
      final months = byMonth.keys.toList()..sort();
      _monthly = months
          .map((m) => {'_id': m, 'data': byMonth[m]})
          .toList();
      notifyListeners();
    } catch (_) {}
  }
}
