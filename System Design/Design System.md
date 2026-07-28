---
tags:
  - project-newclear
  - design-system
  - kaset-nuclear
  - ui
created: 2026-07-28
updated: 2026-07-28
---

# Design System — เกษตรนิวเคลียร์ 🌿

> Design system สำหรับระบบบริหารสมาชิกและเครือข่าย MLM ของ **เกษตรนิวเคลียร์**

---

## 🎨 Brand Identity

### โลโก้
- **ตรานิวเคลียร์** — ตัวการ์ตูนระเบิดสีเขียว สวมเข็มขัด NUCLEAR
- ใช้เป็น logo ทั้งใน sidebar, login page, favicon

### ชื่อแบรนด์
- **ไทย:** เกษตรนิวเคลียร์
- **อังกฤษ:** Kaset Nuclear
- **คำอธิบาย:** วัสดุปรับปรุงดิน — ดินดี พืชดี ผลผลิตดี

### Slogan
```
ดินดี พืชดี ผลผลิตดี
```

---

## 🧱 Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI Framework** | React 19 + TypeScript |
| **Build Tool** | Vite 6 |
| **Routing** | TanStack Router |
| **State** | Zustand |
| **Styling** | Tailwind CSS v4 |
| **UI Components** | shadcn/ui (Radix Primitives) |
| **Forms** | react-hook-form + Zod |
| **HTTP** | Axios |
| **Dark Mode** | Custom ThemeProvider (system/light/dark) |
| **Backend** | NestJS (Prisma ORM) |
| **Auth** | JWT (access token) |

---

## 🎨 Color System

ใช้ **OKLCH** color space เพื่อความ smooth ทั้ง light และ dark mode

### Light Mode (`:root`)

| Token | Value | Usage |
|-------|-------|-------|
| `--background` | `oklch(0.99 0.004 120)` | พื้นหลังหลัก |
| `--foreground` | `oklch(0.15 0.02 145)` | ตัวอักษรหลัก |
| `--primary` | `oklch(0.45 0.14 145)` | สีหลัก (ปุ่ม, active) |
| `--primary-foreground` | `oklch(0.98 0.003 247)` | ตัวอักษรบน primary |
| `--secondary` | `oklch(0.92 0.03 145)` | สีรอง |
| `--accent` | `oklch(0.92 0.03 145)` | สี accent |
| `--muted` | `oklch(0.94 0.02 145)` | สีอ่อน |
| `--destructive` | `oklch(0.58 0.24 27)` | สีอันตราย |
| `--card` | `oklch(0.98 0.006 120)` | พื้นหลังการ์ด |
| `--border` | `oklch(0.88 0.02 145)` | เส้นขอบ |

### Dark Mode (`.dark`)

| Token | Value | Usage |
|-------|-------|-------|
| `--background` | `oklch(0.13 0.02 145)` | พื้นหลังหลัก |
| `--foreground` | `oklch(0.95 0.01 120)` | ตัวอักษรหลัก |
| `--primary` | `oklch(0.65 0.15 145)` | สีหลัก |
| `--primary-foreground` | `oklch(0.13 0.02 145)` | ตัวอักษรบน primary |
| `--secondary` | `oklch(0.25 0.04 145)` | สีรอง |
| `--accent` | `oklch(0.25 0.04 145)` | สี accent |
| `--muted` | `oklch(0.22 0.03 145)` | สีอ่อน |
| `--card` | `oklch(0.18 0.025 145)` | พื้นหลังการ์ด |

### สี Chart

ใช้สำหรับกราฟและสถิติใน dashboard:

- `--chart-1`: เขียวเข้ม `oklch(0.55 0.18 145)`
- `--chart-2`: เขียวฟ้า `oklch(0.6 0.12 165)`
- `--chart-3`: เขียวเหลือง `oklch(0.48 0.1 130)`
- `--chart-4`: เหลือง `oklch(0.7 0.15 100)`
- `--chart-5`: ฟ้าเขียว `oklch(0.65 0.12 180)`

### Radius

