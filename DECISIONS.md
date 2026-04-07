# Architecture Decisions — F1 Seasons App

Decisions made before writing any code, updated as the project evolves. This document exists so that any developer joining the project understands *why* things are built the way they are, not just *how*.

---

## Decision 1: Architecture Pattern

**Chosen: MVVM (Model-View-ViewModel)**

SwiftUI's reactive data flow (`@Published`, `ObservableObject`, `@StateObject`) maps directly to the MVVM pattern. Each screen gets its own ViewModel that owns the data-fetching logic and screen state. Views are kept as dumb as possible — they observe and render, nothing more.

Alternatives considered:
- **No architecture (everything in Views):** Faster to start, but unmaintainable in a team context and untestable.
- **MV (Model-View, no ViewModel):** A valid SwiftUI-native approach, but less established and harder to learn from existing resources. Considered a potential future optimization after MVVM is well understood.

---

## Decision 2: Networking Strategy

**Chosen: Inline first, then extract into a shared API Service**

Phase 1: Network calls were written directly in each ViewModel using `URLSession`. This was intentional — to deeply understand the mechanics of HTTP requests, JSON decoding, headers, and async/await before abstracting.

Phase 2 (completed): Once patterns emerged from repetition (URL construction, header setup, error handling, JSON decoding), the shared logic was extracted into a single `F1APIService` that all ViewModels use. The service exposes a generic `fetch<T: Decodable>` function that handles URL construction, header injection, and JSON decoding for any `Decodable` type. Specific endpoints (`fetchSeasons()`, `fetchDrivers(for:)`) build the URL and call the generic function — separating the *tool* (generic fetch) from the *decisions about how to use it* (specific endpoints).

Alternatives considered:
- **Shared API Service from the start:** Cleaner, but risks building an abstraction without understanding what it abstracts.
- **Third-party library (Alamofire):** Unnecessary for simple GET requests. Adds a dependency without clear benefit at this scale.

---

## Decision 3: Data Models

**Chosen: Single set of Codable structs used by both networking and Views**

API responses are decoded directly into structs (e.g., `Season`, `Driver`) that Views also use to render data. `CodingKeys` are used where API field names don't match Swift conventions — for example, renaming `driverId` to `id`. When a `CodingKeys` enum is defined, *all* decoded properties must be listed as cases (even unchanged ones), because defining the enum disables Swift's auto-generated mappings.

No separate "domain model" layer at this stage. The app has 3 screens and 3 API calls — the overhead of a mapping layer is not justified.

Alternatives considered:
- **Separate API models and domain models:** Proper separation of concerns, but doubles the number of model files for minimal practical benefit at this scale. Revisit if the app grows significantly.

---

## Decision 4: Navigation

**Chosen: Type-based NavigationStack with value-passing NavigationLinks**

The app has a linear 3-screen flow (Seasons → Drivers → Driver Detail) plus external links to Wikipedia. `NavigationStack` handles this with type-safe, data-driven navigation via `NavigationLink(value:)` and `.navigationDestination(for:)`.

This approach separates *intent* from *construction*: the NavigationLink declares "here's a value" and drops it onto the navigation stack. The `.navigationDestination(for: Type.self)` handler — registered separately — watches for that type and builds the appropriate view. The link and the destination are connected only by the *type* of the value, not by direct view references. This makes the navigation stack a plain array of values that can be programmatically manipulated for deep-linking, popping, or resetting.

Wikipedia links are opened using `@Environment(\.openURL)`.

Alternatives considered:
- **Old-style NavigationLink(destination:):** Glues each link to a specific view. Works for 3 screens, but doesn't support programmatic navigation or deep-linking. Less composable.
- **Coordinator pattern:** Common in UIKit, offers full navigation control. Significant complexity overhead for a 3-screen linear flow. Not natural in SwiftUI.

---

## Decision 5: Project Structure

**Chosen: Group by screen, with shared code in Core**

