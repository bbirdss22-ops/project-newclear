# 2026-08-14 — Dev Workflow Progress

**Status:** Phase 1 (Setup) ทำไป ~70% — เหลือ LINE test channel + Render/Vercel dev service

## ✅ เสร็จแล้ว

### Git Branching (Phase 2 บางส่วน)
- `project-nuclear-api`: สร้าง `dev` branch + push
- `project-nuclear-web`: สร้าง `dev` branch + **rename `master` → `main`** (default branch เปลี่ยน, ลบ master แล้ว)
- Branch protection `main` (require 1 PR review) ทั้ง 2 repos

### Env Templates
- API: `.env.development.example` + `.env.production.example`
- Web: `.env.development.example` + `.env.production.example`
- `.gitignore` API เพิ่ม `.env.development` / `.env.production` (กัน secret รั่ว)

### CI/CD Workflows (push แล้วบน dev)
- API: `.github/workflows/dev-deploy.yml` + `prod-deploy.yml` (build + test + Render deploy hook)
- Web: `.github/workflows/dev-deploy.yml` + `prod-deploy.yml` (build + Vercel auto-deploy)
- ⚠️ ตอนแรก push ไม่ได้เพราะ PAT ไม่มี `workflow` scope → เพิ่ม scope แล้ว push สำเร็จ

### Neon Dev Branch ✅ (connection string ใช้ได้)
- DB: `ep-patient-queen-azcllyn0-pooler.c-3.ap-southeast-1.aws.neon.tech/neondb`
- migrations: schema up to date (3 migrations)
- **seed.ts ทำงาน** — แก้ 2 จุด:
  1. Prisma 7 ต้องใช้ driver adapter → `new PrismaClient({ adapter: new PrismaPg({...}) })`
  2. field `passwordHash` → `password` (ตาม schema จริง)
- prisma.config.ts: เพิ่ม `migrations.seed = "tsx prisma/seed.ts"` (Prisma 7 ไม่อ่าน package.json)
- install `tsx` เป็น devDependency
- Seed data: NC00001, NC00002 (referrer = A), admin
- Verify: customers=2, users=1

### ยังไม่ได้ push (ค้างใน local)
- `prisma/seed.ts` (แก้ adapter + password)
- `prisma.config.ts` (seed command)
- `.gitignore` (เพิ่ม env)
- `package.json` (tsx devDep)

## ⬜ เหลือทำ

### ต้อง external access (ทำเอง)
1. **LINE test channel** → LINE Developers Console → secret + access token → ใส่ `.env.development`
2. **Render dev service** `dev-project-newclear-api` → branch `dev` + env จาก `.env.development`
3. **Vercel dev** → เชื่อม branch `dev`

### รอผมทำ (เมื่อมีค่า)
4. Push seed.ts + prisma.config.ts + .gitignore + package.json ขึ้น dev
5. GitHub secrets: `RENDER_DEPLOY_HOOK_DEV`, `RENDER_DEPLOY_HOOK_PROD`, `DATABASE_URL_PROD`
6. ทดสอบ pipeline dev → main

## 📌 หมายเหตุ
- dev-deploy workflow ยังไม่มี CI check จริงใน main protection (contexts ว่าง) — optional เพิ่มทีหลัง
- seed admin password เป็นค่า placeholder (`change-me-in-prod`) — ต้องเปลี่ยนก่อนใช้จริง
- sslmode warning ตอน seed (`sslmode=require` → libpq ใหม่) — ไม่มีผลกับ Prisma
