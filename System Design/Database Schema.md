---
tags:
  - project-newclear
  - database
  - schema
  - mlm
  - commission
created: 2026-07-21
updated: 2026-07-28
---

# Database Schema

> PostgreSQL — ออกแบบเผื่อ MLM tree structure + Commission System

## Entity Relationship

```mermaid
erDiagram
    users ||--o| user_profiles : "has"
    users ||--o{ commissions : "approve"

    customers ||--o{ customers : "referrer"
    customers ||--o{ customers : "placement"
    customers ||--o{ line_events : "has"
    customers ||--o{ orders : "has"
    customers ||--o{ commissions : "earn"
    customers ||--o{ binary_volumes : "track"
    customers ||--o{ commission_payouts : "receive"

    orders ||--o{ order_items : "has"
    orders ||--o{ commissions : "generate"

    products ||--o{ order_items : "in"

    commission_config ||--o{ commissions : "rule"

    commissions ||--o{ commission_payouts : "included"

    users {
        uuid id PK
        string username UK
        string password
        string role
        datetime created_at
    }
    user_profiles {
        uuid id PK
        uuid user_id FK
        string display_name
        string email
        string phone
        string avatar_url
        string bio
        datetime created_at
        datetime updated_at
    }
    customers {
        uuid id PK
        string line_user_id UK
        string code UK "NC00001"
        string display_name
        string first_name
        string last_name
        string phone
        string email
        string id_card_number
        text address
        string bank_name "รหัสธนาคาร"
        string bank_account_name "ชื่อบัญชี"
        string bank_account_number "เลขบัญชี 9-13"
        text bank_book_path "path ใน Supabase Storage (bank-books bucket)"
        string bank_status "none | pending | approved | rejected"
        text bank_reject_reason "เหตุผลเมื่อไม่อนุมัติ"
        datetime bank_reviewed_at "เวลาที่ admin ตรวจสอบ"
        uuid bank_reviewed_by "user id ของ admin ที่ตรวจสอบ"
        string bank_reupload_token "token สำหรับอัปโหลดใหม่ (unique)"
        datetime bank_reupload_token_expires_at "หมดอายุ 7 วัน"
        uuid referrer_id FK
        uuid placement_upline FK
        string position "left | right"
        text tree_path
        string status "active | inactive"
        datetime registered_at
        datetime updated_at
    }
    line_events {
        uuid id PK
        string line_user_id
        string event_type
        jsonb raw
        datetime created_at
    }
    products {
        uuid id PK
        string name
        text description
        decimal price
        string commission_type
        decimal commission_value
        decimal pv
        boolean is_active
        datetime created_at
    }
    orders {
        uuid id PK
        uuid customer_id FK
        string order_no UK
        decimal total_amount
        decimal total_pv
        string status
        datetime paid_at
        datetime created_at
    }
    order_items {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        int quantity
        decimal price
        decimal pv
    }
    commission_config {
        uuid id PK
        string name
        string type
        int level
        decimal percentage
        int max_levels
        decimal min_pv
        boolean is_active
        datetime created_at
    }
    binary_volumes {
        uuid id PK
        uuid customer_id FK UK
        decimal left_volume
        decimal right_volume
        decimal paired_volume
        decimal carry_left
        decimal carry_right
        datetime computed_at
        datetime created_at
        datetime updated_at
    }
    commissions {
        uuid id PK
        uuid customer_id FK
        uuid source_order_id FK
        uuid source_customer_id FK
        uuid commission_config_id FK
        string type
        decimal amount
        decimal pv_amount
        int level
        string status "calculated | approved | paid"
        datetime calculated_at
        datetime approved_at
        uuid approved_by FK
        datetime paid_at
        uuid payout_id FK
        text remark
        datetime created_at
    }
    commission_payouts {
        uuid id PK
        uuid customer_id FK
        decimal total_amount
        string period_type "monthly | biweekly"
        date period_start
        date period_end
        date due_date
        decimal total_calculated
        decimal total_approved
        decimal total_deductions
        decimal net_amount
        string bank_name
        string bank_account
        string account_name
        string status "draft | approved | completed | rejected"
        datetime generated_at
        datetime approved_at
        uuid approved_by FK
        datetime completed_at
        datetime rejected_at
        text reject_reason
        text remark
        datetime created_at
    }
    payout_periods {
        uuid id PK
        string period_type "monthly | biweekly"
        date period_start
        date period_end
        date due_date
        boolean is_closed
        datetime closed_at
        datetime created_at
    }
```

