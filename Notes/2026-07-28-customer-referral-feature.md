# Customer Referral Feature — Solution Design & Tasks

**Feature:** ลูกค้าส่งลิงก์แนะนำเพื่อนสมัครสมาชิก → ได้ commission จากยอดขายของเพื่อน (MLM)

**Date:** 2026-07-28 (Updated: 2026-08-12)  
**Status:** 📝 Designed — pending implementation

> **⚠️ Design Decision (2026-08-12):** เปลี่ยนจากใช้ `referrerId` (UUID) → ใช้ `referrerCode` (customer code เช่น NC00001) ใน URL และ API เพื่อให้ URL สั้น อ่านง่าย แต่ DB schema ยังคงเก็บ `referrerId` (UUID) เป็น FK เดิม

---

## ⚠️ Note: ใช้ referrerCode แทน referrerId

**Decision:** เปลี่ยนจาก `referrerId` (UUID) → `referrerCode` (customer code เช่น NC-001)

**เหตุผล:**
- URL สั้นลง: `/register?referrerCode=NC-001` vs `/register?referrerId=abc123-def456...`
- อ่านง่าย จดจำง่าย
- User-friendly มากขึ้น

**Implementation:** 
- API รับ `referrerCode` (string) → lookup customer by code → ใช้ id สำหรับ FK
- ไม่ต้อง migrate schema (field `referrer_id` ใน DB ยังคงเดิม)
- **Status:** 📝 Designed — ยังไม่ implement code

---

## ✅ สิ่งที่มีพร้อมแล้ว (จาก Schema ปัจจุบัน)

```prisma
model Customer {
  id              String    @id
  referrerId      String?   ✅ มี field นี้แล้ว
  referrer        Customer? ✅ relation หา referrer
  referrals       Customer[] ✅ list คนที่ชวนมา
  placementUpline String?   ✅ สำหรับ binary tree
  position        String?   ✅ "left" / "right"
  treePath        String?   ✅ path string
  downlines       Customer[] ✅ binary children
  binaryVolume    BinaryVolume? ✅ commission volume
  commissions     Commission[] ✅ commission records
}
```

ยืนยัน: **DB Schema พร้อมรับ Referral แล้ว** 🔥

---

## 👣 User Journey

```
Customer A (ลงทะเบียนแล้ว)
  │
  │ กด "🎯 แนะนำเพื่อน" ใน LINE Rich Menu
  ▼
LINE Postback → action=referral
  │
  ▼
Backend LINE Controller:
  ├── หา Customer record จาก lineUserId
  ├── สร้าง Referral Link (ใช้ customer code):
  │   https://project-nuclear-web.vercel.app/register?referrerCode={customer.code}
  └── Reply LINE:
      "🎯 ลิงก์แนะนำเพื่อนของคุณ:
       https://...register?referrerCode=...
       
       แชร์ลิงก์นี้ให้เพื่อน!
       เมื่อเพื่อนสมัครและสั่งซื้อ → คุณได้รับ Commission"
  │
  │ Customer A แชร์ลิงก์ให้ Customer B
  ▼
Customer B เปิดลิงก์ → หน้า Register
  │   ข้อความ: "🎫 แนะนำโดย: Customer A"
  │   referrerCode ถูก pass ไปใน URL
  ▼
Customer B กรอกข้อมูล → Submit
  │
  ▼
POST /api/customers { referrerCode: "NC00001", ... }
  │
  ▼
Backend:
  ├── Lookup customer by referrerCode → ได้ referrerId (UUID)
  ├── 🆕 L1-L4: Identity dedup check (phone/email/idCard/lineUserId)
  ├── └─ เจอ match → ❌ 409 Conflict
  ├── ├─ ไม่เจอ → สร้าง Customer B (referrerId = lookup result)
  ├── Auto-place ใน Binary Tree (side ที่ volume น้อย)
  └── ✅ Response success
```

---

## 🧱 Duplicate Registration Prevention (🆕)

### Problem Statement

> "เมื่อลูกค้าทำการสมัครโดยอยู่ภายใต้ลูกค้าท่านหนึ่งแล้ว ไม่สามารถสมัครอีกได้"

### Scenario

```
1. Customer A แชร์ referral link ให้ Customer B
2. Customer B สมัคร → success (referrerId = A.id)
3. Customer C แชร์ referral link ให้ Customer B
4. Customer B พยายามสมัครอีก → ❌ ต้องโดนปฏิเสธ
```

### 🔍 Identity Sources

