---
tags:
  - project-nuclear
  - qa
  - workflow
  - sub-agent
created: 2026-07-26
---

# QA-Nuclear Sub-Agent

> QA agent สำหรับทดสอบ API endpoints ของ Project Nuclear

## Model

```
model: kimi-k2.7-code
```

## วิธี Spawn

```json
{
  "taskName": "se-nuclear-qa",
  "model": "kimi-k2.7-code",
  "task": "คุณคือ QA Agent สำหรับ Project Nuclear API...",
  "mode": "run",
  "sandbox": "inherit"
}
```

## Template Task Prompt

```
คุณคือ QA Agent สำหรับ Project Nuclear API

## ภารกิจ: ทดสอบ API Endpoints + สร้าง Test Case List

API Base URL: https://project-nuclear-api.onrender.com

### API Endpoints ที่ต้อง Test
{list endpoints}

### คำสั่ง
1. ทดสอบ curl จริง ๆ ไปที่ API base URL
2. บันทึกผลว่า PASS/FAIL แต่ละ endpoint
3. สร้างไฟล์ test case list ที่ Notes/YYYY-MM-DD-api-test-cases.md
4. สรุปผลการเทส

### Accounts สำหรับ Test
- admin1 / admin123 (superadmin)
```

## Test Results — 2026-07-26

ดูเพิ่มเติม: [[2026-07-26-api-test-cases]]

### Summary

| Total | Pass | Fail | Skip |
|-------|------|------|------|
| 17    | 16   | 0    | 1    |

| # | Endpoint | Result |
|---|----------|--------|
| TC-01 | `GET /api/health` | ✅ PASS |
| TC-02 | `POST /api/auth/login` (valid) | ✅ PASS |
| TC-03 | `POST /api/auth/login` (invalid) | ✅ PASS |
| TC-04 | `POST /api/auth/login` (missing fields) | ✅ PASS |
| TC-05 | `POST /api/customers` (create) | ✅ PASS |
| TC-06 | `POST /api/customers` (duplicate lineUserId) | ✅ PASS |
| TC-07 | `POST /api/customers` (malformed JSON) | ✅ PASS |
| TC-08 | `GET /api/customers` (paginated) | ✅ PASS |
| TC-09 | `GET /api/customers/search` | ✅ PASS |
| TC-10 | `GET /api/customers/:id` (found) | ✅ PASS |
| TC-11 | `GET /api/customers/:id` (not found) | ✅ PASS |
| TC-12 | `GET /api/customers/line/:lineUserId` (found) | ✅ PASS |
| TC-12b | `GET /api/customers/line/:lineUserId` (not found) | ✅ PASS |
| TC-13 | `PATCH /api/customers/:id` | ✅ PASS |
| TC-14 | No token → 401 | ✅ PASS |
| TC-15 | Wrong role | ⏭️ SKIP |

### Issues Found

1. **No field-level validation** — `{}` (empty body) creates a customer record with all-null fields (returns 201)
2. **No unique constraint** on `phone` or `email` — เฉพาะ `lineUserId` เท่านั้นที่ unique
3. **Login returns 200** — ควรเป็น 201 (cosmetic issue)
