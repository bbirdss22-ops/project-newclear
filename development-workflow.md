# Development Workflow — Project Newclear

**Created:** 2026-08-12
**Status:** 📝 Designed — pending implementation

---

## 🎯 ปัญหา

ระบบเริ่มใหญ่ขึ้น มี 3 repos + DB + LINE integration:
- `project-newclear-api` (NestJS + Prisma)
- `project-nuclear-web` (Vite + React)
- `project-newclear` (docs)
- Neon PostgreSQL (production)
- LINE OA integration

**ต้องการ:** แยก environment สำหรับ development/testing ก่อน deploy production

---

## 🏗️ Architecture: 2 Environments (Cloud-Based)

```
┌─────────────────────────────────────────────────────────┐
│                    DEVELOPMENT (Cloud)                  │
├─────────────────────────────────────────────────────────┤
│  API:    dev-project-newclear-api.onrender.com         │
│  Web:    dev-project-nuclear-web.vercel.app            │
│  DB:     Neon dev branch (separate database)           │
│  LINE:   Test channel (webhook → dev API cloud URL)    │
│  Seed:   Test data, mock customers, test orders        │
│  Branch: `dev` branch → auto-deploy to dev env         │
└─────────────────────────────────────────────────────────┘
                          │
                     git push main
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    PRODUCTION (Cloud)                    │
├─────────────────────────────────────────────────────────┤
│  API:    project-newclear-api.onrender.com             │
│  Web:    project-nuclear-web.vercel.app                │
│  DB:     Neon production (real data)                   │
│  LINE:   Production channel (real LINE OA)             │
│  Data:   Real customers, real orders                   │
│  Branch: `main` branch → auto-deploy to prod env       │
└─────────────────────────────────────────────────────────┘
```

---

## 📂 Environment Variables

### API (`project-newclear-api`)

**`.env.development`** (Render dev service):
```bash
# Database (Neon dev branch)
DATABASE_URL=postgresql://...@dev-db.neon.tech/newclear-dev

# LINE (test channel)
LINE_CHANNEL_ACCESS_TOKEN=dev-token
LINE_CHANNEL_SECRET=dev-secret

# Frontend URL (dev cloud)
FRONTEND_URL=https://dev-project-nuclear-web.vercel.app

# Activity image (dev)
ACTIVITY_IMAGE_URL=https://via.placeholder.com/600x400?text=Dev+Activity
```

**`.env.production`** (Render):
```bash
# Database (Neon production)
DATABASE_URL=postgresql://...@prod-db.neon.tech/newclear-prod

# LINE (production)
LINE_CHANNEL_ACCESS_TOKEN=prod-token
LINE_CHANNEL_SECRET=prod-secret

# Frontend URL (production)
FRONTEND_URL=https://project-nuclear-web.vercel.app

# Activity image (production)
ACTIVITY_IMAGE_URL=https://real-image-url.com/activity.jpg
```

### Web (`project-nuclear-web`)

**`.env.development`** (Vercel dev):
```bash
VITE_API_BASE_URL=https://dev-project-newclear-api.onrender.com/api
```

**`.env.production`** (Vercel):
```bash
VITE_API_BASE_URL=https://project-newclear-api.onrender.com/api
```

---

## 🌿 Git Branching Strategy

### Option A: Simple (2 branches)

```
main ───────────────────────────────► production
  │
  └── dev ───────────────────────────► development
        │
        └── feature/xxx ─────────────► feature branches
```

- `main` = production (auto-deploy to production)
- `dev` = development (auto-deploy to dev environment)
- `feature/*` = feature branches (merge to `dev` first)

### Option B: Git Flow (recommended for larger team)

```
main ───────────────────────────────► production
  │
  └── develop ───────────────────────► development
        │
        ├── feature/referral-system ─► feature branches
        ├── feature/commission-calc
        └── bugfix/xxx ──────────────► bugfix branches
```

**แนะนำ:** เริ่มด้วย **Option A** (simple) ก่อน ถ้าทีมใหญ่ขึ้นค่อยเปลี่ยนเป็น Git Flow

---

## 🗄️ Database Strategy

### Neon Branches

Neon รองรับ **database branching** (เหมือน git branch):

```
Production (main branch)
├── Database: newclear-prod
├── Data: real customers, real orders
└── Don't touch! ⚠️

Development (dev branch)
├── Database: newclear-dev
├── Data: seed data, test customers
└── Safe to experiment ✅
```

**Migration workflow:**
```bash
# Development
npx prisma migrate dev --name add-commission-table
# → สร้าง migration file + apply to dev DB

# Test locally
npm run seed  # ใส่ test data

# Deploy to production
npx prisma migrate deploy
# → Apply same migration to production DB
```

### Seed Data (`prisma/seed.ts`)

