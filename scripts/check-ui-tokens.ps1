#Requires -Version 7
# Static check invoked by .github/workflows/ui-tokens.yml.
# Confirms base and dark color resources share one name set, and every
# $r('app.color.*') under common/youi_kit resolves to that set.
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')

function Get-ColorNames([string]$path) {
    $json = Get-Content -Raw -Path $path | ConvertFrom-Json
    $names = @($json.color | ForEach-Object { $_.name })
    if ($names.Count -eq 0) {
        throw "no color names in $path"
    }
    return $names
}

$basePath = Join-Path $root 'common/youi_kit/src/main/resources/base/element/color.json'
$darkPath = Join-Path $root 'common/youi_kit/src/main/resources/dark/element/color.json'
$base = Get-ColorNames $basePath
$dark = Get-ColorNames $darkPath
$baseSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$base)
$darkSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$dark)

$onlyBase = @($base | Where-Object { -not $darkSet.Contains($_) })
$onlyDark = @($dark | Where-Object { -not $baseSet.Contains($_) })
if ($onlyBase.Count -gt 0 -or $onlyDark.Count -gt 0) {
    throw "color name sets differ. only base: $($onlyBase -join ', '); only dark: $($onlyDark -join ', ')"
}

$pattern = '\$r\(''app\.color\.([A-Za-z0-9_]+)''\)'
$missing = @()
Get-ChildItem -Recurse -Filter *.ets -Path (Join-Path $root 'common/youi_kit') | ForEach-Object {
    $text = Get-Content -Raw -Path $_.FullName
    foreach ($match in [regex]::Matches($text, $pattern)) {
        $name = $match.Groups[1].Value
        if (-not $baseSet.Contains($name)) {
            $missing += "$($_.FullName): $name"
        }
    }
}
if ($missing.Count -gt 0) {
    throw ("unresolved app.color references:`n" + ($missing -join "`n"))
}

Write-Host "ui token check ok: $($base.Count) color names, base/dark symmetric"
