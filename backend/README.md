# Backend — Express REST API

## Stack

- Node.js (ES modules)
- Express
- MySQL 8 + `mysql2/promise`
- Zod validation
- Helmet, CORS, centralized errors, request IDs

## Setup

```bash
cd backend
npm install
```

Copy `.env.example` to `.env` and set your MySQL credentials. Then run the SQL file:

```bash
mysql -u root -p < sql/schema.sql
```

Start development server:

```bash
npm run dev
```

Expected base URL: `http://localhost:3000/api/v1`.

## Routes

| Method | Path | Success |
|---|---|---|
| GET | `/health` | 200; 503 if database unavailable |
| GET | `/products` | 200 |
| POST | `/products` | 201 + `Location` header |
| GET | `/products/:id` | 200 or 404 |
| PUT | `/products/:id` | 200 or 404 |
| PATCH | `/products/:id` | 200 or 404 |
| DELETE | `/products/:id` | 204 or 404 |
| GET | `/categories` | 200 |
| GET | `/docs` | 200 |

Prefix is `/api/v1`; paths in this table are relative to it.

## Request examples

Create:

```bash
curl -i -X POST http://localhost:3000/api/v1/products \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{"name":"Desk Lamp","description":"LED lamp","category":"Office","price":29.99,"stock":20}'
```

List with search/filter/sort/pagination:

```bash
curl -i 'http://localhost:3000/api/v1/products?page=1&limit=5&search=phone&category=Electronics&sort=price&order=asc'
```

Partial update:

```bash
curl -i -X PATCH http://localhost:3000/api/v1/products/1 \
  -H 'Content-Type: application/json' \
  -d '{"price":749}'
```

Delete (204 has no body):

```bash
curl -i -X DELETE http://localhost:3000/api/v1/products/1
```

## Status-code practice

- `200`: successful read/update
- `201`: successful creation; response includes `Location`
- `204`: delete succeeded, no response body
- `400`: invalid path ID / malformed request
- `401`: use for missing/invalid credentials once auth middleware is added
- `403`: use for authenticated users lacking permission
- `404`: resource/route not found
- `409`: duplicate product name
- `422`: validation errors from Zod
- `500`: unexpected backend failure (generic public message; details only logged)
- `502`: gateway/proxy got an invalid upstream response; generally infrastructure-level
- `503`: database dependency unavailable in this demo

## Design decisions

- Resource-based URLs: `/products`, `/products/:id`
- Query parameters control list operations.
- SQL values use placeholders; sort/order are allowlisted before SQL interpolation.
- `requestId` is attached to each request and returned in error bodies.
- Validation occurs on the server even if Flutter validates too.
- `204` intentionally has no JSON response.
- API version is in the URL (`/api/v1`).

## Limitations / next improvements

This is an educational starter. Add automated tests, authentication (JWT), authorization (401/403), rate limiting, stricter CORS, structured logger, database migrations, and production deployment configuration before using it for real users.
