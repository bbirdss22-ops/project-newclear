---
tags:
  - project-newclear
  - tasks
  - phase-1
created: 2026-07-21
---

# Phase 1 — Task Breakdown

> รวมทั้งหมด **37 tasks** | ประมาณ **12-14 วัน** (ทำขนานได้)

## Labels

| Label | ความหมาย |
|-------|----------|
| 🔴 **P0** | Must have — ถ้าไม่มีโปรเจคไม่เกิด |
| 🟡 **P1** | Should have — critical path |
| 🟢 **P2** | Nice to have — ทำทีหลังก็ได้ |

---

## 📦 S1: Foundation & Database (1 วัน)

> Dependencies: —

### S1.1 — Neon Setup
- [x] **T1** 🔴 สมัคร [Neon](https://neon.tech) account
- [x] **T2** 🔴 สร้าง Neon project → จด connection string

### S1.2 — Database Schema
- [x] **T3** 🔴 เขียน DDL: `users` table (id, username, password, role)
- [x] **T4** 🔴 เขียน DDL: `customers` table (รวม MLM fields)
- [x] **T5** 🟡 เขียน DDL: `line_events` table
- [x] **T6** 🟡 เขียน indexes (line_user_id, referrer_id, tree_path)
- [x] **T7** 🔴 Run migrations ผ่าน Neon console หรือ psql
- [x] **T8** 🟢 Seed ข้อมูล: admin user 5 คน + dummy customers 2-3 คน (สำหรับ dev)

### ✅ Done Criteria
- [x] psql เชื่อมต่อ Neon สำเร็จ
- [x] `\dt` เห็น 3 tables
- [x] INSERT/SELECT ทดสอบผ่าน

---

## 📦 S2: NestJS Backend (3-4 วัน)

> Dependencies: S1 ✅ (ต้องมี DB ก่อน)

### S2.1 — Project Init
- [x] **T9** 🔴 `nest new project-newclear-api`
- [x] **T10** 🟡 ติดตั้ง `@nestjs/config` — env variables (.env)
- [x] **T11** 🔴 ติดตั้ง Prisma ORM + `npx prisma init`
- [x] **T12** 🔴 เขียน Prisma schema (users, customers, line_events)
- [x] **T13** 🔴 `npx prisma generate` + `npx prisma db push`

### S2.2 — Auth Module
- [x] **T14** 🔴 `AuthModule` + `AuthController` → `/api/auth/login`
- [x] **T15** 🔴 `AuthService` — validate credentials + return JWT
- [x] **T16** 🔴 `JwtAuthGuard` — protect protected routes
- [x] **T17** 🟡 `RolesGuard` — เผื่อมี role ต่างกัน

### S2.3 — Customer Module
- [x] **T18** 🔴 `CustomerModule` + `CustomerController` → `/api/customers`
- [x] **T19** 🔴 `POST /api/customers` — create customer (public)
- [x] **T20** 🔴 `GET /api/customers` — list customers (protected, paginated)
  - [x] **R1** 🟡 ปรับ pagination response เป็น standard: `{ data, page, pageSize, totalItems, totalPages, _links }`
  - [x] **R2** 🟡 เปลี่ยน query `limit` → `pageSize` (backward compat รองรับ limit ด้วย)
  - [x] **R3** 🟡 สร้าง `PaginatedResponse<T>` interface ใน `common/interfaces/`
- [x] **T21** 🟡 `GET /api/customers/search?q=xxx` — search (ชื่อ/เบอร์/email)
  - [x] **R4** 🟡 ใช้ pagination format เดียวกันกับ T20
- [x] **T22** 🟡 `GET /api/customers/:id` — customer detail
- [x] **T23** 🟡 `GET /api/customers/line/:lineUserId` — find by Line userId
- [x] **T24** 🟢 `PATCH /api/customers/:id` — update customer info


### S2.4 — Line Module ✅
- [x] **T25** 🔴 ติดตั้ง `@line/bot-sdk`
- [x] **T26** 🔴 `LineModule` + webhook endpoint `POST /api/line/webhook`
- [x] **T27** 🔴 verify Line signature middleware
- [x] **T28** 🔴 Handle `postback` event — สั่งซื้อสินค้า → reply message
- [x] **T29** 🟡 Handle `follow` event — welcome message เมื่อ add friend
- [x] **T30** 🟡 `LineService.pushMessage` — push message กลับหา user

### ✅ Done Criteria
- [x] `nest start:dev` รันติด
- [x] `POST /api/auth/login` → ได้ JWT token กลับ
- [x] `GET /api/customers` (มี token) → ข้อมูลกลับมา
- [x] `POST /api/customers` → insert DB สำเร็จ
- [x] `POST /api/line/webhook` → verify signature + reply postback

---

## 📦 S3: Line OA + Rich Menu (1 วัน)

> Dependencies: S2.4 ✅ (webhook endpoint พร้อม)

### S3.1 — Line OA Setup ✅
- [x] **T31** 🔴 สร้าง Line OA ที่ [LINE Developers Console](https://developers.line.biz)
- [x] **T32** 🔴 จด Channel ID, Channel Secret, Channel Access Token

### S3.2 — Rich Menu ✅
- [x] **T33** 🔴 ออกแบบ Rich Menu image (2500x1686 px) — ใช้ Canva/Figma
- [x] **T34** 🔴 สร้าง Rich Menu JSON + upload ผ่าน API
- [x] **T35** 🔴 Upload rich menu image → get richMenuId
- [x] **T36** 🔴 Set default rich menu `POST /v2/bot/user/all/richmenu/{richMenuId}`
- [x] **T37** 🟡 Config webhook URL → `https://your-app.onrender.com/api/line/webhook`

### ✅ Done Criteria
- [x] แอด Line OA แล้วเห็น Rich Menu
- [x] กด "สั่งซื้อสินค้า" → ข้อความกลับมา
- [x] กด "สมัครสมาชิก" → เปิด URL ไปฟอร์ม

---

## 📦 S4: Next.js Frontend (3-4 วัน)

> Dependencies: S2 ✅ (API พร้อม), S3 ✅ (Line OA พร้อม)

### S4.1 — Project Init ✅
- [x] **T38** 🔴 clone shadcn-admin template (Vite + TanStack Router + shadcn/ui) แทน Next.js
- [x] **T39** 🔴 shadcn/ui + Tailwind CSS พร้อม
- [x] **T40** 🟡 ติดตั้ง Tailwind CSS + configure ✅
- [x] **T41** 🟡 shadcn/ui theme ใช้ default (dark/light toggle)
- [x] **T42** 🔴 Setup environment variables (`VITE_API_BASE_URL`)

### S4.2 — Registration Flow ✅
- [x] **T43** 🔴 `/register` page — รับ `lineUserId` จาก query param
- [x] **T44** 🔴 Registration form — ชื่อ, นามสกุล, เบอร์, email, ที่อยู่
- [x] **T45** 🔴 Form validation (Zod + react-hook-form)
- [x] **T46** 🔴 Submit → `POST /api/customers` ✅
- [x] **T47** 🔴 `/register/success` page (inline success state)
- [x] **T48** 🟡 Loading state + error handling (toast)

### S4.3 — Auth (Dashboard Login) ✅
- [x] **T49** 🔴 `/sign-in` page — username + password form (replace Clerk mock)
- [x] **T50** 🔴 Login → `POST /api/auth/login` → เก็บ JWT + user ใน zustand store
- [x] **T51** 🔴 Auth middleware — `beforeLoad` guard redirect → `/sign-in` ถ้าไม่มี token
- [x] **T52** 🟡 Auto-redirect ถ้า token หมดอายุ (401 interceptor)

### S4.4 — Dashboard (Partial ✅)
- [x] **T53** 🔴 `/customers` — table รายชื่อลูกค้า (data table + API connect)
- [x] **T54** 🟡 Search bar — filter ตามชื่อ/เบอร์/email
- [x] **T55** 🟡 Pagination (20 รายการ/หน้า)
- [ ] **T56** 🟡 `/dashboard/[id]` — detail page (Badge, Modal, Card) ⬜
- [ ] **T57** 🟢 Export CSV ⬜
- [x] **T58** 🟢 Dark mode toggle (built-in shadcn)

### ✅ Done Criteria
- [x] `/register` → submit → DB → success page ✅
- [x] `/login` → JWT → redirect to dashboard ✅
- [x] `/dashboard` → เห็นรายชื่อลูกค้า ✅
- [x] Search + pagination ใช้งานได้ ✅

---

## 📦 S5: Connect Components (1 วัน)

> Dependencies: S2 ✅, S4 ✅

- [x] **T59** 🔴 เชื่อมต่อ Form Register → `POST /api/customers` ✅
- [x] **T60** 🔴 เชื่อมต่อ Dashboard → `GET /api/customers` (Bearer) ✅
- [ ] **T61** 🟡 หลังสมัครสำเร็จ → Line Push API ส่งข้อความ "สมัครสำเร็จ 🎉" ⬜
- [ ] **T62** 🟢 Log Line events ลง DB สำหรับ debug ⬜

### ✅ Done Criteria
- [x] ทุกหน้าเชื่อม API ครบ (register + login + dashboard) ✅
- [ ] Line push ทำงานเมื่อสมัครเสร็จ ⬜

---

## 📦 S6: Deploy (1 วัน)

> Dependencies: S5 ✅

### S6.1 — Render (NestJS) ✅
- [x] **T63** 🔴 Push NestJS code ขึ้น GitHub ✅
- [x] **T64** 🔴 Connect repo → Render → New Web Service ✅
- [x] **T65** 🔴 ENV: `DATABASE_URL`, `LINE_CHANNEL_SECRET`, `LINE_ACCESS_TOKEN`, `JWT_SECRET` ✅
- [x] **T66** 🔴 Build: `npm install && npm run build` ✅
- [x] **T67** 🔴 Start: `npm run start:prod` ✅

### S6.2 — Vercel (Vite/React Frontend) ✅
- [x] **T68** 🔴 Push frontend code ขึ้น GitHub ✅
- [x] **T69** 🔴 Connect repo → Vercel → Import ✅
- [x] **T70** 🔴 ENV: `VITE_API_BASE_URL=https://project-nuclear-api.onrender.com` ✅
- [ ] **T71** 🟡 Config custom domain (ถ้ามี) ⬜

### ✅ Done Criteria
- [ ] `your-app.onrender.com/api/customers` ใช้ได้
- [ ] `your-app.vercel.app/register` ใช้ได้
- [ ] Line webhook → Render endpoint

---

## 📦 S7: Integration Test (1 วัน)

> Dependencies: S6 ✅ (deployed)

### S7.1 — Flow Testing
- [ ] **T72** 🔴 Line OA → rich menu → "สั่งซื้อสินค้า" → ได้ข้อความกลับ
- [ ] **T73** 🔴 Line OA → "สมัครสมาชิก" → ฟอร์ม → submit → DB → success
- [ ] **T74** 🔴 Dashboard login → เห็นรายชื่อลูกค้า
- [ ] **T75** 🔴 คลิกดู detail → ข้อมูลถูกต้อง

### S7.2 — Edge Cases
- [ ] **T76** 🟢 Register: field ว่าง → validation error
- [ ] **T77** 🟢 Register: ซ้ำ (lineUserId เดิม) → error handling
- [ ] **T78** 🟢 Dashboard: ไม่มี token → redirect login
- [ ] **T79** 🟢 Dashboard: token หมดอายุ → auto-redirect

### ✅ Done Criteria
- [ ] All 3 core flows (Order / Register / Dashboard) ✅
- [ ] Edge cases handled ไม่ Error 500

---

## 📊 Timeline

```
Week 1                    |  Week 2
Mon  Tue  Wed  Thu  Fri   |  Mon  Tue  Wed  Thu  Fri
─────┬─────┬─────┬─────┬──┼──┬─────┬─────┬─────┬─────
 S1  │  S2              │  │  S4              │ S5  S6  S7
     │                   │  │                   │
 S3  │                   │  │                   │
```

| Sprint | Tasks | ระยะเวลา |
|--------|-------|----------|
| **S1** Foundation | T1-T8 | 1 วัน |
| **S2** Backend | T9-T30 | 3-4 วัน |
| **S3** Line OA | T31-T37 | 1 วัน (ขนาน S2) |
| **S4** Frontend | T38-T58 | 3-4 วัน |
| **S5** Connect | T59-T62 | 1 วัน |
| **S6** Deploy | T63-T71 | 1 วัน |
| **S7** Test | T72-T79 | 1 วัน |
| **รวม** | **T1-T79** | **~12 วัน** |

## Quick Reference

```
🔴 P0 = 47 tasks (core — must have)
🟡 P1 = 21 tasks (important — should have)
🟢 P2 = 11 tasks (enhancement — nice to have)
```

ดูเพิ่มเติม: [[Phase 1 Plan]]
