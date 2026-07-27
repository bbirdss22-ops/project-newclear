---
tags:
  - project-nuclear
  - progress
  - s2
  - qa
created: 2026-07-26
---

# S2.3 — Customer Module (CRUD) + QA Test Results ✅

> วันที่ 2026-07-26 — Sub-agent `kimi-k2.7-code` ทำงาน + QA agent เทส API ครบ

## S2.3 Customer Module (T18-T24)

| Task | Endpoint | Auth | สถานะ |
|------|----------|------|--------|
| T18 | CustomerModule + CustomerController | — | ✅ |
| T19 | `POST /api/customers` | ❌ Public | ✅ |
| T20 | `GET /api/customers` (paginated) | ✅ JWT | ✅ |
| T21 | `GET /api/customers/search?q=xxx` | ✅ JWT | ✅ |
| T22 | `GET /api/customers/:id` | ✅ JWT | ✅ |
| T23 | `GET /api/customers/line/:lineUserId` | ✅ JWT | ✅ |
| T24 | `PATCH /api/customers/:id` | ✅ JWT | ✅ |

### ไฟล์ที่สร้าง (7 files)

| ไฟล์ | คำอธิบาย |
|------|----------|
| `src/customer/customer.module.ts` | Module definition |
| `src/customer/customer.controller.ts` | 6 endpoints |
| `src/customer/customer.service.ts` | Business logic |
| `src/customer/dto/create-customer.dto.ts` | Create DTO |
| `src/customer/dto/update-customer.dto.ts` | Update DTO (partial) |
| `src/customer/dto/query-customer.dto.ts` | Query DTO (page, limit, q) |
| `src/app.module.ts` | แก้ไข — เพิ่ม CustomerModule |

## QA Test Results

เทสโดย sub-agent `se-nuclear-qa` → **16/17 PASS ✅** (1 skip)

ดูรายละเอียด: [[2026-07-26-api-test-cases]]
ดู QA workflow: [[qa-nuclear]]

### Issues ที่เจอ

1. **Empty body `{}` สร้าง customer ได้** — ไม่มี field-level validation
2. **phone/email ไม่ unique** — เฉพาะ `lineUserId` เท่านั้นที่ unique
3. **Login returns 200** — ควรเป็น 201 (cosmetic)

## สถานะรวม

| Step | Status |
|------|--------|
| **S2.1** NestJS Backend Init | ✅ Health endpoint + Deploy Render |
| **S2.2** Auth Module | ✅ JWT Login + Guards + Roles |
| **S2.3** Customer CRUD | ✅ 6 endpoints + QA test 16/17 PASS |
| **S2.4** Line Webhook | ⏳ รอเริ่ม |
