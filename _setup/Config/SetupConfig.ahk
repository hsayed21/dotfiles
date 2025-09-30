/**
 * Configuration management for the AutoHotkey dotfiles setup system
 * Defines packages, mappings, and environment settings
 */
class SetupConfig {
    /**
     * Get package configurations organized by category
     * @returns {Map} Package configurations by category
     */
    static GetPackages() {
        packages := Map()

        ; Development packages
        packages["Development"] := Map(
            "Scoop", [
                { name: "python" }
            ],
            "Winget", [
                { name: "Microsoft.VisualStudioCode" },
                { name: "Microsoft.WindowsTerminal" },
                { id: "Neovim.Neovim.Nightly" },
                { id: "GitHub.cli" },
                { id: "Git.Git" }
            ],
            "Chocolatey", [
                { name: "dotnet-sdk" },
                { name: "delta" }
            ]
        )

        ; Utilities packages
        packages["Utilities"] := Map(
            "Scoop", [
                { name: "sudo" },
                { name: "curl" },
                { name: "pwsh" },
                { name: "concfg" },
                { name: "extras/unigetui" },
                { name: "zig" },
                { name: "Scoop-Search" },
                { name: "extras/everythingtoolbar" }
            ],
            "Winget", [
                { name: "Microsoft.PowerToys" },
                { name: "JanDeDobbeleer.OhMyPosh" },
                { name: "GlazeWM" },
                { name: "Zebar" },
                { id: "VB-Audio.Voicemeeter.Potato" },
                { id: "7zip.7zip" },
                { id: "ShareX.ShareX" },
                { id: "wez.wezterm" }
            ],
            "Chocolatey", [
                { name: "flow-launcher" },
                { name: "winspy" },
                { name: "wingetui" },
                { name: "nircmd" },
                { name: "everything" },
                { name: "wget" },
                { name: "smartsystemmenu" },
                { name: "ffmpeg" },
                { name: "fzf" },
                { name: "ripgrep" },
                { name: "bat" },
                { name: "grep" },
                { name: "sublimetext4" },
                { name: "yasb" },
                { name: "translucenttb" }
            ],
            "SourceForge", [
                { project: "globonote/files/globonote", file: "globonote-setup.exe"}
            ]
        )

        ; Browsers packages
        packages["Browsers"] := Map(
            "Winget", [
                { name: "Google.Chrome" },
                { name: "Mozilla.Firefox" },
                { name: "Zen-Team.Zen-Browser" }
            ]
        )

        ; Fonts packages
        packages["Fonts"] := Map(
            "Chocolatey", [
                { name: "nerdfont-hack" },
                { name: "nerd-fonts-firacode" },
                { name: "nerd-fonts-jetbrainsmono" },
                { name: "jetbrainsmono" },
                { name: "firacode" },
                { name: "cascadiacode" }
            ],
            "Winget", [
                { name: "Microsoft.CascadiaCode" }
            ]
        )

        return packages
    }

