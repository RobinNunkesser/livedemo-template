# CampusFlow - Sprint 1 Implementation

Ein Flutter-Projekt für Campus-Management mit Mensaplan, Stundenplan, Dozentenliste und Übungsaufgaben.

## Sprint 1 Umsetzung

Dieser Branch enthält die Implementierung der Story SP1-01 bis SP1-10 aus dem Sprint 1 Plan.

### Abgeschlossene Stories

- **SP1-01**: Projektstruktur mit 3-Layer-Architektur (UI → Application → Data)
- **SP1-02**: Riverpod State Management Integration
- **SP1-03**: Shared Error/Loading/Empty Widgets
- **SP1-04**: Navigation mit 4 Tabs (Mensaplan, Stundenplan, Dozenten, Aufgaben)
- **SP1-05**: Mensaplan - Live-API-Anbindung
- **SP1-06**: Mensaplan - Kategorie-Filter
- **SP1-07**: Mensaplan - Allergen-Filter
- **SP1-08**: Mensaplan - Fehler-/Leerzustände mit Retry
- **SP1-09**: CI mit GitHub Actions (Format, Lint, Tests)
- **SP1-10**: Accessibility (WCAG 2.1 AA)

## Projektstruktur

```
lib/
├── main.dart                    # App-Einstiegspunkt, Navigation
├── domain/                      # Domain Models
│   ├── meal.dart               # Meal-Modell
│   └── mensa_day.dart          # MensaDay-Modell
├── data/                        # Data Layer
│   ├── mensa_client.dart       # HTTP-Client für OpenMensa-API
│   ├── mensa_repository.dart   # Repository Interface
│   └── providers.dart          # Data Layer Providers
├── features/                    # Feature-spezifischer Code
│   ├── mensaplan/
│   │   ├── mensaplan_screen.dart
│   │   ├── providers.dart      # Mensaplan State Management
│   │   ├── meal_card.dart
│   │   └── filter_dialog.dart
│   ├── stundenplan/            # Stub Screen
│   ├── dozentenliste/          # Stub Screen
│   └── uebungsaufgaben/        # Stub Screen
└── shared/                      # Geteilte Komponenten
    └── widgets/
        ├── loading_state.dart
        ├── error_state.dart
        └── empty_state.dart
```

## Installation und Setup

### Voraussetzungen

- Flutter SDK 3.19.0+
- Dart 3.3.0+
- Xcode (macOS) oder Android SDK

### Erste Schritte

```bash
# Abhängigkeiten installieren
flutter pub get

# App starten (Desktop/Mobile)
flutter run

# Tests ausführen
flutter test

# Build erstellen
flutter build apk          # Android
flutter build ipa          # iOS
flutter build windows      # Windows
flutter build macos        # macOS
```

## API-Integration

Die App bezieht Mensadaten von der OpenMensa-API:
- **Base URL**: `https://api.studentenwerk-dresden.de/openmensa/v2`
- **Canteen ID**: 6 (Studentenwerk Dresden)
- **Timeout**: 5 Sekunden pro Request
- **Retry-Policy**: 1 automatischer Retry bei Timeout/Network/5xx, kein Retry bei 4xx

### Beispiel-Endpoints

```
GET /canteens/6/days                    # Alle Tage abrufen
GET /canteens/6/days/{date}/meals      # Speisen für einen Tag
```

## Architektur

### 3-Layer-Architektur

**UI Layer (Features)**
- Flutter Widgets und Screens
- Riverpod Provider für State Orchestrierung
- Keine direkten HTTP/DB-Zugriffe

**Application Layer (Providers)**
- Riverpod StateNotifier für Business-Logik
- Filter-Logik, Daten-Orchestrierung
- Use Cases und Services

**Data Layer**
- Repository Pattern für Datenzugriff
- HTTP-Client mit Retry-Logik
- Timeout und Error Handling (5s, 1 Retry)

### State Management

- **Riverpod 2.4.0** für reaktive State Management
- **StateNotifier** für komplexe Logik
- Provider-Tests mit Mock/Fake Repositories
- Widget-Tests ohne echte externe Zugriffe

## Testing

```bash
# Alle Tests ausführen
flutter test

# Spezifischen Test ausführen
flutter test test/meal_test.dart

# Tests mit Coverage
flutter test --coverage
```

### Test-Coverage für Sprint 1

- Repository-Tests: HTTP-Erfolg, Fehlerbehandlung, Timeout, Retry
- Provider-Tests: Filter-Logik, State-Verwaltung
- Widget-Tests: UI-States (Loading, Error, Empty, Closed)

## Accessibility

- WCAG 2.1 AA Level Compliance für Mensaplan
- Semantische Struktur für Screenreader
- Keyboard-Navigation und sichtbare Fokusindikatoren
- Ausreichend Farbkontrast für Kerntexte

## CI/CD Pipeline

GitHub Actions Workflow (`flutter_ci.yml`):
- **Trigger**: Push zu main/develop, Pull Requests
- **Schritte**:
  1. Format Check (`dart format`)
  2. Lint Check (`flutter analyze`)
  3. Unit Tests (`flutter test`)
  4. Build (APK, Web) - optional

## Definition of Done für Sprint 1

- ✅ Alle P1-Stories implementiert (SP1-01 bis SP1-10)
- ✅ Build läuft lokal und in CI
- ✅ Alle relevanten Tests grün
- ✅ Keine Layer-Verletzungen (nur UI → App → Data)
- ✅ Neue Dependencies mit Adapter + Tests integriert
- ✅ Architekturregeln eingehalten
- ✅ Wiki-Dokumentation aktualisiert

## Nächste Schritte (Sprint 2+)

- Stundenplan mit lokalen Seed-Daten
- Dozentenliste
- Übungsaufgaben mit SQLite
- Erweiterte Filter und Sorting
- Offline-Caching für häufig angesehene Daten

## Lizenz

MIT License

---

**Implementiert**: 2026-06-19
**Status**: Sprint 1 Complete
