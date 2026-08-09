# Commission Implementation Tasks

## Phase 1: Backend — Schema & Core Logic

### T1: Prisma Schema
- [ ] เพิ่ม `ProductCommission` table (productId, level, amount)
- [ ] เพิ่ม `Commission` table (orderId, productId, memberId, sponsorId, level, amount, status)
- [ ] เพิ่ม relations: Product → ProductCommission, Customer → commissions earned/paid
- [ ] Run migration

### T2: ProductCommission API (Admin)
- [ ] `GET /admin/products/:id/commissions` — ดู config commission ของสินค้า
- [ ] `POST /admin/products/:id/commissions` — ตั้งค่า level 1, 2
- [ ] `PUT /admin/commissions/:id` — แก้ไข rate
- [ ] Validation: amount ต้อง >= 0, level ต้องเป็น 1 หรือ 2

### T3: Commission Calculation Logic
- [ ] สร้าง `commission.service.ts` ใน API
- [ ] Hook เข้า order creation → คำนวณ commission อัตโนมัติ
- [ ] Walk up sponsor chain 2 levels
- [ ] ใช้ ProductCommission config หา amount ต่อชิ้น
- [ ] สร้าง Commission records (level 1 + level 2)
- [ ] Handle edge cases: ไม่มี sponsor, สินค้าไม่มี config, quantity > 1

### T4: Commission History API
- [ ] `GET /members/commissions` — ดูรายได้ตัวเอง (pending/approved/paid)
- [ ] `GET /admin/commissions` — ดูทั้งหมด (filter by member, date, status)
- [ ] `GET /members/commissions/summary` — สรุป: วันนี้/สัปดาห์นี้/เดือนนี้

---

## Phase 2: Frontend — Admin & Member UI

### T5: Admin Product Commission Settings
- [ ] เพิ่ม section ในหน้า Product Detail/Edit
- [ ] Form: Level 1 (บาท/ชิ้น), Level 2 (บาท/ชิ้น)
- [ ] แสดง preview: "ถ้าขาย 1 ชิ้น → sponsor ได้ X, sponsor ของ sponsor ได้ Y"
- [ ] Bulk set: ตั้งค่าหลายสินค้าพร้อมกัน (optional)

### T6: Admin Commission Dashboard
- [ ] หน้าดู commission ทั้งหมด (table + filter)
- [ ] Filter: status, member, date range
- [ ] Export CSV (optional)
- [ ] แสดงยอดรวม: pending, approved, paid

### T7: Member Commission Dashboard
- [ ] Summary cards: วันนี้/สัปดาห์นี้/เดือนนี้/ทั้งหมด
- [ ] ตารางรายการ commission (จากใคร, สินค้าอะไร, ระดับไหน, จำนวนเงิน)
- [ ] Filter: status, date
- [ ] แสดง sponsor chain (ใครชวนใคร)

---

## Phase 3: Referral & Polish

### T8: Referral Tree UI
- [ ] แสดง tree structure (ใครชวนใคร)
- [ ] คลิกดูรายละเอียดสมาชิก
- [ ] แสดงจำนวน direct/indirect referrals

### T9: Commission Payout (optional, Phase 3)
- [ ] Admin approve/payout commissions
- [ ] Mark as paid
- [ ] Notification ผ่าน LINE เมื่อได้เงิน

---

## Dependencies

```
T1 → T2 → T3 → T4
              ↓
         T5 (Admin UI)
         T6 (Admin Dashboard)
         T7 (Member Dashboard)
              ↓
         T8 (Referral Tree)
         T9 (Payout)
```

## Priority

| Task | Priority | Effort |
|------|----------|--------|
| T1: Schema | 🔴 High | 1-2 ชม. |
| T2: ProductCommission API | 🔴 High | 2-3 ชม. |
| T3: Calc Logic | 🔴 High | 3-4 ชม. |
| T4: History API | 🟡 Medium | 2-3 ชม. |
| T5: Admin Settings UI | 🟡 Medium | 3-4 ชม. |
| T6: Admin Dashboard | 🟡 Medium | 3-4 ชม. |
| T7: Member Dashboard | 🟡 Medium | 3-4 ชม. |
| T8: Referral Tree | 🟢 Low | 4-5 ชม. |
| T9: Payout | 🟢 Low | 4-5 ชม. |

**รวม Phase 1+2:** ~20-25 ชม. (ประมาณ 3-4 วัน)

---

**Created:** 2026-08-09 17:04 GMT+7
**Status:** Planning
