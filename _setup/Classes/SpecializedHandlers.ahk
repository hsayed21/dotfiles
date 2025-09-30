#Include Console.ahk
#Include ..\Config\SetupConfig.ahk
#Include RegistryHelper.ahk

/**
 * PowerShell Module Manager
 */
class PowerShellModuleManager {
    static IsModuleInstalled(ModuleName) {
        res := Console.Instance.RunPowerShellSilent("Get-Module -ListAvailable -Name '" . ModuleName . "'", &output)
        if (res && InStr(StrLower(output), StrLower(ModuleName))) {
            return true
        }

        return false
    }
    ; static InstallModules(ModuleName, Method := "Module") {
    static InstallModules() {

        Console.Instance.ShowSection("PowerShell Modules & Profile")
        psModules := SetupConfig.GetPowerShellModules()
        for idx, module in psModules {
            if (this.IsModuleInstalled(module)) {
                Console.Instance.ShowWarning("PowerShell module already installed: " . module)
                continue
            }

            Console.Instance.ShowStatus("Installing PowerShell module: " . module, "loading")
            res := Console.Instance.RunPowerShellSilent('Install-Module -Name "' . module .
                '" -AcceptLicense -Scope CurrentUser -Force -AllowClobber -Confirm:$false')
            if (res) {
                Console.Instance.ShowSuccess("Installed PowerShell module: " . module)
            } else {
                Console.Instance.ShowWarning("PowerShell module already installed or failed: " . module)
            }
        }

        ; Import concfg and copy theme
        Console.Instance.RunPowerShellSilent('concfg import "' . A_WorkingDir . '\\WindowsTerminal\\concfg.json" -y')
        Console.Instance.RunPowerShellSilent('Copy-Item -Path "' . A_WorkingDir .
            '\\WindowsTerminal\\kali.theme.json" -Destination $Env:LOCALAPPDATA\\kali.theme.json -Force')
        Console.Instance.RunPowerShellFile(A_WorkingDir .
            '\WindowsTerminal\fix warning screen reader for powershell.ps1')

        return true
    }
}

/**
 * VSCode Extensions Manager
 * Installs extensions from a list and updates current-vscode-extensions.txt
 */
class VSCodeExtensionsManager {
    static InstallExtensions(extListFile := "vscode/current-vscode-extensions.txt") {
        Console.Instance.ShowSection("VS Code Extensions")
        extFile := A_WorkingDir . "\" . extListFile
        if (!FileExist(extFile)) {
            Console.Instance.ShowWarning("VS Code extensions file list not found: " . extFile)
            return false
        }
        extensions := []
        extLines := FileRead(extFile)
        for line in StrSplit(extLines, [
            "`r",
            "`n"
        ]) {
            ext := Trim(line)
            if (ext != "")
                extensions.Push(ext)
        }
        installed := []
        result := Console.Instance.RunSilent("code-insiders --list-extensions", &codeList)
        if (!result) {
            Console.Instance.ShowWarning("Failed to list installed VS Code extensions. Is 'code-insiders' in PATH?")
            return false
        }

        for line in StrSplit(codeList, [
            "`r",
            "`n"
        ]) {
            ext := Trim(line)
            if (ext != "")
                installed.Push(ext)
        }
        toInstall := []
        for _, ext in extensions {
            found := false
            for _, inst in installed {
                if (StrLower(ext) = StrLower(inst)) {
                    found := true
                    break
                }
            }
            if (!found)
                toInstall.Push(ext)
        }
        if (toInstall.Length = 0) {
            Console.Instance.ShowSuccess("All VS Code extensions are already installed.")
            return true
        }

        for _, ext in toInstall {
            Console.Instance.ShowStatus("Installing VS Code extension: " . ext . "...", "loading")
            result := Console.Instance.RunSilent("code-insiders --install-extension " . ext, &installOut)
            if (result) {
                Console.Instance.ShowSuccess("Installed VS Code extension: " . ext)
            } else {
                Console.Instance.ShowWarning("Failed to install VS Code extension: " . ext . " Error: " . installOut)
            }
        }

        ; Install other extensions from URLs
        this.OtherExtensions()

        return true
    }

