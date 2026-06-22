# Grobe Bewertung der Implementierungen in `livedemo-template`

Datum: 2026-06-19

Hinweis: Dies ist eine oberflächliche, codefreie Einschätzung basierend auf vorhandener Projektstruktur, README-Dateien, Tests und vorhandenen Adapter-/Domain-Dateien. Es wurden keine Codeänderungen vorgenommen.

Übersicht der geprüften Subprojekte
- `bigpickle`
- `claude-haiku-45`
- `gemini-35-flash`
- `glm-52`
- `kiro/campusflow`
- `openai-gpt-5-mini`
- `swe-16/campusflow`

Bewertungsschlüssel
- **Spezi­fikations­treue**: Wieweit erfüllt das Projekt die Wiki-/TechDesign-Anforderungen (Mensaplan-Flow, Allergen-Parsing, Preise, Fehlerzustände).
- **Qualität**: Struktur, Tests, README/Docs, CI, Plattformunterstützung, Accessibility-Hinweise.
- **Status**: `Complete` | `Partial` | `Scaffold` (nur Gerüst)
- **Empfehlung**: Nächste sinnvolle Schritte.


---

## bigpickle
- Spezifikationstreue: Partial — `README.md` beschreibt Sprint‑1-Funktionen inkl. Mensaplan und Filtern. Projekt enthält `lib/` und `test/`, aber bei oberflächlicher Suche keine klar benannte `mensa_*`-Adapterdatei sichtbar. Möglicherweise ist die Implementierung vorhanden, aber nicht eindeutig benannt.
- Qualität: Gut dokumentiertes README; Projektstruktur vorhanden. Unklar: Testabdeckung und Mapping-Regeln (Preis-Key-Mapping, Allergen-Parsing) — müssen geprüft werden.
- Status: Partial
- Empfehlung: 1) Schnelltesten: `flutter test` ausführen, 2) Prüfen, ob ein `MensaRepository`/Adapter existiert und ob Price-/Allergen-Mapping die reale API berücksichtigt (deutsche Keys `Studierende` etc.). 3) Falls Lücken: Ergänzen von Parser-Tests.

---

## claude-haiku-45
- Spezifikationstreue: High (laut README enthält Mensaplan-Adapter). In der Codebasis finden sich `mensa_client.dart`-Implementierungen (Adapter), plus README mit klarer Sprint‑1-Abdeckung.
- Qualität: Umfangreiche README, Tests vorhanden (Ordner `test/`), Desktop-Targets (`macos/`) vorhanden. Lokal wurde `.gitignore` angepasst und ein Commit existiert — Remote-Push fehlt vermutlich.
- Status: Complete (auf Basis der vorliegenden Artefakte)
- Empfehlung: 1) CI / Tests laufen lassen (`flutter test`) und Test-Resultate prüfen; 2) Parser-Fallbacks für `prices` und `notes` prüfen; 3) Remote-Push für dieses Subrepo konfigurieren (falls nötig).

---

## gemini-35-flash
- Spezifikationstreue: Scaffold — `README.md` ist generisch (Flutter-Starter). Keine Hinweise auf spezifische Mensa‑Adapter oder Tests.
- Qualität: Projekt ist ein Boilerplate; fehlt Feature-spezifische Implementierung.
- Status: Scaffold
- Empfehlung: Entscheiden, ob dieses Repo als Implementierungsbasis weitergeführt oder archiviert werden soll. Wenn weiter, Task: Mensa-Adapter + Domain-Modelle hinzufügen.

---

## glm-52
- Spezifikationstreue: High — explizite Mensa‑Adapter `mensa_api_client.dart`, Domain-Modelle (`meal.dart`, `mensa_day.dart`) und Tests (`mensa_api_client_test.dart`, `mensa_providers_test.dart`, `mensaplan_screen_test.dart`) vorhanden. README dokumentiert Abweichungen zur realen API und wie sie gelöst wurden (Preis-Keys, Kategorie-Mapping, Allergen-Codes, Image-URLs).
- Qualität: Sehr gut — klare Layer-Trennung, Tests, CI-Intent, Accessibility‑Hinweise, Desktop‑Support erwähnt. Mapping‑Regeln and Parser‑Strategien bereits dokumentiert.
- Status: Complete
- Empfehlung: 1) Test-Run / Coverage prüfen; 2) ggf. Parser‑Edgecases (notes mit gemischten Texten) mit zusätzlichen Unit‑Tests absichern; 3) Release- / Deployment-Anweisungen ergänzen.

