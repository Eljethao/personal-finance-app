import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/budget_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/budget_progress_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetProvider>().fetchBudgetStatus();
    context.read<CategoryProvider>().fetchCategories();
  }

  void _showDialog([BudgetModel? budget]) {
    final l = AppLocalizations.of(context);
    final amountCtrl = TextEditingController(
        text: budget != null
            ? ThousandsSeparatorFormatter.format(
                budget.amount.toInt().toString())
            : '');
    String? selectedCategoryId = budget?.categoryId;
    int selectedMonth = budget?.month ?? DateTime.now().month;
    int selectedYear = budget?.year ?? DateTime.now().year;
    final yearCtrl = TextEditingController(text: selectedYear.toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final cats = context.read<CategoryProvider>().expenseCategories;
          return AlertDialog(
            title: Text(budget == null ? l.t('setBudget') : l.t('editBudget')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (budget == null)
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration:
                        InputDecoration(labelText: l.t('category')),
                    items: cats
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedCategoryId = v),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  decoration:
                      InputDecoration(labelText: l.t('budgetAmount')),
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorFormatter()],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedMonth,
                        decoration:
                            InputDecoration(labelText: l.t('month')),
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                              value: i + 1, child: Text('${i + 1}')),
                        ),
                        onChanged: (v) =>
                            setDialogState(() => selectedMonth = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: yearCtrl,
                        decoration:
                            InputDecoration(labelText: l.t('year')),
                        keyboardType: TextInputType.number,
                        onChanged: (v) =>
                            selectedYear = int.tryParse(v) ?? selectedYear,
                      ),
                    ),
                  ],
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
                    'amount': double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0,
                    'month': selectedMonth,
                    'year': selectedYear,
                    if (budget == null && selectedCategoryId != null)
                      'categoryId': selectedCategoryId,
                  };
                  final provider = context.read<BudgetProvider>();
                  if (budget == null) {
                    await provider.createBudget(data);
                  } else {
                    await provider.updateBudget(budget.id, data);
                  }
                  await provider.fetchBudgetStatus();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(l.t('save')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BudgetModel budget) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('deleteBudget')),
        content: Text('${l.t('deleteBudget')} ${budget.categoryName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.t('cancel'))),
          TextButton(
            onPressed: () async {
              final provider = context.read<BudgetProvider>();
              await provider.deleteBudget(budget.id);
              await provider.fetchBudgetStatus();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l.t('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<BudgetProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('budgets')),
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: () => _showDialog()),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.budgetStatuses.isEmpty
              ? Center(child: Text(l.t('noBudgets')))
              : ListView(
                  children: provider.budgetStatuses
                      .map((s) => GestureDetector(
                            onLongPress: () => _showDeleteDialog(s.budget),
                            child: BudgetProgressCard(status: s),
                          ))
                      .toList(),
                ),
    );
  }
}
