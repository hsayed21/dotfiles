---
name: maintain-code
description: Make safe, maintainable application-code changes and reviews with explicit routing for bug fixes and regressions, behavior-preserving refactors, and new or modified code. Use whenever Codex is asked to fix a bug, regression, build failure, performance problem, or unexpected behavior; refactor, clean up, reorganize, decouple, apply SOLID, split a god class or component, remove duplication, introduce dependency injection, or change architecture; review code for clarity, readability, maintainability, duplication, naming, typing, branching, async flow, or structure; or write and modify TypeScript, JavaScript, Angular, C#, and similar application code. Route fixes to the smallest safe diff, explicit refactors to behavior-preserving structural improvement, and reviews or general changes to concise readable guidance or implementation.
---

# Maintain Code

Apply one unified discipline to code changes while selecting the correct operating mode for the user's actual request.

## Mandatory source preservation

This skill is a lossless merge of three source skills. Their complete original instruction files and metadata are bundled under `references/originals/`. Treat those files as normative detail subject to the routing and conflict rules in this file:

- `references/originals/minimal-change-fix/SKILL.md`
- `references/originals/write-clean-readable-code/SKILL.md`
- `references/originals/code-refactorer/SKILL.md`
- `references/originals/minimal-change-fix/agents/openai.yaml`
- `references/originals/write-clean-readable-code/agents/openai.yaml`

Read the complete routed source file before acting. For mixed tasks, read every applicable source file. Use `references/source-coverage.md` and `scripts/verify_source_integrity.py` to audit preservation.

## Routing rules

Classify the request before editing. User intent and explicit scope control the route.

### Route A — bug fixes and regressions

Select this route for bugs, regressions, build or test failures, performance problems, unexpected behavior, diagnoses that include implementation, and requests for the smallest or safest correction.

1. Read `references/originals/minimal-change-fix/SKILL.md` completely.
2. Use the smallest safe and correct change set.
3. Preserve public contracts, existing behavior outside the defect, unrelated code, comments, formatting, naming, and structure.
4. Prefer one focused file and no new abstractions, dependencies, migrations, configuration, or public API changes.
5. Diagnose the root cause and change the responsible path rather than refactoring nearby code.
6. Validate only the affected path first; run broader checks only in proportion to risk.
7. Read `references/originals/write-clean-readable-code/SKILL.md` only when the fix requires meaningful new TypeScript, JavaScript, Angular, or similar application code. Apply its clarity guidance inside the necessary fix boundary without expanding the diff.
8. Do not apply the aggressive structural guidance from `code-refactorer` unless the user separately requests a refactor.

### Route B — refactoring

Select this route only when the user explicitly asks to refactor, clean up, restructure, reorganize, decouple, apply SOLID, split a god unit, introduce dependency injection, remove structural duplication, or move code into layers while preserving behavior.

1. Read `references/originals/code-refactorer/SKILL.md` completely.
2. Read `references/originals/write-clean-readable-code/SKILL.md` completely.
3. Freeze observable behavior: outputs, side effects, errors and error types, messages, ordering, timing, logs, `null` versus `undefined`, precision, and async behavior.
4. Refactor the requested scope thoroughly and aggressively enough to remove the named structural smell, but do not wander into unrelated files.
5. Preserve existing comments unless they become false, obsolete, misleading, or move with the code being refactored. Do not delete comments merely as cleanup.
6. Use small, reversible, mechanically safe moves and verify after each move.
7. Note bugs and missing features without fixing them. If the user also requests a correctness change, separate it into Route A before the refactor unless the user specifies another safe order, and label the behavior change clearly.
8. Apply the architecture, layering, naming, SOLID, encapsulation, boundary, safe-move, and reporting guidance from `code-refactorer`, adapted to the repository's established local patterns and the explicit target.

### Route C — new or modified code

Select this route for features, enhancements, ordinary code changes, new components or services, read-only code-quality reviews, and implementation requests that are neither primarily a defect correction nor an explicit structural refactor.

1. Read `references/originals/write-clean-readable-code/SKILL.md` completely.
2. Produce the smallest straightforward implementation that clearly expresses the requested behavior.
3. Preserve existing behavior, contracts, code, comments, and local patterns outside the requested change.
4. Prioritize a scannable main flow, clear names, precise types, focused helpers, explicit loading and error states, and understandable control flow.
5. Remove meaningful duplication only inside the requested change. Do not perform unrelated cleanup, formatting, restructuring, modernization, or deletion.
6. Do not introduce architectural layers, base classes, generic factories, strategies, custom operators, or utility frameworks unless the requested feature genuinely requires them.
7. For Angular, default to basic `subscribe({ next, error })` and the complete Angular guidance in the routed source. Do not introduce advanced RxJS operators, signals, state management, or typed-form machinery merely as a cleanliness improvement.
8. For a review-only request, inspect and report evidence-backed findings without editing files unless the user also asks for changes.