---

## kiro/campusflow
- Spezifikationstreue: High — README zeigt vollständige Mensaplan‑Implementierung, strukturierte `lib/` mit `mensa_client.dart` und `mensa_repository.dart` laut Projektstruktur. Zielplattformen und Tests sind vorhanden.
- Qualität: Gut dokumentiert; Schichttrennung vorhanden; Desktop-Targets in repo-Struktur. Detaillierter Test-Status muss durch Testausführung verifiziert werden.
- Status: Complete
- Empfehlung: 1) Tests ausführen; 2) Code-Review des Adapters bzgl. Allergen-/Price‑Mapping; 3) Sicherstellen, dass protocol-relative `image`-URLs normalisiert werden.

---

## openai-gpt-5-mini
- Spezifikationstreue: Scaffold — README beschreibt ein MVP‑Scaffold mit Beispiel‑Adapter und Basis‑Widgets. Echte Implementierung ist begrenzt; dient vor allem als Startpunkt.
- Qualität: Sauberer Scaffold; keine großen Feature‑Implementierungen sichtbar.
- Status: Scaffold
- Empfehlung: Use as template; implement Mensa‑Adapter und Domain‑Modelle oder re‑use impl. aus `glm-52`/`kiro`.

---

## swe-16/campusflow
- Spezifikationstreue: Scaffold — Standard Flutter-Starter README, keine Mensa-spezifischen Artefakte sichtbar.
- Qualität: Boilerplate; ohne spezifische Implementierung.
- Status: Scaffold
- Empfehlung: Wie bei `gemini-35-flash` und `openai-gpt-5-mini`: entweder aufhübschen und an Sprint‑1‑Implementierung anbinden oder als Template archivieren.

---

## Übergreifende Befunde & Empfehlungen

- **Beste Umsetzungen:** `glm-52`, `kiro` und `claude-haiku-45` zeigen die höchste Spezifikations‑ und Qualitätsnähe (Domain-Modelle, Adapter, Tests, README). Diese Codebasen sind Kandidaten für ein „Referenz‑Repository“.
- **Scaffolds:** `gemini-35-flash`, `openai-gpt-5-mini`, `swe-16` sind Boilerplates / Templates — nützlich als Startpunkte, aber nicht produktionsreif.
- **Mensa‑Parser‑Härtung:** Überall, wo ein Adapter existiert, sollten Parser-Edgecases (deutsche Preis-Keys, protocol-relative Images, `notes` mit gemischten Infos) durch Unit-Tests abgesichert werden. `TechDesign-Mensaplan.md` enthält bereits konkrete Regeln — diese sollten als Tests festgeschrieben werden.
- **Theme & Desktop:** Light/Dark-Mode-Richtlinien wurden in der Wiki ergänzt; mehrere Implementierungen enthalten `macos/` und `windows/` Ordner — testen sie auf Desktop-Responsiveness.
- **CI & Tests:** README-Dateien behaupten CI/Tests; bitte `flutter test` in den entsprechenden Subprojekten laufen lassen und Fehlermeldungen beheben.
- **Repository-Konsistenz:** Einige Subrepos (z. B. `claude-haiku-45`) haben lokale Commits ohne Remote-Push — wenn ein zentrales GitHub‑Hosting gewünscht ist, Remotes einrichten und Pushs koordinieren.

---

Wenn du möchtest, kann ich als nächsten Schritt pro `Complete`-Repo die Test-Suites ausführen (`flutter test`) und die Ergebnisse hier zusammenfassen (danach ggf. gezielte Listen mit fehlenden Tests/Fehlern erstellen). Oder ich kann konkrete Parser‑Unit‑Tests generieren (in separatem Commit), falls du das wünschst. Bitte gib an, was ich als Nächstes tun soll. 
