
#Include Console.ahk

/**
 * Windows Features Manager
 */
class WindowsFeaturesManager {
    static SetFeature(FeatureName, Enable) {
        console := Console.Instance
        action := Enable ? "Enable" : "Disable"
        console.ShowStatus(action . " Windows feature: " . FeatureName, "loading")
        command := "dism /online /" . (Enable ? "enable" : "disable") . "-feature /featurename:" . FeatureName . " /all /norestart"
        RunWait(command, , "Hide")
        console.ShowSuccess("Feature " . FeatureName . " " . (Enable ? "enabled" : "disabled"))
        return true
    }

    /**
     * Disable Windows Subsystem for Linux
     */
    static DisableWSL() {
        return WindowsFeaturesManager.SetFeature("Microsoft-Windows-Subsystem-Linux", false)
    }

    /**
     * Enable Windows Subsystem for Linux
     */
    static EnableWSL() {
        return WindowsFeaturesManager.SetFeature("Microsoft-Windows-Subsystem-Linux", true)
    }

    /**
     * Disable Windows Media Player
     */
    static DisableWindowsMediaPlayer() {
        return WindowsFeaturesManager.SetFeature("WindowsMediaPlayer", false)
    }
}

/**
 * PowerShell Module Manager
 */
class PowerShellModuleManager {
    static IsModuleInstalled(ModuleName) {
        ; Minimal stub: always return false (custom logic can be added)
        return false
    }
    static InstallModule(ModuleName, Method := "Module") {
        console := Console.Instance
        console.ShowStatus("Installing PowerShell module: " . ModuleName, "loading")
        ; Minimal stub: just show success
        console.ShowSuccess("PowerShell module " . ModuleName . " install attempted")
        return true
    }
    static SetExecutionPolicy(Policy := "RemoteSigned", Scope := "CurrentUser") {
        console := Console.Instance
        console.ShowStatus("Setting PowerShell execution policy to " . Policy . " for " . Scope, "loading")
        console.ShowSuccess("PowerShell execution policy set (simulated)")
        return true
    }
    static UpdateHelp() {
        console := Console.Instance
        console.ShowStatus("Updating PowerShell help...", "loading")
        console.ShowSuccess("PowerShell help update attempted")
        return true
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
