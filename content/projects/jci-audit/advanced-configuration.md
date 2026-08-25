+++
title = "jci-audit Advanced Configuration"
description = "The release record's storage model, advisory-db overrides, and troubleshooting a verify mismatch."
weight = 35

[taxonomies]
tags = ["Rust", "CircleCI", "Security", "CLI", "Orb", "documentation"]
+++

Less common configuration: how the release record is stored today, overriding the advisory-db
location, and troubleshooting a `verify` mismatch. See the
[Configuration Guide](@/projects/jci-audit/configuration-guide.md) for the subset of
`deny.toml`/`about.toml` fields jci-audit interacts with.

---

## The release record is local-only, for now

`jci-audit release` writes `.security/release-<VERSION>.json` to the working directory and does
nothing else with it — no git commit, no push, no signing. Earlier versions committed and
GPG-signed the record via [`pcu`](https://crates.io/crates/pcu); that path is gone
([jerus-org/jci-audit#75](https://github.com/jerus-org/jci-audit/issues/75) phase 1). Distributing
the record as a signed GitHub release asset (verified via `rsign` in `verify`'s remote-fetch path)
is tracked as #75's remaining phase and not yet shipped.

---

## Overriding the advisory-db location

`release` and `verify` both accept `--advisory-db <PATH>`, treated the same way: it's the
advisory-db **root** (not a specific checkout), passed straight through to `deny.toml`'s
`[advisories].db-path` — the directory beneath which `cargo-deny` nests its own managed checkout
as `advisory-db-<hash>`. Default `~/.cargo/advisory-db`.

- **`release`** discovers/refreshes that checkout and pins the release to its resulting commit.
- **`verify`** discovers the existing checkout beneath the given root and moves it to the commit
  recorded in `.security/release-<VERSION>.json`.

Pointing either flag at a specific pre-checked-out commit directory (rather than its parent) is a
common mistake — you'll see `no advisory-db checkout found under '<path>'`, since jci-audit looks
one level down for the `advisory-db-<hash>` subdirectory.

---

## `--deny-warnings`

Present on `check`, `release`, and `verify`. `cargo-deny` reports some conditions (e.g.
`unmaintained = "all"`) as warnings rather than hard errors by default. Pass `--deny-warnings` to
escalate every warning to a failure. Without it, warnings are still surfaced (counted and printed)
but don't affect the exit code.

---

## Troubleshooting a `verify` mismatch

`jci-audit verify --release-version <V>` prints one line per input it couldn't verify or that
didn't match, then a final verdict:

```
verifying release 1.2.0 against advisory-db <commit>
  not verified: <schema too old to check this input>
reproduced: the release passes the gate against its recorded snapshot
```

On a real mismatch, verification fails instead — no `reproduced` line is printed once any
`MISMATCH` is found:

```
verifying release 1.2.0 against advisory-db <commit>
  MISMATCH: <what didn't match>
Error: verification failed: inputs do not match the record
```

- **`not verified` lines** are not failures — they mean the record predates that field (e.g. a
  `schema_version: 1` record has no `deny.toml` policy digest to compare) and are reported
  honestly rather than silently skipped.
- **`MISMATCH` lines** mean something genuinely differs between the record and the checkout.
  Common causes, in order of likelihood:
  1. **Wrong checkout.** `verify` reads the current working tree, not the tag's tree — check out
     the exact tag (`git checkout jci-audit-v<VERSION>`) and re-run.
  2. **`Cargo.lock` changed since release.** The dependency-set digest covers the external package
     set, so this means a real third-party dependency actually differs from what was released.
  3. **`deny.toml`/`about.toml` changed since release** without a new release being cut.

Two other failure modes print no `MISMATCH` line at all:

- **The advisory-db commit is unreachable** (garbage-collected, or the checkout was never made) —
  `verify` fails outright before any comparison output prints. Re-fetch the advisory-db
  (`cargo deny fetch`, or re-run `jci-audit check`/`release` once to let cargo-deny refresh it) and
  retry.
- **Every recorded input still matches, but the gate's pass/fail verdict doesn't** — e.g. a newer
  `cargo-deny` evaluates the same pinned inputs differently than the one that produced the record.
  `verify` still prints its `verifying release ...` banner and any `not verified` lines, then fails
  with `verification failed: the gate did not reproduce the recorded verdict` instead of printing
  `reproduced`. There's nothing to search for in the output here — the inputs genuinely agree; the
  tool's own behavior is what changed.

---

## Multi-crate workspaces

`sync`'s `about.toml` derivation already scopes each crate's `accepted` list to its own dependency
graph. Two related limitations are tracked, not yet implemented:

- **License scope always includes build dependencies**, regardless of `about.toml`'s own
  `ignore-build-dependencies`/`ignore-transitive-dependencies` settings
  ([#63](https://github.com/jerus-org/jci-audit/issues/63)).
- **`release`/`verify` don't yet support per-crate ordering** for a workspace with multiple
  publishable crates and dependencies between them
  ([#62](https://github.com/jerus-org/jci-audit/issues/62)).

---

## See Also

- [Getting Started](@/projects/jci-audit/getting-started.md) — install to running pipeline
- [Configuration Guide](@/projects/jci-audit/configuration-guide.md) — the `deny.toml`/`about.toml` fields jci-audit interacts with
- [CLI Reference](@/projects/jci-audit/cli-reference.md) — full command and option documentation
- [Repository](https://github.com/jerus-org/jci-audit) — source, docs, and issue tracking
