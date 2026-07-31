---
name: maintain-code
description: Make safe, maintainable application-code changes and reviews with explicit routing for bug fixes and regressions, behavior-preserving refactors, and new or modified code. Use whenever Codex is asked to fix a bug, regression, build failure, performance problem, or unexpected behavior; refactor, clean up, reorganize, decouple, apply SOLID, split a god class or component, remove duplication, introduce dependency injection, or change architecture; review code for clarity, readability, maintainability, duplication, naming, typing, branching, async flow, or structure; or write and modify TypeScript, JavaScript, Angular, C#, and similar application code. Route fixes to the smallest safe diff, explicit refactors to behavior-preserving structural improvement, and reviews or general changes to concise readable guidance or implementation.
---

# Maintain Code

Apply one unified discipline to code changes while selecting the correct operating mode for the user's actual request.

## Standalone operating rule

This file contains the consolidated guidance for fixes, refactors, reviews, and ordinary code changes. Do not depend on legacy source skills or broaden one route with permissions from another.

## Routing rules

Classify the request before editing. User intent and explicit scope control the route.

### Route A — bug fixes and regressions

Select this route for bugs, regressions, build or test failures, performance problems, unexpected behavior, diagnoses that include implementation, and requests for the smallest or safest correction.

1. Use the smallest safe and correct change set.
2. Preserve public contracts, existing behavior outside the defect, unrelated code, comments, formatting, naming, and structure.
3. Prefer one focused file and no new abstractions, dependencies, migrations, configuration, or public API changes.
4. Diagnose the root cause and change the responsible path rather than refactoring nearby code.
5. Validate only the affected path first; run broader checks only in proportion to risk.
6. Apply this skill's clarity guidance when the fix requires meaningful new application code, but never expand the fix boundary for cleanup.
7. Do not apply aggressive structural guidance unless the user separately requests a refactor.

Use a default change budget of one file, avoid more than three files, and prefer no new files. Exceed it only when a correct fix requires it, and explain every extra file or structural change. Do not hide errors, disable behavior, suppress warnings, or hardcode a special case unless it is an actual business rule. Do not add speculative null checks, try/catch blocks, retries, logging, fallbacks, flags, compatibility layers, or caching.

For performance work, measure or identify the real bottleneck, change only the hot path, compare the same scenario before and after, and report evidence and trade-offs. Avoid broad rewrites, unrelated algorithm changes, and insignificant micro-optimizations.

### Route B — refactoring

Select this route only when the user explicitly asks to refactor, clean up, restructure, reorganize, decouple, apply SOLID, split a god unit, introduce dependency injection, remove structural duplication, or move code into layers while preserving behavior.

1. Freeze observable behavior: outputs, side effects, errors and error types, messages, ordering, timing, logs, `null` versus `undefined`, precision, and async behavior.
2. Refactor the requested scope thoroughly and aggressively enough to remove the named structural smell, but do not wander into unrelated files.
3. Preserve existing comments unless they become false, obsolete, misleading, or move with the code being refactored. Do not delete comments merely as cleanup.
4. Use small, reversible, mechanically safe moves and verify after each move.
5. Note bugs and missing features without fixing them. If the user also requests a correctness change, separate it into Route A before the refactor unless the user specifies another safe order, and label the behavior change clearly.
6. Apply the architecture, layering, naming, SOLID, encapsulation, boundary, safe-move, and reporting guidance below, adapted to the repository's established local patterns and the explicit target.

### Route C — new or modified code

Select this route for features, enhancements, ordinary code changes, new components or services, read-only code-quality reviews, and implementation requests that are neither primarily a defect correction nor an explicit structural refactor.

1. Produce the smallest straightforward implementation that clearly expresses the requested behavior.
2. Preserve existing behavior, contracts, code, comments, and local patterns outside the requested change.
3. Prioritize a scannable main flow, clear names, precise types, focused helpers, explicit loading and error states, and understandable control flow.
4. Remove meaningful duplication only inside the requested change. Do not perform unrelated cleanup, formatting, restructuring, modernization, or deletion.
5. Do not introduce architectural layers, base classes, generic factories, strategies, custom operators, or utility frameworks unless the requested feature genuinely requires them.
6. For Angular, default to basic `subscribe({ next, error })` and the Angular guidance below. Do not introduce advanced RxJS operators, signals, state management, or typed-form machinery merely as a cleanliness improvement.
7. For a review-only request, inspect and report evidence-backed findings without editing files unless the user also asks for changes.

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
- In Route C, extract a helper, service, or utility only under the reuse, ownership, or independent-testability criteria below.
- In Route B, apply accurate SOLID and default OOP encapsulation where evidence supports it. An interface must have a real second implementation, genuine test seam, or true policy/detail boundary. YAGNI overrides speculative SOLID.

