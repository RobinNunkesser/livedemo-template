# CampusFlow

CampusFlow bündelt wichtige Campus-Informationen in einer Anwendung und erleichtert damit den Studienalltag auf Desktop und Mobilgeräten.

## Sprint 1 – Mensaplan

Der erste vertikale Slice mit Live-API-Anbindung (OpenMensa), Allergen-Filter und Fehler-/Leerzuständen.

### Features

- Mensaplan mit Live-Daten von OpenMensa API
- Kategorie-Filter (Fleisch, Fisch, Vegetarisch, Vegan)
- Allergen-Filter (14 EU-Hauptallergene)
- Fehler- und Leerzustände mit Retry
- Filter-Persistierung (lokal)
- Platzhalter-Screens für Stundenplan, Dozentenliste, Übungsaufgaben

### Architektur

- **3-Layer**: UI (Screens/Widgets) → Application (Providers/State) → Data (Repositories/HTTP)
- **State Management**: Riverpod
- **Repository Pattern**: Abstraktion von Datenzugriffen
- **Datenquellen**: OpenMensa-API (remote), lokale JSON (später)
