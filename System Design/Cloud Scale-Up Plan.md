# Cloud Scale-Up Plan — Project Newclear

## 📊 Current Stack (Phase 0)

| Component | Service | Tier | Cost/mo |
|-----------|---------|------|---------|
| Frontend | Vercel | Pro | $20 |
| Backend | Render | Starter | $7 |
| Database | Neon | Free/Launch | $0-19 |
| Image Storage | Local/Render disk | - | $0 |
| **Total** | | | **~$27-46/mo** |

### Current Limitations
- Render Starter sleeps after inactivity
- Neon Free: 0.5 GB storage, limited compute
- No CDN, monitoring, or backup strategy
- Images stored on ephemeral disk

---

## 🟢 Phase 1: Validation (0-500 users)

**Goal:** Validate product-market fit, minimize cost, establish baseline monitoring

### Infrastructure

| Component | Service | Tier | Cost/mo |
|-----------|---------|------|---------|
| Frontend | Vercel | Pro | $20 |
| Backend | Render | Starter | $7 |
| Database | Neon | Launch | $19 |
| Image Storage | Cloudflare R2 | Free tier (10 GB) | $0 |
| CDN | Cloudflare | Free | $0 |
| Monitoring | Sentry | Free (5k events/mo) | $0 |
| **Total** | | | **~$46/mo** |

### Action Items

**Week 1-2: Storage Migration**
```bash
# Migrate image storage from Render disk to Cloudflare R2
1. Create R2 bucket for bank book uploads
2. Update backend to use R2 SDK
3. Add signed URLs for secure access
4. Migrate existing images (if any)
```

**Week 3-4: Monitoring & CDN**
```bash
1. Add Cloudflare DNS (point domain to Vercel)
2. Enable Cloudflare proxy (orange cloud)
3. Integrate Sentry SDK in backend
4. Set up error alerts (email/Slack)
```

**Ongoing: Database**
```bash
1. Enable automatic backups (Neon Launch includes)
2. Monitor storage usage
3. Set up read queries for dashboard (if needed)
```

### Architecture

```
User → Cloudflare (DNS + CDN)
     → Vercel (Frontend)
     → Render (Backend API)
     → Neon (PostgreSQL)
     → R2 (Images - bank book uploads)
     → Sentry (Error tracking)
```

### Success Metrics
- Uptime > 99%
- P95 response time < 500ms
- Error rate < 1%
- Zero data loss

---

## 🟡 Phase 2: Growth (500-5,000 users)

**Goal:** Support growing user base, reduce downtime, add observability

### Infrastructure

| Component | Service | Tier | Cost/mo |
|-----------|---------|------|---------|
| Frontend | Vercel | Pro | $20 |
| Backend | Render | Standard (2GB RAM) | $25 |
| Database | Neon | Scale (4 GB) | $69 |
| Image Storage | Cloudflare R2 | ~10 GB | $5 |
| CDN | Cloudflare | Pro | $20 |
| Monitoring | Sentry | Team (50k events) | $26 |
| Email | Resend | ~5k emails | $20 |
| **Total** | | | **~$185/mo** |

### Action Items

**Priority 1: Backend Upgrade**
```typescript
// Upgrade Render to Standard tier
- 2GB RAM (no sleep)
- Dedicated CPU
- Auto-restart on crash
- Estimated: 1 week
```

**Priority 2: Email Service**
```typescript
// Integrate Resend for notifications
- Commission payout notifications
- Registration confirmations
- Admin alerts (new bank uploads)
- LINE message fallback
```

**Priority 3: Database Scaling**
```bash
1. Upgrade to Neon Scale (4 GB)
2. Enable read replicas (if needed)
3. Add connection pooling (PgBouncer)
4. Monitor slow queries
```

**Priority 4: Advanced Monitoring**
```bash
1. Add performance monitoring (Sentry)
2. Set up alerts:
   - CPU > 80%
   - Memory > 80%
   - Error rate > 5%
   - Database connections > 80%
3. Create dashboard (Grafana/Sentry)
```

**Priority 5: Security**
```bash
1. Enable rate limiting (100 req/min/IP)
2. Add API key authentication
3. Set up IP whitelist for admin endpoints
4. Enable Cloudflare WAF rules
```

### Architecture

