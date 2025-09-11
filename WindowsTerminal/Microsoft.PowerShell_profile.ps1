################################################################################
#                                Initial Commands                              #
################################################################################

Clear-Host;
$PSStyle.FileInfo.Directory = "[33m"

################################################################################
#                                  Oh my Posh!                                 #
################################################################################

# Import-Module "oh-my-posh";
Import-Module "posh-git";
# Import-Module "Terminal-Icons";
Import-Module "PSReadLine";
# Set-PoshPrompt -Theme "$Env:LOCALAPPDATA\kali.theme.json";

# Initialize Oh-My-Posh with error handling
try {
    oh-my-posh init pwsh --config "$Env:LOCALAPPDATA\kali.theme.json" | Invoke-Expression
} catch {
    # Try to refresh PATH from registry first
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # Try oh-my-posh command again after PATH refresh
    try {
        oh-my-posh init pwsh --config "$Env:LOCALAPPDATA\kali.theme.json" | Invoke-Expression
    } catch {
        # If still not found, try common installation locations
        $ohMyPoshPaths = @(
            "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe",
            "$env:USERPROFILE\scoop\apps\oh-my-posh\current\bin\oh-my-posh.exe",
            "$env:ProgramFiles\oh-my-posh\bin\oh-my-posh.exe"
        )

        $ohMyPoshFound = $false
        foreach ($path in $ohMyPoshPaths) {
            if (Test-Path $path) {
                $ohMyPoshDir = Split-Path $path -Parent

                # Check if directory is already in permanent PATH
                $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
                $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")

                if ($userPath -notlike "*$ohMyPoshDir*" -and $machinePath -notlike "*$ohMyPoshDir*") {
                    # Add to current session PATH
                    if ($env:Path -notlike "*$ohMyPoshDir*") {
                        $env:Path += ";$ohMyPoshDir"
                    }

                    # Add to permanent User PATH
                    try {
                        $newUserPath = if ($userPath) { "$userPath;$ohMyPoshDir" } else { $ohMyPoshDir }
                        [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
                        Write-Host "Permanently added oh-my-posh to User PATH: $ohMyPoshDir" -ForegroundColor Green
                        Write-Host "Please restart your terminal to ensure PATH changes take effect." -ForegroundColor Yellow
                    }
                    catch {
                        Write-Host "Failed to add oh-my-posh to permanent PATH. Added to session only." -ForegroundColor Yellow
                        Write-Host "You can manually add it using: [Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';$ohMyPoshDir', 'User')" -ForegroundColor Cyan
                    }
                } else {
                    # Already in permanent PATH, just ensure it's in current session
                    if ($env:Path -notlike "*$ohMyPoshDir*") {
                        $env:Path += ";$ohMyPoshDir"
                    }
                    # Write-Host "oh-my-posh directory already in permanent PATH: $ohMyPoshDir" -ForegroundColor Green
                }

                & $path init pwsh --config "$Env:LOCALAPPDATA\kali.theme.json" | Invoke-Expression
                $ohMyPoshFound = $true
                break
            }
        }

        if (-not $ohMyPoshFound) {
            Write-Host "Oh-My-Posh not found. Please restart your terminal or add it manually to PATH:" -ForegroundColor Yellow
            Write-Host '  $env:Path += ";C:\Users\$env:USERNAME\AppData\Local\Programs\oh-my-posh\bin"' -ForegroundColor Cyan
        }
    }
}

################################################################################
#                                  PSReadLine                                  #
################################################################################

Set-PSReadlineOption -BellStyle "None";

# Check PSReadLine version and set compatible options
try {
    $psReadLineVersion = (Get-Module PSReadLine).Version
    if ($psReadLineVersion -ge [Version]"2.1.0") {
        Set-PSReadLineOption -PredictionSource "History";
        Set-PSReadLineOption -Colors @{
            "InlinePrediction" = [ConsoleColor]::DarkGray;
        }
    } else {
        # Fallback for older PSReadLine versions
        # Write-Host "PSReadLine version $psReadLineVersion detected. Skipping advanced prediction features." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Could not determine PSReadLine version. Skipping prediction configuration." -ForegroundColor Yellow
}

Set-PSReadLineKeyHandler -Chord "Tab" -Function "MenuComplete";
#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58
