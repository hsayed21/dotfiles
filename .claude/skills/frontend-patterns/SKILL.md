---
name: frontend-patterns
description: Angular frontend patterns — standalone components, signals, RxJS, forms, state management, performance, and UI best practices.
---

# Angular Frontend Patterns

Modern Angular patterns for standalone components, signals, RxJS, and performant UIs.

## When to Activate

- Building Angular components (standalone, composition, inputs/outputs)
- Managing state (signals, RxJS, services)
- Working with reactive forms (FormBuilder, validation)
- Optimizing performance (OnPush, trackBy, lazy loading)
- Building accessible, responsive UI patterns
- Using Angular Material or PrimeNG components

## Component Architecture

### Standalone Components (Default for v17+)

Every new component is standalone. No NgModules unless integrating legacy code.

```typescript
import { Component, input, output, signal, computed, inject } from '@angular/core'
import { AsyncPipe, NgIf, NgFor } from '@angular/common'

@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [AsyncPipe, UserCardComponent, SpinnerComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (users$ | async; as users) {
      @for (user of users; track user.id) {
        <app-user-card [user]="user" (select)="onSelect($event)" />
      } @empty {
        <p>No users found.</p>
      }
    } @else {
      <app-spinner />
    }
  `
})
export class UserListComponent {
  private userService = inject(UserService)
  users$ = this.userService.getAll().pipe(shareReplay(1))
  onSelect(id: string) { this.router.navigate(['/users', id]) }
}
```

### Smart/Dumb Component Pattern

```
containers/          ← Smart: fetch data, handle events, manage state
  UserList/
    user-list.component.ts
components/          ← Dumb: receive inputs, emit outputs, pure rendering
  UserCard/
    user-card.component.ts
  Spinner/
    spinner.component.ts
```

**Smart component**: Injects services, fetches data, handles routing.
**Dumb component**: Only `input()` and `output()`. No service injection. Pure presentation.

### Component Composition with Content Projection

```typescript
@Component({
  selector: 'app-card',
  standalone: true,
  template: `
    <div class="card">
      <ng-content select="[card-header]" />
      <div class="card-body">
        <ng-content />
      </div>
      <ng-content select="[card-footer]" />
    </div>
  `
})
export class CardComponent {}

// Usage
<app-card>
  <h2 card-header>Title</h2>
  <p>Body content here</p>
  <button card-footer>Action</button>
</app-card>
```

## Signals (Modern State Management)

### Core Signal API

```typescript
// Writable signals
count = signal(0)
items = signal<Item[]>([])
isLoading = signal(false)

// Computed signals (auto-track dependencies)
totalPrice = computed(() => this.items().reduce((sum, i) => sum + i.price, 0))
hasItems = computed(() => this.items().length > 0)

// Updating signals immutably
addItem(item: Item) {
  this.items.update(current => [...current, item])
}

removeItem(id: string) {
  this.items.update(current => current.filter(i => i.id !== id))
}

// Effects — use sparingly, mainly for logging/sync
constructor() {
  effect(() => {
    console.debug('Items changed:', this.items().length)
  })
}
```

### Signal-Based Service State

```typescript
@Injectable({ providedIn: 'root' })
export class CartService {
  private http = inject(HttpClient)

  // Private writable, public read-only
  private _items = signal<CartItem[]>([])
  readonly items = this._items.asReadonly()
  readonly count = computed(() => this._items().length)
  readonly total = computed(() => this._items().reduce((s, i) => s + i.price * i.qty, 0))

  load(): void {
    this.http.get<CartItem[]>('/api/cart').subscribe(items => this._items.set(items))
  }

  add(item: CartItem): void {
    this._items.update(current => {
      const existing = current.find(i => i.productId === item.productId)
      if (existing) {
        return current.map(i => i.productId === item.productId
          ? { ...i, qty: i.qty + 1 }
          : i
        )
      }
      return [...current, item]
    })
  }
}
```

## RxJS Patterns

### Service with Async State

```typescript
@Injectable({ providedIn: 'root' })
export class OrderService {
  private http = inject(HttpClient)
  private refresh$ = new Subject<void>()

  getOrders(customerId: string): Observable<Order[]> {
    return this.refresh$.pipe(
      startWith(undefined),
      switchMap(() => this.http.get<Order[]>('/api/orders', { params: { customerId } })),
      catchError(err => {
        console.error('Failed to load orders', err)
        return of([])
      }),
      shareReplay(1)
    )
  }

  refresh(): void {
    this.refresh$.next()
  }
}
```

### Combining Streams

```typescript
@Component({ ... })
export class DashboardComponent {
  private orderService = inject(OrderService)
  private customerService = inject(CustomerService)

  // Combine multiple streams
  vm$ = combineLatest([
    this.orderService.getRecentOrders(),
    this.customerService.getTopCustomers(),
    this.orderService.getStats()
  ]).pipe(
    map(([orders, customers, stats]) => ({ orders, customers, stats })),
    shareReplay(1)
  )
}
```

### Unsubscribing (takeUntilDestroyed)

```typescript
import { takeUntilDestroyed } from '@angular/core/rxjs-interop'

@Component({ ... })
export class MyComponent {
  private destroyRef = inject(DestroyRef)

