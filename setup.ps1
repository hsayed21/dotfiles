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

# Current Directory Path
$currentPath = (Get-Location).Path

# ================================================
# Install Necessary Packages
# ================================================
$scoop_packages = @("git", "python", "concfg", "sudo", "curl", "lazygit", "fzf", "ripgrep", "zig", "pwsh")
foreach ($pkg in $scoop_packages) {
    Install-ScoopPackage -packageName $pkg
}

$winget_packages = @("JanDeDobbeleer.OhMyPosh","Microsoft.PowerToys", "Microsoft.WindowsTerminal", "Microsoft.VisualStudioCode", "Google.Chrome", "Mozilla.Firefox")
foreach ($pkg in $winget_packages) {
    Install-WingetPackage -packageName $pkg
}

# $choco_packages = @("dotnet-sdk")
$choco_packages = @()
foreach ($pkg in $choco_packages) {
    Install-ChocoPackage -packageName $pkg
}

# ================================================
# Configuration
# ================================================
# nvim
Create-SymbolicLink -linkPath "$Env:LOCALAPPDATA\nvim" -targetPath ($currentPath + "\nvim")

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

# vscode
Create-SymbolicLink -linkPath "$Env:APPDATA\Code\User\settings.json" -targetPath ($currentPath + "\vscode\settings.json")
Create-SymbolicLink -linkPath "$Env:APPDATA\Code\User\keybindings.json" -targetPath ($currentPath + "\vscode\keybindings.json")
Create-SymbolicLink -linkPath "$Env:APPDATA\Code\User\snippets" -targetPath ($currentPath + "\vscode\snippets")
# Create-SymbolicLink -linkPath "$Env:APPDATA\Code\User\extensions.json" -targetPath ($currentPath + "\vscode\extensions.json")
Create-SymbolicLink -linkPath "$Home\.vscode\extensions\extensions.json" -targetPath ($currentPath + "\vscode\extensions.json")

# vs2022
& "$Env:ProgramFiles\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe" /ResetSettings ($currentPath + "\VS2022\VS2022_Config.vssettings")
Show-SuccessMessage -Message "VS2022 Settings has been Restored successfully."

# lazygit
Create-SymbolicLink -linkPath "$Env:LOCALAPPDATA\lazygit\config.yml" -targetPath ($currentPath + "\lazygit\config.yml")

# ShareX
Create-SymbolicLink -linkPath "$Home\Documents\ShareX\ApplicationConfig.json" -targetPath ($currentPath + "\ShareX\ApplicationConfig.json")
Create-SymbolicLink -linkPath "$Home\Documents\ShareX\HotkeysConfig.json" -targetPath ($currentPath + "\ShareX\HotkeysConfig.json")

# Everything
Create-SymbolicLink -linkPath "$Env:APPDATA\Everything\Everything.ini" -targetPath ($currentPath + "\Everything\Everything.ini")
Create-SymbolicLink -linkPath "$Env:APPDATA\Everything\Filters.csv" -targetPath ($currentPath + "\Everything\Filters.csv")

# OBS
Create-SymbolicLink -linkPath "$Env:APPDATA\obs-studio\basic\scenes\recording.json" -targetPath ($currentPath + "\OBS\scenes\recording.json")
Create-SymbolicLink -linkPath "$Env:APPDATA\obs-studio\basic\profiles\Virtual_Mic" -targetPath ($currentPath + "\OBS\profiles\Virtual_Mic")

# wireshark
Create-SymbolicLink -linkPath "$Env:APPDATA\Wireshark\profiles\MyProfile" -targetPath ($currentPath + "\wireshark\MyProfile")

