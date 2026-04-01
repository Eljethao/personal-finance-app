import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../utils/icon_map.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => context.read<CategoryProvider>().fetchCategories());
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  Future<String?> _showIconPicker(
      BuildContext context, String current) async {
    final l = AppLocalizations.of(context);
    String search = '';
    String? picked;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) {
          final entries = kCategoryIcons.entries
              .where((e) =>
                  search.isEmpty ||
                  e.key.contains(search.toLowerCase()))
              .toList();

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(sheetCtx).size.height * 0.6,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l.t('searchIcons'),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (v) => setSheet(() => search = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: entries.length,
                      itemBuilder: (_, i) {
                        final name = entries[i].key;
                        final icon = entries[i].value;
                        final isSelected = name == current;
                        return GestureDetector(
                          onTap: () {
                            picked = name;
                            Navigator.pop(sheetCtx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      width: 2)
                                  : null,
                            ),
                            child: Tooltip(
                              message: name,
                              child: Icon(icon,
                                  size: 26,
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                      : Colors.grey.shade700),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
    return picked;
  }

  void _showDialog([CategoryModel? category]) {
    final l = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: category?.name);
    String selectedIcon = category?.icon ?? 'category';
    String type = category?.type ??
        ['income', 'expense', 'investment'][_tabController.index];
    Color selectedColor = _parseColor(category?.color ?? '#4CAF50');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(category == null
              ? l.t('addCategory')
              : l.t('editCategory')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: l.t('name'))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(l.t('icon'),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final picked =
                            await _showIconPicker(ctx, selectedIcon);
                        if (picked != null) {
                          setDialogState(() => selectedIcon = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconFromName(selectedIcon), size: 22),
                            const SizedBox(width: 8),
                            Text(selectedIcon,
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_drop_down,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (category == null)
                  DropdownButtonFormField<String>(
                    value: type,
                    items: ['income', 'expense', 'investment']
                        .map((t) => DropdownMenuItem(
                            value: t, child: Text(l.t(t))))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => type = v!),
                    decoration:
                        InputDecoration(labelText: l.t('type')),
                  ),
                const SizedBox(height: 8),
                Text(l.t('color'),
                    style:
                        const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                BlockPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (c) =>
                      setDialogState(() => selectedColor = c),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.t('cancel'))),
            ElevatedButton(
              onPressed: () async {
                final colorHex =
                    '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
                final provider = context.read<CategoryProvider>();
                if (category == null) {
                  await provider.createCategory({
                    'name': nameCtrl.text,
                    'icon': selectedIcon,
                    'color': colorHex,
                    'type': type,
                  });
                } else {
                  await provider.updateCategory(category.id, {
                    'name': nameCtrl.text,
                    'icon': selectedIcon,
                    'color': colorHex,
                  });
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l.t('save')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<CategoryModel> cats) {
    final l = AppLocalizations.of(context);
    if (cats.isEmpty) {
      return Center(child: Text(l.t('noCategories')));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final c = cats[i];
        final color = _parseColor(c.color);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconFromName(c.icon), color: color),
            ),
            title: Text(c.name),
            subtitle: Text(
                c.isDefault ? l.t('defaultLabel') : l.t('customLabel'),
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 11)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _showDialog(c)),
                if (!c.isDefault)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    onPressed: () => context
                        .read<CategoryProvider>()
                        .deleteCategory(c.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<CategoryProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('categories')),
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: () => _showDialog()),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l.t('income')),
            Tab(text: l.t('expense')),
            Tab(text: l.t('investment')),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(provider.incomeCategories),
                _buildList(provider.expenseCategories),
                _buildList(provider.investmentCategories),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
