# CampusFlow – Sprint 1 (GLM-5.2)

Vertikaler MVP-Slice des Mensaplans für die CampusFlow-App.
Implementiert nach Wiki-Spezifikation `livedemo-template-wiki/`.

## Sprint-Commit (SP1-01 bis SP1-10)

| Story | Beschreibung | Status |
|---|---|---|
| SP1-01 | 3-Layer-Architektur (`lib/{domain,data,features,shared}`) | ✅ |
| SP1-02 | Riverpod State Management (StateNotifier + Provider) | ✅ |
| SP1-03 | Shared Widgets: `LoadingState`, `ErrorState`, `EmptyState` | ✅ |
| SP1-04 | Bottom-Navigation mit 4 Tabs + 3 Platzhalter-Screens | ✅ |
| SP1-05 | Mensaplan – Live-API (OpenMensa, Canteen 6) | ✅ |
| SP1-06 | Kategorie-Filter (Fleisch/Fisch/Vegetarisch/Vegan) | ✅ |
| SP1-07 | Allergen-Filter (14 EU-Allergene + Zusatzstoffe) | ✅ |
| SP1-08 | Fehler-/Leer-/Geschlossen-Zustände mit Retry | ✅ |
| SP1-09 | CI mit GitHub Actions (format, analyze, test, build) | ✅ |
| SP1-10 | Accessibility (Semantik, Labels, Kontrast) | ✅ |

## Architektur

```
lib/
├── main.dart                    # Einstieg + Bottom-Navigation
├── domain/                      # Fachliche Modelle (flutterfrei)
│   ├── allergens.dart           # 14 EU-Allergene + Codes (A4/A5)
│   ├── meal.dart                # Meal + FoodCategory
│   └── mensa_day.dart           # MensaDay + DayStatus
├── data/                        # Data-Schicht (Adapter)
│   ├── mensa_repository.dart    # Port (Interface) + Exception
│   ├── mensa_api_client.dart    # HTTP-Adapter (OpenMensa)
│   └── providers.dart           # Repository-/HTTP-Provider
├── features/
│   └── mensaplan/
│       ├── filter_state.dart    # FilterState + SharedPreferences-Storage
│       ├── providers.dart       # Mensa-/Filter-Notifier (Application)
│       ├── meal_card.dart       # Gericht-Widget
│       ├── filter_dialog.dart   # Filter-UI (A4/A6/A13/A14/A16)
│       └── mensaplan_screen.dart
└── shared/
    └── widgets/
        ├── loading_state.dart
        ├── error_state.dart
        ├── empty_state.dart
        └── placeholder_screen.dart
```

**Schichtregel (C4-Sicht / ADR-004):** nur `UI → Application → Data`.
Provider enthalten keine Infrastruktur-Logik; Datenzugriff läuft über das
Repository-Interface (`MensaRepository`).

## API-Integration (Tech-Design Mensaplan)

- Basis-URL: `https://api.studentenwerk-dresden.de/openmensa/v2`
- Canteen ID: `6`
- Endpoint-Reihenfolge: `/days` → `closed`-Check → `/days/{today}/meals`
- Timeout: 5 s je Request
- Retry: genau 1× bei Timeout/Netzwerk/5xx, kein Retry bei 4xx
- Ungültige Datensätze werden verworfen (A9)

## Festgestellte Abweichungen vom Tech-Design (dokumentiert)

Bei der Prüfung gegen die **echte OpenMensa-API** zeigten sich diese
Abweichungen, die mit bewussten Entscheidungen gelöst wurden:

1. **Preisfelder:** Tech-Design nennt `students/employees/pupils/others`.
   Die reale API liefert **deutsch** `Studierende`/`Bedienstete`.
   → Parser akzeptiert beide (deutsch bevorzugt, englisch als Fallback).

2. **Kategorie-Mapping:** A16 fordert „Fleisch/Fisch/Vegetarisch/Vegan".
   Die API liefert Freitext (z. B. „Angebot 1").
   → `FoodCategory` wird aus `notes` abgeleitet
     („Menü ist vegan", „enthält …fleisch"/„Fisch").

3. **Allergen-Codes:** Tech-Design fordert die 14 EU-Allergene als lesbare
   Namen; die API liefert Codes in Klammern (z. B. „Sellerie (I)").
   → `AllergenCatalog` mappt A–N auf Klartexte, numerische Codes auf
     Zusatzstoffe; unbekannte Codes werden ignoriert.

4. **Bild-URL:** relativ mit `//` → wird zu `https:` normalisiert (A3).

## Tests

```
test/
├── meal_test.dart               # Unit: Meal, Allergens, FoodCategory
├── mensa_api_client_test.dart   # Repository: Erfolg/closed/5xx/4xx/Retry/Validierung
├── mensa_providers_test.dart    # Provider: Allergen-/Kategorie-/AND-Filter
└── mensaplan_screen_test.dart   # Widget: Fehler-/Leer-/Geschlossen-/Daten-Zustand
```

## Definition of Done (WayOfWorking)

- ✅ Läuft auf Desktop und Mobilgerät (Flutter, Material 3, responsive)
- ✅ Unit-Tests für wesentliche Logik vorhanden
- ✅ UI/Provider ohne direkte Infrastrukturzugriffe
- ✅ Datenzugriff über Repository-Interface
- ✅ Business-Regeln in Domain-Klassen (flutterfrei)

## Starten

```bash
cd livedemo-template/glm-52
flutter pub get
flutter run                 # App starten
flutter test                # Tests ausführen
flutter analyze             # Lint
dart format lib test        # Formatieren
```
