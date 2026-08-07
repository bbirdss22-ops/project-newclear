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
- [x] **T43** 🔴 `/register` page — รับ `lineUserId` จาก query param ✅
- [x] **T44** 🔴 Registration form — ชื่อ, นามสกุล, เบอร์, email, ที่อยู่ ✅
- [x] **T45** 🔴 Form validation (Zod + react-hook-form) ✅
- [x] **T46** 🔴 Submit → `POST /api/customers` → Customer Code auto-gen ✅
- [x] **T47** 🔴 `/register/success` page (success state + customer code + countdown 10s auto-close) ✅
- [x] **T48** 🟡 Loading state + error handling (toast) ✅
- [x] **T100** 🟢 Social login (GitHub/Facebook) ลบออกจากหน้า sign-in ✅
- [x] **T101** 🟢 ปุ่ม "กลับหน้าหลัก" ลบออกจากหน้า success (เหลือแค่ "ปิดเลย") ✅
- [x] **T102** 🟢 Rebrand: Theme เขียวธรรมชาติ + โลโก้ตรานิวเคลียร์ + ข้อความ "เกษตรนิวเคลียร์" ทั้งระบบ ✅

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
- [x] **T61** 🟡 หลังสมัครสำเร็จ → Line Push API ส่งข้อความ "สมัครสำเร็จ 🎉" พร้อม customer code ✅
- [ ] **T62** 🟢 Log Line events ลง DB สำหรับ debug ⬜

---

## 📦 S8: Backend Expansion (post-deploy)

> APIs เพิ่มเติมหลังจาก Phase 1 เสร็จ

### Auth Expansion
- [x] **T80** 🔴 `UserProfile` model + `GET/PUT /user-profile/me` (auto-create) ✅
- [x] **T81** 🔴 `POST /auth/change-password` — เปลี่ยนรหัสผ่านด้วย JWT ✅
- [x] **T82** 🟡 Swagger: `@ApiBearerAuth('access-token')` — fix decorator scheme name ทุก endpoint ✅
### Customer Code ✅
- [x] **T83** 🔴 Prisma: เพิ่ม field `code` ใน Customer model + migration ✅
- [x] **T84** 🔴 `CustomerService.generateCustomerCode()` — `NC` + zero-pad 5 digit ✅
- [x] **T85** 🔴 เรียก `generateCustomerCode()` ตอน `createCustomer()` ✅
- [x] **T86** 🟢 LINE push welcome message with customer code ✅
- [x] **T87** 🟢 Frontend success page — แสดง customer code ✅

### Customer Referral
- [ ] **T88** 🔴 `case 'referral'` ใน `LineService.handlePostback()` — สร้าง referral link
- [ ] **T89** 🔴 `CustomerService.getReferralLink()` — gen link `?referrerId={customer.id}`
- [ ] **T90** 🔴 Reply LINE พร้อม referral link + invite text
- [ ] **T91** 🔴 เพิ่มปุ่ม "🎯 แนะนำเพื่อน" ใน Rich Menu
- [ ] **T92** 🟡 Frontend: แสดง "แนะนำโดย" เมื่อมี `referrerId` ใน URL
- [ ] **T93** 🟡 Binary Tree Auto-Placement Algorithm
- [ ] **T94** 🟡 Commission Calculation เมื่อ order → paid
- [ ] **T95** 🟢 API: `GET /api/customers/me/referrals` — ดูคนที่ชวนมา

### Bank Account Fields (Commission Payout) ✅
- [x] **T103** 🔴 Backend: เพิ่ม bank fields (`bankName`, `bankAccountName`, `bankAccountNumber`) ใน Customer model + migration + DTO (create/update) + service write paths ✅
- [x] **T104** 🟡 Frontend: เพิ่ม section "ข้อมูลบัญชีธนาคาร" (select ธนาคาร + ชื่อบัญชี + เลขบัญชี) ใน register form + ส่งไป API ✅
- [x] **T105** 🟢 Frontend: แสดง bank info (ธนาคาร/ชื่อบัญชี/เลขบัญชี) ใน customer detail page ✅

