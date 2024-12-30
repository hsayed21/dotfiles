# Function to install a package using Scoop
function Install-ScoopPackage {
    param([string]$packageName)

    try {
        # Check if the package is already installed
        $packageInstalled = scoop list $packageName -ErrorAction SilentlyContinue

        if ($packageInstalled -match $packageName) {
            Write-Host "`e[32m$packageName is already installed.`e[0m"  # Green text
        } else {
            Write-Host "`e[33mInstalling $packageName using Scoop...`e[0m"  # Yellow text
            scoop install $packageName
            Write-Host "`e[32m$packageName installation complete.`e[0m"  # Green text
        }
    }
    catch {
        Write-Host "`e[31mError: $($_.Exception.Message)`e[0m"  # Red text
    }
}

# Function to install a package using Winget
function Install-WingetPackage {
    param([string]$packageName, [bool]$usePackageId = $false)

    try {
        # Check if the package is already installed
        $packageInstalled = winget search $packageName

        if ($packageInstalled -match $packageName) {
            Write-Host "`e[32m$packageName is already installed.`e[0m"  # Green text
        } else {
            Write-Host "`e[33mInstalling $packageName using Winget...`e[0m"  # Yellow text
            if ($usePackageId) {
                winget install --id $packageName --silent --accept-package-agreements --accept-source-agreements
            } else {
                winget install $packageName --silent --accept-package-agreements --accept-source-agreements
            }
            Write-Host "`e[32m$packageName installation complete.`e[0m"  # Green text
        }
    }
    catch {
        Write-Host "`e[31mError: $($_.Exception.Message)`e[0m"  # Red text
    }
}

# Function to install a package using Chocolatey
function Install-ChocoPackage {
    param([string]$packageName)

    try {
        # Check if the package is already installed
        $packageInstalled = choco search --local-only $packageName

        if ($packageInstalled -match $packageName) {
            Write-Host "`e[32m$packageName is already installed.`e[0m"  # Green text
        } else {
            Write-Host "`e[33mInstalling $packageName using Chocolatey...`e[0m"  # Yellow text
            choco install $packageName -y
            Write-Host "`e[32m$packageName installation complete.`e[0m"  # Green text
        }
    }
    catch {
        Write-Host "`e[31mError: $($_.Exception.Message)`e[0m"  # Red text
    }
}

# Function to create a symbolic link
function Create-SymbolicLink {
    param([string]$destPath, [string]$sourcePath)

    try {
        # Check if the linkPath exists and if it's already a symbolic link
        if (Test-Path $destPath) {
            $item = Get-Item $destPath
            $destPath = $item.FullName
            if ($item.LinkType -eq "SymbolicLink") {
                Write-Host "`e[32mSymbolic link $destPath already exists.`e[0m"  # Green text
                return
            }
            else
            {
                # If it's a file or directory, remove it
                Write-Host "`e[31m$($destPath) already exists. Removing it...`e[0m"  # Red text
                Remove-Item -Path $destPath -Force -Recurse
            }
        }
        # Create the symbolic link again after removing any existing file/folder
        Write-Host "`e[33mCreating symbolic link from $sourcePath to $destPath...`e[0m"  # Yellow text
        New-Item -Path $destPath -Target $sourcePath -ItemType SymbolicLink -Force *>&1 | Out-Null
        Write-Host "`e[32mSymbolic link created successfully.`e[0m"  # Green text
    }
    catch {
        Write-Host "`e[31mError creating symbolic link: $($_.Exception.Message)`e[0m"  # Red text
    }
}

# Function to display a success message
function Show-SuccessMessage {
    param([string]$Message)

    # Format and display the success message
    Write-Host "`e[32m$Message`e[0m"  # Green text
}
