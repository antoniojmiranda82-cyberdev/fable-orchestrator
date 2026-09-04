$ErrorActionPreference = 'Stop'

$source = Join-Path $PSScriptRoot 'skill\fable'
$target = Join-Path $HOME '.codex\skills\fable'

if (-not (Test-Path $source)) {
    throw "Source skill folder not found: $source"
}

Write-Host "Installing Fable skill"
Write-Host "Source: $source"
Write-Host "Target: $target"

New-Item -ItemType Directory -Path $target -Force | Out-Null
Copy-Item -Path (Join-Path $source '*') -Destination $target -Recurse -Force

Write-Host ""
Write-Host "Installed files:"
Get-ChildItem -Path $target -Recurse | Select-Object FullName

Write-Host ""
Write-Host "Done. Restart Codex, then start a new task and invoke Fable with:"
Write-Host '$fable inspect this repository and report the architecture'
