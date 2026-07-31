---
paths:
  - "**/*.cs"
  - "**/*.csx"
---

# C# Coding Style

> Extends [common/coding-style.md](../common/coding-style.md)

## .NET Standards

- Follow official .NET naming conventions and enable **nullable reference types** in all projects
- Prefer explicit access modifiers; avoid `public` on interface members
- Keep one primary type per file; file name matches type name
- Use `dotnet format` for consistent formatting and analyzer fixes

```xml
<!-- Directory.Build.props -->
<Project>
  <PropertyGroup>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <AnalysisMode>Recommended</AnalysisMode>
  </PropertyGroup>
</Project>
```

## Types and Models

- `record` / `record struct` — immutable value-like models (DTOs, request/response)
- `class` — entities with identity and lifecycle
- `interface` — service boundaries and abstractions
- `sealed` — default for classes not designed for inheritance

```csharp
// DTOs as records — immutable, value equality
public sealed record OrderDto(Guid Id, string CustomerName, string Status);

// Entities as classes — identity-based
public sealed class Order
{
    public Guid Id { get; private set; }
    public string CustomerName { get; private set; } = null!;
    public OrderStatus Status { get; private set; }
}
```

## Immutability (CRITICAL)

```csharp
// GOOD: record with `with` expression
public sealed record UserProfile(string Name, string Email);

public static UserProfile Rename(UserProfile profile, string name) =>
    profile with { Name = name };

// GOOD: Init-only properties
public sealed class CreateOrderRequest
{
    public Guid CustomerId { get; init; }
    public IReadOnlyList<OrderItemDto> Items { get; init; } = Array.Empty<OrderItemDto>();
}

// BAD: public setters on DTOs
public class BadDto { public string Name { get; set; } } // mutability for no reason
```

## Async & Cancellation (CRITICAL)

```csharp
// EVERY async method that crosses I/O takes CancellationToken
public async Task<OrderDto?> GetOrderAsync(Guid id, CancellationToken ct)
{
    return await _db.Orders
        .AsNoTracking()
        .FirstOrDefaultAsync(o => o.Id == id, ct);
}

// NEVER block async
var order = service.GetOrderAsync(id, ct).Result;    // BAD — deadlock risk
var order = await service.GetOrderAsync(id, ct);       // GOOD

// NEVER async void except event handlers
async void Save() { ... }      // BAD — unhandled exceptions crash the process
async Task SaveAsync() { ... }  // GOOD
```

## Error Handling

```csharp
// Throw specific exceptions with context
throw new OrderNotFoundException(orderId);

// Log structured details, return safe messages to callers
catch (Exception ex)
{
    _logger.LogError(ex, "Failed to process order {OrderId}", orderId);
    throw; // or return a safe result
}

// NEVER swallow exceptions silently
catch { }               // BAD
catch (Exception) { }   // BAD
```

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Types, classes, records | PascalCase | `OrderService`, `OrderDto` |
| Interfaces | PascalCase + I | `IOrderRepository` |
| Methods | PascalCase | `GetOrderAsync()` |
| Properties | PascalCase | `CustomerName` |
| Private fields | _camelCase | `_dbContext`, `_logger` |
| Local variables | camelCase | `order`, `customerId` |
| Parameters | camelCase | `orderId`, `cancellationToken` |
| Constants | PascalCase | `MaxRetryCount` |

## Expression-Bodied Members

Use when they stay readable:

```csharp
// GOOD: simple and clear
public string FullName => $"{FirstName} {LastName}";
public static OrderId New() => new(Guid.NewGuid());

// BAD: too complex for expression body
public string Description => Items.Where(i => i.Price > 0).Select(i => $"{i.Name}: {i.Price}").Aggregate((a, b) => $"{a}, {b}");
```
