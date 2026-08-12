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

## 🏗️ Architecture: 2 Environments

```
┌─────────────────────────────────────────────────────────┐
│                    DEVELOPMENT                          │
├─────────────────────────────────────────────────────────┤
│  API:    localhost:3000 (or Render dev branch)         │
│  Web:    localhost:5173 (Vite dev server)              │
│  DB:     Neon dev branch (separate database)           │
│  LINE:   Test channel (or webhook proxy)               │
│  Seed:   Test data, mock customers, test orders        │
└─────────────────────────────────────────────────────────┘
                          │
                     git push main
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    PRODUCTION                            │
├─────────────────────────────────────────────────────────┤
│  API:    project-newclear-api.onrender.com             │
│  Web:    project-nuclear-web.vercel.app                │
│  DB:     Neon production (real data)                   │
│  LINE:   Production channel (real LINE OA)             │
│  Data:   Real customers, real orders                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📂 Environment Variables

### API (`project-newclear-api`)

**`.env.development`** (local dev):
```bash
# Database (Neon dev branch)
DATABASE_URL=postgresql://...@dev-db.neon.tech/newclear-dev

# LINE (test channel)
LINE_CHANNEL_ACCESS_TOKEN=dev-token
LINE_CHANNEL_SECRET=dev-secret

# Frontend URL (local dev)
FRONTEND_URL=http://localhost:5173

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

**`.env.development`** (local dev):
```bash
VITE_API_BASE_URL=http://localhost:3000/api
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

## 🔄 CI/CD Pipeline

### GitHub Actions (Recommended)

**`.github/workflows/dev-deploy.yml`**:
```yaml
name: Deploy to Development

on:
  push:
    branches: [dev]

jobs:
  deploy-api:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 20
      - run: npm ci
      - run: npm run build
      - run: npm test
      
      # Deploy to Render (dev branch)
      - name: Deploy to Render (dev)
        run: |
          curl -X POST ${{ secrets.RENDER_DEPLOY_HOOK_DEV }}

  deploy-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 20
      - run: npm ci
      - run: npm run build
      - run: npm run test:e2e
      
      # Vercel auto-deploys on push to dev
      # Just verify build passes
```

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

### Local Development Workflow

```bash
# 1. Clone repos
git clone https://github.com/bbirdss22-ops/project-newclear-api.git
git clone https://github.com/bbirdss22-ops/project-nuclear-web.git

# 2. Switch to dev branch
cd project-newclear-api
git checkout dev

# 3. Install dependencies
npm install

# 4. Setup dev database
npx prisma migrate dev
npm run seed  # Load test data

# 5. Start dev servers
# Terminal 1: API
npm run start:dev  # http://localhost:3000

# Terminal 2: Web
cd ../project-nuclear-web
npm run dev  # http://localhost:5173

# 6. Test locally
# Open http://localhost:5173
# Test registration, LINE webhook, etc.

# 7. When done, commit + push
git add .
git commit -m "feat: add referral system"
git push origin dev  # Auto-deploy to dev environment

# 8. Test on dev environment
# https://dev-project-nuclear-web.vercel.app
# https://dev-project-newclear-api.onrender.com

# 9. If all good, merge to main
git checkout main
git merge dev
git push origin main  # Auto-deploy to production
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

### Development (Test Channel)

สร้าง LINE test channel แยก:
1. ไปที่ [LINE Developers Console](https://developers.line.biz/)
2. Create new provider: "Newclear Dev"
3. Create Messaging API (test channel)
4. ใช้ channel access token ของ test channel ใน `.env.development`

### Testing LINE Webhook Locally

ใช้ **ngrok** เพื่อ expose local server:
```bash
# Install ngrok
npm install -g ngrok

# Expose local API
ngrok http 3000

# Copy URL: https://abc123.ngrok.io
# Set as webhook URL in LINE test channel
```

### Production (Real Channel)

ใช้ LINE production channel:
- Channel access token จาก LINE OA จริง
- Webhook URL: `https://project-newclear-api.onrender.com/webhook`

---

## 📊 Environment Comparison

| Aspect | Development | Production |
|--------|-------------|------------|
| **API URL** | `localhost:3000` or `dev-*.onrender.com` | `project-newclear-api.onrender.com` |
| **Web URL** | `localhost:5173` or `dev-*.vercel.app` | `project-nuclear-web.vercel.app` |
| **Database** | Neon dev branch (test data) | Neon production (real data) |
| **LINE Channel** | Test channel | Production LINE OA |
| **Data** | Seed data, mock customers | Real customers, real orders |
| **Deploy** | Auto on push to `dev` | Auto on push to `main` |
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
2. **Test on dev before merging to main** — catch bugs early
3. **Use seed data** — don't test with real customer data
4. **Keep .env files out of git** — use `.env.example` as template
5. **Document environment setup** — make it easy for new developers
6. **Use feature flags** — test new features without affecting production
7. **Monitor production** — set up alerts for errors, downtime

---

## 🔮 Future Enhancements

- **Staging environment** — mirror of production for final testing
- **Database snapshots** — copy production data to dev (anonymized)
- **Automated testing** — run tests on every PR
- **Preview deployments** — Vercel preview for each PR
- **Feature flags** — toggle features on/off without deploy
- **Monitoring dashboard** — Grafana/Datadog for production metrics

---

## 📚 Related Docs

- [[Commission Design]]
- [[Commission Tasks]]
- [[LINE Ordering Flow]]
- [[2026-07-28-customer-referral-feature]]

---

**Next Step:** เริ่ม Phase 1 (Setup) — สร้าง dev database + seed data 🚀