# elevenclock
Create-SymbolicLink -linkPath "$Home\.elevenclock\CustomClockStrings" -targetPath ($currentPath + "\elevenclock\CustomClockStrings")
Create-SymbolicLink -linkPath "$Home\.elevenclock\PreferredLanguage" -targetPath ($currentPath + "\elevenclock\PreferredLanguage")
Create-SymbolicLink -linkPath "$Home\.elevenclock\CustomClockClickAction" -targetPath ($currentPath + "\elevenclock\CustomClockClickAction")
Create-SymbolicLink -linkPath "$Home\.elevenclock\CustomClockDoubleClickAction" -targetPath ($currentPath + "\elevenclock\CustomClockDoubleClickAction")
Create-SymbolicLink -linkPath "$Home\.elevenclock\ClockFixedHeight" -targetPath ($currentPath + "\elevenclock\ClockFixedHeight")
Create-SymbolicLink -linkPath "$Home\.elevenclock\ClockYOffset" -targetPath ($currentPath + "\elevenclock\ClockYOffset")
Create-SymbolicLink -linkPath "$Home\.elevenclock\ClockXOffset" -targetPath ($currentPath + "\elevenclock\ClockXOffset")
Create-SymbolicLink -linkPath "$Home\.elevenclock\UseCustomFontSize" -targetPath ($currentPath + "\elevenclock\UseCustomFontSize")

# voicemeeter
Create-SymbolicLink -linkPath "$Env:APPDATA\VoiceMeeterBananaDefault.xml" -targetPath ($currentPath + "\VoicemeeterBanana\VoiceMeeterBananaDefault.xml")
Create-SymbolicLink -linkPath "$Home\Documents\Voicemeeter\VoicemeeterBanana_LastSettings.xml" -targetPath ($currentPath + "\VoicemeeterBanana\VoicemeeterBanana_LastSettings.xml")
Create-SymbolicLink -linkPath "$Home\Documents\Voicemeeter\MacroButtonConfig.xml" -targetPath ($currentPath + "\VoicemeeterBanana\MacroButtonConfig.xml")

# ExplorerPatcher
reg import ($currentPath + "\ExplorerPatcher\ExplorerPatcher_22621.1413.54.5.reg") *>&1 | Out-Null
Show-SuccessMessage -Message "ExplorerPatcher Settings has been Restored successfully."

# dbForge
Create-SymbolicLink -linkPath "$Env:ProgramData\Devart\dbForge Studio for SQL Server\Snippets" -targetPath ($currentPath + "\dbForge\SQL Server\Snippets")
Create-SymbolicLink -linkPath "$Env:ProgramData\Devart\dbForge Studio for PostgreSQL\Snippets" -targetPath ($currentPath + "\dbForge\PostgreSQL\Snippets")
Create-SymbolicLink -linkPath "$Env:ProgramData\Devart\dbForge Studio for MySQL\Snippets" -targetPath ($currentPath + "\dbForge\MySQL\Snippets")
Create-SymbolicLink -linkPath "$Env:APPDATA\Devart\dbForge Studio for SQL Server\ShortcutSchemes\Default.xml" -targetPath ($currentPath + "\dbForge\SQL Server\Keybinding_Default.xml")
Create-SymbolicLink -linkPath "$Env:APPDATA\Devart\dbForge Studio for PostgreSQL\ShortcutSchemes\Default.xml" -targetPath ($currentPath + "\dbForge\PostgreSQL\Keybinding_Default.xml")
Create-SymbolicLink -linkPath "$Env:APPDATA\Devart\dbForge Studio for MySQL\ShortcutSchemes\Default.xml" -targetPath ($currentPath + "\dbForge\MySQL\Keybinding_Default.xml")

# git
Create-SymbolicLink -linkPath "$Home\git\.gitconfig-work" -targetPath ($currentPath + "\git\.gitconfig-work")
Create-SymbolicLink -linkPath "$Home\git\.gitconfig" -targetPath ($currentPath + "\git\.gitconfig")

# WindowsTerminal
Create-SymbolicLink -linkPath "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -targetPath ($currentPath + "\WindowsTerminal\settings.json")
concfg import ($currentPath + "\WindowsTerminal\concfg.json")
Copy-Item -Path ($currentPath + "\WindowsTerminal\kali.theme.json") -Destination $Env:LOCALAPPDATA\kali.theme.json -Force
$profileContent = @"
oh-my-posh init pwsh --config '$Env:LOCALAPPDATA\kali.theme.json' | Invoke-Expression
`$PSStyle.FileInfo.Directory = "`e[33m"
"@
Set-Content -Path $Profile -Value $profileContent

& ($currentPath + "\WindowsTerminal\fix warning screen reader for powershell.ps1")
