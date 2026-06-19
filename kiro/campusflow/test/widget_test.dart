import 'package:campusflow/shared/widgets/empty_state.dart';
import 'package:campusflow/shared/widgets/error_state.dart';
import 'package:campusflow/shared/widgets/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadingState', () {
    testWidgets('zeigt Standard-Ladeanzeige', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingState())),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Wird geladen…'), findsOneWidget);
    });

    testWidgets('zeigt benutzerdefinierten Text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(message: 'Mensaplan wird geladen…'),
          ),
        ),
      );
      expect(find.text('Mensaplan wird geladen…'), findsOneWidget);
    });
  });

  group('ErrorState', () {
    testWidgets('zeigt Fehlermeldung und Retry-Button', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Fehler aufgetreten.',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Fehler aufgetreten.'), findsOneWidget);
      expect(find.text('Neu laden'), findsOneWidget);

      await tester.tap(find.text('Neu laden'));
      expect(retried, isTrue);
    });

    testWidgets('ohne onRetry wird kein Button angezeigt', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(message: 'Kein Retry'),
          ),
        ),
      );
      expect(find.text('Neu laden'), findsNothing);
    });
  });

  group('EmptyState', () {
    testWidgets('zeigt Nachricht', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(message: 'Keine Gerichte vorhanden.'),
          ),
        ),
      );
      expect(find.text('Keine Gerichte vorhanden.'), findsOneWidget);
    });

    testWidgets('zeigt optionalen Action-Button', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'Leer',
              onAction: () => tapped = true,
              actionLabel: 'Filter zurücksetzen',
            ),
          ),
        ),
      );

      expect(find.text('Filter zurücksetzen'), findsOneWidget);
      await tester.tap(find.text('Filter zurücksetzen'));
      expect(tapped, isTrue);
    });
  });
}