### Bank Account Validation Workflow ✅
- [x] **T106** 🔴 Backend: Customer model เพิ่ม bank validation fields (bankBookPath, bankStatus, bankRejectReason, bankReviewedAt/BY, bankReuploadToken + expiry) + migration `add_bank_validation` ✅
- [x] **T107** 🔴 Backend: StorageService (Supabase Storage — private bucket `bank-books` ที่มีอยู่แล้ว) + endpoints upload bank-book / bank-book-url / bank-review / bank-reupload validate / bank-reupload ✅
- [x] **T108** 🔴 BACKEND bank-review: LINE push แจ้งผลผ่าน-ไม่ผ่าน (พร้อมลิงก์ re-upload 7 วัน) 📌 handle กรณีไม่มี lineUserId
- [x] **T109** 🟡 Frontend: register form file upload รูปสมุดบัญชี + admin bank review UI (ผ่าน/ไม่อนุมัติ + เหตุผล) + หน้า `/bank-reupload` (validate token → แสดงเหตุผล → อัปโหลดใหม่) + badge/filter สถานะ bank ใน customer table/detail ✅
- [x] **T110** 🟡 Docs: อัปเดต Database Schema + api-reference (endpoints ใหม่) ✅
- [x] **T111** 🟢 UI fix: เปลี่ยน `Created At` → `Registered At` (แก้ `createdAt` → `registeredAt` — field ที่ API ส่งจริง) ใน customer detail + columns + interface ✅
- [x] **T112** 🟢 UI fix: รูปสมุดบัญชีทำ lightbox — คลิกดูรูปเต็ม (Dialog + hover hint "🔍 คลิกดูเต็ม") ✅

### User Management (Superadmin) ✅
- [x] **T113** 🔴 Backend: User CRUD (`GET/POST /api/users`, `PATCH/DELETE /api/users/:id`) — UserModule + controller + service + DTOs, `@Roles('superadmin')` + Swagger เต็ม ✅
- [x] **T114** 🟡 Frontend: หน้า User Management จริง (แทน demo ด้วย faker) — table username/role/createdAt + Add/Edit/Delete dialog + search + pagination + react-query ✅
- [x] **T115** 🟡 Role-based visibility: sidebar Users item + route guard — แสดง/เข้าถึงได้เฉพาะ superadmin (redirect ไป `/` ถ้าไม่ใช่) ✅
- [x] **T116** 🟢 Docs: อัปเดต api-reference + Overview + tasks ✅
- [x] **T117** 🟢 Protections: ห้ามลบบัญชีตัวเอง + ห้ามลบ/เปลี่ยน role ของ superadmin คนสุดท้าย + จัดการ username ซ้ำ (409 Conflict) ✅

> User management (superadmin) — backend CRUD + frontend page + role guard — done 2026-08-03

> Bank account validation workflow (bank book upload to Supabase Storage, admin review, LINE notify, re-upload loop) — done 2026-08-02

> Bank account fields (commission payout) — backend DTO/service/schema + register form + customer detail — done 2026-08-02

### Role Based Access Control (RBAC) ⬜

> Design: [[RBAC Design]] — Role → Permission model, Option A (code-defined map), 4 roles (superadmin/admin/finance/support), SoD: bank:review ≠ payouts:approve

