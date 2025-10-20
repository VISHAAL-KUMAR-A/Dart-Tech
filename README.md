# Dart Backend Technical Test (submission window: up to 4 days)

Welcome! This exercise evaluates your backend fundamentals **without requiring prior Dart experience**. We provide a small Shelf-based HTTP server starter and clear tasks. Focus on clean, pragmatic solutions and tests.

> **Submission window:** You have **up to 4 days** to submit once you receive this.  
> **Expected effort:** ~**2–6 hours** depending on your familiarity. Take less or more time as needed within the window.

---

## 🧪 What you will build

A minimal backend for a fictional SaaS with:
- CRUD for **Notes** (`/v1/notes`)
- **API key auth** per request via `X-API-Key`
- **Rate limiting** per API key
- **Feature flags** endpoint that varies by **tier** (`Sandbox`, `Standard`, `Enhanced`, `Enterprise`)
- Basic **logging** and **error handling**

Optional (bonus):
- Persistence with SQLite via **Drift**
- OpenAPI schema + Swagger UI
- Docker multi-stage build & healthcheck
- Simple CI (GitHub Actions) to run tests

---

## 🧰 Getting started

### Prereqs
- Dart SDK (3.x) or Docker
- Make or Bash (optional)

### Run locally
```bash
cd app
dart pub get
dart run bin/server.dart
```
Server runs on `http://localhost:8080`

### Using Docker
```bash
docker build -t dart-tech-test:dev .
docker run --rm -p 8080:8080 -e API_KEYS="key_sandbox:key_standard:key_enhanced:key_enterprise" dart-tech-test:dev
```

### Quick test
```bash
dart test
```

---

## ✅ Tasks (core scope)

### 1) Notes CRUD
- Implement endpoints in `NotesController`:
  - `POST /v1/notes` → create (fields: `title` (1..120), `content` (0..10k))
  - `GET /v1/notes` → list with pagination (`page`, `limit`)
  - `GET /v1/notes/:id` → fetch
  - `PUT /v1/notes/:id` → update
  - `DELETE /v1/notes/:id` → delete
- In-memory store is fine. **Bonus:** add persistence with SQLite (Drift).

### 2) API Key Authentication
- Middleware reads **`X-API-Key`** and validates against env var `API_KEYS` (colon-separated list).
- Return **401** on missing/invalid key.

### 3) Rate Limiting
- Per API key. Use a simple **fixed window** or **token bucket** (your choice).
- Defaults: 60 requests / 60 seconds per key. Configurable via env:
  - `RATE_LIMIT_MAX=60`
  - `RATE_LIMIT_WINDOW_SEC=60`
- Return **429** when exceeded. Include `Retry-After` header.

### 4) Feature Flags by Tier
- Endpoint: `GET /v1/feature-flags`
- Map API keys to **tiers** and return a JSON describing available features per tier.
  - Tiers: `Sandbox`, `Standard`, `Enhanced`, `Enterprise`
- See `lib/src/services/feature_flags.dart` for starter.

### 5) Logging & Error Handling
- Structured logs (JSON) for request/response metadata + errors.
- Convert thrown errors to JSON responses with status codes.

### 6) Tests
- Add unit tests for services & middleware + integration tests for routes.
- Aim for ~10–15 meaningful tests.

### 7) Performance (light)
- Locally, send 100 requests to `/v1/notes` list and include your P95 latency measurement (any tool).
- Provide a short note in **REPORT.md** on your approach & results.

---

## 📦 Deliverables

- Update code under `app/`
- **REPORT.md** (1–2 pages): architecture choices, tradeoffs, rate limiting approach, test coverage summary, and perf results.
- Provide one of the following:
  1) A **ZIP** of the repository, or a public **Git repo** link, **and**
  2) (Nice to have) A **hosted demo URL** (e.g., Cloud Run/Render) plus a `/health` endpoint.

---

## 🧮 Rubric (what we look for) — 100 pts

- Correctness & API design – 25
- Code quality, structure, maintainability – 20
- Auth & rate limiting – 20
- Tests (coverage & meaningful assertions) – 20
- Error handling & logging – 10
- Documentation & DX – 5

**Bonus (up to +10):** Persistence, OpenAPI, Docker multi-stage, CI.

---

## 📚 Helpful references

- Shelf (HTTP server): https://pub.dev/packages/shelf
- shelf_router: https://pub.dev/packages/shelf_router
- Dart testing: https://pub.dev/packages/test

We value clarity, working software, and thoughtful tradeoffs.
