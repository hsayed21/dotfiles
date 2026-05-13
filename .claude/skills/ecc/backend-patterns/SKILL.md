---
name: backend-patterns
description: ASP.NET Core backend architecture — Minimal APIs, controllers, EF Core, MediatR, repository pattern, caching, background jobs, and server-side best practices.
---

# ASP.NET Core Backend Patterns

Backend architecture patterns for scalable .NET server applications.

## When to Activate

- Designing REST API endpoints in ASP.NET Core
- Implementing repository, service, or CQRS layers
- Optimizing EF Core queries (N+1, indexing, projections)
- Adding caching (IMemoryCache, Redis, HybridCache)
- Setting up background jobs or async processing
- Structuring error handling and validation
- Building middleware (auth, logging, rate limiting)

## API Design

### Minimal APIs (Modern .NET 8+)

```csharp
app.MapGet("/api/orders/{id:guid}", async (
    Guid id,
    OrderService service,
    CancellationToken ct) =>
{
    var order = await service.FindByIdAsync(id, ct);
    return order is null ? Results.NotFound() : Results.Ok(order);
})
.WithName("GetOrder")
.RequireAuthorization();

app.MapPost("/api/orders", async (
    CreateOrderRequest request,
    IValidator<CreateOrderRequest> validator,
    OrderService service,
    CancellationToken ct) =>
{
    var result = await validator.ValidateAsync(request, ct);
    if (!result.IsValid)
        return Results.ValidationProblem(result.ToDictionary());

    var order = await service.CreateAsync(request, ct);
    return Results.Created($"/api/orders/{order.Id}", order);
})
.RequireAuthorization();
```

### Controller-Based APIs (Traditional)

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly OrderService _service;

    public OrdersController(OrderService service) => _service = service;

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<OrderDto>> Get(Guid id, CancellationToken ct)
    {
        var order = await _service.FindByIdAsync(id, ct);
        return order is null ? NotFound() : Ok(order);
    }

    [HttpPost]
    public async Task<ActionResult<OrderDto>> Create(
        CreateOrderRequest request,
        CancellationToken ct)
    {
        var order = await _service.CreateAsync(request, ct);
        return CreatedAtAction(nameof(Get), new { id = order.Id }, order);
    }
}
```

## Consistent API Response

```csharp
public sealed record ApiResponse<T>(
    bool Success,
    T? Data = default,
    string? Error = null,
    object? Meta = null);

// Success
return Results.Ok(new ApiResponse<OrderDto>(true, Data: order));

// Error
return Results.NotFound(new ApiResponse<OrderDto>(false, Error: "Order not found"));
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

public sealed class EfRepository<T> : IRepository<T> where T : class
{
    private readonly AppDbContext _db;

    public EfRepository(AppDbContext db) => _db = db;

    public async Task<IReadOnlyList<T>> FindAllAsync(CancellationToken ct) =>
        await _db.Set<T>().AsNoTracking().ToListAsync(ct);

    public async Task<T?> FindByIdAsync(Guid id, CancellationToken ct) =>
        await _db.Set<T>().FindAsync([id], ct);

    public async Task<T> CreateAsync(T entity, CancellationToken ct)
    {
        _db.Set<T>().Add(entity);
        await _db.SaveChangesAsync(ct);
        return entity;
    }

    public async Task<T> UpdateAsync(T entity, CancellationToken ct)
    {
        _db.Set<T>().Update(entity);
        await _db.SaveChangesAsync(ct);
        return entity;
    }

    public async Task DeleteAsync(Guid id, CancellationToken ct)
    {
        var entity = await FindByIdAsync(id, ct);
        if (entity is not null)
        {
            _db.Set<T>().Remove(entity);
            await _db.SaveChangesAsync(ct);
        }
    }
}
```

## EF Core Best Practices

### Avoid N+1 Queries

```csharp
// BAD: N+1 — lazy loading in a loop
var orders = await _db.Orders.ToListAsync(ct);
foreach (var order in orders)
{
    order.Items = await _db.OrderItems.Where(i => i.OrderId == order.Id).ToListAsync(ct);
}

// GOOD: Eager loading with Include
var orders = await _db.Orders
    .Include(o => o.Items)
    .ThenInclude(i => i.Product)
    .AsNoTracking()
    .ToListAsync(ct);

// GOOD: Projection (most efficient)
var orders = await _db.Orders
    .Select(o => new OrderDto(
        o.Id,
        o.CustomerName,
        o.Items.Select(i => new ItemDto(i.ProductId, i.Quantity, i.Price))))
    .AsNoTracking()
    .ToListAsync(ct);
```

### Always Use AsNoTracking for Reads

```csharp
// Read-only queries: ALWAYS AsNoTracking()
var orders = await _db.Orders.AsNoTracking().ToListAsync(ct);

