#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"
FORCE="${2:-}"

should_write() {
  local file="$1"
  if [[ -f "$file" && "$FORCE" != "--force" ]]; then
    echo "skip (exists): $file"
    return 1
  fi
  return 0
}

write_file() {
  local path="$1"
  local content="$2"

  mkdir -p "$(dirname "$path")"
  if should_write "$path"; then
    printf "%s" "$content" > "$path"
    echo "write: $path"
  fi
}

write_file "$TARGET_DIR/.github/copilot-instructions.md" '# Copilot Instructions for this Classroom Repository

## Purpose

Dieses Repository wird für ein studentisches Projekt verwendet:

- Dokumentation im GitHub Wiki
- Umsetzung im Code-Repository
- KI-gestützte Entwicklung mit GitHub Copilot/Agenten

## Working rules

1. Arbeite in kleinen, reviewbaren Schritten.
2. Begründe wichtige Architekturentscheidungen im Projektordner.
3. Verifiziere Änderungen (Build/Test/Checks), bevor du etwas als fertig markierst.
4. Keine Dependency-Upgrades, großen Refactorings oder Strukturwechsel ohne explizite Begründung.
5. KI-Einsatz ist erlaubt und gewünscht, Ergebnisse müssen aber fachlich geprüft werden.

## Structure expectations

- Wiki dokumentiert Problem, Entscheidungen, Fortschritt und Ergebnis.
- `agent-workbench/` hält Plan, offene Fragen, Entscheidungen und Reviews.
- Code-Änderungen bleiben mit Wiki und Projektplan konsistent.
'

write_file "$TARGET_DIR/.github/instructions/coding.instructions.md" '---
applyTo: "src/**,app/**,lib/**,tests/**,**/*.cs,**/*.ts,**/*.js,**/*.py,**/*.java"
description: "Code changes for student project implementation"
---

# Coding Instructions

- Implementiere nur, was im aktuellen Task-Slice steht.
- Ergänze Tests oder zumindest nachvollziehbare manuelle Prüfschritte.
- Halte Namen und Struktur konsistent.
- Erkläre komplexe Logik kurz im Code.
- Bei Unsicherheit: zuerst kleinste funktionierende Variante.
'

write_file "$TARGET_DIR/.github/instructions/docs.instructions.md" '---
applyTo: "README.md,wiki-templates/**,docs/**,**/*.md"
description: "Documentation and wiki-related instructions"
---

# Documentation Instructions

- Dokumentation muss kurz, konkret und überprüfbar sein.
- Entscheidungen und Trade-offs explizit machen.
- Bei KI-Einsatz immer kurz dokumentieren:
  - Tool
  - Wofür verwendet
  - Wie verifiziert
- Keine erfundenen Quellen, Zahlen oder Ergebnisse.
'

write_file "$TARGET_DIR/.github/prompts/start-task.prompt.md" '# Prompt — Start Task Slice

Kontext:
- Projektziel:
- Aktueller Stand:
- Nächster kleiner Task:

Bitte:
1. fasse den Task in 3-5 Punkten zusammen,
2. nenne Risiken/Annahmen,
3. implementiere den Task in kleinen Schritten,
4. verifiziere die Änderung,
5. gib eine kurze Review-Notiz für `agent-workbench/projects/semesterprojekt/review-notes.md`.
'

write_file "$TARGET_DIR/.github/prompts/review-change.prompt.md" '# Prompt — Review Change

Bitte überprüfe die letzte Änderung auf:

1. fachliche Korrektheit,
2. mögliche Regressionen,
3. fehlende Tests/Checks,
4. Inkonsistenzen mit Wiki- oder Projektdokumentation.

Gib das Ergebnis mit:
- Findings (priorisiert),
- offene Fragen,
- konkrete nächste Schritte.
'

write_file "$TARGET_DIR/.github/prompts/ui-screen-planning.prompt.md" '# Prompt — UI Screen Planning

Kontext:
- Projektziel:
- Zielgruppe:
- Use Case ID (z. B. UC03):
- Eingaben/Quellen (Wiki, Anforderungen, bestehende Screens):

Bitte liefere:
1. eine klare Screen-Definition (Zweck, Hauptaktion, Erfolgskriterium),
2. Informationsstruktur (Bereiche, Reihenfolge, Priorität),
3. UI-Zustände (Initial, Loading, Empty, Error, Success),
4. Navigation (Einstieg, Folgeschritte, Back-Navigation),
5. Akzeptanzkriterien als prüfbare Bulletpoints,
6. einen Mermaid-Flow (User-Flow) für die Wiki-Dokumentation.

