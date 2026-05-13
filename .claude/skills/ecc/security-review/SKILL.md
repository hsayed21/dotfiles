---
name: security-review
description: Security review for .NET and Angular applications — REDACTED detection, injection, XSS, CSRF, auth, input validation, and OWASP Top 10.
---

# Security Review

Comprehensive security checklist and patterns for full-stack .NET + Angular applications.

## When to Activate

- Implementing authentication or authorization
- Handling user input or file uploads
- Creating new API endpoints
- Working with secrets or credentials
- Implementing payment features
- Before production deployment

## Quick Security Checklist

- [ ] No hardcoded secrets (API keys, connection strings, tokens)
- [ ] All user inputs validated at boundaries (FluentValidation, Zod)
- [ ] SQL queries parameterized (EF Core handles this automatically)
- [ ] Authentication on all protected endpoints
- [ ] Authorization checked before sensitive operations
- [ ] XSS prevention (Angular auto-escapes — don't bypass it)
- [ ] CSRF protection on state-changing endpoints
- [ ] Rate limiting on public endpoints
- [ ] Error messages don't leak internals
- [ ] Sensitive data not logged

## Backend (.NET) Security

### Secret Management

```csharp
// NEVER: Hardcoded secrets
const string ApiKey = "sk-live-123";

// ALWAYS: Configuration
var apiKey = builder.Configuration["Api:Key"]
    ?? throw new InvalidOperationException("Api:Key not configured");
```

### SQL Injection Prevention

EF Core parameterizes all queries by default. When using raw SQL, always parameterize:

```csharp
// SAFE: EF Core auto-parameterizes
_db.Orders.Where(o => o.CustomerId == customerId)

// SAFE: Raw SQL with parameters
_db.Database.ExecuteSqlRaw(
    "DELETE FROM Orders WHERE Id = @id",
    new SqlParameter("@id", orderId))

// DANGEROUS: String interpolation
_db.Database.ExecuteSqlRaw($"DELETE FROM Orders WHERE Id = '{orderId}'")
```

### Auth & Authorization

```csharp
// Always require auth on protected endpoints
app.MapGet("/api/orders", ...).RequireAuthorization();

// Always check ownership or role
if (order.UserId != currentUser.Id && !currentUser.IsAdmin)
    return Results.Forbid();
```

## Frontend (Angular) Security

### XSS Prevention

Angular sanitizes templates by default. **Never bypass it:**

```typescript
// DANGEROUS: bypassing Angular's sanitizer
this.sanitizer.bypassSecurityTrustHtml(userContent)

// SAFE: Angular auto-escapes template bindings
// <div>{{ userContent }}</div> ← safe
// Use [innerHTML] only with DomSanitizer + allowlist
```

### Secret Management

```typescript
// NEVER: hardcoded in source
const apiKey = 'sk-abc123'

// Angular environment files should NEVER contain secrets
// Use server-side config, never expose keys to the client
```

### CSRF Protection

Angular's HttpClient auto-sends `X-XSRF-TOKEN` header from `XSRF-TOKEN` cookie.
Ensure the server sets the cookie and validates the header.

## Pre-Deployment Checklist

- [ ] `dotnet build` clean (no warnings as errors)
- [ ] `npm audit` clean (no HIGH/CRITICAL)
- [ ] `dotnet test` all passing
- [ ] No hardcoded secrets in any file
- [ ] `appsettings.Production.json` reviewed for secrets
- [ ] HSTS/HTTPS enforced
- [ ] Rate limiting configured
- [ ] Cors restricted to known origins
