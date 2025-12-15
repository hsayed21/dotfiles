; #Include "ahk-setup\Classes\FileSystemManager.ahk"

; FileSystemManager.CreateSymbolicLink("C:\Users\hsayed\Desktop\source\source.txt", "C:\target.txt", true)

; exmaple registry operations
; RegWrite("1", "REG_DWORD", "HKEY_CURRENT_USER\Software\MyApp", "TestValue")

#Include _setup\Classes\FileSystemManager.ahk

/**
 * Get symbolic link mappings
 * @returns {Array} Array of mapping objects
 */
GetMappings() {
    workingDir := A_WorkingDir
    Home := "C:\Users\" . A_UserName
    LocalAppData := EnvGet("LOCALAPPDATA")

    ; Ensure A_AppDataCommon is defined (some AHk runtimes/tools may not expose it)
    mappings := [{
        source: workingDir . "\Git\.gitconfig",
        dest: Home . "\.gitconfig"
    }, {
        source: workingDir . "\Git\.gitconfig-work",
        dest: Home . "\.gitconfig-work"
    },
    ]

    return mappings
}

dot := DotfileMapper(GetMappings())
dot.ProcessMappings()
