
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
        ; res := RunWaitOne("powershell -NoProfile -ExecutionPolicy Bypass -Command " . Chr(34) . psCommand . Chr(34), &output)
        res := Console.Instance.RunPowerShellSilent(psCommand, &output)

        if res != 0
        {
            Console.Instance.ShowError("Scoop installation command failed with exit code " . res)
            return false
        }

        Console.Instance.ShowSuccess("Scoop installed successfully")
        return true
    }

    IsInstalled() {
        res := Console.Instance.RunSilent("scoop --version", &out)
        return (res && out != "")
    }

    IsPackageInstalled(Package) {
        ; Handle bucket/package format (e.g., "extras/altsnap" -> "altsnap")
        if (InStr(Package, "/")) {
            parts := StrSplit(Package, "/")
            if (parts.Length >= 2)
                Package := parts[2]
        }

        result := Console.Instance.RunSilent("scoop which " . '"' . Package . '"', &output)
        if (!result)
            return { IsInstalled: false, InstalledName: "" }

        return { IsInstalled: true, InstalledName: Package }
    }

    InstallPackage(Package) {
        if (!this.ValidatePackage(Package)) {
            return { Status: "Failed", PackageName: "Unknown", PackageManager: this.Name, Error: "Invalid package definition" }
        }
        packageName := this.GetDisplayName(Package)
        packageId := Package.HasOwnProp("id") ? Package.id : ""
        installCmd := this.Command . " install " . packageName
        if (packageId && packageId != packageName) {
            installCmd .= " --name " . packageId
        }
        if (Package.HasOwnProp("options")) {
            installCmd .= " " . Package.options
        }

        Console.Instance.ShowStatus("Installing " . packageName . "...", "loading")
        res := Console.Instance.Run(installCmd,, &output)
        if (res) {
            Console.Instance.ShowSuccess(packageName . " installed successfully")
            return { Status: "Success", PackageName: packageName, PackageManager: this.Name }
        } else {
            Console.Instance.ShowError("Failed to install " . packageName . ". Exit code: " . res)
            return { Status: "Failed", PackageName: packageName, PackageManager: this.Name, Error: "Exit code " . res }
        }
    }

    AddBucket(BucketName) {
        if (!BucketName || BucketName = "") {
            Console.Instance.ShowError("Bucket name cannot be empty")
            return false
        }
        Console.Instance.ShowStatus("Adding Scoop bucket: " . BucketName, "loading")
        res := Console.Instance.RunSilent(this.Command . " bucket add " . BucketName)
        if (res) {
            Console.Instance.ShowSuccess("Bucket " . BucketName . " added successfully")
            return true
        } else {
            Console.Instance.ShowError("Failed to add bucket " . BucketName . ". Exit code: " . res)
            return false
        }
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
        res := Console.Instance.RunSilent("winget --version", &out)
        return (res && out != "")
    }

    IsPackageInstalled(Package) {
        result := Console.Instance.RunSilent("winget list --name " . '"' . Package . '"')
        if (!result)
        {
            result := Console.Instance.RunSilent("winget list --id " . '"' . Package . '"')
            if (!result)
                return { IsInstalled: false, InstalledName: "" }
        }

        return { IsInstalled: true, InstalledName: Package }
    }

    InstallPackage(Package) {
        if (!this.ValidatePackage(Package)) {
            return { Status: "Failed", PackageName: "Unknown", PackageManager: this.Name, Error: "Invalid package definition" }
        }
        packageName := this.GetDisplayName(Package)
        packageId := Package.HasOwnProp("id") ? Package.id : ""
        installCmd := this.Command . " install --accept-source-agreements --accept-package-agreements " . packageName
        if (packageId && packageId != packageName) {
            installCmd .= " --id " . packageId
        }
        if (Package.HasOwnProp("options")) {
            installCmd .= " " . Package.options
        }

        Console.Instance.ShowStatus("Installing " . packageName . "...", "loading")
        res := Console.Instance.Run(installCmd,, &output)
        if (res) {
            Console.Instance.ShowSuccess(packageName . " installed successfully")
            return { Status: "Success", PackageName: packageName, PackageManager: this.Name }
        } else {
            Console.Instance.ShowError("Failed to install " . packageName . ". Exit code: " . res)
            return { Status: "Failed", PackageName: packageName, PackageManager: this.Name, Error: "Exit code " . res }
        }
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
         res := Console.Instance.RunSilent("choco --version", &out)
        return (res && out != "")
    }

    IsPackageInstalled(Package) {
        result := Console.Instance.RunSilent("choco list --local-only --limit-output", &output)
        if (!result)
            return { IsInstalled: false, InstalledName: "" }


        if (InStr(output, Package)) {
            return {
                IsInstalled: true,
                InstalledName: Package
            }
        }

        return { IsInstalled: false, InstalledName: "" }
    }

    InstallPackage(Package) {
        if (!this.ValidatePackage(Package)) {
            return { Status: "Failed", PackageName: "Unknown", PackageManager: this.Name, Error: "Invalid package definition" }
        }
        packageName := this.GetDisplayName(Package)
        packageId := Package.HasOwnProp("id") ? Package.id : ""
        installCmd := this.Command . " install -y " . packageName
        if (packageId && packageId != packageName) {
            installCmd .= " --id=" . packageId
        }
        if (Package.HasOwnProp("options")) {
            installCmd .= " " . Package.options
        }

        Console.Instance.ShowStatus("Installing " . packageName . "...", "loading")
        res := Console.Instance.Run(installCmd,, &output)
        if (res) {
            Console.Instance.ShowSuccess(packageName . " installed successfully")
            return { Status: "Success", PackageName: packageName, PackageManager: this.Name }
        } else {
            Console.Instance.ShowError("Failed to install " . packageName . ". Exit code: " . res)
            return { Status: "Failed", PackageName: packageName, PackageManager: this.Name, Error: "Exit code " . res }
        }
    }
}

class SourceForgeManager extends PackageManagerBase {
    __New() {
        super.__New("SourceForge", "curl")
    }
    Install() {
        return FileExist("C:\\Windows\\System32\\curl.exe")
    }
    IsPackageInstalled(Package) {
        return FileExist("C:\\Program Files\\" . Package) || FileExist("C:\\Program Files (x86)\\" . Package)
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