```
User → Cloudflare (CDN + WAF + Rate Limiting)
     → Vercel (Frontend)
     → Render (Backend API - 2GB RAM, no sleep)
     → Neon (PostgreSQL - 4GB, connection pooling)
     → R2 (Images - 10GB)
     → Resend (Email notifications)
     → Sentry (APM + Error tracking)
```

### Success Metrics
- Uptime > 99.5%
- P95 response time < 300ms
- Error rate < 0.5%
- Commission calculation < 2s
- Email delivery < 5s

---

## 🔴 Phase 3: Scale (5,000-50,000 users)

**Goal:** High availability, auto-scaling, enterprise-grade reliability

### Infrastructure

| Component | Service | Tier | Cost/mo |
|-----------|---------|------|---------|
| Frontend | Vercel | Business | $150 |
| Backend | Railway / Fly.io | 2 instances (auto-scale) | $50-100 |
| Database | Neon | Business | $199 |
| Image Storage | Cloudflare R2 | ~100 GB | $15 |
| CDN | Cloudflare | Business | $200 |
| Monitoring | Datadog / Grafana Cloud | | $50-100 |
| Email | Resend | ~50k emails | $100 |
| Queue | BullMQ (Redis) | Upstash | $10 |
| Cache | Upstash Redis | ~1 GB | $10 |
| **Total** | | | **~$784-884/mo** |

### Action Items

**Priority 1: Backend Migration**
```bash
# Migrate from Render to Railway or Fly.io
Railway:
  - Better auto-scaling
  - Multiple instances
  - Built-in load balancer
  - Better pricing for scale

Fly.io:
  - Global edge deployment
  - Lower latency
  - Auto-scaling
  - More control
```

**Priority 2: Add Redis Cache**
```typescript
// Cache hot data
- Commission calculations (per user, per month)
- Customer lists (dashboard)
- Session storage
- Rate limiting counters

// Upstash Redis
- Serverless
- Pay-per-request
- Global replication
```

**Priority 3: Background Job Queue**
```typescript
// Move heavy tasks to background
- Commission calculation (bulk)
- LINE webhook processing
- Email sending
- Image processing
- Report generation

// BullMQ + Upstash Redis
- Reliable queue
- Retry mechanism
- Dead letter queue
- Monitoring dashboard
```

**Priority 4: Database Optimization**
```bash
1. Add read replicas (Neon Business)
2. Implement CQRS pattern
   - Write to primary
   - Read from replicas
3. Add database connection pooling
4. Optimize slow queries
5. Add indexes for commission lookups
```

**Priority 5: Auto-Scaling**
```yaml
# Railway/Fly.io auto-scaling config
- Min instances: 2
- Max instances: 5
- Scale on: CPU > 70% OR Memory > 80%
- Cooldown: 5 minutes
```

**Priority 6: Advanced Monitoring**
```bash
1. Datadog or Grafana Cloud
2. Custom dashboards:
   - Commission calculation time
   - API response time (p50, p95, p99)
   - Error rates by endpoint
   - Database query performance
   - Queue depth
3. Alerts:
   - Commission calculation > 5s
   - API error rate > 1%
   - Queue depth > 100
   - Database replication lag > 10s
```

### Architecture

```
User → Cloudflare (CDN + WAF + DDoS Protection)
     → Vercel (Frontend)
     → Railway/Fly.io (Backend API - 2-5 instances, auto-scale)
     → Upstash Redis (Cache + Queue)
     → BullMQ Workers (Commission calc, LINE webhook, Email)
     → Neon (PostgreSQL - Primary + Read Replicas)
     → R2 (Images - 100GB)
     → Resend (Email - 50k/mo)
     → Datadog/Grafana (Monitoring + APM)
```

### Commission Calculation Flow

```typescript
// Phase 3: Async commission calculation
1. Order created → Push to BullMQ queue
2. Worker picks up job
3. Calculate commissions (L1, L2, L3)
4. Batch insert commission records
5. Update user balances
6. Send notifications (email/LINE)
7. Mark job as complete

// Benefits:
- Non-blocking order creation
- Can retry on failure
- Can scale workers independently
- Can monitor queue depth
```

### Success Metrics
- Uptime > 99.9%
- P95 response time < 200ms
- P99 response time < 500ms
- Error rate < 0.1%
- Commission calculation < 1s (async)
- Zero data loss
- Auto-scaling response < 2 min

