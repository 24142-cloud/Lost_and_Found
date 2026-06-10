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
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: const [LanguageSwitcher()],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
          children: [
            _RegisterTitle(
              title: l.text('splash'),
              subtitle: l.text('register'),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: l.text('fullName'),
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) =>
                        Validators.requiredField(value, l.text('required')),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    label: l.text('phoneNumber'),
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        Validators.requiredField(value, l.text('required')),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: l.text('password'),
                    prefixIcon: Icons.lock_outlined,
                    obscureText: true,
                    validator: (value) =>
                        Validators.requiredField(value, l.text('required')),
                  ),
                  const SizedBox(height: 16),
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
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    label: l.text('register'),
                    icon: Icons.person_add_alt_1_rounded,
                    isLoading: authProvider.isLoading,
                    onPressed: _register,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                l.text('alreadyHaveAccount'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterTitle extends StatelessWidget {
  const _RegisterTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: AppColors.primary,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.secondary,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.subtext,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
