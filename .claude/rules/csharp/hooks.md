---
paths:
  - "**/*.cs"
  - "**/*.csx"
  - "**/*.csproj"
  - "**/*.sln"
  - "**/Directory.Build.props"
---

# C# Hooks

> Extends [common/hooks.md](../common/hooks.md)

## PostToolUse Hooks

Configure in `~/.claude/settings.json`:

- **dotnet format** — Auto-format edited C# files
- **dotnet build** — Verify solution still compiles
- **dotnet test --no-build** — Re-run nearest test project after changes

## Stop Hooks

- Final `dotnet build` before ending session with C# changes
- Warn on modified `appsettings*.json` — don't commit secrets
