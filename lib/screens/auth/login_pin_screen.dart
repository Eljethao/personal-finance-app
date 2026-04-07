import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_theme.dart';
import '../home/home_screen.dart';

class LoginPinScreen extends StatefulWidget {
  final String phone;
  const LoginPinScreen({super.key, required this.phone});

  @override
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen> {
  String _pin = '';
  String _errorMessage = '';
  bool _isLoading = false;

  void _onKeyPress(String value) {
    if (_pin.length >= 6 || _isLoading) return;
    setState(() {
      _pin += value;
      _errorMessage = '';
    });
    if (_pin.length == 6) _submit();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final walletProvider = context.read<WalletProvider>();
    final l = AppLocalizations.of(context);
    final success = await auth.login(widget.phone, _pin);
    if (success && mounted) {
      await auth.savePin(_pin);
      await categoryProvider.fetchCategories();
      await walletProvider.fetchWallets();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else if (mounted) {
      setState(() {
        _pin = '';
        _errorMessage = l.t('incorrectPinLogin');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const Icon(Icons.lock_outline, size: 56, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    l.t('enterPin'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.phone,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.length ? Colors.white : Colors.white30,
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildNumpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
      child: Column(
        children: keys.map((row) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((k) => SizedBox(
            width: 72,
            height: 72,
            child: k.isEmpty
                ? const SizedBox()
                : Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: k == '⌫' ? _onBackspace : () => _onKeyPress(k),
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Colors.white.withValues(alpha: 0.3),
                        highlightColor: Colors.white.withValues(alpha: 0.15),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              k,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                ),
          )).toList(),
        )).toList(),
      ),
    );
  }
}