### Mixed requests

When a request combines modes:

1. Split the work into explicit phases.
2. Apply Route A to correctness changes first unless the user specifies another safe order.
3. Apply Route C to requested feature behavior.
4. Apply Route B only to explicitly requested restructuring.
5. Keep behavior changes separate from behavior-preserving moves in the diff, validation, and report.
6. Never let permission to refactor broaden the requested feature or fix, and never let a feature request imply permission for general refactoring.

If intent is ambiguous, prefer Route A's preservation and minimal-diff constraints. Ask only when choosing a route would materially change scope or behavior.

## Conflict resolution

The routed mode has precedence over guidance intended for another mode. Preserve every source instruction through these explicit resolutions:

### Smallest diff versus aggressive restructuring

- In Route A, the smallest safe diff wins. Aggressive restructuring is forbidden unless strictly necessary to fix the root cause and explicitly disclosed.
- In Route B, aggressive structural improvement applies inside the immediate requested scope; minimality means no unrelated files or behavior changes, not leaving the requested smell in place.
- In Route C, use a straightforward local design. Refactor existing structures only as much as the requested change requires.

### Preserve code and comments versus delete dead code and scaffolding

- Preserve existing code and comments by default in every route.
- In Route A and Route C, do not delete dead code, unused parameters, obsolete comments, or scaffolding unless their removal is strictly required for the requested result.
- In Route B, removal is allowed only when it is part of the explicitly scoped refactor, behavior is preserved, references prove it is unused, and the removal makes the target structure complete. Preserve or move still-accurate comments; update only comments made false by the refactor.

### Preserve public contracts versus change contracts during refactoring

- Preserve public contracts in Route A and Route C unless the requested behavior cannot be implemented safely without a contract change.
- In Route B, a contract may change only as a behavior-preserving structural move. Use expand/migrate/contract sequencing, update every caller and test, and keep the supported external behavior identical.

### No new abstractions versus SOLID, interfaces, OOP, and dependency injection

- In Route A, prefer a local fix and introduce no abstraction unless it is required for correctness and reduces the total change surface.
- In Route C, extract a helper, service, or utility only under the reuse, ownership, or independent-testability criteria in `write-clean-readable-code`.
- In Route B, apply accurate SOLID and default OOP encapsulation where evidence supports it. An interface must have a real second implementation, genuine test seam, or true policy/detail boundary. YAGNI overrides speculative SOLID.

### Local repository patterns versus the target layered architecture

- Always inspect and follow the closest established sibling and repository rules.
- Apply the `code-refactorer` target architecture only when Route B is active and the requested refactor concerns architecture or ownership.
- Adapt folder names and deployment structure while preserving dependency direction and boundary roles. Do not impose layer-based organization on a legitimately feature-centric codebase without an explicit architectural request.

### Behavior frozen versus requested behavior changes

- Freeze all behavior outside the user's requested delta.
- Route B freezes all observable behavior.
- Routes A and C permit only the correctness or feature behavior explicitly requested; everything else remains frozen.

### Existing tests versus new tests

- Use the compiler and existing focused tests first in every route.
- Route A may add one focused regression test when useful.
- Route B adds only the smallest characterization test when untyped logic lacks existing coverage and a move could silently change output; do not build a new suite merely to permit refactoring.
- Route C tests the requested behavior in proportion to risk without refactoring test infrastructure.

### Commit every refactor step versus repository and user authority

- Preserve the source intent: keep each refactor move independently understandable, reversible, and verified.
- Create one commit per move only when the user requested commits or repository instructions require them and commit authority is available.
- Otherwise do not create unsolicited commits; keep the working diff partitioned conceptually and report the verified moves.

### Angular simplicity versus advanced reactive patterns

- Basic subscriptions and small named dependent-request methods are the default.
- Use `forkJoin`, `switchMap`, `mergeMap`, `combineLatest`, `firstValueFrom`, `lastValueFrom`, custom operators, or other complex observable chains only when the user explicitly requests RxJS or the existing codebase already uses the pattern confidently and the task requires it.