```
DECISIONS.md
WebstarF1App/
├── App/                      # App entry point
├── Core/
│   ├── Helpers/              # Shared types and utilities (ViewState, DateFormatting, NationalityFlags)
│   ├── Models/               # Shared Codable structs (Season, Driver, ImageSearchResponse)
│   ├── Networking/           # API services (F1APIService, ImageSearchService)
│   └── SharedViews/          # Reusable UI components (ErrorView)
├── Screens/
│   ├── Seasons/              # SeasonsView + SeasonsViewModel
│   ├── SeasonDrivers/        # SeasonDriversView + SeasonDriversViewModel
│   └── DriverProfile/        # DriverProfileView + DriverProfileViewModel
└── Assets.xcassets/          # App icons, colors
```

Originally named `Features/`, renamed to `Screens/` because the folders map 1:1 to screens, not to features in the product sense. The name should describe what the folders *are*.

`Core/SharedViews/` holds UI components that serve multiple screens (e.g., `ErrorView`). `CachedAsyncImage` will also live here once image caching is implemented. The rule: things that serve one screen live with that screen. Things that serve the whole app get their own home in Core.

`Core/Helpers/` holds types and utilities used across the app — `ViewState` enum, `DateFormatting`, `NationalityFlags`. Originally named `Extensions/`, renamed because these aren't Swift extensions — they're standalone types and utilities.

Alternatives considered:
- **Group by type (Models/, Views/, ViewModels/):** Simpler mental model for finding files by role, but requires jumping across multiple folders to work on a single feature. Scales poorly.

---

## Decision 6: State Management

**Chosen: Generic `ViewState<T>` enum with associated values**

Originally used separate `@Published` properties (`isLoading: Bool`, `errorMessage: String?`, data array). Refactored to a single enum after encountering the exact problem predicted: independent properties can represent impossible states (e.g., `isLoading = true` while `errorMessage` contains stale text from a previous failure).

```swift
enum ViewState<T> {
    case idle
    case loading
    case error(String)
    case empty
    case loaded(T)
}
```

Each ViewModel now has a single `@Published var state: ViewState<T>` property. The generic parameter `T` varies by screen: `ViewState<[Season]>` for seasons, `ViewState<[Driver]>` for drivers, `ViewState<URL>` for the driver image. Views consume state via a `switch` statement, which the compiler enforces — every state must be handled.

Key details:
- `idle` exists because there is a real moment before `.task` fires where the screen has no state. It's not loading, not errored, not empty — it simply hasn't started yet.
- `idle` and `loading` render identically (a `ProgressView`) but are semantically distinct.
- Data that was previously stored as a separate `@Published` property alongside the enum (e.g., a `seasons` array) is now stored *inside* the `.loaded` case. Keeping both would reintroduce the sync problem the enum was designed to solve.
- ViewModels that need to reference the loaded data in computed properties (e.g., for filtering or nationality counts) use a private computed property that extracts it: `if case .loaded(let data) = state { return data } else { return [] }`.

Alternatives considered:
- **Optionals and booleans (original approach):** Simpler to start, but allows contradictory states. Refactored away after the pattern proved fragile.

---

## Decision 7: Git Workflow

**Chosen: Single main branch with descriptive commits**

Tried feature branches early on (optimization/networking-code). Dropped the practice after one branch because the overhead wasn't justified — this is a solo project with a linear build order. Creating, switching, and merging branches for every change added friction without the benefit branches exist to provide (parallel work, code review, safe experimentation in a team).

Commit messages remain present-tense and descriptive (e.g., "Add seasons list view with API integration"). Each commit represents one logical change.

Alternatives considered:
- **Feature branches merged into main:** The standard team workflow. Tested once, but the ceremony-to-value ratio was wrong for a single developer on a 3-screen app. Would adopt in a team context where branches protect against conflicting work and enable code review.

---

## Decision 8: Build Order

**Chosen: Vertical slice, then replicate**

