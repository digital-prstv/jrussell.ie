# jrussell.ie DNS migration checklist (Route53 → Cloudflare)

Tracks the DNS/email cutover for moving jrussell.ie hosting from AWS to GitHub Pages
fronted by Cloudflare (free). **Email safety is the top priority** — replicate every
record in Cloudflare and verify *before* switching nameservers.

## Live records (captured 2026-07-09, authoritative = Route53)

| Type | Name | Value | Notes |
|------|------|-------|-------|
| NS | jrussell.ie | ns-1078.awsdns-06.org / ns-354.awsdns-44.com / ns-1733.awsdns-24.co.uk / ns-856.awsdns-43.net | Route53 delegation — changes at the `.ie` registrar |
| MX | jrussell.ie | 1 aspmx.l.google.com; 5 alt1.aspmx.l.google.com; 5 alt2.aspmx.l.google.com; 10 aspmx2.googlemail.com; 10 aspmx3.googlemail.com | Google Workspace — **must replicate exactly** |
| TXT | jrussell.ie | `v=spf1 include:_spf.google.com ~all` | SPF |
| A | www.jrussell.ie | 18.66.171.{13,44,104,105} | → CloudFront (replaced at cutover) |
| A | jrussell.ie (apex) | (none) | apex is email-only today |
| TXT | _dmarc.jrussell.ie | (none) | no DMARC currently |
| TXT | google._domainkey | (none at default selector) | **verify real DKIM selector in Google Admin** |

## Phase 0 — export the authoritative zone (source of truth)

Run with AWS access to the account holding the zone and commit the raw output next to this
file, so nothing is missed (records added outside Terraform won't appear in `iac/`):

```bash
ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name jrussell.ie \
  --query 'HostedZones[0].Id' --output text)
aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID" \
  > docs/route53-jrussell-zone-export.json
```

In **Google Workspace Admin** (Apps → Google Workspace → Gmail → Authenticate email),
read the active **DKIM selector + TXT value** and record it here before cutover.

## Phase 2 — Cloudflare setup (do NOT change nameservers until verified)

- [ ] Add `jrussell.ie` to Cloudflare (free). Let it import, then reconcile against the
      export — every MX/TXT/DKIM/verification record present, DNS-only (grey cloud).
- [ ] `www` → CNAME `digital-prstv.github.io`, **proxied (orange cloud)**.
- [ ] Transform Rules → Modify Response Header, replicating `iac/22-sec-headers/index.js`:
      `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`,
      `Cross-Origin-Opener-Policy`, `Report-To`, etc.
- [ ] SSL/TLS mode = **Full**.
- [ ] Lower Route53 TTLs (60s) a day ahead for fast rollback.
- [ ] GitHub → Settings → Pages → Custom domain = `www.jrussell.ie`; wait for the
      Let's Encrypt cert (grey-cloud `www` temporarily if issuance stalls behind the
      proxy, then re-enable orange). Enable **Enforce HTTPS**.
- [ ] Setting the custom domain above makes `actions/configure-pages` emit
      `base_url = https://www.jrussell.ie` automatically — no workflow change needed for
      the URL. Just enable the `push: main` trigger in `pages.yml` for auto-publish.
- [ ] **Cutover:** change nameservers at the `.ie` registrar from Route53 → Cloudflare.

## Verify (post-cutover)

- [ ] `curl -sI https://www.jrussell.ie` → 200, HTTPS, security headers present.
- [ ] Mozilla Observatory grade at parity with the old A+.
- [ ] `dig NS/MX/TXT/www jrussell.ie` reflect Cloudflare.
- [ ] **Send + receive a test email** on @jrussell.ie.

## Rollback

Revert nameservers at the registrar to the four Route53 NS (zone kept intact until Phase 3
teardown). AWS S3/CloudFront stay live throughout Phase 2 as the fallback origin.
