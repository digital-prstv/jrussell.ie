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
| TXT | _dmarc.jrussell.ie | (none) | no DMARC at capture time — added post-cutover (Phase 2b, now live) |
| TXT | google._domainkey | (none) | **DKIM confirmed OFF** in Google Admin ("Not authenticating email") — nothing to replicate; enabled post-cutover (Phase 2b, now live) |

The table above is the **pre-cutover snapshot**, kept as the historical source of truth for
what had to be replicated. For what is live today see [Phase 2b](#phase-2b--enable-email-authentication-dkim--dmarc-post-cutover).

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

## Phase 2b — enable email authentication (DKIM + DMARC), post-cutover — **DONE**

Deliverability improvement, done **only after** Cloudflare became authoritative and email
was verified working — so each record was entered exactly once, in its final home. Neither
is required to keep email flowing.

- [x] **DKIM** — Google Admin → Apps → Google Workspace → Gmail → Authenticate email →
      select `jrussell.ie` → **Generate new record** (default 2048-bit, selector
      `google`). Added the generated TXT in **Cloudflare** (`google._domainkey`, DNS-only),
      then **Start authentication**. Verify: `dig +short TXT google._domainkey.jrussell.ie`.
- [x] **DMARC** — added a `_dmarc` TXT in Cloudflare in monitor mode (2026-07-11), with
      `rua` pointing at **Cloudflare DMARC Management** (reports are parsed into the
      dashboard rather than delivered to a mailbox).
- [x] Test email re-sent; SPF + DKIM + DMARC all `pass` in the recipient's "show
      original" headers.

### Live email-auth records (verified 2026-07-27)

| Record | Value |
|--------|-------|
| SPF (apex TXT) | `v=spf1 include:_spf.google.com ~all` |
| DKIM `google._domainkey` | `v=DKIM1; k=rsa; p=…` (2048-bit, selector `google`) |
| DMARC `_dmarc` | `v=DMARC1; p=reject; rua=mailto:<id>@dmarc-reports.cloudflare.net` |

Only sending path is Google Workspace, which signs with DKIM and is covered by the SPF
include — so both mechanisms align and no third-party sender needs authorising. This is a
personal account: there are **no** `Send mail as` aliases and no application or service
that sends notification mail using an `@jrussell.ie` identity.

**SPF stays at `~all`, deliberately** — do not "fix" the `Soft fail — Warning` badge in the
Cloudflare dashboard. DMARC treats softfail and hardfail identically (both are a non-`pass`,
so evaluation falls through to DKIM and then to the policy), which means `-all` adds nothing
now that the policy is `reject`. Where the two differ is receivers that act on the SPF result
alone: forwarded mail always fails SPF, because the relay sends from its own IP, and only the
surviving DKIM signature rescues it. `~all` allows that rescue; `-all` invites a strict
receiver to reject before DKIM is considered.

### DMARC enforcement ladder

Reports are reviewed in **Cloudflare → Email Security → DMARC Management → jrussell.ie**
before each tightening step. Review means: every legitimate source shows an *aligned* pass,
and no unexpected sender appears. Forwarders are the usual false positive — they break SPF
but survive on DKIM, so they only matter if DKIM fails too.

| Step | Policy | Date | Status |
|------|--------|------|--------|
| Monitor | `p=none` | 2026-07-11 | done — ~2 weeks of clean reports, Google Workspace only |
| Enforce (quarantine) | `p=quarantine` | 2026-07-27 | done — superseded same day |
| Enforce (reject) | `p=reject` | 2026-07-27 | **live** — verified by `dig` against the Cloudflare and Google resolvers and the authoritative NS |

No `pct=` ramp was used at either step: with a single DKIM-signed sending path a ramp only
adds weeks of waiting without yielding new information. If a legitimate-but-unaligned source
ever shows up, the fix is an SPF include or its own DKIM key — not a weaker policy.

**Report evidence at the reject decision** (Cloudflare DMARC Management, 7 days to
2026-07-27, 16 messages):

- **1 pass** — Google LLC, 100% SPF-aligned and 100% DKIM-aligned.
- **15 fails** — 15 distinct sending services, each 1–2 messages from a single IP, all 0%
  on SPF, DKIM and DMARC: consumer/mobile ISPs in Kazakhstan, Uzbekistan, China, Iran,
  Brazil, Argentina, Indonesia and India. Classic snowshoe spoofing of the domain.

Crucially **none** of the failures showed the forwarder signature (SPF fail + DKIM *pass*),
so no legitimate relayed mail was in the failing set. Every failure was forgery — exactly
the mail `p=reject` should bounce. The quarantine step was skipped forward to reject on the
same day once it was confirmed there are no `Send mail as` aliases and no service accounts
sending as the domain, which removed the only open question (a rarely-used legitimate path
that had not yet appeared in a report).

**Residual watch-item — mailing lists.** The one real-world risk left at `p=reject` for a
personal domain: a list that resends a message unchanged breaks the DKIM signature, so
receivers now bounce it, and some lists auto-unsubscribe bouncing addresses. Most modern
lists rewrite `From:` (or apply ARC) and are unaffected, and no forwarding pattern appears
in the reports. If it ever bites, the fix is list-side `From:` munging — not a weaker policy.

## Rollback

Revert nameservers at the registrar to the four Route53 NS (zone kept intact until Phase 3
teardown). AWS S3/CloudFront stay live throughout Phase 2 as the fallback origin.
