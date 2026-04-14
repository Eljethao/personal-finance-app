import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'login_pin_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPinScreen(phone: _phoneCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
        children: [
          // ── Gradient hero ─────────────────────────────
          Expanded(
            flex: 4,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Image.asset('assets/images/wallet.png', width: 42, height: 42),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.t('appName'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.t('signInToContinue'),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── White form panel ──────────────────────────
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.t('login'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.t('signInToContinue'),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _phoneCtrl,
                            decoration: InputDecoration(
                              labelText: l.t('phoneNumber'),
                              hintText: '20XXXXXXXX',
                              prefixIcon:
                                  const Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _continue(),
                            validator: (v) => v!.isEmpty
                                ? l.t('phoneNumber')
                                : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _continue,
                              child: Text(l.t('continueBtn')),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen())),
                        child: Text(l.t('dontHaveAccount')),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'v${AppConstants.appVersion}',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }
}
