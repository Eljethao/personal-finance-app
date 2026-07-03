import 'dart:io';
import 'package:excel/excel.dart' as xls;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../services/supabase_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _supabase = SupabaseService().client;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  String? _selectedCategoryId;
  bool _isLoading = false;

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<List<TransactionModel>> _fetchTransactions() async {
    var query = _supabase
        .from('transactions')
        .select('*, category:categories(name,icon,color)');
    if (_selectedType != null) query = query.eq('type', _selectedType!);
    if (_selectedCategoryId != null) {
      query = query.eq('category_id', _selectedCategoryId!);
    }
    if (_startDate != null) query = query.gte('date', _startDate!.toIso8601String());
    if (_endDate != null) query = query.lte('date', _endDate!.toIso8601String());
    final rows = await query.order('date', ascending: false);
    return (rows as List)
        .map((r) => TransactionModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<File> _buildExcel(List<TransactionModel> transactions) async {
    final excel = xls.Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];
    sheet.appendRow([
      xls.TextCellValue('Date'),
      xls.TextCellValue('Type'),
      xls.TextCellValue('Category'),
      xls.TextCellValue('Amount'),
      xls.TextCellValue('Currency'),
      xls.TextCellValue('Note'),
    ]);
    for (final t in transactions) {
      sheet.appendRow([
        xls.TextCellValue(
            '${t.date.day}/${t.date.month}/${t.date.year}'),
        xls.TextCellValue(t.type),
        xls.TextCellValue(t.categoryName),
        xls.DoubleCellValue(t.amount),
        xls.TextCellValue('LAK'),
        xls.TextCellValue(t.note ?? ''),
      ]);
    }
    final bytes = excel.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes!);
    return file;
  }

  Future<File> _buildPdf(List<TransactionModel> transactions) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'Transactions'),
          pw.TableHelper.fromTextArray(
            headers: [
              'Date',
              'Type',
              'Category',
              'Amount',
              'Note'
            ],
            data: transactions
                .map((t) => [
                      '${t.date.day}/${t.date.month}/${t.date.year}',
                      t.type,
                      t.categoryName,
                      '${t.amount} LAK',
                      t.note ?? '',
                    ])
                .toList(),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle:
                pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<void> _export(String format) async {
    final l = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      final transactions = await _fetchTransactions();
      final file = format == 'excel'
          ? await _buildExcel(transactions)
          : await _buildPdf(transactions);
      await OpenFile.open(file.path);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.t('exportFailed'))));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final categories = context.watch<CategoryProvider>().categories;
    return Scaffold(
      appBar: AppBar(title: Text(l.t('export'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.t('filters'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_startDate == null
                        ? l.t('startDate')
                        : '${l.t('startDate')}: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                    trailing:
                        const Icon(Icons.calendar_today_outlined),
                    onTap: () => _pickDate(true),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_endDate == null
                        ? l.t('endDate')
                        : '${l.t('endDate')}: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                    trailing:
                        const Icon(Icons.calendar_today_outlined),
                    onTap: () => _pickDate(false),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(labelText: l.t('type')),
                    items: [null, 'income', 'expense', 'investment']
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t != null ? l.t(t) : l.t('all'))))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration:
                        InputDecoration(labelText: l.t('category')),
                    items: [
                      DropdownMenuItem(
                          value: null, child: Text(l.t('all'))),
                      ...categories.map((c) => DropdownMenuItem(
                          value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedCategoryId = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _export('excel'),
                        icon: const Icon(Icons.table_chart),
                        label: Text(l.t('exportExcelLabel')),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _export('pdf'),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(l.t('exportPdf')),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
