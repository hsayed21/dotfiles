---
paths:
  - "**/*.cs"
  - "**/*.csx"
---

# C# & .NET Patterns

> Extends [common/patterns.md](../common/patterns.md)

## API Response Pattern

```csharp
public sealed record ApiResponse<T>(
    bool Success,
    T? Data = default,
    string? Error = null,
    object? Meta = null);
```

## Result Pattern (for service layers)

```csharp
public sealed record Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string? Error { get; }

    private Result(bool success, T? value, string? error) =>
        (IsSuccess, Value, Error) = (success, value, error);

    public static Result<T> Success(T value) => new(true, value, null);
    public static Result<T> Failure(string error) => new(false, default, error);
}
```

## Repository Pattern

```csharp
public interface IRepository<T> where T : class
{
    Task<IReadOnlyList<T>> FindAllAsync(CancellationToken ct);
    Task<T?> FindByIdAsync(Guid id, CancellationToken ct);
    Task<T> CreateAsync(T entity, CancellationToken ct);
    Task<T> UpdateAsync(T entity, CancellationToken ct);
    Task DeleteAsync(Guid id, CancellationToken ct);
}
```

## Options Pattern (Config)

```csharp
public sealed class PaymentOptions
{
    public const string SectionName = "Payment";
    public required string BaseUrl { get; init; }
    public required string ApiKeySecretName { get; init; }
    public int TimeoutSeconds { get; init; } = 30;
}

// Register in Program.cs
builder.Services.Configure<PaymentOptions>(
    builder.Configuration.GetSection(PaymentOptions.SectionName));

// Use via IOptions<T> (singleton), IOptionsSnapshot<T> (scoped), or IOptionsMonitor<T> (reloadable)
```

## Dependency Injection

- Depend on interfaces, not concretions
- Constructor injection (preferred) or `[FromServices]` for Minimal APIs
- If a constructor needs >5 dependencies, split the class

```csharp
services.AddScoped<IOrderRepository, EfOrderRepository>();
services.AddSingleton<ICacheService, RedisCacheService>();
services.AddTransient<IEmailSender, SmtpEmailSender>();
```

## Middleware Pattern

```csharp
public sealed class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next,
        ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var sw = Stopwatch.StartNew();
        await _next(context);
        sw.Stop();
        _logger.LogInformation("{Method} {Path} → {StatusCode} ({Elapsed}ms)",
            context.Request.Method, context.Request.Path,
            context.Response.StatusCode, sw.ElapsedMilliseconds);
    }
}

app.UseMiddleware<RequestLoggingMiddleware>();
```

## Endpoint Route Groups (Minimal APIs)

```csharp
public static class OrderEndpoints
{
    public static RouteGroupBuilder MapOrderEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/orders")
            .RequireAuthorization()
            .WithTags("Orders");

        group.MapGet("/", GetOrders);
        group.MapGet("/{id:guid}", GetOrder);
        group.MapPost("/", CreateOrder);
        group.MapPut("/{id:guid}", UpdateOrder);
        group.MapDelete("/{id:guid}", DeleteOrder);

        return group;
    }
}

// Program.cs
app.MapOrderEndpoints();
```