    /**
     * Get symbolic link mappings
     * @returns {Array} Array of mapping objects
     */
    static GetMappings() {
        workingDir := A_WorkingDir
        Home := "C:\Users\" . A_UserName

        ; Ensure A_AppDataCommon is defined (some AHk runtimes/tools may not expose it)
        mappings := [
            ; nvim
            {
                source: workingDir . "\nvim",
                dest: A_AppData . "\..\Local\nvim"
            },
            ; vscode
            {
                source: workingDir . "\vscode\settings.json",
                dest: A_AppData . "\Code - Insiders\User\settings.json"
            },
            {
                source: workingDir . "\vscode\keybindings.json",
                dest: A_AppData . "\Code - Insiders\User\keybindings.json"
            },
            {
                source: workingDir . "\vscode\extensions.json",
                dest: Home . "\.vscode-insiders\extensions\extensions.json"
            },
            {
                source: workingDir . "\vscode\copilot\prompts",
                dest: A_AppData . "\Code - Insiders\User\prompts"
            },
            ; vs2022
            {
                source: workingDir . "\VS2022\CurrentSettings.vssettings",
                dest: A_AppData . "\..\Local\Microsoft\VisualStudio\17.0_*\Settings\CurrentSettings.vssettings"
            },
            ; lazygit
            {
                source: workingDir . "\lazygit\config.yml",
                dest: A_AppData . "\..\Local\lazygit\config.yml"
            },
            ; ShareX
            {
                source: workingDir . "\ShareX\ApplicationConfig.json",
                dest: Home . "\ShareX\ApplicationConfig.json"
            },
            {
                source: workingDir . "\ShareX\HotkeysConfig.json",
                dest: Home . "\ShareX\HotkeysConfig.json"
            },
            ; Everything
            {
                source: workingDir . "\Everything\Everything.ini",
                dest: A_AppData . "\Everything\Everything.ini"
            },
            {
                source: workingDir . "\Everything\Filters.csv",
                dest: A_AppData . "\Everything\Filters.csv"
            },
            ; OBS
            {
                source: workingDir . "\OBS\basic",
                dest: A_AppData . "\obs-studio\basic"
            },
            ; wireshark
            {
                source: workingDir . "\wireshark\MyProfile",
                dest: A_AppData . "\Wireshark\profiles\MyProfile"
            },
            ; elevenclock
            {
                source: workingDir . "\elevenclock\CustomClockStrings",
                dest: Home . "\.elevenclock\CustomClockStrings"
            },
            {
                source: workingDir . "\elevenclock\PreferredLanguage",
                dest: Home . "\.elevenclock\PreferredLanguage"
            },
            {
                source: workingDir . "\elevenclock\CustomClockClickAction",
                dest: Home . "\.elevenclock\CustomClockClickAction"
            },
            {
                source: workingDir . "\elevenclock\CustomClockDoubleClickAction",
                dest: Home . "\.elevenclock\CustomClockDoubleClickAction"
            },
            {
                source: workingDir . "\elevenclock\ClockFixedHeight",
                dest: Home . "\.elevenclock\ClockFixedHeight"
            },
            {
                source: workingDir . "\elevenclock\ClockYOffset",
                dest: Home . "\.elevenclock\ClockYOffset"
            },
            {
                source: workingDir . "\elevenclock\ClockXOffset",
                dest: Home . "\.elevenclock\ClockXOffset"
            },
            {
                source: workingDir . "\elevenclock\UseCustomFontSize",
                dest: Home . "\.elevenclock\UseCustomFontSize"
            },
            ; voicemeeter
            {
                source: workingDir . "\VoicemeeterBanana\VoiceMeeterBananaDefault.xml",
                dest: A_AppData . "\VoiceMeeterBananaDefault.xml"
            },
            {
                source: workingDir . "\VoicemeeterBanana\VoicemeeterBanana_LastSettings.xml",
                dest: Home . "\Voicemeeter\VoicemeeterBanana_LastSettings.xml"
            },
            {
                source: workingDir . "\VoicemeeterBanana\MacroButtonConfig.xml",
                dest: Home . "\Voicemeeter\MacroButtonConfig.xml"
            },
            ; EqualizerAPO
            {
                source: workingDir . "\EqualizerAPO\config.txt",
                dest: A_ProgramFiles . "\EqualizerAPO\config\config.txt"
            },
            {
                source: workingDir . "\EqualizerAPO\Mic.txt",
                dest: A_ProgramFiles . "\EqualizerAPO\config\Mic.txt"
            },
            {
                source: workingDir . "\EqualizerAPO\peace.txt",
                dest: A_ProgramFiles . "\EqualizerAPO\config\peace.txt"
            },
            ; dbForge
            {
                source: workingDir . "\dbForge\SQL Server\Snippets",
                dest: A_AppDataCommon . "\Devart\dbForge Studio for SQL Server\Snippets"
            },
            {
                source: workingDir . "\dbForge\PostgreSQL\Snippets",
                dest: A_AppDataCommon . "\Devart\dbForge Studio for PostgreSQL\Snippets"
            },
            {
                source: workingDir . "\dbForge\MySQL\Snippets",
                dest: A_AppDataCommon . "\Devart\dbForge Studio for MySQL\Snippets"
            },
            {
                source: workingDir . "\dbForge\SQL Server\Keybinding_Default.xml",
                dest: A_AppData . "\Devart\dbForge Studio for SQL Server\ShortcutSchemes\Default.xml"
            },
            {
                source: workingDir . "\dbForge\PostgreSQL\Keybinding_Default.xml",
                dest: A_AppData . "\Devart\dbForge Studio for PostgreSQL\ShortcutSchemes\Default.xml"
            },
            {
                source: workingDir . "\dbForge\MySQL\Keybinding_Default.xml",
                dest: A_AppData . "\Devart\dbForge Studio for MySQL\ShortcutSchemes\Default.xml"
            },
            ; git
            {
                source: workingDir . "\git\.gitconfig-work",
                dest: Home . "\git\.gitconfig-work"
            },
            {
                source: workingDir . "\git\.gitconfig",
                dest: Home . "\git\.gitconfig"
            },
            ; WindowsTerminal
            {
                source: workingDir . "\WindowsTerminal\settings.json",
                dest: A_AppData . "\..\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
            },
            {
                source: workingDir . "\WindowsTerminal\Microsoft.PowerShell_profile.ps1",
                dest: A_MyDocuments . "\PowerShell\Microsoft.PowerShell_profile.ps1"
            },
            ; glazewm (tiling window manager for Windows inspired by i3wm)
            {
                source: workingDir . "\.glzr",
                dest: Home . "\.glzr"
            },
            ; AltSnap
            {
                source: workingDir . "\AltSnap\AltSnap.ini",
                dest: EnvGet("UserProfile") . "\scoop\apps\altsnap\1.64\AltSnap.ini"
            },
            ; wezterm
            {
                source: workingDir . "\wezterm\.wezterm.lua",
                dest: Home . "\.wezterm.lua"
            },
            ; FlowLauncher
            {
                source: workingDir . "\FlowLauncher\Settings",
                dest: A_AppData . "\FlowLauncher\Settings"
            },
            ; globonote
            {
                source: workingDir . "\.globonote",
                dest: Home . "\.globonote"
            },
            ; Directory Opus
            {
                source: workingDir . "\DirectoryOpus",
                dest: A_AppData . "\GPSoftware\Directory Opus"
            },
            ; editorconfig
            {
                source: workingDir . "\vscode\.editorconfig",
                dest: Home . "\.editorconfig"
            },
            ; Prettier
            {
                source: workingDir . "\vscode\.prettierrc",
                dest: Home . "\.prettierrc"
            },
            ; yasb
            {
                source: workingDir . "\yasb",
                dest: Home . "\.config\yasb"
            },
            ; Epic Pen
            {
                source: workingDir . "\EpicPen\settings.json",
                dest: A_AppData . "\Epic Pen\settings.json"
            },
            ; Zen Browser
            {
                source: workingDir . "\ZenBrowser\profiles\main.Default\prefs.js",
                dest: A_AppData . "\zen\Profiles\main.Default\prefs.js"
            },
            {
                source: workingDir . "\ZenBrowser\profiles\main.Default\extensions.json",
                dest: A_AppData . "\zen\Profiles\main.Default\extensions.json"
            },
            {
                source: workingDir . "\ZenBrowser\profiles\main.Default\extension-settings.json",
                dest: A_AppData . "\zen\Profiles\main.Default\extension-settings.json"
            },
            {
                source: workingDir . "\ZenBrowser\profiles\main.Default\extension-preferences.json",
                dest: A_AppData . "\zen\Profiles\main.Default\extension-preferences.json"
            },
            {
                source: workingDir . "\ZenBrowser\profiles\main.Default\places.sqlite",
                dest: A_AppData . "\zen\Profiles\main.Default\places.sqlite"
            },
            {
                source: workingDir . "\ZenBrowser\profiles\main.Default\zen-themes.json",
                dest: A_AppData . "\zen\Profiles\main.Default\zen-themes.json"
            },
            {
                source: workingDir . "\ZenBrowser\profiles\main.Default\zen-keyboard-shortcuts.json",
                dest: A_AppData . "\zen\Profiles\main.Default\zen-keyboard-shortcuts.json"
            }
        ]

        return mappings
    }

