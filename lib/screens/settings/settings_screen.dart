import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import '../budgets/budget_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l.t('settings'))),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.person, color: Colors.white)),
            title: Text(auth.user?.name ?? ''),
            subtitle: Text(auth.user?.phone ?? ''),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(l.t('budgets')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BudgetScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.t('language')),
            trailing: DropdownButton<String>(
              value: auth.preferredLanguage,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 'en', child: Text(l.t('english'))),
                DropdownMenuItem(value: 'lo', child: Text(l.t('lao'))),
              ],
              onChanged: (v) => auth.setLanguage(v!),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: Text(l.t('biometric')),
            value: auth.biometricEnabled,
            onChanged: (v) => auth.setBiometric(v),
          ),
          ListTile(
            leading: const Icon(Icons.pin),
            title: Text(l.t('changePin')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePinDialog(context, l),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(l.t('logout'),
                style: const TextStyle(color: Colors.red)),
            onTap: () async {
              final navigator = Navigator.of(context);
              await auth.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, AppLocalizations l) {
    final newPinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('changePin')),
        content: TextField(
          controller: newPinCtrl,
          decoration: InputDecoration(labelText: l.t('newPin')),
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              if (newPinCtrl.text.length == 6) {
                await context.read<AuthProvider>().savePin(newPinCtrl.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.t('pinChanged'))));
                }
              }
            },
            child: Text(l.t('save')),
          ),
        ],
      ),
    );
  }
}
