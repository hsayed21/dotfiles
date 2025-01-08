# Common package validation function
function Test-PackageProperty {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Package
    )
    
    if (-not ($Package.ContainsKey('name') -xor $Package.ContainsKey('id'))) {
        Write-Log "Package must have either 'name' or 'id' property, not both or neither" -Level Error
        return $false
    }
    return $true
}

# Function to install a package using Scoop
function Install-ScoopPackage {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Package,
        [int]$maxRetries = 3
    )

    if (-not (Test-PackageProperty -Package $Package)) {
        return $false
    }

    $packageName = $Package.ContainsKey('name') ? $Package.name : $Package.id

    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            if (!(scoop list $packageName -ErrorAction SilentlyContinue)) {
                Write-Log "Installing $packageName (Attempt $i of $maxRetries)" -Level Info
                scoop install $packageName
                if (Test-Installation -Command $packageName -Package $packageName) {
                    return $true
                }
            } else {
                Write-Log "$packageName is already installed" -Level Success
                return $true
            }
        }
        catch {
            Write-Log "Attempt $i failed: $($_.Exception.Message)" -Level Warning
            if ($i -eq $maxRetries) {
                Write-Log "Failed to install $packageName after $maxRetries attempts" -Level Error
                return $false
            }
            Start-Sleep -Seconds ($i * 2)
        }
    }
    return $false
}

# Function to install a package using Winget
function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Package,
        [int]$maxRetries = 3
    )
    
    if (-not (Test-PackageProperty -Package $Package)) {
        return $false
    }

    try {
        $useId = $Package.ContainsKey('id')
        $displayName = $useId ? $Package.id : $Package.name
        
        # Check if package is already installed
        $searchArg = $useId ? "--id $($Package.id)" : "--query $($Package.name)"
        $installedPackages = winget list $searchArg --accept-source-agreements

        if ($installedPackages -match $displayName) {
            Write-Log "$displayName is already installed" -Level Success
            return $true
        }

        # Install package with retry logic
        $installBlock = {
            if ($useId) {
                $result = winget install --exact --id $Package.id --silent --accept-package-agreements --accept-source-agreements
                if ($LASTEXITCODE -ne 0) {
                    if ($result -match "No package found matching input criteria") {
                        throw "Package ID '$($Package.id)' not found"
                    }
                    throw "Winget installation failed with exit code $LASTEXITCODE"
                }
            } else {
                $result = winget install $Package.name --silent --accept-package-agreements --accept-source-agreements
                if ($LASTEXITCODE -ne 0) {
                    throw "Winget installation failed with exit code $LASTEXITCODE"
                }
            }
        }

        $success = Invoke-WithRetry -ScriptBlock $installBlock -OperationName "Installing $displayName with winget" -MaxRetries $maxRetries
        if ($success) {
            Write-Log "$displayName installed successfully" -Level Success
        }
        return $success
    }
    catch {
        Write-Log "Error installing $displayName: $($_.Exception.Message)" -Level Error
        return $false
    }
}

# Function to install a package using Chocolatey
function Install-ChocoPackage {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Package,
        [int]$maxRetries = 3
    )
    
    if (-not (Test-PackageProperty -Package $Package)) {
        return $false
    }

    $packageName = $Package.ContainsKey('name') ? $Package.name : $Package.id

    try {
        # Check if package is already installed
        if (choco list --local-only $packageName --exact | Select-String -Pattern "^$packageName\s+") {
            Write-Log "$packageName is already installed" -Level Success
            return $true
        }

        # Install package with retry logic
        $installBlock = {
            choco install $packageName -y
            if ($LASTEXITCODE -ne 0) { throw "Chocolatey installation failed with exit code $LASTEXITCODE" }
        }

        $success = Invoke-WithRetry -ScriptBlock $installBlock -OperationName "Installing $packageName with chocolatey" -MaxRetries $maxRetries
        if ($success) {
            Write-Log "$packageName installed successfully" -Level Success
        }
        return $success
    }
    catch {
        Write-Log "Error installing $packageName: $($_.Exception.Message)" -Level Error
        return $false
    }
}

