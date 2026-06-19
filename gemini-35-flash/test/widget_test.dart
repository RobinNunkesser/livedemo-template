import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:campusflow/main.dart';
import 'package:campusflow/data/providers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de_DE', null);
  });

  testWidgets('Main navigation shell tab switching test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const CampusFlowApp(),
      ),
    );

    // Verify it starts on Stundenplan Screen
    expect(find.text('Stundenplan'), findsWidgets);
    expect(find.text('Dieser Bereich befindet sich noch in der Planung.'), findsOneWidget);

    // Switch to Mensaplan Tab (represented by restaurant icon/label)
    final mensaTab = find.text('Mensaplan');
    expect(mensaTab, findsOneWidget);
    await tester.tap(mensaTab);
    await tester.pumpAndSettle();

    // Verify Mensaplan screen is visible
    expect(find.text('Keine Filter aktiv'), findsOneWidget);

    // Switch to Aufgaben Tab
    final tasksTab = find.text('Aufgaben');
    expect(tasksTab, findsOneWidget);
    await tester.tap(tasksTab);
    await tester.pumpAndSettle();
    
    expect(find.text('Übungsaufgaben'), findsWidgets);

    // Switch to Dozenten Tab
    final lecturersTab = find.text('Dozenten');
    expect(lecturersTab, findsOneWidget);
    await tester.tap(lecturersTab);
    await tester.pumpAndSettle();

    expect(find.text('Dozentenliste'), findsWidgets);
  });
}