สร้าง seed script สำหรับ dev environment:

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  // Create test customers
  const customerA = await prisma.customer.create({
    data: {
      code: 'NC00001',
      firstName: 'ทดสอบ',
      lastName: 'ลูกค้า',
      phone: '0812345678',
      lineUserId: 'test-line-user-a',
      // ...
    },
  });

  const customerB = await prisma.customer.create({
    data: {
      code: 'NC00002',
      firstName: 'เพื่อน',
      lastName: 'ทดสอบ',
      phone: '0898765432',
      referrerId: customerA.id,
      // ...
    },
  });

  console.log('✅ Seed data created');
}

main().catch(console.error);
```

**package.json:**
```json
{
  "prisma": {
    "seed": "ts-node prisma/seed.ts"
  }
}
```

---

## 🔄 CI/CD Pipeline (Cloud-Based)

### Render Setup

**Production Service:**
- Service name: `project-newclear-api`
- Branch: `main`
- Auto-deploy: ✅
- Environment: `.env.production`

**Dev Service:**
- Service name: `dev-project-newclear-api`
- Branch: `dev`
- Auto-deploy: ✅
- Environment: `.env.development`

### Vercel Setup

**Production:**
- Project: `project-nuclear-web`
- Branch: `main`
- Auto-deploy: ✅
- Environment: Production

**Dev:**
- Project: `dev-project-nuclear-web` (or preview deployments)
- Branch: `dev`
- Auto-deploy: ✅
- Environment: Preview/Development

**`.github/workflows/prod-deploy.yml`**:
```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy-api:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run build
      - run: npm test
      
      # Run migrations
      - run: npx prisma migrate deploy
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL_PROD }}
      
      # Deploy to Render (production)
      - name: Deploy to Render (prod)
        run: |
          curl -X POST ${{ secrets.RENDER_DEPLOY_HOOK_PROD }}

  deploy-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run build
      - run: npm run test:e2e
      
      # Vercel auto-deploys on push to main
```

---

## 🧪 Testing Strategy

### Development Workflow (Cloud-Based)

```bash
# 1. Clone repos
git clone https://github.com/bbirdss22-ops/project-newclear-api.git
git clone https://github.com/bbirdss22-ops/project-nuclear-web.git

# 2. Create feature branch
cd project-newclear-api
git checkout -b feature/referral-system

# 3. Make changes, commit, push
git add .
git commit -m "feat: add referral system"
git push origin feature/referral-system

# 4. Merge to dev branch (via PR or direct merge)
git checkout dev
git merge feature/referral-system
git push origin dev
# → Auto-deploy to dev cloud environment

# 5. Test on dev cloud
# https://dev-project-nuclear-web.vercel.app
# https://dev-project-newclear-api.onrender.com

# 6. If all good, merge to main
git checkout main
git merge dev
git push origin main
# → Auto-deploy to production
```

### Testing Checklist

**Before merging to main:**
- [ ] All tests pass (`npm test`)
- [ ] E2E tests pass (`npm run test:e2e`)
- [ ] Manual testing on dev environment
- [ ] LINE webhook tested (use test channel)
- [ ] Database migrations tested
- [ ] No console errors
- [ ] Mobile responsive (if UI changes)

---

## 🔐 LINE Integration

### Development (Test Channel + Cloud)

1. สร้าง LINE test channel ที่ [LINE Developers Console](https://developers.line.biz/)
2. Set webhook URL: `https://dev-project-newclear-api.onrender.com/webhook`
3. ใช้ channel access token ของ test channel ใน `.env.development`

**ข้อดี:** ไม่ต้องใช้ ngrok — dev API เป็น cloud URL แล้ว

### Production (Real Channel)

ใช้ LINE production channel:
- Channel access token จาก LINE OA จริง
- Webhook URL: `https://project-newclear-api.onrender.com/webhook`

---

## 📊 Environment Comparison

| Aspect | Development | Production |
|--------|-------------|------------|
| **API URL** | `dev-project-newclear-api.onrender.com` | `project-newclear-api.onrender.com` |
| **Web URL** | `dev-project-nuclear-web.vercel.app` | `project-nuclear-web.vercel.app` |
| **Database** | Neon dev branch (test data) | Neon production (real data) |
| **LINE Channel** | Test channel | Production LINE OA |
| **Webhook URL** | `https://dev-.../webhook` (cloud) | `https://prod-.../webhook` (cloud) |
| **Data** | Seed data, mock customers | Real customers, real orders |
| **Deploy** | Auto on push to `dev` | Auto on push to `main` |
| **Access** | Public URL (cloud) | Public URL (cloud) |
| **Risk** | Safe to experiment | ⚠️ Real money, real users |

---

## 🚀 Implementation Tasks

### Phase 1: Setup (1-2 days)

- [ ] Create Neon dev branch (database)
- [ ] Add `.env.development` to both repos
- [ ] Create seed script (`prisma/seed.ts`)
- [ ] Test local dev workflow

### Phase 2: Git Branching (1 day)

- [ ] Create `dev` branch in both repos
- [ ] Set up branch protection rules
  - `main`: require PR, require CI
  - `dev`: allow direct push (for now)
- [ ] Update README with workflow instructions

### Phase 3: CI/CD (2-3 days)

