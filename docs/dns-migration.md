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
| TXT | _dmarc.jrussell.ie | (none) | no DMARC currently — add post-cutover (Phase 2b) |
| TXT | google._domainkey | (none) | **DKIM confirmed OFF** in Google Admin ("Not authenticating email") — nothing to replicate; enable post-cutover (Phase 2b) |

**Email surface to preserve = the 5 MX records + the one SPF TXT only.** DKIM and DMARC
are not configured today, so there is nothing to carry over — which keeps the risky part
of the cutover small. Both are added *after* the move as a deliverability improvement
(Phase 2b), so they are entered exactly once, in their final DNS home (Cloudflare).

## Phase 0 — export the authoritative zone (source of truth)

Run with AWS access to the account holding the zone and commit the raw output next to this
file, so nothing is missed (records added outside Terraform won't appear in `iac/`):

```bash
ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name jrussell.ie \
  --query 'HostedZones[0].Id' --output text)
aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID" \
  > docs/route53-jrussell-zone-export.json
```

Checked **Google Workspace Admin** (Apps → Google Workspace → Gmail → Authenticate
email): DKIM status is **"Not authenticating email"** — no record generated, so there is
no DKIM TXT to export. (Confirmed 2026-07-10.)

## Phase 2 — Cloudflare setup (do NOT change nameservers until verified)

- [ ] Add `jrussell.ie` to Cloudflare (free). Let it import, then reconcile against the
      export — the **5 MX records + the SPF TXT** must all be present, DNS-only (grey
      cloud). (No DKIM/DMARC records exist yet — those come in Phase 2b.)
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

## Phase 2b — enable email authentication (DKIM + DMARC), post-cutover

Optional deliverability improvement, done **only after** Cloudflare is authoritative and
email is verified working — so each record is entered exactly once, in its final home.
Neither is required to keep email flowing; do not start this until the cutover is stable.

- [ ] **DKIM** — Google Admin → Apps → Google Workspace → Gmail → Authenticate email →
      select `jrussell.ie` → **Generate new record** (default 2048-bit, selector
      `google`). Add the generated TXT in **Cloudflare** (`google._domainkey`, DNS-only),
      then click **Start authentication**. Verify: `dig +short TXT google._domainkey.jrussell.ie`.
- [ ] **DMARC** — after DKIM + SPF both pass, add a `_dmarc` TXT in Cloudflare, starting
      in monitor mode: `v=DMARC1; p=none; rua=mailto:<report-address>`. Tighten to
      `p=quarantine` / `p=reject` later once reports look clean.
- [ ] Re-send a test email and confirm SPF + DKIM + DMARC all `pass` in the recipient's
      "show original" headers.

## Rollback

Revert nameservers at the registrar to the four Route53 NS (zone kept intact until Phase 3
teardown). AWS S3/CloudFront stay live throughout Phase 2 as the fallback origin.
