---
paths:
  - "**/*.ts"
  - "**/*.js"
  - "**/*.html"
  - "**/*.component.ts"
---

# TypeScript & Angular Coding Style

> Extends [common/coding-style.md](../common/coding-style.md)

## TypeScript Fundamentals

### Explicit Types on Public APIs

```typescript
// Exported functions and class members need explicit return types
export function formatCurrency(amount: number, locale: string): string {
  return new Intl.NumberFormat(locale, { style: 'currency', currency: 'USD' }).format(amount)
}

// Let inference work for obvious locals
const result = formatCurrency(100, 'en-US') // type is inferred: string
```

### Strict Mode Required

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

### Avoid `any` — Use `unknown` + narrowing

```typescript
// BAD
function handleApiError(error: any): string {
  return error.message // unsafe
}

// GOOD
function handleApiError(error: unknown): string {
  if (error instanceof Error) return error.message
  if (typeof error === 'string') return error
  return 'An unexpected error occurred'
}
```

### Types vs Interfaces

- `interface` for object shapes, component inputs, service contracts
- `type` for unions, intersections, mapped types, tuples
- Prefer string literal unions over `enum`

```typescript
type OrderStatus = 'pending' | 'confirmed' | 'shipped' | 'delivered'

interface Order {
  id: string
  status: OrderStatus
  total: number
  createdAt: Date
}
```

## Angular Component Patterns

### Standalone Components (Modern Angular v17+)

```typescript
import { Component, input, output, signal } from '@angular/core'

@Component({
  selector: 'app-order-card',
  standalone: true,
  template: `
    <div class="order-card">
      <h3>{{ order().customerName }}</h3>
      <span [class]="'badge badge-' + order().status">{{ order().status }}</span>
      <button (click)="select.emit(order().id)">View</button>
    </div>
  `
})
export class OrderCardComponent {
  order = input.required<Order>()
  select = output<string>()
}
```

### Signals over Zone.js (Modern Angular)

```typescript
// Prefer signals for local state
count = signal(0)
items = signal<Item[]>([])

// Computed values auto-track dependencies
totalPrice = computed(() => this.items().reduce((sum, i) => sum + i.price, 0))

// Effects for side effects (rare — prefer RxJS for async)
constructor() {
  effect(() => {
    console.log('Count changed:', this.count())
  })
}

// Update signals immutably
addItem(item: Item): void {
  this.items.update(current => [...current, item])
}
```

### RxJS for Async Operations

```typescript
import { HttpClient } from '@angular/common/http'
import { inject } from '@angular/core'
import { catchError, map, Observable, of, shareReplay, switchMap } from 'rxjs'

@Injectable({ providedIn: 'root' })
export class OrderService {
  private http = inject(HttpClient)

  getOrders(customerId: string): Observable<Order[]> {
    return this.http.get<Order[]>(`/api/orders`, { params: { customerId } }).pipe(
      map(orders => orders.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())),
      catchError(err => {
        console.error('Failed to load orders', err)
        return of([])
      }),
      shareReplay(1)
    )
  }
}
```

### Dependency Injection

```typescript
// Always use inject() function (modern Angular)
@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient)
  private router = inject(Router)
}
```

### Input Validation at Boundaries

```typescript
import { z } from 'zod'

const OrderSchema = z.object({
  customerId: z.string().uuid(),
  items: z.array(z.object({
    productId: z.string().min(1),
    quantity: z.number().int().min(1).max(999)
  })).min(1),
  notes: z.string().max(500).optional()
})

type CreateOrderDto = z.infer<typeof OrderSchema>
```

## Immutability (CRITICAL)

Never mutate state in place — always create new objects:

```typescript
// BAD: mutation
this.items.push(newItem)
user.role = 'admin'

// GOOD: immutability
this.items.update(current => [...current, newItem])
const updated = { ...user, role: 'admin' as const }
```

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Components | PascalCase | `OrderCardComponent` |
| Services | PascalCase | `OrderService` |
| Interfaces | PascalCase | `Order`, `OrderFilter` |
| Functions/methods | camelCase | `getOrders()`, `calculateTotal()` |
| Signals | camelCase | `count`, `items`, `isLoading` |
| Observables | camelCase + $ suffix | `orders$`, `user$` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Directives | PascalCase | `HighlightDirective` |
| Pipes | PascalCase | `CurrencyFormatPipe` |
