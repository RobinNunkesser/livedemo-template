import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/filter_persistence.dart';
import '../../data/mensa_client.dart';
import '../../data/mensa_repository.dart';
import '../../domain/filter_settings.dart';
import '../../domain/meal.dart';
import '../../domain/mensa_day.dart';

// ---------------------------------------------------------------------------
// Infrastruktur-Provider (Data Layer)
// ---------------------------------------------------------------------------

/// Stellt das MensaRepository bereit. In Tests via ProviderScope override
/// durch ein Fake-Repository ersetzbar (Dependency Injection).
final mensaRepositoryProvider = Provider<MensaRepository>((ref) {
  return MensaClient();
});

final filterPersistenceProvider = Provider<FilterPersistence>((ref) {
  return FilterPersistence();
});

// ---------------------------------------------------------------------------
// Today-Provider
// ---------------------------------------------------------------------------

/// Gibt das aktuelle Datum im Format yyyy-MM-dd zurück.
final todayProvider = Provider<String>((ref) {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
});

// ---------------------------------------------------------------------------
// Mensaplan State (sealed class hierarchy)
// ---------------------------------------------------------------------------

sealed class MensaState {}

class MensaLoading extends MensaState {}

class MensaClosed extends MensaState {}

class MensaLoaded extends MensaState {
  MensaLoaded(this.meals);
  final List<Meal> meals;
}

class MensaEmpty extends MensaState {}

class MensaError extends MensaState {
  MensaError(this.message);
  final String message;
}

// ---------------------------------------------------------------------------
// Mensaplan Notifier (Riverpod 3.x: Notifier)
// ---------------------------------------------------------------------------

/// Lädt den Mensaplan und verwaltet den Zustand.
/// Hält Dependency on MensaRepository (Port), nicht auf den HTTP-Client direkt.
class MensaNotifier extends Notifier<MensaState> {
  @override
  MensaState build() {
    // Startet sofort mit dem Laden
    Future.microtask(load);
    return MensaLoading();
  }

  /// Lädt den Mensaplan gemäß Endpoint-Reihenfolge aus TechDesign-Mensaplan.md:
  /// 1. GET /days → Tag mit heutigem Datum suchen
  /// 2. closed=true → MensaClosed
  /// 3. closed=false → GET /days/{today}/meals
  Future<void> load() async {
    state = MensaLoading();
    final repository = ref.read(mensaRepositoryProvider);
    final today = ref.read(todayProvider);

    try {
      final days = await repository.getDays();
      final todayEntry = _findToday(days, today);

      if (todayEntry == null) {
        state = MensaEmpty();
        return;
      }

      if (todayEntry.closed) {
        state = MensaClosed();
        return;
      }

      final meals = await repository.getMealsForDay(today);
      if (meals.isEmpty) {
        state = MensaEmpty();
      } else {
        state = MensaLoaded(meals);
      }
    } on MensaException catch (e) {
      state = MensaError(_userFriendlyError(e));
    } catch (_) {
      state = MensaError('Mensaplan nicht verfügbar.\nBitte später versuchen.');
    }
  }

  MensaDay? _findToday(List<MensaDay> days, String today) {
    try {
      return days.firstWhere((d) => d.date == today);
    } catch (_) {
      return null;
    }
  }

  String _userFriendlyError(MensaException e) {
    return switch (e.kind) {
      MensaErrorKind.timeout =>
        'Verbindung zu langsam. Bitte Internetverbindung prüfen.',
      MensaErrorKind.network =>
        'Keine Internetverbindung. Bitte prüfen und neu laden.',
      MensaErrorKind.http =>
        'Mensaplan nicht verfügbar (Fehler ${e.statusCode ?? ''}).\nBitte später versuchen.',
      MensaErrorKind.parse =>
        'Mensadaten konnten nicht gelesen werden.\nBitte später versuchen.',
    };
  }
}

final mensaNotifierProvider =
    NotifierProvider<MensaNotifier, MensaState>(MensaNotifier.new);

// ---------------------------------------------------------------------------
// Filter Notifier (Riverpod 3.x: Notifier)
// ---------------------------------------------------------------------------

/// Verwaltet aktive Filter und persistiert sie lokal.
class FilterNotifier extends Notifier<FilterSettings> {
  @override
  FilterSettings build() {
    // Lädt gespeicherte Filter asynchron nach
    Future.microtask(_loadSaved);
    return const FilterSettings();
  }

  Future<void> _loadSaved() async {
    final persistence = ref.read(filterPersistenceProvider);
    final saved = await persistence.load();
    state = saved;
  }

  void toggleAllergen(String allergen) {
    final current = Set<String>.from(state.selectedAllergens);
    if (current.contains(allergen)) {
      current.remove(allergen);
    } else {
      current.add(allergen);
    }
    state = state.copyWith(selectedAllergens: current);
    ref.read(filterPersistenceProvider).save(state);
  }

  void toggleCategory(String category) {
    final current = Set<String>.from(state.selectedCategories);
    if (current.contains(category)) {
      current.remove(category);
    } else {
      current.add(category);
    }
    state = state.copyWith(selectedCategories: current);
    ref.read(filterPersistenceProvider).save(state);
  }

  void clearAll() {
    state = const FilterSettings(
      selectedAllergens: {},
      selectedCategories: {},
    );
    ref.read(filterPersistenceProvider).clear();
  }
}

final filterNotifierProvider =
    NotifierProvider<FilterNotifier, FilterSettings>(FilterNotifier.new);

// ---------------------------------------------------------------------------
// Gefilterte Mahlzeiten (Use-Case-Logik in Domain-Schicht)
// ---------------------------------------------------------------------------

/// Wendet Allergen- und Kategorie-Filter mit AND-Logik an.
/// Allergen-Filter: exklusiv (Mahlzeiten mit gewählten Allergenen ausblenden)
/// Kategorie-Filter: inklusiv (nur gewählte Kategorien anzeigen)
List<Meal> applyFilters(List<Meal> meals, FilterSettings filters) {
  return meals.where((meal) {
    // Allergen-Filter: Mahlzeit ausblenden, wenn sie ein gewähltes Allergen hat
    if (filters.selectedAllergens.isNotEmpty) {
      final hasBlockedAllergen =
          meal.allergens.any((a) => filters.selectedAllergens.contains(a));
      if (hasBlockedAllergen) return false;
    }

    // Kategorie-Filter: nur ausgewählte Kategorien anzeigen
    if (filters.selectedCategories.isNotEmpty) {
      if (!filters.selectedCategories.contains(meal.category)) return false;
    }

    return true;
  }).toList();
}

final filteredMealsProvider = Provider<List<Meal>>((ref) {
  final mensaState = ref.watch(mensaNotifierProvider);
  final filters = ref.watch(filterNotifierProvider);

  if (mensaState is MensaLoaded) {
    return applyFilters(mensaState.meals, filters);
  }
  return [];
});

/// Alle Kategorien aus den aktuell geladenen Mahlzeiten.
final availableCategoriesProvider = Provider<List<String>>((ref) {
  final mensaState = ref.watch(mensaNotifierProvider);
  if (mensaState is MensaLoaded) {
    return mensaState.meals.map((m) => m.category).toSet().toList()..sort();
  }
  return [];
});
