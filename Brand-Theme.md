# 🎨 Brand Theme — Project Nuclear (จาก logo)

> **Theme สีบังคับใช้กับทุก infographic ของ Project Nuclear**
> extract จาก logo วัสดุปรับปรุงดินตรานิวเคลียร์ (2026-09-04)

## Palette หลัก (Hex)

| สี | Hex (extract pixel) | ใช้กับ |
|---|---|---|
| **Forest Green** | `#4A8000` | สีหลัก — ความเจริญเติบโต, ธรรมชาติ, ตัวละคร, วงนอก |
| **Lime Green** | `#7CB342` (dark `#338000`) | สีรองเขียว — ใบไม้, ไฮไลต์, เลขเด่น |
| **Deep Teal-Navy** | `#00503C` (`#003040`) | ความน่าเชื่อถือ, เทคโนโลยี, "ตรานิวเคลียร์", หัวข้อหลัก |
| **Golden Yellow** | `#F5A800` | พลังงาน, "นิวเคลียร์", จุดเด่น, ไฮไลต์ |
| **Soft Off-white** | `#F0F0F0` | พื้นหลังหลัก |
| **White** | `#FFFFFF` | เสริม, ข้อความบนแถบเข้ม |

> หมายเหตุ: hex นี้ extract จาก pixel จริงของ logo (PIL quantize) — แม่นกว่า vision

## โทนโดยรวม

**Green Energy Agriculture / Smart Farming** — อบอุ่น + สดใส
- เขียว (ธรรมชาติ) ผสม เหลือง/น้ำเงิน (เทคโนโลยี/พลังงาน)
- ดูมีชีวิตชีวา, มีพลัง สอดคล้องชื่อ "นิวเคลียร์"

## กฎการใช้ (ทุก infographic)

1. พื้นหลัง: off-white `#F0F0F0` หรือ White
2. หัวข้อหลัก: **Deep Teal-Navy** `#00503C` — น่าเชื่อถือ
3. จุดเด่น/ตัวเลขเงิน: **Golden Yellow** `#F5A800` — ดึงดูด
4. เนื้อหา/ธรรมชาติ: **Forest Green** `#4A8000`
5. กล่องขั้นตอน: สลับ เขียวอ่อน `#DDE8C8` / เหลืองอ่อน `#FFF2D9` / น้ำเงินอ่อน `#DBE9E4` (จาง)
6. ตัวอักษรหลัก: เขียวเข้ม `#338000` หรือ Teal เข้ม
7. accent ตัวละคร/ไอคอน: Lime Green + Golden Yellow

## Prompt block (แทรกได้ทุกครั้ง)

```
สไตล์สี: "Green Energy Agriculture / Nuclear" theme
- สีหลัก: Forest Green #4A8000, Lime Green #7CB342
- หัวข้อ/ความน่าเชื่อถือ: Deep Teal-Navy #00503C
- จุดเด่น/ตัวเลข: Golden Yellow #F5A800
- พื้นหลัง: off-white #F0F0F0
- หัวเรื่องใช้ Deep Teal-Navy, ตัวเลขเด่นใช้ Golden Yellow
- โทน: อบอุ่น สดใส มีพลัง (นิวเคลียร์) — ธรรมชาติ + เทคโนโลยี
```