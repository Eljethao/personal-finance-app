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
                // ── Expense by Category ───────────────────────
                if (byCategory.isNotEmpty) ...[
                  Text(l.t('expenseByCategory'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Builder(builder: (ctx) {
                    final total = byCategory.fold<double>(
                        0, (s, i) => s + ((i as Map)['total'] ?? 0).toDouble());
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          // Donut chart with total in center
                          SizedBox(
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sections: byCategory.map((item) {
                                      final i = item as Map;
                                      final pct = total > 0
                                          ? (i['total'] ?? 0) / total * 100
                                          : 0.0;
                                      final color = _parseColor(
                                          (i['category'] as Map?)?['color'] ?? '#4CAF50');
                                      return PieChartSectionData(
                                        value: (i['total'] ?? 0).toDouble(),
                                        title: pct >= 5 ? '${pct.toStringAsFixed(0)}%' : '',
                                        color: color,
                                        radius: 70,
                                        titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList(),
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 52,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l.t('expense'),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        )),
                                    const SizedBox(height: 2),
                                    Text(
                                      Formatters.currency(total),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 4),
                          // Category rows with progress bars
                          ...byCategory.map((item) {
                            final i = item as Map;
                            final color = _parseColor(
                                (i['category'] as Map?)?['color'] ?? '#4CAF50');
                            final categoryId = (i['category'] as Map?)?['_id'] as String?;
                            final categoryName = (i['category'] as Map?)?['name'] as String? ?? '';
                            final amount = (i['total'] ?? 0).toDouble();
                            final pct = total > 0 ? amount / total : 0.0;
                            return InkWell(
                              onTap: categoryId == null
                                  ? null
                                  : () => Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                          builder: (_) => TransactionListScreen(
                                            filterCategoryId: categoryId,
                                            filterCategoryName: categoryName,
                                          ),
                                        ),
                                      ),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(categoryName,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.textPrimary)),
                                        ),
                                        Text(
                                          '${(pct * 100).toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          Formatters.currency(amount),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.chevron_right,
                                            size: 14,
                                            color: AppTheme.textSecondary),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 4,
                                        backgroundColor:
                                            color.withValues(alpha: 0.12),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(color),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 24),
                // ── Monthly Overview ──────────────────────────
                if (monthly.isNotEmpty) ...[
                  Text(l.t('monthlyOverview'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _LegendDot(color: AppTheme.income, label: l.t('income')),
                            const SizedBox(width: 16),
                            _LegendDot(color: AppTheme.expense, label: l.t('expense')),
                            const SizedBox(width: 16),
                            _LegendDot(color: AppTheme.investment, label: l.t('investment')),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 240,
                          child: BarChart(
                            BarChartData(
                              barGroups: monthly.map<BarChartGroupData>((m) {
                                final mo = m as Map;
                                final month = (mo['_id'] ?? 0) as int;
                                final data = (mo['data'] as List?) ?? [];
                                double income = 0, expense = 0, invest = 0;
                                for (final d in data) {
                                  final dm = d as Map;
                                  if (dm['type'] == 'income') income = (dm['total'] ?? 0).toDouble();
                                  if (dm['type'] == 'expense') expense = (dm['total'] ?? 0).toDouble();
                                  if (dm['type'] == 'investment') invest = (dm['total'] ?? 0).toDouble();
                                }
                                return BarChartGroupData(
                                  x: month,
                                  groupVertically: false,
                                  barRods: [
                                    BarChartRodData(
                                      toY: income,
                                      color: AppTheme.income,
                                      width: 7,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    BarChartRodData(
                                      toY: expense,
                                      color: AppTheme.expense,
                                      width: 7,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    BarChartRodData(
                                      toY: invest,
                                      color: AppTheme.investment,
                                      width: 7,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                  barsSpace: 3,
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (v, _) {
                                      const names = [
                                        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                      ];
                                      final idx = v.toInt();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          idx >= 1 && idx <= 12 ? names[idx] : '',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 48,
                                    getTitlesWidget: (v, _) {
                                      if (v == 0) return const SizedBox();
                                      String label;
                                      if (v >= 1000000) {
                                        label = '${(v / 1000000).toStringAsFixed(1)}M';
                                      } else if (v >= 1000) {
                                        label = '${(v / 1000).toStringAsFixed(0)}K';
                                      } else {
                                        label = v.toInt().toString();
                                      }
                                      return Text(label,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: AppTheme.textSecondary,
                                          ));
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: null,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                                  strokeWidth: 1,
                                  dashArray: [4, 4],
                                ),
                              ),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: AppTheme.primaryDark,
                                  tooltipRoundedRadius: 10,
                                  getTooltipItem: (group, _, rod, rodIndex) {
                                    final labels = [l.t('income'), l.t('expense'), l.t('investment')];
                                    return BarTooltipItem(
                                      '${labels[rodIndex]}\n',
                                      const TextStyle(color: Colors.white70, fontSize: 10),
                                      children: [
                                        TextSpan(
                                          text: Formatters.currency(rod.toY),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
