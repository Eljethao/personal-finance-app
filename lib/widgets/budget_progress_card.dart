import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/budget_model.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetStatus status;

  const BudgetProgressCard({super.key, required this.status});

  Color get _statusColor {
    if (status.status == 'exceeded') return AppTheme.expense;
    if (status.status == 'warning') return AppTheme.investment;
    return AppTheme.income;
  }

  IconData get _statusIcon {
    if (status.status == 'exceeded') return Icons.warning_amber_rounded;
    if (status.status == 'warning') return Icons.info_outline_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isExceeded = status.status == 'exceeded';
    final isWarning = status.status == 'warning';
    final progress = (status.percentage / 100).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(
                  status.budget.categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${status.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_statusColor, _statusColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Spent / Budget row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l.t('spent')}: ${Formatters.currency(status.spent)}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              Text(
                '${l.t('budgetAmount')}: ${Formatters.currency(status.budget.amount)}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          // Alert badge
          if (isExceeded || isWarning) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _statusColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon, color: _statusColor, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    isExceeded
                        ? l.t('budgetExceeded')
                        : l.t('budgetWarning'),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
