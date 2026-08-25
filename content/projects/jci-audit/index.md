+++
title = "jci-audit"
description = "A context-aware Rust security gate orchestrating cargo-audit and cargo-deny, with reproducible release-time validation against a pinned advisory-db commit."
weight = 17

[taxonomies]
tags = ["Rust", "CircleCI", "Security", "CLI", "Orb"]

[extra]
pinned = true
quick_navigation_buttons = true
local_image = "projects/jci-audit/jci-audit-logo.webp"
+++

**jci-audit** orchestrates [`cargo-audit`](https://crates.io/crates/cargo-audit) and
[`cargo-deny`](https://crates.io/crates/cargo-deny) — two tools with complementary strengths that
rarely run together in the same gate. `cargo audit` checks live, fresh RustSec advisories;
`cargo deny` enforces policy (advisories, bans, licenses, sources) through file-based ignores that
carry a written justification. jci-audit runs both, and treats `deny.toml` as the single source of
truth: `.cargo/audit.toml` and every crate's `about.toml` are derived from it, never maintained by
hand in parallel.

Release validation is where this differs most from a plain CI check: `cargo deny` locks to a
**pinned advisory-db commit** and runs offline, so a release's security gate can be independently
reproduced later — not just asserted once and trusted. `cargo audit` keeps running live alongside
it, as a non-blocking currency check. `jci-audit verify` re-derives a past release's recorded
inputs from a real checkout and confirms it still passes under the exceptions in force at the
time; a no-checkout path that fetches and signature-checks the record straight from a published
release is designed in but not yet wired up end to end (the release side doesn't sign and upload
the record yet — see the [Advanced Configuration Guide](@/projects/jci-audit/advanced-configuration.md)).

jci-audit ships a crate to crates.io and a generated CircleCI orb, `jerus-org/jci-audit`, in
tag-lockstep — the orb is produced by [gen-circleci-orb](@/projects/gen-circleci-orb/index.md)
from the CLI's own `--help` output, so its jobs never drift from the binary. It is deliberately a
**bin-only** publish: nothing links `jci-audit` as a library, so the published crate carries no
importable `[lib]` target.

[Getting Started](@/projects/jci-audit/getting-started.md)

[Configuration Guide](@/projects/jci-audit/configuration-guide.md)

[Advanced Configuration Guide](@/projects/jci-audit/advanced-configuration.md)

[CLI Reference](@/projects/jci-audit/cli-reference.md)
