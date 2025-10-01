#Requires AutoHotkey >=2.0-

#SingleInstance Off
#NoTrayIcon ;Suggested
LibConDebug := 1 ;let the user know about errors

#Include _setup\Classes\\PackageManagers.ahk
#Include _setup\Classes\FileSystemManager.ahk
#Include _setup\Classes\InstallationStats.ahk
#Include _setup\Classes\PackageInstaller.ahk
#Include _setup\Classes\SpecializedHandlers.ahk
#Include _setup\Classes\Console.ahk
#Include _setup\Config\SetupConfig.ahk

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
        ; Initialize package installer
        this.PackageInstaller := PackageInstaller()
        ; Initialize dotfile mapper
        mappings := SetupConfig.GetMappings()
        this.DotfileMapper := DotfileMapper(mappings)
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


    /**
     * Main execution method with enhanced feedback
     */
    Run() {

        ; Console.Instance.ShowSection("Starting Dotfiles Setup")
        startTime := A_TickCount

        try {
            ; Setup package managers
            this.PackageInstaller.SetupPackageManagers()

            ; Install packages
            this.PackageInstaller.InstallPackages()

            ; Configure PowerShell
            PowerShellModuleManager.InstallModules()

            ; Install VS Code extensions
            VSCodeExtensionsManager.InstallExtensions()

            ; Mapping (symbolic links)
            this.DotfileMapper.ProcessMappings()

            ; Apply registry settings & windows tweaks
            RegistryManager.RunAll()

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
}

try {
    setup := DotfilesSetup()

    ; Require elevation for system operations
    if (!A_IsAdmin) {
        try {
           setup.RunAhkAsAdmin()
        } catch as err {
            MsgBox("This script requires administrator privileges to run properly.`n`nError: " . err.Message,
                "Administrator Required", "Icon!")
        }
        ExitApp()
    }

    setup.Run()
} catch as err {
    MsgBox("Setup failed with error:`n`n" . err.Message, "Setup Error", "Icon!")
}
Pause()
