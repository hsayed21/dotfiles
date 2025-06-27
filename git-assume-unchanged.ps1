#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Manages Git's --assume-unchanged flag for files that should remain unchanged locally.

.DESCRIPTION
    This script allows you to mark files as "assume unchanged" so Git will ignore local modifications.
    Reads the list of files from the assume-unchanged.txt file.
    Supports both individual files and folders (applies to all files in the folder recursively).

.PARAMETER Ignore
    Mark files as assume-unchanged

.PARAMETER Unignore
    Unmark files as assume-unchanged

.EXAMPLE
    .\git-assume-unchanged.ps1 -Ignore

.EXAMPLE
    .\git-assume-unchanged.ps1 -Unignore
#>

param(
    [switch]$Ignore,
    [switch]$Unignore
)

# Function to get all files from a folder recursively
function Get-FilesFromFolder {
    param([string]$FolderPath)

    if (Test-Path $FolderPath -PathType Container) {
        return Get-ChildItem -Path $FolderPath -File -Recurse | ForEach-Object {
            # Convert to relative path from current directory
            $relativePath = Resolve-Path -Path $_.FullName -Relative
            # Remove the .\ prefix if present
            if ($relativePath.StartsWith(".\")) {
                $relativePath = $relativePath.Substring(2)
            }
            return $relativePath
        }
    }
    return @()
}

# Function to expand paths (handle both files and folders)
function Expand-FilePaths {
    param([string[]]$Paths)

    $expandedFiles = @()

    foreach ($path in $Paths) {
        # Use the path as-is (should be relative to repo root)
        if (Test-Path $path -PathType Container) {
            Write-ColorOutput "📁 Expanding folder: $path" "Cyan"
            $folderFiles = Get-FilesFromFolder -FolderPath $path
            $expandedFiles += $folderFiles
            Write-ColorOutput "   Found $($folderFiles.Count) files in folder" "Cyan"
        } elseif (Test-Path $path -PathType Leaf) {
            $expandedFiles += $path
        } else {
            # Path doesn't exist, but we'll add it anyway (Git might handle it)
            $expandedFiles += $path
        }
    }

    return $expandedFiles
}

# Function to parse assume-unchanged files from txt file
function Get-AssumeUnchangedFilesFromTxtFile {
    param([string]$TxtFilePath)

    if (-not (Test-Path $TxtFilePath)) {
        Write-ColorOutput "❌ Error: assume-unchanged.txt file not found at $TxtFilePath" "Red"
        return @()
    }

    $files = @()
    $lines = Get-Content $TxtFilePath

    foreach ($line in $lines) {
        $trimmedLine = $line.Trim()

        # Skip empty lines and comment lines
        if ($trimmedLine -eq "" -or $trimmedLine.StartsWith("#")) {
            continue
        }

        # Add non-comment, non-empty lines as file paths
        $files += $trimmedLine
    }

    return $files
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )

    $colorMap = @{
        "Red" = [ConsoleColor]::Red
        "Green" = [ConsoleColor]::Green
        "Yellow" = [ConsoleColor]::Yellow
        "Blue" = [ConsoleColor]::Blue
        "Cyan" = [ConsoleColor]::Cyan
        "White" = [ConsoleColor]::White
    }

    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

function Test-GitRepository {
    $gitDir = git rev-parse --git-dir 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Error: Not in a Git repository" "Red"
        exit 1
    }
    return $true
}

function Set-AssumeUnchanged {
    param([string[]]$FilePaths)

    foreach ($file in $FilePaths) {
        # Use the file path directly (should already be relative)
        git update-index --assume-unchanged $file
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Marked as assume-unchanged: $file" "Green"
        } else {
            Write-ColorOutput "❌ Failed to mark: $file" "Red"
        }
    }
}

function Remove-AssumeUnchanged {
    param([string[]]$FilePaths)

    foreach ($file in $FilePaths) {
        git update-index --no-assume-unchanged $file
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Unmarked assume-unchanged: $file" "Green"
        } else {
            Write-ColorOutput "❌ Failed to unmark: $file" "Red"
        }
    }
}

function Show-Usage {
    Write-ColorOutput @"
Git Assume Unchanged Manager

Usage:
  .\git-assume-unchanged.ps1 -Ignore      Mark files as assume-unchanged
  .\git-assume-unchanged.ps1 -Unignore    Unmark files as assume-unchanged

Files are read from assume-unchanged.txt file.

Supports both individual files and folders:
  - Individual files: file.txt
  - Folders: folder/ (applies to all files in folder recursively)
"@ "Cyan"
}

# Main script logic
Test-GitRepository | Out-Null

# Get files from assume-unchanged.txt
$TxtFile = Join-Path $PSScriptRoot "assume-unchanged.txt"
$TargetPaths = Get-AssumeUnchangedFilesFromTxtFile -TxtFilePath $TxtFile

if ($TargetPaths.Count -eq 0) {
    Write-ColorOutput "❌ No files found in assume-unchanged.txt" "Red"
    exit 1
}

# Expand paths to handle folders
$TargetFiles = Expand-FilePaths -Paths $TargetPaths

if ($TargetFiles.Count -eq 0) {
    Write-ColorOutput "❌ No files found after expanding paths" "Red"
    exit 1
}

# print files to process
# foreach ($file in $TargetFiles) {
# 		Write-ColorOutput "$file" "White"
# }

if ($Ignore) {
    Write-ColorOutput "📋 Found $($TargetFiles.Count) file(s) to process" "Blue"
    Write-ColorOutput "🔒 Marking files as assume-unchanged..." "Blue"
    Set-AssumeUnchanged -FilePaths $TargetFiles
} elseif ($Unignore) {
    Write-ColorOutput "📋 Found $($TargetFiles.Count) file(s) to process" "Blue"
    Write-ColorOutput "🔓 Unmarking files as assume-unchanged..." "Blue"
    Remove-AssumeUnchanged -FilePaths $TargetFiles
} else {
    Show-Usage
}
