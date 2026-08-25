+++
title = "jci-audit: Getting Started"
description = "Install jci-audit, scaffold a deny.toml policy, and wire the PR/dev and release gates."
weight = 20

[taxonomies]
tags = ["Rust", "CircleCI", "Security", "CLI", "Orb", "documentation"]
+++

jci-audit orchestrates `cargo audit` and `cargo deny` as subprocesses rather than bundling them —
install both alongside it.

## Installation

### With cargo-binstall (pre-compiled binary)

```bash
cargo binstall jci-audit
cargo binstall cargo-audit cargo-deny
```

### From crates.io

```bash
cargo install jci-audit
cargo install cargo-audit cargo-deny
```

Every subcommand that shells out to either tool checks for it first and reports, with actionable
install guidance, if it's missing.

---

## Scaffold a policy with `init`

```bash
jci-audit init
```

Writes a standard `deny.toml` (advisories, licenses, bans, sources) plus the `.cargo/audit.toml`
derived from it, into the current directory. It refuses to overwrite an existing `deny.toml`
unless you pass `--force`. The template denies all licenses except an explicit allow-list, and
leaves `[advisories].ignore` empty — see the
[Configuration Guide](@/projects/jci-audit/configuration-guide.md) for what each section means.

---

## Run the PR/dev gate

```bash
jci-audit check
```

Runs `cargo deny check advisories bans licenses sources` (policy), a **live** `cargo audit` scan
(fresh RustSec advisories), and a check that `about.toml` still matches `deny.toml`'s license
policy — all three independently blocking, aggregated so a failure in one never hides another.
Wire this into your CI's validation workflow.

---

## Keep derived files in sync

`.cargo/audit.toml`, and every crate's `about.toml` if you use
[`cargo-about`](https://github.com/EmbarkStudios/cargo-about) for license notices, are **derived**
from `deny.toml` — never hand-edit them:

```bash
jci-audit sync             # regenerate
jci-audit sync --check     # CI: fail instead of writing, if they've drifted
```

Add `sync --check` to your validation workflow so a hand-edit to either derived file — or a
`deny.toml` change nobody re-synced — surfaces as a failing check.

---

## Catch ignores that no longer fire

```bash
jci-audit prune --check
```

`deny.toml [advisories].ignore` accumulates over time — an advisory gets fixed upstream, or a
dependency is dropped, and its ignore entry just sits there, no longer doing anything. `prune`
runs audit/deny against the naked advisory-db (no local ignores applied) and flags any configured
ignore that no longer fires, so stale entries get noticed and removed instead of quietly
accumulating.

---

## Run the release gate

```bash
jci-audit release --release-version 1.2.0
```

Locks `cargo-deny` to a **pinned advisory-db commit** and runs it offline for reproducibility,
then runs a **live** `cargo audit` as a non-blocking currency check, and writes
`.security/release-1.2.0.json` — a record of exactly what was checked.

To confirm a past release still checks out against what's on disk today:

```bash
jci-audit verify --release-version 1.2.0
```

Run this from a checkout of the released tag.

---

## See Also

- [Configuration Guide](@/projects/jci-audit/configuration-guide.md) — the `deny.toml`/`about.toml` fields jci-audit interacts with
- [Advanced Configuration Guide](@/projects/jci-audit/advanced-configuration.md) — the release record's storage model, advisory-db overrides, troubleshooting
- [CLI Reference](@/projects/jci-audit/cli-reference.md) — full command and option documentation
- [Repository](https://github.com/jerus-org/jci-audit) — source, docs, and issue tracking
