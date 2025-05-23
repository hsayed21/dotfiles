$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$vscodeFolderPath = Join-Path -Path $scriptRoot -ChildPath "vscode"
$extensionsOutputPath = Join-Path -Path $vscodeFolderPath -ChildPath "vscode-extensions.txt"
$currentExtensionsOutputPath = Join-Path -Path $vscodeFolderPath -ChildPath "current-vscode-extensions.txt"

Write-Host "Exporting VSCode extensions..."

try {
    $extensions = code --list-extensions
    $uniqueExtensions = $extensions | Sort-Object -Unique

    # Always write current extensions to the current-extensions file
    $uniqueExtensions | Out-File -FilePath $currentExtensionsOutputPath -Encoding utf8
    Write-Host "Current extensions saved to: $currentExtensionsOutputPath"

    if (Test-Path -Path $extensionsOutputPath) {
        $existingExtensions = Get-Content -Path $extensionsOutputPath
        $combinedExtensions = ($existingExtensions + $uniqueExtensions) | Sort-Object -Unique

        $newExtensions = $uniqueExtensions | Where-Object { $_ -notin $existingExtensions }

        # Always write the combined, sorted, unique list
        $combinedExtensions | Out-File -FilePath $extensionsOutputPath -Encoding utf8

        if ($newExtensions.Count -gt 0) {
            Write-Host "Added $($newExtensions.Count) new extensions"
            Write-Host "New extensions:"
            $newExtensions | ForEach-Object { Write-Host "  $_" }
        } else {
            Write-Host "No new extensions to add"
        }

        Write-Host "Total extensions in file: $($combinedExtensions.Count)"
    } else {
        # Create new file
        $uniqueExtensions | Out-File -FilePath $extensionsOutputPath -Encoding utf8
        Write-Host "Created new extensions file with $($uniqueExtensions.Count) extensions"
    }

    Write-Host "Done! Extensions saved to: $extensionsOutputPath"
}
catch {
    Write-Host "Error: $_"
}
