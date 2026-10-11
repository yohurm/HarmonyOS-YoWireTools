# Requires the UI spec to name the tokens the screens use.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$ui = Join-Path $root 'docs/goal/ui'

$files = @(
  'README.md',
  'QUALITY-GATE.md',
  'app-shell/design-tokens.md',
  'app-shell/density.md',
  'app-shell/layout-patterns.md',
  'app-shell/navigation.md',
  'app-shell/color-scheme.md',
  'bluetooth/classic-scan.md',
  'wifi-network/scan.md',
  'log/center.md',
  'settings/hub.md'
)
foreach ($rel in $files) {
  $path = Join-Path $ui $rel
  if (-not (Test-Path -LiteralPath $path)) {
    throw "missing $rel"
  }
}

$tokens = Get-Content -LiteralPath (Join-Path $ui 'app-shell/design-tokens.md') -Raw
$names = @('space.16', 'radius.20', 'radius.32', 'type.title.m', 'touch.40', 'row.64', 'bar.56')
foreach ($name in $names) {
  if ($tokens.IndexOf($name) -lt 0) {
    throw "design-tokens.md missing $name"
  }
}

$gate = Get-Content -LiteralPath (Join-Path $ui 'QUALITY-GATE.md') -Raw
if ($gate.IndexOf('不可进入大规模页面实现') -lt 0) {
  throw 'QUALITY-GATE.md lost the blocked conclusion'
}

Write-Host 'ui token spec ok'
