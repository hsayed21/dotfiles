---
paths:
  - "**/*.ts"
  - "**/*.html"
  - "**/*.component.ts"
---

# Angular & TypeScript Security

> Extends [common/security.md](../common/security.md)

## XSS Prevention (Critical for Angular)

Angular automatically sanitizes values in templates. **Never bypass this:**

```typescript
// BAD: bypassing Angular's security (XSS risk)
constructor(private sanitizer: DomSanitizer) {
  this.trustedHtml = sanitizer.bypassSecurityTrustHtml(userInput) // DANGEROUS
}

// GOOD: keep Angular's auto-escaping (it's on by default)
// Template: <div>{{ userContent }}</div>  ← auto-escaped
// Template: <div [innerHTML]="sanitizedContent"></div> ← use only with DomSanitizer + allowlist
```

## Secret Management

```typescript
// NEVER: hardcoded secrets
const apiKey = 'sk-live-123'

// ALWAYS: environment variables at build time, loaded from secure config
// environment.ts (no secrets — checked in)
export const environment = {
  apiUrl: '/api',
  production: false
}
```

## Input Validation at All Boundaries

```typescript
// All form inputs validated
// All API responses validated (don't trust the server)
import { z } from 'zod'

const ApiOrderSchema = z.object({
  id: z.string().uuid(),
  customerId: z.string().uuid(),
  status: z.enum(['pending', 'confirmed', 'shipped', 'delivered']),
  total: z.number().positive(),
  createdAt: z.string().datetime()
})

// Validate API responses before using
this.http.get('/api/orders/123').pipe(
  map(data => ApiOrderSchema.parse(data))
)
```

## CSRF Protection

```typescript
// Angular's HttpClient includes built-in XSRF protection
// Cookie named 'XSRF-TOKEN' is automatically sent as 'X-XSRF-TOKEN' header
// Ensure the server sets the cookie:

// ASP.NET Core automatically handles this with:
// services.AddAntiforgery(options => options.HeaderName = "X-XSRF-TOKEN")
```

## Safe Navigation & Null Checking

```typescript
// Use optional chaining + nullish coalescing
const customerName = order?.customer?.name ?? 'Unknown'

// In templates, use the safe navigation operator
// {{ order?.customer?.name }}

// For signals with nullable values
displayName = computed(() => this.user()?.name ?? 'Guest')
```

## Route Guards for Authorization

```typescript
// Always protect routes server-side too — client-side guards are UX only
export const adminGuard: CanActivateFn = () => {
  const auth = inject(AuthService)
  if (!auth.hasRole('admin')) {
    inject(Router).navigate(['/unauthorized'])
    return false
  }
  return true
}
```

## No Sensitive Data in Logs/Templates

```typescript
// BAD: logging sensitive data
console.log('User login:', { email, password, token })

// GOOD: redact sensitive data
console.log('User login:', { userId: user.id, timestamp: Date.now() })
```