    static OtherExtensions() {
        exts := [
            { url: "https://github.com/hsayed21/vscode-fold/releases/download/v1/vscode-fold-1.4.3.vsix", name: "vscode-fold-1.4.3.vsix" },
            { url: "https://github.com/hsayed21/vscode-harpoon/releases/download/v1/vscode-harpoon-1.6.0.vsix", name: "vscode-harpoon-1.6.0.vsix" }
        ]

        tempDir := A_Temp . "\temp_vscode_ext"
        if !DirExist(tempDir)
            DirCreate(tempDir)

        ; using curl to download and install
        for _, ext in exts {
            Console.Instance.ShowStatus("Installing VS Code extension: " . ext.name . "...", "loading")
            tempPath := tempDir . "\" . ext.name
            result := Console.Instance.RunSilent('curl -L -o "' . tempPath . '" "' . ext.url . '"', &curlOut)
            if (!result || !FileExist(tempPath)) {
                Console.Instance.ShowWarning("Failed to download VS Code extension: " . ext.name . " Error: " . curlOut)
                continue
            }
            result := Console.Instance.RunSilent('code-insiders --install-extension "' . tempPath . '"', &installOut)
            if (result) {
                Console.Instance.ShowSuccess("Installed VS Code extension: " . ext.name)
            } else {
                Console.Instance.ShowWarning("Failed to install VS Code extension: " . ext.name . " Error: " . installOut)
            }
            FileDelete(tempPath)
        }

        DirDelete(tempDir, 1)

        return true
    }
}

/**
 * Windows Features Manager
 */
class WindowsFeaturesManager {

    /**
     * Helper: Set a Windows feature on/off
     */
    static SetFeature(featureName, enable) {
        console := Console.Instance
        action := enable ? "Enable" : "Disable"
        console.ShowStatus(action . " Windows feature: " . featureName, "loading")
        command := "dism /online /" . (enable ? "enable" : "disable") . "-feature /featurename:" . featureName .
        " /all /norestart"
        Console.Instance.Run(command, "", &output)
        console.ShowSuccess("Feature " . featureName . " " . (enable ? "enabled" : "disabled"))
        return true
    }

    /**
     * Enable/Disable WSL and Media Player (legacy methods)
     */
    static DisableWSL() {
        return WindowsFeaturesManager.SetFeature("Microsoft-Windows-Subsystem-Linux", false)
    }
    static EnableWSL() {
        return WindowsFeaturesManager.SetFeature("Microsoft-Windows-Subsystem-Linux", true)
    }
    static DisableWindowsMediaPlayer() {
        return WindowsFeaturesManager.SetFeature("WindowsMediaPlayer", false)
    }
}

class RegistryManager {