| Field | Current | Reliability |
|-------|---------|-------------|
| `lineUserId` | ✅ `@unique` (LINE flow) | 🟢 Strong — เฉพาะคนที่สมัครผ่าน LINE |
| `phone` | ❌ ไม่มี constraint | 🟡 Strong — เบอร์ไทย unique ต่อคน |
| `email` | ❌ ไม่มี constraint | 🟡 Medium — ไม่ใช่ทุกคนมี |
| `idCardNumber` | ❌ ไม่มี constraint | 🟢 **Strongest** — เลขบัตร ปชช. 13 หลัก |
| `firstName + lastName + phone` | ❌ ไม่มี constraint | 🟡 Probabilistic (fuzzy) |

### Solution Architecture: **Layered Dedup (Defense in Depth)**

```
Registration Request
  │
  ├─ L1: lineUserId (ถ้ามีจาก LINE flow)
  │     └─ unique → reject if exists ✅
  │
  ├─ L2: idCardNumber (ถ้ากรอก)
  │     └─ unique → reject if exists ✅
  │
  ├─ L3: phone (ถ้ากรอก)
  │     └─ unique → reject if exists ✅
  │
  ├─ L4: email (ถ้ากรอก)
  │     └─ unique → reject if exists ✅
  │
  └─ L5: Fuzzy check (probabilistic match)
        └─ firstName + lastName + phone partial → log for admin review
```

### 🗄️ Data Model Changes

**Prisma Schema — เพิ่ม UNIQUE constraints:**

```prisma
model Customer {
  // ... existing fields ...
  phone           String?  @unique @db.VarChar(20)        // 🆕 UNIQUE
  email           String?  @unique @db.VarChar(255)       // 🆕 UNIQUE
  idCardNumber    String?  @unique @map("id_card_number") @db.VarChar(20)  // 🆕 UNIQUE
  // ... rest unchanged ...
}
```

**Migration SQL (Neon):**

```sql
CREATE UNIQUE INDEX idx_customers_phone_unique ON customers(phone) WHERE phone IS NOT NULL;
CREATE UNIQUE INDEX idx_customers_email_unique ON customers(email) WHERE email IS NOT NULL;
CREATE UNIQUE INDEX idx_customers_id_card_unique ON customers(id_card_number) WHERE id_card_number IS NOT NULL;
```

### 🔒 Registration Validation Logic

```typescript
async createCustomer(dto: CreateCustomerDto) {
  // ── L1-L4: Duplicate Check ──────────────────────────────
  const { phone, email, idCardNumber, lineUserId } = dto;

  const identityFilters: Prisma.CustomerWhereInput[] = [];

  if (lineUserId) identityFilters.push({ lineUserId });
  if (idCardNumber) identityFilters.push({ idCardNumber });
  if (phone) identityFilters.push({ phone });
  if (email) identityFilters.push({ email });

  if (identityFilters.length > 0) {
    const existing = await this.prisma.customer.findFirst({
      where: { OR: identityFilters },
      select: { id: true, registeredAt: true },
    });

    if (existing) {
      throw new ConflictException({
        message: 'บุคคลนี้ลงทะเบียนแล้วในระบบ',
        detail: 'ไม่สามารถสมัครซ้ำได้ กรุณาตรวจสอบข้อมูลหรือติดต่อเจ้าหน้าที่',
        existingRegistration: { date: existing.registeredAt },
      });
    }
  }

  // ── L5: Fuzzy Check (Optional) ──────────────────────────
  // firstName + lastName + last4phone → log for admin review
  // ...

  return this.prisma.customer.create({ data: { ... } });
}
```

**Error Response (HTTP 409):**

```json
{
  "statusCode": 409,
  "error": "Conflict",
  "message": "บุคคลนี้ลงทะเบียนแล้วในระบบ",
  "detail": "ไม่สามารถสมัครซ้ำได้ กรุณาตรวจสอบข้อมูลหรือติดต่อเจ้าหน้าที่",
  "existingRegistration": {
    "date": "2026-07-28T14:30:00.000Z"
  }
}
```

> ⚠️ **Security:** ไม่บอก field ที่ match — ป้องกัน social engineering

### Prisma Exception Filter — จัดการ Unique Violation (P2002)

```typescript
@Catch(Prisma.PrismaClientKnownRequestError)
export class PrismaClientExceptionFilter implements ExceptionFilter {
  catch(exception: Prisma.PrismaClientKnownRequestError, host: ArgumentsHost) {
    if (exception.code === 'P2002') {
      // Always return generic message — don't expose which field
      response.status(HttpStatus.CONFLICT).json({
        statusCode: 409,
        error: 'Conflict',
        message: 'บุคคลนี้ลงทะเบียนแล้วในระบบ',
        detail: 'ไม่สามารถสมัครซ้ำได้ กรุณาตรวจสอบข้อมูลหรือติดต่อเจ้าหน้าที่',
      });
    }
  }
}
```

### 🖥️ Frontend — จัดการ 409 Conflict

