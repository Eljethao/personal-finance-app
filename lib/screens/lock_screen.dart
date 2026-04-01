import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'home/home_screen.dart';
import 'auth/login_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _localAuth = LocalAuthentication();
  String _enteredPin = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final auth = context.read<AuthProvider>();
    if (!auth.biometricEnabled) return;
    final l = AppLocalizations.of(context);
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return;
      final authenticated = await _localAuth.authenticate(
        localizedReason: l.t('authenticateReason'),
        options: const AuthenticationOptions(biometricOnly: false),
      );
      if (authenticated && mounted) _navigateHome();
    } catch (_) {}
  }

  void _onKeyPress(String value) {
    if (_enteredPin.length >= 6) return;
    setState(() {
      _enteredPin += value;
      _errorMessage = '';
    });
    if (_enteredPin.length == 6) _verifyPin();
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(
        () => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
  }

  Future<void> _verifyPin() async {
    final l = AppLocalizations.of(context);
    final valid = await context.read<AuthProvider>().verifyPin(_enteredPin);
    if (valid) {
      _navigateHome();
    } else {
      setState(() {
        _enteredPin = '';
        _errorMessage = l.t('incorrectPin');
      });
    }
  }

  void _navigateHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                    onPressed: _logout,
                    child: Text(l.t('logout'),
                        style: const TextStyle(color: Colors.white70))),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(l.t('enterPin'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _enteredPin.length
                              ? Colors.white
                              : Colors.white30,
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 32),
                  if (context.read<AuthProvider>().biometricEnabled)
                    TextButton.icon(
                      onPressed: _tryBiometric,
                      icon: const Icon(Icons.fingerprint,
                          color: Colors.white),
                      label: Text(l.t('useBiometric'),
                          style: const TextStyle(color: Colors.white)),
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
      ['', '0', '⌫']
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
      child: Column(
        children: keys
            .map((row) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row
                      .map((k) => SizedBox(
                            width: 72,
                            height: 72,
                            child: k.isEmpty
                                ? const SizedBox()
                                : TextButton(
                                    onPressed: k == '⌫'
                                        ? _onBackspace
                                        : () => _onKeyPress(k),
                                    child: Text(k,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600)),
                                  ),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }
}
