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

## 📦 S4: Frontend (Vite + shadcn-admin) (3-4 วัน)

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
- [x] **T56** 🟡 `/customers/$customerId` — detail page (route + customer detail component) ✅
- [ ] **T57** 🟢 Export CSV ⬜
- [x] **T58** 🟢 Dark mode toggle (built-in shadcn)
- [x] **T59** 🟡 Sidebar cleanup — เหลือแค่ Dashboard, Customers, Change Password ✅
- [x] **T60** 🔴 Change Password page `/change-password` — form + validation + API connect ✅
- [x] **T61** 🟡 Error page 500 fix — beforeLoad try/catch + QueryCache handler ✅

### ✅ Done Criteria
- [x] `/register` → submit → DB → success page ✅
- [x] `/login` → JWT → redirect to dashboard ✅
- [x] `/dashboard` → เห็นรายชื่อลูกค้า ✅
- [x] Search + pagination ใช้งานได้ ✅
- [x] `/change-password` → change password via API ✅
- [x] Auth guard ไม่ error 500 route root ✅

---

## 📦 S5: Connect Components (1 วัน)

> Dependencies: S2 ✅, S4 ✅

- [x] **T59** 🔴 เชื่อมต่อ Form Register → `POST /api/customers` ✅
- [x] **T60** 🔴 เชื่อมต่อ Dashboard → `GET /api/customers` (Bearer) ✅
- [ ] **T61** 🟡 หลังสมัครสำเร็จ → Line Push API ส่งข้อความ "สมัครสำเร็จ 🎉" พร้อม customer code ⬜
- [ ] **T62** 🟢 Log Line events ลง DB สำหรับ debug ⬜

---

## 📦 S8: Backend Expansion (post-deploy)

> APIs เพิ่มเติมหลังจาก Phase 1 เสร็จ

### Auth Expansion
- [x] **T80** 🔴 `UserProfile` model + `GET/PUT /user-profile/me` (auto-create) ✅
- [x] **T81** 🔴 `POST /auth/change-password` — เปลี่ยนรหัสผ่านด้วย JWT ✅
- [x] **T82** 🟡 Swagger: `@ApiBearerAuth('access-token')` — fix decorator scheme name ทุก endpoint ✅
### Customer Code
- [ ] **T83** 🔴 Prisma: เพิ่ม field `code` ใน Customer model + migration
- [ ] **T84** 🔴 `CustomerService.generateCustomerCode()` — `NC` + zero-pad 5 digit
- [ ] **T85** 🔴 เรียก `generateCustomerCode()` ตอน `createCustomer()`
- [ ] **T86** 🟢 LINE push welcome message with customer code
- [ ] **T87** 🟢 Frontend success page — แสดง customer code

### Customer Referral
- [ ] **T88** 🔴 `case 'referral'` ใน `LineService.handlePostback()` — สร้าง referral link
- [ ] **T89** 🔴 `CustomerService.getReferralLink()` — gen link `?referrerId={customer.id}`
- [ ] **T90** 🔴 Reply LINE พร้อม referral link + invite text
- [ ] **T91** 🔴 เพิ่มปุ่ม "🎯 แนะนำเพื่อน" ใน Rich Menu
- [ ] **T92** 🟡 Frontend: แสดง "แนะนำโดย" เมื่อมี `referrerId` ใน URL
- [ ] **T93** 🟡 Binary Tree Auto-Placement Algorithm
- [ ] **T94** 🟡 Commission Calculation เมื่อ order → paid
- [ ] **T95** 🟢 API: `GET /api/customers/me/referrals` — ดูคนที่ชวนมา

### Documentation
- [x] **T96** 🟡 `api-reference.md` — อัปเดตเพิ่ม user-profile + change-password ✅
- [x] **T97** 🟡 `AGENTS.md` — เพิ่ม Swagger security section + updated endpoint table ✅
- [x] **T98** 🟡 `api-reference.md` — อัปเดต change-password error code 401 → 400 ✅
- [x] **T99** 🟡 `AGENTS.md` — เพิ่ม RULE: ทุก API update ต้อง update Swagger ให้ตรง ✅

### ✅ Done Criteria
- [x] user-profile API ใช้ได้ (tested via curl) ✅
- [x] change-password API ใช้ได้ (build + deploy) ✅
- [x] change-password error code 400 (Bad Request) แทน 401 ✅
- [x] Swagger docs แสดง security scheme ถูกต้อง ✅
- [x] AGENTS.md + api-reference.md อัปเดตตรง ✅
- [x] AGENTS.md มี RULE ว่า Swagger ต้องตรงกับ API ทุกครั้ง ✅
- [ ] Customer Code auto-gen + LINE push ⬜
- [ ] Customer Referral link + invite flow ⬜

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
- [x] **T71** 🟡 Config custom domain (ถ้ามี) — ใช้ Vercel domain ไปก่อน ✅

### ✅ Done Criteria
- [x] `your-app.onrender.com/api/customers` ใช้ได้
- [x] `your-app.vercel.app/register` ใช้ได้
- [x] Line webhook → Render endpoint

---

## 📦 S7: Integration Test (1 วัน)

> Dependencies: S6 ✅ (deployed)

### S7.1 — Flow Testing
- [x] **T72** 🔴 Line OA → rich menu → "สั่งซื้อสินค้า" → ได้ข้อความกลับ ✅
- [x] **T73** 🔴 Line OA → "สมัครสมาชิก" → ฟอร์ม → submit → DB → success ✅
- [x] **T74** 🔴 Dashboard login → เห็นรายชื่อลูกค้า ✅
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
🟡 P1 = 25 tasks (important — should have)
🟢 P2 = 13 tasks (enhancement — nice to have)

**รวม: 87 tasks** | S1-S6 + S8 ✅ | S7 remaining
```

ดูเพิ่มเติม: [[Phase 1 Plan]]
