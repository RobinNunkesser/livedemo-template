import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campusflow/shared/widgets/loading_state.dart';
import 'package:campusflow/shared/widgets/error_state.dart';
import 'package:campusflow/shared/widgets/empty_state.dart';

void main() {
  group('LoadingState', () {
    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingState())),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingState(message: 'Lädt …')),
        ),
      );
      expect(find.text('Lädt …'), findsOneWidget);
    });
  });

  group('ErrorState', () {
    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(message: 'Ein Fehler ist aufgetreten.'),
          ),
        ),
      );
      expect(find.text('Ein Fehler ist aufgetreten.'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(message: 'Fehler', onRetry: () => retried = true),
          ),
        ),
      );
      expect(find.text('Neu laden'), findsOneWidget);
      await tester.tap(find.text('Neu laden'));
      expect(retried, isTrue);
    });

    testWidgets('does not show retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorState(message: 'Fehler')),
        ),
      );
      expect(find.text('Neu laden'), findsNothing);
    });
  });

  group('EmptyState', () {
    testWidgets('shows empty state message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyState(message: 'Keine Daten verfügbar.')),
        ),
      );
      expect(find.text('Keine Daten verfügbar.'), findsOneWidget);
    });
  });
}
