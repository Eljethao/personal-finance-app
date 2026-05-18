import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart'; // ThousandsSeparatorFormatter

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<WalletProvider>().fetchWallets());
  }

  void _showDialog([WalletModel? wallet]) {
    final l = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: wallet?.name);
    final currencyCtrl =
        TextEditingController(text: wallet?.currency ?? 'LAK');
    final balanceCtrl = TextEditingController(
      text: wallet != null
          ? ThousandsSeparatorFormatter.format(
              wallet.initialBalance.toInt().toString())
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(wallet == null ? l.t('addWallet') : l.t('editWallet')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l.t('name'))),
            const SizedBox(height: 8),
            TextField(
                controller: currencyCtrl,
                decoration: InputDecoration(labelText: l.t('currency'))),
            const SizedBox(height: 8),
            TextField(
              controller: balanceCtrl,
              decoration:
                  InputDecoration(labelText: l.t('initialBalance')),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorFormatter()],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              final data = <String, dynamic>{
                'name': nameCtrl.text,
                'icon': 'wallet',
                'currency': currencyCtrl.text,
                'initialBalance': double.tryParse(
                        balanceCtrl.text.replaceAll(',', '')) ??
                    0,
              };
              final provider = context.read<WalletProvider>();
              if (wallet == null) {
                await provider.createWallet(data);
              } else {
                await provider.updateWallet(wallet.id, data);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l.t('save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<WalletProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('wallets')),
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: () => _showDialog()),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.wallets.isEmpty
              ? Center(child: Text(l.t('noWallets')))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.wallets.length,
                  itemBuilder: (_, i) {
                    final w = provider.wallets[i];
                    final isDefault = w.id == provider.defaultWalletId;
                    final isPinned = provider.isPinned(w.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: AppTheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    w.currency,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Formatters.currency(w.balance,
                                        currency: w.currency),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: w.balance >= 0
                                          ? AppTheme.income
                                          : AppTheme.expense,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                                size: 18,
                                color: isPinned ? AppTheme.primary : Colors.grey,
                              ),
                              onPressed: () => provider.togglePin(w.id),
                              tooltip: isPinned ? 'Unpin from home' : 'Pin to home screen',
                            ),
                            IconButton(
                              icon: Icon(
                                isDefault ? Icons.star_rounded : Icons.star_border_rounded,
                                size: 20,
                                color: isDefault ? Colors.amber : Colors.grey,
                              ),
                              onPressed: isDefault ? null : () => provider.setDefaultWallet(w.id),
                              tooltip: isDefault ? 'Default wallet' : 'Set as default',
                            ),
                            IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18),
                                onPressed: () => _showDialog(w)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red),
                              onPressed: () =>
                                  provider.deleteWallet(w.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