    /**
     * Configure PowerShell Console and fonts/colors
     */
    static ConfigureConsole() {
        Console.Instance.ShowSection("Configuring Console")
        RegistryHelper.BatchSetRegistry([
            ;# Make 'Source Code Pro' an available Console font
            { path: 'HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Console\\TrueTypeFont', name: '000', value: 'Source Code Pro',
                type: 'REG_SZ' },
            {
                paths: [
                    'HKCU\\Console',
                    'HKCU\\Console\\%SystemRoot%_System32_bash.exe',
                    'HKCU\\Console\\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe',
                    'HKCU\\Console\\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe',
                    'HKCU\\Console\\Windows PowerShell (x86)',
                    'HKCU\\Console\\Windows PowerShell'
                ],
                values: [
                    ;# Name of display font
                    { name: 'FaceName', value: 'Source Code Pro', type: 'REG_SZ' },
                    ;# Font Family: Raster: 0, TrueType: 54
                    { name: 'FontFamily', value: 54 },
                    ;# Boldness of font: Raster=(Normal: 0, Bold: 1), TrueType=(100-900, Normal: 400)
                    { name: 'FontWeight', value: 400 },
                    ;# Dimensions of font character in pixels, not Points: 8-byte; 4b height, 4b width. 0: Auto
                    { name: 'FontSize', value: 0x00110000 }, ;# 17px height x auto width
                    ;# Dimensions of window, in characters: 8-byte; 4b height, 4b width. Max: 0x7FFF7FFF (32767h x 32767w)
                    { name: 'WindowSize', value: 0x002D0078 }, ;# 45h x 120w
                    ;# Dimensions of screen buffer in memory, in characters: 8-byte; 4b height, 4b width. Max: 0x7FFF7FFF (32767h x 32767w)
                    { name: 'ScreenBufferSize', value: 0x0BB80078 }, ;# 3000h x 120w
                    ;# Percentage of Character Space for Cursor: 25: Small, 50: Medium, 100: Large
                    { name: 'CursorSize', value: 100 },
                    ;# Number of commands in history buffer
                    { name: 'HistoryBufferSize', value: 50 },
                    ;# Discard duplicate commands
                    { name: 'HistoryNoDup', value: 1 },
                    ;# Typing Mode: Overtype: 0, Insert: 1
                    { name: 'InsertMode', value: 1 },
                    ;# Enable Copy/Paste using Mouse
                    { name: 'QuickEdit', value: 1 },
                    ;# Background and Foreground Colors for Window: 2-byte; 1b background, 1b foreground; Color: 0-F
                    { name: 'ScreenColors', value: 0x0F },
                    ;# Background and Foreground Colors for Popup Window: 2-byte; 1b background, 1b foreground; Color: 0-F
                    { name: 'PopupColors', value: 0xF0 },
                    ;# Adjust opacity between 30% and 100%: 0x4C to 0xFF -or- 76 to 255
                    { name: 'WindowAlpha', value: 0xF2 }
                ]
            }
        ])
        ; Console.Instance.RunPowerShell(
        ;     'Set-PSReadlineOption -Colors @{"Default"="#e8e8d3";"Comment"="#888888";"Keyword"="#8197bf";"String"="#99ad6a";"Operator"="#c6b6ee";"Variable"="#c6b6ee";"Command"="#8197bf";"Parameter"="#e8e8d3";"Type"="#fad07a";"Number"="#cf6a4c";"Member"="#fad07a";"Emphasis"="#f0a0c0";"Error"="#902020"}'
        ; )
        ;# Remove property overrides from PowerShell and Bash shortcuts
        Console.Instance.RunPowerShell('Reset-AllPowerShellShortcuts; Reset-AllBashShortcuts')
    }
    /**
     * Configure Disk Cleanup (CleanMgr.exe)
     */
    static ConfigureDiskCleanup() {
        Console.Instance.ShowSection("Configuring Disk Cleanup")
        RegistryHelper.BatchSetRegistry([
            {
                paths: [
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Downloaded Program Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Internet Cache Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Old ChkDsk Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\RetailDemo Offline Content",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Setup Log Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Temporary Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Temporary Setup Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Thumbnail Cache",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Update Cleanup",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Windows Defender"
                ],
                values: [
                    { name: 'StateFlags6174', value: 2 }
                ]
            },
            {
                paths: [
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\BranchCache",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Offline Pages Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Previous Installations",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Recycle Bin",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Service Pack Cleanup",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\System error memory dump files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\System error minidump files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Upgrade Discarded Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\User file versions",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Windows Error Reporting Archive Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Windows Error Reporting Queue Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Windows Error Reporting System Archive Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Windows Error Reporting System Queue Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Windows Error Reporting Temp Files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Windows ESD installation files",
                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VolumeCaches\\Windows Upgrade Log Files"
                ],
                values: [
                    { name: 'StateFlags6174', value: 0 }
                ]
            }
        ])
    }
    /**
     * Configure Security and Identity
     */
    static ConfigureSecurityAndPrivacy() {
        Console.Instance.ShowSection("Configuring System Security & Privacy")

        RegistryHelper.BatchSetRegistry([
            ;# General: Don't let apps use advertising ID for experiences across apps: Allow: 1, Disallow: 0
            {
                path: 'HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AdvertisingInfo',
                value: { name: 'Enabled', value: 0 }
            },
            ;# General: Disable Application launch tracking: Enable: 1, Disable: 0
            {
                path: 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced',
                value: { name: 'Start-TrackProgs', value: 0 }
            },
            ;# General: Disable SmartScreen Filter for Store Apps: Enable: 1, Disable: 0
            {
                path: 'HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppHost',
                value: { name: 'EnableWebContentEvaluation', value: 0 }
            },
            ;# General: Disable key logging & transmission to Microsoft: Enable: 1, Disable: 0
            ;# Disabled when Telemetry is set to Basic
            {
                path: 'HKCU\\SOFTWARE\\Microsoft\\Input\\TIPC',
                value: { name: 'Enabled', value: 0 }
            },
            ;# General: Opt-out from websites from accessing language list: Opt-in: 0, Opt-out 1
            {
                path: 'HKCU\\Control Panel\\International\\User Profile',
                value: { name: 'HttpAcceptLanguageOptOut', value: 1 }
            },
            {
                paths: [
                    'HKLM\\SOFTWARE\\Microsoft\Windows\CurrentVersion\SmartGlass'
                ],
                values: [
                    ;# General: Disable SmartGlass: Enable: 1, Disable: 0
                    { name: 'UserAuthPolicy', value: 0 },
                    ;# General: Disable SmartGlass over BlueTooth: Enable: 1, Disable: 0
                    { name: 'BluetoothPolicy', value: 0 }
                ]
            },
            {
                paths: [
                    'HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager'
                ],
                values: [
                    ;# General: Disable suggested content in settings app: Enable: 1, Disable: 0
                    { name: 'SubscribedContent-338393Enabled', value: 0 },
                    { name: 'SubscribedContent-338394Enabled', value: 0 },
                    { name: 'SubscribedContent-338396Enabled', value: 0 },
                    ;# General: Disable tips and suggestions for welcome and what's new: Enable: 1, Disable: 0
                    { name: 'SubscribedContent-310093Enabled', value: 0 },
                    ;# General: Disable tips and suggestions when I use windows: Enable: 1, Disable: 0
                    { name: 'SubscribedContent-338389Enabled', value: 0 },
                    ;# Start Menu: Disable suggested content: Enable: 1, Disable: 0
                    { name: 'SubscribedContent-338388Enabled', value: 0 }
                ]
            },
            ;# Start Menu: Disable search entries: Enable: 0, Disable: 1
            {
                path: 'HKCU\\Software\\Policies\\Microsoft\\Windows\\Explorer',
                value: { name: 'DisableSearchBoxSuggestions', value: 1 }
            },
            ;# Camera: Don't let apps use camera: Allow, Deny
            {
                path: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam",
                value: { name: "Value", value: "Deny" }
            },
            ;# Microphone: Don't let apps use microphone: Allow, Deny
            {
                path: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone",
                value: { name: "Value", value: "Deny" }
            },
            ;# Notifications: Don't let apps access notifications: Allow, Deny
            {
                path: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener",
                value: { name: "Value", value: "Deny" }
            },
            ;# Speech, Inking, & Typing: Stop "Getting to know me"
            {
                paths: [
                    "HKCU\SOFTWARE\Microsoft\InputPersonalization",
                ],
                values: [
                    {
                        name: "RestrictImplicitTextCollection",
                        value: 1
                    },
                    {
                        name: "RestrictImplicitInkCollection",
                        value: 1
                    }
                ]
            },
            {
                path: "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore",
                value: { name: "HarvestContacts", value: 0 }
            },
            {
                path: "HKCU\SOFTWARE\Microsoft\Personalization\Settings",
                value: { name: "AcceptedPrivacyPolicy", value: 0 }
            },
            {
                path: "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy",
                value: { name: "HasAccepted", value: 0 }
            },
            {
                paths: [
                    ;# Account Info: Don't let apps access name, picture, and other account info: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation",
                    ;# Contacts: Don't let apps access contacts: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts",
                    ;# Calendar: Don't let apps access calendar: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments",
                    ;# Call History: Don't let apps make phone calls: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall",
                    ;# Call History: Don't let apps access call history: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory",
                    ;# Diagnostics: Don't let apps access diagnostics of other apps: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics",
                    ;# Documents: Don't let apps access documents: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary",
                    ;# Downloads: Don't let apps access downloads: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder",
                    ;# Email: Don't let apps read and send email: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email",
                    ;# File System: Don't let apps access the file system: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess",
                    ;# Location: Don't let apps access the location: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location",
                    ;# Messaging: Don't let apps read or send messages (text or MMS): Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat",
                    ;# Music Library: Don't let apps access music library: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary",
                    ;# Pictures: Don't let apps access pictures: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary",
                    ;# Radios: Don't let apps control radios (like Bluetooth): Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios",
                    ;# Screenshot: Don't let apps take screenshots: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic",
                    ;# Screenshot Borders: Don't let apps access screenshot border settings: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder",
                    ;# Tasks: Don't let apps access the tasks: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks",
                    ;# Other Devices: Don't let apps share and sync with non-explicitly-paired wireless devices over uPnP: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync",
                    ;# Videos: Don't let apps access videos: Allow, Deny
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary",
                ],
                values: [
                    { name: "Value", value: "Deny" }
                ]
            }, ,
            ;# Feedback: Windows should never ask for my feedback
            {
                path: "HKCU\SOFTWARE\Microsoft\Siuf\Rules",
                value: { name: "NumberOfSIUFInPeriod", value: 0 }
            },
            ;# Feedback: Telemetry: Send Diagnostic and usage data: Basic: 1, Enhanced: 2, Full: 3
            {
                paths: [
                    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
                ],
                values: [
                    { name: "AllowTelemetry", value: 1 },
                    { name: "MaxTelemetryAllowed", value: 1 }
                ]
            },
            ;# Turn Off Windows Narrator Hotkey: Enable: 1, Disable: 0
            {
                path: 'HKCU\\SOFTWARE\\Microsoft\\Narrator\\NoRoam',
                value: { name: 'WinEnterLaunchEnabled', value: 0 }
            },
            ;# Disable "Window Snap" Automatic Window Arrangement: Enable: 1, Disable: 0
            {
                path: 'HKCU\\Control Panel\\Desktop',
                value: { name: 'WindowArrangementActive', value: 0 }
            },
            {
                paths: [
                    'HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced'
                ],
                values: [
                    ;# Disable automatic fill to space on Window Snap: Enable: 1, Disable: 0
                    { name: 'SnapFill', value: 0 },
                    ;# Disable showing what can be snapped next to a window: Enable: 1, Disable: 0
                    { name: 'SnapAssist', value: 0 },
                    ;# Disable automatic resize of adjacent windows on snap: Enable: 1, Disable: 0
                    { name: 'JointResize', value: 0 }
                ]
            },
            ;# Disable auto-correct: Enable: 1, Disable: 0
            {
                path: 'HKCU\\SOFTWARE\\Microsoft\\TabletTip\\1.7',
                value: { name: 'EnableAutocorrection', value: 0 }
            },
            {
                path: 'HKLM\\SOFTWARE\\Microsoft\\WindowsUpdate\\UX\\Settings',
                values: [
                    ;# Disable automatic reboot after install: Enable: 1, Disable: 0
                    { name: 'IsExpedited', value: 0 },
                    ;# Disable restart required notifications: Enable: 1, Disable: 0
                    { name: 'RestartNotificationsAllowed2', value: 0 },
                    ;# Disable updates over metered connections: Enable: 1, Disable: 0
                    { name: 'AllowAutoWindowsUpdateDownloadOverMeteredNetwork', value: 0 }
                ]
            }
        ])

        ;Windows Defender
        ;# Disable Cloud-Based Protection: Enabled Advanced: 2, Enabled Basic: 1, Disabled: 0
        Console.Instance.RunPowerShell('Set-MpPreference -MAPSReporting 0')
        ;# Disable automatic sample submission: Prompt: 0, Auto Send Safe: 1, Never: 2, Auto Send All: 3
        Console.Instance.RunPowerShell('Set-MpPreference -SubmitSamplesConsent 2')

    }

