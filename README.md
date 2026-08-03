# Stock Watchlist

A small full-stack coding challenge that displays a closed set of stocks from MongoDB and lets a user maintain one shared watchlist.

## Features

- Market and Watchlist tabs with the supplied stock metrics
- MongoDB-backed add and remove actions
- Loading, empty, retry, and mutation-error states
- Responsive Flutter Web layout for desktop Chrome
- Consistent REST errors and HTTP status codes

## Technology

- Java 17, Spring Boot 3.5, Maven Wrapper
- Spring Web, Spring Data MongoDB, Bean Validation
- Flutter Web, Dart, Material 3, Riverpod, `http`
- MongoDB on the default local port

## Architecture

The backend follows a small controller-service-repository structure. Controllers handle HTTP, services hold watchlist rules, and Spring Data repositories access MongoDB. Stock documents are converted to one API DTO. The watchlist stores ticker references only and resolves them to current stock documents with one batch query.

The frontend has one API service and one Riverpod notifier. The notifier owns market stocks and the watched ticker set, so both tabs always derive from the same state. Add and remove actions use confirmed server responses and do not reload all stocks.

```text
backend/   Spring Boot REST API
frontend/  Flutter Web application
```

## Prerequisites

- Java 17
- Flutter with Chrome Web support
- MongoDB Community Server, `mongosh`, and `mongoimport`

This repository contains `.java-version` with `17`. With `jenv` configured, verify it with:

```bash
jenv version
java -version
```

Global Maven is not required because the backend includes Maven Wrapper.

## MongoDB setup

Start MongoDB installed through Homebrew:

```bash
brew services start mongodb-community
```

The stock JSON is source data for a one-time manual import only. It must not be added to backend resources or Flutter assets:

```bash
mongoimport --uri mongodb://localhost:27017/stock_watchlist \
  --collection stocks --file /path/to/stocks.json --jsonArray
```

Create the required unique indexes:

```bash
mongosh mongodb://localhost:27017/stock_watchlist --eval \
  'db.stocks.createIndex({ticker: 1}, {unique: true}); db.watchlist.createIndex({ticker: 1}, {unique: true})'
```

Database: `stock_watchlist`. Collections: `stocks` and `watchlist`. The application never seeds stocks or supplies fallback records; an empty `stocks` collection produces an empty API list.

## Run the backend

```bash
cd backend
./mvnw spring-boot:run
```

Configuration can be overridden without editing source:

- `MONGODB_URI` (default `mongodb://localhost:27017/stock_watchlist`)
- `SERVER_PORT` (default `8080`)
- `CORS_ALLOWED_ORIGIN_PATTERNS` (default `http://localhost:*`)

The localhost origin pattern supports Flutter's random development port while excluding non-local origins. For another environment, provide a comma-separated list of trusted origin patterns.

## Run the frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

The API URL defaults to `http://localhost:8080/api` and is configured at build time with `API_BASE_URL`.

## Tests and builds

```bash
cd backend
./mvnw clean compile
./mvnw test

cd ../frontend
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web
```

## REST API

| Method | Path | Success |
|---|---|---|
| `GET` | `/api/stocks` | `200` with all stocks |
| `GET` | `/api/watchlist` | `200` with resolved watched stocks |
| `POST` | `/api/watchlist/{ticker}` | `201` with the added stock |
| `DELETE` | `/api/watchlist/{ticker}` | `204` |

Expected errors include `400` for invalid ticker syntax, `404` for an unknown stock or missing watchlist entry, `409` for a duplicate entry, and `503` when MongoDB is unavailable. Errors share the fields `timestamp`, `status`, `code`, `message`, and `path`.

## Assumptions and design decisions

- The challenge has one shared local watchlist because it defines no users or authentication.
- Tickers are trimmed and uppercased before service operations.
- Watchlist documents store only the ticker, avoiding duplicated stock metrics.
- Unique MongoDB indexes are the final duplicate guard under concurrent requests.
- Removing a ticker that is not watched returns `404`.
- Market and watchlist requests run concurrently on startup; mutations update local state only after backend success.

## Troubleshooting

- Connection errors: verify `brew services list` and the MongoDB URI.
- Empty Market tab: verify `db.stocks.countDocuments({})` in `mongosh`; the app does not seed data.
- Browser CORS errors: ensure the frontend uses localhost or configure `CORS_ALLOWED_ORIGIN_PATTERNS` with the exact trusted origin pattern.
- Wrong Java version: run `jenv local 17` from the repository root.
- Chrome missing from Flutter: run `flutter devices` and `flutter doctor`.
