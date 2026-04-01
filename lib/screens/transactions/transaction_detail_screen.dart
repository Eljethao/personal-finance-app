import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('transactionDetail')),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, l),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.category, color: _typeColor, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${transaction.type == 'income' ? '+' : '-'}${Formatters.currency(transaction.amount, currency: transaction.currency)}',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _typeColor),
                  ),
                  Text(transaction.type.toUpperCase(),
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _InfoRow(
                    icon: Icons.category_outlined,
                    label: l.t('category'),
                    value: transaction.categoryName),
                const Divider(height: 1),
                _InfoRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: l.t('wallet'),
                    value: transaction.walletName),
                const Divider(height: 1),
                _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: l.t('date'),
                    value: Formatters.dateTime(transaction.date)),
                if (transaction.note != null) ...[
                  const Divider(height: 1),
                  _InfoRow(
                      icon: Icons.note_outlined,
                      label: l.t('note'),
                      value: transaction.note!),
                ],
              ],
            ),
          ),
          if (transaction.slipImageUrl != null) ...[
            const SizedBox(height: 12),
            Text(l.t('receipt'),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: transaction.slipImageUrl!,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Icon(Icons.error),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l) async {
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
      final provider = context.read<TransactionProvider>();
      final navigator = Navigator.of(context);
      await provider.deleteTransaction(transaction.id);
      navigator.pop();
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
}
