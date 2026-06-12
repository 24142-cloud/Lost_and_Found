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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context);

    final success = await context.read<AuthProvider>().register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      AppSnackbars.showSuccess(context, l.text('registerSuccess'));
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.secondary,
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [LanguageSwitcher()],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
          children: [
            // ── Header ──────────────────────────────────────────────
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    l.text('appName'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.secondary,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l.text('register'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.subtext,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 38),

            // ── Form card ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: l.text('fullName'),
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) =>
                        Validators.requiredField(value, l.text('required')),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _emailController,
                    label: l.text('email'),
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => Validators.emailWithMessage(
                      value,
                      l.text('required'),
                      l.text('invalidEmail'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _phoneController,
                    label: l.text('phoneNumber'),
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        Validators.requiredField(value, l.text('required')),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _passwordController,
                    label: l.text('password'),
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: (value) =>
                        Validators.requiredField(value, l.text('required')),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: l.text('confirmPassword'),
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                      l.text('required'),
                      l.text('passwordsDoNotMatch'),
                    ),
                  ),
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 22),
                  CustomButton(
                    label: l.text('register'),
                    isLoading: authProvider.isLoading,
                    onPressed: _register,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Footer link ──────────────────────────────────────────
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtext,
                  ),
                  children: [
                    TextSpan(text: '${l.text('alreadyHaveAccount')}  '),
                    TextSpan(
                      text: l.text('login'),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}