  constructor() {
    this.service.data$.pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe(data => {
      // Auto-unsubscribes when component is destroyed
    })
  }
}
```

## Reactive Forms

### Typed Forms with Validation

```typescript
import { FormBuilder, Validators } from '@angular/forms'

interface OrderForm {
  customerId: FormControl<string>
  items: FormArray<FormGroup<{
    productId: FormControl<string>
    quantity: FormControl<number>
  }>>
  notes: FormControl<string | null>
}

@Component({ ... })
export class CreateOrderComponent {
  private fb = inject(FormBuilder)

  form = this.fb.nonNullable.group<OrderForm>({
    customerId: ['', [Validators.required]],
    items: this.fb.array([this.createItem()]),
    notes: [null]
  })

  createItem(): FormGroup {
    return this.fb.nonNullable.group({
      productId: ['', Validators.required],
      quantity: [1, [Validators.required, Validators.min(1)]]
    })
  }

  addItem(): void {
    this.form.controls.items.push(this.createItem())
  }

  removeItem(index: number): void {
    this.form.controls.items.removeAt(index)
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched()
      return
    }
    // form.value is fully typed
    this.orderService.create(this.form.getRawValue()).subscribe(...)
  }
}
```

### Custom Validators

```typescript
export function jsonValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) return null
    try {
      JSON.parse(control.value)
      return null
    } catch {
      return { invalidJson: true }
    }
  }
}

// Usage
this.fb.group({
  config: ['', jsonValidator()]
})
```

## Performance

### OnPush Change Detection (ALWAYS)

```typescript
@Component({
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush, // Always use OnPush
  ...
})
```

### trackBy in Loops

```html
<!-- Always use trackBy with @for -->
@for (item of items(); track item.id) {
  <app-item-card [item]="item" />
}

<!-- In older templates -->
<div *ngFor="let item of items; trackBy: trackById">
```

### Lazy Loading Routes

```typescript
const routes: Routes = [
  {
    path: 'admin',
    loadChildren: () => import('./admin/admin.routes').then(m => m.ADMIN_ROUTES),
    canActivate: [adminGuard]
  }
]
```

### Deferrable Views (Angular v17+)

```html
@defer (on viewport) {
  <app-heavy-chart [data]="data()" />
} @placeholder {
  <div class="chart-placeholder">Chart loading...</div>
} @loading (minimum 300ms) {
  <app-spinner />
} @error {
  <p>Failed to load chart.</p>
}
```

## HTTP & API Communication

### Typed HttpClient

```typescript
@Injectable({ providedIn: 'root' })
export class ApiService {
  private http = inject(HttpClient)
  private baseUrl = '/api'

  get<T>(path: string, params?: HttpParams): Observable<T> {
    return this.http.get<T>(`${this.baseUrl}/${path}`, { params })
  }

  post<T>(path: string, body: unknown): Observable<T> {
    return this.http.post<T>(`${this.baseUrl}/${path}`, body)
  }

  put<T>(path: string, body: unknown): Observable<T> {
    return this.http.put<T>(`${this.baseUrl}/${path}`, body)
  }

  delete<T>(path: string): Observable<T> {
    return this.http.delete<T>(`${this.baseUrl}/${path}`)
  }
}
```

## Error Handling Patterns

### Global Error Handler

```typescript
@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  private toast = inject(ToastService)

  handleError(error: unknown): void {
    console.error('Unhandled error:', error)
    this.toast.error('Something went wrong. Please try again.')
  }
}

// Register in app config
provideAppConfig({ providers: [{ provide: ErrorHandler, useClass: GlobalErrorHandler }] })
```

### Per-Request Error Handling

```typescript
this.orderService.create(dto).pipe(
  catchError(err => {
    if (err.status === 409) {
      this.toast.warning('Duplicate order detected.')
    } else {
      this.toast.error('Failed to create order.')
    }
    return EMPTY
  })
).subscribe(...)
```

## Angular Material Integration

```typescript
import { MatTableModule } from '@angular/material/table'
import { MatPaginatorModule } from '@angular/material/paginator'
import { MatSortModule } from '@angular/material/sort'

@Component({
  selector: 'app-order-table',
  standalone: true,
  imports: [MatTableModule, MatPaginatorModule, MatSortModule, AsyncPipe],
  template: `
    <table mat-table [dataSource]="orders$ | async" matSort>
      <ng-container matColumnDef="id">
        <th mat-header-cell *matHeaderCellDef mat-sort-header>ID</th>
        <td mat-cell *matCellDef="let order">{{ order.id }}</td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
      <tr mat-row *matRowDef="let row; columns: displayedColumns"></tr>
    </table>
  `
})
export class OrderTableComponent {
  displayedColumns = ['id', 'customer', 'status', 'total']
}
```

## Accessibility (a11y)

- Every `img` has `[alt]` text
- Forms use `<label>` + `[for]` or `aria-label` on inputs
- Modals trap focus and restore on close
- Color is never the only way to convey meaning
- `[attr.aria-expanded]`, `[attr.aria-selected]` on interactive elements
- Test with `ng lint` (eslint-plugin-a11y) and screen reader

---

**Remember**: Angular is a full framework — use its features. Services for shared state, RxJS for async, signals for local state, and standalone components for everything.
