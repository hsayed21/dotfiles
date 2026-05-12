---
name: pr-review
description: Comprehensive PR review orchestrating code quality, security, simplicity, logic, E2E testing, and Azure DevOps PR comments. Use for full backend+frontend PR review. Triggered by /pr-review or when user asks for a full PR review.
---

# PR Review Skill

Full-spectrum PR review that orchestrates parallel specialized agents and produces a developer-friendly report with actionable fixes.

## When to Activate

- User asks for "PR review", "full review", "comprehensive review"
- Before merging a PR to main/master
- User wants Azure DevOps PR comments posted
- User wants both backend and frontend reviewed together

## Review Flow

### Phase 1: Gather Context

1. Determine PR source:
   - **Azure DevOps PR**: User provides PR ID or URL → use `mcp__azureDevOps__get_pull_request` and `mcp__azureDevOps__get_pull_request_changes`
   - **Local branch**: Run `git diff main...HEAD` and `git log main..HEAD --oneline`
2. Identify changed files — classify as backend, frontend, shared, config
3. For big refactors: run `git diff main...HEAD --stat` and identify files with >100 line changes for deep comparison

### Phase 2: Parallel Agent Reviews

Launch ALL of these simultaneously (independent reviews):

**Agent 1 — Security Review** (`security-reviewer` agent)
- Secrets detection, injection vulnerabilities, auth checks, input validation
- Prompt: "Review all changed files for security vulnerabilities. Check: hardcoded secrets, SQL injection, XSS, CSRF, auth bypass, path traversal, unsafe crypto. Flag only real issues (>80% confidence). Output findings grouped by severity (CRITICAL/HIGH/MEDIUM)."

**Agent 2 — Code Quality + Simplicity** (`code-reviewer` agent)
- Naming, file size, function length, nesting, error handling, immutability, dead code
- Prompt: "Review all changed files for code quality and simplicity. Check: functions >50 lines, files >800 lines, deep nesting >4 levels, missing error handling, mutation patterns, dead code, console.log statements. Skip minor style preferences. Focus on bugs and maintainability issues."

**Agent 3 — Logic & Architecture** (`architect` agent)
- Correct logic, architectural consistency, data flow, API design
- For big refactors: compare old vs new logic, flag corrupt/broken logic
- Prompt: "Review the architectural impact of these changes. Check: correct business logic, data flow correctness, API contract changes, breaking changes. If refactoring existing code, compare old and new logic — flag any behavior changes or broken logic. Identify patterns that don't match the rest of the codebase."

**Agent 4 — Redundancy & Simplification** (`code-simplifier` agent)
- Duplicate code, over-engineered patterns, unnecessary abstraction
- Prompt: "Review changed files for redundancy, over-engineering, and unnecessary complexity. Flag: duplicate logic, premature abstractions, overly complex patterns for simple tasks, code that could be simplified. For each finding, show a simplified version."

**Agent 5 — E2E Testing Coverage** (`e2e-runner` agent)
- Check if critical user flows are covered, test gaps
- Prompt: "Review changes for E2E test coverage gaps. Identify critical user flows affected by these changes. Check: are there existing E2E tests covering these flows? What new E2E tests are needed? List specific test scenarios to add."

### Phase 3: Write Report to Markdown File

Aggregate all agent findings and write them to a markdown file. **Do NOT print the full report to the terminal** — only print the file path and a one-line summary.

**File naming:**
- For Azure DevOps PR: `pr-review-<PR-ID>-<branch-name>.md`
- For local branch: `pr-review-<branch-name>.md`
- Save location: current working directory

**Report structure:**

````markdown
# PR Review Report

**Branch:** `<branch-name>` → `<target>`
**PR:** #<id> (if Azure DevOps)
**Date:** <today>
**Files Changed:** <count> | **Additions:** <N> | **Deletions:** <N>

---

## Summary

| Category | Score | Status |
|----------|-------|--------|
| Security | X/10 | pass / warn / fail |
| Code Quality | X/10 | pass / warn / fail |
| Logic/Architecture | X/10 | pass / warn / fail |
| Simplicity | X/10 | pass / warn / fail |
| E2E Coverage | X/10 | pass / warn / fail |

**Overall Verdict:** APPROVED / WARNING / BLOCKED

---

## Critical Issues (Must Fix)

> These block merge. Found by security and logic review.

### [CRITICAL] <issue title>
**File:** `path/to/file.ts:42`
**Category:** Security / Logic
**Problem:** <clear explanation of what's wrong>
**Fix:**
```diff
- bad code here
+ good code here
```

---

## High Priority (Should Fix)

> These should be addressed before merge.

### [HIGH] <issue title>
...same format as above...

---

## Medium Priority (Consider Fixing)

### [MEDIUM] <issue title>
...same format...

---

## Low Priority (Nice to Have)

### [LOW] <issue title>
...same format...

---

## E2E Testing

### Tests to Add
- [ ] **Test scenario name** — `tests/e2e/file.spec.ts` — covers <what>

### Existing Tests That Pass
- Test name (file.ts:line)

---

## Architecture Notes

<If big refactor: comparison table showing old vs new behavior for key functions>

| Function | Old Behavior | New Behavior | Verdict |
|----------|-------------|-------------|---------|
| `funcA()` | ... | ... | OK / CHANGED / BROKEN |

---

## Developer Action Items

1. **[CRITICAL]** Fix <issue> in `<file>:<line>` — <one-liner>
2. **[HIGH]** Add <test> for `<file>` — <one-liner>
3. ...
````

**After writing the file**, print to terminal only:
```
PR Review complete → pr-review-<branch>.md
Overall: APPROVED / WARNING / BLOCKED
Issues: X critical, Y high, Z medium
```

### Phase 4: Post Azure DevOps Comments (if requested)

If user confirms posting comments to Azure DevOps PR:

For CRITICAL issues: Create a new comment thread per file
```
mcp__azureDevOps__add_pull_request_comment
  pullRequestId: <id>
  content: "### [CRITICAL] <title>\n**Problem:** ...\n**Fix:**\n```...```"
  filePath: <path>
  lineNumber: <line>
  status: "active"
```

For summary: Post one overall summary comment on the PR (no file path).

**IMPORTANT:** Always ask user confirmation before posting any comments. Show a preview of what will be posted first.

---

## Review Rules

1. **Only real issues** — Skip if <80% confident
2. **Before/After code** — Every code suggestion shows the fix
3. **Developer-friendly** — Plain language, no jargon
4. **Actionable** — Every finding has a specific fix instruction
5. **No style nitpicking** — Only flag patterns that cause bugs or maintenance problems
6. **Backend + Frontend** — Both are reviewed in the same report
7. **Big changes get deep comparison** — If >100 lines changed in a file, compare old vs new logic carefully

## Azure DevOps Integration

To get PR details:
```
mcp__azureDevOps__get_pull_request(projectId, pullRequestId)
mcp__azureDevOps__get_pull_request_changes(repositoryId, pullRequestId)
```

To post comments (requires user confirmation):
```
mcp__azureDevOps__add_pull_request_comment(pullRequestId, content, filePath?, lineNumber?, status?)
```

Default organization: `posbankbh`, default project: `Snapos`.