Ausgabeformat:
- kurz und umsetzungsnah,
- so formuliert, dass es direkt in `SCRxx-*.md` und `UCxx-*.md` übernommen werden kann.
'

write_file "$TARGET_DIR/.github/prompts/ui-components-state.prompt.md" '# Prompt — UI Components and State

Kontext:
- Screen/Feature:
- Zielplattform:
- Bestehende Komponenten:
- Qualitätsanforderungen (z. B. Barrierefreiheit, Performance):

Bitte liefere:
1. Komponentenbaum (Container, Komponenten, Subkomponenten),
2. pro Komponente Zustände und Varianten,
3. benötigte Props/Parameter und Events,
4. Validierungs- und Fehlermeldungslogik,
5. Wiederverwendungspotenzial (was gehört in shared/ui?),
6. konkrete Testfälle (Unit/UI) pro kritischem Zustand.

Optional:
- Mermaid State Diagram für zentrale Zustandsübergänge.

Ausgabeformat:
- tabellarisch oder als klare Bullets,
- direkt nutzbar für Implementierung und Testplanung.
'

write_file "$TARGET_DIR/agent-workbench/playbooks/classroom-project-playbook.md" '# Playbook — Classroom Projektworkflow

## Iterationszyklus

1. Problem und Ziel im Wiki konkretisieren.
2. Nächsten kleinen Task in `plan.md` festlegen.
3. Umsetzung mit Copilot/Agent.
4. Verifikation (Build/Test/Manual Check).
5. Erkenntnisse in `review-notes.md` dokumentieren.
6. Wiki aktualisieren.

## Done-Kriterien je Slice

- Code funktioniert nachweisbar.
- Änderungen sind dokumentiert.
- Offene Risiken sind benannt.
'

write_file "$TARGET_DIR/agent-workbench/prompts/recurring/iteration-check.prompt.md" '# Prompt — Iteration Check

Analysiere den aktuellen Stand des Repositories:

1. Was wurde seit der letzten Iteration erreicht?
2. Welche Risiken sind offen?
3. Was ist der kleinste nächste sinnvolle Task?
4. Welche Verifikation fehlt noch?

Aktualisiere danach:
- `agent-workbench/projects/semesterprojekt/plan.md`
- `agent-workbench/projects/semesterprojekt/next-session-checklist.md`
'

write_file "$TARGET_DIR/agent-workbench/projects/semesterprojekt/plan.md" '# Plan — Semesterprojekt

## Ziel

Kurze Beschreibung des Projektziels.

## Scope

- In Scope:
- Out of Scope:

## Nächste Slices

1. Slice 1:
2. Slice 2:
3. Slice 3:
'

write_file "$TARGET_DIR/agent-workbench/projects/semesterprojekt/open-questions.md" '# Open Questions

- Frage 1
- Frage 2
- Frage 3
'

write_file "$TARGET_DIR/agent-workbench/projects/semesterprojekt/decisions.md" '# Decisions

## Entscheidung 1

- Kontext:
- Entscheidung:
- Begründung:
'

write_file "$TARGET_DIR/agent-workbench/projects/semesterprojekt/review-notes.md" '# Review Notes

## Iteration YYYY-MM-DD

- Umsetzung:
- Verifikation:
- Risiken:
- Nächster Schritt:
'

write_file "$TARGET_DIR/agent-workbench/projects/semesterprojekt/next-session-checklist.md" '# Next Session Checklist

- [ ] Task-Slice auswählen
- [ ] Umsetzung durchführen
- [ ] Verifikation dokumentieren
- [ ] Wiki aktualisieren
'

write_file "$TARGET_DIR/wiki-templates/Home.md" '# Projekt-Wiki

## Ziel

Was soll das Projekt lösen?

## Team

- Name 1
- Name 2

## Aktueller Stand

- Stand:
- Nächster Meilenstein:

## Links

- Repository:
- Board/Issues:
- Demo:
'

write_file "$TARGET_DIR/wiki-templates/Projektbericht.md" '# Projektbericht

## Problemstellung

## Zielsetzung

## Lösungsansatz

## Architektur / Designentscheidungen

## Umsetzung

## Verifikation (Tests/Checks)

## KI-Einsatz

- Tool:
- Unterstützte Aufgaben:
- Wie wurde verifiziert?

## Lessons Learned
'

