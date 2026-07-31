---
paths:
  - "**/*.cs"
  - "**/*.csx"
  - "**/*.csproj"
---

# C# & .NET Testing

> Extends [common/testing.md](../common/testing.md)

## Test Framework

- **xUnit** — primary unit/integration test framework
- **FluentAssertions** — readable assertions
- **Moq** or **NSubstitute** — mocking
- **Testcontainers** — real infrastructure (SQL Server, Redis) for integration tests
- **Playwright** — E2E for the Angular frontend

## Test Organization

```
tests/
├── Api.Tests/                    # Integration tests (WebApplicationFactory)
│   └── Endpoints/
│       └── OrderEndpointsTests.cs
├── Application.Tests/            # Unit tests (MediatR handlers, validators)
│   └── Orders/
│       └── CreateOrderHandlerTests.cs
├── Domain.Tests/                 # Domain logic tests (entities, value objects)
│   └── OrderTests.cs
└── Architecture.Tests/           # ArchUnitNet tests (dependency rules)
    └── LayerDependencyTests.cs
```

## Unit Test Pattern (AAA)

```csharp
public sealed class CreateOrderHandlerTests
{
    [Fact]
    public async Task Handle_CreatesOrder_WhenInputIsValid()
    {
        // Arrange
        var db = CreateTestDbContext();
        var handler = new CreateOrderHandler(db);
        var command = new CreateOrderCommand(Guid.NewGuid(), "Acme",
            [new OrderItemDto(Guid.NewGuid(), 2, 9.99m)]);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.CustomerName.Should().Be("Acme");
        result.Status.Should().Be(OrderStatus.Pending);
        (await db.Orders.CountAsync()).Should().Be(1);
    }

    [Fact]
    public async Task Handle_ThrowsValidationException_WhenNoItems()
    {
        var handler = new CreateOrderHandler(CreateTestDbContext());
        var command = new CreateOrderCommand(Guid.NewGuid(), "Acme", []);

        await handler.Invoking(h => h.Handle(command, CancellationToken.None))
            .Should().ThrowAsync<ValidationException>();
    }
}
```

## Integration Test Pattern

```csharp
public sealed class OrderApiTests : IClassFixture<WebApplicationFactory<IApiMarker>>
{
    private readonly HttpClient _client;

    public OrderApiTests(WebApplicationFactory<IApiMarker> factory)
    {
        _client = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureTestServices(services =>
            {
                // Replace DB with test database
                services.RemoveAll<AppDbContext>();
                services.AddDbContext<AppDbContext>(opts =>
                    opts.UseInMemoryDatabase("TestDb"));
            });
        }).CreateClient();
    }

    [Fact]
    public async Task GetOrder_Returns404_WhenOrderNotFound()
    {
        var response = await _client.GetAsync("/api/orders/00000000-0000-0000-0000-000000000000");
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }
}
```

## Test Naming Convention

```
MethodName_ExpectedBehavior_WhenCondition

Examples:
Handle_CreatesOrder_WhenInputIsValid
Handle_ThrowsException_WhenItemsAreEmpty
GetOrder_Returns404_WhenOrderNotFound
```

## Coverage Target

- **80%+ line coverage** overall
- **100%** on domain logic and validation
- Focus on failure paths, edge cases, and authorization checks — not just happy paths
- Run `dotnet test --collect:"XPlat Code Coverage"` in CI
