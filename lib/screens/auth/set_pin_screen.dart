import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_theme.dart';
import '../home/home_screen.dart';

class SetPinScreen extends StatefulWidget {
  final String name;
  final String phone;
  const SetPinScreen({super.key, required this.name, required this.phone});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;
  String _errorMessage = '';
  bool _isLoading = false;

  void _onKeyPress(String value) {
    if (_isLoading) return;
    final current = _confirming ? _confirmPin : _pin;
    if (current.length >= 6) return;
    setState(() {
      _errorMessage = '';
      if (_confirming) {
        _confirmPin += value;
      } else {
        _pin += value;
      }
    });
    final newLen = (_confirming ? _confirmPin : _pin).length;
    if (newLen == 6) {
      if (_confirming) {
        _submit();
      } else {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _confirming = true);
        });
      }
    }
  }

  void _onBackspace() {
    if (_isLoading) return;
    setState(() {
      _errorMessage = '';
      if (_confirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _confirming = false;
        }
      } else if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_pin != _confirmPin) {
      setState(() {
        _confirmPin = '';
        _errorMessage = l.t('pinsDoNotMatch');
        _confirming = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final walletProvider = context.read<WalletProvider>();
    final success = await auth.register(widget.name, widget.phone, _pin);
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
        _confirmPin = '';
        _confirming = false;
        _errorMessage = l.t('registrationFailed');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currentPin = _confirming ? _confirmPin : _pin;
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 56, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    _confirming ? l.t('confirmPin') : l.t('setPin'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _confirming
                        ? l.t('enterPinAgain')
                        : l.t('chooseSixDigitPin'),
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
                        color: i < currentPin.length
                            ? Colors.white
                            : Colors.white30,
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
                : TextButton(
                    onPressed: k == '⌫' ? _onBackspace : () => _onKeyPress(k),
                    child: Text(
                      k,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
          )).toList(),
        )).toList(),
      ),
    );
  }
}
