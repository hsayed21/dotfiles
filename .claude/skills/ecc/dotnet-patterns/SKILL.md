---
name: dotnet-patterns
description: .NET & ASP.NET Core patterns — Minimal APIs, controllers, EF Core, MediatR, FluentValidation, Options pattern, authentication, middleware, background jobs, and testing.
---

# .NET & ASP.NET Core Patterns

Comprehensive patterns for building production .NET applications with ASP.NET Core.

## When to Activate

- Designing ASP.NET Core APIs (Minimal APIs or Controllers)
- Configuring Entity Framework Core queries and migrations
- Implementing CQRS with MediatR
- Setting up authentication/authorization
- Structuring validation with FluentValidation
- Configuring dependency injection
- Building middleware pipeline
- Writing integration tests

## Project Structure

```
src/
├── Api/                          # ASP.NET Core host
│   ├── Endpoints/                # Minimal API endpoint groups
│   ├── Controllers/              # Controller-based APIs
│   ├── Middleware/               # Custom middleware
│   └── Program.cs
├── Application/                  # Business logic (no EF references)
│   ├── Orders/
│   │   ├── Commands/             # Create, Update, Delete
│   │   ├── Queries/              # Get, List, Search
│   │   └── Dtos/                 # Request/response DTOs
│   └── Common/
│       ├── Behaviors/            # MediatR pipeline behaviors
│       └── Interfaces/           # Service abstractions
├── Domain/                       # Entities, enums, value objects
│   ├── Entities/
│   └── Enums/
├── Infrastructure/               # External concerns
│   ├── Persistence/
│   │   ├── AppDbContext.cs
│   │   ├── Configurations/       # EF entity configs
│   │   └── Migrations/
│   ├── Repositories/
│   └── Services/                 # External API clients
└── tests/
    ├── Api.Tests/                # Integration tests
    ├── Application.Tests/        # Unit tests
    └── Architecture.Tests/       # ArchUnitNet tests
```

## Dependency Injection

### Service Registration (Clean)

```csharp
// Program.cs — extension methods keep Program.cs clean
builder.Services
    .AddApplication()
    .AddInfrastructure(builder.Configuration)
    .AddApi();

// Application/DependencyInjection.cs
public static IServiceCollection AddApplication(this IServiceCollection services)
{
    services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly()));
    services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());
    return services;
}

// Infrastructure/DependencyInjection.cs
public static IServiceCollection AddInfrastructure(
    this IServiceCollection services, IConfiguration config)
{
    services.AddDbContext<AppDbContext>(opts =>
        opts.UseSqlServer(config.GetConnectionString("Default")));
    services.AddScoped<IOrderRepository, EfOrderRepository>();
    return services;
}
```

### Lifetime Guidelines

| Lifetime | When to Use |
|----------|------------|
| Singleton | Stateless services, configuration, cache |
| Scoped | DbContext, unit-of-work, request-scoped services |
| Transient | Lightweight, stateless workers |

```csharp
services.AddSingleton<IEmailTemplateService, EmailTemplateService>();
services.AddScoped<IOrderRepository, EfOrderRepository>();
services.AddTransient<IHashService, BCryptHashService>();
```

## Entity Framework Core

### Entity Configuration (Fluent API)

```csharp
public sealed class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.HasKey(o => o.Id);
        builder.Property(o => o.Id).ValueGeneratedNever(); // Use strongly-typed IDs

        builder.Property(o => o.CustomerName)
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(o => o.Status)
            .HasConversion<string>()
            .HasMaxLength(20);

        builder.HasMany(o => o.Items)
            .WithOne()
            .HasForeignKey(i => i.OrderId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(o => o.CustomerId);
        builder.HasIndex(o => o.CreatedAt);
    }
}
```

### Strongly-Typed IDs

```csharp
public readonly record struct OrderId(Guid Value)
{
    public static OrderId New() => new(Guid.NewGuid());
    public static OrderId From(Guid value) => new(value);
}
```

### Migration Safety

```bash
# Always generate a migration, never edit DB directly
dotnet ef migrations add AddOrderTable

# Generate idempotent SQL script for review
dotnet ef migrations script -i -o migrate.sql

# Verify migration SQL before applying
dotnet ef migrations script --idempotent | code -
```

## CQRS with MediatR

### Query (Read)

```csharp
public sealed record GetOrderQuery(OrderId Id) : IRequest<OrderDto?>;

public sealed class GetOrderHandler : IRequestHandler<GetOrderQuery, OrderDto?>
{
    private readonly AppDbContext _db;
    public GetOrderHandler(AppDbContext db) => _db = db;

    public async Task<OrderDto?> Handle(GetOrderQuery q, CancellationToken ct) =>
        await _db.Orders
            .AsNoTracking()
            .Where(o => o.Id == q.Id)
            .Select(o => new OrderDto(o.Id.Value, o.CustomerName, o.Status))
            .FirstOrDefaultAsync(ct);
}
```

