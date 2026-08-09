# Commission Design

## เงื่อนไข Commission (แบบง่าย)

### โครงสร้างต้นไม้

```
A (ชวน B)
  └── B (ชวน C)
        └── C
```

### กฎการจ่าย Commission

| สมาชิกซื้อของ | Direct Sponsor ได้ | Sponsor ของ Sponsor ได้ |
|--------------|-------------------|------------------------|
| **B** ซื้อของ 1 ชิ้น | **A ได้ 10 บาท** | - |
| **C** ซื้อของ 1 ชิ้น | **B ได้ 10 บาท** | **A ได้ 2 บาท** |

### คุณสมบัติสำคัญ

- ✅ **Direct referral = 10 บาท/ชิ้น** (sponsor โดยตรง)
- ✅ **2-level referral = 2 บาท/ชิ้น** (sponsor ของ sponsor)
- ✅ **Admin กำหนด commission ต่อสินค้าได้** (backend configurable)

---

## Commission Flow: 1 Level vs 2 Level vs 3 Level

### โครงสร้างสมาชิก

```
A → B → C → D → E
```

(ลูกศร = "ชวนมา")

### 1 Level (Direct เท่านั้น)

```
E ซื้อของ 1 ชิ้น
  └── D ได้ 10 บาท ✅ (sponsor โดยตรง)
  └── C ได้ 0 ❌
  └── B ได้ 0 ❌
  └── A ได้ 0 ❌
```

**สรุป:** ได้เฉพาะคนชวนตรงเท่านั้น ไม่มี chain

### 2 Level (แบบที่ออกแบบไว้)

```
E ซื้อของ 1 ชิ้น
  └── D ได้ 10 บาท ✅ (L1 — sponsor โดยตรง)
  └── C ได้  2 บาท ✅ (L2 — sponsor ของ sponsor)
  └── B ได้  0 บาท ❌
  └── A ได้  0 บาท ❌
```

**สรุป:** ได้ 2 ชั้น — คนชวนตรง + คนชวนของคนชวน

### 3 Level

```
E ซื้อของ 1 ชิ้น
  └── D ได้ 10 บาท ✅ (L1 — sponsor โดยตรง)
  └── C ได้  2 บาท ✅ (L2 — sponsor ของ sponsor)
  └── B ได้  1 บาท ✅ (L3 — sponsor ระดับ 3)
  └── A ได้  0 บาท ❌
```

**สรุป:** ได้ 3 ชั้น — เพิ่มคนชวนของคนชวนของคนชวน

### เปรียบเทียบค่า commission ต่อสินค้า 1 ชิ้น (ราคาสมมติ 200 บาท)

| Level | ตัวอย่าง | Commission/ชิ้น | ต้นทุนต่อสินค้า |
|-------|---------|-----------------|------------------|
| **1 Level** | E ซื้อ → D ได้ | 10 บาท | 5% |
| **2 Level** | E ซื้อ → D + C ได้ | 10 + 2 = 12 บาท | 6% |
| **3 Level** | E ซื้อ → D + C + B ได้ | 10 + 2 + 1 = 13 บาท | 6.5% |

### ข้อดี-ข้อเสียของแต่ละแบบ

| | 1 Level | 2 Level | 3 Level |
|--|---------|---------|---------|
| **แรงจูงใจชวน** | ⭐⭐ ปานกลาง | ⭐⭐⭐ ดี | ⭐⭐⭐⭐ สูง |
| **แรงจูงใจสร้างทีม** | ❌ ไม่มี | ✅ พอใช้ | ✅✅ ดี |
| **ความซับซ้อน** | ง่ายมาก | ง่าย | ปานกลาง |
| **ต้นทุน commission** | ต่ำสุด | ปานกลาง | สูงสุด |
| **ความเสี่ยง pyramid** | ต่ำ | ปานกลาง | สูงขึ้น |

### แนะนำสำหรับ Newclear

> **2 Level** เหมาะสมที่สุดสำหรับเริ่มต้น — เข้าใจง่าย, ต้นทุนควบคุมได้, ยังมีแรงจูงใจสร้างทีมอยู่
> ถ้าต้องการขยายเป็น 3 Level ภายหลัง ก็เพิ่มแค่ level 3 (เช่น 1 บาท/ชิ้น) — ไม่ต้องเปลี่ยนโครงสร้างหลัก

---

## Database Schema

### 1. ProductCommission Table

```prisma
model ProductCommission {
  id        String   @id @default(uuid())
  productId String   @map("product_id")
  level     Int      // 1 = direct, 2 = sponsor's sponsor
  amount    Decimal  @db.Decimal(10, 2)  // จำนวนเงินต่อชิ้น
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")
  
  product   Product  @relation(fields: [productId], references: [id])
  
  @@unique([productId, level])
  @@map("product_commissions")
}
```

### 2. Commission Table

```prisma
model Commission {
  id            String    @id @default(uuid())
  orderId       String    @map("order_id")
  productId     String    @map("product_id")
  memberId      String    @map("member_id")  // ผู้ได้รับ commission
  sponsorId     String    @map("sponsor_id") // ผู้ที่ชวน
  level         Int       // 1 หรือ 2
  amount        Decimal   @db.Decimal(10, 2)
  status        String    @default("pending") // pending, approved, paid
  createdAt     DateTime  @default(now()) @map("created_at")
  
  order         Order     @relation(fields: [orderId], references: [id])
  product       Product   @relation(fields: [productId], references: [id])
  member        Customer  @relation("CommissionReceiver", fields: [memberId], references: [id])
  sponsor       Customer  @relation("CommissionSponsor", fields: [sponsorId], references: [id])
  
  @@map("commissions")
}
```

---

## Logic Flow

