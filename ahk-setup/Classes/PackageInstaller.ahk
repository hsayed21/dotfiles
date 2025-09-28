
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
        for manager in this.Managers.Values() {
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
        ; Minimal local check: look for folder in Program Files
        for searchName in searchNames {
            if (FileExist("C:\\Program Files\\" . searchName) || FileExist("C:\\Program Files (x86)\\" . searchName)) {
                return {
                    IsInstalled: true,
                    PackageManager: "Local",
                    InstalledName: searchName
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

        totalPackages := 0
        for categoryName, categoryPackages in packages {
            if (Categories.Length = 0 || this.ArrayContains(Categories, categoryName)) {
                for managerName, packageList in categoryPackages {
                    totalPackages += packageList.Length
                }
            }
        }

        this.Progress.Initialize("Package Installation", totalPackages)

        for categoryName, categoryPackages in packages {
            if (Categories.Length = 0 || this.ArrayContains(Categories, categoryName)) {
                Console.Instance.ShowSection("Installing " . categoryName . " Packages")

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

                        this.Progress.UpdateProgress("Checking " . packageName)

                        installCheck := this.IsPackageInstalled(packageName, packageId)
                        if (installCheck.IsInstalled) {
                            Console.Instance.ShowSuccess(packageName . " already installed via " . installCheck.PackageManager)
                            this.Stats.AddSkip(packageName, managerName, "Already installed via " . installCheck.PackageManager)
                        } else {
                            this.Progress.UpdateProgress("Installing " . packageName)
                            result := manager.InstallPackage(package)
                            this.Stats.ProcessResult(result)
                        }
                    }
                }
            }
        }

        this.Progress.Complete()
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

    GetStats() {
        return this.Stats
    }
}
