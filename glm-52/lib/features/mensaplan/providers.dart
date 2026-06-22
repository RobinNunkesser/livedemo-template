/// Riverpod-Provider für das Mensaplan-Feature (Application-Schicht).
///
/// Orchestriert Laden, Filtern und Persistieren – enthält selbst keine
/// Infrastruktur-Logik (ADR-004 / WayOfWorking).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/mensa_repository.dart';
import '../../data/providers.dart';
import '../../domain/meal.dart';
import '../../domain/mensa_day.dart';
import 'filter_state.dart';

/// SharedPreferences-Provider.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

/// Filter-Storage-Provider (Port), Adapter auf SharedPreferences.
final filterStorageProvider = FutureProvider<FilterStorage>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SharedPreferencesFilterStorage(prefs);
});

/// Verwaltet den aktiven Filter-Zustand und persistiert Änderungen (A14).
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier(this._storage) : super(const FilterState()) {
    _initFuture = _loadInitial();
  }

  final FilterStorage _storage;
  late final Future<void> _initFuture;

  Future<void> _loadInitial() async {
    state = await _storage.load();
  }

  /// Stellt sicher, dass das initiale Laden abgeschlossen ist, bevor
  /// explizite Änderungen den Zustand überschreiben (Race Condition).
  Future<void> _ensureInitialized() => _initFuture;

  Future<void> setAllergens(Set<String> codes) async {
    await _ensureInitialized();
    state = state.copyWith(hiddenAllergens: codes);
    await _storage.save(state);
  }

  Future<void> setCategories(Set<String> codes) async {
    await _ensureInitialized();
    state = state.copyWith(selectedCategories: codes);
    await _storage.save(state);
  }

  Future<void> reset() async {
    await _ensureInitialized();
    state = const FilterState();
    await _storage.save(state);
  }
}

/// Aktiver Filter (A14: lokal gespeichert, A15: automatisch angewendet).
final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  final storage = ref.watch(filterStorageProvider).maybeWhen(
        data: (s) => s,
        orElse: _InMemoryStorage.new,
      );
  return FilterNotifier(storage);
});

// Fallback-Storage, falls SharedPreferences noch nicht geladen ist.
class _InMemoryStorage implements FilterStorage {
  FilterState _state = const FilterState();
  @override
  Future<FilterState> load() async => _state;
  @override
  Future<void> save(FilterState s) async {
    _state = s;
  }
}

/// Zustand des Mensa-Ladevorgangs.
sealed class MensaState {
  const MensaState();
}

class MensaLoading extends MensaState {
  const MensaLoading();
}

class MensaData extends MensaState {
  const MensaData(this.day);
  final MensaDay day;
}

class MensaError extends MensaState {
  const MensaError(this.message);
  final String message;
}

class MensaClosed extends MensaState {
  const MensaClosed();
}

class MensaEmpty extends MensaState {
  const MensaEmpty();
}

/// Lädt den Mensa-Tag für heute und wendet den aktiven Filter an.
class MensaNotifier extends StateNotifier<MensaState> {
  MensaNotifier(this._repository) : super(const MensaLoading());

  final MensaRepository _repository;

  String _today() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}';
  }

  Future<void> load() async {
    state = const MensaLoading();
    try {
      final day = await _repository.getDay(_today());
      if (day.status == DayStatus.closed) {
        state = const MensaClosed();
      } else if (day.meals.isEmpty) {
        state = const MensaEmpty();
      } else {
        state = MensaData(day);
      }
    } on MensaRepositoryException catch (e) {
      state = MensaError(_friendlyMessage(e));
    }
  }

  String _friendlyMessage(MensaRepositoryException e) {
    switch (e.kind) {
      case MensaErrorKind.timeout:
      case MensaErrorKind.network:
        return 'Die Mensadaten konnten nicht geladen werden '
            '(Netzwerk/Timeout). Bitte später erneut versuchen.';
      case MensaErrorKind.http:
        return 'Die Mensadaten sind aktuell nicht erreichbar '
            '(HTTP ${e.statusCode ?? '?'}). Bitte später erneut versuchen.';
      case MensaErrorKind.parse:
        return 'Die Mensadaten konnten nicht gelesen werden.';
      case MensaErrorKind.unknown:
        return 'Ein unerwarteter Fehler ist aufgetreten.';
    }
  }
}

/// Gefilterte Gericht-Liste (A12: kombiniert Allergen + Kategorie via AND).
final filteredMealsProvider = Provider<List<Meal>>((ref) {
  final mensaState = ref.watch(mensaProvider);
  final filter = ref.watch(filterProvider);

  if (mensaState is! MensaData) return const [];

  var meals = mensaState.day.meals;

  // Allergen-Filter: exklusiv (Gerichte mit gewählten Allergenen ausblenden).
  if (filter.hiddenAllergens.isNotEmpty) {
    meals = meals
        .where((m) => !m.containsAnyAllergen(filter.hiddenAllergens))
        .toList();
  }

  // Kategorie-Filter: inklusiv auf gewählten Kategorien.
  if (filter.selectedCategories.isNotEmpty) {
    meals = meals
        .where((m) => filter.selectedCategories.contains(m.foodCategory.name))
        .toList();
  }

  return meals;
});

final mensaProvider = StateNotifierProvider<MensaNotifier, MensaState>((ref) {
  final repo = ref.watch(mensaRepositoryProvider);
  return MensaNotifier(repo);
});