    /**
     * Get registry file paths for import
     * @returns {Array} Array of registry file paths
     */
    static GetRegistryFiles() {
        workingDir := A_WorkingDir

        return [
            workingDir . "\vscode\vscode contextmenu with profile.reg",
            workingDir . "\ExplorerPatcher\ExplorerPatcher_22621.1413.54.5.reg"
        ]
    }

    /**
     * Get PowerShell modules to install
     * @returns {Array} Array of PowerShell module names
     */
    static GetPowerShellModules() {
        return [
            "CompletionPredictor",
            "PSScriptAnalyzer",
            "ps-color-scripts",
            "Get-ChildItemColor",
            "oh-my-posh",
            "pscolor",
            "posh-ssh",
            "posh-git",
            "Microsoft.WinGet.CommandNotFound"
        ]
    }

    /**
     * Get Windows apps to uninstall
     * @returns {Array} Array of Windows app package names
     */
    static GetAppsToUninstall() {
        return [
            "Microsoft.3DBuilder",
            "AdobeSystemsIncorporated.AdobeCreativeCloudExpress",
            "Microsoft.WindowsAlarms",
            "AmazonVideo.PrimeVideo",
            "*.AutodeskSketchBook",
            "Microsoft.BingFinance",
            "Microsoft.BingNews",
            "Microsoft.BingSports",
            "Microsoft.BingWeather",
            "king.com.BubbleWitch3Saga",
            "Microsoft.WindowsCommunicationsApps",
            "king.com.CandyCrushSodaSaga",
            "Clipchamp.Clipchamp",
            "Microsoft.549981C3F5F10",
            "Disney.37853FC22B2CE",
            "*.DisneyMagicKingdoms",
            "DolbyLaboratories.DolbyAccess",
            "Facebook.Facebook*",
            "Microsoft.MicrosoftOfficeHub",
            "Facebook.Instagram*",
            "Microsoft.WindowsMaps",
            "*.MarchofEmpires",
            "Microsoft.Messaging",
            "Microsoft.OneConnect",
            "Microsoft.Office.OneNote",
            "Microsoft.Paint",
            "Microsoft.People",
            "Microsoft.Print3D",
            "Microsoft.SkypeApp",
            "*.SlingTV",
            "Microsoft.MicrosoftSolitaireCollection",
            "SpotifyAB.SpotifyMusic",
            "Microsoft.MicrosoftStickyNotes",
            "Microsoft.Office.Sway",
            "*.TikTok",
            "*.Twitter",
            "Microsoft.WindowsSoundRecorder",
            "Microsoft.XboxGamingOverlay",
            "Microsoft.GamingApp",
            "Microsoft.YourPhone",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo"
        ]
    }

