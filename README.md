# Movies API

A Rails 7.2 JSON API backed by a SQLite database of movies, cast, and crew from the last 15 years.

---

## Getting Started

### Prerequisites

- Ruby 3.3.6 (set in `.ruby-version`)
- Bundler
- SQLite3

### Setup

**1. Install dependencies**

```bash
bundle install
```

**2. Add the database**

Download `movies.db` from the [Google Drive link](https://drive.google.com/file/d/1Jt3GCLI97wisxnrbLk5tNAnXzQTipKZv/view) provided in the assessment and place it in the `db/` directory:

```
movies-api/db/movies.db
```

**3. Run migrations**

The original database has been normalised through a series of migrations. Run them all to bring the schema up to date:

```bash
bundle exec rails db:migrate
```

This will:
- Extract genres into their own `genres` and `title_genres` tables
- Split the `crew` table into separate `directors` and `writers` tables
- Parse comma-delimited character lists and professions into JSON arrays
- Remove orphaned title references from `names.known_for_titles`

**4. Prepare the test database**

```bash
bundle exec rails db:test:setup
```

This copies the migrated development database to `db/movies-test.db` for use by the test suites.

**5. Start the server**

```bash
bundle exec rails server
```

The API will be available at `http://localhost:3000`.

---

## Running Tests

The project has two test suites.

**Minitest** (model and controller unit tests):

```bash
bundle exec rails test
```

**RSpec** (request/integration specs covering every endpoint):

```bash
bundle exec rspec
```

Run both together:

```bash
bundle exec rails test && bundle exec rspec
```

---

## Manual Testing (Postman)

[Postman](https://www.postman.com/) or something similar is recommended for exploring the API manually. Import the base URL `http://localhost:3000` and use the endpoint reference below.

---

## API Reference

| Method | Endpoint | Description | Params |
|--------|----------|-------------|--------|
| GET | `/titles` | Paginated list of titles | `year`, `runtime`, `genre`, `rating`, `page` (at least one filter required) |
| GET | `/titles/:id` | Full detail for a single title | — |
| GET | `/titles/:id/writers` | Writers credited on a title | — |
| GET | `/titles/:id/directors` | Directors credited on a title | — |
| GET | `/titles/:id/cast` | Actors and actresses credited on a title | — |
| GET | `/titles/:id/principals` | Everyone credited on a title | — |
| GET | `/writers/:id` | Writer detail and filmography | — |
| GET | `/directors/:id` | Director detail and filmography | — |
| GET | `/cast/:id` | Actor/actress detail and filmography | — |
| GET | `/principals/:id` | Person detail and full credit history | — |

### Filter examples

```
GET /titles?year=2020
GET /titles?genre=Comedy
GET /titles?rating=7.5
GET /titles?runtime=90
GET /titles?year=2020&genre=Drama&rating=7.0&page=2
```

### Pagination

All `/titles` index responses are paginated at 50 results per page and return the following envelope:

```json
{
  "total_pages": 7,
  "page": 1,
  "total_result": 346,
  "result_count": 50,
  "titles": [ ... ]
}
```

---

## What I Implemented

### Problem 1 — Models and Controllers

- Created models for all 5 database tables (`Title`, `Rating`, `Principal`, `Crew`, `Name`) with associations and validations.
- Created controllers for each model with `index` and `show` actions returning static sample responses as a starting point.
- Wired up RESTful routes restricted to `index` and `show`.
- Added Minitest model tests (validations, associations) and controller tests (response shape).
- Configured RSpec alongside the Rails default Minitest suite.

### Problem 2 — Database Normalisation

Ten migrations were written to clean and normalise the database. They were intentionally split granularly — schema changes, data migrations, and column drops are separate migrations so each step can be reasoned about and reviewed independently.

**Genres** (`titles.genres` → `genres` + `title_genres`):
- Migration 1: Create `genres` and `title_genres` tables with unique indexes.
- Migration 2: Parse the comma-delimited `genres` column and populate both tables (batched, ~261k titles, 25 distinct genres → 386k join records).
- Migration 3: Drop `titles.genres` column.

**Crew** (`crew` table → `directors` + `writers`):
- Migration 4: Create `directors` table.
- Migration 5: Create `writers` table.
- Migration 6: Parse `crew.directors` and `crew.writers` (comma-delimited name IDs) and populate the new tables (batched, ~257k crew rows → 291k directors, 323k writers).
- Migration 7: Drop the `crew` table.

**In-place data transformations**:
- Migration 8: Parse `principals.characters` from `[Char1,Char2]` bracket format into a proper JSON array (batched CASE WHEN updates, ~1.35M rows, ~11 seconds).
- Migration 9: Parse `names.primary_profession` from comma-delimited into a JSON array (~1.3M rows).
- Migration 10: Parse `names.known_for_titles` from comma-delimited into a JSON array, filtering out any title IDs not present in the `titles` table to remove orphaned references (~108k names had all references pruned).

**Key decisions:**
- Used `CASE WHEN` bulk SQL updates within batches rather than individual `UPDATE` statements to keep data migrations fast (one query per 1000-row batch instead of 1000 queries).
- `characters` column: treated as a comma-delimited list and split on commas. If a character name contains a comma it becomes two entries — this was a deliberate trade-off since it felt safer than treating the entire string as a single character.

### Problem 3 — Routes, Responses, and Scopes

- Overhauled routes: removed unused endpoints (`/ratings`, `/names`, `/crews`) and added nested member routes under `/titles` plus top-level person endpoints.
- Added 4 chainable Active Record scopes to `Title`: `by_year`, `by_runtime`, `by_genre`, `by_rating`.
- Implemented `TitlesController#index` with filter enforcement (400 if no filters provided) and all 4 scopes.
- Implemented `TitlesController#show` with a single eager-loaded query covering genres, rating, writers, directors, and principals — cast is filtered from the already-loaded principals in Ruby to avoid an extra query.
- Added nested title actions: `/titles/:id/writers`, `/directors`, `/cast`, `/principals`.
- Created `WritersController`, `DirectorsController`, `CastController`, and `PrincipalsController` with person detail and filmography responses.
- Extracted shared serialization helpers (`title_summary`, `name_summary`, `principal_entry`, `person_detail`) into `ApplicationController` to avoid duplication across controllers.
- `PrincipalsController#show` groups multiple credits per title in Ruby from a single eager-loaded query, producing a `credits` array on each filmography entry.

### Problem 4 — Pagination

- Added a `page` parameter to `GET /titles`.
- Page size is fixed at 50 (`PAGE_SIZE = 50` constant in `TitlesController`).
- Implementation runs two queries: a `COUNT` on the filtered relation, then a `SELECT` with `LIMIT`/`OFFSET` and `includes` for the page data.
- Response envelope changed from a plain array to `{ total_pages, page, total_result, result_count, titles }`.

### Problem 5 — Test Coverage

- Wrote RSpec request specs for all 10 endpoints using real preconfigured database records.
- Each spec uses `let!` blocks to create isolated test data (rolled back after each example via transactional fixtures) and `context` blocks to separate happy path, edge cases, and 404 scenarios.
- Response shape, filter behaviour, cast filtering, pagination metadata, and credit grouping are all explicitly asserted.

---

## What I Would Do Next / Differently

**Features and improvements:**

- **Variable page size** — `page_size` is currently hardcoded at 50. Accepting it as a query param (with a sensible cap, e.g. max 200) would make the API more flexible.
- **Sorting** — `/titles` has no sort order beyond what SQLite returns by default. Adding an `order` param (`year`, `rating`, `runtime`) would make paging more useful.
- **Multi-value filters** — currently each filter accepts a single value. Accepting comma-delimited genre lists or rating ranges would allow richer queries.
- **Full-text search** — a `search` param on `/titles` backed by SQLite FTS5 would be a natural extension.
- **Rate limiting** — no rate limiting is in place. In production, `rack-attack` would be the obvious addition.
- **Caching** — person detail responses (`/writers/:id`, `/directors/:id`, etc.) are expensive joins that change infrequently. HTTP cache headers or a Redis-backed fragment cache would help significantly at scale.
- **API versioning** — namespacing routes under `/v1` from the start would make future breaking changes easier to manage.
- **Create/Update Endpoints** - In order to keep this movie database up to date having a way to programatically create new data or update existing data would be essential.

**Technical improvements:**

- **JSON serializers** — response shape is currently built with inline Ruby hashes in controllers. A dedicated serializer layer (e.g. `blueprinter` or `alba`) would make the response format easier to maintain and test independently of controller logic.
- **Characters parsing** — treating `principals.characters` as a comma-delimited list was the practical choice, but it means character names containing commas are split into two entries. The original IMDB format uses quoted JSON arrays; a more robust parser could handle that correctly.
- **Background migrations** — the data migrations (character parsing, JSON rewrites) took 10–16 seconds each on a 3M-row table. In a production setting these would be run as online background jobs to avoid downtime.
- **N+1 monitoring** — adding `bullet` gem in development would surface any N+1 queries introduced by future changes before they reach production.

---

## AI Assistance Disclosure

This project was built with the assistance of **Claude Code** (Anthropic). Claude was used throughout — for scaffolding models and controllers, writing migrations, implementing controller logic, and generating test coverage across both Minitest and RSpec.

All generated output was reviewed, and several corrections and design decisions were made during the session (e.g. splitting the crew migration into separate director/writer migrations, choosing to define models before migrations rather than using inline class definitions, the comma-delimited interpretation of the `characters` column).
