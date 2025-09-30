#Include Console.ahk
#Include PackageInstaller.ahk

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

            result := Console.Instance.RunSilent(command)
            return result
        } catch as err {
            Console.Instance.ShowError("Failed to create symlink: " . err.Message)
            return false
        }
    }

    static isSymbolicLink(path) {
        try {
            attrs := FileGetAttrib(path)
            return InStr(attrs, "L") > 0
        } catch {
            return false
        }
    }

    static GetSymlinkTarget(path) {
        ; Open file/directory handle with backup semantics for directories
        hFile := DllCall("CreateFileW"
            , "str", path
            , "uint", 0 ; GENERIC_READ not needed, query only
            , "uint", 0x00000007 ; FILE_SHARE_READ|WRITE|DELETE
            , "ptr", 0
            , "uint", 3 ; OPEN_EXISTING
            , "uint", 0x02000000 ; FILE_FLAG_BACKUP_SEMANTICS
            , "ptr", 0
            , "ptr")

        if (hFile = -1 || hFile = 0) {
            err := A_LastError
            throw Error("Failed to open path '" path "'. Win32 error: " err)
        }

        ; Use try/finally to ensure handle cleanup
        try {
            ; First call to get required buffer size
            requiredSize := DllCall("GetFinalPathNameByHandleW"
                , "ptr", hFile
                , "ptr", 0
                , "uint", 0
                , "uint", 0
                , "uint")

            if (requiredSize = 0) {
                err := A_LastError
                throw Error("Failed to get path size. Win32 error: " err)
            }

            ; Allocate buffer (size in characters, WCHAR = 2 bytes)
            buf := Buffer(requiredSize * 2, 0)

            ; Get actual path
            len := DllCall("GetFinalPathNameByHandleW"
                , "ptr", hFile
                , "ptr", buf
                , "uint", requiredSize
                , "uint", 0
                , "uint")

            if (len = 0 || len >= requiredSize) {
                err := A_LastError
                throw Error("Failed to resolve symlink. Win32 error: " err)
            }

            result := StrGet(buf, "UTF-16")

            ; Strip \\?\ prefix
            if (SubStr(result, 1, 4) = "\\?\") {
                result := SubStr(result, 5)
            }

            ; Convert \\?\UNC\server\share to \\server\share
            if (SubStr(result, 1, 8) = "\\?\UNC\") {
                result := "\\" SubStr(result, 9)
            }

            return result

        } finally {
            ; Always close handle even if error occurs
            DllCall("CloseHandle", "ptr", hFile)
        }
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
        for index, mapping in this.Mappings {
            if (FileSystemManager.CreateSymbolicLink(mapping.source, mapping.dest, Force)) {
                Console.Instance.ShowSuccess("Created symlink: " . mapping.source . " -> " . mapping.dest)
            } else {
                Console.Instance.ShowError("Failed: " . mapping.source . " -> " . mapping.dest)
            }
        }

        ; Special handling for Zen browser profiles
        PackageInstaller.ManageZenProfiles()

    }
}
