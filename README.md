# Projektvorlage (GitHub Classroom)

Dieses Repository ist bereits als Projektvorlage vorbereitet.

## Was bereits eingerichtet ist

- Copilot- und Agent-Regeln unter `.github/`
- Projektsteuerung unter `agent-workbench/`
- Wiki-Vorlagen unter `wiki-templates/`

## Start für Studierende

1. Teamnamen und Projektthema im Repository festhalten.
2. `agent-workbench/projects/semesterprojekt/plan.md` ausfüllen.
3. Das GitHub Wiki initial befüllen:
   - Inhalt aus `wiki-templates/Home.md` auf die Wiki-Startseite übernehmen
   - Inhalt aus `wiki-templates/Projektbericht.md` als Projektbericht anlegen
   - optional: `wiki-templates/advanced/` für strukturierte Vorlagen (Projektvision, REQ, UC, ADR)
4. Ersten kleinen Implementierungs-Slice umsetzen.

## Erwarteter Workflow pro Iteration

1. Nächsten Task-Slice planen (`plan.md`).
2. Mit Copilot/Agenten umsetzen.
3. Verifizieren (Build/Test/Checks).
4. Ergebnisse im Wiki und in `review-notes.md` dokumentieren.

## Lokaler Workflow mit Code + Wiki in einem VS-Code-Workspace

Empfohlen ist ein lokaler Zwei-Ordner-Workflow (ohne Submodul):

```bash
bash tools/setup-local-wiki-workspace.sh
```

Unter Windows mit PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools/setup-local-wiki-workspace.ps1
```

Das Skript:

- klont das Wiki-Repo als Nachbarordner (z. B. `../<repo>-wiki`)
- erzeugt eine `.code-workspace`-Datei mit Code-Repo und Wiki-Repo
- erleichtert Agentenarbeit mit vollem Kontext auf Implementierung und Dokumentation

## KI-Einsatz

KI-Einsatz ist explizit erlaubt und gewünscht.

Voraussetzung:

- Ergebnisse fachlich prüfen
- KI-Beiträge kurz dokumentieren (Tool, Nutzung, Verifikation)

## Strukturüberblick

```text
.github/
agent-workbench/
wiki-templates/
```