- [ ] **T118** 🔴 Backend: `permissions.ts` (enum Role + ROLE_PERMISSIONS map) + `PermissionsGuard` + `@RequirePermissions` decorator
- [ ] **T119** 🔴 Backend: เปลี่ยน controllers ใช้ `@RequirePermissions` (แทน `@Roles` string เทียบตรง)
- [ ] **T120** 🔴 Backend: login response + `GET /user-profile/me` คืน `user.permissions`
- [ ] **T121** 🟡 Backend: unit tests — guard อนุญาต/ปฏิเสธตาม permission matrix
- [ ] **T122** 🔴 Frontend: `auth-store` เก็บ permissions + `hasPermission()` + route guards ใช้ permission
- [ ] **T123** 🟡 Frontend: sidebar + command menu filter ด้วย permission (แทน role เทียบตรง)
- [ ] **T124** 🟡 Frontend: `<Can>` component + redirect ไปหน้า `/403` (แทน silent redirect หน้าแรก)
- [ ] **T125** 🟢 Docs: อัปเดต api-reference + AGENTS.md + tasks

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
- [x] Customer Code auto-gen + LINE push ✅
- [ ] Customer Referral link + invite flow ⬜

### Dashboard Stats + Customer Actions 🟢

> ฟีเจอร์: แดชบอร์ดแสดงสถิติสมัครสมาชิกจริง (แทน mock) + Customer page มี action แก้ไข/ลบ/ส่งลิงก์อัปโหลดสมุดบัญชี — done 2026-08-05

- [x] **T126** 🔴 Backend: `GET /api/customers/stats/registrations` (daily/monthly/yearly) group by `registeredAt`, default 30d/12mo/5yr, filter `status != deleted` ✅
- [x] **T127** 🔴 Backend: `DELETE /api/customers/:id` — soft delete (ตั้ง `status='deleted'`) + filter ใน `findAll()`/`search()`/`findByLineUserId()` ✅
- [x] **T128** 🔴 Backend: `POST /api/customers/:id/bank-reupload-send` — สร้าง reupload token (randomBytes 24 hex, expiry 7 วัน) + push LINE ลิงก์; คืน `{ sent:false }` ถ้าไม่มี Line ID (ไม่ throw) ✅
- [x] **T129** 🟡 Frontend: Dashboard cards ลูกค้าวันนี้/เดือนนี้/ปีนี้/รวม + date range (preset วันนี้/7 วัน/30 วัน/กำหนดเอง) + period toggle (รายวัน/เดือน/ปี) + recharts bar chart (แทน mock revenue cards) ✅
- [x] **T130** 🟡 Frontend: Customers table เพิ่ม column "จัดการ" — แก้ไข (Dialog), ลบ (AlertDialog confirm + soft delete), ส่งลิงก์ re-upload (confirm + toast ผล) — พร้อม `stopPropagation` บนปุ่ม row action ✅
- [x] **T131** 🟡 Frontend: `api.ts` เพิ่ม `getRegistrationStats`, `deleteCustomer`, `sendBankReupload` + types ✅

### UI Adjustments 🟢

> ฟีเจอร์: ปรับ UX หลัง dashboard/customer actions — done 2026-08-05 (commit `231129c` web master)