## Universal workflow

### 1. Establish scope and invariants

1. Read the target code, directly used services, DTOs, templates, interfaces, tests, and closest sibling implementation.
2. Identify the user's requested behavior or structural target.
3. State what must remain unchanged.
4. Inspect the worktree and preserve user changes.
5. List callers, contracts, flows, and likely breakpoints.
6. Choose Route A, B, C, or explicit mixed phases.

### 2. Plan the smallest complete approach

- Reuse established utilities and patterns.
- Prefer a local change over a new layer except in an explicit architectural refactor.
- Avoid speculative options, flags, hooks, shims, defenses, fallbacks, caching, logging, and abstractions.
- Explain any necessary expansion beyond the normal change budget before implementing it.
- Keep comments and formatting stable unless the requested change makes a local edit necessary.

### 3. Implement safely

- Make incremental edits.
- Keep the main execution path easy to scan.
- Use early returns when they reduce nesting.
- Name domain intent rather than mechanics.
- Strengthen types without broadening scope.
- Keep I/O and framework details at boundaries.
- Preserve dependency direction.
- Use the safe mechanics from `code-refactorer` for extract, contract migration, seam introduction, conditional replacement, type-driven change, and rename operations.
- Never combine unrelated operations into dense code or hide business rules behind generic helpers.

### 4. Validate proportionally

- Run the narrowest relevant typecheck, test, build, or reproduction first.
- In refactors, typecheck and test after every meaningful move.
- Check silent behavioral drift by inspection.
- Report pre-existing and unrelated warnings separately.
- If a check cannot run, state exactly what failed or was skipped.

### 5. Audit the complete diff

For every changed line, ask:

- Is it required by the selected route and user request?
- Is it directly connected to the defect, feature, or named structural smell?
- Can it be removed while keeping the result correct and complete?
- Does it alter unrelated behavior, code, comments, contracts, formatting, or architecture?
- Is it formatting noise, speculative defense, or cleanup?
- Is there a smaller equally safe implementation?

Remove every change that fails the audit.

## New and modified code quality

Apply all detailed priorities, preferred patterns, simplicity guardrails, size heuristics, TypeScript and Angular guidance, and final-review checks from `references/originals/write-clean-readable-code/SKILL.md`.

In particular:

- Preserve behavior and public contracts first.
- Optimize for the next developer reading the code.
- Keep lifecycle methods short.
- Let public event handlers describe the flow.
- Extract only substantial details or meaningful duplication.
- Prefer declarative configuration and domain names.
- Use small local interfaces instead of broad `any`.
- Keep forms responsible for validation and payload creation and list pages responsible for loading, filtering, and opening forms.
- Ensure loading and error state cannot get stuck.
- Do not introduce a base class for one or two components.
- Treat the source size heuristics as review signals, not hard limits.

## Refactoring architecture and standards

When Route B applies, follow the complete architecture and standards in `references/originals/code-refactorer/SKILL.md`, including:

- the backend, frontend, root-shared, transport, configuration, middleware, and leaf-shared layer definitions;
- dependency direction and the controller, repository, client, API, and transport seams;
- routing questions and the adaptable target folder structure;
- understanding-before-moving questions;
- clarity, naming, lean-code, type, encapsulation, boundary, and accurate SOLID checks;
- structural smells;
- mechanically safe change sequences;
- compiler-first and existing-test validation;
- scope, commit, final-review, and reporting requirements;
- all included examples, including the Cart encapsulation example.

Do not preemptively add a `domain/` layer. Do not treat the example structure as a mandate. Keep the invariant that a recursive folder listing should reveal units and layers when architectural restructuring is actually requested.

## Mode-specific reporting

### Route A report

Use:

1. Root Cause
2. Minimal Fix
3. Changed Files
4. Intentionally Unchanged
5. Validation
6. Diff Audit

Confirm that no unrelated refactoring, unnecessary files, or formatting-only changes remain.

### Route B report

Report:

1. Smell → principle → fix, with `file:line`
2. Behavior preserved by
3. Deliberately not done

Also state any separate correctness change distinctly.

### Route C report

Lead with the outcome. Summarize the requested behavior, directly changed files, focused validation, and any relevant unchanged boundaries. Keep the report concise and readable.

## Decision rule

When multiple safe approaches exist, select the route-appropriate solution that changes fewer unrelated lines, introduces fewer unnecessary concepts, preserves more behavior and comments, remains complete for the user's request, and is easiest to review and reverse.
