# Function to install a package if it doesn't exist
function Install-ScoopPackage {
    param( [string]$packageName)

    try {
        # Check if the package is already installed
        $packageInstalled = scoop list $packageName -ErrorAction SilentlyContinue

        if ($packageInstalled -match $packageName) {
            Write-Host "$packageName is already installed."
        } else {
            Write-Host "Installing $packageName..."
            scoop install $packageName
            Write-Host "$packageName installation complete."
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}

function Install-WingetPackage { 
    param( [string]$packageName) 
 
    try { 
        # Check if the package is already installed using winget
        $packageInstalled = winget search $packageName
        
        if ($packageInstalled -match $packageName) { 
            Write-Host "$packageName is already installed." 
        } else { 
            Write-Host "Installing $packageName using winget..." 
            winget install $packageName
            Write-Host "$packageName installation complete." 
        } 
    } 
    catch { 
        Write-Host "Error: $($_.Exception.Message)" 
    } 
}

function Install-ChocoPackage { 
    param( [string]$packageName) 
 
    try { 
        # Check if the package is already installed using choco
        $packageInstalled = choco search --local-only $packageName
        
        if ($packageInstalled -match $packageName) { 
            Write-Host "$packageName is already installed." 
        } else { 
            Write-Host "Installing $packageName using choco..." 
            choco install $packageName -y
            Write-Host "$packageName installation complete." 
        } 
    } 
    catch { 
        Write-Host "Error: $($_.Exception.Message)" 
    } 
}


# Function to create a symbolic link
function Create-SymbolicLink {
    param( [string]$linkPath, [string]$targetPath)

    try {
        if (Test-Path $linkPath) {
            Write-Host "Symbolic link $linkPath already exists."
        } else {
            Write-Host "Creating symbolic link from $linkPath to $targetPath..."
            New-Item -Path $linkPath -Target $targetPath -ItemType SymbolicLink -Force
            Write-Host "Symbolic link created successfully."
        }
    }
    catch {
        Write-Host "Error creating symbolic link: $($_.Exception.Message)"
    }
}
