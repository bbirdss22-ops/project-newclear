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

**Created:** 2026-08-08 21:21 GMT+7
**Status:** Design phase - ยังไม่เริ่ม implement
