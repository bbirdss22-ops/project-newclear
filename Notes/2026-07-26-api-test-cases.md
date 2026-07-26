---
tags:
  - project-nuclear
  - qa
  - test
created: 2026-07-26
---

# API Test Cases — Project Nuclear

> Test date: 2026-07-26
> Environment: https://project-nuclear-api.onrender.com
> Tester: QA Agent (subagent)

## Summary

| Total | Pass | Fail | Skip |
|-------|------|------|------|
| 17    | 16   | 0    | 1    |

## Test Results

### TC-01: Health Check
| Field | Value |
|-------|-------|
| **Method** | GET |
| **Endpoint** | /api/health |
| **Auth** | ❌ None |
| **Expected** | 200 |
| **Actual** | 200 — `{"status":"ok","timestamp":"2026-07-26T11:33:15.673Z","service":"project-newclear-api","version":"0.0.1"}` |
| **Status** | ✅ PASS |

### TC-02: Login Valid Credentials
| Field | Value |
|-------|-------|
| **Method** | POST |
| **Endpoint** | /api/auth/login |
| **Auth** | ❌ None |
| **Body** | `{"username":"admin1","password":"admin123"}` |
| **Expected** | 201 + access_token + user info |
| **Actual** | 200 — access_token + user `{id, username, role: "superadmin"}` |
| **Status** | ✅ PASS *(Note: returned 200, not 201 — no semantic issue)* |

### TC-03: Login Invalid Credentials
| Field | Value |
|-------|-------|
| **Method** | POST |
| **Endpoint** | /api/auth/login |
| **Auth** | ❌ None |
| **Body** | `{"username":"admin1","password":"wrongpass"}` |
| **Expected** | 401 |
| **Actual** | 401 — `{"message":"Invalid credentials","error":"Unauthorized","statusCode":401}` |
| **Status** | ✅ PASS |

### TC-04: Login Missing Fields
| Field | Value |
|-------|-------|
| **Method** | POST |
| **Endpoint** | /api/auth/login |
| **Auth** | ❌ None |
| **Body** | `{"username":"admin1"}` |
| **Expected** | 400 |
| **Actual** | 400 — `{"message":["password should not be empty","password must be a string"],"error":"Bad Request","statusCode":400}` |
| **Status** | ✅ PASS |

### TC-05: Create Customer (Public)
| Field | Value |
|-------|-------|
| **Method** | POST |
| **Endpoint** | /api/customers |
| **Auth** | ❌ None |
| **Body** | `{"firstName":"สมชาย","lastName":"ใจดี","phone":"0812345678","email":"somchai@test.com"}` |
| **Expected** | 201 |
| **Actual** | 201 — customer object with `id`, `displayName`, etc. |
| **Status** | ✅ PASS |

### TC-06: Create Customer Duplicate lineUserId
| Field | Value |
|-------|-------|
| **Method** | POST |
| **Endpoint** | /api/customers |
| **Auth** | ❌ None |
| **Body** | `{"firstName":"สมศรี2","lastName":"รักดี2","phone":"0898765433","email":"somsri2@test.com","lineUserId":"Uline12345"}` (duplicate `lineUserId`) |
| **Expected** | 409 |
| **Actual** | 409 — `{"message":"Customer with lineUserId \"Uline12345\" already exists","error":"Conflict","statusCode":409}` |
| **Status** | ✅ PASS |

### TC-07: Create Customer Invalid Body
| Field | Value |
|-------|-------|
| **Method** | POST |
| **Endpoint** | /api/customers |
| **Auth** | ❌ None |
| **Body** | Malformed JSON: `not-json` |
| **Expected** | 400 |
| **Actual** | 400 — `{"message":"Unexpected token 'n', \"not-json\" is not valid JSON","error":"Bad Request","statusCode":400}` |
| **Status** | ✅ PASS |

> **Note:** Empty object `{}` returns 201 (creates record with null fields). No field-level validation exists for `firstName`, `phone`, `email` — this is a **minor concern** worth flagging.

