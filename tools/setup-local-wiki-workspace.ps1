param(
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
