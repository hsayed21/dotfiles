---
paths:
  - "**/*.ts"
  - "**/*.html"
  - "**/*.scss"
  - "**/*.component.ts"
---

# Angular/TypeScript Hooks

> Extends [common/hooks.md](../common/hooks.md)

## PostToolUse Hooks

- **Prettier** — Auto-format TS/HTML/SCSS files
- **ng lint** — Run Angular ESLint after editing
- **tsc --noEmit** — Type check after editing .ts files
- **console.log warning** — Warn about debug logging in edited files

## Stop Hooks

- **console.log audit** — Check all modified files for debug logging
- **ng build --configuration production** — Verify production build before major merges
