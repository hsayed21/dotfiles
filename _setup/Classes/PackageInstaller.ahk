
#Include Console.ahk
#Include InstallationStats.ahk
#Include PackageManagers.ahk

class PackageInstaller {
    Stats := InstallationStats()
    Progress := ProgressTracker()
    Managers := Map()

    __New() {
        this.Managers["Scoop"] := ScoopManager()
        this.Managers["Winget"] := WingetManager()
        this.Managers["Chocolatey"] := ChocolateyManager()
    }

    IsPackageInstalled(packageName, packageId := "") {
        searchNames := [packageName]
        if (packageId && packageId != packageName) {
            searchNames.Push(packageId)
        }
        if (InStr(packageName, "/")) {
            parts := StrSplit(packageName, "/")
            if (parts.Length >= 2) {
                searchNames.Push(parts[2])
            }
        }
        for _, manager in this.Managers {
            if (manager.IsInstalled()) {
                for searchName in searchNames {
                    result := manager.IsPackageInstalled(searchName)
                    if (result.IsInstalled) {
                        return {
                            IsInstalled: true,
                            PackageManager: manager.Name,
                            InstalledName: result.InstalledName
                        }
                    }
                }
            }
        }

        ; Local installation check (basic)
        basePaths := [
            A_ProgramFiles,                     ; e.g., C:\Program Files
            A_ProgramFiles . " (x86)",          ; e.g., C:\Program Files (x86)
            A_AppData,                          ; Roaming AppData
            EnvGet("LOCALAPPDATA"),                     ; Local AppData
            EnvGet("LOCALAPPDATA") . "\Programs"          ; Local Programs
        ]

        for searchName in searchNames {
            for basePath in basePaths {
                if !DirExist(basePath)  ; skip if base path doesn’t exist
                    continue

                loop files basePath "\*", "D" { ; D = only directories
                    if InStr(A_LoopFileName, searchName) {
                        return {
                            IsInstalled: true,
                            PackageManager: "Local",
                            InstalledName: searchName,
                        }
                    }
                }
            }
        }

        return {
            IsInstalled: false,
            PackageManager: "",
            InstalledName: ""
        }
    }

    SetupPackageManagers() {
        Console.Instance.ShowSection("Setting up Package Managers")

        allReady := true
        for name, manager in this.Managers {
            if (!manager.IsInstalled()) {
                if (!manager.Install()) {
                    Console.Instance.ShowError("Failed to install " . name)
                    allReady := false
                } else {
                    Console.Instance.ShowSuccess(name . " installed successfully")
                }
            } else {
                Console.Instance.ShowSuccess(name . " is already installed")
            }
        }

        return allReady
    }

    SetupScoopBuckets() {
        if (!this.Managers["Scoop"].IsInstalled()) {
            return
        }

        Console.Instance.ShowInfo("Setting up Scoop buckets...")
        scoopManager := this.Managers["Scoop"]

        scoopManager.AddBucket("extras")
        scoopManager.AddBucket("versions")
    }

    InstallPackages(Categories := []) {
        packages := SetupConfig.GetPackages()

        Console.Instance.ShowSection("Installing Packages")

        for categoryName, categoryPackages in packages {
            if (Categories.Length = 0 || this.ArrayContains(Categories, categoryName)) {

                for managerName, packageList in categoryPackages {
                    if (!this.Managers.Has(managerName)) {
                        Console.Instance.ShowWarning("Unknown package manager: " . managerName)
                        continue
                    }

                    manager := this.Managers[managerName]
                    if (!manager.IsInstalled()) {
                        Console.Instance.ShowWarning(managerName . " is not installed, skipping packages")
                        continue
                    }

                    for package in packageList {
                        packageName := manager.GetDisplayName(package)
                        packageId := package.HasOwnProp("id") ? package.id : ""

                        installCheck := this.IsPackageInstalled(packageName, packageId)
                        if (installCheck.IsInstalled) {
                            Console.Instance.ShowSuccess(packageName . " already installed via " . installCheck.PackageManager)
                            this.Stats.AddSkip(packageName, managerName, "Already installed via " . installCheck.PackageManager)
                        } else {
                            result := manager.InstallPackage(package)
                            this.Stats.ProcessResult(result)
                        }
                    }
                }
            }
        }

        return this.Stats
    }

    ArrayContains(Array, Value) {
        for item in Array {
            if (StrLower(item) = StrLower(Value)) {
                return true
            }
        }
        return false
    }

    static ManageZenProfiles() {
        ProfilesIniPath := A_AppData "\zen\profiles.ini"
        zenDir := ""
        SplitPath(ProfilesIniPath, , &zenDir)
        if (!DirExist(zenDir)) {
            ; DirCreate(zenDir)
            return false
        }

        ; Initialize variables
        hasMainDefault := false
        hasInstallSection := false
        profileCount := 0
        installSectionName := ""
        installId := ""
        mainProfileSectionName := ""

        ; Check if file exists and read sections
        if (FileExist(ProfilesIniPath)) {
            ; Get all sections
            sections := IniRead(ProfilesIniPath)
            sectionArray := StrSplit(sections, "`n", "`r")

            for section in sectionArray {
                if (RegExMatch(section, "i)^Install(.+)", &match)) {
                    hasInstallSection := true
                    installSectionName := section
                    installId := match[1]
                }

                if (RegExMatch(section, "i)^Profile\d+")) {
                    profileCount++
                    path := IniRead(ProfilesIniPath, section, "Path", "")
                    if (path = "Profiles/main.Default") {
                        hasMainDefault := true
                        mainProfileSectionName := section
                    }
                }
            }
        }

        if (hasInstallSection) {
            currentDefault := IniRead(ProfilesIniPath, installSectionName, "Default", "")
            if (currentDefault != "Profiles/main.Default") {
                IniWrite("Profiles/main.Default", ProfilesIniPath, installSectionName, "Default")
            }

            if (installId != "") {
                IniWrite("Profiles/main.Default", A_AppData . "\zen\installs.ini", installId, "Default")
            }
        }

        ; Add main.Default profile if missing
        if (!hasMainDefault) {
            newProfileSection := "Profile" profileCount
            IniWrite("Default", ProfilesIniPath, newProfileSection, "Name")
            IniWrite("1", ProfilesIniPath, newProfileSection, "IsRelative")
            IniWrite("Profiles/main.Default", ProfilesIniPath, newProfileSection, "Path")
            IniWrite("1", ProfilesIniPath, newProfileSection, "Default")
        } else {
            ; Ensure existing main.Default profile is set as default
            currentDefault := IniRead(ProfilesIniPath, mainProfileSectionName, "Default", "")
            if (currentDefault != "1") {
                IniWrite("1", ProfilesIniPath, mainProfileSectionName, "Default")
            }
        }
    }
}
