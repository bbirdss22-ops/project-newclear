---
tags:
  - project-nuclear
  - api
  - documentation
created: 2026-07-26
updated: 2026-07-29
---

# API Reference — Project Nuclear

> ⚠️ **ต้องอัปเดตทุกครั้งที่มีการแก้ไขหรือเพิ่ม API** — ถ้าเห็น doc นี้ไม่ตรงกับโค้ด ให้แจ้งจาวิส

> **Base URL:** `https://project-nuclear-api.onrender.com`
> **Swagger UI:** `https://project-nuclear-api.onrender.com/api/docs`
> **API Prefix:** ทุก endpoint อยู่ภายใต้ `/api`

---

## General

### CORS
เปิดทั้งหมด (`app.enableCors()`) — frontend จาก Vercel หรือ local dev เข้าถึงได้

### Validation
ValidationPipe เปิด `whitelist: true`, `forbidNonWhitelisted: true`, `transform: true`
- Field ไม่ได้ประกาศใน DTO → **ถูก strip ทิ้ง**
- Field ที่ไม่รู้จักใน DTO → **400 Bad Request**
- Type transform อัตโนมัติ (string → number, etc.)

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

## Authentication

ส่วนใหญ่ endpoint ใช้ JWT Bearer token

```
Authorization: Bearer <access_token>
```

### Login

```
POST /api/auth/login
Content-Type: application/json
```

**Auth:** ❌ ไม่ต้อง

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `username` | string | ✅ | ชื่อผู้ใช้ |
| `password` | string | ✅ | รหัสผ่าน |

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

### Seed Accounts

| Username | Password | Role |
|----------|----------|------|
| `admin1` | `admin123` | `superadmin` |
| `admin2` — `admin5` | `admin123` | `admin` |

---

### Validate Registration Token

```
GET /api/auth/registration-token/:token
```

**Auth:** ❌ ไม่ต้อง

**Path Parameters:**
| Field | Type | Description |
|-------|------|-------------|
| `token` | string | UUID token ที่ได้จาก LINE postback action=register |

**Response 200 (token valid):**
```json
{
  "valid": true,
  "lineUserId": "Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "alreadyRegistered": false
}
```

**Response 200 (token valid แต่มี customer อยู่แล้ว):**
```json
{
  "valid": true,
  "lineUserId": "Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "alreadyRegistered": true
}
```

**Response 404 (token invalid หรือ expired):**
```json
{
  "message": "Invalid or expired registration token",
  "statusCode": 404
}
```

---

### Consume Registration Token

```
POST /api/auth/registration-token/:token/consume
Content-Type: application/json
```

**Auth:** ❌ ไม่ต้อง

**Path Parameters:**
| Field | Type | Description |
|-------|------|-------------|
| `token` | string | UUID token |

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `customerId` | string | ✅ | UUID ของ customer ที่สร้างเสร็จ |

**Response 200:**
```json
{
  "message": "Token consumed successfully"
}
```

**Response 404:**
```json
{
  "message": "Registration token not found",
  "statusCode": 404
}
```

---

### Change Password (Protected)

