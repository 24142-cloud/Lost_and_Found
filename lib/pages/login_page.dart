import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/utils/snackbars.dart';
import 'package:lost_and_found/core/utils/validators.dart';
import 'package:lost_and_found/core/widgets/custom_button.dart';
import 'package:lost_and_found/core/widgets/custom_text_field.dart';
import 'package:lost_and_found/providers/auth_provider.dart';
import 'package:lost_and_found/widgets/language_switcher.dart';

// ─── Design Tokens ──────────────────────────────────────────────────────────
const _kBg = Color(0xFFF7F4EF);
const _kPrimary = Color(0xFF0F6B6F);
const _kText = Color(0xFF2E2E2E);
const _kAccent = Color(0xFFD9B07A);
const _kCard = Color(0xFFFFFFFF);
const _kSubtext = Color(0xFF7A7A7A);
const _kDivider = Color(0xFFE8E2D9);

// ─── Login Page ──────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();



  @override
  void dispose() {

    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context);

    final success = await context.read<AuthProvider>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      AppSnackbars.showSuccess(context, l.text('loginSuccess'));
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      AppSnackbars.showError(
        context,
        context.read<AuthProvider>().errorMessage ?? l.text('genericError'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const SizedBox.shrink(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection:
      Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Hero Header ──────────────────────────────────────────
                const SizedBox(height: 16),
                _AppHero(),
                const SizedBox(height: 36),

                // ── Tab + Form Card ───────────────────────────────────────
                Container(
  decoration: BoxDecoration(
    color: _kCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _kDivider),
  ),
  child: _LoginTab(
    formKey: _loginFormKey,
    emailController: _emailController,
    passwordController: _passwordController,
    authProvider: authProvider,
    l: l,
    onLogin: _login,
  ),
),
                const SizedBox(height: 28),

                // ── Bottom CTA ────────────────────────────────────────────
                _BottomSignupRow(
                  onTap: () {
                  Navigator.pushNamed(context, '/register');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── App Hero ─────────────────────────────────────────────────────────────────
class _AppHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        // Accent dot above title
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: const BoxDecoration(
            color: _kAccent,
            shape: BoxShape.circle,
          ),
        ),
        // App name
        Text(
        l.text('appName'),
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: _kPrimary,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        // Subtitle
        Text(
            
          l.text('appSubtitle'),
  
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 15,
            color: _kSubtext,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        // Thin accent line
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            color: _kAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─── Login Tab ────────────────────────────────────────────────────────────────
class _LoginTab extends StatelessWidget {
  const _LoginTab({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.authProvider,
    required this.l,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final AuthProvider authProvider;
  final AppLocalizations l;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email field
            CustomTextField(
              controller: emailController,
              label: l.text('email'),
              hintText: 'example@mail.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) => Validators.emailWithMessage(
                value,
                l.text('required'),
                l.text('invalidEmail'),
              ),
            ),
            const SizedBox(height: 14),

            // Password field
            CustomTextField(
              controller: passwordController,
              label: l.text('password'),
              hintText: '••••••••',
              obscureText: true,
              validator: (value) =>
                  Validators.requiredField(value, l.text('required')),
            ),
            const SizedBox(height: 6),


            // Error message
            if (authProvider.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  authProvider.errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Login button
            CustomButton(
              label: l.text('login'),
              isLoading: authProvider.isLoading,
              onPressed: onLogin,
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Bottom Signup Row ────────────────────────────────────────────────────────
class _BottomSignupRow extends StatelessWidget {
  const _BottomSignupRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.text('dontHaveAccount'),
          style: TextStyle(
            fontSize: 14,
            color: _kSubtext,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            l.text('createAccount'),
            style: TextStyle(
              fontSize: 14,
              color: _kAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
