import 'package:flutter/material.dart';

class DateFilterProvider extends ChangeNotifier {
  String _selectedRange = 'thisMonth';
  DateTime? _startDate;
  DateTime? _endDate;

  String get selectedRange => _selectedRange;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  DateFilterProvider() {
    _applyPredefinedRange('thisMonth');
  }

  void setFilter(String range, {DateTime? start, DateTime? end}) {
    _selectedRange = range;
    if (range == 'custom') {
      _startDate = start;
      _endDate = end;
    } else {
      _applyPredefinedRange(range);
    }
    notifyListeners();
  }

  void _applyPredefinedRange(String range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (range) {
      case 'today':
        _startDate = today;
        _endDate = today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        break;
      case 'lastDay':
        final yesterday = today.subtract(const Duration(days: 1));
        _startDate = yesterday;
        _endDate = yesterday.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        break;
      case 'thisMonth':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
        break;
      case 'lastMonth':
        _startDate = DateTime(now.year, now.month - 1, 1);
        _endDate = DateTime(now.year, now.month, 1).subtract(const Duration(milliseconds: 1));
        break;
      case 'thisYear':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
        break;
      case 'all':
      default:
        _startDate = null;
        _endDate = null;
        break;
    }
  }
}