// Only track when you plan to update
var order = await _db.Orders.FindAsync([id], ct);
order.Status = OrderStatus.Shipped;
await _db.SaveChangesAsync(ct);
```

### Compiled Queries for Hot Paths

```csharp
private static readonly Func<AppDbContext, Guid, CancellationToken, Task<OrderDto?>>
    GetOrderById = EF.CompileAsyncQuery(
        (AppDbContext db, Guid id, CancellationToken ct) =>
            db.Orders.Where(o => o.Id == id)
                .Select(o => new OrderDto(o.Id, o.CustomerName, o.Status))
                .FirstOrDefault());
```

## CQRS with MediatR

```csharp
// Query
public sealed record GetOrdersQuery(Guid CustomerId) : IRequest<IReadOnlyList<OrderDto>>;

public sealed class GetOrdersHandler : IRequestHandler<GetOrdersQuery, IReadOnlyList<OrderDto>>
{
    private readonly AppDbContext _db;
    public GetOrdersHandler(AppDbContext db) => _db = db;

    public async Task<IReadOnlyList<OrderDto>> Handle(
        GetOrdersQuery request, CancellationToken ct) =>
        await _db.Orders
            .Where(o => o.CustomerId == request.CustomerId)
            .AsNoTracking()
            .Select(o => new OrderDto(o.Id, o.CustomerName, o.Status))
            .ToListAsync(ct);
}

// Command
public sealed record CreateOrderCommand(
    Guid CustomerId, List<OrderItemDto> Items) : IRequest<OrderDto>;

public sealed class CreateOrderHandler : IRequestHandler<CreateOrderCommand, OrderDto>
{
    private readonly AppDbContext _db;
    public CreateOrderHandler(AppDbContext db) => _db = db;

    public async Task<OrderDto> Handle(CreateOrderCommand cmd, CancellationToken ct)
    {
        var order = new Order { Id = Guid.NewGuid(), CustomerId = cmd.CustomerId };
        _db.Orders.Add(order);
        await _db.SaveChangesAsync(ct);
        return new OrderDto(order.Id, order.CustomerId, order.Status);
    }
}
```

## Validation with FluentValidation

```csharp
public sealed class CreateOrderValidator : AbstractValidator<CreateOrderRequest>
{
    public CreateOrderValidator()
    {
        RuleFor(x => x.CustomerId).NotEmpty();
        RuleFor(x => x.Items).NotEmpty().WithMessage("At least one item is required");
        RuleForEach(x => x.Items).ChildRules(item =>
        {
            item.RuleFor(i => i.ProductId).NotEmpty();
            item.RuleFor(i => i.Quantity).InclusiveBetween(1, 999);
        });
    }
}

// Register
builder.Services.AddValidatorsFromAssemblyContaining<CreateOrderValidator>();
```

## Options Pattern

```csharp
public sealed class PaymentOptions
{
    public const string SectionName = "Payment";
    public required string BaseUrl { get; init; }
    public required string ApiKeySecretName { get; init; }
}

// Register
builder.Services.Configure<PaymentOptions>(
    builder.Configuration.GetSection(PaymentOptions.SectionName));

// Use
public class PaymentService
{
    public PaymentService(IOptions<PaymentOptions> options)
    {
        var config = options.Value;
        // use config.BaseUrl, config.ApiKeySecretName
    }
}
```

## Caching

```csharp
// HybridCache (.NET 9+)
public sealed class OrderService
{
    private readonly HybridCache _cache;
    private readonly AppDbContext _db;

    public async Task<OrderDto?> GetOrderAsync(Guid id, CancellationToken ct) =>
        await _cache.GetOrCreateAsync(
            $"order:{id}",
            async ct =>
            {
                var order = await _db.Orders.AsNoTracking()
                    .FirstOrDefaultAsync(o => o.Id == id, ct);
                return order is null ? null : new OrderDto(order.Id, order.CustomerName, order.Status);
            },
            new HybridCacheEntryOptions { Expiration = TimeSpan.FromMinutes(5) },
            cancellationToken: ct);
}
```

## Middleware Pattern

```csharp
public sealed class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger) => (_next, _logger) = (next, logger);

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception: {Path}", context.Request.Path);
            context.Response.StatusCode = 500;
            await context.Response.WriteAsJsonAsync(
                new ApiResponse<object>(false, Error: "An unexpected error occurred."));
        }
    }
}

// Register
app.UseMiddleware<ExceptionHandlingMiddleware>();
```

## Background Jobs

```csharp
// Simple background service
public sealed class OrderProcessingService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<OrderProcessingService> _logger;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            // Process pending orders...
            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }
    }
}
```

## Input Validation at Boundaries

```csharp
// Always validate at API entry points
app.MapPost("/api/orders", async (CreateOrderRequest request,
    IValidator<CreateOrderRequest> validator, CancellationToken ct) =>
{
    var result = await validator.ValidateAsync(request, ct);
    if (!result.IsValid)
        return Results.ValidationProblem(result.ToDictionary());
    // proceed...
});

// Never trust external data
var sanitized = System.Net.WebUtility.HtmlEncode(userInput);
```
