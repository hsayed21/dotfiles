# Development Workflow

> Extends [common/git-workflow.md](./git-workflow.md) with the full feature development process.

## Feature Implementation Workflow

0. **Research & Reuse** _(mandatory before new implementation)_
   - Search for existing implementations first (GitHub, Azure DevOps, internal codebase)
   - Use Context7 for library docs (ASP.NET Core, EF Core, Angular, etc.)
   - Check NuGet/npm registries before writing utility code
   - Prefer battle-tested libraries over hand-rolled solutions

1. **Plan First**
   - Use **planner** agent or `/plan` command
   - Identify dependencies and risks
   - Break down into phases

2. **TDD Approach**
   - Use **tdd-guide** agent
   - Write tests first (RED) → Implement (GREEN) → Refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review**
   - Use **csharp-reviewer** for .cs files
   - Use **typescript-reviewer** for .ts files
   - Use **security-reviewer** for auth/input/payment code
   - Address CRITICAL and HIGH issues before merge

4. **Commit & Push**
   - Conventional commits format
   - Detailed commit messages
   - See [git-workflow.md](./git-workflow.md)

## Tech Stack Reference

| Layer | Technology |
|-------|-----------|
| Backend | ASP.NET Core, EF Core, MediatR, FluentValidation |
| Frontend | Angular (standalone, signals, RxJS), TypeScript |
| Database | SQL Server (primary), PostgreSQL |
| Automation | AutoHotkey v2 (desktop), n8n (workflow + AI agents) |
| Integration | n8n MCP (AI agent ↔ n8n bridge) |