    /**
     * Configure Devices, Power, and Startup
     */
    static ConfigureDevicesPower() {
        Console.Instance.ShowSection("Configuring Devices, Power, and Startup")
        RegistryHelper.BatchSetRegistry([
            ;# Sound: Disable Startup Sound: Enable: 0, Disable: 1
            {
                paths: [
                    'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System',
                    'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI\\BootAnimation',
                ],
                values: [
                    { name: 'DisableStartupSound', value: 1 }
                ]
            },
            {
                path: 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\EditionOverrides',
                value: { name: 'UserSetting_DisableStartupSound', value: 1 }
            },
            ;# SSD: Disable SuperFetch: Enable: 1, Disable: 0
            {
                path: 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management\\PrefetchParameters',
                value: { name: 'EnableSuperfetch', value: 0 }
            },
            ;# Network: Disable WiFi Sense: Enable: 1, Disable: 0
            {
                path: 'HKLM\\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config',
                value: { name: 'AutoConnectAllowedOEM', value: 0 }
            },
            ;# Enable Custom Background on the Login / Lock Screen
            ;# Background file: C:\someDirectory\someImage.jpg
            ;# File Size Limit: 256Kb
            ; {
            ;     path: "HKLM\Software\Policies\Microsoft\Windows\Personalization",
            ;     value: { name: "LockScreenImage", value: "C:\someDirectory\someImage.jpg" }
            ; },
        ])
        Console.Instance.RunPowerShell('powercfg /hibernate off')
        ; (Optional) Set standby delay, disable WiFi Sense, etc. (commented in .ps1)
    }

