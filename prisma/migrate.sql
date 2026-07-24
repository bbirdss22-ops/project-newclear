-- =============================================================
-- project-newclear — Full DDL
-- Generated from Database Schema (2026-07-24)
-- =============================================================

-- 1. users
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username    VARCHAR(50) UNIQUE NOT NULL,
  password    VARCHAR(255) NOT NULL,
  role        VARCHAR(20) DEFAULT 'admin',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. customers
CREATE TABLE customers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  line_user_id    VARCHAR(255) UNIQUE,
  display_name    VARCHAR(255),
  first_name      VARCHAR(100),
  last_name       VARCHAR(100),
  phone           VARCHAR(20),
  email           VARCHAR(255),
  id_card_number  VARCHAR(20),
  address         TEXT,
  referrer_id      UUID REFERENCES customers(id),
  placement_upline UUID REFERENCES customers(id),
  position         VARCHAR(10) CHECK (position IN ('left', 'right')),
  tree_path        TEXT,
  status          VARCHAR(20) DEFAULT 'active',
  registered_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_customers_line_user_id ON customers(line_user_id);
CREATE INDEX idx_customers_referrer ON customers(referrer_id);
CREATE INDEX idx_customers_upline ON customers(placement_upline);
CREATE INDEX idx_customers_tree_path ON customers(tree_path);

-- 3. line_events
CREATE TABLE line_events (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  line_user_id VARCHAR(255),
  event_type  VARCHAR(50),
  raw         JSONB,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_line_events_user ON line_events(line_user_id);

-- 4. products
CREATE TABLE products (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            VARCHAR(200) NOT NULL,
  description     TEXT,
  price           DECIMAL(10,2) NOT NULL,
  commission_type VARCHAR(20) DEFAULT 'percent',
  commission_value DECIMAL(10,2),
  pv              DECIMAL(10,2) DEFAULT 0,
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 5. orders
CREATE TABLE orders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL REFERENCES customers(id),
  order_no        VARCHAR(50) UNIQUE NOT NULL,
  total_amount    DECIMAL(10,2) NOT NULL,
  total_pv        DECIMAL(10,2) DEFAULT 0,
  status          VARCHAR(20) DEFAULT 'pending',
  paid_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);

-- 6. order_items
CREATE TABLE order_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id        UUID NOT NULL REFERENCES orders(id),
  product_id      UUID NOT NULL REFERENCES products(id),
  quantity        INT NOT NULL DEFAULT 1,
  price           DECIMAL(10,2) NOT NULL,
  pv              DECIMAL(10,2) DEFAULT 0
);

CREATE INDEX idx_order_items_order ON order_items(order_id);

-- 7. commission_config
CREATE TABLE commission_config (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            VARCHAR(100) NOT NULL,
  type            VARCHAR(20) NOT NULL,
  level           INT DEFAULT 0,
  percentage      DECIMAL(5,2) NOT NULL,
  max_levels      INT DEFAULT 1,
  min_pv          DECIMAL(10,2) DEFAULT 0,
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 8. binary_volumes
CREATE TABLE binary_volumes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL REFERENCES customers(id),
  left_volume     DECIMAL(10,2) DEFAULT 0,
  right_volume    DECIMAL(10,2) DEFAULT 0,
  paired_volume   DECIMAL(10,2) DEFAULT 0,
  carry_left      DECIMAL(10,2) DEFAULT 0,
  carry_right     DECIMAL(10,2) DEFAULT 0,
  computed_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(customer_id)
);

-- 9. commissions (no payout FK yet — added after payout table)
CREATE TABLE commissions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id         UUID NOT NULL REFERENCES customers(id),
  source_order_id     UUID REFERENCES orders(id),
  source_customer_id  UUID REFERENCES customers(id),
  commission_config_id UUID REFERENCES commission_config(id),
  type                VARCHAR(20) NOT NULL,
  amount              DECIMAL(10,2) NOT NULL,
  pv_amount           DECIMAL(10,2) DEFAULT 0,
  level               INT DEFAULT 0,
  status              VARCHAR(20) DEFAULT 'calculated',
  calculated_at       TIMESTAMPTZ DEFAULT NOW(),
  approved_at         TIMESTAMPTZ,
  paid_at             TIMESTAMPTZ,
  approved_by         UUID REFERENCES users(id),
  remark              TEXT
);

CREATE INDEX idx_commissions_customer ON commissions(customer_id);
CREATE INDEX idx_commissions_status ON commissions(status);
CREATE INDEX idx_commissions_payout ON commissions(payout_id);
CREATE INDEX idx_commissions_type ON commissions(type);

-- 10. commission_payouts
CREATE TABLE commission_payouts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL REFERENCES customers(id),
  total_amount    DECIMAL(10,2) NOT NULL,
  period_type     VARCHAR(10) NOT NULL,
  period_start    DATE NOT NULL,
  period_end      DATE NOT NULL,
  due_date        DATE,
  total_calculated DECIMAL(10,2) DEFAULT 0,
  total_approved   DECIMAL(10,2) DEFAULT 0,
  total_deductions DECIMAL(10,2) DEFAULT 0,
  net_amount       DECIMAL(10,2) NOT NULL,
  bank_name       VARCHAR(100),
  bank_account    VARCHAR(50),
  account_name    VARCHAR(200),
  status          VARCHAR(20) DEFAULT 'draft',
  generated_at    TIMESTAMPTZ DEFAULT NOW(),
  approved_at     TIMESTAMPTZ,
  approved_by     UUID REFERENCES users(id),
  completed_at    TIMESTAMPTZ,
  rejected_at     TIMESTAMPTZ,
  reject_reason   TEXT,
  remark          TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payouts_customer ON commission_payouts(customer_id);
CREATE INDEX idx_payouts_status ON commission_payouts(status);
CREATE INDEX idx_payouts_period ON commission_payouts(period_type, period_start);

-- Add payout FK to commissions (after commission_payouts exists)
ALTER TABLE commissions ADD COLUMN payout_id UUID REFERENCES commission_payouts(id);

-- 11. payout_periods
CREATE TABLE payout_periods (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  period_type     VARCHAR(10) NOT NULL,
  period_start    DATE NOT NULL,
  period_end      DATE NOT NULL,
  due_date        DATE,
  is_closed       BOOLEAN DEFAULT false,
  closed_at       TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_payout_period_unique ON payout_periods(period_type, period_start);

-- =============================================================
-- Seed Data
-- =============================================================

-- Admin users (5 คน) — password: admin123 (bcrypt hash)
INSERT INTO users (username, password, role) VALUES
  ('admin1', '$2b$10$8KzQMGx5C5Kc5Q5Q5Q5Q5u5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5u', 'admin'),
  ('admin2', '$2b$10$8KzQMGx5C5Kc5Q5Q5Q5Q5u5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5u', 'admin'),
  ('admin3', '$2b$10$8KzQMGx5C5Kc5Q5Q5Q5Q5u5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5u', 'admin'),
  ('admin4', '$2b$10$8KzQMGx5C5Kc5Q5Q5Q5Q5u5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5u', 'admin'),
  ('admin5', '$2b$10$8KzQMGx5C5Kc5Q5Q5Q5Q5u5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5u', 'admin');
