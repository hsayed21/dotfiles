/**
 * Enhanced AutoHotkey v2 Dotfiles Setup System with WinConsole Integration
 * Provides real-time feedback and logging for each step of the setup process
 *
 * Usage:
 *   setup-enhanced.ahk [--package] [--mapping] [--environment] [--all] [--category=Category1,Category2]
 *   setup-enhanced.ahk --console-only  # Show console without auto-starting setup
 */

#Requires AutoHotkey >=2.0-

#SingleInstance Off
#NoTrayIcon ;Suggested
LibConDebug := 1 ;let the user know about errors

RunAhkAsAdmin() {
    full_command_line := DllCall("GetCommandLine", "str")
    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
        try
        {
            if A_IsCompiled
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }
        ExitApp
    }

    ; MsgBox "A_IsAdmin: " A_IsAdmin "`nCommand line: " full_command_line
}

; Require elevation for system operations
if (!A_IsAdmin) {
    try {
        RunAhkAsAdmin()
    } catch as err {
        MsgBox("This script requires administrator privileges to run properly.`n`nError: " . err.Message,
            "Administrator Required", "Icon!")
    }
    ExitApp()
}

; Include all required classes
#Include Classes\PackageManagers.ahk
#Include Classes\FileSystemManager.ahk
#Include Classes\InstallationStats.ahk
#Include Classes\PackageInstaller.ahk
#Include Classes\SpecializedHandlers.ahk
#Include Classes\Console.ahk
#Include Config\SetupConfig.ahk

/**
 * Enhanced setup class with WinConsole integration
 */
class DotfilesSetup {
    ; Components
    PackageInstaller := ""
    DotfileMapper := ""
    Stats := InstallationStats()
    Console := ""

    /**
     * Constructor - Parse command line arguments and initialize console
     */
    __New() {
        this.InitializeComponents()
    }

    /**
     * Initialize components
     */
    InitializeComponents() {
        ; Show initialization progress
        Console.Instance.ShowSection("System Initialization")
        ; Console.Instance.ShowProgress("Initializing package installer...")

        ; Initialize package installer
        this.PackageInstaller := PackageInstaller()

        ; Console.Instance.ShowProgress("Initializing dotfile mapper...")

        ; Initialize dotfile mapper
        ; mappings := SetupConfig.GetMappings()
        ; this.DotfileMapper := DotfileMapper(mappings)

        Console.Instance.ShowSuccess("System components initialized")
    }

    /**
     * Check if array contains value (case-insensitive)
     */
    ArrayContains(Array, Value) {
        for item in Array {
            if (StrLower(item) = StrLower(Value)) {
                return true
            }
        }
        return false
    }

    /**
     * Main execution method with enhanced feedback
     */
    Run() {

        Console.Instance.ShowSection("Starting Dotfiles Setup")
        startTime := A_TickCount

        try {
            ; Setup package managers
            this.PackageInstaller.SetupPackageManagers()

            ; Configure PowerShell
            ; if (this.RunPowerShell) {
            ;     this.ConfigurePowerShell()
            ; }

            ; Install packages
            ; this.PackageInstaller.InstallPackages()

            ; Install VS Code extensions
            ; Console.Instance.ShowSection("VS Code Extensions")
            ; Console.Instance.ShowProgress("Installing VS Code extensions...")
            ; Implementation would go here

            ; Create symbolic links
            ; if (this.RunMappings) {
            ;     this.CreateSymbolicLinks()
            ; }

            ; Apply registry settings
            ; if (this.RunRegistry) {
            ;     this.ApplyRegistrySettings()
            ; }

            ; Generate final report
            elapsedTime := Round((A_TickCount - startTime) / 1000, 1)

            Console.Instance.ShowSection("Setup Complete!")
            Console.Instance.WriteColored("🎉 Dotfiles setup completed successfully!")
            Console.Instance.WriteColored("⏱️  Total time: " . elapsedTime . " seconds")
            Console.Instance.WriteColored("")
            Console.Instance.WriteColored("📋 Summary:")

            ; Display statistics if packages were installed
            ; if (this.RunPackages) {
            ;     Console.Instance.WriteColored("   • Packages: " . this.Stats.GetSuccessCount() . "/" . this.Stats.Total . " successful")
            ; }

            ; Console.Instance.WriteColored("   • Log file: setup.log")
            ; Console.Instance.WriteColored("")
            ; Console.Instance.WriteColored("Press any key or close this window to finish...")

        } catch as err {
            ; Console.Instance.ShowError("Setup failed: " . err.Message)
            throw err
        }
    }

    /**
     * Run Windows configuration
     */
    RunWindowsConfiguration() {
        Console.Instance.Info("Running Windows configuration...")

        windowsScript := A_WorkingDir . "\_helper\windows.ps1"
        if (FileExist(windowsScript)) {
            result := Console.Instance.RunPowerShell('& "' . windowsScript . '"')
            if (result.Success) {
                Console.Instance.Success("Windows configuration completed")
            } else {
                Console.Instance.Error("Windows configuration failed: " . result.StdErr)
            }
        } else {
            Console.Instance.Warning("Windows configuration script not found")
        }
    }

}

; Helper function for string joining
StrJoin(separator, array) {
    result := ""
    for index, item in array {
        if (index > 1) {
            result .= separator
        }
        result .= item
    }
    return result
}

; Create and run the enhanced setup
try {
    setup := DotfilesSetup()
    setup.Run()
} catch as err {
    MsgBox("Setup failed with error:`n`n" . err.Message, "Setup Error", "Icon!")
    ; ExitApp(1)
}
Pause()