    /**
     * Configure Explorer, Taskbar, and System Tray
     */
    static ConfigureExplorerTaskbar() {
        Console.Instance.ShowSection("Configuring Explorer, Taskbar, and System Tray")
        RegistryHelper.BatchSetRegistry([
            {
                paths: [
                    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                ],
                values: [
                    ;# Explorer: Show hidden files by default: Show Files: 1, Hide Files: 2
                    { name: "Hidden", value: 1 },
                    ;# Explorer: Show file extensions by default: Hide: 1, Show: 0
                    { name: "HideFileExt", value: 0 }
                ]
            },
            ;# Explorer: Show path in title bar: Hide: 0, Show: 1
            {
                path: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState",
                value: { name: "FullPath", value: 1 }
            },
            {
                paths: [
                    "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
                ],
                values: [
                    ;# Explorer: Disable creating Thumbs.db files on network volumes: Enable: 0, Disable: 1
                    { name: "DisableThumbnailsOnNetworkFolders", value: 1 },
                    ;# Recycle Bin: Disable Delete Confirmation Dialog: Enable: 1, Disable: 0
                    { name: "ConfirmFileDelete", value: 0 }
                ]
            },
            ;# Taskbar: Hide the Search, Task, Widget, and Chat buttons: Show: 1, Hide: 0
            {
                path: "HKCU\Software\Microsoft\Windows\CurrentVersion\Search",
                value: { name: "SearchboxTaskbarMode", value: 0 }
            },
            {
                paths: [
                    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                ],
                values: [
                    { name: "ShowTaskViewButton", value: 0 }, ; Task View
                    { name: "TaskbarDa", value: 0 }, ; Widgets
                    { name: "TaskbarMn", value: 0 } ; Chat
                ]
            },
            ;# Taskbar: Show colors on Taskbar, Start, and SysTray: Disabled: 0, Taskbar, Start, & SysTray: 1, Taskbar Only: 2
            {
                path: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize",
                value: { name: "ColorPrevalence", value: 1 }
            },
            ;# Titlebar: Disable theme colors on titlebar: Enable: 1, Disable: 0
            {
                path: "HKCU\SOFTWARE\Microsoft\Windows\DWM",
                value: { name: "ColorPrevalence", value: 0 }
            },
        ])

        Console.Instance.RunPowerShell('reg import "' . A_WorkingDir .
            '\\ExplorerPatcher\\ExplorerPatcher_22621.1413.54.5.reg" *>&1 | Out-Null')
    }

