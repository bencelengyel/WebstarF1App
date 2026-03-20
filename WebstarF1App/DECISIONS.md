# Architecture Decisions — F1 Seasons App

Decisions made before writing any code. This document exists so that any developer joining the project understands *why* things are built the way they are, not just *how*.

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

Phase 1: Network calls are written directly in each ViewModel using `URLSession`. This is intentional — to deeply understand the mechanics of HTTP requests, JSON decoding, headers, and async/await before abstracting.

Phase 2: Once patterns emerge from repetition (URL construction, header setup, error handling, JSON decoding), the shared logic will be extracted into a single `F1APIService` that all ViewModels use.

Alternatives considered:
- **Shared API Service from the start:** Cleaner, but risks building an abstraction without understanding what it abstracts.
- **Third-party library (Alamofire):** Unnecessary for simple GET requests. Adds a dependency without clear benefit at this scale.

---

## Decision 3: Data Models

**Chosen: Single set of Codable structs used by both networking and Views**

API responses are decoded directly into structs (e.g., `Season`, `Driver`) that Views also use to render data. `CodingKeys` are used where API field names don't match Swift conventions.

No separate "domain model" layer at this stage. The app has 3 screens and 3 API calls — the overhead of a mapping layer is not justified.

Alternatives considered:
- **Separate API models and domain models:** Proper separation of concerns, but doubles the number of model files for minimal practical benefit at this scale. Revisit if the app grows significantly.

---

## Decision 4: Navigation

**Chosen: NavigationStack with NavigationLink**

The app has a linear 3-screen flow (Seasons → Drivers → Driver Detail) plus external links to Wikipedia. `NavigationStack` handles this natively with built-in back-button support and type-safe navigation via `navigationDestination(for:)`.

Wikipedia links are opened using `@Environment(\.openURL)` or `SFSafariViewController` for in-app browsing.

Alternatives considered:
- **Coordinator pattern:** Common in UIKit, offers full navigation control. Significant complexity overhead for a 3-screen linear flow. Not natural in SwiftUI.

---

## Decision 5: Project Structure

**Chosen: Group by feature**

```
F1App/
├── App/                  # App entry point, root NavigationStack
├── Core/
│   ├── Networking/       # Shared API service (Phase 2)
│   ├── Models/           # Shared Codable structs
│   └── Extensions/       # Helpers (date formatting, etc.)
├── Features/
│   ├── Seasons/          # SeasonsView + SeasonsViewModel
│   ├── Drivers/          # DriversView + DriversViewModel
│   └── DriverDetail/     # DriverDetailView + DriverDetailViewModel
└── Resources/            # Assets, nationality-to-flag mappings
```

Each feature folder contains everything needed to understand that screen. Shared code (models, networking, utilities) lives in `Core/`.

Alternatives considered:
- **Group by type (Models/, Views/, ViewModels/):** Simpler mental model for finding files by role, but requires jumping across multiple folders to work on a single feature. Scales poorly.

---

## Decision 6: State Management

**Chosen: Optionals and booleans**

Each ViewModel uses explicit `@Published` properties:
- `isLoading: Bool`
- `errorMessage: String?`
- `seasons: [Season]` (or equivalent data array)

Known trade-off: These properties can theoretically fall out of sync (e.g., `isLoading` still true after an error is set). Careful management in the ViewModel is required.

Alternatives considered:
- **Single ViewState enum with associated values:** Eliminates contradictory states entirely. More expressive, but requires comfort with Swift enum associated values. Flagged as a potential refactor once the app is working.

---

## Decision 7: Git Workflow

**Chosen: Feature branches merged into main**

Each logical piece of work (networking layer, each screen, bonus features) is developed on a dedicated branch and merged into `main` when complete.

Branch naming convention: `feature/<description>` (e.g., `feature/seasons-screen`, `feature/networking-abstraction`)

Commit messages: Present-tense, descriptive (e.g., "Add seasons list view with API integration")

Alternatives considered:
- **All work on main:** Simpler, but doesn't reflect team workflows and makes rollback difficult.

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

## API Notes

### Base URL & Headers

- Base URL: `https://api.jolpi.ca/ergast/f1/`
- All requests must include header: `Content-Type: application/json` (required by spec, even though the API responds with JSON regardless — the spec is testing that we know how to set HTTP headers on requests from code).

### Response Structure

All three endpoints share the same wrapper pattern:

```
response → MRData → [SeasonTable | DriverTable] → [Seasons | Drivers]
```

This means four levels of nesting before reaching actual data. Swift model structs must account for each layer.

### Endpoints

- `GET /seasons?limit=100` — list of all F1 seasons
- `GET /{year}/drivers` — drivers in a specific season
- `GET /drivers/{driverId}` — single driver details

Endpoints 2 and 3 return **the same Driver object structure** (driverId, permanentNumber, code, url, givenName, familyName, dateOfBirth, nationality). One `Driver` struct covers both. The detail endpoint does not provide additional fields beyond what the season driver list already contains. This means the Driver Detail screen could either receive a `Driver` object passed from the list screen or fetch it independently — both are valid approaches.

### Pagination

The API paginates with `limit` and `offset` parameters. Default limit is 30.

- Seasons: `total: 77`, default returns only 30 (1950–1979). Missing 47 seasons without explicit limit.
- Drivers per season: `total: 20` for 2019, fits within default limit of 30.

**Current approach:** `?limit=100` on the seasons endpoint to fetch all results in one request.

**Future enhancement:** "Load more" button or infinite scroll when reaching the bottom of the list. This would mean managing offset state, appending to existing arrays, detecting whether more data exists, and preventing duplicate fetches. Deferred until core functionality is complete — the UX benefit is real, but the implementation adds meaningful complexity that shouldn't block the three core screens.

### Edge Cases

- `permanentNumber` is a **String** in the JSON (e.g., `"77"` not `77`), and is **optional** — drivers active before 2014 may not have one. Must be decoded as `String?` or the app will crash on older season data.
- The spec requires a fallback display when `permanentNumber` is absent (e.g., "N/A" or an empty string).

---

*This document will be updated as new decisions arise during development.*