```tsx
const mutation = useMutation({
  mutationFn: (data) => api.post('/api/customers', data),
  onError: (error) => {
    if (error?.response?.status === 409) {
      setError('root', {
        type: 'conflict',
        message: '❌ บุคคลนี้ลงทะเบียนแล้วในระบบ\n'
          + 'ไม่สามารถสมัครซ้ำได้\n\n'
          + '📅 วันที่ลงทะเบียน: '
          + new Date(error.response.data.existingRegistration.date)
              .toLocaleDateString('th-TH')
          + '\n\nหากมีข้อสงสัย ติดต่อเจ้าหน้าที่',
      });
    }
  },
});
```

### 🛡️ Edge Cases

| Case | Handling |
|------|----------|
| NULL fields ต่างกัน → register ผ่าน | ✅ unique constraint รองรับ NULL (PostgreSQL) |
| LINE flow + Web flow คนเดียวกัน (ไม่มี shared field) | ✅ OR query จับทุก field |
| ID Card ซ้ำ (fraud) | ✅ Unique constraint → block |
| Edit profile หลังสมัคร | ✅ Update own record — unique check pass |
| ลบ account (soft delete) → สมัครใหม่ | 🟡 Blocked — ถ้าต้องการ revert ใช้ partial index `WHERE status != 'deleted'` |
| ไม่กรอก identity fields | ✅ ผ่านได้ — **แนะนำให้บังคับเบอร์** |

### Identity Matching Matrix

```
                    Phone     Email     ID Card     LINE ID
Phone               🟢 exact   🟡 match  🟡 match    🟠 indirect
Email               🟡 match   🟢 exact  🟠 indirect  🟠 indirect
ID Card             🟡 match   🟠 indirect 🟢 exact   🟠 indirect
LINE ID             🟠 indirect 🟠 indirect 🟠 indirect 🟢 exact
firstName+lastName  🟡 fuzzy   🟡 fuzzy  🟡 fuzzy    🟡 fuzzy

🟢 = Strong match (unique constraint)
🟡 = Probabilistic (fuzzy check L5)
🟠 = Weak (no direct relation)
```

---

## 🧩 Component Design

### 1. LINE Handler — เพิ่ม case ใน `handlePostback`

```typescript
case 'referral':
  const customer = await this.prisma.customer.findUnique({
    where: { lineUserId }
  });
  if (!customer) {
    reply: "⚠️ กรุณาสมัครสมาชิกก่อนใช้ฟีเจอร์แนะนำเพื่อน"
    return;
  }
  const referralUrl = `https://project-nuclear-web.vercel.app/register?referrerCode=${customer.code}`;
  reply: `🎯 ลิงก์แนะนำเพื่อนของคุณ:\n${referralUrl}\n\nแชร์ลิงก์นี้ให้เพื่อน!\nเมื่อเพื่อนสมัครและซื้อสินค้า → คุณได้รับ Commission`
```

### 2. API Endpoints ที่เกี่ยวข้อง

| Method | Endpoint | Status |
|--------|----------|--------|
| `POST` | `/api/customers` | ✅ มีแล้ว — ต้องแก้ให้รับ `referrerCode` แทน `referrerId` (lookup code → id) |
| `POST` | `/api/customers/me/referral-link` | 📝 ต้องสร้าง (Auth) |
| `POST` | `/api/commissions/calculate` | 📝 ต้องสร้าง |
| `GET` | `/api/customers/me/referrals` | 📝 ดูรายชื่อคนที่ชวนมา |

### 3. Frontend Register Page

ปัจจุบันหน้า `/register` รองรับ `referrerCode` ผ่าน URL params (แทน `referrerId`):
```tsx
const searchSchema = z.object({
  lineUserId: z.string().optional(),
  referrerCode: z.string().optional(),   // ✅ ใช้ customer code แทน UUID
  token: z.string().optional(),
})
```

Backend จะ lookup customer by `referrerCode` → ได้ `referrerId` (UUID) → เก็บเป็น FK ✅

**Optional Enhancement:** แสดงข้อความ "🎫 แนะนำโดย [referrer name]" เมื่อมี `referrerCode` ใน URL

### 4. Binary Tree Auto-Placement Algorithm

```
findPlacement(referrerId):
  if (!referrer.hasLeftChild)
    → place left
  else if (!referrer.hasRightChild)
    → place right
  else if (referrer.leftVolume <= referrer.rightVolume)
    → findPlacement(referrer.leftChildId)
  else
    → findPlacement(referrer.rightChildId)
```

**ข้อมูลเพิ่ม:** ลูกค้าใหม่ลงทะเบียน → `status: "active"`  
แต่ต้องซื้อสินค้าก่อนถึงเริ่มนับ volume → ต่างจาก referral ตรงที่เกิดทันที

### 5. Commission Flow

```
เมื่อ order.status → "paid":
  ┌─ Direct Commission: order.total × config.percentage (1 level)
  ├─ Binary Commission: min(left_vol, right_vol) × config.percentage
  └─ Upline Commission: recursive ขึ้นไป n levels
     → จาก CommissionConfig model
