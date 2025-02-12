. .\_helper\_function.ps1

$mappings = @(
  # EqualizerAPO
  @{
    source = "$PWD\OBS\basic"
    dest = "$Env:APPDATA\obs-studio\basic"
  }
)

foreach ($mapping in $mappings) {
  Write-Output "Creating symlink for $($mapping.source) -> $($mapping.dest)"
  Create-SymbolicLink -destPath "$($mapping.dest)" -sourcePath "$($mapping.source)" -Force
}
