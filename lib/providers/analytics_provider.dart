import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final _api = ApiService();
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
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();
      final res = await _api.get('/analytics/summary', params: params);
      _summary = res.data['data'] as Map<String, dynamic>;
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchByCategory(
      {DateTime? startDate, DateTime? endDate, String? type}) async {
    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();
      if (type != null) params['type'] = type;
      final res = await _api.get('/analytics/by-category', params: params);
      _byCategory = res.data['data'] as List;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchMonthly({int? year}) async {
    try {
      final params = <String, dynamic>{};
      if (year != null) params['year'] = year;
      final res = await _api.get('/analytics/monthly', params: params);
      _monthly = res.data['data'] as List;
      notifyListeners();
    } catch (_) {}
  }
}
