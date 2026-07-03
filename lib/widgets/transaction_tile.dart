import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction_model.dart';
import '../providers/analytics_provider.dart';
import '../providers/date_filter_provider.dart';
import '../providers/transaction_provider.dart';
import '../screens/transactions/add_transaction_screen.dart';
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

  Future<void> _refreshSummary(BuildContext context) {
    final df = context.read<DateFilterProvider>();
    return context
        .read<AnalyticsProvider>()
        .fetchSummary(startDate: df.startDate, endDate: df.endDate);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.t('deleteTransaction')),
        content: Text(l.t('deleteTransactionConfirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.t('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TransactionProvider>().deleteTransaction(transaction.id);
      if (context.mounted) await _refreshSummary(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catColor = _parseColor(transaction.categoryColor);
    final sign = transaction.type == 'income' ? '+' : '-';

    return Slidable(
      key: ValueKey(transaction.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.42,
        children: [
          CustomSlidableAction(
            onPressed: (_) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(transaction: transaction)),
            ).then((_) {
              if (context.mounted) _refreshSummary(context);
            }),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: _SlideActionContent(icon: Icons.edit_outlined, label: l.t('edit')),
          ),
          CustomSlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: AppTheme.expense,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: _SlideActionContent(icon: Icons.delete_outline, label: l.t('delete')),
          ),
        ],
      ),
      child: InkWell(
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
                child: Icon(iconFromName(transaction.categoryIcon), color: catColor, size: 22),
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
                      Formatters.date(transaction.date),
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
                    '$sign${Formatters.currency(transaction.amount)}',
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
      ),
    );
  }
}

/// Compact icon+label content for swipe actions — smaller than
/// [SlidableAction]'s built-in (non-configurable) icon size.
class _SlideActionContent extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SlideActionContent({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
