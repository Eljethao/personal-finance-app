import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      // App
      'appName': 'Personal Finance',
      'loading': 'Loading...',

      // Auth
      'login': 'Login',
      'register': 'Register',
      'signInToContinue': 'Sign in to continue',
      'phoneNumber': 'Phone Number',
      'continueBtn': 'Continue',
      'dontHaveAccount': "Don't have an account? Register",
      'alreadyHaveAccount': 'Already have an account? Login',
      'createAccount': 'Create Account',
      'fullName': 'Full Name',
      'name': 'Name',
      'pin': 'PIN',
      'enterPin': 'Enter PIN',
      'setPin': 'Set PIN',
      'confirmPin': 'Confirm PIN',
      'chooseSixDigitPin': 'Choose a 6-digit PIN',
      'enterPinAgain': 'Enter your PIN again to confirm',
      'pinsDoNotMatch': 'PINs do not match. Try again.',
      'incorrectPin': 'Incorrect PIN. Try again.',
      'incorrectPinLogin': 'Incorrect PIN. Please try again.',
      'registrationFailed': 'Registration failed. Phone may already be in use.',

      // Navigation
      'home': 'Home',
      'dashboard': 'Dashboard',
      'transactions': 'Transactions',
      'wallets': 'Wallets',
      'categories': 'Categories',
      'budgets': 'Budgets',
      'analytics': 'Analytics',
      'settings': 'Settings',
      'export': 'Export',
      'seeAll': 'See all',

      // Transaction types
      'income': 'Income',
      'expense': 'Expense',
      'investment': 'Investment',
      'totalIncome': 'Total Income',
      'totalExpense': 'Total Expenses',
      'totalInvestment': 'Total Investment',
      'netBalance': 'Net Balance',

      // Transactions
      'recentTransactions': 'Recent Transactions',
      'addTransaction': 'Add Transaction',
      'saveTransaction': 'Save Transaction',
      'transactionDetail': 'Transaction Detail',
      'deleteTransaction': 'Delete Transaction',
      'deleteTransactionConfirm':
          'Are you sure you want to delete this transaction?',
      'noTransactions': 'No transactions found',
      'noTransactionsYet': 'No transactions yet',
      'amount': 'Amount',
      'category': 'Category',
      'wallet': 'Wallet',
      'date': 'Date',
      'note': 'Note (optional)',
      'receipt': 'Receipt',
      'attachReceipt': 'Attach Receipt (optional)',
      'slipAttached': 'Slip attached ✓',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'selectCategory': 'Please select a category',
      'selectWallet': 'Please select a wallet',
      'failedToSave': 'Failed to save transaction',

      // Wallets
      'addWallet': 'Add Wallet',
      'editWallet': 'Edit Wallet',
      'noWallets': 'No wallets. Tap + to add one.',
      'currency': 'Currency',
      'initialBalance': 'Initial Balance',

      // Categories
      'addCategory': 'Add Category',
      'editCategory': 'Edit Category',
      'noCategories': 'No categories',
      'icon': 'Icon',
      'color': 'Color',
      'type': 'Type',
      'defaultLabel': 'Default',
      'customLabel': 'Custom',
      'searchIcons': 'Search icons...',

      // Budgets
      'addBudget': 'Add Budget',
      'editBudget': 'Edit Budget',
      'deleteBudget': 'Delete Budget',
      'setBudget': 'Set Budget',
      'budgetAmount': 'Budget Amount',
      'month': 'Month',
      'year': 'Year',
      'spent': 'Spent',
      'remaining': 'Remaining',
      'noBudgets': 'No budgets set. Tap + to add one.',

      // Analytics
      'expenseByCategory': 'Expense by Category',
      'monthlyOverview': 'Monthly Overview',

      // Export
      'exportExcel': 'Export Excel',
      'exportExcelLabel': 'Export Excel (.xlsx)',
      'exportPdf': 'Export PDF',
      'filters': 'Filters',
      'startDate': 'Start Date',
      'endDate': 'End Date',
      'all': 'All',
      'filter': 'Filter',
      'exportFailed': 'Export failed',
      'budgetExceeded': 'Budget exceeded!',
      'budgetWarning': 'Approaching budget limit',

      // Settings
      'language': 'Language',
      'biometric': 'Biometric Authentication',
      'useBiometric': 'Use Biometric',
      'authenticateReason': 'Authenticate to access your finances',
      'changePin': 'Change PIN',
      'newPin': 'New PIN (6 digits)',
      'pinChanged': 'PIN changed successfully',
      'logout': 'Logout',

      // General
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'welcomeBack': 'Welcome Back',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'custom': 'Custom',
      'english': 'English',
      'lao': 'ລາວ',
      'slipImage': 'Receipt Image (optional)',
      'today': 'Today',
      'lastDay': 'Yesterday',
      'thisMonth': 'This Month',
      'lastMonth': 'Last Month',
      'thisYear': 'This Year',
      'customRange': 'Custom Range',
      'filterByDate': 'Filter by Date',
    },
    'lo': {
      // App
      'appName': 'ການເງິນສ່ວນຕົວ',
      'loading': 'ກຳລັງໂຫລດ...',

      // Auth
      'login': 'ເຂົ້າສູ່ລະບົບ',
      'register': 'ລົງທະບຽນ',
      'signInToContinue': 'ເຂົ້າສູ່ລະບົບເພື່ອສືບຕໍ່',
      'phoneNumber': 'ເບີໂທລະສັບ',
      'continueBtn': 'ສືບຕໍ່',
      'dontHaveAccount': 'ບໍ່ມີບັນຊີ? ລົງທະບຽນ',
      'alreadyHaveAccount': 'ມີບັນຊີແລ້ວ? ເຂົ້າສູ່ລະບົບ',
      'createAccount': 'ສ້າງບັນຊີ',
      'fullName': 'ຊື່ເຕັມ',
      'name': 'ຊື່',
      'pin': 'ລະຫັດ PIN',
      'enterPin': 'ປ້ອນ PIN',
      'setPin': 'ຕັ້ງ PIN',
      'confirmPin': 'ຢືນຢັນ PIN',
      'chooseSixDigitPin': 'ເລືອກ PIN 6 ຕົວເລກ',
      'enterPinAgain': 'ປ້ອນ PIN ອີກຄັ້ງເພື່ອຢືນຢັນ',
      'pinsDoNotMatch': 'PIN ບໍ່ກົງກັນ. ລອງໃໝ່.',
      'incorrectPin': 'PIN ບໍ່ຖືກ. ລອງໃໝ່.',
      'incorrectPinLogin': 'PIN ບໍ່ຖືກ. ກະລຸນາລອງໃໝ່.',
      'registrationFailed': 'ການລົງທະບຽນລົ້ມເຫຼວ. ເບີໂທລະສັບອາດຖືກໃຊ້ແລ້ວ.',

      // Navigation
      'home': 'ໜ້າຫຼັກ',
      'dashboard': 'ໜ້າຫຼັກ',
      'transactions': 'ລາຍການ',
      'wallets': 'ກະເປົ໋າ',
      'categories': 'ປະເພດ',
      'budgets': 'ງົບປະມານ',
      'analytics': 'ການວິເຄາະ',
      'settings': 'ການຕັ້ງຄ່າ',
      'export': 'ສົ່ງອອກ',
      'seeAll': 'ເບິ່ງທັງໝົດ',

      // Transaction types
      'income': 'ລາຍຮັບ',
      'expense': 'ລາຍຈ່າຍ',
      'investment': 'ການລົງທຶນ',
      'totalIncome': 'ລາຍຮັບທັງໝົດ',
      'totalExpense': 'ລາຍຈ່າຍທັງໝົດ',
      'totalInvestment': 'ການລົງທຶນທັງໝົດ',
      'netBalance': 'ຍອດສຸດທິ',

      // Transactions
      'recentTransactions': 'ລາຍການຫຼ້າສຸດ',
      'addTransaction': 'ເພີ່ມລາຍການ',
      'saveTransaction': 'ບັນທຶກລາຍການ',
      'transactionDetail': 'ລາຍລະອຽດລາຍການ',
      'deleteTransaction': 'ລຶບລາຍການ',
      'deleteTransactionConfirm': 'ທ່ານຕ້ອງການລຶບລາຍການນີ້ບໍ?',
      'noTransactions': 'ບໍ່ພົບລາຍການ',
      'noTransactionsYet': 'ຍັງບໍ່ມີລາຍການ',
      'amount': 'ຈຳນວນ',
      'category': 'ປະເພດ',
      'wallet': 'ກະເປົ໋າ',
      'date': 'ວັນທີ',
      'note': 'ໝາຍເຫດ (ທາງເລືອກ)',
      'receipt': 'ໃບບິນ',
      'attachReceipt': 'ແນບໃບບິນ (ທາງເລືອກ)',
      'slipAttached': 'ແນບໃບບິນແລ້ວ ✓',
      'camera': 'ກ້ອງຖ່າຍຮູບ',
      'gallery': 'ຄັງຮູບ',
      'selectCategory': 'ກະລຸນາເລືອກປະເພດ',
      'selectWallet': 'ກະລຸນາເລືອກກະເປົ໋າ',
      'failedToSave': 'ບໍ່ສາມາດບັນທຶກລາຍການໄດ້',

      // Wallets
      'addWallet': 'ເພີ່ມກະເປົ໋າ',
      'editWallet': 'ແກ້ໄຂກະເປົ໋າ',
      'noWallets': 'ບໍ່ມີກະເປົ໋າ. ກົດ + ເພື່ອເພີ່ມ.',
      'currency': 'ສະກຸນເງິນ',
      'initialBalance': 'ຍອດເງິນເລີ່ມຕົ້ນ',

      // Categories
      'addCategory': 'ເພີ່ມປະເພດ',
      'editCategory': 'ແກ້ໄຂປະເພດ',
      'noCategories': 'ບໍ່ມີປະເພດ',
      'icon': 'ໄອຄອນ',
      'color': 'ສີ',
      'type': 'ປະເພດ',
      'defaultLabel': 'ຄ່າເລີ່ມຕົ້ນ',
      'customLabel': 'ກຳນົດເອງ',
      'searchIcons': 'ຄົ້ນຫາໄອຄອນ...',

      // Budgets
      'addBudget': 'ເພີ່ມງົບ',
      'editBudget': 'ແກ້ໄຂງົບ',
      'deleteBudget': 'ລຶບງົບ',
      'setBudget': 'ຕັ້ງງົບ',
      'budgetAmount': 'ຈຳນວນງົບ',
      'month': 'ເດືອນ',
      'year': 'ປີ',
      'spent': 'ໃຊ້ໄປ',
      'remaining': 'ເຫຼືອ',
      'noBudgets': 'ຍັງບໍ່ມີງົບ. ກົດ + ເພື່ອເພີ່ມ.',

      // Analytics
      'expenseByCategory': 'ລາຍຈ່າຍຕາມປະເພດ',
      'monthlyOverview': 'ພາບລວມລາຍເດືອນ',

      // Export
      'exportExcel': 'ສົ່ງອອກ Excel',
      'exportExcelLabel': 'ສົ່ງອອກ Excel (.xlsx)',
      'exportPdf': 'ສົ່ງອອກ PDF',
      'filters': 'ການກັ່ນຕອງ',
      'startDate': 'ວັນທີເລີ່ມຕົ້ນ',
      'endDate': 'ວັນທີສິ້ນສຸດ',
      'all': 'ທັງໝົດ',
      'filter': 'ກັ່ນຕອງ',
      'exportFailed': 'ການສົ່ງອອກລົ້ມເຫຼວ',
      'budgetExceeded': 'ເກີນງົບ!',
      'budgetWarning': 'ໃກ້ຮອດຂອບເຂດງົບ',

      // Settings
      'language': 'ພາສາ',
      'biometric': 'ການຢືນຢັນຊີວະມິຕິ',
      'useBiometric': 'ໃຊ້ຊີວະມິຕິ',
      'authenticateReason': 'ຢືນຢັນຕົວຕົນເພື່ອເຂົ້າເຖິງຂໍ້ມູນການເງິນ',
      'changePin': 'ປ່ຽນ PIN',
      'newPin': 'PIN ໃໝ່ (6 ຕົວເລກ)',
      'pinChanged': 'ປ່ຽນ PIN ສຳເລັດ',
      'logout': 'ອອກ',

      // General
      'save': 'ບັນທຶກ',
      'cancel': 'ຍົກເລີກ',
      'delete': 'ລຶບ',
      'edit': 'ແກ້ໄຂ',
      'welcomeBack': 'ຍິນດີຕ້ອນຮັບກັບຄືນ',
      'monthly': 'ລາຍເດືອນ',
      'yearly': 'ລາຍປີ',
      'custom': 'ກຳນົດເອງ',
      'english': 'English',
      'lao': 'ລາວ',
      'slipImage': 'ຮູບໃບບິນ (ທາງເລືອກ)',
      'today': 'ມື້ນີ້',
      'lastDay': 'ມື້ວານນີ້',
      'thisMonth': 'ເດືອນນີ້',
      'lastMonth': 'ເດືອນກ່ອນ',
      'thisYear': 'ປີນີ້',
      'customRange': 'ກຳນົດຊ່ວງເວລາ',
      'filterByDate': 'ກັ່ນຕອງຕາມວັນທີ',
    },
  };

  String t(String key) =>
      _strings[locale.languageCode]?[key] ?? _strings['lo']?[key] ?? key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'lo'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
