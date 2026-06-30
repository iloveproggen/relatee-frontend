param(
    [switch]$NoLaunch
)

$projectRoot = Join-Path $PSScriptRoot 'frontend_v1'

if (-not (Test-Path (Join-Path $projectRoot 'pubspec.yaml'))) {
    throw "No pubspec.yaml found under $projectRoot."
}

Set-Location $projectRoot

if ($NoLaunch) {
    Write-Host "Project root: $projectRoot"
    Write-Host "pubspec.yaml found: $(Test-Path pubspec.yaml)"
    return
}

flutter run