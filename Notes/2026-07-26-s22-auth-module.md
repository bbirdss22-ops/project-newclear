---
tags:
  - project-nuclear
  - progress
  - s2
created: 2026-07-26
---

# S2.2 — Auth Module (JWT Login) ✅

> Auth module เสร็จสมบูรณ์ — Login ได้ JWT + Guards + Roles + Auto-seed

## สรุป

| รายการ | สถานะ |
|--------|--------|
| `AuthModule` (JwtModule + PassportModule) | ✅ |
| `AuthService` — validateUser() bcrypt + login() sign JWT | ✅ |
| `AuthController` — `POST /api/auth/login` | ✅ |
| `LoginDto` — validation (username, password required) | ✅ |
| `JwtStrategy` — extract Bearer + validate | ✅ |
| `JwtAuthGuard` — protect routes | ✅ |
| `RolesGuard` — superadmin/admin roles | ✅ |
| `@Roles()` + `@CurrentUser()` decorators | ✅ |
| `prisma/seed.ts` — auto-seed ทุก startup | ✅ |
| Build + deploy Render ผ่าน | ✅ |
| API test — ยิง login ได้ JWT กลับมา | ✅ |

## ไฟล์ที่สร้าง

| ไฟล์ | ไว้ทำอะไร |
|------|-----------|
| `src/auth/auth.module.ts` | AuthModule — imports JwtModule (async), PassportModule |
| `src/auth/auth.service.ts` | validateUser(), login(), validateJwtPayload() |
| `src/auth/auth.controller.ts` | `POST /api/auth/login` |
| `src/auth/dto/login.dto.ts` | Field validation |
| `src/auth/strategies/jwt.strategy.ts` | JWT Bearer strategy |
| `src/auth/guards/jwt-auth.guard.ts` | Route protection guard |
| `src/auth/guards/roles.guard.ts` | Role-based access guard |
| `src/auth/decorators/roles.decorator.ts` | `@Roles()` decorator |
| `src/auth/decorators/current-user.decorator.ts` | `@CurrentUser()` decorator |
| `prisma/seed.ts` | Seed admin users + startup auto-seed |

## API Login

```bash
POST /api/auth/login
Body: {"username":"admin1","password":"admin123"}
→ {"access_token":"eyJ...","user":{"id":"...","username":"admin1","role":"superadmin"}}
```

## Accounts

| Username | Password | Role |
|----------|----------|------|
| `admin1` | `admin123` | `superadmin` |
| `admin2`-`admin5` | `admin123` | `admin` |

## หมายเหตุ

- Token expires in 7 days (`JWT_EXPIRES_IN` env)
- Auto-seed บนทุก startup — ใช้ bcrypt hash จริง, ไม่ใช่ placeholder
- `admin1` role `superadmin`, ส่วนที่เหลือ `admin`

## ถัดไป

- [[Phase 1 Tasks#📦 S2 NestJS Backend 3-4 วัน|S2.3 — Customer Module (CRUD)]]
- S2.4 — Line Module (Webhook)