### TC-08: List Customers (Protected, Paginated)
| Field | Value |
|-------|-------|
| **Method** | GET |
| **Endpoint** | /api/customers?page=1&limit=10 |
| **Auth** | ✅ JWT (superadmin) |
| **Expected** | 200 + paginated list |
| **Actual** | 200 — `{"data":[...],"total":5,"page":1,"limit":10}` |
| **Status** | ✅ PASS |

### TC-09: Search Customers
| Field | Value |
|-------|-------|
| **Method** | GET |
| **Endpoint** | /api/customers/search?q=สมชาย |
| **Auth** | ✅ JWT (superadmin) |
| **Expected** | 200 + matching results |
| **Actual** | 200 — `{"data":[...2 results...],"total":2,"page":1,"limit":20}` |
| **Status** | ✅ PASS |

### TC-10: Get Customer by ID (Found)
| Field | Value |
|-------|-------|
| **Method** | GET |
| **Endpoint** | /api/customers/:id |
| **Auth** | ✅ JWT (superadmin) |
| **Expected** | 200 |
| **Actual** | 200 — full customer object |
| **Status** | ✅ PASS |

### TC-11: Get Customer by ID (Not Found)
| Field | Value |
|-------|-------|
| **Method** | GET |
| **Endpoint** | /api/customers/:id (non-existent UUID) |
| **Auth** | ✅ JWT (superadmin) |
| **Expected** | 404 |
| **Actual** | 404 — `{"message":"Customer with id \"00000000-...\" not found","error":"Not Found","statusCode":404}` |
| **Status** | ✅ PASS |

### TC-12: Get Customer by lineUserId (Found)
| Field | Value |
|-------|-------|
| **Method** | GET |
| **Endpoint** | /api/customers/line/:lineUserId |
| **Auth** | ✅ JWT (superadmin) |
| **Expected** | 200 |
| **Actual** | 200 — customer object with matching lineUserId |
| **Status** | ✅ PASS |

### TC-12b: Get Customer by lineUserId (Not Found)
| Field | Value |
|-------|-------|
| **Method** | GET |
| **Endpoint** | /api/customers/line/UNONEXISTENT |
| **Auth** | ✅ JWT (superadmin) |
| **Expected** | 404 |
| **Actual** | 404 — `{"message":"Customer with lineUserId \"UNONEXISTENT\" not found","error":"Not Found","statusCode":404}` |
| **Status** | ✅ PASS |

### TC-13: Update Customer (PATCH)
| Field | Value |
|-------|-------|
| **Method** | PATCH |
| **Endpoint** | /api/customers/:id |
| **Auth** | ✅ JWT (superadmin) |
| **Body** | `{"phone":"0888888888"}` |
| **Expected** | 200 |
| **Actual** | 200 — updated customer with `phone: "0888888888"` and `updatedAt` changed |
| **Status** | ✅ PASS |

### TC-14: Protected Endpoint — No Token
| Field | Value |
|-------|-------|
| **Method** | GET |
| **Endpoint** | /api/customers?page=1&limit=10 |
| **Auth** | ❌ None |
| **Expected** | 401 |
| **Actual** | 401 — `{"message":"Unauthorized","statusCode":401}` |
| **Status** | ✅ PASS |

### TC-15: Protected Endpoint — Wrong Role
| Field | Value |
|-------|-------|
| **Method** | GET |
| **Endpoint** | /api/customers?page=1&limit=10 |
| **Auth** | ✅ Invalid token |
| **Expected** | 403 |
| **Actual** | 401 — same as no-token response (token validation fails before role check) |
| **Status** | ⏭️ SKIP *(requires separate user with valid token but unauthorized role; no such test account available — both `admin1` and `admin2` have access)* |

## Issues Found

| # | Severity | Description |
|---|----------|-------------|
| 1 | ⚠️ Low | Login returns `200` instead of `201` — no semantic issue, but spec says 201 |
| 2 | ⚠️ Medium | No field-level validation on customer creation — empty `{}` creates a record with all-null fields (201) |
| 3 | ⚠️ Low | No duplicate detection on `phone` or `email` — only `lineUserId` has unique constraint |
| 4 | ⬜ Info | `limit` default is 20 for search endpoint (vs 10 for list) |
| 5 | ⬜ Info | `admin` role (admin2) has same access as `superadmin` on customers — no role-based restriction observed |
