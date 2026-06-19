# Sprint 1 – Anforderungen

## Quelle

Vollständige Anforderungen in der Wiki-Spezifikation:
- [Sprint-1-Plan](../../../../../../livedemo-template-wiki/Sprint-1-Plan.md)
- [Feature: Mensaplan](../../../../../../livedemo-template-wiki/Feature-Mensaplan.md)
- [Tech-Design: Mensaplan](../../../../../../livedemo-template-wiki/TechDesign-Mensaplan.md)
- [ADR-004: Riverpod](../../../../../../livedemo-template-wiki/ADR-004-State-Management-Riverpod.md)

## Sprint Commit (P1)

| ID | Story | Status |
|----|-------|--------|
| SP1-01 | Projektstruktur (3-Layer: UI/Application/Data) | ✅ |
| SP1-02 | Riverpod State Management | ✅ |
| SP1-03 | Shared LoadingState / ErrorState / EmptyState | ✅ |
| SP1-04 | Bottom Navigation mit 4 Tabs + Platzhalter-Screens | ✅ |
| SP1-05 | Mensaplan – Live-API OpenMensa (Canteen ID 6) | ✅ |
| SP1-06 | Mensaplan – Kategorie-Filter lokal gespeichert | ✅ |
| SP1-07 | Mensaplan – 14 EU-Allergen-Filter lokal gespeichert | ✅ |
| SP1-08 | Mensaplan – Fehler-/Leerzustände + Retry | ✅ |
| SP1-09 | CI mit GitHub Actions (Format, Lint, Test, Build) | ✅ |
| SP1-10 | Accessibility WCAG 2.1 AA | ✅ |

## Kernregeln (aus ADR-004 + TechDesign)

1. Schichtregel: `UI → Application (Riverpod) → Data`. Keine Layer-Verletzungen.
2. Provider/Notifier enthalten keine Infrastruktur-Logik.
3. Datenzugriff nur über Repository-Interfaces (Ports).
4. Filterlogik (applyFilters) liegt in der Domain/Application-Schicht, nicht in Widgets.
5. API: 5s Timeout, 1 Retry bei Timeout/Network/5xx, kein Retry bei 4xx.
6. Ungültige Meals werden stillschweigend verworfen und geloggt.