    /**
     * Get privacy registry settings
     * @returns {Array} Array of registry setting objects
     */
    static GetPrivacySettings() {
        return [
            ; General: Don't let apps use advertising ID
            {
                KeyPath: "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo",
                ValueName: "Enabled",
                ValueData: "0",
                ValueType: "REG_DWORD"
            },
            ; General: Disable Application launch tracking
            {
                KeyPath: "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
                ValueName: "Start-TrackProgs",
                ValueData: "0",
                ValueType: "REG_DWORD"
            },
            ; General: Disable SmartScreen Filter for Store Apps
            {
                KeyPath: "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost",
                ValueName: "EnableWebContentEvaluation",
                ValueData: "0",
                ValueType: "REG_DWORD"
            },
            ; General: Disable key logging & transmission to Microsoft
            {
                KeyPath: "HKCU:\SOFTWARE\Microsoft\Input\TIPC",
                ValueName: "Enabled",
                ValueData: "0",
                ValueType: "REG_DWORD"
            },
            ; General: Opt-out from websites from accessing language list
            {
                KeyPath: "HKCU:\Control Panel\International\User Profile",
                ValueName: "HttpAcceptLanguageOptOut",
                ValueData: "1",
                ValueType: "REG_DWORD"
            }
            ; Add more privacy settings as needed...
        ]
    }