```
POST /api/auth/change-password
Content-Type: application/json
Authorization: Bearer <access_token>
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `currentPassword` | string | ✅ | รหัสผ่านปัจจุบัน |
| `newPassword` | string | ✅ | รหัสผ่านใหม่ (อย่างน้อย 6 ตัว) |

**Response 200:**
```json
{
  "message": "Password changed successfully"
}
```

**Response 400 (รหัสผ่านปัจจุบันผิด):**
```json
{
  "message": "Current password is incorrect",
  "error": "Bad Request",
  "statusCode": 400
}
```

**Response 400 (newPassword สั้นเกิน):**
```json
{
  "message": ["newPassword must be longer than or equal to 6 characters"],
  "error": "Bad Request",
  "statusCode": 400
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
| `firstName` | string | ✅ | ชื่อจริง (max 100 chars) |
| `lastName` | string | ✅ | นามสกุล (max 100 chars) |
| `phone` | string | ✅ | เบอร์โทร (max 20 chars) |
| `email` | string | ❌ | อีเมล (ต้องมี @ ถ้าให้, max 255 chars) |
| `address` | string | ❌ | ที่อยู่ |
| `bankName` | string | ❌ | รหัสธนาคาร (KBANK, KTB, BBL, SCB, BAY, TTB, GSB, BAAC, OTHER) — สำหรับรับค่าคอมมิชชั่น |
| `bankAccountName` | string | ❌ | ชื่อบัญชี (max 100 chars) |
| `bankAccountNumber` | string | ❌ | เลขบัญชี — ตัวเลข 9-13 หลัก (regex `/^[0-9]{9,13}$/`) |
| `lineUserId` | string | ❌ | Line User ID (unique) |
| `referrerId` | string | ❌ | UUID ของคนชวน (ถ้ามี) |

> **Behavior:** ถ้า `lineUserId` ตรงกับ stub customer (มีอยู่แล้วแต่ยังไม่มี firstName) → **update record เดิม**แทนที่จะสร้างใหม่

**Note on referrerId:** ถ้าให้ `referrerId` ที่ไม่มีในระบบ → **400 Bad Request**

**Response 201:**
```json
{
  "id": "uuid",
  "code": "NC00001",
  "lineUserId": null,
  "displayName": "สมชาย ใจดี",
  "firstName": "สมชาย",
  "lastName": "ใจดี",
  "phone": "0812345678",
  "email": "somchai@test.com",
  "address": null,
  "bankName": null,
  "bankAccountName": null,
  "bankAccountNumber": null,
  "referrerId": null,
  "status": "active",
  "registeredAt": "2026-07-26T10:00:00.000Z",
  "updatedAt": "2026-07-26T10:00:00.000Z"
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

**Response 400 (referrerId ไม่มีในระบบ):**
```json
{
  "message": "Referrer with id \"uuid\" not found",
  "error": "Bad Request",
  "statusCode": 400
}
```

**Response 409 (duplicate lineUserId — already fully registered):**
```json
{
  "message": "Customer with lineUserId \"Uxxxxxxxxxxxx\" already exists",
  "statusCode": 409
}
```

> **Auto-push LINE:** ถ้า customer มี `lineUserId` และ `code` → push ข้อความต้อนรับ + customer code ผ่าน LINE โดยอัตโนมัติ

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
| `limit` | number | 20 | **[Deprecated]** — ยังใช้ได้แต่แนะนำ `pageSize` |

> Priority: `pageSize` > `limit` > default 20

**Response 200:**
```json
{
  "data": [
    {
      "id": "uuid",
      "code": "NC00001",
      "lineUserId": null,
      "displayName": "สมชาย ใจดี",
      "firstName": "สมชาย",
      "lastName": "ใจดี",
      "phone": "0812345678",
      "email": "somchai@test.com",
      "address": null,
      "bankName": null,
      "bankAccountName": null,
      "bankAccountNumber": null,
      "referrerId": null,
      "status": "active",
      "registeredAt": "2026-07-26T10:00:00.000Z",
      "updatedAt": "2026-07-26T10:00:00.000Z"
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
GET /api/customers/search?q=สมชาย&page=1&pageSize=20
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Query Parameters:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `q` | string | "" | คำค้นหา (firstName, lastName, phone, email, displayName) |
| `page` | number | 1 | |
| `pageSize` | number | 20 | จำนวนต่อหน้า |
| `limit` | number | 20 | **[Deprecated]** |

> Search เป็น case-insensitive ใช้ `mode: 'insensitive'` ของ Prisma

**Response 200:** (รูปแบบเดียวกับ List Customers)
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

**Path Parameters:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | UUID ของ customer |

**Response 200:**
```json
{
  "id": "uuid",
  "code": "NC00001",
  "lineUserId": null,
  "displayName": "สมชาย ใจดี",
  "firstName": "สมชาย",
  "lastName": "ใจดี",
  "phone": "0812345678",
  "email": "somchai@test.com",
  "address": null,
  "bankName": null,
  "bankAccountName": null,
  "bankAccountNumber": null,
  "referrerId": null,
  "status": "active",
  "registeredAt": "2026-07-26T10:00:00.000Z",
  "updatedAt": "2026-07-26T10:00:00.000Z"
}
```

**Response 404:**
```json
{
  "message": "Customer with id \"uuid\" not found",
  "statusCode": 404
}
```

---

### Get Customer by Line User ID (Protected)

```
GET /api/customers/line/:lineUserId
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Path Parameters:**
| Field | Type | Description |
|-------|------|-------------|
| `lineUserId` | string | Line User ID |

**Response 200:** (schema เดียวกับ Get by ID)

**Response 404:**
```json
{
  "message": "Customer with lineUserId \"Uxxxx\" not found",
  "statusCode": 404
}
```

---

### Update Customer (Protected)

```
PATCH /api/customers/:id
Content-Type: application/json
Authorization: Bearer <access_token>
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Path Parameters:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | UUID ของ customer |

**Request Body:** (partial — ส่งเฉพาะ field ที่ต้องการแก้)
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `firstName` | string | ❌ | |
| `lastName` | string | ❌ | |
| `phone` | string | ❌ | |
| `email` | string | ❌ | |
| `address` | string | ❌ | |
| `bankName` | string | ❌ | รหัสธนาคาร (KBANK, ...) |
| `bankAccountName` | string | ❌ | ชื่อบัญชี |
| `bankAccountNumber` | string | ❌ | เลขบัญชี — ตัวเลข 9-13 หลัก |
| `lineUserId` | string | ❌ | เช็ค unique ถ้าเปลี่ยน |
| `referrerId` | string | ❌ | UUID ของ referrer (ใหม่) — validate existence |

> `displayName` จะ rebuild อัตโนมัติเมื่อ firstName หรือ lastName เปลี่ยน

**Response 200:**
```json
{
  "id": "uuid",
  "phone": "0898765432",
  "email": "newemail@test.com",
  "updatedAt": "2026-07-26T12:00:00.000Z"
}
```

**Response 404:**
```json
{
  "message": "Customer with id \"uuid\" not found",
  "statusCode": 404
}
```

**Response 409 (lineUserId conflict):**
```json
{
  "message": "Customer with lineUserId \"Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\" already exists",
  "statusCode": 409
}
```

**Response 400 (referrerId not found):**
```json
{
  "message": "Referrer with id \"uuid\" not found",
  "error": "Bad Request",
  "statusCode": 400
}
```

---

## User Profile

### Get Current User Profile (Protected)

```
GET /api/user-profile/me
Authorization: Bearer <access_token>
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

> **Auto-create:** ถ้ายังไม่มี profile → สร้าง auto (object เปล่า) แล้ว return

**Response 200:**
```json
{
  "id": "uuid",
  "userId": "uuid",
  "displayName": "Admin One",
  "email": "admin1@project-nuclear.com",
  "phone": "081-234-5678",
  "avatarUrl": null,
  "bio": null,
  "createdAt": "2026-07-27T10:00:00.000Z",
  "updatedAt": "2026-07-27T10:00:00.000Z"
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

### Update Current User Profile (Protected)

```
PUT /api/user-profile/me
Content-Type: application/json
Authorization: Bearer <access_token>
```

**Auth:** ✅ JWT Bearer token (admin/superadmin)

**Request Body:** (partial — ส่งเฉพาะ field ที่ต้องการแก้)
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `displayName` | string | ❌ | ชื่อที่แสดง (max 100 chars) |
| `email` | string | ❌ | อีเมล (ต้องมี @ ถ้าให้) |
| `phone` | string | ❌ | เบอร์โทร (max 20 chars) |
| `avatarUrl` | string | ❌ | URL รูปโปรไฟล์ |
| `bio` | string | ❌ | คำอธิบายสั้นๆ |

> **หมายเหตุ:** ใช้ `PUT` (ไม่ใช่ `PATCH`) แต่ทำงานแบบ partial update

**Response 200:**
```json
{
  "id": "uuid",
  "userId": "uuid",
  "displayName": "Admin One Updated",
  "email": "admin1@project-nuclear.com",
  "phone": "081-234-5678",
  "avatarUrl": "https://example.com/avatar.jpg",
  "bio": "Senior admin of Project Nuclear",
  "createdAt": "2026-07-27T10:00:00.000Z",
  "updatedAt": "2026-07-27T14:00:00.000Z"
}
```

---

## Line Webhook

### Webhook Endpoint

```
POST /api/line/webhook
```

**Auth:** ❌ Signature verification ผ่าน `LineSignatureGuard` (ใช้ `x-line-signature` header)

**Content-Type:** `text/plain` (raw JSON string — ตามที่ LINE platform ส่ง)

**Request Body:**
```json
{
  "destination": "Uxxxxxxxxxxxxxxxxxxxxxxxxx",
  "events": [
    {
      "type": "follow",
      "source": { "userId": "Uxxxxxxxxxxxxxxxxxxxxxxxxx", "type": "user" },
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

| Event | Action | การทำงาน |
|-------|--------|----------|
| `follow` | — | Log event → reply welcome message |
| `postback` | `action=register` | Log event → สร้าง registration token (5 นาที) → reply link |
| `postback` | `action=product_order_{id}` | Log event → reply ข้อความยืนยัน |
| `message` (text) | `"สวัสดี"` / `"hi"` / `"hello"` | reply คำต้อนรับ + command list |
| `message` (text) | `"สินค้า"` / `"product"` | reply ข้อความแนะนำสินค้า |
| `message` (text) | `"ติดต่อ"` / `"contact"` | reply ช่องทางติดต่อ |
| `message` (text) | `"สมัคร"` / `"register"` | reply link สมัครสมาชิก |
| อื่นๆ | — | **Silently ignored** (ไม่มีการ fallback) |

> **หมายเหตุ:**
> - ถ้า `LINE_CHANNEL_SECRET` ยังไม่ตั้งค่า → Signature verify จะข้ามไป (log warning)
> - ถ้า `LINE_ACCESS_TOKEN` ยังไม่ตั้งค่า → Push/reply message จะไม่ทำงาน
> - ทุก event จะถูก log ลง `line_events` table ใน DB

### LINE Rich Menu Postback Flow

**Register:**
```
User กด "สมัครสมาชิก" → postback data="action=register"
  → สร้าง RegistrationToken (UUID, หมดอายุ 5 นาที)
  → Reply: "📝 กรุณากดลิงก์นี้เพื่อสมัครสมาชิก (ลิงก์หมดอายุใน 5 นาที):
       https://project-nuclear-web.vercel.app/register?token={token}"
  → User เปิดลิงก์ → หน้า Register → กรอกข้อมูล → Submit
  → POST /api/customers → consume token → push welcome 🎉
```

**สั่งซื้อสินค้า:**
```
User กด "สั่งซื้อสินค้า" → postback data="action=product_order_{id}"
  → Reply: "✅ ขอบคุณที่สนใจสั่งซื้อสินค้า (รหัส: {id})
       เจ้าหน้าที่จะติดต่อกลับโดยเร็วที่สุด"
```

---

## Customer Code Generation

| Format | ตัวอย่าง | Mechanism |
|--------|----------|-----------|
| `NC` + 5-digit zero-padded | NC00001 | `count() + 1` จาก Prisma |
| Max | NC99999 | ป้องกันซ้ำ: unique constraint |

> สร้างตอน `POST /api/customers` และ push ไปที่ LINE พร้อมข้อความต้อนรับ

---

## Database Schema

ดูเพิ่มเติม: [[Database Schema]]

---

## Changelog

| Date | Changes |
|------|---------|
| 2026-07-29 | เพิ่ม `GET /api/auth/registration-token/:token` และ consume endpoint |
| 2026-07-29 | เพิ่ม `code` (NC000XX), `displayName` ใน Response |
| 2026-07-29 | อัปเดต stub customer behavior, referrerId validation |
| 2026-07-29 | LINE command router (สวัสดี, สินค้า, ติดต่อ, สมัคร) |
| 2026-07-29 | User Profile auto-create, PUT not PATCH |
| 2026-07-29 | Swagger UI URL, ValidationPipe info |
| 2026-08-02 | เพิ่ม optional bank fields (bankName, bankAccountName, bankAccountNumber) ใน create/update customer สำหรับรับค่าคอมมิชชั่น |
