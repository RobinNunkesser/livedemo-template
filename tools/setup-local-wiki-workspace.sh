#!/usr/bin/env bash
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
