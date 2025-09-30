$extensions = Get-Content "$PSScriptRoot\current-vscode-extensions.txt"

foreach ($ext in $extensions) {
    if (-not (code-insiders --list-extensions | Select-String -Pattern $ext)) {
        code-insiders --install-extension $ext
    } else {
        Write-Host "Extension '$ext' is already installed, skipping..."
    }
}
