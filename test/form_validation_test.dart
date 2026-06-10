import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/utils/validators.dart';
import 'package:lost_and_found/pages/post_details_page.dart';

void main() {
  test('Login validation requires email and password', () {
    expect(
      Validators.emailWithMessage('', 'Champ obligatoire', 'Email invalide'),
      'Champ obligatoire',
    );
    expect(
      Validators.requiredField('', 'Champ obligatoire'),
      'Champ obligatoire',
    );
  });

  test('Register validation checks email and password confirmation', () {
    expect(
      Validators.emailWithMessage('bad', 'Champ obligatoire', 'Email invalide'),
      'Email invalide',
    );
    expect(
      Validators.confirmPassword(
        'different',
        'secret',
        'Champ obligatoire',
        'Les mots de passe ne correspondent pas',
      ),
      'Les mots de passe ne correspondent pas',
    );
  });

  test('Post form validation requires editable fields', () {
    final requiredFields = ['', ' ', null];

    for (final value in requiredFields) {
      expect(
        Validators.requiredField(value, 'Champ obligatoire'),
        'Champ obligatoire',
      );
    }
  });

  testWidgets('Delete confirmation dialog shows cancel and delete choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        Scaffold(
          body: DeletePostConfirmationDialog(
            title: 'Confirmer la suppression',
            message: 'Voulez-vous vraiment supprimer cette annonce ?',
            cancelLabel: 'Annuler',
            deleteLabel: 'Supprimer',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Confirmer la suppression'), findsOneWidget);
    expect(
      find.text('Voulez-vous vraiment supprimer cette annonce ?'),
      findsOneWidget,
    );
    expect(find.text('Annuler'), findsOneWidget);
    expect(find.text('Supprimer'), findsOneWidget);
  });
}

Widget _localizedApp(Widget child) {
  return MaterialApp(
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: child,
  );
}
