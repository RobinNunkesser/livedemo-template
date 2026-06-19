# CampusFlow – Sprint 1

Flutter-App für Campus-Informationen: Mensaplan, Stundenplan, Übungsaufgaben, Dozentenliste.

## Sprint 1 Status

| Story | Beschreibung | Status |
|-------|-------------|--------|
| SP1-01 | Projektstruktur (Features, Shared, Data, Domain) | ✅ |
| SP1-02 | Riverpod State Management | ✅ |
| SP1-03 | Shared Error/Loading/Empty Widgets | ✅ |
| SP1-04 | Bottom Navigation mit 4 Tabs + Platzhalter-Screens | ✅ |
| SP1-05 | Mensaplan – Live-API (OpenMensa, heute) | ✅ |
| SP1-06 | Mensaplan – Kategorie-Filter (lokal gespeichert) | ✅ |
| SP1-07 | Mensaplan – Allergen-Filter (14 EU-Hauptallergene) | ✅ |
| SP1-08 | Mensaplan – Fehler-/Leerzustände + Retry | ✅ |
| SP1-09 | CI mit GitHub Actions (Format, Lint, Test, Build) | ✅ |
| SP1-10 | Accessibility WCAG 2.1 AA (Semantik, Kontraste) | ✅ |

## Architektur

```
lib/
├── domain/          # Flutter-unabhängige Modelle & Filterlogik
│   ├── meal.dart
│   ├── mensa_day.dart
│   └── filter_settings.dart
├── data/            # Adapter (HTTP, Persistence)
│   ├── mensa_repository.dart    # Port (Interface)
│   ├── mensa_client.dart        # Adapter (HTTP)
│   └── filter_persistence.dart  # SharedPreferences
├── features/
│   ├── mensaplan/   # Vollständig implementiert
│   ├── stundenplan/ # Platzhalter (Sprint 2)
│   ├── dozentenliste/ # Platzhalter
│   └── uebungsaufgaben/ # Platzhalter
└── shared/widgets/  # LoadingState, ErrorState, EmptyState
```

**Schichtregel:** `UI → Application (Riverpod) → Data`. Kein direkter Infrastrukturzugriff aus UI oder Providern.

## API

- Basis-URL: `https://api.studentenwerk-dresden.de/openmensa/v2`
- Canteen ID: 6 (Studentenwerk Dresden)
- Timeout: 5s, Retry: 1x bei Timeout/Network/5xx, kein Retry bei 4xx

## Starten

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```
