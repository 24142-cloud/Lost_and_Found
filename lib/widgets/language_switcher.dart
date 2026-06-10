import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context);

    return PopupMenuButton<Locale>(
      tooltip: l.text('changeLanguage'),
      icon: const Icon(Icons.language),
      initialValue: localeProvider.locale,
      onSelected: localeProvider.setLocale,
      itemBuilder: (context) => [
        PopupMenuItem(value: const Locale('ar'), child: Text(l.text('arabic'))),
        PopupMenuItem(value: const Locale('fr'), child: Text(l.text('french'))),
      ],
    );
  }
}