---

## ⚫ Phase 4: Enterprise (50,000+ users)

**Goal:** Full control, maximum performance, compliance, multi-region

### Infrastructure

| Component | Service | Tier | Cost/mo |
|-----------|---------|------|---------|
| Frontend | Vercel | Enterprise | Custom |
| Backend | Kubernetes (GKE/EKS) | Auto-scaling | $200-500 |
| Database | Supabase / Self-hosted PG | Multi-AZ | $300-500 |
| Storage | Cloudflare R2 / S3 | Multi-region | $50-100 |
| CDN | Cloudflare | Enterprise | Custom |
| Monitoring | Datadog Enterprise | | $200-500 |
| Email | AWS SES | High volume | $50-100 |
| Queue | AWS SQS / Kafka | | $20-50 |
| **Total** | | | **~$1,000-2,000+/mo** |

### Action Items

**Priority 1: Kubernetes Migration**
```bash
# Migrate to Kubernetes (GKE/EKS)
- Deploy backend as pods
- Horizontal Pod Autoscaler (HPA)
- Rolling updates
- Self-healing
- Resource limits
```

**Priority 2: Database Sharding**
```bash
# Commission table grows fast - need sharding
- Shard by customer_id or date
- Use Citus (PostgreSQL extension) or custom sharding
- Partition old data (archive older than 1 year)
- Add materialized views for reports
```

**Priority 3: Multi-Region Deployment**
```bash
# Deploy to multiple regions
- Primary: Singapore (SEA users)
- Secondary: US (backup)
- Use Cloudflare load balancer
- Database replication across regions
```

**Priority 4: Compliance**
```bash
# SOC2 / ISO27001
- Audit logging (all admin actions)
- Data encryption at rest + in transit
- Access control (RBAC)
- Regular security audits
- GDPR compliance (data export/deletion)
```

**Priority 5: Advanced Analytics**
```bash
# Business intelligence
- Commission analytics dashboard
- User growth metrics
- Revenue forecasting
- Fraud detection
```

### Architecture

```
User → Cloudflare (Enterprise CDN + WAF + DDoS)
     → Vercel (Frontend - Enterprise)
     → Kubernetes (GKE/EKS)
        - Backend API pods (auto-scale 5-20)
        - Worker pods (commission calc, LINE webhook)
        - Scheduled jobs (reports, cleanup)
     → Supabase/PostgreSQL (Multi-AZ, sharded)
     → Upstash Redis / AWS ElastiCache (Cluster mode)
     → AWS SQS / Kafka (Message queue)
     → R2 / S3 (Multi-region storage)
     → AWS SES (Email)
     → Datadog (Enterprise monitoring)
```

### Success Metrics
- Uptime > 99.99%
- P95 response time < 100ms
- P99 response time < 300ms
- Error rate < 0.01%
- Commission calculation < 500ms
- Zero data loss
- Compliance: SOC2 / ISO27001

---

## 💰 Cost Over Time

| Phase | Users | Cost/mo | Cost/user | Revenue (est.) | Margin |
|-------|-------|---------|-----------|----------------|--------|
| **Phase 1** | 0-500 | ~$46 | $0.09-0.23 | $500-2,000 | 90%+ |
| **Phase 2** | 500-5K | ~$185 | $0.04-0.37 | $5K-20K | 95%+ |
| **Phase 3** | 5K-50K | ~$800 | $0.02-0.16 | $50K-200K | 98%+ |
| **Phase 4** | 50K+ | ~$1,500+ | $0.03+ | $200K+ | 99%+ |

### Cost Optimization Tips

1. **Use reserved instances** (Phase 3+) - save 30-40%
2. **Spot instances** for background jobs - save 60-70%
3. **Cache aggressively** - reduce database load
4. **Compress images** before upload - save storage
5. **Use CDN** for static assets - reduce bandwidth
6. **Monitor and right-size** - don't over-provision
7. **Negotiate enterprise deals** (Phase 4) - custom pricing

---

## 🎯 Migration Checklist

### Phase 0 → Phase 1
- [ ] Create Cloudflare account
- [ ] Set up R2 bucket
- [ ] Update backend to use R2 SDK
- [ ] Add Sentry SDK
- [ ] Configure Cloudflare DNS
- [ ] Test migration (staging first)
- [ ] Deploy to production