### Command (Write)

```csharp
public sealed record CreateOrderCommand(
    Guid CustomerId,
    string CustomerName,
    List<OrderItemDto> Items) : IRequest<OrderDto>;

public sealed class CreateOrderHandler : IRequestHandler<CreateOrderCommand, OrderDto>
{
    private readonly AppDbContext _db;
    public CreateOrderHandler(AppDbContext db) => _db = db;

    public async Task<OrderDto> Handle(CreateOrderCommand cmd, CancellationToken ct)
    {
        var order = Order.Create(cmd.CustomerId, cmd.CustomerName, cmd.Items);
        _db.Orders.Add(order);
        await _db.SaveChangesAsync(ct);
        return new OrderDto(order.Id.Value, order.CustomerName, order.Status);
    }
}
```

### Pipeline Behaviors (Cross-cutting)

```csharp
// Validation behavior — runs before every command/query
public sealed class ValidationBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public async Task<TResponse> Handle(TRequest request,
        RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        if (!_validators.Any()) return await next();

        var context = new ValidationContext<TRequest>(request);
        var results = await Task.WhenAll(
            _validators.Select(v => v.ValidateAsync(context, ct)));
        var failures = results.SelectMany(r => r.Errors)
            .Where(f => f is not null).ToList();

        if (failures.Count > 0)
            throw new ValidationException(failures);

        return await next();
    }
}
```

## FluentValidation

```csharp
public sealed class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.CustomerId).NotEmpty();
        RuleFor(x => x.CustomerName).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Items).NotEmpty();
        RuleForEach(x => x.Items).ChildRules(item =>
        {
            item.RuleFor(i => i.ProductId).NotEmpty();
            item.RuleFor(i => i.Quantity).InclusiveBetween(1, 999);
            item.RuleFor(i => i.Price).GreaterThan(0);
        });
    }
}
```

## Authentication & Authorization

### JWT Bearer Setup

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(opts =>
    {
        opts.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = config["Jwt:Issuer"],
            ValidAudience = config["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(config["Jwt:Key"]!))
        };
    });

builder.Services.AddAuthorization(opts =>
{
    opts.AddPolicy("AdminOnly", p => p.RequireRole("Admin"));
    opts.AddPolicy("CanManageOrders", p =>
        p.RequireAssertion(ctx =>
            ctx.User.IsInRole("Admin") ||
            ctx.User.HasClaim("permission", "orders.manage")));
});

// Middleware order matters
app.UseAuthentication();
app.UseAuthorization();
```

## Resiliency with HttpClientFactory

```csharp
builder.Services.AddHttpClient<IPaymentGateway, StripeGateway>(client =>
{
    client.BaseAddress = new Uri(config["Payment:BaseUrl"]!);
    client.DefaultRequestHeaders.Add("Accept", "application/json");
})
.AddTransientHttpErrorPolicy(policy =>
    policy.WaitAndRetryAsync(3, retryAttempt =>
        TimeSpan.FromSeconds(Math.Pow(2, retryAttempt))))
.AddCircuitBreakerPolicy(policy =>
    policy.HandleTransientHttpError()
        .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30)));
```

## Testing

### Integration Tests with WebApplicationFactory

```csharp
public sealed class OrderApiTests : IClassFixture<WebApplicationFactory<IApiMarker>>
{
    private readonly WebApplicationFactory<IApiMarker> _factory;

    public OrderApiTests(WebApplicationFactory<IApiMarker> factory)
        => _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureTestServices(services =>
            {
                // Replace real DB with test container or in-memory
                services.RemoveAll<AppDbContext>();
                services.AddDbContext<AppDbContext>(opts =>
                    opts.UseInMemoryDatabase(Guid.NewGuid().ToString()));
            });
        });

    [Fact]
    public async Task GetOrder_ReturnsOrder_WhenExists()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/api/orders/1");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
```

### Unit Tests with Moq/FluentAssertions

```csharp
[Fact]
public async Task CreateOrder_SavesOrder_WhenValid()
{
    // Arrange
    var db = new InMemoryDbContext();
    var handler = new CreateOrderHandler(db);
    var cmd = new CreateOrderCommand(Guid.NewGuid(), "Acme", []);

    // Act
    var result = await handler.Handle(cmd, CancellationToken.None);

    // Assert
    result.CustomerName.Should().Be("Acme");
    (await db.Orders.CountAsync()).Should().Be(1);
}
```

## Performance Patterns

- **AsNoTracking()** — Always for read-only queries
- **Select projections** — Only fetch needed columns
- **Compiled queries** — For hot paths
- **Async all the way** — Never `.Result` or `.Wait()`
- **CancellationToken** — Every async method accepts one
- **Response caching** — Cache GET responses with `[ResponseCache]`
- **Pagination** — Every list endpoint has page/pageSize
