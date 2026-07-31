---
paths:
  - "**/*.cs"
  - "**/*.csx"
  - "**/*.csproj"
  - "**/appsettings*.json"
---

# C# & .NET Security

> Extends [common/security.md](../common/security.md)

## Secret Management (CRITICAL)

```csharp
// NEVER: Hardcoded secrets
const string ApiKey = "sk-live-123";
const string ConnectionString = "Server=...;Password=admin123";

// ALWAYS: Configuration + REDACTED manager
var apiKey = builder.Configuration["Payment:ApiKey"]
    ?? throw new InvalidOperationException("Payment:ApiKey not configured");

// Local dev: dotnet user-secrets
// Production: Azure Key Vault, AWS Secrets Manager, or environment variables
```

## SQL Injection Prevention (CRITICAL)

```csharp
// NEVER: String concatenation in SQL
var sql = $"SELECT * FROM Orders WHERE CustomerId = '{customerId}'"; // DANGEROUS

// ALWAYS: Parameterized queries (EF Core handles this automatically)
var orders = await _db.Orders
    .Where(o => o.CustomerId == customerId)  // EF Core parameterizes
    .ToListAsync(ct);

// Raw SQL: ALWAYS parameterize
var orders = await _db.Orders
    .FromSqlRaw("SELECT * FROM Orders WHERE CustomerId = @customerId",
        new SqlParameter("@customerId", customerId))
    .ToListAsync(ct);

// Dynamic ORDER BY / filtering: WHITELIST the column names
private static readonly HashSet<string> AllowedSortColumns = new()
    { "Id", "CustomerName", "CreatedAt", "Total" };

if (!AllowedSortColumns.Contains(sortColumn))
    throw new ArgumentException($"Invalid sort column: {sortColumn}");
```

## Input Validation

```csharp
// ALWAYS validate at the API boundary
public sealed class CreateOrderRequest
{
    [Required, MaxLength(200)]
    public string CustomerName { get; init; } = null!;

    [Required, MinLength(1)]
    public List<OrderItemDto> Items { get; init; } = null!;
}

// Or with FluentValidation
public sealed class CreateOrderValidator : AbstractValidator<CreateOrderRequest>
{
    public CreateOrderValidator()
    {
        RuleFor(x => x.CustomerName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Items).NotEmpty();
        RuleForEach(x => x.Items).ChildRules(item =>
        {
            item.RuleFor(i => i.ProductId).NotEmpty();
            item.RuleFor(i => i.Quantity).InclusiveBetween(1, 999);
        });
    }
}
```

## Authentication & Authorization

```csharp
// ALWAYS: Use framework auth, not custom token parsing
builder.Services.AddAuthentication().AddJwtBearer(/* ... */);
builder.Services.AddAuthorization();

// ALWAYS: Require auth on protected endpoints
app.MapGet("/api/orders", ...).RequireAuthorization();

// NEVER: Log raw tokens or passwords
_logger.LogInformation("User {UserId} authenticated", userId);
// NOT: _logger.LogInformation("Token: {Token}", rawToken);
```

## Safe Error Responses

```csharp
// NEVER: Expose internals to clients
catch (Exception ex)
{
    return Results.Json(new { error = ex.Message, stack = ex.StackTrace }, statusCode: 500);
}

// ALWAYS: Safe client messages + detailed server logs
catch (Exception ex)
{
    _logger.LogError(ex, "Failed to process order {OrderId}", orderId);
    return Results.Json(new { error = "An unexpected error occurred." }, statusCode: 500);
}
```

## CSRF / Antiforgery

```csharp
// For MVC/controller-based APIs with cookie auth:
builder.Services.AddAntiforgery(options =>
{
    options.HeaderName = "X-XSRF-TOKEN"; // Angular sends this by default
});

// Minimal APIs + JWT: CSRF is less critical (no cookies), but validate origin headers
```

## Path Traversal Prevention

```csharp
// NEVER: Use raw user input in file paths
var path = Path.Combine(uploadDir, userProvidedFileName); // user could use "../../etc/passwd"

// ALWAYS: Validate and sanitize
var safeName = Path.GetFileName(userProvidedFileName); // Strips directory components
var fullPath = Path.GetFullPath(Path.Combine(uploadDir, safeName));
if (!fullPath.StartsWith(Path.GetFullPath(uploadDir)))
    throw new UnauthorizedAccessException("Invalid file path");
```
