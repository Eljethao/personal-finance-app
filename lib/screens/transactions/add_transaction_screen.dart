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
import '../../utils/slip_parser.dart';

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
  bool _isScanning = false;

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

  Future<void> _scanSlip(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
        source: source, maxWidth: 1600, imageQuality: 90);
    if (image == null || !mounted) return;

    setState(() {
      _slipImagePath = image.path;
      _isScanning = true;
    });

    try {
      final result = await SlipParser.parse(image.path);
      if (!mounted) return;
      final l = AppLocalizations.of(context);

      if (!result.hasData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.t('couldNotReadSlip'))),
        );
        return;
      }

      setState(() {
        if (result.amount != null) {
          _amountCtrl.text = ThousandsSeparatorFormatter.format(
              result.amount!.toInt().toString());
        }
        if (result.date != null) _selectedDate = result.date!;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l.t('slipScanned')}${result.amount != null ? ' ${l.t('amount')}: ${result.amount}' : ''}${result.date != null ? ' ${l.t('date')}: ${result.date!.day}/${result.date!.month}/${result.date!.year}' : ''}',
          ),
          backgroundColor: AppTheme.income,
        ),
      );
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.t('scanFailed'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showScanPicker() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(l.t('scanBankSlip'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(l.t('autoFillFromSlip'),
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
                ),
                title: Text(l.t('takePhoto'), style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(l.t('useCameraForSlip')),
                onTap: () { Navigator.pop(ctx); _scanSlip(ImageSource.camera); },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.photo_library_rounded, color: AppTheme.primary),
                ),
                title: Text(l.t('chooseFromGallery'), style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(l.t('pickExistingSlip')),
                onTap: () { Navigator.pop(ctx); _scanSlip(ImageSource.gallery); },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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
              // ── Scan slip button ─────────────────────────
              InkWell(
                onTap: _isScanning ? null : _showScanPicker,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: _isScanning ? null : AppTheme.primaryGradient,
                    color: _isScanning ? AppTheme.surface : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isScanning ? null : AppTheme.primaryShadow,
                    border: _isScanning
                        ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isScanning)
                        const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                        )
                      else
                        const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _isScanning ? l.t('scanningSlip') : l.t('scanBankSlip'),
                        style: TextStyle(
                          color: _isScanning ? AppTheme.primary : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
