---
tags:
  - project-nuclear
  - progress
  - s2
created: 2026-07-26
---

# S2.1 — NestJS Backend Init ✅

> Backend พร้อมใช้งานบน Render แล้ว

## สรุป

| รายการ | สถานะ |
|--------|--------|
| NestJS 11 project | ✅ |
| Prisma v7 schema (11 tables) | ✅ |
| Health endpoint `GET /api/health` | ✅ |
| Global ValidationPipe + CORS | ✅ |
| ConfigModule + .env | ✅ |
| `.gitignore` + `.env.example` + `AGENTS.md` | ✅ |
| Deploy ขึ้น Render | ✅ |

## Repo

- **GitHub:** `bbirdss22-ops/project-nuclear-api` (branch `main`)
- **Render:** `https://project-nuclear-api.onrender.com`

## Fixes ระหว่าง deploy

1. `prisma.service.ts` — ลบ lifecycle hooks (`$connect`/`$disconnect`) เพราะ Prisma v7 auto-connect
2. `package.json` — เพิ่ม `"postinstall": "prisma generate"` + fix `start:prod` path → `node dist/src/main.js`

## API Test

```bash
curl https://project-nuclear-api.onrender.com/api/health
# → {"status":"ok","timestamp":"...","service":"project-newclear-api","version":"0.0.1"}
```

## ถัดไป

- [[Phase 1 Tasks#📦 S2 NestJS Backend 3-4 วัน|S2.2 — Auth Module]] (JWT login)
- S2.3 — Customer Module (CRUD)
- S2.4 — Line Module (Webhook)
