---
tags:
  - project-nuclear
  - progress
  - s2
created: 2026-07-26
---

# S2.3 — Customer Module (CRUD) ✅

> Customer CRUD เสร็จสมบูรณ์ — Public create + Protected list/search/detail/update

## สรุป

| รายการ | สถานะ |
|--------|--------|
| `CustomerModule` | ✅ |
| `POST /api/customers` (public) | ✅ |
| `GET /api/customers` (paginated, protected) | ✅ |
| `GET /api/customers/search?q=` (protected) | ✅ |
| `GET /api/customers/:id` (protected) | ✅ |
| `GET /api/customers/line/:lineUserId` (protected) | ✅ |
| `PATCH /api/customers/:id` (protected) | ✅ |
| class-validator DTOs (create, update, query) | ✅ |
| Build + push + deploy Render | ✅ |

## ไฟล์ที่สร้าง

| ไฟล์ | คำอธิบาย |
|------|----------|
| `src/customer/customer.module.ts` | Module |
| `src/customer/customer.controller.ts` | Controller (6 endpoints) |
| `src/customer/customer.service.ts` | Business logic |
| `src/customer/dto/create-customer.dto.ts` | Create DTO |
| `src/customer/dto/update-customer.dto.ts` | Update DTO (partial) |
| `src/customer/dto/query-customer.dto.ts` | Query DTO (page, limit, q) |
| `src/app.module.ts` | แก้ไข import CustomerModule |

## API Test

```bash
# Create customer (public)
curl -X POST https://project-nuclear-api.onrender.com/api/customers \
  -H "Content-Type: application/json" \
  -d '{"firstName":"ทดสอบ","lastName":"ระบบ","phone":"0812345678","email":"test@example.com"}'
# → 201 ✅
```

## Implementation Details

- **Public POST**: No auth guard, validates lineUserId uniqueness, validates referrerId existence
- **Protected routes**: JwtAuthGuard + RolesGuard (`@Roles('admin', 'superadmin')`)
- **Validation**: class-validator decorators (UUID, max length, email)
- **DisplayName**: auto-build จาก firstName + lastName
- **Search**: case-insensitive on firstName, lastName, phone, email, displayName
- **Pagination**: `{ data, total, page, limit }` format

## ถัดไป

- [[Phase 1 Tasks#📦 S2 NestJS Backend 3-4 วัน|S2.4 — Line Module (Webhook)]]
