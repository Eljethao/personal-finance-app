import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/analytics_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/date_filter_bottom_sheet.dart';
import '../../providers/date_filter_provider.dart';
import '../transactions/transaction_list_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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
    final p = context.read<AnalyticsProvider>();
    p.fetchByCategory(
      type: 'expense',
      startDate: _dateFilter.startDate,
      endDate: _dateFilter.endDate,
    );
    p.fetchMonthly(year: _dateFilter.startDate?.year);
  }

  @override
  void dispose() {
    _dateFilter.removeListener(_onDateFilterChanged);
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AnalyticsProvider>();
    final byCategory = provider.byCategory;
    final monthly = provider.monthly;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('analytics')),
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
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (byCategory.isNotEmpty) ...[
                  Text(l.t('expenseByCategory'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: byCategory.asMap().entries.map((e) {
                          final item = e.value as Map;
                          final total = byCategory.fold<double>(
                              0,
                              (s, i) =>
                                  s + ((i as Map)['total'] ?? 0).toDouble());
                          final pct = total > 0
                              ? (item['total'] ?? 0) / total * 100
                              : 0.0;
                          final color = _parseColor(
                              (item['category'] as Map?)?['color'] ??
                                  '#4CAF50');
                          return PieChartSectionData(
                            value: (item['total'] ?? 0).toDouble(),
                            title:
                                '${(pct as double).toStringAsFixed(1)}%',
                            color: color,
                            radius: 80,
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...byCategory.map((item) {
                    final i = item as Map;
                    final color = _parseColor(
                        (i['category'] as Map?)?['color'] ?? '#4CAF50');
                    final categoryId = (i['category'] as Map?)?['_id'] as String?;
                    final categoryName = (i['category'] as Map?)?['name'] as String? ?? '';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle)),
                      title: Text(categoryName,
                          style: const TextStyle(fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              Formatters.currency(
                                  (i['total'] ?? 0).toDouble()),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                        ],
                      ),
                      onTap: categoryId == null ? null : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionListScreen(
                            filterCategoryId: categoryId,
                            filterCategoryName: categoryName,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 24),
                if (monthly.isNotEmpty) ...[
                  Text(l.t('monthlyOverview'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        barGroups: monthly.map<BarChartGroupData>((m) {
                          final mo = m as Map;
                          final month = (mo['_id'] ?? 0) as int;
                          final data = (mo['data'] as List?) ?? [];
                          double income = 0, expense = 0;
                          for (final d in data) {
                            final dm = d as Map;
                            if (dm['type'] == 'income') {
                              income = (dm['total'] ?? 0).toDouble();
                            }
                            if (dm['type'] == 'expense') {
                              expense = (dm['total'] ?? 0).toDouble();
                            }
                          }
                          return BarChartGroupData(
                            x: month,
                            barRods: [
                              BarChartRodData(
                                  toY: income,
                                  color: AppTheme.income,
                                  width: 8),
                              BarChartRodData(
                                  toY: expense,
                                  color: AppTheme.expense,
                                  width: 8),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Text(
                                  '${v.toInt()}',
                                  style:
                                      const TextStyle(fontSize: 10)),
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 12, height: 12, color: AppTheme.income),
                      const SizedBox(width: 4),
                      Text(l.t('income'),
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                      Container(
                          width: 12,
                          height: 12,
                          color: AppTheme.expense),
                      const SizedBox(width: 4),
                      Text(l.t('expense'),
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