write_file "$TARGET_DIR/tools/setup-local-wiki-workspace.sh" '#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

ORIGIN_URL="${1:-$(git remote get-url origin 2>/dev/null || true)}"

if [[ -z "$ORIGIN_URL" ]]; then
  echo "Fehler: Konnte origin URL nicht ermitteln. Bitte URL als 1. Argument uebergeben."
  exit 1
fi

if [[ "$ORIGIN_URL" == *.wiki.git ]]; then
  WIKI_URL="$ORIGIN_URL"
elif [[ "$ORIGIN_URL" == *.git ]]; then
  WIKI_URL="${ORIGIN_URL%.git}.wiki.git"
else
  WIKI_URL="${ORIGIN_URL}.wiki.git"
fi

REPO_NAME="$(basename "$ORIGIN_URL")"
REPO_NAME="${REPO_NAME%.git}"
REPO_NAME="${REPO_NAME%.wiki}"

DEFAULT_WIKI_DIR="../${REPO_NAME}-wiki"
WIKI_DIR="${2:-$DEFAULT_WIKI_DIR}"

if [[ -d "$WIKI_DIR/.git" ]]; then
  echo "Wiki-Repo existiert bereits: $WIKI_DIR"
else
  git clone "$WIKI_URL" "$WIKI_DIR"
fi

WORKSPACE_FILE="${REPO_ROOT}/${REPO_NAME}-with-wiki.code-workspace"

cat > "$WORKSPACE_FILE" <<EOF
{
  "folders": [
    { "path": "$REPO_ROOT" },
    { "path": "$WIKI_DIR" }
  ],
  "settings": {}
}
EOF

echo "Fertig. Workspace-Datei erstellt: $WORKSPACE_FILE"
echo "Tipp: In VS Code \"File > Open Workspace from File...\" nutzen."
'

write_file "$TARGET_DIR/tools/setup-local-wiki-workspace.ps1" 'param(
  [string]$OriginUrl = "",
  [string]$WikiDir = ""
)

$ErrorActionPreference = "Stop"

$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) {
  $repoRoot = (Get-Location).Path
}
Set-Location $repoRoot

if ([string]::IsNullOrWhiteSpace($OriginUrl)) {
  try {
    $OriginUrl = (git remote get-url origin).Trim()
  } catch {
    throw "Konnte origin URL nicht ermitteln. Bitte als Parameter -OriginUrl uebergeben."
  }
}

if ($OriginUrl.EndsWith(".wiki.git")) {
  $wikiUrl = $OriginUrl
} elseif ($OriginUrl.EndsWith(".git")) {
  $wikiUrl = $OriginUrl.Substring(0, $OriginUrl.Length - 4) + ".wiki.git"
} else {
  $wikiUrl = $OriginUrl + ".wiki.git"
}

$repoName = [System.IO.Path]::GetFileName($OriginUrl)
if ($repoName.EndsWith(".git")) {
  $repoName = $repoName.Substring(0, $repoName.Length - 4)
}
if ($repoName.EndsWith(".wiki")) {
  $repoName = $repoName.Substring(0, $repoName.Length - 5)
}

if ([string]::IsNullOrWhiteSpace($WikiDir)) {
  $WikiDir = Join-Path ".." "$repoName-wiki"
}

if (Test-Path (Join-Path $WikiDir ".git")) {
  Write-Host "Wiki-Repo existiert bereits: $WikiDir"
} else {
  git clone $wikiUrl $WikiDir
}

$workspaceFile = Join-Path $repoRoot "$repoName-with-wiki.code-workspace"
$workspaceJson = @{
  folders = @(
    @{ path = $repoRoot },
    @{ path = $WikiDir }
  )
  settings = @{}
} | ConvertTo-Json -Depth 5

Set-Content -Path $workspaceFile -Value $workspaceJson -Encoding UTF8

Write-Host "Fertig. Workspace-Datei erstellt: $workspaceFile"
Write-Host "Tipp: In VS Code File > Open Workspace from File nutzen."
'

echo ""
echo "Bootstrap abgeschlossen."
echo "Nächste Schritte:"
echo "1) Dateien committen"
echo "2) Wiki initial mit wiki-templates füllen"
echo "3) Erstes Slice in agent-workbench/projects/semesterprojekt/plan.md planen"
echo "4) Optional: bash tools/setup-local-wiki-workspace.sh"
echo "5) Optional (Windows/PowerShell): powershell -ExecutionPolicy Bypass -File tools/setup-local-wiki-workspace.ps1"
