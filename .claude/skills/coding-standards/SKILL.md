---
name: coding-standards
description: Cross-project coding conventions for .NET and Angular — naming, immutability, error handling, code quality review, and best practices.
---

# Coding Standards

Baseline conventions for full-stack .NET + Angular development.

For framework-specific patterns:
- **C#/.NET**: `dotnet-patterns`, `backend-patterns`
- **Angular/TypeScript**: `frontend-patterns`
- **API Design**: `api-design`
- **Security**: `security-review`

## When to Activate

- New project or module setup
- Code review for quality and maintainability
- Refactoring to follow conventions
- Enforcing naming, formatting, or structural consistency

## Core Principles

### KISS (Keep It Simple)
- Simplest solution that works. No over-engineering.
- Avoid premature optimization — profile first.

### DRY (Don't Repeat Yourself)
- Extract repeated logic into shared functions/services.
- But wait for 3+ repetitions before abstracting.

### YAGNI (You Aren't Gonna Need It)
- Don't build features or abstractions before they're needed.
- Start simple, refactor when pressure is real.

## Immutability (CRITICAL)

**C#**: Use `record`, `init` setters, `with` expressions
**TypeScript/Angular**: Use spread operator, `signal.update()`, never mutate in place

```typescript
// BAD: mutation
this.items.push(newItem)
user.name = newName

// GOOD: immutability
this.items.update(current => [...current, newItem])
const updated = { ...user, name: newName }
```

```csharp
// BAD: mutation
order.Status = OrderStatus.Shipped;
order.Items.Add(newItem);

// GOOD: immutable pattern
public Order Ship() => this with { Status = OrderStatus.Shipped };
```

## Error Handling

- Handle errors explicitly at every level
- User-friendly messages in UI
- Structured logging server-side with `ILogger`
- Never silently swallow exceptions

```csharp
// C# — structured logging
catch (Exception ex)
{
    _logger.LogError(ex, "Failed to process order {OrderId}", orderId);
    throw; // or return safe result
}
```

```typescript
// Angular — graceful degradation
this.http.get<Order[]>('/api/orders').pipe(
  catchError(err => {
    console.error('Failed to load orders', err)
    return of([]) // safe fallback
  })
)
```

## Input Validation

Validate at EVERY system boundary:

- **C#**: FluentValidation, DataAnnotations, or guard clauses
- **Angular**: Zod schemas, reactive form validators
- Never trust external data (API responses, user input, file uploads)

## Naming Conventions

| Context | Style | Example |
|---------|-------|---------|
| C# types | PascalCase | `OrderService` |
| C# methods | PascalCase | `GetOrderAsync()` |
| C# private fields | _camelCase | `_dbContext` |
| Angular components | PascalCase | `OrderCardComponent` |
| Angular services | PascalCase | `OrderService` |
| TS variables/functions | camelCase | `getOrders()`, `isLoading` |
| Signals | camelCase | `items`, `count` |
| Observables | camelCase + $ | `orders$` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRIES` |

## Code Smells to Avoid

- **Long functions** (>50 lines) — extract helpers
- **Large files** (>800 lines) — split by responsibility
- **Deep nesting** (>4 levels) — use early returns/guard clauses
- **Magic numbers** — use named constants
- **Dead code** — commented-out code, unreachable branches
- **Silent failures** — empty catch blocks, swallowed exceptions