### Local repository patterns versus the target layered architecture

- Always inspect and follow the closest established sibling and repository rules.
- Apply the target architecture below only when Route B is active and the requested refactor concerns architecture or ownership.
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
- Use the safe mechanics below for extract, contract migration, seam introduction, conditional replacement, type-driven change, and rename operations.
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

Apply these priorities in order:

1. Preserve behavior and public contracts.
2. Make the main path easy to scan from top to bottom.
3. Remove meaningful duplication inside scope.
4. Reduce file and method size when the selected route permits it.
5. Strengthen names, types, error handling, and state ownership.
6. Match the implementation to the user's current knowledge.
7. Avoid abstractions that cost more understanding than they save.

### Preferred patterns

- Keep lifecycle methods short: initialize state and start required loads.
- Let public event handlers describe the flow; extract only substantial details.
- Use early returns to reduce nesting.
- Share add/update success and error handling when basic control flow remains clear.
- Filter collections with one readable predicate when several filters apply together.
- Use small local interfaces for events, filters, modal results, and request values instead of broad `any`.
- Use immutable transformations when they make state transitions obvious.
- Keep configuration arrays declarative and separate from behavioral methods.
- Prefer domain names such as `loadCategories`, `openCategoryForm`, and `confirmDeactivation` over vague names such as `handleData` or `process`.
- Extract a helper when it removes meaningful duplication, names a business rule, or clarifies a long method.
- Extract a service or utility only when logic is reused, independently testable, or does not belong to the component.

### Simplicity guardrails and size signals

- Do not introduce a base class for one or two components.
- Do not create generic factories, strategies, custom operators, or utility layers for one simple use case.
- Do not trade clear names for abbreviations, hide business rules behind generic helpers, or combine unrelated work into dense one-liners.
- Do not split a short cohesive method merely to reduce its line count.
- Do not remove apparently unused code until references and intended behavior are checked.
- Treat methods over roughly 30-40 lines, nesting beyond two or three levels, repeated blocks of five meaningful lines, and components approaching several hundred lines as review signals, not hard limits.
- Reduce a 1,000-line component by responsibility boundaries, not formatting tricks.

### TypeScript and Angular

- Type event payloads, filter models, modal results, and API request values.
- Use basic `subscribe({ next, error })` by default and set loading state explicitly in both paths.
- When one request depends on another, prefer small named methods for each step over a visibly nested subscription block.
- Keep forms responsible for validation and payload creation; keep list pages responsible for loading, filtering, and opening forms.
- Open the same add/edit modal through one method with an optional ID.
- Put complicated confirmation rules in small named methods with clear parameters.
- Do not introduce advanced RxJS, signals, state management, or typed-form machinery merely as a cleanliness improvement.

Before finishing, re-read the code at a junior or mid-level developer's altitude. Undo clever compression or indirection. Confirm the main flow is understandable, every extraction has one reason to exist, loading and error state cannot get stuck, and relevant add, edit, cancel, validation, filtering, and status flows remain correct.

## Refactoring architecture and standards

Use this section only when Route B applies. Adapt folder names to the repository and keep established local patterns where they already express clear ownership. A legitimately feature-centric codebase may remain feature-centric.

### Layer responsibilities

Backend:

- `controllers/`: inbound delivery. Parse the request, call one service, and shape the response. Keep out business rules and database access.
- `services/`: business workflows, policy, orchestration, and transactions. Depend on interfaces rather than HTTP, SQL, ORM, or provider details.
- `repositories/`: owned persistence behind interfaces. This is the only layer that knows the database, filesystem, SQL, or ORM.
- `clients/`: outbound adapters for third-party APIs behind interfaces. Translate provider data without making business decisions.
- `models/`: one source of truth for entities and value objects. Split boundary DTOs only when exposed shapes genuinely differ or a field must remain hidden.
- `transport/`: protocol, connection lifecycle, serialization, headers, retries, and reconnects. Keep out business meaning.
- `config/`: environment, settings, feature flags, dependency injection, and the composition root.
- `middleware/`: cross-cutting inbound concerns such as auth, logging, and error mapping.
- `shared/`: pure leaf utilities that import no application layer.

Frontend:

- `ui/`: presentation-only components, views, and screens.
- `state/`: stores, hooks, and view logic; call the API layer, never backend internals.
- `api/`: domain-meaningful backend calls and model mapping without protocol mechanics.
- `transport/`: HTTP, WebSocket, or RPC client mechanics.
- `shared/`: pure leaf utilities.

At a full-stack repository root, `shared/` may contain the typed client-server contract. Keep it distinct from each application's utility folder. Do not add a `domain/` layer by default; reserve it for genuinely complex domain modeling with domain experts.

