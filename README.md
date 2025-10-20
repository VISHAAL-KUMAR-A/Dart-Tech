# Dart Backend API - Notes Management System

A minimal REST API backend built with Dart and Shelf framework featuring CRUD operations for notes, API key authentication, rate limiting, and tier-based feature flags.

## 🚀 Features

- **Notes CRUD API** - Full create, read, update, delete operations
- **API Key Authentication** - Secure endpoints with X-API-Key header validation
- **Rate Limiting** - Per-API-key rate limiting with configurable limits
- **Feature Flags** - Tier-based feature access (Sandbox, Standard, Enhanced, Enterprise)
- **Structured Logging** - JSON-formatted request/response logging
- **Health Check** - Basic health check endpoint
- **In-Memory Storage** - Fast in-memory data storage

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Server](#running-the-server)
- [API Documentation](#api-documentation)
- [Testing with Postman](#testing-with-postman)
- [Running Tests](#running-tests)
- [Docker](#docker)

---

## Prerequisites

- **Dart SDK** 3.x or higher
- **Docker** (optional, for containerized deployment)

---

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dart-backend-tech-test_v2
   ```

2. **Install dependencies**
   ```bash
   cd app
   dart pub get
   ```

---

## Configuration

### Environment Variables

Configure the following environment variables:

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `PORT` | Server port | `8080` | `8080` |
| `API_KEYS` | Colon-separated list of valid API keys | - | `key1:key2:key3` |
| `RATE_LIMIT_MAX` | Maximum requests per window | `60` | `100` |
| `RATE_LIMIT_WINDOW_SEC` | Rate limit window in seconds | `60` | `60` |

### API Key Setup

API keys determine tier access for feature flags:
- Keys containing `enterprise` → **Enterprise** tier
- Keys containing `enhanced` → **Enhanced** tier
- Keys containing `standard` → **Standard** tier
- All other keys → **Sandbox** tier

**Example API Keys:**
```
hello
my_standard_key
my_enhanced_key
my_enterprise_key
```

---

## Running the Server

### Option 1: Without API Key Authentication (Development)

```bash
cd app
dart run bin/server.dart
```

In this mode, all requests are allowed without authentication.

### Option 2: With API Key Authentication

**Windows PowerShell:**
```powershell
cd app
$env:API_KEYS="hello:my_standard_key:my_enhanced_key:my_enterprise_key"
dart run bin/server.dart
```

**Linux/Mac:**
```bash
cd app
export API_KEYS="hello:my_standard_key:my_enhanced_key:my_enterprise_key"
dart run bin/server.dart
```

**Windows Command Prompt:**
```cmd
cd app
set API_KEYS=hello:my_standard_key:my_enhanced_key:my_enterprise_key
dart run bin/server.dart
```

The server will start on `http://localhost:8080`

You should see:
```
🚀 Server listening on port 8080
```

---

## API Documentation

### Base URL
```
http://localhost:8080
```

### Authentication
All endpoints (except `/health`) require the `X-API-Key` header:
```
X-API-Key: your_api_key_here
```

---

### Endpoints

#### 1. Health Check
Check if the server is running.

**Request:**
```http
GET /health
```

**Response:** `200 OK`
```
ok
```

---

#### 2. Get Feature Flags
Get available features based on your API key tier.

**Request:**
```http
GET /v1/feature-flags
Headers:
  X-API-Key: my_enterprise_key
```

**Response:** `200 OK`
```json
{
  "tier": "Enterprise",
  "features": {
    "notesCrud": true,
    "oauth": true,
    "advancedReports": true,
    "ssoSaml": true
  }
}
```

**Tier Features:**
- **Sandbox**: `notesCrud`
- **Standard**: `notesCrud`, `oauth`
- **Enhanced**: `notesCrud`, `oauth`, `advancedReports`
- **Enterprise**: `notesCrud`, `oauth`, `advancedReports`, `ssoSaml`

---

#### 3. Create Note
Create a new note.

**Request:**
```http
POST /v1/notes
Headers:
  X-API-Key: your_api_key
  Content-Type: application/json
  
Body:
{
  "title": "My Note Title",
  "content": "Note content goes here"
}
```

**Validation:**
- `title`: Required, 1-120 characters
- `content`: Optional, 0-10,000 characters

**Response:** `201 Created`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "My Note Title",
  "content": "Note content goes here",
  "createdAt": "2025-10-20T10:30:00.000Z",
  "updatedAt": "2025-10-20T10:30:00.000Z"
}
```

---

#### 4. List Notes
Get all notes with pagination.

**Request:**
```http
GET /v1/notes?page=1&limit=20
Headers:
  X-API-Key: your_api_key
```

**Query Parameters:**
- `page` (optional): Page number, default `1`
- `limit` (optional): Items per page, default `20`

**Response:** `200 OK`
```json
{
  "page": 1,
  "limit": 20,
  "total": 5,
  "items": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "My Note Title",
      "content": "Note content goes here",
      "createdAt": "2025-10-20T10:30:00.000Z",
      "updatedAt": "2025-10-20T10:30:00.000Z"
    }
  ]
}
```

---

#### 5. Get Note by ID
Retrieve a specific note.

**Request:**
```http
GET /v1/notes/{id}
Headers:
  X-API-Key: your_api_key
```

**Response:** `200 OK`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "My Note Title",
  "content": "Note content goes here",
  "createdAt": "2025-10-20T10:30:00.000Z",
  "updatedAt": "2025-10-20T10:30:00.000Z"
}
```

**Error:** `404 Not Found`
```
Not found
```

---

#### 6. Update Note
Update an existing note.

**Request:**
```http
PUT /v1/notes/{id}
Headers:
  X-API-Key: your_api_key
  Content-Type: application/json
  
Body:
{
  "title": "Updated Title",
  "content": "Updated content"
}
```

**Response:** `200 OK`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Updated Title",
  "content": "Updated content",
  "createdAt": "2025-10-20T10:30:00.000Z",
  "updatedAt": "2025-10-20T10:35:00.000Z"
}
```

---

#### 7. Delete Note
Delete a note.

**Request:**
```http
DELETE /v1/notes/{id}
Headers:
  X-API-Key: your_api_key
```

**Response:** `204 No Content`

**Error:** `404 Not Found`
```
Not found
```

---

### Error Responses

#### 401 Unauthorized
Invalid or missing API key.
```
Unauthorized: missing or invalid API key
```

#### 400 Bad Request
Validation error.
```
Invalid title
```
or
```
Content too long
```

#### 429 Too Many Requests
Rate limit exceeded.
```
Rate limit exceeded
```
Headers include:
```
Retry-After: 45
```

---

## Testing with Postman

### 1. Start the Server

**Using Standalone PowerShell (Recommended):**
```powershell
cd app
$env:API_KEYS="hello:my_standard_key:my_enhanced_key:my_enterprise_key"
dart run bin/server.dart
```

### 2. Configure Postman

**Base URL:** `http://localhost:8080`

**Add Authentication Header to All Requests:**
- **Key:** `X-API-Key`
- **Value:** `hello` (or any key from your API_KEYS)

### 3. Test Sequence

#### Step 1: Health Check
```
GET http://localhost:8080/health
```
No authentication required.

#### Step 2: Create a Note
```
POST http://localhost:8080/v1/notes
Headers:
  X-API-Key: hello
  Content-Type: application/json
Body:
{
  "title": "Test Note",
  "content": "This is a test"
}
```
Save the returned `id` for next steps.

#### Step 3: List All Notes
```
GET http://localhost:8080/v1/notes?page=1&limit=20
Headers:
  X-API-Key: hello
```

#### Step 4: Get Single Note
```
GET http://localhost:8080/v1/notes/{id}
Headers:
  X-API-Key: hello
```

#### Step 5: Update Note
```
PUT http://localhost:8080/v1/notes/{id}
Headers:
  X-API-Key: hello
  Content-Type: application/json
Body:
{
  "title": "Updated Note",
  "content": "Updated content"
}
```

#### Step 6: Delete Note
```
DELETE http://localhost:8080/v1/notes/{id}
Headers:
  X-API-Key: hello
```

#### Step 7: Test Feature Flags
Test different tiers by changing the API key:

**Sandbox:**
```
GET http://localhost:8080/v1/feature-flags
Headers:
  X-API-Key: hello
```

**Standard:**
```
GET http://localhost:8080/v1/feature-flags
Headers:
  X-API-Key: my_standard_key
```

**Enhanced:**
```
GET http://localhost:8080/v1/feature-flags
Headers:
  X-API-Key: my_enhanced_key
```

**Enterprise:**
```
GET http://localhost:8080/v1/feature-flags
Headers:
  X-API-Key: my_enterprise_key
```

#### Step 8: Test Authentication Failure
```
GET http://localhost:8080/v1/notes
Headers:
  X-API-Key: invalid_key
```
Should return `401 Unauthorized`

#### Step 9: Test Rate Limiting
Send 61+ rapid requests to any endpoint:
```
GET http://localhost:8080/v1/notes
Headers:
  X-API-Key: hello
```
After 60 requests, you'll get `429 Too Many Requests`

---

## Running Tests

Run the test suite:

```bash
cd app
dart test
```

Run tests with verbose output:
```bash
dart test --reporter=expanded
```

---

## Docker

### Build the Docker Image
```bash
docker build -t dart-notes-api:latest -f app/Dockerfile ./app
```

### Run with Docker
```bash
docker run --rm -p 8080:8080 \
  -e API_KEYS="hello:my_standard_key:my_enhanced_key:my_enterprise_key" \
  -e RATE_LIMIT_MAX=100 \
  -e RATE_LIMIT_WINDOW_SEC=60 \
  dart-notes-api:latest
```

### Test Docker Container
```bash
curl http://localhost:8080/health
```

---

## Project Structure

```
app/
├── bin/
│   └── server.dart              # Application entry point
├── lib/
│   └── src/
│       ├── controllers/
│       │   └── notes_controller.dart    # Notes CRUD logic
│       ├── middleware/
│       │   ├── auth.dart               # API key authentication
│       │   ├── logging.dart            # Request/response logging
│       │   └── rate_limit.dart         # Rate limiting
│       ├── models/
│       │   └── note.dart               # Note data model
│       └── services/
│           └── feature_flags.dart      # Feature flags by tier
├── test/
│   └── notes_test.dart          # Test suite
├── pubspec.yaml                 # Dependencies
└── Dockerfile                   # Docker configuration
```

---

## Rate Limiting

- **Algorithm:** Fixed window
- **Default:** 60 requests per 60 seconds per API key
- **Configurable:** Via `RATE_LIMIT_MAX` and `RATE_LIMIT_WINDOW_SEC`
- **Response:** HTTP 429 with `Retry-After` header

---

## Logging

All requests are logged in JSON format:
```json
{
  "method": "POST",
  "path": "/v1/notes",
  "status": 201,
  "duration_ms": "15.23"
}
```

---

## Tech Stack

- **Language:** Dart 3.x
- **Framework:** Shelf (HTTP server)
- **Router:** shelf_router
- **UUID:** uuid package
- **Testing:** test package

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `dart test`
5. Submit a pull request

---

## License

This project is part of a technical assessment.

---

## Support

For issues or questions, please check:
- Dart documentation: https://dart.dev/guides
- Shelf framework: https://pub.dev/packages/shelf
- Project REPORT.md for architecture details
