
#Requires AutoHotkey >=2.0-

; #SingleInstance Off
; #NoTrayIcon ;Suggested
; LibConDebug := 1 ;let the user know about errors

#Include "..\libs\LibCon.ahk"

class Console {
    static _Instance := ""
    currentProgress := 0
    maxProgress := 100
    progressBarWidth := 50

    static Colors := {
        Info: White,
        Success: Green,
        Warning: Yellow,
        Error: Red,
        Progress: Cyan,
        Section: Magenta,
        Command: Gray
    }

    static Instance {
        get {
            if (!this._Instance) {
                this._Instance := Console()
            }
            return this._Instance
        }
    }

    __New() {
        SmartStartConsole()
        ; ClearScreen()
        this.ShowWelcome()
    }

    ShowWelcome() {
        SetFgColor(Console.Colors.Section)
        puts("╔══════════════════════════════════════════════════════════════╗")
        puts("║                      AutoHotkey Setup Console                ║")
        puts("║                    Enhanced User Experience                  ║")
        puts("╚══════════════════════════════════════════════════════════════╝")
        SetFgColor(Console.Colors.Info)
        NewLine(1)
    }

    WriteColored(text, color := "", newLine := true) {
        if (color && Console.Colors.HasProp(color)) {
            SetFgColor(Console.Colors.%color%)
        }

        if (newLine) {
            puts(text)
        } else {
            print(text)
        }

        if (color) {
            SetFgColor(Console.Colors.Info)
        }
    }

    ShowSection(title) {
        NewLine(1)
        SetFgColor(Console.Colors.Section)
        borderLength := StrLen(title) + 4
        border := ""
        Loop borderLength {
            border .= "═"
        }
        puts("╔" . border . "╗")
        puts("║  " . title . "  ║")
        puts("╚" . border . "╝")
        SetFgColor(Console.Colors.Info)
        NewLine(1)
    }

    ShowSuccess(message) {
        this.WriteColored("✅ " . message, "Success")
        this.PlaySound("success")
    }

    ShowInfo(message) {
        this.WriteColored("ℹ️  " . message, "Info")
    }

    ShowWarning(message) {
        this.WriteColored("⚠️  " . message, "Warning")
        this.PlaySound("warning")
    }

    ShowError(message) {
        this.WriteColored("❌ " . message, "Error")
        this.PlaySound("error")
    }

    ShowCommand(command, description := "") {
        if (description) {
            this.WriteColored("🔄 " . description, "Progress")
        }
        SetFgColor(Cyan)
        this.WriteColored("   ➤ " . command, "Command")
        SetFgColor(White)
    }

    Run(command, description := "", &output := "") {
        this.ShowCommand(command, description)
        return RunCommand(command,, &output)
    }

    RunSilent(command, &output := "") {
        return RunCommandSilent(command, , &output)
    }

    RunPowerShellSilent(command, &output := "") {
        return RunPowerShellSilent(command,, &output)
    }

    RunPowerShellFile(command, &output := "") {
        return RunPowerShellFile(command,, &output)
    }

    InitProgress(maxSteps, title := "Progress") {
        this.maxProgress := maxSteps
        this.currentProgress := 0
        this.WriteColored("📊 " . title . " (0/" . maxSteps . ")", "Progress")
    }

    UpdateProgress(step := 1, message := "") {
        this.currentProgress += step
        percent := Round((this.currentProgress / this.maxProgress) * 100)
        progressBar := sProgressBar(this.progressBarWidth, this.currentProgress, this.maxProgress)

        SetFgColor(Console.Colors.Progress)
        if (message) {
            puts("   " . message . " (" . this.currentProgress . "/" . this.maxProgress . ")")
        }
        puts("   " . progressBar . " " . percent . "%")
        SetFgColor(Console.Colors.Info)
    }

    CompleteProgress(message := "All tasks completed successfully! 🎉") {
        this.currentProgress := this.maxProgress
        this.UpdateProgress(0, message)
        this.PlaySound("complete")
        NewLine(1)
    }

    AskConfirmation(message, defaultYes := true) {
        SetFgColor(Console.Colors.Warning)
        puts("❓ " . message . " " . (defaultYes ? "[Y/n]" : "[y/N]") . ": ")
        SetFgColor(Console.Colors.Info)

        input := ""
        gets(&input)
        input := Trim(StrLower(input))

        result := (input = "") ? defaultYes : (input = "y" || input = "yes")
        this.WriteColored("   → " . (result ? "Yes" : "No"), result ? "Success" : "Warning")
        return result
    }

    GetInput(prompt, defaultValue := "") {
        SetFgColor(Console.Colors.Info)
        defaultText := defaultValue ? " [" . defaultValue . "]" : ""
        puts("📝 " . prompt . defaultText . ": ")

        input := ""
        gets(&input)
        input := Trim(input)
        result := input ? input : defaultValue

        if (result) {
            this.WriteColored("   → " . result, "Success")
        }
        return result
    }

    ShowList(items, title := "") {
        if (title) {
            this.WriteColored("📋 " . title, "Info")
        }
        for index, item in items {
            this.WriteColored("   " . index . ". " . item, "Info")
        }
        NewLine(1)
    }

    ShowStatus(message, status := "info") {
        switch status {
            case "loading":
                this.WriteColored("⏳ " . message, "Progress")
            case "complete":
                this.WriteColored("✅ " . message, "Success")
            case "pending":
                this.WriteColored("⏸️  " . message, "Warning")
            default:
                this.WriteColored("ℹ️  " . message, "Info")
        }
    }

    WaitForKeypress(message := "Press any key to continue...") {
        SetFgColor(Console.Colors.Warning)
        puts("⏸️  " . message)
        SetFgColor(Console.Colors.Info)

        keyName := ""
        getch(&keyName)
        this.WriteColored("   → Key pressed: " . keyName, "Success")
    }

    PlaySound(type := "info") {
        try {
            switch type {
                case "success", "complete":
                    SoundPlay("*48")
                case "error":
                    SoundPlay("*16")
                case "warning":
                    SoundPlay("*32")
                default:
                    return
            }
        }
    }

    Clear() {
        ; ClearScreen()
    }

    Close() {
        this.WriteColored("👋 Setup completed! Console session ended.", "Success")
        NewLine(1)
        this.WriteColored("Thank you for using AutoHotkey Setup Console! 🚀", "Info")
        pause(2)
        FreeConsole()
    }
}

; Console.Instance.WriteColored("Console initialized.", "Info")
; Pause(1)
