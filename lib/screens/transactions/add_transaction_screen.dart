import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../../models/wallet_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/icon_map.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _type = 'expense';
  CategoryModel? _selectedCategory;
  WalletModel? _selectedWallet;
  DateTime _selectedDate = DateTime.now();
  String? _slipImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final cp = context.read<CategoryProvider>();
      if (cp.categories.isEmpty) cp.fetchCategories();
      final wp = context.read<WalletProvider>();
      if (wp.wallets.isEmpty) wp.fetchWallets();
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
        source: source, maxWidth: 1024, imageQuality: 80);
    if (image != null) setState(() => _slipImagePath = image.path);
  }

  void _showImagePicker() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l.t('camera')),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l.t('gallery')),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.t('selectCategory'))));
      return;
    }
    if (_selectedWallet == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.t('selectWallet'))));
      return;
    }

    setState(() => _isLoading = true);
    final txProvider = context.read<TransactionProvider>();

    String? slipUrl;
    if (_slipImagePath != null && _type == 'expense') {
      slipUrl = await txProvider.uploadSlip(_slipImagePath!);
    }

    final data = <String, dynamic>{
      'type': _type,
      'amount': double.parse(_amountCtrl.text.replaceAll(',', '')),
      'categoryId': _selectedCategory!.id,
      'walletId': _selectedWallet!.id,
      'date': _selectedDate.toIso8601String(),
      if (_noteCtrl.text.isNotEmpty) 'note': _noteCtrl.text,
      if (slipUrl != null) 'slipImageUrl': slipUrl,
    };

    final success = await txProvider.createTransaction(data);

    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.t('failedToSave'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wallets = context.watch<WalletProvider>().wallets;
    final allCategories = context.watch<CategoryProvider>().categories;
    final categoriesForType =
        allCategories.where((c) => c.type == _type).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.t('addTransaction'))),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (final t in ['income', 'expense', 'investment'])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(l.t(t),
                              style: const TextStyle(fontSize: 12)),
                          selected: _type == t,
                          selectedColor: t == 'income'
                              ? AppTheme.income
                              : t == 'expense'
                                  ? AppTheme.expense
                                  : AppTheme.investment,
                          labelStyle: TextStyle(
                              color: _type == t ? Colors.white : null),
                          onSelected: (_) => setState(() {
                            _type = t;
                            _selectedCategory = null;
                          }),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                decoration: InputDecoration(
                    labelText: l.t('amount'),
                    prefixIcon: const Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorFormatter()],
                validator: (v) => v!.isEmpty ? l.t('amount') : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: l.t('category'),
                  prefixIcon: _selectedCategory != null
                      ? Icon(iconFromName(_selectedCategory!.icon),
                          color: AppTheme.primary)
                      : const Icon(Icons.category_outlined),
                ),
                items: categoriesForType.map((c) {
                  final color = c.color.isNotEmpty
                      ? Color(int.parse(
                          c.color.replaceFirst('#', '0xFF')))
                      : AppTheme.primary;
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(iconFromName(c.icon), color: color, size: 20),
                        const SizedBox(width: 10),
                        Text(c.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) =>
                    v == null ? l.t('selectCategory') : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WalletModel>(
                value: _selectedWallet,
                decoration: InputDecoration(
                    labelText: l.t('wallet'),
                    prefixIcon: const Icon(
                        Icons.account_balance_wallet_outlined)),
                items: wallets
                    .map((w) =>
                        DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedWallet = v),
                validator: (v) =>
                    v == null ? l.t('selectWallet') : null,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(
                    '${l.t('date')}: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
              const Divider(),
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                    labelText: l.t('note'),
                    prefixIcon: const Icon(Icons.note_outlined)),
                maxLines: 2,
              ),
              if (_type == 'expense') ...[
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(_slipImagePath != null
                      ? l.t('slipAttached')
                      : l.t('attachReceipt')),
                  trailing: _slipImagePath != null
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _slipImagePath = null))
                      : const Icon(Icons.add_photo_alternate_outlined),
                  onTap: _showImagePicker,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(l.t('saveTransaction')),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}