    /**
     * Configure Default Windows Applications (uninstall bloatware)
     */
    static ConfigureDefaultApps() {
        Console.Instance.ShowSection("Configuring Default Windows Applications")
        ; List of bloatware removal commands from windows.ps1
        apps := SetupConfig.GetDefaultApps()
        for _, app in apps {
            appId := app
            ; Remove AppxPackage
            Console.Instance.RunPowerShellSilent('Get-AppxPackage "' . appId .
                '" -AllUsers | Remove-AppxPackage -AllUsers')
            ; Remove AppXProvisionedPackage
            Console.Instance.RunPowerShell('Get-AppXProvisionedPackage -Online | Where DisplayName -like "' . appId .
                '" | Remove-AppxProvisionedPackage -Online -AllUsers | Out-Null')
        }

        ; Disable Windows Media Player
        Console.Instance.RunPowerShellSilent(
            'Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null'
        )

        ;# Prevent "Suggested Applications" from returning
        RegistryHelper.BatchSetRegistry([
            {
                paths: [
                    'HKLM\\Software\Policies\Microsoft\Windows\CloudContent'
                ],
                values: [
                    { name: 'DisableWindowsConsumerFeatures', value: 1 } { name: 'DisableCloudOptimizedContent', value: 1 } { name: 'DisableConsumerAccountStateContent',
                        value: 1 }
                ]
            }
        ])
    }

