# Requires the UI spec to keep HarmonyOS semantic tokens and the implementation gate.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$required = @(
  'docs/goal/ui/README.md',
  'docs/goal/ui/QUALITY-GATE.md',
  'docs/goal/ui/SOURCES.md',
  'docs/goal/ui/app-shell/design-tokens.md',
  'docs/goal/ui/app-shell/navigation.md',
  'docs/goal/ui/app-shell/layout-patterns.md',
  'docs/goal/ui/bluetooth/overview.md',
  'docs/goal/ui/nearlink/scan.md',
  'docs/goal/ui/wifi-network/scan.md',
  'docs/goal/ui/log/center.md',
  'docs/goal/ui/settings/hub.md'
)

foreach ($rel in $required) {
  $path = Join-Path $root $rel
  if (-not (Test-Path $path)) {
    Write-Error "Missing UI spec file: $rel"
  }
}

$tokens = Get-Content -Raw (Join-Path $root 'docs/goal/ui/app-shell/design-tokens.md')
foreach ($needle in @('#0A59F7', 'font_primary', 'background_secondary', 'comp_background_emphasize', 'space.16', 'row.64', 'bar.56', 'touch.40')) {
  if ($tokens -notmatch [regex]::Escape($needle)) {
    Write-Error "design-tokens.md missing $needle"
  }
}

$gate = Get-Content -Raw (Join-Path $root 'docs/goal/ui/QUALITY-GATE.md')
if ($gate -notmatch '不可进入大规模页面实现') {
  Write-Error 'QUALITY-GATE.md lost the implementation block'
}

$readme = Get-Content -Raw (Join-Path $root 'docs/goal/ui/README.md')
if ($readme -notmatch 'PR #19 已关闭未合并') {
  Write-Error 'README.md must record that PR 19 is closed and unmerged'
}

$sources = Get-Content -Raw (Join-Path $root 'docs/goal/ui/SOURCES.md')
foreach ($needle in @('蓝牙通讯组件', '应用内可视化日志', '通用状态服务', '网络测速组件')) {
  if ($sources -notmatch [regex]::Escape($needle)) {
    Write-Error "SOURCES.md missing $needle"
  }
}

Write-Host 'UI token checks passed'
