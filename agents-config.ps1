<#
.SYNOPSIS
  Merge public + private AI-agent config into each tool's home folder using per-item symlinks.

.DESCRIPTION
  Google Drive (G:) cannot hold symlinks, so each tool's folder must be a REAL local
  folder. Every child of the public and private source folder is linked into it.
  Private wins on a name clash. Re-run any time you add or remove files.
  Needs admin or Windows Developer Mode. Supports -WhatIf.
  A tool whose Home folder does not exist (not installed) is skipped.
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'

# ---- Config (edit here) ---------------------------------------------------
# Source roots. Each Map entry is:  '<folder in tool home>' = '<folder under source root>'
$PublicRoot  = 'G:\My Drive\dotfiles'
$PrivateRoot = 'G:\My Drive\dotfiles\dotfiles-private'

$Targets = @(
    @{
        Name = 'Claude'
        Home = Join-Path $env:USERPROFILE '.claude'
        Src  = '.claude'                      # subfolder inside Public/Private root
        Map  = [ordered]@{
            commands = 'commands'
            agents   = 'agents'
            rules    = 'rules'
            skills   = 'skills'
        }
    }
    @{
        Name = 'Codex'
        Home = Join-Path $env:USERPROFILE '.codex'
        Src  = '.codex'
        Map  = [ordered]@{
            skills  = 'skills'
            prompts = 'prompts'
						rules	  = 'rules'
        }
    }
    @{
        Name = 'Cursor'
        Home = Join-Path $env:USERPROFILE '.cursor'
        Src  = '.cursor'
        Map  = [ordered]@{
            commands = 'commands'
						skills   = 'skills'
        }
    }
)
# ---------------------------------------------------------------------------

function Test-IsLink([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    return ($null -ne $item) -and [bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function Remove-LinkOnly([string]$Path) {
    # .Delete() removes only the link, never the target's contents.
    (Get-Item -LiteralPath $Path -Force).Delete()
}

foreach ($t in $Targets) {
    if (-not (Test-Path -LiteralPath $t.Home)) {
        Write-Host "[$($t.Name)] $($t.Home) not found - skipped" -ForegroundColor DarkGray
        continue
    }
    Write-Host "[$($t.Name)]" -ForegroundColor Yellow

    foreach ($destName in $t.Map.Keys) {
        $srcName = $t.Map[$destName]
        $dest    = Join-Path $t.Home $destName
        Write-Host "== $destName" -ForegroundColor Cyan

        # 1. Make $dest a real local directory (replace a folder symlink if present).
        if (Test-IsLink $dest) {
            if ($PSCmdlet.ShouldProcess($dest, 'Remove folder symlink')) { Remove-LinkOnly $dest }
        }
        if (-not (Test-Path -LiteralPath $dest)) {
            if ($PSCmdlet.ShouldProcess($dest, 'Create real directory')) {
                New-Item -ItemType Directory -Path $dest | Out-Null
            }
        }

        # 2. Drop stale links. Real files are never touched.
        if (Test-Path -LiteralPath $dest) {
            Get-ChildItem -LiteralPath $dest -Force | Where-Object { Test-IsLink $_.FullName } | ForEach-Object {
                if ($PSCmdlet.ShouldProcess($_.FullName, 'Remove old link')) { Remove-LinkOnly $_.FullName }
            }
        }

        # 3. Collect sources; private overrides public on the same name.
        $sources = [ordered]@{}
        foreach ($root in @($PublicRoot, $PrivateRoot)) {
            $src = Join-Path (Join-Path $root $t.Src) $srcName
            if (-not (Test-Path -LiteralPath $src)) { continue }
            foreach ($child in Get-ChildItem -LiteralPath $src -Force) {
                if ($sources.Contains($child.Name)) {
                    Write-Warning "'$destName\$($child.Name)' exists in both; using $root"
                }
                $sources[$child.Name] = $child.FullName
            }
        }

        # 4. Link each item.
        foreach ($name in $sources.Keys) {
            $linkPath = Join-Path $dest $name
            if ((Test-Path -LiteralPath $linkPath) -and -not (Test-IsLink $linkPath)) {
                Write-Warning "Skipping '$linkPath': a real file/folder is in the way."
                continue
            }
            if ($PSCmdlet.ShouldProcess($linkPath, "Link -> $($sources[$name])")) {
                New-Item -ItemType SymbolicLink -Path $linkPath -Target $sources[$name] | Out-Null
                Write-Host "  linked $name"
            }
        }
    }
}

Write-Host "`nDone. Restart the tools / app to reload." -ForegroundColor Green
