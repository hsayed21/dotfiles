# Load the generated colors from wal, typically located at $HOME\.cache\wal\colors.json
$colorsPath = "$HOME\.cache\wal\colors.json"

# Check if colors.json file exists
if (-not (Test-Path $colorsPath)) {
    Write-Error "Colors file not found at: $colorsPath"
    exit 1
}

# Convert the JSON colors to a PowerShell object
try {
    $colors = Get-Content -Raw -Path $colorsPath | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse colors.json: $_"
    exit 1
}

# Generate the :root{} section
$variablesSection = @"
:root {
    --backgroundcol: $($colors.special.background);
    --foregroundcol: $($colors.special.foreground);
    --cursorcol: $($colors.special.cursor);
    --colors0: $($colors.colors.color0);
    --colors1: $($colors.colors.color1);
    --colors2: $($colors.colors.color2);
    --colors3: $($colors.colors.color3);
    --colors4: $($colors.colors.color4);
    --colors5: $($colors.colors.color5);
    --colors6: $($colors.colors.color6);
    --colors7: $($colors.colors.color7);
    --colors8: $($colors.colors.color8);
    --colors9: $($colors.colors.color9);
    --colors10: $($colors.colors.color10);
    --colors11: $($colors.colors.color11);
    --colors12: $($colors.colors.color12);
    --colors13: $($colors.colors.color13);
    --colors14: $($colors.colors.color14);
    --colors15: $($colors.colors.color15);
}
"@

# Read the existing styles.css file, typically located at $HOME\.config\yasb\styles.css
$stylesPath = "$HOME\.config\yasb\styles.css"

# Check if styles.css file exists
if (-not (Test-Path $stylesPath)) {
    Write-Error "Styles file not found at: $stylesPath"
    exit 1
}

try {
    $stylesContent = Get-Content -Raw -Path $stylesPath
} catch {
    Write-Error "Failed to read styles.css: $_"
    exit 1
}

# Check if :root{} section exists, if so replace it, otherwise prepend it
if ($stylesContent -match ":root\s*\{[\s\S]*?\}") {
    # Replace the existing :root{} section
    $newStylesContent = $stylesContent -replace ":root\s*\{[\s\S]*?\}", $variablesSection
} else {
    # Prepend the new :root{} section
    $newStylesContent = "$variablesSection`n`n$stylesContent"
}

# Trim trailing whitespace from the content
$newStylesContent = $newStylesContent.TrimEnd()

# Write the updated content back to styles.css
try {
    $newStylesContent | Set-Content -Path $stylesPath
    Write-Host "Successfully updated styles.css with new color variables"
} catch {
    Write-Error "Failed to write to styles.css: $_"
    exit 1
}