### Dependency direction and placement

Backend calls flow `controller -> service -> repository/client`. Services own policy and depend on contracts; concrete repositories and clients implement those contracts; `config` wires them. No SQL or ORM type may leak into a service signature, no provider type may escape a client, and no wire detail may surface above transport. Frontend flow is `ui -> state -> api -> transport`.

Use these routing questions:

- Does the outside world call in? Place the adapter in `controllers/`.
- Is it a business rule or workflow? Place it in `services/`.
- Does it read or write owned persistence? Place it in `repositories/`.
- Does it call someone else's API? Place it in `clients/`.
- Is it a data shape? Place it in `models/` or the true boundary contract.
- Is it protocol, sockets, serialization, retries, or reconnects? Place it in `transport/`.
- Is it wiring, settings, or flags? Place it in `config/`.
- Is it pure and reused with no application dependencies? Place it in `shared/`.

If one file answers several questions, split it at those boundaries. Prefer a recursive tree that reveals deployment units and layers before files are opened, but do not impose a sample structure merely for conformity.

### Understand before moving

- Restate the exact requested scope and frozen observable behavior.
- Map current units to their roles and intended destinations.
- Read the closest sibling in full and follow its established pattern.
- Read controlling interfaces, base types, callers, and existing tests.
- List contracts and flows each move could break.

### Clarity, naming, types, and encapsulation

- Make ownership obvious and keep public surfaces small.
- Tighten types so invalid internal states cannot be constructed where practical.
- Name intent rather than mechanics or encoded types. Use verbs for functions, nouns for values, and positive predicates for booleans.
- Make cost and side effects audible: prefer `fetch`, `load`, or `query` for I/O and `commit`, `flush`, or `invalidate` for mutation.
- Use one domain term per concept and symmetric opposites.
- Replace vague noise names such as `Manager`, `Helper`, `Util`, `Data`, `Processor`, `handle`, and `Impl` with the actual role when scope permits.
- Include units at boundaries, such as `timeoutMs` and `sizeBytes`.
- Prefer precise types, discriminated unions, literals, and focused interfaces over `any`, broad strings, casts, and loose object bags.
- Never suppress compiler errors to make a refactor pass. Validate untrusted input at the boundary instead of trusting a cast.
- Encapsulate related mutable state and its invariants behind a cohesive class with a small public interface. If multiple functions share or mutate the same state, consider moving them with that state. Leave genuinely pure, stateless transforms as functions.
- Expose members intentionally and keep invariant-sensitive primitives private.

### Lean code and accurate SOLID

- Extend an existing pattern when it makes the total system smaller.
- Reject speculative options, flags, hooks, wrappers, shims, and abstractions.
- Remove pass-through wrappers, dead code, unused parameters, obsolete comments, and scaffolding only within the explicit Route B scope and only after proving they are unreferenced and behavior-neutral.
- A few repeated lines may be clearer than premature abstraction; repeated lifecycles, files, or branches may indicate a missing shared shape.
- **SRP:** split by actor or reason to change, such as policy, rendering, persistence, and I/O, rather than the folklore of “does one thing.”
- **OCP:** replace growing variant conditionals with a registry, strategy, or polymorphic contract only when doing so reduces the total change.
- **LSP:** narrow or split a base abstraction when callers need type checks or implementations require no-op or unsupported methods.
- **ISP:** split fat contracts and unrelated option bags into caller-specific roles, such as reader and writer.
- **DIP:** make high-level policy and low-level details depend on a true abstraction and wire the concrete implementation at one composition root.
- An interface earns its place only through a real second implementation, genuine test seam, or true policy-detail boundary.

### Structural smells

Look for import-time side effects, god units, duplicated domain logic, missing timer or socket disposal, inconsistent boundary error mapping, silent invalid-input filtering, effect over-invalidation, hard-coded configuration inside logic, business rules in controllers or clients, and infrastructure details leaking into services.

### Mechanically safe moves

- **Extract:** copy logic to the new unit, make the old site delegate, verify, then delete the old body.
- **Change a contract:** add the new shape beside the old, migrate callers incrementally, then remove the unreferenced old shape.
- **Introduce a seam:** derive the interface from current usage, make the concrete implement it, inject it, and wire it at one composition root.
- **Replace a conditional:** establish equivalent dispatch, move one branch at a time, then remove the empty conditional.
- **Type-driven change:** change the definition and let compiler errors enumerate callers; fix every error instead of relying only on text search.
- **Rename:** use a type-aware rename so every reference moves together.

Never disguise a rewrite as a refactor. If behavior-preserving moves cannot reach the target, stop and flag the rewrite as a separate decision.

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
