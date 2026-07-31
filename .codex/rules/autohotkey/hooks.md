---
paths:
  - "**/*.ahk"
  - "**/*.ah2"
---

# AutoHotkey Hooks

> Extends [common/hooks.md](../common/hooks.md)

## Before Editing

- Check for `#Requires AutoHotkey v2.0` at the top — ensure v2 syntax
- If the script uses v1 syntax (`gosub`, legacy commands, `%var%`), flag it

## PostToolUse Hooks

- Verify `#Requires AutoHotkey v2.0` is present
- Check no v1 syntax leaks into v2 scripts
- Ensure `Persistent(true)` is set for any script with hotkeys outside GUI context

## Common Migration Traps (v1 → v2)

| v1 (Legacy) | v2 (Correct) |
|-------------|-------------|
| `MsgBox, text` | `MsgBox("text")` |
| `Send, ^c` | `SendInput("^c")` |
| `var := %expression%` | `var := expression` |
| `StringReplace, out, in, a, b` | `out := StrReplace(in, a, b)` |
| `IfWinActive, title` | `if WinActive(title)` |
| `Gui, Add, Text,, Label` | `gui.AddText(, "Label")` |
| `Gosub, Label` | Call a function instead |
| `#Persistent` | `Persistent(true)` |
