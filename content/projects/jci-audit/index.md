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

## Architecture

jci-audit is built as three components, deliberately kept distinct even though two of them
currently ship together:

1. **The CLI** — the `jci-audit` binary. Replaces ad hoc bash scripts: `init` scaffolds the
   policy, and `check`/`release`/`sync`/`prune`/`verify` are the actual CI-service operations it
   runs. Independently published to crates.io — the only one of the three with no CI-runner
   dependency.
2. **The container** — the execution environment the binary needs (`cargo-audit`, `cargo-deny`,
   `rsign`, on an official Rust base).
3. **CI-runner scripting** — currently CircleCI only: the commands, jobs, and executor that load
   the container and invoke the CLI's operations as pipeline steps.

Components 2 and 3 currently ship together, generated as a single CircleCI orb by
[gen-circleci-orb](@/projects/gen-circleci-orb/index.md) — there's no path yet to reuse the same
container with a different CI runner's scripting. The three-way split is what would make a future
non-CircleCI runner a scripting-layer addition rather than a rewrite, once 2 and 3 are decoupled.

`jci-audit verify`'s no-checkout path additionally assumes a GitHub-hosted repository (it fetches
release assets and raw file contents from `github.com`) — a CLI-level constraint separate from the
CI-runner question above.

[Getting Started](@/projects/jci-audit/getting-started.md)

[Configuration Guide](@/projects/jci-audit/configuration-guide.md)

[Advanced Configuration Guide](@/projects/jci-audit/advanced-configuration.md)

[CLI Reference](@/projects/jci-audit/cli-reference.md)
