# Technical Lecture Formatting Reference

This reference demonstrates the desired writing quality.

The exact headings must adapt to the lecture.

The goal is to preserve meaningful information while removing filler and unnecessary repetition.

## General style

- Use clear Markdown headings.
- Keep explanations concise and technically complete.
- Put examples directly under their related concept.
- Separate commands, output, code, and configuration.
- Use the correct code-fence language.
- Preserve errors, debugging steps, and fixes.
- Include timestamps where they improve navigation.
- Avoid generic textbook material not present in the source.
- Do not create empty sections.

## Concept-focused example

# Dependency Injection

## Definition

Dependency injection allows a class to receive its dependencies from an external provider instead of constructing them directly.

## Why It Is Used

- Reduces coupling.
- Makes dependencies replaceable.
- Simplifies testing.
- Centralizes object creation and lifetime management.

## Example

### Interface

```csharp
public interface IMessageService
{
    void Send(string message);
}
```

### Implementation

```csharp
public sealed class EmailMessageService : IMessageService
{
    public void Send(string message)
    {
        Console.WriteLine(message);
    }
}
```

### Consumer

```csharp
public sealed class NotificationService
{
    private readonly IMessageService _messageService;

    public NotificationService(IMessageService messageService)
    {
        _messageService = messageService;
    }
}
```

The consumer depends on the abstraction instead of constructing a specific implementation.

## Common Pitfall

Creating the dependency directly inside the consumer tightly couples the two classes and makes replacement or testing harder.

## Key Takeaways

* Consumers request dependencies.
* The container or composition root creates them.
* Interfaces make implementations replaceable.

## Coding-demonstration example

# Creating a REST API Endpoint

## Objective

Create an endpoint that returns a user by identifier.

## Step 1 — Define the route

```csharp
app.MapGet("/users/{id:int}", async (
    int id,
    IUserRepository repository) =>
{
    var user = await repository.GetByIdAsync(id);

    return user is null
        ? Results.NotFound()
        : Results.Ok(user);
});
```

## Step 2 — Request the endpoint

```bash
curl http://localhost:5000/users/10
```

## Result

```json
{
  "id": 10,
  "name": "Ahmed"
}
```

## Important Behavior

* `{id:int}` constrains the route value to an integer.
* A missing user returns HTTP 404.
* A found user returns HTTP 200 with JSON.

## Debugging example

# Diagnosing a Database Connection Failure

## Problem

The application fails while opening the database connection.

## Error

```text
Login failed for user 'app_user'.
```

## Investigation

1. Verified the connection string.
2. Checked that the database server was running.
3. Confirmed that the account existed.
4. Tested the credentials separately.

## Root Cause

The configured password did not match the database account.

## Fix

Updated the REDACTED used by the application and restarted the service.

## Verification

The application connected successfully and the query returned data.

## Configuration example

# Docker Compose Service Configuration

```yaml
services:
  api:
    build:
      context: .
    ports:
      - "8080:8080"
    environment:
      ConnectionStrings__Default: Server=db;Database=AppDb

  db:
    image: postgres:17
    environment:
      POSTGRES_DB: AppDb
      POSTGRES_USER: app
      POSTGRES_PASSWORD: example
```

## Important Relationships

* The API reaches PostgreSQL using the service hostname `db`.
* The host exposes the API through port `8080`.
* Double underscores map environment variables to nested configuration keys in .NET.
