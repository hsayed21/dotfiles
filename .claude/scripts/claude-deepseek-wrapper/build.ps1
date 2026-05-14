#Requires -Version 5.1
<#
.SYNOPSIS
    Builds claude-deepseek-wrapper.exe using Go.
    Output: ..\bin\claude-deepseek-wrapper.exe  (single file, no dependencies)

.REQUIREMENTS
    Go 1.18+  →  https://go.dev/dl/
#>

$ErrorActionPreference = 'Stop'

# Verify Go is installed
if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    Write-Error "Go not found. Install from https://go.dev/dl/ then re-run this script."
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$outDir    = Join-Path (Split-Path -Parent $scriptDir) 'bin'
$outExe    = Join-Path $outDir 'claude-deepseek-wrapper.exe'

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

Write-Host "Building..." -ForegroundColor Cyan

$env:GOOS        = 'windows'
$env:GOARCH      = 'amd64'
$env:CGO_ENABLED = '0'   # pure Go — no C runtime dependency

go build -ldflags="-s -w" -o $outExe "$scriptDir\main.go"

if ($LASTEXITCODE -ne 0) { Write-Error "Build failed."; exit 1 }

$size = [math]::Round((Get-Item $outExe).Length / 1MB, 1)
Write-Host "Done: $outExe ($size MB)" -ForegroundColor Green
Write-Host ""
Write-Host 'Add to VS Code settings.json:' -ForegroundColor Yellow
Write-Host "  `"claudeCode.claudeProcessWrapper`": `"$($outExe.Replace('\','\\'))`""
