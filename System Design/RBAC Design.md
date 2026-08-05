---
tags:
  - project-newclear
  - system-design
  - rbac
  - security
created: 2026-08-05
---

# RBAC Design — Role Based Access Control

> ระบบสิทธิ์การเข้าถึง admin dashboard สำหรับ **Project Nuclear (เกษตรนิวเคลียร์)**
> ออกแบบให้รองรับ: หลายบทบาท, การแยกหน้าที่ (segregation of duties), และเงิน (commission/payout)

---

## 1. ปัญหาของระบบปัจจุบัน

| ปัญหา | รายละเอียด |
|-------|-----------|
| Role เป็น string เปล่าๆ | `User.role` = `'admin'` / `'superadmin'` เท่านั้น, guard เทียบ string ตรงๆ |
| Binary เกินไป | มีแค่ "ได้หมด" vs "ได้บางส่วน" — ไม่มีระดับกลาง เช่น การเงิน, ซัพพอร์ต |
| ไล่แก้ทุกจุด | เพิ่ม role ใหม่ = ต้องแก้ controller guard + frontend route + sidebar + command menu |
| เงินกับสิทธิ์ปนกัน | อนาคตมี commission/payout — คนตรวจ bank กับคนอนุมัติจ่ายเงิน **ควรแยกคนกัน** |
| Frontend ตรวจเอง | ตอนนี้ frontend ใช้ `role !== 'superadmin'` — เป็น UX ไม่ใช่ security (security ต้องอยู่ที่ API เสมอ) |

## 2. หลักการออกแบบ (Principles)

1. **Least privilege** — ให้สิทธิ์เท่าที่จำเป็นต่องาน
2. **Deny by default** — ไม่มี permission = เข้าไม่ได้
3. **Defense in depth** — API guard คือ security จริง, frontend guard เป็นแค่ UX
4. **Segregation of duties (SoD)** — งานเสี่ยงต้องแยกคน: ตรวจ bank book ≠ อนุมัติจ่ายเงิน
5. **Single source of truth** — permission map อยู่ที่ backend อย่างเดียว, frontend อ่านจาก API

## 3. โมเดล: RBAC (Role → Permission)

### Permission naming convention

```
{module}:{action}

module: customers | bank | users | products | orders | commissions | payouts | reports | settings
action: read | write | approve | manage | export
```

ตัวอย่าง: `customers:read`, `bank:review`, `payouts:approve`, `users:manage`

### Roles ที่เสนอ (4 บทบาท)

| Role | บทบาทในธุรกิจ | คล้าย |
|------|--------------|-------|
| `superadmin` | เจ้าของระบบ — จัดการ user, settings, อนุมัติทุกอย่าง | Owner |
| `admin` | ทีมงานหลัก — ดูแลลูกค้า, ตรวจ bank book, จัดการสินค้า/ออเดอร์ | Manager |
| `finance` | การเงิน — ดู commission, อนุมัติ payout, ดูรายงานการเงิน | Accountant |
| `support` | ซัพพอร์ต — ดูข้อมูลลูกค้า/ออเดอร์ (read-only), แก้ปัญหา LINE | Staff |

> superadmin มี permission `*` (wildcard) — แต่อย่าใช้บัญชีนี้ทำงานประจำ (best practice: สร้าง user แยกตาม role)

### Permission Matrix

| Permission | superadmin | admin | finance | support |
|---|:---:|:---:|:---:|:---:|
| `*` (ทั้งหมด) | ✅ | — | — | — |
| `customers:read` | ✅ | ✅ | ✅ | ✅ |
| `customers:write` | ✅ | ✅ | ❌ | ❌ |
| `bank:review` | ✅ | ✅ | ❌ | ❌ |
| `users:manage` | ✅ | ❌ | ❌ | ❌ |
| `products:manage` | ✅ | ✅ | ❌ | ❌ |
| `orders:read` | ✅ | ✅ | ✅ | ✅ |
| `orders:write` | ✅ | ✅ | ❌ | ❌ |
| `commissions:read` | ✅ | ✅ | ✅ | ❌ |
| `commissions:approve` | ✅ | ❌ | ✅ | ❌ |
| `payouts:approve` | ✅ | ❌ | ✅ | ❌ |
| `reports:read` | ✅ | ✅ | ✅ | ❌ |
| `settings:manage` | ✅ | ❌ | ❌ | ❌ |

> 🔒 **SoD:** `bank:review` (admin) ≠ `payouts:approve` (finance) — ตรวจสอบของกับอนุมัติเงิน ต้องไม่ใช่คนเดียวกัน

## 4. ตัวเลือก Implementation

