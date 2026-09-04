# 🖼️ Infographic Prompt Template — Project Nuclear

> ใช้ทุกครั้งที่ขอสร้าง infographic — แทรก brand theme ให้อัตโนมัติ
> ใช้คู่กับ [[Brand-Theme]]

## ค่าเริ่มต้น (defaults)

```
Layout:   linear-progression (ขั้นตอน) / bento-grid (ภาพรวม) / hub-spoke (ศูนย์กลาง)
Style:    hand-drawn-edu (น่ารัก การศึกษา) / bold-graphic (โมเดิร์น)
Aspect:   portrait 9:16 (แชร์ LINE) / landscape 16:9 (เว็บ/โพสต์)
Language: th
```

## 🔑 Prompt block หลัก (แทรกทุกครั้ง)

```
สร้างอินโฟกราฟิกภาษาไทย
{HEADLINE}
ขนาด {ASPECT}

สไตล์สี: "Green Energy Agriculture / Nuclear" theme
- สีหลัก: Forest Green #4A8000
- ไฮไลต์/เลข: Lime Green #7CB342
- หัวเรื่อง/น่าเชื่อถือ: Deep Teal-Navy #00503C
- ตัวเลขเด่น/จุดเด่น: Golden Yellow #F5A800
- พื้นหลัง: off-white #F0F0F0
โทน: อบอุ่น สดใส มีพลัง — ธรรมชาติ + เทคโนโลยี
พื้นสะอาด, ตัวเลขสำคัญตัวใหญ่เด่นสีเหลือง, หัวเรื่องสีเขียวเข้ม

โครงสร้าง:
{SECTIONS}
ข้อความห้ามเกิน: {KEY_MESSAGE}
```

## ส่วนประกอบ (fill ตามงาน)

### {HEADLINE} — หัวข้อ 1 บรรทัด
### {ASPECT} — portrait 9:16 / landscape 16:9 / square 1:1
### {SECTIONS} — ลำดับแต่ละบล็อก (ยึดธีม):
- กล่องขั้นตอนสลับ: เขียวอ่อน `#DDE8C8` / เหลืองอ่อน `#FFF2D9` / น้ำเงินอ่อน `#DBE9E4`
- ตัวเลขในวงกลม: เขียว/เหลือง/น้ำเงินเข้ม สลับ
- จุดเงิน: Golden Yellow เสมอ
### {KEY_MESSAGE} — กล่องสรุปท้าย (ขาว + ขอบเขียว, ข้อความหลักเหลือง)

---

## ตัวอย่างสำเร็จรูป (copy ใช้ได้เลย)

### A. Referral "ชวนเพื่อน" (portrait)

```
สร้างอินโฟกราฟิกภาษาไทย โฟกัสขั้น "การชวนเพื่อน" อย่างเดียว
ขนาด portrait 9:16

สไตล์สี: "Green Energy Agriculture / Nuclear" theme
- สีหลัก: Forest Green #4A8000, ไฮไลต์ Lime #7CB342
- หัวเรื่อง: Deep Teal-Navy #00503C
- จุดเด่น/ตัวเลข: Golden Yellow #F5A800
- พื้นหลัง: off-white #F0F0F0

หัวข้อ: "🌱 แค่แชร์ลิงก์ ก็เริ่มเก็บรายได้ได้แล้ว"

3 ขั้นตอน (กล่องสลับเขียว/เหลือง/น้ำเงินอ่อน):
1. กดปุ่ม "แนะนำเพื่อน" — ไอคอนมือกดหน้าจอ
2. ได้ลิงก์ส่วนตัว — ไอคอน bubble
3. แชร์ให้เพื่อน — ไอคอนแชร์

กล่องสรุป (ขาว+ขอบเขียว): "เพื่อนสมัคร → ระบบเชื่อมต่อให้เอง ✅"
โทน: อบอุ่น เป็นมิตร อ่านจบใน 10 วินาที
```

### B. Commission "ได้เงิน" (portrait)

```
สร้างอินโฟกราฟิกภาษาไทย อธิบายรายได้จาก referral แบบ flat ต่อชิ้น
ขนาด portrait 9:16

สไตล์สี: "Green Energy Agriculture / Nuclear" theme
(หัวเรื่อง Deep Teal-Navy #00503C, เลขเงิน Golden Yellow #F5A800,
พื้น off-white #F0F0F0)

หัวข้อ: "🤑 เพื่อนซื้อ = คุณได้เงิน"

2 ระดับ (บน = 1st, ล่าง = 2nd):
- 1st level upline: 10 บาท/ชิ้น (เลขเหลืองใหญ่)
- 2nd level upline: 1 บาท/ชิ้น

กล่องสรุป (ขาว+ขอบเขียว):
"ตัวอย่าง: เพื่อนซื้อ 3 ชิ้น → 30 + 3 = 33 บาท 💸"
หมายเหตุท้าย: "จ่ายแค่ 2 ระดับบน 🚫 ไม่มี level 3+"
```

---

## Flow ใช้งาน

```
1. ระบุ: หัวข้อ + ขนาด + layout/style (ถ้าไม่ระบุใช้ default)
2. ผม: ประกอบ prompt โดยแทรก brand theme block
3. สร้าง: SVG → render PNG (เหมือน referral-invite)
4. ถ้าใช้ image_generate: เอาภาพมาแทน SVG
```