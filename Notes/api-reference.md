---
tags:
  - project-nuclear
  - api
  - documentation
created: 2026-07-26
updated: 2026-07-26
---

# API Reference — Project Nuclear

> ⚠️ **ต้องอัปเดตทุกครั้งที่มีการแก้ไขหรือเพิ่ม API** — ถ้าเห็น doc นี้ไม่ตรงกับโค้ด ให้แจ้งจาวิส

> Base URL: `https://project-nuclear-api.onrender.com`
> **Swagger UI:** `https://project-nuclear-api.onrender.com/api/docs`

## Authentication

ส่วนใหญ่ endpoint ต้องใช้ JWT Bearer token

```
Authorization: Bearer <access_token>
```

### Login

```
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin1",
  "password": "***"
}
```

**Response 200:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "username": "admin1",
    "role": "superadmin"
  }
}
```

**Response 401:**
```json
{
  "message": "Unauthorized",
  "statusCode": 401
}
```

**Response 400 (missing fields):**
```json
{
  "message": ["username must be a string", "password must be a string"],
  "error": "Bad Request",
  "statusCode": 400
}
```

### Accounts

| Username | Password | Role |
|----------|----------|------|
| `admin1` | `admin123` | `superadmin` |
| `admin2`-`admin5` | `admin123` | `admin` |

---

## Health Check

```
GET /api/health
```

**Auth:** ❌ ไม่ต้อง

**Response 200:**
```json
{
  "status": "ok",
  "timestamp": "2026-07-26T10:10:31.917Z",
  "service": "project-newclear-api",
  "version": "0.0.1"
}
```

---

## Customers

### Create Customer (Public)

```
POST /api/customers
Content-Type: application/json
```

**Auth:** ❌ ไม่ต้อง

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `firstName` | string | ✅ | ชื่อ |
| `lastName` | string | ✅ | นามสกุล |
| `phone` | string | ✅ | เบอร์โทร |
| `email` | string | ❌ | อีเมล (ต้องมี @ ถ้าให้) |
| `lineUserId` | string | ❌ | Line User ID (unique) |
| `address` | string | ❌ | ที่อยู่ |
| `referrerId` | string | ❌ | UUID ของคนชวน |

**Response 201:**
```json
{
  "id": "uuid",
  "firstName": "สมชาย",
  "lastName": "ใจดี",
  "phone": "0812345678",
  "email": "somchai@test.com",
  "lineUserId": null,
  "address": null,
  "referrerId": null,
  "status": "active",
  "createdAt": "2026-07-26T..."
}
```

**Response 400 (missing required fields):**
```json
{
  "message": ["firstName must be a string", "lastName must be a string", "phone must be a string"],
  "error": "Bad Request",
  "statusCode": 400
}
```

**Response 409 (duplicate lineUserId):**
```json
{
  "message": "lineUserId already exists",
  "statusCode": 409
}
```

---

### List Customers (Protected)

```
GET /api/customers?page=1&pageSize=20
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Query Parameters:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | number | 1 | หน้าปัจจุบัน |
| `pageSize` | number | 20 | จำนวนต่อหน้า (แนะนำให้ใช้) |
| `limit` | number | 20 | **[Deprecated]** เดิมใช้ 'limit' — ยังใช้ได้แต่แนะนำ pageSize |

> `pageSize` > `limit` > default 20 (backward compatible)

**Response 200:**
```json
{
  "data": [
    {
      "id": "uuid",
      "firstName": "สมชาย",
      "lastName": "ใจดี",
      "phone": "0812345678",
      "email": "somchai@test.com",
      "status": "active",
      "createdAt": "2026-07-26T..."
    }
  ],
  "page": 1,
  "pageSize": 20,
  "totalItems": 100,
  "totalPages": 5,
  "_links": {
    "self": "/api/customers?page=1&pageSize=20",
    "next": "/api/customers?page=2&pageSize=20",
    "prev": null
  }
}
```

**Response 401 (no token):**
```json
{
  "message": "Unauthorized",
  "statusCode": 401
}
```

---

### Search Customers (Protected)

```
GET /api/customers/search?q=สมชาย
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Query Parameters:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `q` | string | "" | คำค้นหา (firstName, lastName, phone, email) |
| `page` | number | 1 | |
| `pageSize` | number | 20 | จำนวนต่อหน้า |
| `limit` | number | 20 | **[Deprecated]** |

**Response 200:**
```json
{
  "data": [...],
  "page": 1,
  "pageSize": 20,
  "totalItems": 1,
  "totalPages": 1,
  "_links": {
    "self": "/api/customers/search?q=สมชาย&page=1&pageSize=20",
    "next": null,
    "prev": null
  }
}
```

---

### Get Customer by ID (Protected)

```
GET /api/customers/:id
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Response 200:**
```json
{
  "id": "uuid",
  "lineUserId": null,
  "displayName": "สมชาย ใจดี",
  "firstName": "สมชาย",
  "lastName": "ใจดี",
  "phone": "0812345678",
  "email": "somchai@test.com",
  "status": "active",
  "createdAt": "2026-07-26T...",
  "updatedAt": "2026-07-26T..."
}
```

**Response 404:**
```json
{
  "message": "Customer not found",
  "statusCode": 404
}
```

---

### Get Customer by Line User ID (Protected)

```
GET /api/customers/line/:lineUserId
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Response 200:**
```json
{
  "id": "uuid",
  "lineUserId": "Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "firstName": "สมชาย",
  ...
}
```

**Response 404:**
```json
{
  "message": "Customer not found",
  "statusCode": 404
}
```

---

### Update Customer (Protected)

```
PATCH /api/customers/:id
Content-Type: application/json
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Request Body:** (partial — ส่งเฉพาะ field ที่ต้องการแก้)
```json
{
  "phone": "0898765432",
  "email": "newemail@test.com"
}
```

**Response 200:**
```json
{
  "id": "uuid",
  "phone": "0898765432",
  "email": "newemail@test.com",
  "updatedAt": "2026-07-26T..."
}
```

**Response 404:**
```json
{
  "message": "Customer not found",
  "statusCode": 404
}
```

---

## Line Webhook

### Webhook Endpoint

```
POST /api/line/webhook
```

**Auth:** ❌ Signature verification (ใช้ `x-line-signature` header กรณีตั้งค่า `LINE_CHANNEL_SECRET`)

**Content-Type:** `text/plain` (raw JSON string — ตามที่ Line platform ส่ง)

**Request Body:**
```json
{
  "destination": "Uxxxxxxxxxxxxxxxxxxxxxxxxx",
  "events": [
    {
      "type": "follow",
      "source": { "userId": "Uxxxxxxxx", "type": "user" },
      "replyToken": "rxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "timestamp": 1700000000000
    }
  ]
}
```

**Response 200:**
```json
{
  "status": "ok"
}
```

### Event Types

| Event | Data | การทำงาน |
|-------|------|----------|
| `follow` | — | Save log → reply welcome message |
| `postback` | `data: "action=order"` | Save log → reply ข้อความสั่งซื้อ |
| `postback` | `data: "action=register"` | Save log → reply link สมัครสมาชิก |

**หมายเหตุ:** 
- ถ้า `LINE_CHANNEL_SECRET` ยังไม่ตั้งค่า → Signature verify จะข้ามไป (log warning)
- ถ้า `LINE_ACCESS_TOKEN` ยังไม่ตั้งค่า → Push message จะไม่ทำงาน
- ทุก event จะถูก log ลง `line_events` table ใน DB

---

## Database Schema

ดูเพิ่มเติม: [[Database Schema]]