- [ ] Create LINE test channel
- [ ] Set up GitHub Actions workflows
- [ ] Configure Render dev environment
- [ ] Configure Vercel preview deployments
- [ ] Test full pipeline: dev → main

### Phase 4: Testing (ongoing)

- [ ] Write E2E tests (Playwright/Cypress)
- [ ] Add unit tests for critical logic (commission calc)
- [ ] Set up monitoring (Sentry, etc.)
- [ ] Create testing checklist

---

## 💡 Tips & Best Practices

1. **Never work directly on `main`** — always use `dev` or feature branches
2. **Test on dev cloud before merging to main** — catch bugs in cloud environment
3. **Use seed data** — don't test with real customer data
4. **Keep .env files out of git** — use `.env.example` as template
5. **Document environment setup** — make it easy for new developers
6. **Use feature flags** — test new features without affecting production
7. **Monitor production** — set up alerts for errors, downtime
8. **Dev = Production-like** — same cloud infrastructure, just different data

---

## 🔮 Future Enhancements

- **Staging environment** — mirror of production for final testing (pre-prod)
- **Database snapshots** — copy production data to dev (anonymized)
- **Automated testing** — run tests on every PR
- **Preview deployments** — Vercel preview for each PR (already supported)
- **Feature flags** — toggle features on/off without deploy
- **Monitoring dashboard** — Grafana/Datadog for production metrics
- **Local dev fallback** — optional localhost setup for offline work

---

## 📚 Related Docs

- [[Commission Design]]
- [[Commission Tasks]]
- [[LINE Ordering Flow]]
- [[2026-07-28-customer-referral-feature]]

---

**Next Step:** เริ่ม Phase 1 (Setup) — สร้าง dev database + seed data 🚀

---

# 📈 Progress Log

## 2026-08-14 — Phase 1 Setup ~70%

**Status:** เหลือ LINE test channel + Render/Vercel dev service

### ✅ เสร็จแล้ว

**Git Branching (Phase 2 บางส่วน)**
- `project-nuclear-api`: สร้าง `dev` branch + push
- `project-nuclear-web`: สร้าง `dev` branch + **rename `master` → `main`** (default branch เปลี่ยน, ลบ master แล้ว)
- Branch protection `main` (require 1 PR review) ทั้ง 2 repos

**Env Templates**
- API: `.env.development.example` + `.env.production.example`
- Web: `.env.development.example` + `.env.production.example`
- `.gitignore` API เพิ่ม `.env.development` / `.env.production`

**CI/CD Workflows (push แล้วบน dev)**
- API: `.github/workflows/dev-deploy.yml` + `prod-deploy.yml` (build + test + Render deploy hook)
- Web: `.github/workflows/dev-deploy.yml` + `prod-deploy.yml` (build + Vercel auto-deploy)
- ⚠️ ตอนแรก push ไม่ได้เพราะ PAT ไม่มี `workflow` scope → เพิ่ม scope แล้ว push สำเร็จ

**Neon Dev Branch ✅ (connection string ใช้ได้)**
- DB: `ep-patient-queen-azcllyn0-pooler.c-3.ap-southeast-1.aws.neon.tech/neondb`
- migrations: schema up to date (3 migrations)
- **seed.ts ทำงาน** — แก้ 2 จุด:
  1. Prisma 7 ต้องใช้ driver adapter → `new PrismaClient({ adapter: new PrismaPg({...}) })`
  2. field `passwordHash` → `password` (ตาม schema จริง)
- prisma.config.ts: เพิ่ม `migrations.seed = "tsx prisma/seed.ts"` (Prisma 7 ไม่อ่าน package.json)
- install `tsx` เป็น devDependency
- Seed data: NC00001, NC00002 (referrer = A), admin
- Verify: customers=2, users=1

**ยังไม่ได้ push (ค้างใน local)**
- `prisma/seed.ts` (แก้ adapter + password)
- `prisma.config.ts` (seed command)
- `.gitignore` (เพิ่ม env)
- `package.json` (tsx devDep)

### ⬜ เหลือทำ

**ต้อง external access (ทำเอง)**
1. **LINE test channel** → LINE Developers Console → secret + access token → ใส่ `.env.development`
2. **Render dev service** `dev-project-newclear-api` → branch `dev` + env จาก `.env.development`
3. **Vercel dev** → เชื่อม branch `dev`

**รอ agent ทำ (เมื่อมีค่า)**
4. Push seed.ts + prisma.config.ts + .gitignore + package.json ขึ้น dev
5. GitHub secrets: `RENDER_DEPLOY_HOOK_DEV`, `RENDER_DEPLOY_HOOK_PROD`, `DATABASE_URL_PROD`
6. ทดสอบ pipeline dev → main

### 📌 หมายเหตุ
- dev-deploy workflow ยังไม่มี CI check จริงใน main protection (contexts ว่าง) — optional เพิ่มทีหลัง
- seed admin password เป็นค่า placeholder (`change-me-in-prod`) — ต้องเปลี่ยนก่อนใช้จริง
- sslmode warning ตอน seed (`sslmode=require` → libpq ใหม่) — ไม่มีผลกับ Prisma
