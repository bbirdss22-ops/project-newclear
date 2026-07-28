# Customer Referral Feature — Solution Design & Tasks

**Feature:** ลูกค้าส่งลิงก์แนะนำเพื่อนสมัครสมาชิก → ได้ commission จากยอดขายของเพื่อน (MLM)

**Date:** 2026-07-28  
**Status:** 📝 Designed — pending implementation

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
  ├── สร้าง Referral Link:
  │   https://project-nuclear-web.vercel.app/register?referrerId={customer.id}
  └── Reply LINE:
      "🎯 ลิงก์แนะนำเพื่อนของคุณ:
       https://...register?referrerId=...
       
       แชร์ลิงก์นี้ให้เพื่อน!
       เมื่อเพื่อนสมัครและสั่งซื้อ → คุณได้รับ Commission"
  │
  │ Customer A แชร์ลิงก์ให้ Customer B
  ▼
Customer B เปิดลิงก์ → หน้า Register
  │   ข้อความ: "🎫 แนะนำโดย: Customer A"
  │   referrerId ถูก pass ไปใน URL
  ▼
Customer B กรอกข้อมูล → Submit
  │
  ▼
POST /api/customers { referrerId: A.id, ... }
  │
  ▼
Backend:
  ├── สร้าง Customer B (referrerId = A.id)
  ├── Auto-place ใน Binary Tree (side ที่ volume น้อย)
  └── ✅ Response success
```

---

## 🧩 Component Design

### 1. LINE Handler — เพิ่ม case ใน `handlePostback`

```typescript
case 'referral':
  // 1. หา Customer จาก lineUserId
  const customer = await this.prisma.customer.findUnique({
    where: { lineUserId }
  });
  if (!customer) {
    reply: "⚠️ กรุณาสมัครสมาชิกก่อนใช้ฟีเจอร์แนะนำเพื่อน"
    return;
  }
  // 2. สร้าง referral link
  const referralUrl = `https://project-nuclear-web.vercel.app/register?referrerId=${customer.id}`;
  // 3. Reply LINE
  reply: `🎯 ลิงก์แนะนำเพื่อนของคุณ:\n${referralUrl}\n\nแชร์ลิงก์นี้ให้เพื่อน!\nเมื่อเพื่อนสมัครและซื้อสินค้า → คุณได้รับ Commission`
```

### 2. API Endpoints ที่เกี่ยวข้อง

| Method | Endpoint | Status |
|--------|----------|--------|
| `POST` | `/api/customers/me/referral-link` | 📝 ต้องสร้าง (Auth) |
| `POST` | `/api/customers` | ✅ มีแล้ว — รองรับ `referrerId` |
| `POST` | `/api/commissions/calculate` | 📝 ต้องสร้าง |
| `GET` | `/api/customers/me/referrals` | 📝 ดูรายชื่อคนที่ชวนมา |

### 3. Frontend Register Page

ปัจจุบันหน้า `/register` รองรับ `referrerId` อยู่แล้วผ่าน URL params:
```tsx
const searchSchema = z.object({
  lineUserId: z.string().optional(),
  referrerId: z.string().optional(),   // ✅ พร้อม
  token: z.string().optional(),
})
```

Form ส่ง `referrerId` ไปกับ `createCustomer` API → ลง DB อัตโนมัติ ✅

**Optional Enhancement:** แสดงข้อความ "🎫 แนะนำโดย [referrer name]" เมื่อมี `referrerId` ใน URL

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
| 1 | เพิ่ม `case 'referral'` ใน `LineService.handlePostback()` | `line.service.ts` | 🔴 High |
| 2 | สร้าง `CustomerService.getReferralLink(customerId)` | `customer.service.ts` | 🔴 High |
| 3 | Reply LINE → referral link + invite text | `line.service.ts` | 🔴 High |
| 4 | เพิ่มปุ่ม "🎯 แนะนำเพื่อน" ใน Rich Menu | LINE Dev Console | 🔴 High |
| 5 | Frontend: แสดง "แนะนำโดย" เมื่อมี `referrerId` | `register/index.tsx` | 🟡 Med |
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

**แนะนำ:** เริ่มด้วย UUID ก่อน → optimize ทีหลัง

---

## 📌 หมายเหตุ

- รอ LINE Platform Outage (status.line-platform.com) หายก่อนถึงทดสอบ LINE flow ได้
- Frontend register page เปิด `?referrerId=` ได้แล้ว — ทดสอบผ่าน browser ได้เลย
- Customer schema มี `referrerId` พร้อมแล้ว — ไม่ต้อง migrate DB เพิ่ม
