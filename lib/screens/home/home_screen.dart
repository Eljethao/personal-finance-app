import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/date_filter_bottom_sheet.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_detail_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../wallets/wallet_screen.dart';
import '../categories/category_screen.dart';
import '../export/export_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';
import '../../providers/date_filter_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late DateFilterProvider _dateFilter;

  @override
  void initState() {
    super.initState();
    _dateFilter = context.read<DateFilterProvider>();
    _dateFilter.addListener(_onDateFilterChanged);
    Future.microtask(() => _loadData());
  }

  void _onDateFilterChanged() {
    _loadData();
  }

  @override
  void dispose() {
    _dateFilter.removeListener(_onDateFilterChanged);
    super.dispose();
  }

  Future<void> _loadData() async {
    final start = _dateFilter.startDate;
    final end = _dateFilter.endDate;

    await Future.wait([
      context.read<AnalyticsProvider>().fetchSummary(startDate: start, endDate: end),
      context.read<WalletProvider>().fetchWallets(),
      context.read<TransactionProvider>().fetchTransactions(startDate: start, endDate: end),
      context.read<BudgetProvider>().fetchBudgetStatus(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pages = [
      _DashboardPage(onRefresh: _loadData),
      const TransactionListScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              ).then((_) => _loadData()),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: l.t('home')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long_rounded),
              label: l.t('transactions')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.bar_chart_rounded),
              label: l.t('analytics')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: l.t('settings')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Dashboard Page
// ─────────────────────────────────────────────
class _DashboardPage extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _DashboardPage({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final analytics = context.watch<AnalyticsProvider>();
    final wallets = context.watch<WalletProvider>();
    final transactions = context.watch<TransactionProvider>();
    final summary = analytics.summary;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l.t('dashboard'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const DateFilterBottomSheet(),
              );
            },
          ),
          IconButton(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WalletScreen()))),
          IconButton(
              icon: const Icon(Icons.category_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CategoryScreen()))),
          IconButton(
              icon: const Icon(Icons.file_download_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ExportScreen()))),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            // ── Balance card ──────────────────────────────
            if (summary != null)
              _BalanceCard(summary: summary, l: l)
            else
              _BalanceCardSkeleton(),

            const SizedBox(height: 28),

            // ── Wallets ───────────────────────────────────
            _SectionHeader(title: l.t('wallets'), action: l.t('seeAll'),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const WalletScreen()))),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: wallets.wallets.length,
                padding: EdgeInsets.zero,
                itemBuilder: (_, i) {
                  final w = wallets.wallets[i];
                  final isPrimary = i == 0;
                  return GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const WalletScreen())),
                    child: Container(
                      width: 168,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isPrimary ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isPrimary
                            ? AppTheme.primaryShadow
                            : AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: isPrimary
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppTheme.primary,
                            size: 22,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w.name,
                                style: TextStyle(
                                  color: isPrimary
                                      ? Colors.white70
                                      : AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                Formatters.currency(w.balance,
                                    currency: w.currency),
                                style: TextStyle(
                                  color: isPrimary
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // ── Recent Transactions ───────────────────────
            _SectionHeader(
                title: l.t('recentTransactions'),
                action: '',
                onTap: null),
            const SizedBox(height: 12),

            if (transactions.isLoading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator()))
            else if (transactions.transactions.isEmpty)
              Center(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l.t('noTransactionsYet'),
                          style: const TextStyle(
                              color: AppTheme.textSecondary))))
            else
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    ...transactions.transactions.take(10).map((t) {
                      final isLast =
                          transactions.transactions.indexOf(t) ==
                                  (transactions.transactions.length > 10
                                      ? 9
                                      : transactions.transactions.length - 1);
                      return Column(
                        children: [
                          TransactionTile(
                            transaction: t,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TransactionDetailScreen(transaction: t)),
                            ),
                          ),
                          if (!isLast)
                            const Divider(
                                height: 1, indent: 80, endIndent: 16),
                        ],
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Balance Card
// ─────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final Map summary;
  final AppLocalizations l;
  const _BalanceCard({required this.summary, required this.l});

  @override
  Widget build(BuildContext context) {
    final netBalance = (summary['netBalance'] ?? 0).toDouble();
    final income = (summary['income'] ?? 0).toDouble();
    final expense = (summary['expense'] ?? 0).toDouble();
    final invest = (summary['investment'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + month
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.t('netBalance'),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  Formatters.monthYear(DateTime.now()),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Balance amount
          Text(
            Formatters.currency(netBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          // Glassmorphism stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                _MiniStat(
                  label: l.t('income'),
                  amount: income,
                  icon: Icons.arrow_circle_down_rounded,
                  color: AppTheme.income,
                ),
                Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.2)),
                _MiniStat(
                  label: l.t('expense'),
                  amount: expense,
                  icon: Icons.arrow_circle_up_rounded,
                  color: AppTheme.expense,
                ),
                Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.2)),
                _MiniStat(
                  label: l.t('investment'),
                  amount: invest,
                  icon: Icons.show_chart_rounded,
                  color: AppTheme.investment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Mini stat inside balance card
// ─────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _MiniStat(
      {required this.label,
      required this.amount,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 13),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            Formatters.currency(amount),
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Balance card skeleton while loading
// ─────────────────────────────────────────────
class _BalanceCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.primaryShadow,
      ),
      child: const Center(
          child: CircularProgressIndicator(color: Colors.white38)),
    );
  }
}

// ─────────────────────────────────────────────
//  Section header
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onTap;
  const _SectionHeader(
      {required this.title, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        if (action.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            child: Text(action,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
      ],
    );
  }
}
