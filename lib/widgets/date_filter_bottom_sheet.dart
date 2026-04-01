import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/date_filter_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class DateFilterBottomSheet extends StatelessWidget {
  const DateFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<DateFilterProvider>();
    final selected = provider.selectedRange;

    final options = [
      {'value': 'today', 'label': l.t('today')},
      {'value': 'lastDay', 'label': l.t('lastDay')},
      {'value': 'thisMonth', 'label': l.t('thisMonth')},
      {'value': 'lastMonth', 'label': l.t('lastMonth')},
      {'value': 'thisYear', 'label': l.t('thisYear')},
      {'value': 'all', 'label': l.t('all')},
      {'value': 'custom', 'label': l.t('customRange')},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.t('filterByDate'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = selected == opt['value'];
              return ChoiceChip(
                label: Text(opt['label']!),
                selected: isSelected,
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (bool checked) async {
                  if (checked) {
                    if (opt['value'] == 'custom') {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDateRange: provider.startDate != null && provider.endDate != null
                            ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
                            : null,
                      );
                      if (picked != null) {
                        provider.setFilter('custom', start: picked.start, end: picked.end);
                        if (context.mounted) Navigator.pop(context);
                      }
                    } else {
                      provider.setFilter(opt['value']!);
                      Navigator.pop(context);
                    }
                  }
                },
              );
            }).toList(),
          ),
          if (selected == 'custom' && provider.startDate != null && provider.endDate != null) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.date_range, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${Formatters.date(provider.startDate!)} - ${Formatters.date(provider.endDate!)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
