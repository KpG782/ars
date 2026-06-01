# ARS Rapide Chatbot API - Proper Implementation Guide

This guide shows how to call the ARS Rapide chatbot API outside Swagger/OpenAPI docs and integrate it safely in real apps.

## 1) Base Info

- Base URL: `https://pacebeats-ars-chatbot.kygozf.easypanel.host`
- Chat endpoint: `POST /chat`
- Health endpoint: `GET /health`
- Metrics endpoints: `GET /metrics`, `GET /stats`
- Auth header (required): `X-API-Key: <YOUR_API_KEY>`

## 2) Temporary Rate Limit Note

- Temporary capacity update: **2x rate limits until April 2, 2026**.
- Do not rely on temporary limits for long-term sizing. Keep retry/backoff in place.

## 3) Required Request Format (`/chat`)

### Request body

```json
{
  "message": "My brake pads are squealing loudly",
  "conversation_id": "conv_12345",
  "user_id": "user_67890"
}
```

- `message` (required): User issue description
- `conversation_id` (optional but recommended): Keep multi-turn context
- `user_id` (optional): Analytics/tracing

### Response fields (typical)

- `response` (string)
- `confidence` (number)
- `intent` (string)
- `urgency` (string)
- `cost_estimate` (object; may include detailed service pricing)
- `conversation_id` (string)
- `cached` (boolean)
- `latency_ms` (number)

## 4) Test Outside Swagger

### cURL (Windows `cmd` style)

```bash
curl -X POST "https://pacebeats-ars-chatbot.kygozf.easypanel.host/chat" ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -H "X-API-Key: %ARS_RAPIDE_API_KEY%" ^
  -d "{\"message\":\"My brake pads are squealing loudly\",\"conversation_id\":\"conv_12345\",\"user_id\":\"user_67890\"}"
```

### PowerShell

```powershell
$headers = @{
  "Accept" = "application/json"
  "Content-Type" = "application/json"
  "X-API-Key" = $env:ARS_RAPIDE_API_KEY
}

$body = @{
  message = "My brake pads are squealing loudly"
  conversation_id = "conv_12345"
  user_id = "user_67890"
} | ConvertTo-Json

Invoke-RestMethod `
  -Uri "https://pacebeats-ars-chatbot.kygozf.easypanel.host/chat" `
  -Method Post `
  -Headers $headers `
  -Body $body
```

### JavaScript (`fetch`)

```javascript
const res = await fetch("https://pacebeats-ars-chatbot.kygozf.easypanel.host/chat", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
    "X-API-Key": process.env.ARS_RAPIDE_API_KEY
  },
  body: JSON.stringify({
    message: "My brake pads are squealing loudly",
    conversation_id: "conv_12345",
    user_id: "user_67890"
  })
});

if (!res.ok) {
  const errText = await res.text();
  throw new Error(`Chat API failed (${res.status}): ${errText}`);
}

const data = await res.json();
console.log(data);
```

## 5) Production Integration Checklist

- Store API key in environment variables or secret manager (never hardcode in app code).
- Do not expose API key in mobile/web client bundles; call API via your backend proxy when possible.
- Use request timeout (for example 15 to 30 seconds).
- Add retries with exponential backoff for `429` and `5xx`.
- Reuse `conversation_id` per chat thread.
- Log `latency_ms`, status code, and request IDs for monitoring.
- Handle `422` validation errors with user-friendly messages.
- Add fallback UX when chatbot is unavailable.

### Flutter app config (`--dart-define`)

The app integration reads:

- `ARS_CHATBOT_BASE_URL`
- `ARS_CHATBOT_API_KEY`

Run with:

```bash
flutter run --dart-define=ARS_CHATBOT_BASE_URL=https://pacebeats-ars-chatbot.kygozf.easypanel.host --dart-define=ARS_CHATBOT_API_KEY=YOUR_KEY
```

Build with:

```bash
flutter build apk --release --dart-define=ARS_CHATBOT_BASE_URL=https://pacebeats-ars-chatbot.kygozf.easypanel.host --dart-define=ARS_CHATBOT_API_KEY=YOUR_KEY
```

## 6) Common Errors

### 401/403 Unauthorized
- Missing or invalid `X-API-Key`.

### 422 Validation Error
- Missing `message` or invalid JSON shape.

### 429 Too Many Requests
- Rate limit hit. Retry with backoff and jitter.

### 5xx Server Error
- Temporary backend issue. Retry with capped backoff and alerting.

## 7) Security Actions (Important)

If an API key has been pasted in chats, screenshots, commits, or docs:

1. Rotate/regenerate the key immediately.
2. Revoke the old key.
3. Update all environments (`dev`, `staging`, `prod`).
4. Check access logs for abnormal usage.

## 8) Quick Health Check

```bash
curl -X GET "https://pacebeats-ars-chatbot.kygozf.easypanel.host/health" -H "Accept: application/json"
```

Use this endpoint for uptime checks before sending user traffic to `/chat`.
