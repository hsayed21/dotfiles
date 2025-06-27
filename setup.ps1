param(
    [switch]$Package,
    [switch]$Mapping,
    [switch]$Environment,
    [switch]$PackageManager,
    [switch]$PowerShell,
    [switch]$Registry,
    [switch]$All,
    [string[]]$Category = @(),
    [switch]$Help
)

# Show help information
if ($Help) {
    Write-Host @"
Setup Script Parameters:

-Package         : Install packages only
-Mapping         : Create symbolic links/mappings only
-Environment     : Setup environment (package managers + PowerShell modules)
-PackageManager  : Install package managers only
-PowerShell      : Configure PowerShell environment only
-Registry        : Apply registry settings only
-All             : Run all sections (default behavior)
-Category        : Install packages from specific categories only (Development, Utilities, Browsers, Fonts)
-Help            : Show this help message

Examples:
  .\setup.ps1                                    # Run everything
  .\setup.ps1 -Package                          # Install packages only
  .\setup.ps1 -Mapping                          # Create symlinks only
  .\setup.ps1 -Category Development,Utilities   # Install only Development and Utilities packages
  .\setup.ps1 -Environment                      # Setup package managers and PowerShell
"@
    exit 0
}

# If no parameters specified, run all sections
if (-not ($Package -or $Mapping -or $Environment -or $PackageManager -or $PowerShell -or $Registry -or $Category)) {
    $Mapping = $true
}

. .\_helper\_function.ps1
#Requires -RunAsAdministrator

# Initialize logging
Initialize-Log
Write-Log "Starting setup process..." -Level Info

# Group packages by categories
$packages = @{
  Development = @{
    Scoop  = @(
      @{ name = "git" },
      @{ name = "python" }
    )
    Winget = @(
      @{ name = "Microsoft.VisualStudioCode" },
      @{ name = "Microsoft.WindowsTerminal" }
    )
    Choco  = @(
      @{ name = "dotnet-sdk" }
    )
  }
  Utilities   = @{
    Scoop       = @(
      @{ name = "sudo" },
      @{ name = "curl" },
      @{ name = "pwsh" },
      @{ name = "concfg" },
      @{ name = "extras/altsnap" },
      @{ name = "alacritty" }
      @{ name = "extras/unigetui" }
      @{ name = "zig" },
      @{ name = "lazygit" }
      # @{ name = "fzf" },
      # @{ name = "ripgrep" }
    )
    Winget      = @(
      @{ name = "Microsoft.PowerToys" },
      @{ name = "JanDeDobbeleer.OhMyPosh" },
      @{ name = "GlazeWM" },
      @{ name = "Zebar" },
      @{ id = "stnkl.EverythingToolbar" }
    )
    Choco       = @(
      @{ name = "flow-launcher" },
      @{ name = "winspy" },
      @{ name = "wingetui" },
      @{ name = "nircmd" },
      @{ name = "7zip" },
      @{ name = "notepadplusplus" },
      @{ name = "everything" },
      @{ name = "wget" },
      @{ name = "smartsystemmenu" },
      @{ name = "ffmpeg" },
      @{ name = "fzf" },
      @{ name = "ripgrep" },
      @{ name = "bat" },
      @{ name = "grep" }
    )
    SourceForge = @(
      @{
        project = "globonote/files/globonote"
        file    = "globonote-setup.exe"
        # args = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
      }
    )
  }
  Browsers    = @{
    Winget = @(
      @{ name = "Google.Chrome" },
      @{ name = "Mozilla.Firefox" }
    )
  }
  Fonts       = @{
    Choco = @(
      @{ name = "nerdfont-hack" },
      @{ name = "nerd-fonts-firacode" }
    )
  }
}


