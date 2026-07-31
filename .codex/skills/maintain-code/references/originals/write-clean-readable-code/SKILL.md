---
name: write-clean-readable-code
description: Refactor, review, or write application code that stays concise, readable, and maintainable without clever or excessive abstractions. Use for TypeScript, JavaScript, Angular, and similar code when Codex should remove duplication, shorten oversized components, simplify branching and async flows, extract focused helpers, improve naming and typing, or make code understandable to junior and mid-level developers while preserving behavior. Default to basic Angular subscriptions and avoid advanced RxJS unless the user explicitly requests it.
---

# Write Clean Readable Code

Produce the smallest straightforward implementation that clearly expresses the behavior. Optimize for the next developer reading the file, not for minimum character count.

## Priorities

Apply these priorities in order:

1. Preserve behavior and public contracts.
2. Make the main execution path easy to scan from top to bottom.
3. Remove meaningful duplication.
4. Reduce file and method size.
5. Strengthen names, types, error handling, and state ownership.
6. Match the implementation to the user's current knowledge.
7. Avoid abstractions that cost more understanding than they save.

## Workflow

1. Read the target code, templates, tests, DTOs, and directly used services before editing.
2. Identify behavior that must remain unchanged and existing user modifications that must be preserved.
3. Locate the highest-value complexity:
   - duplicated request or success/error blocks;
   - deeply nested conditions;
   - long methods with multiple responsibilities;
   - dead, commented-out, or unused code;
   - repeated modal, filtering, mapping, or loading flows;
   - broad `any` types where a small local interface is clearer;
   - UI components carrying reusable domain or data logic.
4. Refactor incrementally. Prefer small safe changes over a full rewrite.
5. Re-read the result as a junior or mid-level developer. Undo clever compression or indirection that makes the flow harder to follow.
6. Run the narrowest relevant typecheck, test, or build. Report unrelated warnings separately.

## Preferred Patterns

- Keep lifecycle methods short: initialize state, start required loads, and nothing more.
- Let public event handlers describe the flow; extract only substantial details into well-named private methods.
- Use early returns to avoid nesting.
- Share add/update success and error handling when this remains clear with basic control flow.
- Filter collections with one readable predicate when several filters apply together.
- Create small local interfaces for event and filter values instead of `any`.
- Use immutable transformations when they make state changes obvious.
- Keep configuration arrays declarative and separate from behavioral methods.
- Prefer domain names such as `loadCategories`, `openCategoryForm`, and `confirmDeactivation` over generic names such as `handleData` or `process`.
- Extract a helper when it removes duplication, names a business rule, or makes a long method readable.
- Extract a service or utility only when logic is reused, independently testable, or does not belong to the component.

## Simplicity Guardrails

- Do not introduce a base class for one or two components.
- Do not create generic factories, strategy patterns, custom operators, or utility layers for a single simple use case.
- Do not combine unrelated operations into dense one-liners.
- Do not trade clear names for abbreviations.
- Do not hide business rules behind generic helpers.
- Do not split a short cohesive method merely to reduce its line count.
- Do not change APIs, templates, translations, DTO contracts, or user behavior unless the request requires it.
- Do not remove code only because it appears unused until references and intended behavior are checked.
- Do not introduce advanced RxJS operators as a clean-code requirement.
- Do not use `forkJoin`, `switchMap`, `mergeMap`, `combineLatest`, `firstValueFrom`, `lastValueFrom`, custom operators, or complex observable chains unless the user explicitly requests RxJS or already uses it confidently.

## Size Heuristics

Treat these as review signals, not hard limits:

- A method over roughly 30–40 lines may contain multiple responsibilities.
- Nesting deeper than two or three levels usually benefits from early returns or extraction.
- Repeated blocks of five or more meaningful lines should usually share one path.
- A component approaching several hundred lines deserves separation of configuration, view coordination, and domain logic.
- A 1,000-line component should be reduced by responsibility boundaries, not by formatting tricks.

## TypeScript and Angular Guidance

- Type event payloads, filter models, modal results, and API request values.
- Use basic `subscribe({ next, error })` by default in Angular code.
- Set loading state explicitly in both `next` and `error` when avoiding RxJS operators.
- If one request depends on another, prefer small named methods that perform each step over a visibly nested subscription block.
- Keep forms responsible for validation and payload creation; keep list pages responsible for loading, filtering, and opening forms.
- When opening the same modal for add and edit, use one method with an optional ID.
- Put complicated confirmation rules in small named methods with clear parameters.
- Avoid adopting advanced RxJS, signals, state management, or typed-form machinery until the user asks for it or confirms they understand it.

## Final Review

Before finishing, verify:

- The main flow can be understood without jumping through many files.
- Duplication was removed without creating a generic framework.
- Every extracted method has one clear reason to exist.
- Names explain intent and avoid comments that merely restate code.
- Loading and error state cannot get stuck.
- Add, edit, cancel, validation, filtering, and status changes still behave correctly.
- The relevant build or tests pass.
