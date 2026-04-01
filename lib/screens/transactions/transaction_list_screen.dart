import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/date_filter_bottom_sheet.dart';
import '../../providers/date_filter_provider.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String? _selectedType;

  late DateFilterProvider _dateFilter;

  @override
  void initState() {
    super.initState();
    _dateFilter = context.read<DateFilterProvider>();
    _dateFilter.addListener(_onDateFilterChanged);
    Future.microtask(() => _fetchData());
  }

  void _onDateFilterChanged() {
    _fetchData();
  }

  void _fetchData() {
    context.read<TransactionProvider>().fetchTransactions(
      type: _selectedType,
      startDate: _dateFilter.startDate,
      endDate: _dateFilter.endDate,
    );
  }

  @override
  void dispose() {
    _dateFilter.removeListener(_onDateFilterChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('transactions')),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const DateFilterBottomSheet(),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) {
              setState(() => _selectedType = v == 'all' ? null : v);
              _fetchData();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'all', child: Text(l.t('all'))),
              PopupMenuItem(value: 'income', child: Text(l.t('income'))),
              PopupMenuItem(value: 'expense', child: Text(l.t('expense'))),
              PopupMenuItem(
                  value: 'investment', child: Text(l.t('investment'))),
            ],
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.transactions.isEmpty
              ? Center(child: Text(l.t('noTransactions')))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.transactions.length,
                  itemBuilder: (_, i) {
                    final t = provider.transactions[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: TransactionTile(
                        transaction: t,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  TransactionDetailScreen(transaction: t)),
                        ).then((_) => _fetchData()),
                      ),
                    );
                  },
                ),
    );
  }
}
