import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/date_filter_bottom_sheet.dart';
import '../../providers/date_filter_provider.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final String? filterCategoryId;
  final String? filterCategoryName;
  const TransactionListScreen({super.key, this.filterCategoryId, this.filterCategoryName});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String? _selectedType;
  int _page = 1;
  bool _isFetchingMore = false;
  bool _initializing = true;
  late ScrollController _scrollController;
  late DateFilterProvider _dateFilter;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _dateFilter = context.read<DateFilterProvider>();
    _dateFilter.addListener(_onDateFilterChanged);
    Future.microtask(() async {
      await _fetchData(reset: true);
      if (mounted) setState(() => _initializing = false);
    });
  }

  void _onDateFilterChanged() => _fetchData(reset: true);

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore) {
      _fetchMore();
    }
  }

  Future<void> _fetchData({bool reset = false}) async {
    if (reset) _page = 1;
    await context.read<TransactionProvider>().fetchTransactions(
      type: _selectedType,
      categoryId: widget.filterCategoryId,
      startDate: _dateFilter.startDate,
      endDate: _dateFilter.endDate,
      page: _page,
    );
  }

  Future<void> _fetchMore() async {
    final provider = context.read<TransactionProvider>();
    if (_page >= provider.totalPages) return;
    setState(() => _isFetchingMore = true);
    _page++;
    await provider.fetchTransactions(
      type: _selectedType,
      categoryId: widget.filterCategoryId,
      startDate: _dateFilter.startDate,
      endDate: _dateFilter.endDate,
      page: _page,
      append: true,
    );
    if (mounted) setState(() => _isFetchingMore = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dateFilter.removeListener(_onDateFilterChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filterCategoryName ?? l.t('transactions')),
        actions: [
          if (widget.filterCategoryId == null) ...[
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
                _fetchData(reset: true);
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'all', child: Text(l.t('all'))),
                PopupMenuItem(value: 'income', child: Text(l.t('income'))),
                PopupMenuItem(value: 'expense', child: Text(l.t('expense'))),
                PopupMenuItem(value: 'investment', child: Text(l.t('investment'))),
              ],
            ),
          ],
        ],
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : provider.transactions.isEmpty
              ? Center(child: Text(l.t('noTransactions')))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.transactions.length + (_isFetchingMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == provider.transactions.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final t = provider.transactions[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: TransactionTile(
                        transaction: t,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TransactionDetailScreen(transaction: t)),
                        ).then((_) => _fetchData(reset: true)),
                      ),
                    );
                  },
                ),
    );
  }
}