- `--radius`: `0.625rem` (10px)
- `--radius-sm`: `calc(var(--radius) - 4px)`
- `--radius-md`: `calc(var(--radius) - 2px)`
- `--radius-lg`: `var(--radius)`
- `--radius-xl`: `calc(var(--radius) + 4px)`

---

## 🔤 Typography

| Family | Name | Usage |
|--------|------|-------|
| **Inter** | Sans-serif | ตัวอักษรหลักทั่วไป |
| **Manrope** | Sans-serif | หัวข้อ, จุดเด่น |

```css
--font-inter: 'Inter', 'sans-serif';
--font-manrope: 'Manrope', 'sans-serif';
```

---

## 🧩 Components

ใช้ **shadcn/ui** (Radix Primitives + Tailwind CSS) เป็นหลัก:

| Component | Source |
|-----------|--------|
| Button | shadcn/ui |
| Input | shadcn/ui |
| Card | shadcn/ui |
| Sidebar | shadcn/ui |
| Table | shadcn/ui |
| Form | react-hook-form + shadcn/ui |
| Dialog/Modal | shadcn/ui |
| Dropdown Menu | shadcn/ui |
| Avatar | shadcn/ui |
| Badge | shadcn/ui |
| Select | shadcn/ui |
| Toast | Sonner |
| Password Input | custom wrapper |

---

## 📐 Layout

### Dashboard Layout
- **Sidebar:** คงที่ทางซ้าย (256px)
  - Team switcher: เกษตรนิวเคลียร์ 🏢
  - Nav: Dashboard / Customers / Change Password
- **Content Area:** ส่วนที่เหลือ
  - Top bar: App title + Profile dropdown
  - Main content: scrollable

### Auth Layout
- จอเต็มตรงกลาง
- โลโก้ + ชื่อระบบ "เกษตรนิวเคลียร์"
- Card login form

---

## 🔐 Forms

ใช้ **react-hook-form** + **Zod** schema validation:

```typescript
const formSchema = z.object({
  username: z.string().min(1, 'Please enter your username.'),
  password: z.string().min(7, 'Password must be at least 7 characters.'),
})
```

### Registration Form Fields
| Field | Type | Validation |
|-------|------|------------|
| firstName | Text | Required |
| lastName | Text | Required |
| phone | Text | Required |
| email | Text | Optional, email format |
| idCardNumber | Text | Optional |
| address | Textarea | Optional |

---

## 🌓 Theme System

- **Custom ThemeProvider** (ไม่ใช้ next-themes)
- เก็บ theme ใน cookie (ชื่อ `vite-ui-theme`)
- 3 modes: `light` | `dark` | `system`
- Default: `system`
- CSS class: `.light` หรือ `.dark` ที่ `<html>`
- Toggle: Config drawer + Settings page

---

## 🖼️ ตัวอย่าง UI

### หน้า Login
```
[ โลโก้  เกษตรนิวเคลียร์ ]
┌──────────────────────┐
│ Username             │
│ [_______________]    │
│ Password             │
│ [_______________]    │
│                      │
│ [  🔵  Sign in  ]    │
└──────────────────────┘
```

### หน้า Register Success
```
┌──────────────────────┐
│  🎉 สมัครสมาชิกสำเร็จ!  │
│                      │
│  NC00001             │
│                      │
│ ⏰ ปิดหน้านี้ใน 10 วิ   │
│                      │
│    [ ปิดเลย ]         │
└──────────────────────┘
```

---

## 📁 Files ที่เกี่ยวข้อง

| File | Path |
|------|------|
| Theme CSS | `src/styles/theme.css` |
| Root CSS | `src/styles/index.css` |
| Logo Component | `src/assets/logo.tsx` |
| Logo Image | `public/images/nuclear-logo.jpg` |
| Sidebar Config | `src/components/layout/data/sidebar-data.ts` |
| Theme Provider | `src/context/theme-provider.tsx` |
| Favicon | `public/images/favicon.svg` |

---

## ดูเพิ่มเติม
- [[Overview]] — Architecture overview
- [[Phase 1 Plan]] — Implementation plan
- [[Phase 1 Tasks]] — Task breakdown
- [[Database Schema]] — Database design