### Option A — Code-defined map (แนะนำสำหรับตอนนี้) ⭐

- `User.role` เก็บ string เดิม (ไม่ต้อง migration)
- `ROLE_PERMISSIONS: Record<Role, Permission[]>` เป็น constant ในโค้ด (`src/auth/permissions.ts`)
- Guard ใหม่ `PermissionsGuard` + decorator `@RequirePermissions('bank:review')`
- Login ตอบ `user.permissions` กลับไป → frontend เก็บใน zustand

| ข้อดี | ข้อเสีย |
|------|--------|
| ไม่มี migration, เร็ว, เทสต์ง่าย | เปลี่ยน permission ต้อง deploy |
| Guard interface เดียว — อัปเกรดเป็น Option C ได้โดยไม่แตะ controller | ไม่รองรับ multi-role ต่อ user |

### Option B — DB-backed RBAC (ยืดหยุ่นสุด, เผื่ออนาคต)

- ตาราง `roles`, `permissions`, `role_permissions`, `user_roles` (many-to-many)
- Admin UI จัดการ role/permission ได้ runtime

| ข้อดี | ข้อเสีย |
|------|--------|
| เปลี่ยนได้โดยไม่ deploy, multi-role, audit ครบ | งานเยอะ: schema + seed + admin UI + cache invalidation |

### Option C — Hybrid (กลางๆ)

- ตาราง `roles` + `role_permissions` ใน DB (seed ไว้), `User.roleId` FK
- Guard อ่าน permission จาก DB (cache 60s)

| ข้อดี | ข้อเสีย |
|------|--------|
| แก้ permission โดยไม่แตะโค้ด, single role ต่อ user (ง่ายกว่า B) | ต้อง migration + cache layer |

### คำแนะนำ

> **เริ่มที่ Option A** — ระบบเล็ก (admin users ~5 คน), free tier, ไม่มี admin UI สำหรับจัดการสิทธิ์
> Guard interface ออกแบบให้เหมือนกันทั้ง 3 option → ถ้าโปรเจคโตค่อยย้ายไป C โดยแก้แค่ `permissions.ts` เป็น DB query

## 5. Backend Design (Option A)

```
src/auth/
├── permissions.ts                            # enum Role + ROLE_PERMISSIONS map
├── decorators/require-permissions.decorator.ts
├── guards/permissions.guard.ts               # ตัวใหม่
└── guards/roles.guard.ts                     # เดิม — keep ไว้ backward compat
```

### permissions.ts

```ts
export enum Role {
  SUPERADMIN = 'superadmin',
  ADMIN = 'admin',
  FINANCE = 'finance',
  SUPPORT = 'support',
}

export const ROLE_PERMISSIONS: Record<Role, string[]> = {
  [Role.SUPERADMIN]: ['*'],
  [Role.ADMIN]: [
    'customers:read', 'customers:write',
    'bank:review',
    'products:manage',
    'orders:read', 'orders:write',
    'commissions:read',
    'reports:read',
  ],
  [Role.FINANCE]: [
    'customers:read',
    'orders:read',
    'commissions:read', 'commissions:approve',
    'payouts:approve',
    'reports:read',
  ],
  [Role.SUPPORT]: [
    'customers:read',
    'orders:read',
  ],
};
```

### permissions.guard.ts

```ts
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<string[]>(PERMISSIONS_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!required?.length) return true; // ไม่ระบุ = อนุญาต (หลัง JwtAuthGuard)

    const { user } = context.switchToHttp().getRequest();
    const perms = ROLE_PERMISSIONS[user.role as Role] ?? [];
    return required.every((p) => perms.includes('*') || perms.includes(p));
  }
}
```

### ใช้ที่ controller

```ts
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller('customers')
export class CustomerController {
  @Get()
  @RequirePermissions('customers:read')   // แทน @Roles('superadmin') ที่ใช้กันอยู่
  findAll() { ... }

  @Post(':id/bank-review')
  @RequirePermissions('bank:review')
  reviewBank() { ... }
}
```

### Login response เพิ่ม permissions

```json
{
  "access_token": "...",
  "user": {
    "id": "...",
    "username": "admin01",
    "role": "admin",
    "permissions": ["customers:read", "customers:write", "bank:review", "..."]
  }
}
```

> JWT ยังใส่แค่ `role` (token เล็ก) — resolve permission จาก map ทุก request
> (permission map เป็น static → ไม่มีปัญหา stale; ถ้าย้ายเป็น DB-based ค่อยใส่ version/cache)

## 6. Frontend Design

- `auth-store` เพิ่ม `permissions: string[]` — มาจาก login response + `GET /user-profile/me`
- `src/lib/permissions.ts` — helper:

