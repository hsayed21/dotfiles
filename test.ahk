; #Include "ahk-setup\Classes\FileSystemManager.ahk"

; FileSystemManager.CreateSymbolicLink("C:\Users\hsayed\Desktop\source\source.txt", "C:\target.txt", true)

; exmaple registry operations
; RegWrite("1", "REG_DWORD", "HKEY_CURRENT_USER\Software\MyApp", "TestValue")

msgbox(EnvGet("LOCALAPPDATA"))