    /**
     * Configure Windows Update & Application Updates
     */
    static ConfigureOtherStuff() {
        Console.Instance.ShowSection("Configuring Other Stuff ")
        ; Opt-In to Microsoft Update (COM object)
        Console.Instance.RunPowerShellSilent(
            '$MU = New-Object -ComObject Microsoft.Update.ServiceManager -Strict; $MU.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") | Out-Null; Remove-Variable MU'
        )

        ; Set Computer Name (example: "hsayed")
        Console.Instance.RunPowerShell('(Get-WmiObject Win32_ComputerSystem).Rename("hsayed") | Out-Null')
        ; Optionally set display name for account (commented in .ps1)
        ; Enable Developer Mode (commented in .ps1)
        ; Console.Instance.RunPowerShell('Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 1')
        ; Disable WSL (can be enabled by EnableWSL)
        Console.Instance.RunPowerShell(
            'Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null'
        )

        ; VS Code context menu
        Console.Instance.RunPowerShell('reg import "' . A_WorkingDir .
            '\\vscode\\vscode contextmenu with profile.reg" *>&1 | Out-Null')



            ; # vs2022
            ; # & "$Env:ProgramFiles\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe" /ResetSettings ($currentPath + "\VS2022\VS2022_Config.vssettings")
            ; # Show-SuccessMessage -Message "VS2022 Settings has been Restored successfully." Show-SuccessMessage -Message "VS2022 Settings has been Restored successfully."
    }

    /**
     * Run all configuration steps in order
     */
    static RunAll() {
        this.ConfigureSecurityAndPrivacy()
        this.ConfigureDevicesPower()
        this.ConfigureExplorerTaskbar()
        this.ConfigureDefaultApps()
        this.ConfigureDiskCleanup()
        this.ConfigureConsole()
        this.ConfigureOtherStuff()
    }

}

/**
 * Environment Variables Manager
 */
class EnvironmentManager {
    static SetVariable(Name, Value, Scope := "User") {
        console := Console.Instance
        console.ShowStatus("Setting environment variable: " . Name . " = " . Value . " (" . Scope . ")", "loading")
        console.ShowSuccess("Environment variable set (simulated)")
        return true
    }
    static GetVariable(Name, Scope := "Process") {
        return ""
    }
    static AddToPath(NewPath, Scope := "User") {
        console := Console.Instance
        console.ShowStatus("Adding to PATH: " . NewPath, "loading")
        console.ShowSuccess("Path updated (simulated)")
        return true
    }
}

/**
 * Git Configuration Manager
 */
class GitConfigManager {
    static SetConfig(Key, Value, IsGlobal := true) {
        console := Console.Instance
        console.ShowStatus("Setting git config: " . Key . " = " . Value, "loading")
        console.ShowSuccess("Git config set (simulated)")
        return true
    }
    static ConfigureUser(Name, Email) {
        return GitConfigManager.SetConfig("user.name", Name) && GitConfigManager.SetConfig("user.email", Email)
    }
    static SetupAliases() {
        console := Console.Instance
        console.ShowStatus("Setting up git aliases", "loading")
        console.ShowSuccess("Git aliases set (simulated)")
        return true
    }
}
