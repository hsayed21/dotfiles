#Include Console.ahk
class InstallationStats {
    Successful := []
    Failed := []
    Skipped := []
    Total := 0

    AddSuccess(PackageName, PackageManager) {
        this.Successful.Push({
            PackageName: PackageName,
            PackageManager: PackageManager,
            Timestamp: A_Now
        })
        this.Total++
    }

    AddFailure(PackageName, PackageManager, Error) {
        this.Failed.Push({
            PackageName: PackageName,
            PackageManager: PackageManager,
            Error: Error,
            Timestamp: A_Now
        })
        this.Total++
    }

    AddSkip(PackageName, PackageManager, Reason) {
        this.Skipped.Push({
            PackageName: PackageName,
            PackageManager: PackageManager,
            Reason: Reason,
            Timestamp: A_Now
        })
        this.Total++
    }

    ProcessResult(Result) {
        switch Result.Status {
            case "Success":
                this.AddSuccess(Result.PackageName, Result.PackageManager)
            case "Failed":
                this.AddFailure(Result.PackageName, Result.PackageManager, Result.Error)
            case "Skipped":
                this.AddSkip(Result.PackageName, Result.PackageManager, Result.Reason)
        }
    }

    GetSuccessCount() {
        return this.Successful.Length
    }

    GetFailCount() {
        return this.Failed.Length
    }

    GetSkipCount() {
        return this.Skipped.Length
    }

    GetSuccessRate() {
        if (this.Total = 0)
            return 0.0
        return (this.GetSuccessCount() / this.Total) * 100
    }

    Reset() {
        this.Successful := []
        this.Failed := []
        this.Skipped := []
        this.Total := 0
    }

    GenerateReport() {
        consoleInstance := Console.Instance
        consoleInstance.ShowSection("Installation Summary")

        consoleInstance.ShowInfo("Total packages: " . this.Total)
        consoleInstance.ShowSuccess("Successfully installed: " . this.GetSuccessCount())
        consoleInstance.ShowError("Failed installations: " . this.GetFailCount())
        consoleInstance.ShowWarning("Skipped installations: " . this.GetSkipCount())

        if (this.Total > 0) {
            consoleInstance.ShowInfo("Success rate: " . Round(this.GetSuccessRate(), 1) . "%")
        }

        if (this.GetSuccessCount() > 0) {
            successList := []
            for item in this.Successful {
                successList.Push(item.PackageName . " (" . item.PackageManager . ")")
            }
            consoleInstance.ShowList(successList, "Successfully Installed")
        }

        if (this.GetFailCount() > 0) {
            failedList := []
            for item in this.Failed {
                errorInfo := item.Error ? " - " . item.Error : ""
                failedList.Push(item.PackageName . " (" . item.PackageManager . ")" . errorInfo)
            }
            consoleInstance.ShowList(failedList, "Failed Installations")
        }

        if (this.GetSkipCount() > 0) {
            skippedList := []
            for item in this.Skipped {
                reasonInfo := item.Reason ? " - " . item.Reason : ""
                skippedList.Push(item.PackageName . " (" . item.PackageManager . ")" . reasonInfo)
            }
            consoleInstance.ShowList(skippedList, "Skipped Installations")
        }
    }

    ExportToJson(FilePath) {
        consoleInstance := Console.Instance
        try {
            statsData := {
                Summary: {
                    Total: this.Total,
                    Successful: this.GetSuccessCount(),
                    Failed: this.GetFailCount(),
                    Skipped: this.GetSkipCount(),
                    SuccessRate: this.GetSuccessRate(),
                    Timestamp: A_Now
                },
                Details: {
                    Successful: this.Successful,
                    Failed: this.Failed,
                    Skipped: this.Skipped
                }
            }

            jsonContent := this.ObjectToJson(statsData)
            FileAppend(jsonContent, FilePath)
            consoleInstance.ShowSuccess("Statistics exported to: " . FilePath)

        } catch as err {
            consoleInstance.ShowError("Failed to export statistics: " . err.Message)
        }
    }

    ObjectToJson(Obj) {
        result := "{"
        first := true

        for key, value in Obj.OwnProps() {
            if (!first)
                result .= ","
            first := false

            result .= '"' . key . '":'

            if (IsObject(value)) {
                if (Type(value) = "Array") {
                    result .= this.ArrayToJson(value)
                } else {
                    result .= this.ObjectToJson(value)
                }
            } else {
                result .= '"' . String(value) . '"'
            }
        }

        result .= "}"
        return result
    }

    ArrayToJson(Arr) {
        result := "["
        first := true

        for item in Arr {
            if (!first)
                result .= ","
            first := false

            if (IsObject(item)) {
                result .= this.ObjectToJson(item)
            } else {
                result .= '"' . String(item) . '"'
            }
        }

        result .= "]"
        return result
    }
}

class ProgressTracker {
    CurrentOperation := ""
    TotalSteps := 0
    CurrentStep := 0
    StartTime := 0

    Initialize(Operation, TotalSteps) {
        this.CurrentOperation := Operation
        this.TotalSteps := TotalSteps
        this.CurrentStep := 0
        this.StartTime := A_TickCount
        Console.Instance.InitProgress(TotalSteps, Operation)
    }

    UpdateProgress(StepDescription, StepNumber := -1) {
        if (StepNumber > 0)
            this.CurrentStep := StepNumber
        else
            this.CurrentStep++

        Console.Instance.UpdateProgress(1, StepDescription)
    }

    Complete() {
        elapsedTime := A_TickCount - this.StartTime
        elapsedSeconds := Round(elapsedTime / 1000, 1)
        Console.Instance.CompleteProgress("Completed in " . elapsedSeconds . " seconds")
    }

    GetEstimatedTimeRemaining() {
        if (this.CurrentStep = 0)
            return 0

        elapsed := A_TickCount - this.StartTime
        avgTimePerStep := elapsed / this.CurrentStep
        remainingSteps := this.TotalSteps - this.CurrentStep

        return Round((avgTimePerStep * remainingSteps) / 1000, 1)
    }
}
