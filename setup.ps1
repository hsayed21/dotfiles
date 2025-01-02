. .\_helper\_function.ps1
#Requires -RunAsAdministrator

# ================================================
# Setup Environment
# ================================================
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
# Check and install Scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    Show-SuccessMessage -Message "Scoop has been installed successfully."
} else {
    Show-SuccessMessage -Message "Scoop is already installed."
}

# Check and install Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
    Show-SuccessMessage -Message "Chocolatey has been installed successfully."
} else {
    Show-SuccessMessage -Message "Chocolatey is already installed."
}

# ================================================
# Install Necessary Packages
# ================================================
scoop bucket add extras
$scoop_packages = @("git", "python", "concfg", "sudo", "curl", "lazygit", "fzf", "ripgrep", "zig", "pwsh",
"extras/altsnap", "alacritty", "extras/unigetui")
foreach ($pkg in $scoop_packages) {
    Install-ScoopPackage -packageName $pkg
}

$winget_packages = @("JanDeDobbeleer.OhMyPosh","Microsoft.PowerToys", "Microsoft.WindowsTerminal", "Microsoft.VisualStudioCode",
 "Google.Chrome", "Mozilla.Firefox", "GlazeWM", "Zebar")
foreach ($pkg in $winget_packages) {
    Install-WingetPackage -packageName $pkg
}
$winget_packages_ids = @("stnkl.EverythingToolbar")
foreach ($pkg in $winget_packages_ids) {
    Install-WingetPackage -packageName $pkg -usePackageId $true
}


# $choco_packages = @("dotnet-sdk")
$choco_packages = @("flow-launcher", "winspy", "wingetui", "nircmd", "7zip", "notepadplusplus", "everything")

foreach ($pkg in $choco_packages) {
    Install-ChocoPackage -packageName $pkg
}

# ================================================
# Configuration
# ================================================
$mappings = @(
   # nvim
  @{
    source = "$PWD\nvim"
    dest = "$Env:LOCALAPPDATA\nvim"
  },
   # vscode
  @{
    source = "$PWD\vscode\settings.json"
    dest = "$Env:APPDATA\Code\User\settings.json"
  },
  @{
    source = "$PWD\vscode\keybindings.json"
    dest = "$Env:APPDATA\Code\User\keybindings.json"
  },
  @{
    source = "$PWD\vscode\extensions.json"
    dest = "$Home\.vscode\extensions\extensions.json"
  },
  # vs2022
  @{
    source = "$PWD\VS2022\CurrentSettings.vssettings"
    dest = "$Env:LOCALAPPDATA\Microsoft\VisualStudio\17.0_*\Settings\CurrentSettings.vssettings"
  },
  # lazygit
  @{
    source = "$PWD\lazygit\config.yml"
    dest = "$Env:LOCALAPPDATA\lazygit\config.yml"
  },
  # ShareX
  @{
    source = "$PWD\ShareX\ApplicationConfig.json"
    dest = "$Home\Documents\ShareX\ApplicationConfig.json"
  },
  @{
    source = "$PWD\ShareX\HotkeysConfig.json"
    dest = "$Home\Documents\ShareX\HotkeysConfig.json"
  },
  # Everything
  @{
    source = "$PWD\Everything\Everything.ini"
    dest = "$Env:APPDATA\Everything\Everything.ini"
  },
  @{
    source = "$PWD\Everything\Filters.csv"
    dest = "$Env:APPDATA\Everything\Filters.csv"
  },
  # OBS
  @{
    source = "$PWD\OBS\scenes\recording.json"
    dest = "$Env:APPDATA\obs-studio\basic\scenes\recording.json"
  },
  @{
    source = "$PWD\OBS\profiles\Virtual_Mic"
    dest = "$Env:APPDATA\obs-studio\basic\profiles\Virtual_Mic"
  },
  # wireshark
  @{
    source = "$PWD\wireshark\MyProfile"
    dest = "$Env:APPDATA\Wireshark\profiles\MyProfile"
  },
  # elevenclock
  @{
    source = "$PWD\elevenclock\CustomClockStrings"
    dest = "$Home\.elevenclock\CustomClockStrings"
  },
  @{
    source = "$PWD\elevenclock\PreferredLanguage"
    dest = "$Home\.elevenclock\PreferredLanguage"
  },
  @{
    source = "$PWD\elevenclock\CustomClockClickAction"
    dest = "$Home\.elevenclock\CustomClockClickAction"
  },
  @{
    source = "$PWD\elevenclock\CustomClockDoubleClickAction"
    dest = "$Home\.elevenclock\CustomClockDoubleClickAction"
  },
  @{
    source = "$PWD\elevenclock\ClockFixedHeight"
    dest = "$Home\.elevenclock\ClockFixedHeight"
  },
  @{
    source = "$PWD\elevenclock\ClockYOffset"
    dest = "$Home\.elevenclock\ClockYOffset"
  },
  @{
    source = "$PWD\elevenclock\ClockXOffset"
    dest = "$Home\.elevenclock\ClockXOffset"
  },
  @{
    source = "$PWD\elevenclock\UseCustomFontSize"
    dest = "$Home\.elevenclock\UseCustomFontSize"
  },
  # voicemeeter
  @{
    source = "$PWD\VoicemeeterBanana\VoiceMeeterBananaDefault.xml"
    dest = "$Env:APPDATA\VoiceMeeterBananaDefault.xml"
  },
  @{
    source = "$PWD\VoicemeeterBanana\VoicemeeterBanana_LastSettings.xml"
    dest = "$Home\Documents\Voicemeeter\VoicemeeterBanana_LastSettings.xml"
  },
  @{
    source = "$PWD\VoicemeeterBanana\MacroButtonConfig.xml"
    dest = "$Home\Documents\Voicemeeter\MacroButtonConfig.xml"
  },
  # dbForge
  @{
    source = "$PWD\dbForge\SQL Server\Snippets"
    dest = "$Env:ProgramData\Devart\dbForge Studio for SQL Server\Snippets"
  },
  @{
    source = "$PWD\dbForge\PostgreSQL\Snippets"
    dest = "$Env:ProgramData\Devart\dbForge Studio for PostgreSQL\Snippets"
  },
  @{
    source = "$PWD\dbForge\MySQL\Snippets"
    dest = "$Env:ProgramData\Devart\dbForge Studio for MySQL\Snippets"
  },
  @{
    source = "$PWD\dbForge\SQL Server\Keybinding_Default.xml"
    dest = "$Env:APPDATA\Devart\dbForge Studio for SQL Server\ShortcutSchemes\Default.xml"
  },
  @{
    source = "$PWD\dbForge\PostgreSQL\Keybinding_Default.xml"
    dest = "$Env:APPDATA\Devart\dbForge Studio for PostgreSQL\ShortcutSchemes\Default.xml"
  },
  @{
    source = "$PWD\dbForge\MySQL\Keybinding_Default.xml"
    dest = "$Env:APPDATA\Devart\dbForge Studio for MySQL\ShortcutSchemes\Default.xml"
  },
  # git
  @{
    source = "$PWD\git\.gitconfig-work"
    dest = "$Home\git\.gitconfig-work"
  },
  @{
    source = "$PWD\git\.gitconfig"
    dest = "$Home\git\.gitconfig"
  }
  # WindowsTerminal
  @{
    source = "$PWD\WindowsTerminal\settings.json"
    dest = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
  },
  @{
    source = "$PWD\WindowsTerminal\Microsoft.PowerShell_profile.ps1"
    dest = "$Profile"
  },
  # glazewm (tiling window manager for Windows inspired by i3wm)
  @{
    source = "$PWD\.glzr"
    dest = "$Home\.glzr"
  },
  # AltSnap
  @{
    source = "$PWD\AltSnap\AltSnap.ini"
    dest = "$env:UserProfile\scoop\apps\altsnap\1.64\AltSnap.ini"
  }
  # wezterm
  @{
    source = "$PWD\wezterm\.wezterm.lua"
    dest = "$Home\.wezterm.lua"
  }
)


