import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats an integer amount with thousand-separator commas while typing.
/// Strip commas before parsing: `text.replaceAll(',', '')`.
class ThousandsSeparatorFormatter extends TextInputFormatter {
  /// Format a plain digit string into comma-separated form, e.g. "50000" → "50,000".
  static String format(String digits) {
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return '';
    final buf = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && (clean.length - i) % 3 == 0) buf.write(',');
      buf.write(clean[i]);
    }
    return buf.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = format(newValue.text);
    if (formatted.isEmpty) return newValue.copyWith(text: '');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class Formatters {
  static String currency(double amount, {String currency = 'LAK'}) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount)} $currency';
  }

  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