# Function to create a symbolic link
function Create-SymbolicLink {
    param(
        [string]$destPath,
        [string]$sourcePath,
        [switch]$Force
    )

    try {
        # Validate paths
        if (-not (Test-Path $sourcePath)) {
            Write-Log "Source path does not exist: $sourcePath" -Level Error
            return $false
        }

        # Create parent directory if needed
        $parentDir = Split-Path -Parent $destPath
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            Write-Log "Created parent directory: $parentDir" -Level Info
        }

        # Handle existing destination
        if (Test-Path $destPath) {
            $item = Get-Item $destPath -Force
            if ($item.LinkType -eq "SymbolicLink") {
                $currentTarget = (Get-Item $destPath).Target
                if ($currentTarget -eq $sourcePath) {
                    Write-Log "Symlink already exists and points to correct target" -Level Success
                    return $true
                }
            }
            
            if ($Force) {
                Backup-ExistingConfig -Path $destPath
                Remove-Item -Path $destPath -Force -Recurse
                Write-Log "Removed existing item at $destPath" -Level Info
            } else {
                Write-Log "Destination exists and -Force not specified: $destPath" -Level Warning
                return $false
            }
        }

        # Create symlink
        New-Item -Path $destPath -Target $sourcePath -ItemType SymbolicLink -Force | Out-Null
        Write-Log "Created symlink: $destPath -> $sourcePath" -Level Success
        return $true
    }
    catch {
        Write-Log "Error creating symlink: $($_.Exception.Message)" -Level Error
        return $false
    }
}

# Function to display a success message
function Show-SuccessMessage {
    param([string]$Message)

    # Format and display the success message
    Write-Host "`e[32m$Message`e[0m"  # Green text
}

# Function to initialize logging
function Initialize-Log {
    param([string]$LogPath = "$PWD\setup.log")
    
    $Global:LogFile = $LogPath
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - Setup started" | Out-File -FilePath $LogFile
}

# Function to write to log
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - [$Level] $Message"
    $logMessage | Out-File -FilePath $Global:LogFile -Append

    # Console output with colors
    $colors = @{
        'Info' = 'White'
        'Warning' = 'Yellow'
        'Error' = 'Red'
        'Success' = 'Green'
    }
    Write-Host -ForegroundColor $colors[$Level] $Message
}

# Function to backup existing config
function Backup-ExistingConfig {
    param([string]$Path)
    
    if (Test-Path $Path) {
        $backupDir = New-BackupDirectory
        $fileName = Split-Path $Path -Leaf
        $backupPath = Join-Path $backupDir "$fileName.backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
        
        try {
            Copy-Item -Path $Path -Destination $backupPath -Recurse -Force
            Write-Log "Backed up $Path to $backupPath" -Level Success
            return $true
        }
        catch {
            Write-Log "Failed to backup $Path: $($_.Exception.Message)" -Level Error
            return $false
        }
    }
    return $false
}

# Function to verify installation
function Test-Installation {
    param(
        [string]$Command,
        [string]$Package
    )
    
    try {
        $null = Get-Command $Command -ErrorAction Stop
        Write-Log "Verified $Package installation" -Level Success
        return $true
    }
    catch {
        Write-Log "Failed to verify $Package installation" -Level Error
        return $false
    }
}

# Function to handle retries
function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [string]$OperationName,
        [int]$MaxRetries = 3,
        [int]$RetryDelay = 2
    )
    
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            Write-Log "Attempting $OperationName (Try $i of $MaxRetries)" -Level Info
            & $ScriptBlock
            return $true
        }
        catch {
            Write-Log "$OperationName failed: $($_.Exception.Message)" -Level Warning
            if ($i -eq $MaxRetries) {
                Write-Log "Failed $OperationName after $MaxRetries attempts" -Level Error
                return $false
            }
            Start-Sleep -Seconds ($RetryDelay * $i)
        }
    }
}

# Enhanced config management functions
function New-BackupDirectory {
    param([string]$Path)
    
    $backupDir = Join-Path $PWD "backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    return $backupDir
}
