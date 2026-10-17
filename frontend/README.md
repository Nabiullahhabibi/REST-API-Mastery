# Frontend — Flutter REST API Client

## Features

- `Dio`-based reusable `ApiClient`
- Product model parsing from JSON
- Repository separates API/data concerns from UI
- GET list with pagination, search, filtering, sorting
- POST create and DELETE remove
- Loading, empty, and error states
- Debounced search
- Handles `204 No Content` without decoding a JSON body

## Setup

```bash
cd frontend
flutter pub get
flutter run
```

## Set the API base URL

Android emulator can reach your host machine at `10.0.2.2`:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

For a physical Android phone, use your computer's LAN IP address and ensure both devices are on the same network:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api/v1
```

Replace the example IP with your computer's actual local IP. Make sure the OS firewall allows incoming connections on port 3000.

For Android local HTTP development, Android may block cleartext traffic depending on project configuration and OS target. Prefer HTTPS for real deployments; if needed for local development, configure cleartext traffic only for the development build.

## Architecture

```text
ProductsPage
   ↓
ProductRepository
   ↓
ApiClient (Dio)
   ↓
Express REST API
```

The page does not build URLs or decode JSON itself. The repository coordinates endpoint calls and maps responses into typed models.

## Try these behaviors

1. Search `phone`.
2. Select a category.
3. Change sort field and ascending/descending order.
4. Navigate pages.
5. Create a product.
6. Delete a product; backend returns `204 No Content`.

## Current scope

The UI currently implements list/search/filter/sort/pagination/create/delete. The backend supports GET by ID, PUT, and PATCH as well; use Postman/curl now and extend the Flutter UI as a practice exercise.

Authentication screens/token storage are intentionally not included yet. The API client has a clear place to add an `Authorization: Bearer ...` header when auth is studied.