# Mappings for symbolic links
$mappings = @(
  # nvim
  @{
    source = "$PWD\nvim"
    dest   = "$Env:LOCALAPPDATA\nvim"
  },
  # vscode
  @{
    source = "$PWD\vscode\settings.json"
    dest   = "$Env:APPDATA\Code\User\settings.json"
  },
  @{
    source = "$PWD\vscode\keybindings.json"
    dest   = "$Env:APPDATA\Code\User\keybindings.json"
  },
  @{
    source = "$PWD\vscode\extensions.json"
    dest   = "$Home\.vscode\extensions\extensions.json"
  },
  # vs2022
  @{
    source = "$PWD\VS2022\CurrentSettings.vssettings"
    dest   = "$Env:LOCALAPPDATA\Microsoft\VisualStudio\17.0_*\Settings\CurrentSettings.vssettings"
  },
  # lazygit
  @{
    source = "$PWD\lazygit\config.yml"
    dest   = "$Env:LOCALAPPDATA\lazygit\config.yml"
  },
  # ShareX
  @{
    source = "$PWD\ShareX\ApplicationConfig.json"
    dest   = "$Home\Documents\ShareX\ApplicationConfig.json"
  },
  @{
    source = "$PWD\ShareX\HotkeysConfig.json"
    dest   = "$Home\Documents\ShareX\HotkeysConfig.json"
  },
  # Everything
  @{
    source = "$PWD\Everything\Everything.ini"
    dest   = "$Env:APPDATA\Everything\Everything.ini"
  },
  @{
    source = "$PWD\Everything\Filters.csv"
    dest   = "$Env:APPDATA\Everything\Filters.csv"
  },
  # OBS
  @{
    source = "$PWD\OBS\basic"
    dest   = "$Env:APPDATA\obs-studio\basic"
  },
  # wireshark
  @{
    source = "$PWD\wireshark\MyProfile"
    dest   = "$Env:APPDATA\Wireshark\profiles\MyProfile"
  },
  # elevenclock
  @{
    source = "$PWD\elevenclock\CustomClockStrings"
    dest   = "$Home\.elevenclock\CustomClockStrings"
  },
  @{
    source = "$PWD\elevenclock\PreferredLanguage"
    dest   = "$Home\.elevenclock\PreferredLanguage"
  },
  @{
    source = "$PWD\elevenclock\CustomClockClickAction"
    dest   = "$Home\.elevenclock\CustomClockClickAction"
  },
  @{
    source = "$PWD\elevenclock\CustomClockDoubleClickAction"
    dest   = "$Home\.elevenclock\CustomClockDoubleClickAction"
  },
  @{
    source = "$PWD\elevenclock\ClockFixedHeight"
    dest   = "$Home\.elevenclock\ClockFixedHeight"
  },
  @{
    source = "$PWD\elevenclock\ClockYOffset"
    dest   = "$Home\.elevenclock\ClockYOffset"
  },
  @{
    source = "$PWD\elevenclock\ClockXOffset"
    dest   = "$Home\.elevenclock\ClockXOffset"
  },
  @{
    source = "$PWD\elevenclock\UseCustomFontSize"
    dest   = "$Home\.elevenclock\UseCustomFontSize"
  },
  # voicemeeter
  @{
    source = "$PWD\VoicemeeterBanana\VoiceMeeterBananaDefault.xml"
    dest   = "$Env:APPDATA\VoiceMeeterBananaDefault.xml"
  },
  @{
    source = "$PWD\VoicemeeterBanana\VoicemeeterBanana_LastSettings.xml"
    dest   = "$Home\Documents\Voicemeeter\VoicemeeterBanana_LastSettings.xml"
  },
  @{
    source = "$PWD\VoicemeeterBanana\MacroButtonConfig.xml"
    dest   = "$Home\Documents\Voicemeeter\MacroButtonConfig.xml"
  },
  # EqualizerAPO
  @{
    source = "$PWD\EqualizerAPO\config.txt"
    dest   = "$Env:ProgramFiles\EqualizerAPO\config\config.txt"
  },
  @{
    source = "$PWD\EqualizerAPO\Mic.txt"
    dest   = "$Env:ProgramFiles\EqualizerAPO\config\Mic.txt"
  },
  @{
    source = "$PWD\EqualizerAPO\peace.txt"
    dest   = "$Env:ProgramFiles\EqualizerAPO\config\peace.txt"
  },
  # dbForge
  @{
    source = "$PWD\dbForge\SQL Server\Snippets"
    dest   = "$Env:ProgramData\Devart\dbForge Studio for SQL Server\Snippets"
  },
  @{
    source = "$PWD\dbForge\PostgreSQL\Snippets"
    dest   = "$Env:ProgramData\Devart\dbForge Studio for PostgreSQL\Snippets"
  },
  @{
    source = "$PWD\dbForge\MySQL\Snippets"
    dest   = "$Env:ProgramData\Devart\dbForge Studio for MySQL\Snippets"
  },
  @{
    source = "$PWD\dbForge\SQL Server\Keybinding_Default.xml"
    dest   = "$Env:APPDATA\Devart\dbForge Studio for SQL Server\ShortcutSchemes\Default.xml"
  },
  @{
    source = "$PWD\dbForge\PostgreSQL\Keybinding_Default.xml"
    dest   = "$Env:APPDATA\Devart\dbForge Studio for PostgreSQL\ShortcutSchemes\Default.xml"
  },
  @{
    source = "$PWD\dbForge\MySQL\Keybinding_Default.xml"
    dest   = "$Env:APPDATA\Devart\dbForge Studio for MySQL\ShortcutSchemes\Default.xml"
  },
  # git
  @{
    source = "$PWD\git\.gitconfig-work"
    dest   = "$Home\git\.gitconfig-work"
  },
  @{
    source = "$PWD\git\.gitconfig"
    dest   = "$Home\git\.gitconfig"
  }
  # WindowsTerminal
  @{
    source = "$PWD\WindowsTerminal\settings.json"
    dest   = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
  },
  @{
    source = "$PWD\WindowsTerminal\Microsoft.PowerShell_profile.ps1"
    dest   = "$Profile"
  },
  # glazewm (tiling window manager for Windows inspired by i3wm)
  @{
    source = "$PWD\.glzr"
    dest   = "$Home\.glzr"
  },
  # AltSnap
  @{
    source = "$PWD\AltSnap\AltSnap.ini"
    dest   = "$env:UserProfile\scoop\apps\altsnap\1.64\AltSnap.ini"
  }
  # wezterm
  @{
    source = "$PWD\wezterm\.wezterm.lua"
    dest   = "$Home\.wezterm.lua"
  },
  # FlowLauncher
  @{
    source = "$PWD\FlowLauncher\Settings"
    dest   = "$Env:APPDATA\FlowLauncher\Settings"
  },
  # globonote
  @{
    source = "$PWD\.globonote"
    dest   = "$Home\.globonote"
  },
  # Directory Opus
  @{
    source = "$PWD\DirectoryOpus"
    dest   = "$Env:APPDATA\GPSoftware\Directory Opus"
  },
  # editorconfig
  @{
    source = "$PWD\vscode\.editorconfig"
    dest   = "$Home\.editorconfig"
  },
  # Prettier
  @{
    source = "$PWD\vscode\.prettierrc"
    dest   = "$Home\.prettierrc"
  },
  # yasb
  @{
    source = "$PWD\yasb"
    dest   = "$Home\.config\yasb"
  }
)


