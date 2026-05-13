---
paths:
  - "**/*.ahk"
  - "**/*.ah2"
---

# AutoHotkey v2 Coding Style

> AutoHotkey v2 is a breaking change from v1. All code here assumes **AHK v2** syntax.

## v2 Fundamentals

```autohotkey
; AHK v2 — always use #Requires
#Requires AutoHotkey v2.0

; Variables: expressions by default (no % needed)
name := "John"
count := 42
isActive := true

; Functions everywhere (v2 removes command syntax)
MsgBox("Hello, " . name)
SendInput("{Ctrl down}c{Ctrl up}")

; Objects and arrays
config := { debug: true, timeout: 5000 }
items := ["one", "two", "three"]
```

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Variables | camelCase | `userName`, `maxRetries` |
| Functions | PascalCase | `GetWindowTitle()`, `ParseConfig()` |
| Classes | PascalCase | `WindowManager`, `ClipboardMonitor` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT` |
| Hotkeys | Descriptive labels | `^!t` not bare `F1` without comment |

## Hotkeys & Hotstrings

```autohotkey
; Named hotkeys (preferred — easier to manage than bare labels)
^!t:: {
    MsgBox("Ctrl+Alt+T pressed")
}

; Context-sensitive hotkeys (only in specific windows)
#HotIf WinActive("ahk_class Notepad")
^s:: {
    SendInput("^s")
    MsgBox("File saved!")
}
#HotIf  ; Reset context

; Hotstrings with options
:*:btw::by the way        ; * = no end character needed
::@@::myemail@domain.com  ; Plain hotstring
:*?B0:ahk::AutoHotkey     ; ? = inside words, B0 = no backspace
```

## Functions

```autohotkey
; Always declare functions with clear names and parameters
GetWindowInfo(hwnd) {
    if !WinExist("ahk_id " . hwnd) {
        return false
    }
    title := WinGetTitle("ahk_id " . hwnd)
    class := WinGetClass("ahk_id " . hwnd)
    return { title: title, class: class }
}

; Use default parameters
RunCommand(cmd, workDir := A_WorkingDir, hide := false) {
    opts := hide ? "Hide" : ""
    return RunWait(cmd, workDir, opts)
}
```

## Error Handling

```autohotkey
; Always check for errors on file and system operations
try {
    content := FileRead(configPath)
} catch as err {
    MsgBox("Failed to read config: " . err.Message, "Error", "Icon!")
    return
}

; Validate inputs
SetVolume(level) {
    if !IsInteger(level) || level < 0 || level > 100 {
        throw ValueError("Volume must be 0-100")
    }
    SoundSetVolume(level)
}
```

## Immutability (for shared state)

```autohotkey
; BAD: mutating shared global
global config := Map()
config["theme"] := "dark"

; GOOD: create copy, don't mutate original
UpdateConfig(oldConfig, key, value) {
    newConfig := oldConfig.Clone()
    newConfig[key] := value
    return newConfig
}
```

## Script Organization

```autohotkey
#Requires AutoHotkey v2.0

; 1. Includes
#Include "lib\WindowUtils.ahk"
#Include "lib\ClipboardUtils.ahk"

; 2. Configuration
APP_NAME := "MyTool"
VERSION := "2.0.0"

; 3. Hotkeys (with comments)
^!t::ShowMainWindow()    ; Toggle main window
^!c::ProcessClipboard()  ; Transform clipboard content

; 4. Functions
ShowMainWindow() {
    ; ...
}
```

## Logging

```autohotkey
; Simple file logger
Log(level, message) {
    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    line := Format("[{1}] {2}: {3}`n", timestamp, level, message)
    try FileAppend(line, A_ScriptDir . "\app.log")
}
```