- [x] **T132** 🟡 Frontend: ย้ายปุ่ม "ส่งลิงก์อัปโหลดสมุดบัญชี" จากตาราง → หน้า customer detail (ส่วนบัญชีธนาคาร, มี AlertDialog confirm + toast) ✅
- [x] **T133** 🟡 Frontend: เพิ่มคอลัมน์ "รหัสลูกค้า" (`code` NC#####, null → `-`) เป็นคอลัมน์แรกในตาราง ✅
- [x] **T134** 🟢 Frontend: ลบปุ่ม Download + tab select ออกจาก dashboard — แสดง `RegistrationStats` ตรงๆ + ลบ import ไม่ใช้ (build ผ่าน) ✅

### Backend Chore 🟢

> งานบำรุง — done 2026-08-05 (commit `0f75be4` api main)

- [x] **T135** 🟢 Backend: ลบ admin seeder (`prisma/seed.ts` + `seedAdminUsers()` ใน `prisma.service.ts`) — เลิกสร้าง/รีเซ็ต admin1-5 (password `admin123`) ทุก boot; ข้อมูล admin ใน DB ไม่ถูกแตะ ✅

### Known Issues ⚠️

- [x] **BUG** CORS error ตอน update customer (web→api) — สืบแล้ว: server CORS config ถูกต้อง (preflight 204 + `allow-origin: *`), bundle ที่ deploy ส่ง PATCH ถูกต้อง; อาการ "Provisional headers are shown" = request ถูก block ก่อนส่ง → สาเหตุจริงคือ **Render free tier cold start** (instance sleep หลัง idle 15 นาที → ตอบ error page ไม่มี CORS headers) ✅ **ปิดแล้ว** — user ยืนยัน 2026-08-07 ว่าหายแล้ว (ไม่ใช่ code bug) — ทางกันกลับ: upgrade tier หรือ keep-alive cron ถ้าเจออีก

### Performance: Customer List Query 🟡

> จาก load test 2026-08-07 (ดู [[2026-08-07-load-test-performance]]) — `GET /api/customers` ช้ากว่า detail ทุกรอบ (ข้อมูลแค่ 4 รายการ แต่ p95 ~800ms-1.3s ที่ conc 10-15) → bottleneck อยู่ที่ query เอง ไม่ใช่ Render/Neon — อัปเกรด infra ไม่คุ้ม

- [x] **T136** 🔴 Backend: profile & optimize `GET /api/customers` (`CustomerService.findAll()`) — แยกวัด count query vs pagination vs `placementUpline`/`treePath` computation, กำจัด N+1 / recursive scan ✅ (commit `f1803cd`)
- [x] **T137** 🟡 Backend: เช็ค/เพิ่ม index บน `code` / `status` / `registeredAt` (Prisma migration ถ้าจำเป็น) ✅ (migration `customers_status_idx` + `customers_registered_at_idx` — apply กับ production แล้ว)
- [ ] **T138** 🟡 Re-run load test (`loadtest_nuclear.js`) หลัง optimize — เป้าหมาย: list p95 < 300ms ที่ conc 10-15
- [ ] **T139** 🟢 Docs: อัปเดตผล load test หลัง optimize ใน [[2026-08-07-load-test-performance]]

> หมายเหตุเพิ่มเติมจาก load test: `admin1` login ไม่ได้แล้ว (เหลือ admin3/4/5, password `admin123`) — ควรตรวจบัญชี admin ใน DB

### Register Flow — Phone Unique + Shipping Notice 🟡

> เพิ่มความเข้มงวด/ความชัดเจนตอนสมัคร — 2026-08-07

- [x] **T140** 🔴 เบอร์มือถือห้ามซ้ำ — unique constraint บน `phone` (Prisma migration) + ตรวจซ้ำใน `CustomerService.create()` → ตอบ 409 พร้อม error message + จัดการ P2002 (กัน race); Frontend แสดง error ที่ field เบอร์โทร ✅ (backend `f1803cd` + frontend `2d51334`)
- [x] **T141** 🟡 Frontend: เพิ่มข้อความใต้ field ที่อยู่ (helper text) — "ที่อยู่และเบอร์โทรนี้จะใช้ในการจัดส่งสินค้า" เพื่อให้ลูกค้ารู้ว่าจะใช้ข้อมูลนี้จัดส่ง (register form) ✅ (commit `2d51334`)

### Gift Flow — แจกของสมนาคุณ 🎁

> Flow: สมัคร → ได้รหัส NC0000x → LINE แจ้ง + ลิงก์ Google Form → ลูกค้ากรอก (รหัส + พืชที่ปลูก) → บริษัทจัดส่งของตามที่อยู่/เบอร์ที่สมัคร (ดู [[2026-08-07-register-gift-flow]])

- [x] ~~**T142**~~ ~~LINE push หลังสมัครสำเร็จ — เพิ่มลิงก์ Google Form~~ — ✖️ **ยกเลิกตามคำขอ user (2026-08-07)** — revert commit `cc1f252` (ลบ `GIFT_FORM_URL` ออกจากโค้ด + env แล้ว)
- [ ] ~~**T143**~~ ~~(ตัดสินใจ) ข้อมูลจาก Google Form อยู่นอกระบบ~~ — ✅ **ตัดสินใจแล้ว (2026-08-07): เลือกเก็บในแอปแทน** — ดู T146 (field `พืชที่ปลูก` ใน register form + customer detail)
- [ ] **T144** 🟢 (ตัดสินใจ) สถานะส่งของ (ส่งแล้ว/ยัง) — ต้องมี tracking ไหม (รู้ว่าใครยังไม่ได้ของ)

### LINE Push — รูปกิจกรรมหลังสมัคร 🖼️

> เพิ่ม 2026-08-07 — หลังลูกค้าสมัครสมาชิก ให้ LINE ส่งรูปกิจกรรม (activity image) ด้วย

- [x] **T145** 🟡 Backend: LINE push รูปกิจกรรมหลังสมัครสำเร็จ — set ผ่าน env `ACTIVITY_IMAGE_URL` ✅ (commit `67d384c`) — **ถ้ามีค่า** → ส่ง image message + ข้อความแจ้งรหัส / **ถ้าไม่มี** → ข้าม (text อย่างเดียว ไม่พัง)
  - การ implement: `LineService.pushMessage()` รองรับ array messages (image + text), เพิ่ม `pushWelcome()` อ่าน env เอง, controller เรียก `pushWelcome()` — รองรับ `ACTIVITY_IMAGE_PREVIEW_URL` แยก (LINE บังคับ preview ≤ 240×240) fallback ใช้ URL เดียวกับรูปใหญ่
  - **การ host รูป (เลือกแล้ว): Supabase Storage public bucket** — สร้าง bucket `activity` (public) → อัปโหลดรูป → ใช้ URL `https://<project>.supabase.co/storage/v1/object/public/activity/<file>.jpg` ไปใส่ใน Render env `ACTIVITY_IMAGE_URL`
  - รายละเอียด: ใช้ LINE Messaging API `type: 'image'` (`originalContentUrl` + `previewImageUrl` ใช้ค่าเดียวกัน) — ต่อ `messages` array ใน `pushMessage`/`replyMessage` — ดูว่า `LineService.pushMessage()` รองรับ array messages ไหม ถ้าไม่ ต้องปรับ (ตอนนี้รับ `text: string` อย่างเดียว)
  - env: เพิ่ม `ACTIVITY_IMAGE_URL=` ใน `.env.example` — ไม่ commit ค่าจริง

### Customer — พืชที่ปลูก 🌱

> เพิ่ม 2026-08-07 — เก็บข้อมูล "ลูกค้าปลูกอะไร" เข้าระบบโดยตรง (แทน Google Form — ตัดสินใจปิด T143)

- [ ] **T146** 🟡 เก็บ field `พืชที่ปลูก` (optional) — หน้า สมัครสมาชิก + แสดงใน customer detail
  - Backend: เพิ่ม column `plants` (String? / Text) ใน `Customer` (Prisma schema + migration) → `CreateCustomerDto` + `UpdateCustomerDto` เพิ่ม `plants?` optional → response ของ `POST /api/customers` + `GET /api/customers/{id}` มี field นี้ด้วย
  - Frontend (web): หน้า register form เพิ่ม field `พืชที่ปลูก` (optional — placeholder เช่น "ข้าว, มะม่วง, ผักสวนครัว" หรือ textarea) → ส่ง `plants` ใน payload
  - Frontend (web): หน้า customer detail แสดง "พืชที่ปลูก" (ถ้ามีค่า — ถ้าไม่มีไม่ต้องแสดง/hide)
  - ตรวจ: tsc/build ผ่านทั้ง 2 repo + push (api `main`, web `master`)

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
- [x] **T73** 🔴 Line OA → "สมัครสมาชิก" → ฟอร์ม → submit → DB → success (พร้อม Customer Code) ✅
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

**รวม: 87 tasks + T118-T125 (RBAC) + T126-T135** | S1-S6 ✅ | S7 + S8 (referral/RBAC) remaining
```

ดูเพิ่มเติม: [[Phase 1 Plan]]
