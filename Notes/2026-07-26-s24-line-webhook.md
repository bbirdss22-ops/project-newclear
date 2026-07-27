---
tags:
  - project-nuclear
  - progress
  - s2
  - qa
  - workflow
created: 2026-07-26
---

# S2.4 — Line Webhook + Defect Fixes + Git Convention ✅

> วันที่ 2026-07-26 — S2.4 เสร็จ + QA เทสผ่าน + fix defects + ตั้ง commit convention

## S2.4 Line Module (T25-T30) ✅

| Task | Endpoint | Auth | สถานะ |
|------|----------|------|--------|
| T25 | ติดตั้ง `@line/bot-sdk` | — | ✅ มีแล้ว |
| T26 | `POST /api/line/webhook` | Signature Guard | ✅ |
| T27 | Line signature verify | LineSignatureGuard | ✅ (ข้ามถ้า env ยังไม่ตั้ง) |
| T28 | Handle postback event | — | ✅ (สั่งซื้อสินค้า + สมัคร) |
| T29 | Handle follow event (welcome) | — | ✅ |
| T30 | LineService.pushMessage | — | ✅ (ยังไม่ทำงานเพราะไม่มี token) |

### ไฟล์ที่สร้าง (7 files)

| ไฟล์ | คำอธิบาย |
|------|----------|
| `src/line/line.module.ts` | LineModule |
| `src/line/line.controller.ts` | `POST /api/line/webhook` |
| `src/line/line.service.ts` | Business logic + pushMessage |
| `src/line/dto/line-webhook.dto.ts` | TypeScript types |
| `src/line/guards/line-signature.guard.ts` | Signature verify |
| `src/main.ts` | (mod) raw body middleware |
| `src/app.module.ts` | (mod) import LineModule |

## QA Test — S2.4 Line Webhook ✅

| Test Case | Result |
|-----------|--------|
| Health Check | ✅ PASS |
| Webhook — No Signature | ✅ PASS |
| Webhook — Follow Event | ✅ PASS |
| Webhook — Postback action=order | ✅ PASS |
| Webhook — Postback action=register | ✅ PASS |
| Webhook — Empty Body | ✅ PASS |
| Webhook — Malformed JSON | ✅ PASS |

## Defect Fixes 🐛✅

| Issue | ก่อน | หลัง | ไฟล์ที่แก้ |
|-------|------|------|-----------|
| **#1** `{}` → 201 (create null customer) | 201 Created | 400 Bad Request | `create-customer.dto.ts` |
| **#6** Webhook + `application/json` → 400 | 400 Error | 200 OK | `line.controller.ts`, `line-signature.guard.ts`, `main.ts` |

## Git Commit Convention 📝

Format: `{agent-name} | (type): {commit message}`

| Agent | Name |
|-------|------|
| ผู้ช่วยหลัก | `JARVIS` |
| Software Engineer sub-agent | `SE-NUCLEAR` |
| QA sub-agent | `QA-NUCLEAR` |

ดูเพิ่ม: [[git-commit-convention]]

## สถานะรวม

| Step | Status |
|------|--------|
| **S2.1** NestJS Backend Init | ✅ |
| **S2.2** Auth Module | ✅ |
| **S2.3** Customer CRUD | ✅ |
| **S2.4** Line Webhook | ✅ |
| **QA** API Test (22 tests) | ✅ 22/22 PASS after fix |
| **Defects** Fix | ✅ 2/2 Fixed |
| **Git Convention** | ✅ Set |

## หมายเหตุ

- `LINE_CHANNEL_SECRET` / `LINE_ACCESS_TOKEN` ยังเป็น placeholder — ต้องใส่ของจริงตอนเชื่อมต่อ Line OA
- Line webhook signature verify จะข้าม (log warning) ถ้า env ยังไม่ตั้งค่า
- Push message ยังใช้งานไม่ได้จนกว่าจะมี token จริง
