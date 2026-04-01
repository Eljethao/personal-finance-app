import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/icon_map.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  Color get _typeColor {
    switch (transaction.type) {
      case 'income':
        return AppTheme.income;
      case 'expense':
        return AppTheme.expense;
      default:
        return AppTheme.investment;
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  // Best-effort icon from category name
  IconData _categoryIcon() {
    final name = transaction.categoryName.toLowerCase();
    for (final key in kCategoryIcons.keys) {
      if (name.contains(key) || key.contains(name)) {
        return kCategoryIcons[key]!;
      }
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _parseColor(transaction.categoryColor);
    final sign = transaction.type == 'income' ? '+' : '-';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_categoryIcon(), color: catColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.categoryName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.walletName} · ${Formatters.date(transaction.date)}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount + type badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${Formatters.currency(transaction.amount, currency: transaction.currency)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _typeColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    transaction.type,
                    style: TextStyle(
                      color: _typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
