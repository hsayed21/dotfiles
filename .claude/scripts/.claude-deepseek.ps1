$currentScriptPath = $MyInvocation.MyCommand.Definition
$realScriptPath = (Get-Item $currentScriptPath).Target
# If it's not a symlink, .Target will be empty, so we fallback to the original path
if (-not $realScriptPath) { $realScriptPath = $currentScriptPath }
$realDirectory = Split-Path -Parent $realScriptPath
$claudeRoot = Split-Path -Parent $realDirectory

$tokenFilePath = Join-Path $claudeRoot ".deepseek-token"

if (Test-Path $tokenFilePath) {
    $env:ANTHROPIC_AUTH_TOKEN = (Get-Content $tokenFilePath).Trim()
} else {
    Write-Error "Token file not found at: $tokenFilePath"
    return
}
$env:ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
$env:ANTHROPIC_MODEL="deepseek-v4-flash"
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
$env:CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
$env:CLAUDE_CODE_EFFORT_LEVEL="max"