---
name: pr-review
description: POSBANK PR Review — Tester-first, security, logic, E2E trace, Azure DevOps. Minimal-change philosophy. Triggered by /pr-review or when user asks for a full PR review.
---

# PR Review Skill

Full-spectrum PR review with Azure DevOps integration. Follows the "understand first, minimal changes" philosophy.

## Core Review Philosophy (CRITICAL)

These rules override all other review instincts:

1. **Understand first** — Before any critique, understand what the PR is for, what feature/bug it addresses, and what the developer intended
2. **Respect existing code** — Don't suggest full rewrites unless the entire function logic is broken. Keep changes minimal — fix the issue, not the surrounding code
3. **Deep logic analysis** — Trace the change through the whole system. Does it break old logic? Does it handle edge cases? Think about the full picture
4. **Security-first** — Always check: XSS, SQL injection, CSRF, auth bypass, hardcoded secrets, input validation, path traversal
5. **Simple comments** — Developer-facing comments must be one-liners: what to do and why. Example: "Must add null check here — customerId can be null when called from guest checkout" or "Better to use IMemoryCache here instead of Dictionary for thread safety"

## When to Activate

- User asks for "PR review", "full review", "comprehensive review"
- Before merging a PR to main/master
- User wants Azure DevOps PR comments posted

## Review Flow

### Phase 1: Understand the PR

1. **Read PR description** — What is this change for? What issue does it fix?
2. **Identify changed files** — via Azure DevOps (`get_pull_request_changes`) or local git
3. **Classify changes** — Backend (.cs), Frontend (.ts/.html), Shared, Config, Migration
4. **Read the full files** — Not just diffs. Understand surrounding context and callers

### Phase 2: Deep Logic Analysis

Before commenting on any file, ask:

- What was the old behavior? What is the new behavior?
- Does this change break any existing callers?
- Are edge cases handled (null, empty, large, concurrent)?
- Does the data flow still make sense end-to-end?
- For refactored code: compare old vs new logic line-by-line

### Phase 3: Security Check (ALWAYS)

Scan every changed file for:

| Vulnerability | Backend (.cs) | Frontend (.ts/.html) |
|---|---|---|
| Injection | String-concat SQL, Process.Start with user input | `eval()`, `innerHTML` with user data |
| XSS | Unencoded Razor output | Bypassing DomSanitizer, `[innerHTML]` |
| Auth | Missing `[Authorize]`, no role checks | Missing route guards |
| Secrets | Hardcoded keys, connection strings | Hardcoded API keys in environments |
| CSRF | Missing `[ValidateAntiForgeryToken]` | — |
| Path traversal | User input in file paths | — |
| Input validation | No FluentValidation/DataAnnotations | No Zod schema, no form validation |

### Phase 4: Review Categories

**Logic & Correctness:**
- Does the code do what it claims to do?
- Are there off-by-one errors, null reference risks, race conditions?
- Does it handle errors properly or swallow them?
- For refactors: is the old behavior preserved (unless intentionally changed)?

**Code Quality (keep it minimal):**
- Functions > 50 lines — suggest extraction only if it improves clarity
- Deep nesting > 4 levels — suggest early returns
- Missing CancellationToken on async methods
- `.Result`/`.Wait()` blocking calls
- Any `async void` outside event handlers
- Magic strings/numbers that obscure intent

**Breaking Changes:**
- API contract changes (renamed/removed fields, changed types)
- Database schema changes that could fail on existing data
- Authentication/authorization changes affecting existing users
- Configuration key changes

### Phase 5: Write Report

Write the report to a markdown file. **Do NOT print the full report to terminal** — just print the file path and summary.

**File:** `pr-review-<branch-name>.md` (saved in current working directory)

**Comment format for developers (keep it simple):**

```
CRITICAL: Must add null check at OrderService.cs:42 — customer can be null from guest checkout flow

HIGH: Better to use IMemoryCache instead of Dictionary — not thread-safe under load

MEDIUM: Consider extracting this 60-line method — the validation block can be its own method
```

**Every issue includes:**
1. Severity (CRITICAL/HIGH/MEDIUM/LOW)
2. One-line action
3. File and line number
4. Brief reason why

**When showing fixes, use diff format:**

```diff
- _db.Orders.Where(o => o.CustomerId == customerId)
+ _db.Orders.Where(o => o.CustomerId == customerId).AsNoTracking()
```

### Phase 6: Post Azure DevOps Comments (with confirmation)

**Always ask user confirmation** before posting comments. Show a preview first.

For each finding:

```
mcp__azureDevOps__add_pull_request_comment(
  pullRequestId: <id>,
  content: "[SEVERITY] Action — reason",
  filePath: <path>,
  lineNumber: <line>,
  status: "active"
)
```

Post one summary comment on the PR (no file path) with the overall verdict and action items.

## Review Rules

1. **Minimal changes** — Fix the bug, don't refactor the module
2. **Only real issues** — Skip if <80% confident
3. **Understand before critique** — Read PR description and full context first
4. **Security always** — Every review checks all vulnerability categories
5. **Deep trace** — Follow the data flow through the whole system
6. **Simple comments** — One line: what + why. No essays
7. **Show the fix** — Every issue includes a before/after code snippet (diff format)
8. **Big changes get deep comparison** — >100 lines changed in a file = compare old vs new logic

## Azure DevOps Defaults

- Organization: `posbankbh`
- Project: `Snapos`
