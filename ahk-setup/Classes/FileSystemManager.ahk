#Include Console.ahk

class FileSystemManager {
    static CreateSymbolicLink(SourcePath, DestPath, Force := false) {
        if (!FileExist(SourcePath) && !DirExist(SourcePath)) {
            return false
        }

        SplitPath(DestPath, , &parentDir)
        if (!DirExist(parentDir)) {
            try {
                DirCreate(parentDir)
            } catch as err {
                return false
            }
        }

        if (InStr(DestPath, "*")) {
            expandedPath := FileSystemManager.ExpandWildcardPath(DestPath)
            if (!expandedPath) {
                return false
            }
            DestPath := expandedPath
        }

        if (FileExist(DestPath) || DirExist(DestPath)) {
            if (FileSystemManager.IsSymbolicLink(DestPath)) {
                currentTarget := FileSystemManager.GetSymlinkTarget(DestPath)
                if (currentTarget = SourcePath) {
                    Console.Instance.ShowSuccess("Symlink already exists and is correct")
                    return true
                }
            }

            if (Force) {
                FileSystemManager.BackupExistingConfig(DestPath)
                try {
                    if (DirExist(DestPath)) {
                        DirDelete(DestPath, true)
                    } else {
                        FileDelete(DestPath)
                    }
                } catch as err {
                    Console.Instance.ShowError("Failed to remove existing destination")
                    return false
                }
            } else {
                Console.Instance.ShowWarning("Destination already exists: " . DestPath)
                return false
            }
        }

        try {
            isDirectory := DirExist(SourcePath)
            command := 'mklink ' . (isDirectory ? '/D ' : '') . '"' . DestPath . '" "' . SourcePath . '"'

            result := Console.Instance.Run(command, "Creating symlink")
            return result
        } catch as err {
            Console.Instance.ShowError("Failed to create symlink: " . err.Message)
            return false
        }
    }

    static IsSymbolicLink(Path) {
        try {
            result := Console.Instance.Run('dir "' . Path . '" /AL',, &output)
            return result && InStr(output, "<SYMLINK>")
        } catch {
            return false
        }
    }

    static GetSymlinkTarget(Path) {
        try {
            result := Console.Instance.Run('dir "' . Path . '" /AL',, &output)
            if (result) {
                lines := StrSplit(output, "`n")
                for line in lines {
                    if (InStr(line, "<SYMLINK>")) {
                        bracketPos := InStr(line, "[")
                        if (bracketPos > 0) {
                            target := SubStr(line, bracketPos + 1)
                            target := SubStr(target, 1, InStr(target, "]") - 1)
                            return target
                        }
                    }
                }
            }
        } catch {
        }
        return ""
    }

    static ExpandWildcardPath(WildcardPath) {
        try {
            SplitPath(WildcardPath, &fileName, &parentPath)
            if (!DirExist(parentPath)) {
                return ""
            }

            Loop Files, parentPath . "\*", "D" {
                if (A_LoopFileName ~= StrReplace(fileName, "*", ".*")) {
                    SplitPath(WildcardPath, , , , &nameNoExt)
                    return A_LoopFileFullPath . "\" . nameNoExt
                }
            }
        } catch {
        }
        return ""
    }

    static BackupExistingConfig(Path) {
        if (!FileExist(Path) && !DirExist(Path)) {
            return false
        }

        backupDir := A_WorkingDir . "\backups"
        if (!DirExist(backupDir)) {
            DirCreate(backupDir)
        }

        SplitPath(Path, &fileName)
        timestamp := FormatTime(, "yyyyMMddHHmmss")
        backupPath := backupDir . "\" . fileName . ".backup-" . timestamp

        try {
            if (DirExist(Path)) {
                DirCopy(Path, backupPath, true)
            } else {
                FileCopy(Path, backupPath, true)
            }
            Console.Instance.ShowInfo("Backed up existing config to: " . backupPath)
            return true
        } catch as err {
            Console.Instance.ShowWarning("Failed to backup existing config")
            return false
        }
    }

    static EnsureDirectory(DirPath) {
        if (DirExist(DirPath)) {
            return true
        }
        try {
            DirCreate(DirPath)
            return true
        } catch {
            return false
        }
    }
}

class DotfileMapper {
    Mappings := []

    __New(MappingArray := []) {
        this.Mappings := MappingArray
    }

    AddMapping(SourcePath, DestPath) {
        this.Mappings.Push({
            source: SourcePath,
            dest: DestPath
        })
    }

    ProcessMappings(Force := true) {
        consoleInstance := Console.Instance
        consoleInstance.InitProgress(this.Mappings.Length, "Processing Symbolic Links")

        successful := 0
        failed := 0

        for index, mapping in this.Mappings {
            consoleInstance.UpdateProgress(1, "Mapping " . index . "/" . this.Mappings.Length)

            if (FileSystemManager.CreateSymbolicLink(mapping.source, mapping.dest, Force)) {
                successful++
            } else {
                failed++
                consoleInstance.ShowError("Failed: " . mapping.source . " -> " . mapping.dest)
            }
        }

        consoleInstance.CompleteProgress("Processed " . successful . "/" . this.Mappings.Length . " mappings successfully")

        return {
            Total: this.Mappings.Length,
            Successful: successful,
            Failed: failed
        }
    }

    ValidateMappings() {
        results := []
        for mapping in this.Mappings {
            validation := {
                Source: mapping.source,
                Dest: mapping.dest,
                SourceExists: FileExist(mapping.source) || DirExist(mapping.source),
                DestExists: FileExist(mapping.dest) || DirExist(mapping.dest),
                IsSymlink: false,
                TargetCorrect: false
            }

            if (validation.DestExists) {
                validation.IsSymlink := FileSystemManager.IsSymbolicLink(mapping.dest)
                if (validation.IsSymlink) {
                    target := FileSystemManager.GetSymlinkTarget(mapping.dest)
                    validation.TargetCorrect := (target = mapping.source)
                }
            }
            results.Push(validation)
        }
        return results
    }

    ReportStatus() {
        consoleInstance := Console.Instance
        validations := this.ValidateMappings()

        consoleInstance.ShowSection("Mapping Status Report")

        for validation in validations {
            if (validation.TargetCorrect) {
                consoleInstance.ShowSuccess(validation.Dest . " -> " . validation.Source)
            } else if (validation.IsSymlink) {
                consoleInstance.ShowWarning(validation.Dest . " (wrong target)")
            } else if (validation.DestExists) {
                consoleInstance.ShowWarning(validation.Dest . " (exists, not symlink)")
            } else if (!validation.SourceExists) {
                consoleInstance.ShowError(validation.Dest . " (source missing)")
            } else {
                consoleInstance.ShowInfo(validation.Dest . " (not created)")
            }
        }
    }
}
