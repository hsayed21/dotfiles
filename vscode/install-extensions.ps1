$extensions = Get-Content ".\current-vscode-extensions.txt"

foreach ($ext in $extensions) {
    if (-not (code --list-extensions | Select-String -Pattern $ext)) {
        code --install-extension $ext
    } else {
        Write-Host "Extension '$ext' is already installed, skipping..."
    }
}