1. Build the Seasons screen end-to-end first (model → networking → ViewModel → View)
2. This establishes patterns for how the MVVM pieces connect
3. Replicate the pattern for Drivers and Driver Detail screens
4. Extract shared networking code into `F1APIService` (Decision 2, Phase 2)
5. Add bonus features (search, flag emojis, Google Image Search)
6. Polish: error states, loading indicators, edge cases
7. Write unit tests for ViewModels
8. Final README

Alternatives considered:
- **Layer by layer (all models, then all networking, then all Views):** Systematic and mature, but delays visible results. High risk of momentum loss.
- **Screen by screen without establishing patterns:** Fast results, but leads to inconsistency and rework across screens.

---

## Decision 9: Data Filtering — Sparse Driver Entries

**Chosen: Filter out drivers where `nationality == nil`**

The Ergast API returns two kinds of driver records. Full records have `driverId`, `givenName`, `familyName`, `dateOfBirth`, `nationality`, `url`, and optionally `permanentNumber` and `code`. Sparse records have *only* `driverId`, `givenName`, and `familyName` — everything else is missing. These appear to be reserve/test drivers rather than race participants.

This was verified by inspecting driver data across multiple seasons (1952, 1968, 1975, 1994, 2004, 2020, 2025). In all seasons from 1950 through 2024, every driver has `dateOfBirth`, `nationality`, and `url`. Sparse entries only appear in the 2025 season (e.g., Paul Aron, Dino Beganovic, Luke Browning).

`nationality` was chosen as the filter property because the app's nationality summary feature depends on it — a driver without nationality can't participate in that aggregation. The filter serves double duty: cleaning the data *and* protecting a feature.

The filter lives in a single computed property on the ViewModel (`private var drivers`) so it applies once at the source. All downstream computed properties (filtering, nationality counts) work with already-clean data.

Originally considered a separate "Guest Drivers" section with its own UI treatment. Dropped because the distinction added UI complexity without meaningful value to the user — it's trivia, not useful information.

Alternatives considered:
- **Separate "Guest Drivers" section:** More complete representation of the data, but adds a Section, a second ForEach, and duplicate filtering logic for marginal user value.
- **Filter by `racingNumber != nil`:** Would exclude legitimate pre-2014 drivers who raced without permanent numbers. Incorrect signal.
- **Filter by `dateOfBirth != nil`:** Also valid — every real driver in the dataset has a birth date. But `nationality` better serves the app's features.

---

## Decision 10: Error Message Strategy

**Chosen: User-friendly messages for full-screen errors; raw messages acceptable for non-critical failures**

Full-screen error states (SeasonsView, SeasonDriversView) use the reusable `ErrorView` component. These should show user-friendly messages rather than raw `error.localizedDescription` output, since the user's only action is "retry" and technical details don't help.

Non-critical errors (e.g., a failed image fetch in DriverProfileView where the rest of the screen still works) currently pass `error.localizedDescription` directly. This is a known rough edge — these should also be simplified to something like "Image unavailable."

No distinction is made between error *types* in the UI (network failure vs. server error vs. bad data). The user's only available action in all cases is "retry" or "try again later," so differentiating adds complexity without helping the user do anything differently.

---

## Decision 11: Partial vs. Full Screen State Ownership

**Chosen: ViewState scope matches the async dependency, not the whole screen**

In SeasonsView and SeasonDriversView, the *entire* screen content depends on the network fetch. No data = nothing to show. The `switch` on `viewModel.state` replaces the whole view body.

In DriverProfileView, the driver's info (name, nationality, number, date of birth) is already in hand — passed from the previous screen. Only the image is async. The `switch` on `viewModel.state` is scoped to *just the image area* of the layout. Driver info renders immediately and unconditionally, regardless of image state.

This means `ViewState<URL>` in the DriverProfileViewModel describes the image lifecycle, not the screen lifecycle. The same enum serves a narrower scope. The generic type parameter (`URL` vs `[Season]` vs `[Driver]`) already communicates what's being tracked.

