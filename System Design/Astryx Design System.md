---
tags:
  - project-newclear
  - design-system
  - astryx
  - ui
  - meta
created: 2026-07-21
---

# Astryx Design System

> Design system by Meta ที่ใช้ในโปรเจคนี้

## ภาพรวม

**Astryx** คือ open-source design system จาก Meta ที่ใช้ React components เต็มรูปแบบ

| Detail | Value |
|--------|-------|
| **Source** | [https://astryx.atmeta.com/](https://astryx.atmeta.com/) |
| **Made by** | Meta (8+ years, 13,000+ apps) |
| **License** | Open source |
| **Components** | 160+ |
| **Framework** | React |
| **Dark mode** | ✅ Built-in |
| **Accessible** | ✅ |
| **CLI/MCP** | ✅ Agent-ready |

## Key Features

### 🎨 Themeable & Customizable
- ระบบ themes ที่ปรับเปลี่ยนได้ตาม brand
- ไม่ต้องเริ่มจากศูนย์ — มี foundation ที่ปรับแต่งได้
- Dark mode built-in

### 🧩 160+ Components
- Accessible (a11y) ✅
- React components พร้อมใช้
- Built-in spacing system
- Dark mode support
- Flexible styling

### 📱 Agent-Ready
- CLI สำหรับ scaffold projects
- Generate themes จาก command line
- MCP (Model Context Protocol) support — ทำให้ AI agent ใช้ design system เป็น tools ได้
- Browse templates และ docs จาก terminal

### 🗂️ Production Templates
- Templates พร้อมใช้สำหรับหน้าเว็บทั่วไป
- Plug in content แล้วใช้งานได้เลย

## ทำไมถึงเลือก Astryx สำหรับโปรเจคนี้

| ความต้องการ | Astryx Solution |
|-------------|----------------|
| Dashboard UI | Component set ครบ (table, form, input, button, badge, etc.) |
| Registration form | Form components + validation-ready |
| Cost $0 | Open source, ใช้ฟรี |
| Next.js compatible | React based ใช้งานกับ Next.js ได้เลย |
| Dark mode | Built-in |
| Agent-ready (MLM) | CLI/MCP support สำหรับ automation |

## Components ที่น่าสนใจ

จากหน้า landing page มี components ที่ใช้กับโปรเจคนี้ได้:

- **Badge** — แสดงสถานะลูกค้า
- **Checkbox / Switch** — filter ใน dashboard
- **Table / Grid** — รายชื่อลูกค้า
- **Form inputs** — ฟอร์มสมัครสมาชิก
- **Dialog / Modal** — รายละเอียดลูกค้า
- **Button** — actions ทุกประเภท
- **Select / Dropdown** — filter options
- **Card** — แสดงข้อมูลลูกค้า

## วิธีติดตั้ง

```bash
# ติดตั้งผ่าน package manager
npm install @atmeta/astryx
# หรือ
yarn add @atmeta/astryx
```

## CLI Tools

```bash
# Scaffold project
npx astryx create my-app

# Browse templates
npx astryx templates

# Generate theme
npx astryx theme generate --name my-brand

# Component docs
npx astryx docs button
```

## ดูเพิ่มเติม
- [[Overview]] — Architecture overview
- [[Phase 1 Plan]] — Implementation plan
