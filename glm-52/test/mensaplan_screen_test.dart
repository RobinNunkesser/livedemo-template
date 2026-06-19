import 'package:campusflow/data/mensa_repository.dart';
import 'package:campusflow/domain/meal.dart';
import 'package:campusflow/domain/mensa_day.dart';
import 'package:campusflow/features/mensaplan/providers.dart';
import 'package:campusflow/features/mensaplan/mensaplan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRepository implements MensaRepository {
  _StubRepository(this._state);
  final MensaState _state;

  @override
  Future<MensaDay> getDay(String date) async {
    switch (_state) {
      case MensaLoading():
        throw MensaRepositoryException(MensaErrorKind.unknown, 'loading');
      case MensaData(:final day):
        return day;
      case MensaError():
        throw MensaRepositoryException(MensaErrorKind.network, 'net');
      case MensaClosed():
        return MensaDay(date: date, status: DayStatus.closed);
      case MensaEmpty():
        return MensaDay(date: date, status: DayStatus.open, meals: const []);
    }
  }
}

void main() {
  testWidgets('Fehlerzustand zeigt Neu-laden-Button (A8)', (tester) async {
    final container = ProviderContainer(overrides: [
      mensaProvider.overrideWith(
        (ref) =>
            MensaNotifier(_StubRepository(const MensaError('fail')))..load(),
      ),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MensaplanScreen()),
    ));
    await tester.pump();

    // Nach dem asynchronen load() ist der Fehler sichtbar.
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Neu laden'), findsOneWidget);

    container.dispose();
  });

  testWidgets('Geschlossen-Zustand zeigt Hinweis (A7)', (tester) async {
    final container = ProviderContainer(overrides: [
      mensaProvider.overrideWith(
        (ref) => MensaNotifier(_StubRepository(const MensaClosed()))..load(),
      ),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MensaplanScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Mensa heute geschlossen'), findsOneWidget);
    container.dispose();
  });

  testWidgets('Leerzustand zeigt Hinweis', (tester) async {
    final container = ProviderContainer(overrides: [
      mensaProvider.overrideWith(
        (ref) => MensaNotifier(_StubRepository(const MensaEmpty()))..load(),
      ),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MensaplanScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Kein Angebot heute'), findsOneWidget);
    container.dispose();
  });

  testWidgets('Datenzustand zeigt Gericht an (A1, A2)', (tester) async {
    final day = MensaDay(
      date: '2026-06-19',
      status: DayStatus.open,
      meals: [
        Meal(
          id: 1,
          name: 'Testcurry',
          category: 'Angebot 1',
          priceStudent: 3.5,
        ),
      ],
    );
    final container = ProviderContainer(overrides: [
      mensaProvider.overrideWith(
        (ref) => MensaNotifier(_StubRepository(MensaData(day)))..load(),
      ),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MensaplanScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Testcurry'), findsOneWidget);
    expect(find.text('€3,50'), findsOneWidget);
    container.dispose();
  });
}
