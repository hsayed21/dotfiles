
#Include Console.ahk

class PackageManagerBase {
    Name := ""
    Command := ""
    __New(name, command) {
        this.Name := name
        this.Command := command
    }
    GetDisplayName(Package) {
        if (Package.HasOwnProp("name"))
            return Package.name
        else if (Package.HasOwnProp("id"))
            return Package.id
        else
            return "Unknown"
    }
    ValidatePackage(Package) {
        hasName := Package.HasOwnProp("name")
        hasId := Package.HasOwnProp("id")
        if (!hasName && !hasId) {
            Console.Instance.ShowError("Package must have either 'name' or 'id' property")
            return false
        }
        if (hasName && hasId) {
            Console.Instance.ShowError("Package must have either 'name' or 'id' property, not both")
            return false
        }
        return true
    }
}

class ScoopManager extends PackageManagerBase {
    __New() {
        super.__New("Scoop", "scoop")
    }
    Install() {
        if (this.IsInstalled()) {
            Console.Instance.ShowSuccess("Scoop is already installed")
            return true
        }
        Console.Instance.ShowStatus("Installing Scoop...", "loading")
        ; Console.Instance.Run('powershell -Command `'iex `"& {$(irm get.scoop.sh)} -RunAsAdmin`"`'')
        ; psCommand := "iex `"& { $(irm get.scoop.sh) } -RunAsAdmin`""
        ; RunWaitOne('powershell -Command "' . psCommand . '"')

        ; psCommand := "iex " "& { $(irm get.scoop.sh) } -RunAsAdmin" ""
        ; RunWaitOne('powershell -NoProfile -Command ' . Chr(34) . psCommand . Chr(34), &output)

        ; psCommand := "iwr -useb get.scoop.sh | iex"
        ; psCommand := 'iex "& {$(irm get.scoop.sh)} -RunAsAdmin"'
        ; psCommand := 'irm get.scoop.sh | iex'

        ; Run PowerShell with the command
        ; RunWaitOne("powershell -NoProfile -ExecutionPolicy Bypass -Command " . Chr(34) . psCommand . Chr(34), &output)
        ; RunWaitOne("powershell -NoProfile -ExecutionPolicy Bypass -Command '" . psCommand . "'", &output)
        psCommand := "iex '& {$(irm get.scoop.sh)} -RunAsAdmin'"
        RunWaitOne("powershell -NoProfile -ExecutionPolicy Bypass -Command " . Chr(34) . psCommand . Chr(34), &output)

        if instr(output, "Scoop was installed successfully")
            Console.Instance.ShowSuccess("Scoop installed successfully")
        else
            Console.Instance.ShowWarning("Scoop installation may have failed or requires manual intervention")

        Console.Instance.ShowSuccess("Scoop install attempted")
        return true
    }

    IsInstalled() {
        exitCode := RunWaitOne("scoops --version", &out)
        return (exitCode = 0 && out != "")
    }

    IsPackageInstalled(PackageName, PackageId := "") {
        result := Console.Instance.Run("scoop list",, &output)
        if (!result.Success)
            return { IsInstalled: false, InstalledName: "" }

        ; Create search terms
        searchNames := [PackageName]
        if (PackageId && PackageId != PackageName)
            searchNames.Push(PackageId)

        ; Handle bucket/package format (e.g., "extras/altsnap" -> "altsnap")
        if (InStr(PackageName, "/")) {
            parts := StrSplit(PackageName, "/")
            if (parts.Length >= 2)
                searchNames.Push(parts[2])
        }

        ; Check each search term
        for searchName in searchNames {
            if (InStr(output, searchName)) {
                return {
                    IsInstalled: true,
                    InstalledName: searchName
                }
            }
        }

        return { IsInstalled: false, InstalledName: "" }
    }
}

class WingetManager extends PackageManagerBase {
    __New() {
        super.__New("Winget", "winget")
    }
    Install() {
        if (this.IsInstalled()) {
            Console.Instance.ShowSuccess("Winget is already installed")
            return true
        }
        Console.Instance.ShowStatus("Installing Winget...", "loading")
        psCommand := 'irm asheroto.com/winget | iex'
        RunWait('powershell -Command "' . psCommand . '"', , "Hide")
        Console.Instance.ShowSuccess("Winget install attempted")
        return true
    }
    IsInstalled() {
        return FileExist(A_WinDir . "\System32\winget.exe")
    }

    IsPackageInstalled(PackageName, PackageId := "") {
        result := Console.Instance.Run("winget list --accept-source-agreements --disable-interactivity",, &output)
        if (!result.Success)
            return { IsInstalled: false, InstalledName: "" }

        ; Create search terms
        searchNames := [PackageName]
        if (PackageId && PackageId != PackageName)
            searchNames.Push(PackageId)

        ; Check each search term
        for searchName in searchNames {
            if (InStr(output, searchName)) {
                return {
                    IsInstalled: true,
                    InstalledName: searchName
                }
            }
        }

        return { IsInstalled: false, InstalledName: "" }
    }
}

class ChocolateyManager extends PackageManagerBase {
    __New() {
        super.__New("Chocolatey", "choco")
    }
    Install() {
        if (this.IsInstalled()) {
            Console.Instance.ShowSuccess("Chocolatey is already installed")
            return true
        }
        Console.Instance.ShowStatus("Installing Chocolatey...", "loading")
        psCommand := 'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))'
        RunWait('powershell -Command "' . psCommand . '"', , "Hide")
        Console.Instance.ShowSuccess("Chocolatey install attempted")
        return true
    }
    IsInstalled() {
        return FileExist("C:\\ProgramData\\chocolatey\\bin\\choco.exe")
    }

    IsPackageInstalled(PackageName, PackageId := "") {
        result := Console.Instance.Run("choco list --local-only --limit-output",, &output)
        if (!result.Success)
            return { IsInstalled: false, InstalledName: "" }

        ; Create search terms
        searchNames := [PackageName]
        if (PackageId && PackageId != PackageName)
            searchNames.Push(PackageId)

        ; Check each search term
        for searchName in searchNames {
            if (InStr(output, searchName)) {
                return {
                    IsInstalled: true,
                    InstalledName: searchName
                }
            }
        }

        return { IsInstalled: false, InstalledName: "" }
    }
}

class SourceForgeManager extends PackageManagerBase {
    __New() {
        super.__New("SourceForge", "curl")
    }
    Install() {
        return FileExist("C:\\Windows\\System32\\curl.exe")
    }
    IsPackageInstalled(PackageName, PackageId := "") {
        return FileExist("C:\\Program Files\\" . PackageName) || FileExist("C:\\Program Files (x86)\\" . PackageName)
    }
    InstallPackage(Package) {
        console := Console.Instance
        if (!Package.HasOwnProp("project") || !Package.HasOwnProp("file")) {
            console.ShowError("SourceForge package must have 'project' and 'file' properties")
            return { Status: "Failed", PackageName: "Unknown", PackageManager: this.Name, Error: "Missing properties" }
        }
        projectName := Package.project
        fileName := Package.file
        tempDir := A_Temp . "\sf_downloads"
        if (!DirExist(tempDir)) {
            DirCreate(tempDir)
        }
        outputPath := tempDir . "\" . fileName
        directUrl := "https://sourceforge.net/projects/" . projectName . "/files/latest/download"
        console.ShowStatus("Downloading from: " . directUrl, "loading")
        RunWait('curl -L -o "' . outputPath .
            '" --progress-bar --fail --connect-timeout 30 --max-time 600 --insecure "' . directUrl . '"', , "Hide")
        if (FileExist(outputPath)) {
            console.ShowStatus("Installing " . fileName . "...", "loading")
            try {
                Run(outputPath, , "Wait")
                console.ShowSuccess("Installation completed successfully")
                FileDelete(outputPath)
                return { Status: "Success", PackageName: projectName, PackageManager: this.Name }
            } catch as err {
                console.ShowError("Installation failed: " . err.Message)
                return { Status: "Failed", PackageName: projectName, PackageManager: this.Name, Error: err.Message }
            }
        }
        console.ShowError("Download file not found")
        return { Status: "Failed", PackageName: projectName, PackageManager: this.Name, Error: "Download file not found" }
    }
}
