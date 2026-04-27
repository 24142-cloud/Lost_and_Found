import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lost_and_found/main.dart';

void main() {
  testWidgets('Test affichage texte', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hi'), findsOneWidget);
  });
}