---

## Core Tables

### `users` — Dashboard Users (Admin 5 คน)

```sql
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username    VARCHAR(50) UNIQUE NOT NULL,
  password    VARCHAR(255) NOT NULL,          -- bcrypt hash
  role        VARCHAR(20) DEFAULT 'admin',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### `customers` — ลูกค้า (ออกแบบเผื่อ MLM)

```sql
CREATE TABLE customers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  line_user_id    VARCHAR(255) UNIQUE,
  display_name    VARCHAR(255),

  -- ข้อมูลส่วนตัว
  first_name      VARCHAR(100),
  last_name       VARCHAR(100),
  phone           VARCHAR(20),
  email           VARCHAR(255),
  id_card_number  VARCHAR(20),                -- สำหรับ verify ตอน MLM
  address         TEXT,

  -- รับค่าคอมมิชชั่น
  bank_name           VARCHAR(50),            -- รหัสธนาคาร (KBANK, KTB, ...)
  bank_account_name   VARCHAR(100),           -- ชื่อบัญชี
  bank_account_number VARCHAR(20),            -- เลขบัญชี (9-13 หลัก)

  -- Bank account validation workflow
  bank_book_path              TEXT,                     -- path ใน Supabase Storage
  bank_status                 VARCHAR(20) DEFAULT 'none', -- none|pending|approved|rejected
  bank_reject_reason          TEXT,                     -- เหตุผลเมื่อไม่อนุมัติ
  bank_reviewed_at            TIMESTAMPTZ,              -- เวลาที่ admin ตรวจสอบ
  bank_reviewed_by            UUID,                     -- user id ของ admin
  bank_reupload_token         VARCHAR(64) UNIQUE,       -- token อัปโหลดใหม่
  bank_reupload_token_expires_at TIMESTAMPTZ,           -- หมดอายุ 7 วัน

  -- MLM Structure
  referrer_id      UUID REFERENCES customers(id),  -- คนชวน (who refer)
  placement_upline UUID REFERENCES customers(id), -- ตำแหน่งใน tree
  position         VARCHAR(10) CHECK (position IN ('left', 'right')),
  tree_path        TEXT,                         -- materialized path

  status          VARCHAR(20) DEFAULT 'active',
  registered_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_customers_line_user_id ON customers(line_user_id);
