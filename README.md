# REST API Mastery — Flutter + Node.js + Express + MySQL

A learning project for practicing HTTP, REST resource design, CRUD, status codes, headers, JSON, validation, pagination, filtering, sorting, searching, versioning, error responses, and Flutter repository/API-client architecture.

## Architecture

```text
Flutter UI → ProductRepository → ApiClient (Dio) → HTTPS/HTTP → Express /api/v1 → Service → MySQL
```

## Project layout

- `backend/` — Express REST API, MySQL schema, validation, error handling, and backend README.
- `frontend/` — Flutter client with API client, models, repository, and UI README.

## Prerequisites

- Node.js 20+
- MySQL 8+
- Flutter stable + Dart
- Android emulator or a physical Android device
- Postman or curl (optional, useful for inspecting HTTP)

## Quick start

1. Read `backend/README.md` and configure `backend/.env`.
2. Create the database and tables using `backend/sql/schema.sql`.
3. Start the backend using `npm install` and `npm run dev`.
4. Read `frontend/README.md`, run `flutter pub get`, and set the API base URL for your device.
5. Test backend routes before debugging Flutter.

## Main endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/v1/health` | Health check |
| GET | `/api/v1/products` | List + pagination/filter/sort/search |
| POST | `/api/v1/products` | Create |
| GET | `/api/v1/products/:id` | Read one |
| PUT | `/api/v1/products/:id` | Replace editable fields |
| PATCH | `/api/v1/products/:id` | Partially update |
| DELETE | `/api/v1/products/:id` | Delete; returns 204 |
| GET | `/api/v1/categories` | List categories |
| GET | `/api/v1/docs` | Human-readable route overview |

## Example list request

```http
GET /api/v1/products?page=1&limit=10&search=phone&category=Electronics&sort=price&order=asc
Accept: application/json
```

## Topics practiced

- HTTP request/response, methods, headers, JSON
- REST resources and CRUD
- `200`, `201`, `204`, `400`, `401`, `403`, `404`, `409`, `422`, `500`, `502`, `503`
- Query parameters, pagination, filtering, sorting, searching
- Versioned URLs (`/api/v1`)
- Consistent errors and request IDs
- Flutter `ApiClient` + repository separation
- Input validation and SQL parameterization

## Important note about status codes

The demo naturally demonstrates `200`, `201`, `204`, `400`, `404`, `409`, and `422`. `401` and `403` are included in the error-handling examples/docs and are returned by the example auth/authorization middleware if enabled; `500` is handled centrally. `502` and `503` are infrastructure/dependency failures, so their real use is explained in the docs rather than being artificially returned for normal product operations.

This is a learning starter, not a production-ready security baseline. Before production, add authentication/authorization, rate limiting, CORS allowlists, secrets management, migrations, tests, and deployment hardening.
