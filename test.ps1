. .\_helper\_function.ps1

$mappings = @(
  @{
    source = "$PWD\FlowLauncher\Settings"
    dest = "$Env:APPDATA\FlowLauncher\Settings"
  }
)

foreach ($mapping in $mappings) {
  Write-Output "Creating symlink for $($mapping.source) -> $($mapping.dest)"
  Create-SymbolicLink -destPath "$($mapping.dest)" -sourcePath "$($mapping.source)"
}
