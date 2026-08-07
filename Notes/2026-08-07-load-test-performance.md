---
tags:
  - project-newclear
  - performance
  - load-test
  - api
created: 2026-08-07
---

# Load Test — Customer API (List + Detail) 📊

> เทสบน production: https://project-nuclear-api.onrender.com | 2026-08-07
> ใช้ script `loadtest_nuclear.js` (Node.js concurrent fetcher — p50/p95/p99, error rate, req/s)

## วิธีเทส
- Login: `POST /api/auth/login` → JWT Bearer
- **List:** `GET /api/customers?page=1&pageSize=20` (totalItems = 4)
- **Detail:** `GET /api/customers/{id}` (id จริงตัวแรก)
- Concurrency 10-15, ~100-150 req/endpoint, รอ idle ~6 นาทีก่อนรอบแรก

## ผลลัพธ์

| Endpoint | รอบ | Req | Conc | p50 | p95 | p99 | Error | req/s |
|----------|------|-----|------|-------|-------|-------|-------|-------|
| list | after-idle (R1) | 100 | 10 | 188ms | 619ms | 890ms | 0% | 37.5 |
| detail | after-idle (R1) | 100 | 10 | 161ms | 749ms | 861ms | 0% | 38.5 |
| list | warm c=10 | 100 | 10 | 157ms | **813ms** | 960ms | 0% | 31.2 |
| detail | warm c=10 | 100 | 10 | 101ms | **235ms** | 254ms | 0% | 78.0 |
| list | warm c=15 | 100 | 15 | 340ms | **1290ms** | 1374ms | 0% | 28.5 |
| detail | warm c=15 | 100 | 15 | 182ms | 494ms | 679ms | 0% | 62.9 |

## ข้อค้นพบหลัก 🔍

1. **list ช้ากว่า detail ทุกรอบ** — ข้อมูลแค่ 4 รายการ แต่ p95 ยังค้าง ~800-960ms แม้ตอน warm และพังหนักขึ้นเมื่อ concurrency เพิ่ม (p95 → 1.3s)
2. **detail ปกติดี** — warm แล้ว p95 ~235ms, scale ถึง 78 req/s → ไม่ใช่ปัญหา infrastructure โดยรวม
3. **ไม่มี error 5xx เลย** (0% ทั้งหมด)
4. **Cold start:** ครั้งแรกหลัง idle ~0.78s (น่าจะเป็น Neon resume) แต่ Render instance ยังตื่นอยู่ — ไม่ใช่ตัวปัญหาหลัก

## สรุป Bottleneck 🎯

**อยู่ที่ query ของ `GET /api/customers` เอง** — น่าจะเป็น count query + pagination + การคำนวณ `placementUpline`/`treePath` หรือ N+1 — **ไม่ใช่ Render หรือ Neon**

→ การอัปเกรด infra ตอนนี้**ไม่คุ้ม** — แก้ query ก่อนได้ผลชัวร์กว่า

## แนวทางแก้ (ลำดับแนะนำ)

1. ดู query ใน `customer.service.ts` (list) — แยกวัด count query vs treePath computation
2. เช็ค index บน `code` / `status` / `registeredAt`
3. กำจัด N+1 / recursive scan

## ⚠️ หมายเหตุเพิ่มเติม
- `admin1/admin123` **login ไม่ได้แล้ว** (401 — โดนลบ/เปลี่ยนใน DB) — เหลือ admin3/4/5 (password `admin123`) — ควรตรวจบัญชี admin
- script `loadtest_nuclear.js` เก็บไว้ reuse ได้

## ไฟล์ที่เกี่ยวข้อง
- [[2026-07-26-api-test-cases]] — test cases API (เดิม)
- [[qa-nuclear]] — QA sub-agent workflow