### Phase 1 → Phase 2
- [ ] Upgrade Render to Standard
- [ ] Integrate Resend
- [ ] Upgrade Neon to Scale
- [ ] Add rate limiting
- [ ] Set up monitoring alerts
- [ ] Load test (simulate 1,000 users)

### Phase 2 → Phase 3
- [ ] Migrate backend to Railway/Fly.io
- [ ] Set up Upstash Redis
- [ ] Implement BullMQ for background jobs
- [ ] Add database read replicas
- [ ] Configure auto-scaling
- [ ] Load test (simulate 10,000 users)

### Phase 3 → Phase 4
- [ ] Set up Kubernetes cluster
- [ ] Implement database sharding
- [ ] Deploy to multiple regions
- [ ] Add audit logging
- [ ] Complete security audit
- [ ] Obtain SOC2 certification

---

## 🚨 Risk Mitigation

### Database Risks
**Risk:** Commission table grows too large
**Solution:** 
- Partition by date (monthly)
- Archive old data (older than 1 year)
- Use materialized views for reports
- Consider sharding (Phase 4)

### Backend Risks
**Risk:** Commission calculation blocks order creation
**Solution:**
- Move to background queue (Phase 2+)
- Add timeout (max 5s)
- Retry mechanism
- Circuit breaker pattern

### Cost Risks
**Risk:** Infrastructure cost exceeds revenue
**Solution:**
- Monitor cost/user ratio
- Optimize queries (reduce DB load)
- Cache aggressively
- Use reserved instances (Phase 3+)

### Security Risks
**Risk:** Commission fraud (fake orders)
**Solution:**
- Admin approval for payouts (already implemented)
- Rate limiting
- Audit logging
- Anomaly detection (Phase 4)

---

## 📊 Monitoring Dashboard

### Key Metrics to Track

**Application:**
- Request rate (req/s)
- Error rate (%)
- Response time (p50, p95, p99)
- Active users
- Commission calculation time

**Infrastructure:**
- CPU utilization (%)
- Memory utilization (%)
- Database connections
- Queue depth
- Cache hit rate (%)

**Business:**
- Orders per day
- Commission paid per day
- Average commission per user
- User growth rate
- Revenue per user

### Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| CPU | > 70% | > 90% |
| Memory | > 70% | > 90% |
| Error rate | > 1% | > 5% |
| Response time (p95) | > 500ms | > 1s |
| Queue depth | > 100 | > 500 |
| DB connections | > 80% | > 95% |

---

## 🔮 Future Considerations

### Phase 5: Global Scale (500,000+ users)
- Multi-cloud strategy (AWS + GCP + Azure)
- Edge computing (Cloudflare Workers)
- Global database (CockroachDB / TiDB)
- Advanced ML (fraud detection, recommendations)

### Alternative Technologies
**Database:**
- CockroachDB (distributed PostgreSQL)
- TiDB (MySQL-compatible, distributed)
- PlanetScale (serverless MySQL)

**Backend:**
- AWS Lambda (serverless)
- Google Cloud Run (container-based)
- Deno Deploy (edge functions)

**Queue:**
- AWS SQS (fully managed)
- Google Pub/Sub (global)
- Kafka (high throughput)

---

## 📝 Summary

### Recommended Path
1. **Start with Phase 1** - validate product, minimize cost
2. **Move to Phase 2 at 500 users** - add monitoring, email, security
3. **Scale to Phase 3 at 5K users** - auto-scaling, caching, queue
4. **Enterprise at 50K users** - Kubernetes, sharding, compliance

### Key Principles
- **Don't over-engineer early** - start simple, scale as needed
- **Monitor everything** - data-driven decisions
- **Automate deployments** - CI/CD from day 1
- **Design for failure** - retries, circuit breakers, graceful degradation
- **Optimize for cost** - use free tiers, reserved instances, spot instances

### Next Steps
1. Implement Phase 1 (Cloudflare R2, Sentry, CDN)
2. Set up monitoring dashboard
3. Load test current setup
4. Plan Phase 2 migration
5. Document architecture decisions

---

**Created:** 2026-08-09 12:27 GMT+7
**Status:** Planning phase
**Next Review:** When reaching 500 users
