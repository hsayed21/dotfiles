---
paths:
  - "**/*.ahk"
  - "**/*.ah2"
---

# AutoHotkey v2 Patterns

## Window Management

```autohotkey
class WindowManager {
    static ToggleWindow(title, processPath) {
        if WinExist(title) {
            hwnd := WinGetID(title)
            if WinActive("ahk_id " . hwnd) {
                WinMinimize("ahk_id " . hwnd)
            } else {
                WinActivate("ahk_id " . hwnd)
            }
        } else {
            Run(processPath)
            WinWait(title, , 5)
            WinActivate(title)
        }
    }

    ; Position window to specific monitor
    static MoveToMonitor(title, monitorIndex) {
        MonitorGetWorkArea(monitorIndex, &left, &top, &right, &bottom)
        WinMove(left, top, right - left, bottom - top, title)
        WinActivate(title)
    }
}
```

## Clipboard Manipulation

```autohotkey
class ClipboardTools {
    ; Save and restore clipboard (critical for any clipboard manipulation)
    static Transform(fn) {
        saved := ClipboardAll()
        A_Clipboard := ""  ; Clear
        SendInput("^c")
        if !ClipWait(2) {
            A_Clipboard := saved
            return
        }
        result := fn(A_Clipboard)
        if result != "" {
            A_Clipboard := result
            SendInput("^v")
        }
        Sleep(100)
        A_Clipboard := saved
    }
}

; Usage: uppercase selection
^!u::ClipboardTools.Transform((text) => StrUpper(text))
```

## HOTKEY Manager (multi-key sequences)

```autohotkey
class HotkeyManager {
    static sequences := Map()

    static Register(keys, callback) {
        this.sequences[keys] := callback
        Hotkey(keys, (*) => callback())
        return this
    }

    static EnableAll() {
        for keys in this.sequences {
            Hotkey(keys, "On")
        }
    }

    static DisableAll() {
        for keys in this.sequences {
            Hotkey(keys, "Off")
        }
    }
}
```

## Tray Menu Pattern

```autohotkey
; Create a proper tray menu for persistent scripts
Persistent(true)

A_TrayMenu.Delete()
A_TrayMenu.Add("Show Window", (*) => ShowMainWindow())
A_TrayMenu.Add()
A_TrayMenu.Add("Settings", (*) => OpenSettings())
A_TrayMenu.Add("Reload Script", (*) => Reload())
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Show Window"

A_IconTip := "MyTool v" . VERSION
```

## Config File Pattern (INI)

```autohotkey
class Config {
    filePath := A_ScriptDir . "\settings.ini"

    Load() {
        if !FileExist(this.filePath) {
            return { theme: "dark", fontSize: 12 }
        }
        return {
            theme: IniRead(this.filePath, "UI", "theme", "dark"),
            fontSize: Integer(IniRead(this.filePath, "UI", "fontSize", 12))
        }
    }

    Save(settings) {
        IniWrite(settings.theme, this.filePath, "UI", "theme")
        IniWrite(settings.fontSize, this.filePath, "UI", "fontSize")
    }
}
```

## GUI Pattern

```autohotkey
class SettingsGui {
    settings := {}

    Show(currentSettings) {
        this.settings := currentSettings.Clone()
        gui := Gui(, "Settings")
        gui.SetFont("s10")

        gui.AddText(, "Theme:")
        themeDDL := gui.AddDropDownList("vTheme Choose" . (this.settings.theme = "dark" ? 1 : 2),
            ["dark", "light"])

        gui.AddText("xm", "Font Size:")
        fontSizeEdit := gui.AddEdit("vFontSize Number Limit2",
            this.settings.fontSize)

        gui.AddButton("Default w80", "OK").OnEvent("Click", (*) =>
            this.Save(gui, themeDDL, fontSizeEdit))

        gui.AddButton("x+m w80", "Cancel").OnEvent("Click", (*) => gui.Destroy())
        gui.Show()
    }

    Save(gui, themeDDL, fontSizeEdit) {
        this.settings.theme := themeDDL.Text
        this.settings.fontSize := Integer(fontSizeEdit.Text)
        gui.Destroy()
        ; callback to parent
    }
}
```