# powershell
# PS Modules
# Set the PSGallery repository to trusted
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
$psModules = @(
    "CompletionPredictor"
    "PSScriptAnalyzer"
    "ps-color-scripts"
)
install-module Get-ChildItemColor -scope CurrentUser -Force -AllowClobber -Confirm:$false
install-module oh-my-posh -scope CurrentUser -Force -AllowClobber -Confirm:$false
install-module pscolor -scope CurrentUser -Force -AllowClobber -Confirm:$false
install-module posh-ssh -scope CurrentUser -Force -AllowClobber -Confirm:$false
install-module posh-git -scope CurrentUser -Force -AllowClobber -Confirm:$false
foreach ($psModule in $psModules) {
    if (!(Get-Module -ListAvailable -Name $psModule)) {
        Install-Module -Name $psModule -AcceptLicense -Scope CurrentUser -Force -AllowClobber -Confirm:$false
    }
}

Show-SuccessMessage -Message "PS Modules has been installed successfully."

# install font nerd-font
choco install -y "nerdfont-hack";
choco install -y "nerd-fonts-firacode"

# vs2022
# & "$Env:ProgramFiles\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe" /ResetSettings ($currentPath + "\VS2022\VS2022_Config.vssettings")
# Show-SuccessMessage -Message "VS2022 Settings has been Restored successfully."

foreach ($mapping in $mappings) {
  Create-SymbolicLink -destPath "$($mapping.dest)" -sourcePath "$($mapping.source)"
}

# vscode
reg import "$PWD\vscode\vscode contextmenu with profile.reg" *>&1 | Out-Null

# ExplorerPatcher
reg import "$PWD\ExplorerPatcher\ExplorerPatcher_22621.1413.54.5.reg" *>&1 | Out-Null
Show-SuccessMessage -Message "ExplorerPatcher Settings has been Restored successfully."

concfg import "$PWD\WindowsTerminal\concfg.json"
Copy-Item -Path "$PWD\WindowsTerminal\kali.theme.json" -Destination $Env:LOCALAPPDATA\kali.theme.json -Force
# $profileContent = @"
# oh-my-posh init pwsh --config '$Env:LOCALAPPDATA\kali.theme.json' | Invoke-Expression
# `$PSStyle.FileInfo.Directory = "`e[33m"
# "@
# Set-Content -Path $Profile -Value $profileContent

& "$PWD\WindowsTerminal\fix warning screen reader for powershell.ps1"
