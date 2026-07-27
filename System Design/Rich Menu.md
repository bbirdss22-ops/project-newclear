---
tags:
  - project-newclear
  - line-oa
  - rich-menu
  - ui
created: 2026-07-21
---

# Rich Menu

> Line OA Rich Menu Actions

## Menu Layout

```
┌──────────────────────────────┐
│                              │
│   🛒 สั่งซื้อสินค้า           │
│   (Tap → ส่งข้อความ)         │
│                              │
├──────────────────────────────┤
│                              │
│   📝 สมัครสมาชิก             │
│   (Tap → เปิด URL)           │
│                              │
└──────────────────────────────┘
```

## Actions

### ปุ่ม 1: สั่งซื้อสินค้า
- **Type:** `postback`
- **Data:** `action=order`
- **เมื่อกด:** NestJS webhook รับ postback แล้ว Reply ข้อความ "สั่งซื้อสินค้า" กลับไป

### ปุ่ม 2: สมัครสมาชิก
- **Type:** `postback`
- **Data:** `action=register`
- **เมื่อกด:** NestJS webhook รับ postback → สร้าง temporary token (UUID, expires 5 นาที) → Reply ลิงก์พร้อม token
- **หน้า Register:** รับ token query param → validate กับ backend → resolve เป็น lineUserId → submit form

## JSON Rich Menu Definition

```json
{
  "size": {
    "width": 2500,
    "height": 1686
  },
  "selected": true,
  "name": "main-menu",
  "chatBarText": "เมนู",
  "areas": [
    {
      "bounds": {
        "x": 0,
        "y": 0,
        "width": 2500,
        "height": 843
      },
      "action": {
        "type": "postback",
        "data": "action=order",
        "displayText": "สั่งซื้อสินค้า"
      }
    },
    {
      "bounds": {
        "x": 0,
        "y": 843,
        "width": 2500,
        "height": 843
      },
      "action": {
        "type": "postback",
        "data": "action=register",
        "displayText": "สมัครสมาชิก"
      }
    }
  ]
}
```

## Rich Menu Image

- ขนาด: 2500 × 1686 px
- Format: PNG/JPG/JPEG
- Max size: 1MB
- ใช้ Pillow generate แบบง่ายๆ (gradient สีน้ำเงิน + ข้อความ)

## Rich Menu ID

- **ID:** `richmenu-f12168ede4eea38f58a36b5adbf2b217`
- **Status:** ถูก Set เป็น default rich menu สำหรับทุก user แล้ว

## NestJS Webhook Handler

```typescript
@Post('webhook')
async handleWebhook(@Body() body: WebhookEventBody) {
  for (const event of body.events) {
    if (event.type === 'postback' && event.postback.data === 'action=order') {
      await this.lineService.replyMessage(event.replyToken, {
        type: 'text',
        text: 'สั่งซื้อสินค้า'
      });
    }
  }
}
```

## การ Set Rich Menu ครั้งแรก

1. Upload image → `POST /v2/bot/richmenu` → ได้ richMenuId
2. Upload image → `POST /v2/bot/richmenu/{richMenuId}/content` (binary)
3. Set default → `POST /v2/bot/user/all/richmenu/{richMenuId}`

✅ **ครั้งแรกเรียบร้อยแล้ว (2026-07-27)**
