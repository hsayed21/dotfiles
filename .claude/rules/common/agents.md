# Agent Orchestration

## Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| csharp-reviewer | C# and .NET code review | All C# changes |
| typescript-reviewer | TypeScript/Angular code review | All TS changes |
| security-reviewer | Security analysis | Auth, input, payments |
| code-reviewer | General code quality | After writing code |
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| tdd-guide | Test-driven development | New features, bug fixes |
| build-error-resolver | Fix build errors | When build fails |
| e2e-runner | E2E testing | Critical user flows |
| performance-optimizer | Performance analysis | Bottleneck investigation |
| database-reviewer | Database/EF Core review | Schema changes, queries |
| code-explorer | Codebase exploration | Understanding existing code |
| code-architect | Feature architecture design | New feature planning |
| code-simplifier | Code simplification | After writing complex code |
| silent-failure-hunter | Error handling review | Catch blocks, fallbacks |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation | Updating docs |
| deep-research-agent | Deep research | Complex investigation |
| loop-operator | Autonomous loops | Monitoring, polling |
| a11y-architect | Accessibility | UI components, WCAG |

## Immediate Agent Usage

No user prompt needed:
1. Complex feature requests → **planner** agent
2. C# code just written → **csharp-reviewer** agent
3. TS/Angular code just written → **typescript-reviewer** agent
4. Auth/input/payment code → **security-reviewer** agent
5. Bug fix or new feature → **tdd-guide** agent
6. Architectural decision → **architect** agent

## Parallel Execution

For independent tasks, launch agents in parallel:
- Security review + code quality review can run simultaneously
- Frontend review + backend review can run simultaneously
