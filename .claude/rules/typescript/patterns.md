---
paths:
  - "**/*.ts"
  - "**/*.html"
  - "**/*.component.ts"
---

# Angular & TypeScript Patterns

> Extends [common/patterns.md](../common/patterns.md)

## Smart vs Presentational Components

```typescript
// SMART: handles data fetching, state, logic
@Component({
  selector: 'app-order-list',
  standalone: true,
  imports: [OrderCardComponent, AsyncPipe],
  template: `
    @if (orders$ | async; as orders) {
      @for (order of orders; track order.id) {
        <app-order-card [order]="order" (select)="onSelect($event)" />
      } @empty {
        <p>No orders found.</p>
      }
    } @else {
      <app-spinner />
    }
  `
})
export class OrderListComponent {
  private orderService = inject(OrderService)
  orders$ = this.orderService.getOrders().pipe(shareReplay(1))
}

// PRESENTATIONAL: receives data via inputs, emits via outputs
@Component({
  selector: 'app-order-card',
  standalone: true,
  template: `...`
})
export class OrderCardComponent {
  order = input.required<Order>()
  select = output<string>()
}
```

## Repository Pattern for API Access

```typescript
@Injectable({ providedIn: 'root' })
export class OrderRepository {
  private http = inject(HttpClient)

  findAll(filters?: OrderFilters): Observable<Order[]> {
    let params = new HttpParams()
    if (filters?.status) params = params.set('status', filters.status)
    if (filters?.limit) params = params.set('limit', filters.limit.toString())
    return this.http.get<Order[]>('/api/orders', { params })
  }

  findById(id: string): Observable<Order> {
    return this.http.get<Order>(`/api/orders/${id}`)
  }

  create(dto: CreateOrderDto): Observable<Order> {
    return this.http.post<Order>('/api/orders', dto)
  }

  update(id: string, dto: UpdateOrderDto): Observable<Order> {
    return this.http.put<Order>(`/api/orders/${id}`, dto)
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`/api/orders/${id}`)
  }
}
```

## API Response Format

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: {
    total: number
    page: number
    limit: number
  }
}
```

## Reactive Form Patterns

```typescript
import { FormBuilder, Validators } from '@angular/forms'

@Component({ ... })
export class CreateOrderComponent {
  private fb = inject(FormBuilder)
  private orderService = inject(OrderService)

  form = this.fb.nonNullable.group({
    customerId: ['', [Validators.required, Validators.pattern(/^[0-9a-f-]{36}$/)]],
    items: this.fb.array([this.createItem()]),
    notes: ['']
  })

  createItem(): FormGroup {
    return this.fb.nonNullable.group({
      productId: ['', Validators.required],
      quantity: [1, [Validators.required, Validators.min(1)]]
    })
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched()
      return
    }
    this.orderService.create(this.form.getRawValue()).subscribe({
      next: order => this.router.navigate(['/orders', order.id]),
      error: err => this.error.set('Failed to create order')
    })
  }
}
```

## RxJS Error Handling Pattern

```typescript
getOrders(): Observable<Order[]> {
  return this.http.get<Order[]>('/api/orders').pipe(
    retry({ count: 2, delay: (err, retryCount) => {
      // Only retry on 5xx, not 4xx
      return err.status >= 500 ? timer(1000 * retryCount) : throwError(() => err)
    }}),
    catchError(err => {
      this.toast.error('Failed to load orders. Please try again.')
      return throwError(() => err)
    })
  )
}
```

## Async Pipe + OnPush (Default)

```typescript
@Component({
  selector: 'app-dashboard',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush, // Always OnPush
  template: `
    @if (data$ | async; as data) {
      <app-stats [data]="data" />
    }
  `
})
export class DashboardComponent {
  data$ = this.service.getDashboardData().pipe(shareReplay(1))
}
```

## Route Guards (Functional)

```typescript
// Modern functional guard (Angular v15+)
export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService)
  const router = inject(Router)
  return auth.isAuthenticated() ? true : router.createUrlTree(['/login'])
}

export const roleGuard = (role: string): CanActivateFn => () => {
  const auth = inject(AuthService)
  return auth.hasRole(role) ? true : inject(Router).createUrlTree(['/forbidden'])
}

// Usage in routes
const routes: Routes = [
  { path: 'admin', component: AdminComponent, canActivate: [authGuard, roleGuard('admin')] }
]
```

## HttpInterceptor Pattern

```typescript
export function authInterceptor(req: HttpRequest<unknown>, next: HttpHandlerFn): Observable<HttpEvent<unknown>> {
  const token = inject(AuthService).token()
  if (token && !req.url.includes('/auth/')) {
    req = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } })
  }
  return next(req).pipe(
    catchError(err => {
      if (err instanceof HttpErrorResponse && err.status === 401) {
        inject(AuthService).logout()
      }
      return throwError(() => err)
    })
  )
}

// Register in app config
provideHttpClient(withInterceptors([authInterceptor]))
```