---

## Decision 12: Reusable Error Handling

**Chosen: Shared `ErrorView` component with action injection**

`ErrorView` takes a `message: String` and `onRetry: () -> Void`. The retry closure is provided by the caller, not hardcoded — this allows one component to serve all screens without knowing what function to call. The caller wraps its specific async retry function in a `Task { }` closure to bridge from the synchronous `() -> Void` signature to async ViewModel methods.

Loading states use SwiftUI's built-in `ProgressView()` directly rather than a custom wrapper, since no additional customization beyond frame sizing is needed. If loading states grow more complex (e.g., skeleton screens, progress percentages), a shared component would be warranted.

`ErrorView` lives in `Core/SharedViews/`.

This pattern — a component that defines the *shape* of an interaction while the caller fills in the *specifics* — is reused across the app (e.g., `.navigationDestination` closures, ForEach with key paths).

---

## API Notes

### Base URL & Headers

- Base URL: `https://api.jolpi.ca/ergast/f1/`
- All requests must include header: `Content-Type: application/json` (required by spec, even though the API responds with JSON regardless — the spec is testing that we know how to set HTTP headers on requests from code).
- Note: `URLSession` caches API responses by default using HTTP caching headers. This is good for production (faster, more resilient) but can mask network errors during testing. To test error states, clear the simulator cache or modify the URL to bypass the cache.

### Response Structure

All three endpoints share the same wrapper pattern:

```
response → MRData → [SeasonTable | DriverTable] → [Seasons | Drivers]
```

This means four levels of nesting before reaching actual data. Swift model structs must account for each layer.

### Endpoints

- `GET /seasons?limit=100` — list of all F1 seasons
- `GET /{year}/drivers?limit=100` — drivers in a specific season
- `GET /drivers/{driverId}` — single driver details (not currently used — driver data is passed via navigation)

Endpoints 2 and 3 return **the same Driver object structure** (driverId, permanentNumber, code, url, givenName, familyName, dateOfBirth, nationality). One `Driver` struct covers both. The detail endpoint does not provide additional fields beyond what the season driver list already contains. This means the Driver Detail screen receives a `Driver` object passed from the list screen via navigation — no additional fetch needed for driver data. Only the profile image requires a separate network call (to Google Custom Search API).

### Pagination

The API paginates with `limit` and `offset` parameters. Default limit is 30.

- Seasons: `total: 77`, default returns only 30 (1950–1979). Missing 47 seasons without explicit limit.
- Drivers per season: varies (e.g., `total: 20` for 2019, `total: 105` for 1952, `total: 36` for 2025).

**Current approach:** `?limit=100` on both the seasons and drivers endpoints to fetch all results in one request.

**Known limitation:** 1952 has 105 drivers, exceeding the current `limit=100`. A future pagination implementation would resolve this.

**Future enhancement:** "Load more" button or infinite scroll when reaching the bottom of the list. This would mean managing offset state, appending to existing arrays, detecting whether more data exists, and preventing duplicate fetches. Deferred until core functionality is complete — the UX benefit is real, but the implementation adds meaningful complexity that shouldn't block the three core screens.

### Edge Cases

- `permanentNumber` is a **String** in the JSON (e.g., `"77"` not `77`), and is **optional** — drivers active before 2014 may not have one. Must be decoded as `String?` or the app will crash on older season data.
- The spec requires a fallback display when `permanentNumber` is absent (e.g., "N/A" or an empty string). Current approach: conditionally render the number only if present, showing nothing if absent.
- Some seasons (notably 2025) include sparse driver entries with only `driverId`, `givenName`, and `familyName`. These are filtered out (see Decision 9).
- `code` is optional and only appears on drivers from roughly the mid-1990s onward.
- `url` (Wikipedia link) is present on all full driver records but absent on sparse entries.

---

*This document will be updated as new decisions arise during development.*