```ts
export function hasPermission(required: string | string[]): boolean {
  const perms = useAuthStore.getState().user?.permissions ?? [];
  const need = Array.isArray(required) ? required : [required];
  return perms.includes('*') || need.every((p) => perms.includes(p));
}
```

- Route guard (`beforeLoad`):

```ts
beforeLoad: () => {
  if (!hasPermission('users:manage')) {
    throw redirect({ to: '/403' })   // หน้า 403 จริง แทน silent redirect หน้าแรก
  }
}
```

- Sidebar / command menu: filter ด้วย `hasPermission()` แทน `role === 'superadmin'`
- Component `<Can permission="payouts:approve">` — ซ่อน/แสดงปุ่มตามสิทธิ์
- หน้า `(errors)/403.tsx` — มีอยู่แล้ว เอามาใช้

## 7. หมายเหตุสำคัญ: Customer ≠ Admin User

- **customers** (สมาชิก, auth ผ่าน LINE) กับ **users** (admin, auth ผ่าน JWT) เป็นคนละ entity กัน
- RBAC นี้ใช้กับ **admin users** เท่านั้น
- อนาคตถ้าให้ลูกค้าเข้าดูข้อมูลตัวเอง (referral tree, commission ของตัวเอง) → ต้องเพิ่ม **resource-level authorization** (object ownership) แยกอีกชั้น:
  - `customer.id === req.user.id` หรือ `customer.referrerId === req.user.id`
  - แนะนำออกแบบเป็น 2 ชั้น: **RBAC (function-level)** + **ownership check (resource-level)**

## 8. Audit Trail (แนะนำ, ทำทีหลังได้)

- ตาราง `audit_logs` — ใคร ทำอะไร เมื่อไหร่ (สำคัญกับเงิน)

```prisma
model AuditLog {
  id         String   @id @default(uuid()) @db.Uuid
  userId     String?  @map("user_id") @db.Uuid
  action     String   @db.VarChar(100)   // e.g. "payouts.approve"
  resource   String?  @db.VarChar(100)   // e.g. "payout:uuid"
  detail     Json?    @db.JsonB
  ip         String?  @db.VarChar(45)
  createdAt  DateTime @default(now()) @map("created_at")

  @@index([userId])
  @@index([action])
  @@map("audit_logs")
}
```

## 9. Tasks (ต่อจาก T117)

- [ ] **T118** 🔴 Backend: `permissions.ts` (enum + ROLE_PERMISSIONS) + `PermissionsGuard` + `@RequirePermissions` decorator
- [ ] **T119** 🔴 Backend: เปลี่ยน controllers ใช้ `@RequirePermissions` (แทน `@Roles` string เทียบตรง)
- [ ] **T120** 🔴 Backend: login response + `GET /user-profile/me` คืน `permissions`
- [ ] **T121** 🟡 Backend: unit tests — guard อนุญาต/ปฏิเสธตาม matrix
- [ ] **T122** 🔴 Frontend: `auth-store` + `hasPermission()` + route guards ใช้ permission
- [ ] **T123** 🟡 Frontend: sidebar + command menu filter ด้วย permission
- [ ] **T124** 🟡 Frontend: `<Can>` component + หน้า 403 (redirect จริง)
- [ ] **T125** 🟢 Docs: อัปเดต api-reference + AGENTS.md + tasks

## 10. สรุปการตัดสินใจ

| Decision | เลือก | เหตุผล |
|----------|------|--------|
| Model | RBAC (role → permission) | ง่ายพอสำหรับ 5 users, ยืดหยุ่นพอสำหรับ 4 roles |
| Implementation | **Option A** (code-defined map) | ไม่ migration, deploy ไว, guard เดียวกันอัปเกรดทีหลังได้ |
| Roles เริ่มต้น | superadmin, admin, finance, support | ครอบคลุมงานจริง + SoD เรื่องเงิน |
| Permission format | `module:action` | อ่านแล้วรู้เรื่อง, grep ได้, extend ได้ |
| Frontend | อ่าน permissions จาก API (ไม่ mirror map) | single source of truth |
| Security boundary | API guard = security, frontend = UX | defense in depth |
| SoD | `bank:review` ≠ `payouts:approve` | กันทุจริตภายใน |

---

## ดูเพิ่มเติม
- [[Overview]] — ภาพรวมระบบ
- [[Database Schema]] — ตารางปัจจุบัน (User.role)
- [[Phase 1 Tasks]] — T118-T125 อยู่ใน backlog
- [[api-reference]] — endpoint ปัจจุบัน
