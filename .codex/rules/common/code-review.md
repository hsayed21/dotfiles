# Code Review Standards

## Purpose

Code review ensures quality, security, and maintainability before code is merged.

## Core Review Philosophy

1. **Understand first** — Read PR description. Know what this change is for before judging it.
2. **Respect existing code** — Don't suggest full rewrites. Fix the issue, not the surrounding code. Only call for a rewrite if the entire function logic is broken.
3. **Deep analysis** — Trace the change through the whole system. Does it break old logic? Edge cases handled?
4. **Security always** — XSS, SQL injection, CSRF, auth bypass, hardcoded secrets, input validation.
5. **Simple comments** — One-liner: what to do + why. Show before/after diff for fixes.

## When to Review

**MANDATORY review triggers:**
- After writing or modifying code
- Before any commit to shared branches
- When security-sensitive code changes (auth, payments, user data)
- When architectural changes are made
- Before merging pull requests

## Review Checklist

Before marking code complete:

- [ ] Security scanned (secrets, injection, XSS, auth)
- [ ] Logic traced end-to-end (does it break old code?)
- [ ] Edge cases considered (null, empty, large, concurrent)
- [ ] Error handling explicit (no swallowed exceptions)
- [ ] Immutability respected (no in-place mutations)
- [ ] No hardcoded secrets or credentials
- [ ] No debug logging (console.log, Debug.WriteLine)
- [ ] Tests exist for new functionality

## Security Review Triggers

**STOP and use security-reviewer agent when:**
- Authentication or authorization code
- User input handling
- Database queries
- File system operations
- External API calls
- Cryptographic operations
- Payment or financial code

## Review Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| CRITICAL | Security vulnerability or data loss risk | **BLOCK** - Must fix before merge |
| HIGH | Bug or significant quality issue | **WARN** - Should fix before merge |
| MEDIUM | Maintainability concern | **INFO** - Consider fixing |
| LOW | Style or minor suggestion | **NOTE** - Optional |

## Agent Usage

| Agent | Purpose |
|-------|---------|
| **csharp-reviewer** | C# and .NET code review |
| **typescript-reviewer** | TypeScript/Angular code review |
| **security-reviewer** | Security vulnerabilities, OWASP Top 10 |
| **code-reviewer** | General code quality, patterns, best practices |
