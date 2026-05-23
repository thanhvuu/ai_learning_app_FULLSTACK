# AI Learning Architecture

## Flutter Direction

The Flutter app should use feature-based MVVM + Clean Architecture:

```text
lib/
  core/
    error/          shared typed exceptions
    network/        ApiClient, connectivity, retry/timeout policy
    result/         Result<T> boundary for safe failures
  features/
    feature_name/
      data/
        datasources/ remote/local data access
        models/      DTOs and JSON mapping
        repositories repository implementations
      domain/
        entities/    UI-independent business models
        repositories repository contracts
        usecases/    single-purpose actions
      presentation/
        view_models/ ChangeNotifier/ViewModel state
        views/       widgets/screens only
```

Dependency rule:

```text
View -> ViewModel -> UseCase -> Repository interface -> Repository impl -> DataSource/DAO/API
```

Views must not call HTTP, Firebase, SQLite, or `jsonDecode` directly. They receive state from ViewModels and render loading/error/success states.

## Applied Module

`features/leaderboard` is the reference implementation:

- `ApiClient` applies base URL, timeout and typed error mapping.
- `Result<T>` prevents uncaught API exceptions from crashing screens.
- `LeaderboardRemoteDataSource` owns raw API access.
- `LeaderboardRepository` hides data source details from domain/presentation.
- `GetLeaderboard` is the use case.
- `DiscoverViewModel` owns loading/error/data state.
- `DiscoverScreen` only renders state.

## Backend Scale Direction

Tens of thousands of users are mainly a backend and infrastructure concern. Required production moves:

- Keep database connection pooling bounded with HikariCP.
- Add indexes for hot query paths: username lookup, leaderboard XP ordering, lesson lookup by username/category.
- Use environment variables for secrets and deploy config.
- Disable SQL logging in production.
- Move heavy AI/PDF generation to async jobs/queue when traffic grows.
- Add cache for leaderboard and static roadmap/template data.
- Add rate limiting on login/register/AI endpoints.
- Add observability: metrics, structured logs, tracing, health checks.
- Deploy multiple stateless backend instances behind a load balancer.
