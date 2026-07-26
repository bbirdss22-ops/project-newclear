---
tags:
  - project-nuclear
  - workflow
  - sub-agent
created: 2026-07-26
---

# Sub-Agent Software Engineer — Project Nuclear

> ใช้ `kimi-k2.7-code` เป็น software engineer agent สำหรับงาน coding

## Model

```
model: kimi-k2.7-code
```

## วิธี Spawn

ใช้ `sessions_spawn` ด้วย workflow นี้:

```json
{
  "taskName": "se-{task-name}",
  "model": "kimi-k2.7-code",
  "task": "คำอธิบายงาน + context + requirements",
  "mode": "run",
  "sandbox": "inherit"
}
```

## Template Task Prompt

```
คุณคือ Software Engineer Agent สำหรับ Project Nuclear API

## ภารกิจ: {ชื่อ Task}

ทำต่อจาก S2.1/S2.2 ที่เสร็จแล้ว

### งานที่ต้องทำ
{list tasks}

### โปรเจคอยู่ที่
- /root/project-newclear-api/ — NestJS project
- Deployed: https://project-nuclear-api.onrender.com
- GitHub: bbirdss22-ops/project-nuclear-api (main)

### Dependencies ที่ติดตั้งไว้แล้ว
@nestjs/config, @nestjs/passport, @nestjs/jwt, passport,
passport-jwt, bcrypt, class-validator, class-transformer,
@line/bot-sdk, @prisma/client, @prisma/adapter-pg, prisma

### ข้อควรระวัง
- Prisma v7 ใช้ driver adapter (@prisma/adapter-pg)
- TypeScript module: nodenext
- หลังเขียนโค้ด ให้ build ตรวจสอบ: npm run build
- ทดสอบ localhost ก่อน report
- commit + push ขึ้น GitHub auto-deploy

### รายงานผล
- ไฟล์ที่สร้าง + build status + endpoint status
- ถ้ามีการแก้ไขหรือเพิ่ม API → ต้องอัปเดต `Notes/api-reference.md` ใน vault ด้วย
- Commit message ใช้ convention: `{agent-name} | (type): {commit message}`
```

## ⚠️ Workflow Rule — API Work (ห้ามลืม!)

**เมื่อมีคำสั่งเกี่ยวกับ API ทุกครั้ง (แก้ไข/เพิ่ม endpoint, ติดตั้ง package ที่เกี่ยวกับ API, เปลี่ยน logic):**

1. **อย่าทำเอง** — Spawn sub-agent `kimi-k2.7-code` เสมอ
2. sub-agent implement → build → commit + push
3. ผม (JARVIS) ทดสอบ QA + **อัปเดต `Notes/api-reference.md`** ใน vault เสมอ
4. Push vault

> สาเหตุ: API งานมีหลายส่วน (controller, service, DTO, decorators, build, deploy) — การทำเองเสี่ยงพลาด/ลืมบางไฟล์

## ตัวอย่างการใช้งาน

```bash
# 1. Auth Module (S2.2)
TaskName: se-nuclear-auth
→ สร้าง AuthModule, JWT Auth, Guards, Roles, seed
→ ✅ Complete

# 2. Customer CRUD (S2.3) — Next
TaskName: se-nuclear-customer
→ CustomerModule, CRUD endpoints, search, pagination
```

## ข้อควรรู้

| หัวข้อ | รายละเอียด |
|--------|-----------|
| Working Dir | `/root/project-newclear-api/` |
| Logs | Render dashboard → project-nuclear-api → Logs |
| Auto-deploy | Push branch `main` → Render auto-deploy |
| Vault | `project-newclear` repo — progress notes ใน `Notes/` |
| Vault Workflow | สร้าง markdown → `git add/commit/push` → auto push ขึ้น GitHub |

## S2.2 Auth Module — สรุปผลจาก Sub-Agent

### ไฟล์ที่สร้าง

| ไฟล์ | คำอธิบาย |
|------|----------|
| `src/auth/auth.module.ts` | AuthModule — imports JwtModule + PassportModule |
| `src/auth/auth.service.ts` | validateUser() bcrypt + login() sign JWT |
| `src/auth/auth.controller.ts` | `POST /api/auth/login` |
| `src/auth/dto/login.dto.ts` | LoginDto validation |
| `src/auth/strategies/jwt.strategy.ts` | JWT Bearer strategy |
| `src/auth/guards/jwt-auth.guard.ts` | Route protection |
| `src/auth/guards/roles.guard.ts` | Role-based access (superadmin/admin) |
| `src/auth/decorators/roles.decorator.ts` | `@Roles()` decorator |
| `src/auth/decorators/current-user.decorator.ts` | `@CurrentUser()` decorator |
| `prisma/seed.ts` | Auto-seed admin users ทุก startup |

### Accounts

| Username | Password | Role |
|----------|----------|------|
| `admin1` | `admin123` | `superadmin` |
| `admin2`-`admin5` | `admin123` | `admin` |

### API

```bash
POST /api/auth/login
Body: {"username":"admin1","password":"***"}
→ {"access_token":"eyJ...","user":{"id":"...","username":"admin1","role":"superadmin"}}
```
