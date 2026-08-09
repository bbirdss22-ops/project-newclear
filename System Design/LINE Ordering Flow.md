# LINE Ordering Flow

## Overview

ลูกค้าสั่งสินค้าผ่าน LINE OA โดยใช้ customer code
สินค้าและสต๊อกจัดการภายนอก Newclear ทำหน้าที่ track order + คำนวณ commission

---

## Flow Diagram

```
┌─────────┐         ┌─────────┐         ┌─────────┐
│ Customer│         │  LINE   │         │Newclear │
│ (LINE)  │         │   OA    │         │  API    │
└────┬────┘         └────┬────┘         └────┬────┘
     │                   │                   │
     │ "สั่งซื้อ คอลูกซ่า 2 ถุง"  │                   │
     │ code: NC-001      │                   │
     │──────────────────▶│                   │
     │                   │                   │
     │                   │ POST /orders      │
     │                   │──────────────────▶│
     │                   │                   │
     │                   │                   │ 1. Lookup customer by code
     │                   │                   │ 2. Check product exists
     │                   │                   │ 3. Create order (status: pending)
     │                   │                   │
     │                   │    "✅ รับออเดอร์  │
     │                   │     ORD-001       │
     │                   │     รอแอดมินยืนยัน"│
     │◀──────────────────│◀──────────────────│
     │                   │                   │
     │                   │                   │
     │                   │     Admin confirm │
     │                   │◀──────────────────│
     │                   │                   │
     │                   │                   │ 4. Calculate commission
     │                   │                   │ 5. Create Commission records
     │                   │                   │ 6. Update order status
     │                   │                   │
     │ "✅ ออเดอร์ยืนยันแล้ว │                   │
     │  ยอดรวม 600 บาท"   │                   │
     │◀──────────────────│◀──────────────────│
```

---

## LINE Commands

### Customer Commands

| Command | Example | Description |
|---------|---------|-------------|
| `สั่งซื้อ <product> <qty>` | `สั่งซื้อ คอลูกซ่า 2 ถุง` | สร้างออเดอร์ใหม่ |
| `สั่งซื้อ code:<code> <product> <qty>` | `สั่งซื้อ code:NC-001 คอลูกซ่า 2` | ระบุ customer code |
| `รายการสั่งซื้อ` | `รายการสั่งซื้อ` | ดูออเดอร์ของตัวเอง |
| `สถานะ <orderNo>` | `สถานะ ORD-001` | เช็คสถานะออเดอร์ |

### Admin Commands

| Command | Example | Description |
|---------|---------|-------------|
| `ยืนยัน <orderNo>` | `ยืนยัน ORD-001` | ยืนยันออเดอร์ → คำนวณ commission |
| `ยกเลิก <orderNo> <reason>` | `ยกเลิก ORD-001 สินค้าหมด` | ยกเลิกออเดอร์ |
| `รายการรอ` | `รายการรอ` | ดูออเดอร์ที่รอยืนยัน |

---

## Order Status

```
pending → confirmed → shipped → completed
                ↓
           cancelled
```

| Status | Description | Commission |
|--------|-------------|------------|
| `pending` | รอแอดมินยืนยัน | ยังไม่คำนวณ |
| `confirmed` | แอดมินยืนยันแล้ว | ✅ คำนวณแล้ว |
| `shipped` | ส่งของแล้ว | - |
| `completed` | เสร็จสมบูรณ์ | - |
| `cancelled` | ยกเลิก | ❌ ลบ commission |

---

## Commission Calculation

**Trigger:** เมื่อ admin กด `ยืนยัน` ออเดอร์

**Logic:**
```
for each item in order:
  for level 1 (direct sponsor):
    commission = productCommission.level1Rate * item.quantity
    create Commission record for customer.sponsor
  
  for level 2 (sponsor's sponsor):
    commission = productCommission.level2Rate * item.quantity
    create Commission record for customer.sponsor.sponsor
```

**Example:**
```
Order: คอลูกซ่า x2 (productComm: L1=10, L2=2)

Commission:
  - Sponsor ของลูกค้า: 10 * 2 = 20 บาท (L1)
  - Sponsor ของ sponsor: 2 * 2 = 4 บาท (L2)
```

---

## Product in Newclear

Newclear เก็บ product data เพื่อคำนวณ commission เท่านั้น
(สต๊อก/ราคาจริง = external system)

```prisma
model Product {
  id          String   @id @default(uuid())
  code        String   @unique           // product code/sku
  name        String
  price       Decimal                    // ราคา (reference)
  commRateL1  Decimal?                   // commission L1 (บาท/ชิ้น)
  commRateL2  Decimal?                   // commission L2 (บาท/ชิ้น)
  isActive    Boolean  @default(true)
}
```

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| ลูกค้าไม่มีในระบบ | Bot แจ้ง "ไม่พบ customer code นี้ กรุณาสมัครสมาชิก" |
| สินค้าไม่มีใน Newclear | Bot แจ้ง "ไม่พบสินค้านี้ในระบบ" |
| สินค้าไม่มี commission config | สร้างออเดอร์ได้ แต่ไม่คำนวณ commission |
| Customer code ซ้ำ (LINE + manual) | ใช้ code เดิม, link กับ LINE user |
| Admin ยกเลิกออเดอร์ | ลบ commission records ที่สร้างไว้ |
| ลูกค้าสั่งซ้ำ (duplicate) | ระบบตรวจ orderNo ซ้ำ |

---

## Admin Dashboard

### Order Management Page

- ตารางออเดอร์ทั้งหมด (filter: status, date, customer)
- ปุ่ม `ยืนยัน` / `ยกเลิก` สำหรับ pending orders
- ดูรายละเอียด: รายการสินค้า, customer info, sponsor chain
- แสดง commission ที่จะจ่ายก่อนยืนยัน

### Product Management Page

- เพิ่ม/แก้ไขสินค้า (code, name, price, commission rates)
- CSV import สำหรับ bulk upload
- Preview: "ถ้าขาย 1 ชิ้น → L1 ได้ X, L2 ได้ Y"

---

## Notification Flow

| Event | Customer | Sponsor | Admin |
|-------|----------|---------|-------|
| สร้างออเดอร์ | ✅ | - | ✅ |
| ยืนยันออเดอร์ | ✅ | - | - |
| คำนวณ commission | - | ✅ "คุณได้ค่าคอม X บาท" | ✅ |
| ยกเลิกออเดอร์ | ✅ | - | - |

---

## Future Enhancements

- [ ] Rich menu ใน LINE สำหรับสั่งซื้อ
- [ ] Order history ใน dashboard
- [ ] Bulk confirm orders
- [ ] Auto-ship status sync (ถ้า external system มี webhook)
- [ ] Commission payout integration

---

**Created:** 2026-08-09 17:20 GMT+7
**Status:** Design phase
**Related:** [[Commission Design]], [[Commission Tasks]]
