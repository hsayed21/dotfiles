# Common Patterns

## Repository Pattern

Encapsulate data access behind a consistent interface:

```csharp
// .NET
public interface IRepository<T> where T : class
{
    Task<IReadOnlyList<T>> FindAllAsync(CancellationToken ct);
    Task<T?> FindByIdAsync(Guid id, CancellationToken ct);
    Task<T> CreateAsync(T entity, CancellationToken ct);
    Task<T> UpdateAsync(T entity, CancellationToken ct);
    Task DeleteAsync(Guid id, CancellationToken ct);
}
```

```typescript
// Angular service
@Injectable({ providedIn: 'root' })
export class OrderRepository {
  private http = inject(HttpClient)

  findAll(filters?: Filters): Observable<Order[]> { ... }
  findById(id: string): Observable<Order | null> { ... }
  create(dto: CreateDto): Observable<Order> { ... }
  update(id: string, dto: UpdateDto): Observable<Order> { ... }
  delete(id: string): Observable<void> { ... }
}
```

## API Response Format

Consistent envelope for all API responses:

```csharp
public sealed record ApiResponse<T>(
    bool Success,
    T? Data = default,
    string? Error = null,
    object? Meta = null);
```

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: { total: number; page: number; limit: number }
}
```

## Design Principles

- **KISS**: Simplest solution that works
- **DRY**: Extract repetition, but wait for 3+ instances
- **YAGNI**: No speculative features or abstractions
- **Immutability**: Create new objects, never mutate in place
- **Many small files** > few large files (200-400 lines typical, 800 max)