# Track installation statistics
$stats = @{
  Successful = 0
  Failed     = 0
  Skipped    = 0
  Total      = 0
}

# Determine which sections to run
$runPackageManager = $All -or $Environment -or $PackageManager
$runPowerShell = $All -or $Environment -or $PowerShell
$runPackages = $All -or $Package -or ($Category.Count -gt 0)
$runMappings = $All -or $Mapping
$runRegistry = $All -or $Registry

Write-Log "Running sections: PackageManager=$runPackageManager, PowerShell=$runPowerShell, Packages=$runPackages, Mappings=$runMappings, Registry=$runRegistry" -Level Info



# Setup Environment
if ($runPackageManager) {
    Write-Log "Setting up package managers..." -Level Info

    # Package Manager Installation
    $packageManagers = @(
      @{
        Name      = "Scoop"
        Condition = { -not (Get-Command scoop -ErrorAction SilentlyContinue) }
        Install   = { iex "& {$(irm get.scoop.sh)} -RunAsAdmin" }
      },
      @{
        Name      = "Chocolatey"
        Condition = { -not (Get-Command choco -ErrorAction SilentlyContinue) }
        Install   = { Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1")) }
      },
      @{
        Name      = "Winget"
        Condition = { -not (Get-Command winget -ErrorAction SilentlyContinue) }
        Install   = { irm asheroto.com/winget | iex }
      }
    )

    foreach ($pm in $packageManagers) {
      if (& $pm.Condition) {
        try {
          Write-Log "Installing $($pm.Name)..." -Level Info
          & $pm.Install
          Show-SuccessMessage -Message "$($pm.Name) has been installed successfully."
        }
        catch {
          Write-Log "Failed to install $($pm.Name): $($_.Exception.Message)" -Level Error
          exit 1
        }
      }
      else {
        Show-SuccessMessage -Message "$($pm.Name) is already installed."
      }
    }
}

# Install packages by category
if ($runPackages) {
    Write-Log "Installing packages..." -Level Info

    foreach ($category in $packages.Keys) {
      if ($Category.Count -eq 0 -or $Category -contains $category) {
        Write-Log "Installing $category packages..." -Level Info

        if ($packages[$category].Scoop) {
          foreach ($pkg in $packages[$category].Scoop) {
            $stats.Total++
            $result = Install-ScoopPackage -Package $pkg
            if ($result) { $stats.Successful++ } else { $stats.Failed++ }
          }
        }

        if ($packages[$category].Winget) {
          foreach ($pkg in $packages[$category].Winget) {
            $stats.Total++
            $result = Install-WingetPackage -Package $pkg
            if ($result) { $stats.Successful++ } else { $stats.Failed++ }
          }
        }

        if ($packages[$category].Choco) {
          foreach ($pkg in $packages[$category].Choco) {
            $stats.Total++
            $result = Install-ChocoPackage -Package $pkg
            if ($result) { $stats.Successful++ } else { $stats.Failed++ }
          }
        }

        if ($packages[$category].SourceForge) {
          foreach ($pkg in $packages[$category].SourceForge) {
            $stats.Total++
            $result = Install-SourceForgePackage -Package $pkg
            if ($result) { $stats.Successful++ } else { $stats.Failed++ }
          }
        }
      }
    }
}

# Configuration/Mapping
if ($runMappings) {
    Write-Log "Creating symbolic links..." -Level Info

    # Process symlinks with progress and force
    $total = $mappings.Count
    $current = 0
    foreach ($_mapping in $mappings) {
      $current++
      $progress = [math]::Round(($current / $total) * 100)
      Write-Progress -Activity "Creating symlinks" -Status "$progress% Complete" -PercentComplete $progress

      Create-SymbolicLink -destPath $_mapping.dest -sourcePath $_mapping.source -Force
    }
    Write-Progress -Activity "Creating symlinks" -Completed
}

# Configure PowerShell environment
if ($runPowerShell) {
    Write-Log "Configuring PowerShell environment..." -Level Info

    # Install PowerShell modules
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    $psModules = @(
      "CompletionPredictor",
      "PSScriptAnalyzer",
      "ps-color-scripts",
      "Get-ChildItemColor",
      "oh-my-posh",
      "pscolor",
      "posh-ssh",
      "posh-git"
    )

    foreach ($module in $psModules) {
      if (!(Get-Module -ListAvailable -Name $module)) {
        Write-Log "Installing PowerShell module: $module" -Level Info
        Install-Module -Name $module -AcceptLicense -Scope CurrentUser -Force -AllowClobber -Confirm:$false
      }
    }

    # PowerShell profile and theme configuration
    concfg import "$PWD\WindowsTerminal\concfg.json"
    Copy-Item -Path "$PWD\WindowsTerminal\kali.theme.json" -Destination $Env:LOCALAPPDATA\kali.theme.json -Force
    & "$PWD\WindowsTerminal\fix warning screen reader for powershell.ps1"

    # $profileContent = @"
    # oh-my-posh init pwsh --config '$Env:LOCALAPPDATA\kali.theme.json' | Invoke-Expression
    # `$PSStyle.FileInfo.Directory = "`e[33m"
    # "@
    # Set-Content -Path $Profile -Value $profileContent

}

# Registry settings
if ($runRegistry) {
    Write-Log "Applying registry settings..." -Level Info

    # vscode
    reg import "$PWD\vscode\vscode contextmenu with profile.reg" *>&1 | Out-Null
    Write-Log "VS Code context menu settings applied" -Level Success

    # ExplorerPatcher
    reg import "$PWD\ExplorerPatcher\ExplorerPatcher_22621.1413.54.5.reg" *>&1 | Out-Null
    Write-Log "ExplorerPatcher settings applied" -Level Success

    # vs2022
    # & "$Env:ProgramFiles\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe" /ResetSettings ($currentPath + "\VS2022\VS2022_Config.vssettings")
    # Show-SuccessMessage -Message "VS2022 Settings has been Restored successfully."
}

# Display installation summary
Write-Log "Installation Summary:" -Level Info
Write-Log "Total packages: $($stats.Total)" -Level Info
Write-Log "Successfully installed: $($stats.Successful)" -Level Success
Write-Log "Failed installations: $($stats.Failed)" -Level Error
Write-Log "Skipped installations: $($stats.Skipped)" -Level Warning

Write-Log "Setup completed successfully!" -Level Success
