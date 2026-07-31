# Source Coverage and Conflict Audit

## Purpose

This file records how `maintain-code` preserves and routes every source skill. The exact source artifacts remain bundled under `references/originals/`; their SHA-256 hashes are verified by `scripts/verify_source_integrity.py`.

## Complete source artifacts

| Source skill | Complete instructions | Supporting resources |
|---|---|---|
| `minimal-change-fix` | `originals/minimal-change-fix/SKILL.md` | `originals/minimal-change-fix/agents/openai.yaml` |
| `write-clean-readable-code` | `originals/write-clean-readable-code/SKILL.md` | `originals/write-clean-readable-code/agents/openai.yaml` |
| `code-refactorer` | `originals/code-refactorer/SKILL.md` | None in the source directory |

The inventory found no source scripts, references, or assets beyond the metadata files listed above.

## Routing coverage

### `minimal-change-fix`

- Description and triggers → Route A metadata and routing.
- Establish Change Boundary → Universal workflow step 1 and the complete original.
- Minimize the Diff → Route A and Universal workflow step 2.
- Preserve Existing Behavior → Route A and conflict resolution.
- Forbid Unrelated Work → preservation rules and diff audit.
- Avoid New Abstractions → abstraction conflict resolution.
- Avoid Speculative Defenses → Universal workflow step 2.
- Prevent Formatting Noise → preservation rules and diff audit.
- Handle Performance Problems → Route A through the complete original.
- Keep Tests and Validation Focused → validation conflict resolution.
- Handle Necessary Scope Expansion → Universal workflow step 2.
- Audit the Final Diff → Universal workflow step 5.
- Report the Result → Route A reporting.
- Decision Rule → unified decision rule.

### `write-clean-readable-code`

- Description and triggers, including review-only requests → Route C metadata and routing.
- Priorities → New and modified code quality and the complete original.
- Workflow → Universal workflow and Route C.
- Preferred Patterns → New and modified code quality and the complete original.
- Simplicity Guardrails → Route C, conflict resolution, and the complete original.
- Size Heuristics → New and modified code quality.
- TypeScript and Angular Guidance → Route C and Angular conflict resolution.
- Final Review → validation and diff audit.

### `code-refactorer`

- Mission, aggressive structure, frozen behavior, immediate scope, stepwise commits → Route B and conflict resolution.
- Target architecture, folders, dependency rule, boundary adapters, routing questions, and structure → Refactoring architecture and the complete original.
- Understand before moving → Universal workflow step 1.
- Clarity, naming, lean code, types, encapsulation, boundaries, and SOLID → Route B and the complete original.
- Structural smells → Refactoring architecture and the complete original.
- Safe moves → Universal workflow step 3 and the complete original.
- Verification → Universal workflow step 4 and validation conflict resolution.
- Scope and commits → Route B and commit conflict resolution.
- Final review and reporting → Route B reporting and diff audit.
- Every example and detailed definition → preserved verbatim in the complete original.

## Explicitly resolved conflicts

1. Smallest diff versus aggressive restructuring → route by user intent.
2. Preserve code/comments versus delete dead code/scaffolding → preserve by default; remove only inside explicit refactor scope when proven and necessary.
3. Preserve contracts versus contract migration → preserve for fixes/features; use safe migration only for explicit behavior-preserving refactors.
4. Avoid abstractions versus SOLID/OOP/DI → evidence-based abstractions only, with stricter limits in fixes.
5. Local patterns versus target layers → local patterns always; architecture target only for explicit architectural refactors.
6. Frozen behavior versus requested behavior changes → freeze everything outside the explicit delta.
7. Existing tests versus new regression/characterization tests → route-specific focused tests.
8. Commit every step versus commit authority → preserve stepwise verification; commit only when authorized or required.
9. Angular simplicity versus advanced RxJS → basic patterns by default; advanced patterns only when requested or required by established code.
10. Refactorer prohibition on bug fixes/features versus mixed requests → split into labeled route phases.

## Integrity verification

Run:

```powershell
python scripts/verify_source_integrity.py
python <skill-creator>/scripts/quick_validate.py .
```

Both checks must pass before changing the trigger metadata of the source skills or considering their removal.