```

---

## 📋 Implementation Tasks (Priority Order)

| # | Task | File/Module | Priority |
|---|------|-------------|----------|
| **🆕** | **DB: เพิ่ม unique constraints (phone, email, idCardNumber)** | `prisma/schema.prisma` | 🔴 High |
| **🆕** | **API: Create PrismaClientExceptionFilter — handle P2002 → 409** | `src/prisma-client-exception.filter.ts` | 🔴 High |
| **🆕** | **API: Identity OR query ใน `createCustomer()`** | `customer.service.ts` | 🔴 High |
| **🆕** | **API: จำกัดข้อมูลใน 409 error response (ไม่บอก field ที่ match)** | `customer.service.ts` | 🟡 Med |
| **🆕** | **Frontend: จัดการ 409 → show error UI** | `register/index.tsx` | 🟡 Med |
| 1 | เพิ่ม `case 'referral'` ใน `LineService.handlePostback()` | `line.service.ts` | 🔴 High |
| 2 | สร้าง `CustomerService.getReferralLink(customerId)` | `customer.service.ts` | 🔴 High |
| 3 | Reply LINE → referral link + invite text | `line.service.ts` | 🔴 High |
| 4 | เพิ่มปุ่ม "🎯 แนะนำเพื่อน" ใน Rich Menu | LINE Dev Console | 🔴 High |
| 5 | Frontend: เปลี่ยนจาก `referrerId` → `referrerCode` ใน URL + แสดง "แนะนำโดย" | `register/index.tsx` | 🟡 Med |
| 6 | Binary Tree Auto-Placement Algorithm | `customer.service.ts` | 🟡 Med |
| 7 | Commission Calculation เมื่อ order paid | `commission.service.ts` | 🟡 Med |
| 8 | API: `GET /api/customers/me/referrals` | `customer.controller.ts` | 🟡 Med |
| 9 | API: `POST /api/customers/me/referral-link` | `customer.controller.ts` | 🟢 Low |
| 10 | Share text optimization (LINE Flex Message) | `line.service.ts` | 🟢 Low |

---

## 💡 Trade-offs & Considerations

| ตัวเลือก | ข้อดี | ข้อเสีย |
|----------|------|---------|
| **ใช้ customer.id (UUID)** ในลิงก์ | ไม่ต้อง gen referral code เพิ่ม | URL ยาว |
| **สร้าง Referral Code สั้น** | URL สั้น, สวย | ต้อง gen + manage |
| **Auto-place binary tree** | User ไม่ต้องคิด | Algorithm ซับซ้อน |
| **ให้เลือกตำแหน่งเอง** | User control | UX เพิ่มขั้น |
| **Unique constraint** | DB-level safety, performance | ต้อง migrate |
| **Partial index (`WHERE NOT deleted`)** | รองรับ soft delete | Complex เพิ่ม |
| **OR query dedup** | จับทุก field match | Query complexity |
| **Fuzzy check (L5)** | จับ false negative | False positive — ต้อง human review |

**แนะนำ:** เริ่มด้วย UUID ก่อน → optimize ทีหลัง  
**แนะนำ:** Unique constraint + OR query ก่อน → Fuzzy check phase ทีหลัง

> **📝 Design Update (2026-08-12):**  
> เปลี่ยนจากใช้ `referrerId` (UUID) → ใช้ `referrerCode` (customer code) ใน URL และ API  
> **เหตุผล:** URL สั้นลง อ่านง่าย  
> **Implementation:**  
> - URL: `/register?referrerCode=NC00001` (แทน `/register?referrerId=abc123-def456...`)  
> - API: รับ `referrerCode` → lookup customer → ใช้ `referrerId` (UUID) เป็น FK  
> - DB Schema: ไม่ต้องแก้ (ยังคง `referrer_id` UUID)  
> - **Status:** 📝 Designed — ยังไม่ implement

---

## 📌 หมายเหตุ

- รอ LINE Platform Outage (status.line-platform.com) หายก่อนถึงทดสอบ LINE flow ได้
- Frontend register page เปิด `?referrerCode=` ได้แล้ว — ทดสอบผ่าน browser ได้เลย
- Customer schema มี `referrerId` พร้อมแล้ว — ไม่ต้อง migrate DB เพิ่มสำหรับ referral
- **ต้อง migrate DB สำหรับ unique constraints** (phone, email, idCardNumber)
- แนะนำให้ **บังคับกรอกเบอร์โทรศัพท์** ตอนสมัครเพื่อ identity anchor ที่แน่นอน