CREATE INDEX idx_customers_referrer ON customers(referrer_id);
CREATE INDEX idx_customers_upline ON customers(placement_upline);
CREATE INDEX idx_customers_tree_path ON customers(tree_path);
```

### `line_events` — Log Event เผื่อ Debug

```sql
CREATE TABLE line_events (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  line_user_id VARCHAR(255),
  event_type  VARCHAR(50),
  raw         JSONB,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_line_events_user ON line_events(line_user_id);
```

---

### `user_profiles` — โปรไฟล์ Admin (1:1 กับ users)

> เพิ่มเมื่อ: 2026-07-27 — สำหรับ admin dashboard users
> Auto-create เมื่อเรียก `GET /user-profile/me` ครั้งแรก

```sql
CREATE TABLE user_profiles (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  display_name    VARCHAR(100),
  email           VARCHAR(255),
  phone           VARCHAR(20),
  avatar_url      TEXT,
  bio             TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

**API:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/user-profile/me` | ✅ Bearer | Get current user profile (auto-create)
| PUT | `/api/user-profile/me` | ✅ Bearer | Update displayName, email, phone, avatarUrl, bio

---

## MLM Tree Structure

### Materialized Path

ใช้ `tree_path` เก็บ path แบบ `/root/left/right/left` เพื่อให้ query ง่าย

- **หา downline ทั้งหมด:** `WHERE tree_path LIKE '/root/left/%'`
- **หาคนที่อยู่ลึกเท่าไหร่:** นับจำนวน `/` ใน tree_path
- **หาคนชวน (referrer):** `referrer_id` column

### Binary Tree (Binary MLM)

| Field | Usage |
|-------|-------|
| `referrer_id` | คนที่ชวนมา |
| `placement_upline` | คนที่อยู่เหนือใน tree (อาจต่างจาก referrer) |
| `position` | `left` หรือ `right` |
| `tree_path` | เก็บ path สำหรับ query ได้ง่าย |

> 💡 **Tip:** ใช้ `ltree` extension ของ PostgreSQL หรือเก็บเป็น materialized path string ก็พอสำหรับ 200 คน

---

## Commission System Tables

### `products` — สินค้า

```sql
CREATE TABLE products (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            VARCHAR(200) NOT NULL,
  description     TEXT,
  price           DECIMAL(10,2) NOT NULL,
  commission_type VARCHAR(20) DEFAULT 'percent',  -- percent | fixed
  commission_value DECIMAL(10,2),                 -- % หรือ จำนวนเงิน
  pv              DECIMAL(10,2) DEFAULT 0,        -- Personal Volume (ใช้คิดคอมมิชชั่น)
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### `orders` — คำสั่งซื้อ + ใช้คำนวณคอมมิชชั่น

```sql
CREATE TABLE orders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL REFERENCES customers(id),
  order_no        VARCHAR(50) UNIQUE NOT NULL,      -- เช่น ORD-20260724-0001
  total_amount    DECIMAL(10,2) NOT NULL,
  total_pv        DECIMAL(10,2) DEFAULT 0,          -- Total Personal Volume
  status          VARCHAR(20) DEFAULT 'pending',    -- pending | paid | cancelled
  paid_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
```

### `order_items` — รายการสินค้าในออเดอร์

```sql
CREATE TABLE order_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id        UUID NOT NULL REFERENCES orders(id),
  product_id      UUID NOT NULL REFERENCES products(id),
  quantity        INT NOT NULL DEFAULT 1,
  price           DECIMAL(10,2) NOT NULL,
  pv              DECIMAL(10,2) DEFAULT 0
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
```

### `commission_config` — กฎการจ่ายคอมมิชชั่น

```sql
CREATE TABLE commission_config (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            VARCHAR(100) NOT NULL,           -- เช่น "Referral 10%", "Binary 8%"
  type            VARCHAR(20) NOT NULL,            -- referral | binary | matching | level
  -- referral: จ่าย % จากยอดคนที่ชวนมา
  -- binary: จ่าย % จากยอดขายฝั่งอ่อน (weaker leg)
  -- matching: จ่าย % จากคอมมิชชั่นของ downline
  -- level: จ่าย % ตาม depth (L1=10%, L2=5%, L3=2%)

  -- ค่าคอนฟิกตาม type
  level           INT DEFAULT 0,                   -- depth (level commission)
  percentage      DECIMAL(5,2) NOT NULL,           -- % หรือจำนวนเงิน
  max_levels      INT DEFAULT 1,                   -- จ่ายกี่ชั้น (matching/level)
  min_pv          DECIMAL(10,2) DEFAULT 0,         -- เงื่อนไขขั้นต่ำ (binary)
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

**ตัวอย่างข้อมูล:**
```sql
INSERT INTO commission_config (name, type, level, percentage, max_levels) VALUES
  ('Referral Direct', 'referral', 0, 10.00, 1),     -- ชวนตรง → 10%
  ('Binary Pairing',  'binary',   0, 8.00,  1),      -- binary match → 8%
  ('Matching L1',     'matching', 1, 10.00, 1),      -- L1 ได้ 10% ของคอมมิชชั่น downline
  ('Matching L2',     'matching', 2, 5.00,  2),      -- L2 ได้ 5%
  ('Level L1',        'level',    1, 10.00, 5),      -- L1 = 10%
  ('Level L2',        'level',    2, 5.00,  5),      -- L2 = 5%
  ('Level L3',        'level',    3, 2.00,  5);      -- L3 = 2%
```

### `binary_volumes` — ยอดขายฝั่งซ้าย/ขวา (สำหรับ Binary MLM)

```sql
CREATE TABLE binary_volumes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL REFERENCES customers(id),
  left_volume     DECIMAL(10,2) DEFAULT 0,         -- ยอดรวมฝั่งซ้าย
  right_volume    DECIMAL(10,2) DEFAULT 0,         -- ยอดรวมฝั่งขวา
  paired_volume   DECIMAL(10,2) DEFAULT 0,         -- ยอดที่ match แล้ว
  carry_left      DECIMAL(10,2) DEFAULT 0,         -- ยอดคงค้างฝั่งซ้าย (flushed)
  carry_right     DECIMAL(10,2) DEFAULT 0,         -- ยอดคงค้างฝั่งขวา
  computed_at     TIMESTAMPTZ,                     -- เวลาที่คำนวณล่าสุด
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(customer_id)
);
```

### `commissions` — ประวัติคอมมิชชั่นที่เกิดขึ้น

```sql
CREATE TABLE commissions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id         UUID NOT NULL REFERENCES customers(id),
  source_order_id     UUID REFERENCES orders(id),       -- มาจากออเดอร์ไหน
  source_customer_id  UUID REFERENCES customers(id),    -- คนที่ทำให้เกิดคอมมิชชั่น (downline)
  commission_config_id UUID REFERENCES commission_config(id),

  type                VARCHAR(20) NOT NULL,             -- referral | binary | matching | level
  amount              DECIMAL(10,2) NOT NULL,           -- จำนวนเงิน
  pv_amount           DECIMAL(10,2) DEFAULT 0,          -- PV ที่ใช้คำนวณ
  level               INT DEFAULT 0,                    -- level ของ downline

  -- status flow: calculated → approved → paid
  status              VARCHAR(20) DEFAULT 'calculated',
  calculated_at       TIMESTAMPTZ DEFAULT NOW(),       -- auto: ตอนคำนวณ
  approved_at         TIMESTAMPTZ,                      -- admin: กด approve
  paid_at             TIMESTAMPTZ,                       -- system: จ่ายแล้ว
  approved_by         UUID REFERENCES users(id),        -- admin คนที่ approve

  payout_id           UUID REFERENCES commission_payouts(id), -- เชื่อมไปรอบจ่าย
  remark              TEXT
);

CREATE INDEX idx_commissions_customer ON commissions(customer_id);
CREATE INDEX idx_commissions_status ON commissions(status);
CREATE INDEX idx_commissions_payout ON commissions(payout_id);
CREATE INDEX idx_commissions_type ON commissions(type);
```

### `commission_payouts` — การจ่ายเงินจริง (รอบจ่าย)

```sql
CREATE TABLE commission_payouts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL REFERENCES customers(id),
  total_amount    DECIMAL(10,2) NOT NULL,

  -- รอบจ่าย
  period_type     VARCHAR(10) NOT NULL,          -- monthly | biweekly
  period_start    DATE NOT NULL,
  period_end      DATE NOT NULL,
  due_date        DATE,                          -- วันที่ต้องจ่าย

  -- ตรวจสอบก่อนจ่าย
  total_calculated DECIMAL(10,2) DEFAULT 0,      -- ยอดที่ระบบคำนวณ
  total_approved   DECIMAL(10,2) DEFAULT 0,      -- ยอดที่ admin approve
  total_deductions DECIMAL(10,2) DEFAULT 0,      -- หัก ณ ที่จ่าย (tax/fee)
  net_amount       DECIMAL(10,2) NOT NULL,        -- ยอดสุทธิ

  -- ข้อมูลการโอน
  bank_name       VARCHAR(100),
  bank_account    VARCHAR(50),
  account_name    VARCHAR(200),

  -- status flow: draft → approved → completed | rejected
  status          VARCHAR(20) DEFAULT 'draft',
  generated_at    TIMESTAMPTZ DEFAULT NOW(),     -- auto generate
  approved_at     TIMESTAMPTZ,                    -- admin approve
  approved_by     UUID REFERENCES users(id),
  completed_at    TIMESTAMPTZ,                    -- โอนจ่ายจริง
  rejected_at     TIMESTAMPTZ,
  reject_reason   TEXT,

  remark          TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payouts_customer ON commission_payouts(customer_id);
CREATE INDEX idx_payouts_status ON commission_payouts(status);
CREATE INDEX idx_payouts_period ON commission_payouts(period_type, period_start);
```

### `payout_periods` — จัดการรอบจ่าย

```sql
CREATE TABLE payout_periods (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  period_type     VARCHAR(10) NOT NULL,          -- monthly | biweekly
  period_start    DATE NOT NULL,
  period_end      DATE NOT NULL,
  due_date        DATE,                          -- วันที่ปิดรอบ
  is_closed       BOOLEAN DEFAULT false,
  closed_at       TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_payout_period_unique ON payout_periods(period_type, period_start);
```

---

## 🔄 Commission Flow

```
1. สั่งซื้อ → orders (status=paid)
       ↓
2. ระบบคำนวณ commissions (auto)
   ├── referral → commissions(status=calculated)
   ├── binary → binary_volumes → match → commissions
   └── level/matching → ไล่ upline → commissions
       ↓
3. สิ้นรอบจ่าย (monthly/biweekly)
   ├── สรุป commissions ของรอบ
   ├── generate commission_payouts(status=draft)
   └── แสดงใน Dashboard รอ approve
       ↓
4. Admin ตรวจสอบ
   ├── ดู payout รายคน
   ├── ดู breakdown commissions
   ├── กด approve → commissions(status=approved)
   └── กด approve → payout(status=approved)
       ↓
5. จ่ายเงินจริง (manual หรือ auto)
   └── update commissions(status=paid), payout(status=completed)
```

---

## 📅 ตัวอย่างรอบจ่าย

| Period | type | start | end |
|---|---|---|---|
| Jul 2026 | monthly | 2026-07-01 | 2026-07-31 |
| Aug 2026 | monthly | 2026-08-01 | 2026-08-31 |
| W1 Aug | biweekly | 2026-08-01 | 2026-08-14 |
| W2 Aug | biweekly | 2026-08-15 | 2026-08-31 |

---

## 🎯 ตารางทั้งหมด

| ตาราง | ใช้ทำอะไร |
|---|---|
| `users` | Admin dashboard users |
| `user_profiles` | โปรไฟล์ Admin (1:1 กับ users) |
| `customers` | ลูกค้า + MLM tree |
| `line_events` | Log event Line OA |
| `products` | สินค้า + ตั้งค่า PV |
| `orders` / `order_items` | คำสั่งซื้อ |
| `commission_config` | กฎคอมมิชชั่น (referral/binary/matching/level) |
| `binary_volumes` | ยอดฝั่งซ้าย-ขวา (สำหรับ binary tree) |
| `commissions` | ประวัติคอมมิชชั่นที่เกิดขึ้น |
| `commission_payouts` | การจ่ายเงินจริง (รอบจ่าย) |
| `payout_periods` | จัดการรอบจ่าย monthly/biweekly |
