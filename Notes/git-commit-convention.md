---
tags:
  - project-nuclear
  - workflow
  - git
created: 2026-07-26
---

# Git Commit Convention

> ใช้ format เดียวกันทั้งโปรเจค

## Format

```
{agent-name} | (type): {commit message}
```

## Examples

```
JARVIS | (feat): add AuthModule with JWT login
SE-NUCLEAR | (fix): add field-level validation on POST /api/customers
JARVIS | (docs): add AGENTS.md for project context
SE-NUCLEAR | (refactor): extract line signature guard
JARVIS | (progress): S2.3 Customer Module complete
```

## Type

| Type | เมื่อไหร่ |
|------|----------|
| `feat` | เพ่งิม feature ใหม่ |
| `fix` | แก้ bug / defect |
| `docs` | เอกสาร / AGENTS.md / notes |
| `refactor` | ปรับโครงสร้างโค้ด ไม่เปลี่ยนพฤติกรรม |
| `progress` | บันทึก progress / status |
| `chore` | dependencies / config / tooling |
| `style` | จัด format / lint ไม่เปลี่ยน logic |
| `test` | เพิ่มหรือแก้ test |
| `perf` | เพิ่มประสิทธิภาพ |

## Agent Name

| Agent | Name |
|-------|------|
| จาวิส (ผู้ช่วยหลัก) | `JARVIS` |
| Software Engineer sub-agent | `SE-NUCLEAR` |
| QA sub-agent | `QA-NUCLEAR` |

## Enforcement

- ใช้ format นี้กับทุก commit ใน repo `project-nuclear-api` และ `project-newclear`
- Sub-agent ต้องใช้ format นี้ด้วย
- ใช้ `git commit --amend` เพื่อแก้ commit message ถ้าลืม