```typescript
// เมื่อมี order ใหม่
async function calculateCommission(order: Order) {
  const buyer = await getCustomerWithSponsor(order.customerId);
  
  for (const item of order.items) {
    // Level 1: Direct sponsor ได้ 10 บาท/ชิ้น
    if (buyer.sponsorId) {
      const commission = await getProductCommission(item.productId, 1);
      await createCommission({
        orderId: order.id,
        productId: item.productId,
        memberId: buyer.sponsorId,
        sponsorId: buyer.sponsorId,
        level: 1,
        amount: commission.amount * item.quantity,
      });
    }
    
    // Level 2: Sponsor ของ sponsor ได้ 2 บาท/ชิ้น
    if (buyer.sponsorId) {
      const sponsor = await getCustomer(buyer.sponsorId);
      if (sponsor.sponsorId) {
        const commission = await getProductCommission(item.productId, 2);
        await createCommission({
          orderId: order.id,
          productId: item.productId,
          memberId: sponsor.sponsorId,
          sponsorId: buyer.sponsorId,
          level: 2,
          amount: commission.amount * item.quantity,
        });
      }
    }
  }
}
```

---

## สิ่งที่ต้องทำ

### Backend API

1. **Product Commission Management**
   - `GET /admin/products/:id/commissions` - ดู commission ของสินค้า
   - `POST /admin/products/:id/commissions` - กำหนด commission (level 1, 2)
   - `PUT /admin/commissions/:id` - แก้ไข commission

2. **Commission Calculation**
   - คำนวณเมื่อมี order ใหม่
   - สร้าง commission records สำหรับ sponsor level 1 และ 2

3. **Commission Dashboard**
   - `GET /members/commissions` - ดู commission ที่ได้รับ
   - `GET /admin/commissions` - ดู commission ทั้งหมด (admin)

### Frontend

1. **Admin Product Management**
   - เพิ่ม UI สำหรับกำหนด commission ต่อสินค้า
   - แสดง commission level 1 และ level 2

2. **Member Commission Dashboard**
   - แสดง commission ที่ได้รับ แยกตาม level
   - สรุปยอดรวม, pending, paid

---

## Commission Flow: 1 Level vs 2 Level vs 3 Level

### โครงสร้างสมาชิก

```
A → B → C → D → E
```

(ลูกศร = "ชวนมา")

### 1 Level (Direct เท่านั้น)

```
E ซื้อของ 1 ชิ้น
  └── D ได้ 10 บาท ✅ (sponsor โดยตรง)
  └── C ได้ 0 ❌
  └── B ได้ 0 ❌
  └── A ได้ 0 ❌
```

**สรุป:** ได้เฉพาะคนชวนตรงเท่านั้น ไม่มี chain

### 2 Level (แบบที่ออกแบบไว้)

```
E ซื้อของ 1 ชิ้น
  └── D ได้ 10 บาท ✅ (L1 — sponsor โดยตรง)
  └── C ได้  2 บาท ✅ (L2 — sponsor ของ sponsor)
  └── B ได้  0 บาท ❌
  └── A ได้  0 บาท ❌
```

**สรุป:** ได้ 2 ชั้น — คนชวนตรง + คนชวนของคนชวน

### 3 Level

```
E ซื้อของ 1 ชิ้น
  └── D ได้ 10 บาท ✅ (L1 — sponsor โดยตรง)
  └── C ได้  2 บาท ✅ (L2 — sponsor ของ sponsor)
  └── B ได้  1 บาท ✅ (L3 — sponsor ระดับ 3)
  └── A ได้  0 บาท ❌
```

**สรุป:** ได้ 3 ชั้น — เพิ่มคนชวนของคนชวนของคนชวน

### เปรียบเทียบค่า commission ต่อสินค้า 1 ชิ้น (ราคาสมมติ 200 บาท)

| Level | ตัวอย่าง | Commission/ชิ้น | ต้นทุนต่อสินค้า |
|-------|---------|-----------------|------------------|
| **1 Level** | E ซื้อ → D ได้ | 10 บาท | 5% |
| **2 Level** | E ซื้อ → D + C ได้ | 10 + 2 = 12 บาท | 6% |
| **3 Level** | E ซื้อ → D + C + B ได้ | 10 + 2 + 1 = 13 บาท | 6.5% |

### ข้อดี-ข้อเสียของแต่ละแบบ

| | 1 Level | 2 Level | 3 Level |
|--|---------|---------|----------|
| **แรงจูงใจชวน** | ⭐⭐ ปานกลาง | ⭐⭐⭐ ดี | ⭐⭐⭐⭐ สูง |
| **แรงจูงใจสร้างทีม** | ❌ ไม่มี | ✅ พอใช้ | ✅✅ ดี |
| **ความซับซ้อน** | ง่ายมาก | ง่าย | ปานกลาง |
| **ต้นทุน commission** | ต่ำสุด | ปานกลาง | สูงสุด |
| **ความเสี่ยง pyramid** | ต่ำ | ปานกลาง | สูงขึ้น |

### แนะนำสำหรับ Newclear

> **2 Level** เหมาะสมที่สุดสำหรับเริ่มต้น — เข้าใจง่าย, ต้นทุนควบคุมได้, ยังมีแรงจูงใจสร้างทีมอยู่

ถ้าต้องการขยายเป็น 3 Level ภายหลัง ก็เพิ่มแค่ level 3 (เช่น 1 บาท/ชิ้น) — ไม่ต้องเปลี่ยนโครงสร้างหลัก

---

**Created:** 2026-08-08 21:21 GMT+7
**Updated:** 2026-08-09 11:20 GMT+7
**Status:** Design phase - ยังไม่เริ่ม implement