    /**
     * Get console configuration options for LibCon integration
     * @returns {Object} Console configuration object
     */
    static GetConsoleConfig() {
        return {
            ; Console window settings
            title: "AutoHotkey Dotfiles Setup System",
            size: {
                width: 120,
                height: 40
            },

            ; Console behavior settings
            enableColors: true,
            enableProgress: true,
            enableInteraction: true,
            autoScroll: true,

            ; Visual settings
            fontSize: 12,
            backgroundColor: "Black",
            defaultTextColor: "White",

            ; Color scheme for different message types
            colorScheme: {
                info: { color: "White", icon: "ℹ️" },
                success: { color: "Green", icon: "✅" },
                warning: { color: "Yellow", icon: "⚠️" },
                error: { color: "Red", icon: "❌" },
                progress: { color: "Cyan", icon: "🔄" },
                section: { color: "Magenta", icon: "📋" },
                command: { color: "Gray", icon: "➤" }
            },

            ; Progress bar settings
            progressBar: {
                width: 50,
                showPercentage: true,
                showETA: true,
                progressChar: "█",
                emptyChar: "─",
                leftBracket: "[",
                rightBracket: "]"
            },

            ; Interactive settings
            interactive: {
                confirmationTimeout: 30000, ; 30 seconds
                inputTimeout: 60000,         ; 60 seconds
                defaultConfirmation: true,   ; Default to yes
                showHelpText: true,
                pageSize: 20                 ; Lines per page for paged content
            },

            ; Advanced settings
            advanced: {
                enableStatistics: true,
                logConsoleOutput: true,
                clearOnStart: true,
                showWelcomeMessage: true,
                enableKeyboardShortcuts: true,
                enableSpinner: true,
                spinnerFrames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
            }
        }
    }

    /**
     * Get profile-specific console configurations
     * @returns {Map} Map of profile configurations
     */
    static GetConsoleProfiles() {
        profiles := Map()

        ; Compact profile for quick operations
        profiles["compact"] := {
            title: "Quick Setup",
            size: { width: 100, height: 25 },
            fontSize: 10,
            enableProgress: false,
            progressBar: { width: 30 }
        }

        ; Detailed profile for full installations
        profiles["detailed"] := {
            title: "Detailed Installation Progress",
            size: { width: 140, height: 50 },
            fontSize: 11,
            enableProgress: true,
            enableInteraction: true,
            advanced: { enableStatistics: true, showWelcomeMessage: true }
        }

        ; Silent profile for automated runs
        profiles["silent"] := {
            title: "Silent Installation",
            size: { width: 80, height: 20 },
            enableColors: false,
            enableProgress: false,
            enableInteraction: false,
            interactive: { defaultConfirmation: true }
        }

        ; Debug profile for troubleshooting
        profiles["debug"] := {
            title: "Debug Mode - Detailed Logging",
            size: { width: 150, height: 60 },
            fontSize: 9,
            enableColors: true,
            enableProgress: true,
            advanced: {
                enableStatistics: true,
                logConsoleOutput: true,
                showWelcomeMessage: true
            }
        }

        return profiles
    }

    static GetDefaultApps() {
        return  [
            "Microsoft.3DBuilder",
            "AdobeSystemsIncorporated.AdobeCreativeCloudExpress",
            "Microsoft.WindowsAlarms",
            "AmazonVideo.PrimeVideo",
            "*.AutodeskSketchBook",
            "Microsoft.BingFinance",
            "Microsoft.BingNews",
            "Microsoft.BingSports",
            "Microsoft.BingWeather",
            "king.com.BubbleWitch3Saga",
            "Microsoft.WindowsCommunicationsApps",
            "king.com.CandyCrushSodaSaga",
            "Clipchamp.Clipchamp",
            "Microsoft.549981C3F5F10",
            "Disney.37853FC22B2CE",
            "*.DisneyMagicKingdoms",
            "DolbyLaboratories.DolbyAccess",
            "Facebook.Facebook*",
            "Microsoft.MicrosoftOfficeHub",
            "Facebook.Instagram*",
            "Microsoft.WindowsMaps",
            "*.MarchofEmpires",
            "Microsoft.Messaging",
            "Microsoft.OneConnect",
            "Microsoft.Office.OneNote",
            "Microsoft.People",
            "Microsoft.Print3D",
            "Microsoft.SkypeApp",
            "*.SlingTV",
            "Microsoft.MicrosoftSolitaireCollection",
            "SpotifyAB.SpotifyMusic",
            "Microsoft.MicrosoftStickyNotes",
            "Microsoft.Office.Sway",
            "*.TikTok",
            "*.Twitter",
            "Microsoft.WindowsSoundRecorder",
            "Microsoft.XboxGamingOverlay",
            "Microsoft.GamingApp",
            "Microsoft.YourPhone",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo",
        ]
    }
}
