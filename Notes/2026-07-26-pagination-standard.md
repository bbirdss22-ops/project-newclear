---
tags:
  - project-nuclear
  - api
  - progress
created: 2026-07-26
---

# Pagination Response Standard

> ปรับ pagination response ให้เป็นมาตรฐานตาม RESTful API best practices

## การเปลี่ยนแปลง

| หัวข้อ | ก่อน | หลัง |
|--------|------|------|
| query param | `limit` | `pageSize` (ยังรับ `limit` ได้ backward compat) |
| response | `{ data, total, page, limit }` | `{ data, page, pageSize, totalItems, totalPages, _links: { self, next, prev } }` |
| sort order | ❌ ไม่มี | ✅ `createdAt DESC` เสมอ |
| interface | ❌ hardcoded | ✅ `PaginatedResponse<T>` reusable |

## ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | การเปลี่ยนแปลง |
|------|---------------|
| `src/common/interfaces/pagination.interface.ts` | ✨ สร้างใหม่ — `PaginatedResponse<T>` + `buildPaginationLinks()` |
| `src/customer/dto/query-customer.dto.ts` | 🔧 เพิ่ม `pageSize` + `limit` backward compat |
| `src/customer/customer.service.ts` | 🔧 ปรับ response format |
| `src/customer/customer.controller.ts` | 🔧 เพิ่ม Swagger decorators สำหรับ pageSize/limit |

## ตัวอย่าง Response

```json
GET /api/customers?page=1&pageSize=20
{
  "data": [...],
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
