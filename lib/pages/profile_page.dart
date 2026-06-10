import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/utils/snackbars.dart';
import 'package:lost_and_found/providers/auth_provider.dart';
import 'package:lost_and_found/widgets/language_switcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final l = AppLocalizations.of(context);
    final appUser = authProvider.appUser;
    final firebaseUser = authProvider.firebaseUser;
    final displayName = appUser?.name ?? firebaseUser?.email ?? 'D';

    return Scaffold(
      appBar: AppBar(
        title: Text(l.text('profile')),
        actions: const [LanguageSwitcher()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFFF4ECE2),
                  child: Text(
                    displayName.isEmpty ? 'D' : displayName.substring(0, 1),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  appUser?.name ?? firebaseUser?.displayName ?? '-',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  appUser?.email ?? firebaseUser?.email ?? '-',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _ProfileRow(
                  icon: Icons.person_outline_rounded,
                  title: l.text('name'),
                  subtitle: appUser?.name ?? firebaseUser?.displayName ?? '-',
                ),
                const Divider(height: 1, indent: 56),
                _ProfileRow(
                  icon: Icons.email_outlined,
                  title: l.text('email'),
                  subtitle: appUser?.email ?? firebaseUser?.email ?? '-',
                ),
                const Divider(height: 1, indent: 56),
                _ProfileRow(
                  icon: Icons.call_outlined,
                  title: l.text('phoneNumber'),
                  subtitle: appUser?.phone.isNotEmpty == true
                      ? appUser!.phone
                      : '-',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              AppSnackbars.showSuccess(context, l.text('logoutSuccess'));
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
            label: Text(l.text('logout')),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.subtext,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
