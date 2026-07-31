---
name: minimal-change-fix
description: Fix bugs, performance problems, regressions, build failures, and unexpected behavior with the smallest safe and correct change set. Use whenever Codex is asked to diagnose and fix an existing problem and should keep the Git diff surgical, touch the minimum files, preserve existing behavior, avoid unrelated refactoring, and validate only the affected path.
---

# Minimal Change Fix

Solve the reported root cause with a focused, reviewable, and easily reversible diff. Treat broad, unrelated, or avoidable modifications as incorrect even when the resulting code works.

## Establish the Change Boundary

Before editing:

1. Reproduce or understand the observed failure.
2. Trace the relevant execution path.
3. Identify the exact root cause and hot path.
4. Inspect related tests and existing implementations.
5. Determine the smallest complete fix.
6. State the files expected to change and why.
7. State what related areas will intentionally remain unchanged.

Do not begin with broad edits based on assumptions.

## Minimize the Diff

Prefer, in order:

- One focused change over distributed changes.
- Editing the responsible existing method over adding abstractions.
- Reusing existing utilities and patterns.
- A local change over an architectural change.
- Updating one relevant test or adding one focused regression test.

Use this default change budget:

- Prefer one modified file.
- Avoid modifying more than three files.
- Prefer no new files, dependencies, migrations, configuration changes, public API changes, or architectural changes.

Exceed the budget only when technically necessary. Explain why every additional file or structural change is required.

## Preserve Existing Behavior

Preserve all behavior outside the reported issue. Do not change public APIs, method signatures, response formats, database schemas, configuration formats, business rules, or unrelated user-visible behavior unless the root-cause fix cannot be safe and complete without it.

Choose the smallest correct root-cause fix, not a workaround. Do not hide errors, disable functionality, suppress warnings, or add hardcoded special cases unless they represent an actual business rule.

## Forbid Unrelated Work

Do not:

- Refactor, clean up, or modernize nearby working code.
- Rename variables, methods, classes, files, or folders.
- Move code or reorganize project structure.
- Reformat unrelated lines or sort imports unnecessarily.
- Update unrelated comments.
- Replace existing patterns, libraries, or dependency-injection structure.
- Upgrade packages unless required by the fix.
- Fix nearby issues that were not requested.
- Prepare for hypothetical future requirements.
- Modify generated files, lock files, configuration, or schemas unless required.

Mention discovered technical debt separately without changing it.

## Avoid New Abstractions

Do not add services, interfaces, base classes, helpers, wrappers, factories, dependencies, or configuration layers by default.

Add an abstraction only when all are true:

1. It is required for a safe fix.
2. Existing code cannot reasonably support the fix.
3. It reduces the total change surface.

Do not abstract code used only once without a strong technical reason.

## Avoid Speculative Defenses

Do not add null checks, try/catch blocks, retries, validation, logging, fallbacks, feature flags, or compatibility layers without evidence that they directly address the observed failure. Do not solve hypothetical problems.

## Prevent Formatting Noise

Preserve each file's line endings and existing style. Do not reformat entire files, reorder members, convert quotes, change brace style, alter unrelated indentation, or run broad formatters. Keep the final diff meaningful line by line.

## Handle Performance Problems

For a performance issue:

1. Measure or identify the actual bottleneck first.
2. Change only the measured hot path.
3. Preserve correctness before improving speed.
4. Do not introduce caching without evidence and explicit justification.
5. Do not rewrite the whole component or service.
6. Avoid unrelated algorithm changes and insignificant micro-optimizations.
7. Compare the same scenario before and after.
8. Report the bottleneck, measurements, and any trade-offs.

Do not claim improvement without evidence.

## Keep Tests and Validation Focused

Run the smallest validation that demonstrates correctness:

- A targeted test.
- A targeted build or static check.
- The original reproduction scenario.
- A comparable before/after benchmark for performance work.

Prefer updating an existing relevant test or adding one focused regression test. Do not refactor test infrastructure, rewrite suites, update unrelated snapshots, or change unrelated expectations.

If a useful regression test cannot reasonably be added, explain why.

## Handle Necessary Scope Expansion

When a correct fix genuinely requires broader changes:

1. Do not expand scope silently.
2. Explain why a smaller fix would be unsafe or incomplete.
3. Separate required changes from optional improvements.
4. Implement only required changes.
5. Keep every changed file directly connected to the root cause.

## Audit the Final Diff

Inspect the complete Git diff before completion. For every changed line, ask:

- Is it required to resolve the reported root cause?
- Is it directly connected to the issue?
- Can it be removed while keeping the fix correct?
- Does it alter unrelated behavior?
- Is it formatting noise or speculative protection?
- Is there a smaller equally safe implementation?

Remove every change that fails this audit. Do not overwrite or include unrelated user changes already present in a dirty worktree.

## Report the Result

Use this concise final structure:

### Root Cause

Explain the observed cause.

### Minimal Fix

Explain exactly what changed.

### Changed Files

List every changed file and why it was necessary.

### Intentionally Unchanged

Mention relevant areas reviewed but deliberately left untouched.

### Validation

State targeted tests, builds, reproduction steps, or measurements.

### Diff Audit

Confirm:

- No unrelated refactoring was performed.
- No unnecessary files were changed.
- No formatting-only changes remain.
- Every changed line is directly related to the fix.

## Decision Rule

When two solutions are both safe and complete, choose the one that changes fewer files and lines, introduces fewer concepts, preserves more behavior, and is easier to review and revert.

Minimal means focused, justified, correct, and complete—not careless.
