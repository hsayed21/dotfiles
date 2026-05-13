---
paths:
  - "**/*.ts"
  - "**/*.spec.ts"
  - "**/*.component.ts"
---

# Angular Testing

> Extends [common/testing.md](../common/testing.md)

## Test Framework

- **Jasmine + Karma** (default Angular) or **Jest** (preferred for speed)
- **Angular Testing Library** for component tests
- **Playwright** for E2E tests

## Component Testing

```typescript
import { render, screen, fireEvent } from '@testing-library/angular'
import { OrderCardComponent } from './order-card.component'

describe('OrderCardComponent', () => {
  it('displays customer name and emits select on click', async () => {
    const onSelect = jasmine.createSpy('onSelect')
    await render(OrderCardComponent, {
      componentInputs: {
        order: { id: '1', customerName: 'Acme Corp', status: 'pending' }
      },
      componentOutputs: { select: { emit: onSelect } as any }
    })

    expect(screen.getByText('Acme Corp')).toBeTruthy()
    fireEvent.click(screen.getByRole('button', { name: /view/i }))
    expect(onSelect).toHaveBeenCalledWith('1')
  })
})
```

## Service Testing

```typescript
import { TestBed } from '@angular/core/testing'
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing'
import { provideHttpClient } from '@angular/common/http'
import { OrderService } from './order.service'

describe('OrderService', () => {
  let service: OrderService
  let httpMock: HttpTestingController

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [OrderService, provideHttpClient(), provideHttpClientTesting()]
    })
    service = TestBed.inject(OrderService)
    httpMock = TestBed.inject(HttpTestingController)
  })

  afterEach(() => httpMock.verify())

  it('returns orders on success', () => {
    service.getOrders().subscribe(orders => {
      expect(orders.length).toBe(2)
    })

    const req = httpMock.expectOne('/api/orders')
    expect(req.request.method).toBe('GET')
    req.flush([{ id: '1' }, { id: '2' }])
  })

  it('returns empty array on error', () => {
    service.getOrders().subscribe(orders => {
      expect(orders).toEqual([])
    })

    httpMock.expectOne('/api/orders').error(new ProgressEvent('error'))
  })
})
```

## Pipe Testing

```typescript
describe('CurrencyFormatPipe', () => {
  it('formats number to currency string', () => {
    const pipe = new CurrencyFormatPipe()
    expect(pipe.transform(1234.56, 'USD')).toBe('$1,234.56')
  })
})
```

## E2E (Playwright)

```typescript
import { test, expect } from '@playwright/test'

test('user can view order list', async ({ page }) => {
  await page.goto('/orders')
  await expect(page.locator('[data-testid="order-card"]').first()).toBeVisible()
})

test('user can create an order', async ({ page }) => {
  await page.goto('/orders/new')
  await page.fill('[data-testid="customer-select"]', 'Acme Corp')
  await page.click('[data-testid="add-item"]')
  await page.fill('[data-testid="product-select-0"]', 'Widget')
  await page.fill('[data-testid="quantity-0"]', '5')
  await page.click('[data-testid="submit-order"]')
  await expect(page.locator('text=Order created')).toBeVisible()
})
```

## Coverage

- Target 80%+ line coverage
- Focus on services, pipes, guards, and domain logic
- Component tests should cover user-visible behavior, not implementation details
