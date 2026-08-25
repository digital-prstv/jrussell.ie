+++
title = "jci-audit CLI Reference"
description = "Full CLI reference for jci-audit — check, release, sync, prune, verify, and init."
weight = 25

[taxonomies]
tags = ["Rust", "CircleCI", "Security", "CLI", "Orb", "documentation"]
+++

jci-audit orchestrates cargo-audit and cargo-deny per pipeline context: `check` gates PRs on both
tools, `release` validates reproducibly against a pinned advisory-db, `sync` derives
`.cargo/audit.toml` from the canonical `deny.toml`, `prune` detects stale advisory ignores,
`verify` re-checks a past release, and `init` scaffolds a standard `deny.toml`.

```
jci-audit [OPTIONS] <COMMAND>

Options:
  -v, --verbose...   Increase logging verbosity
  -q, --quiet...     Decrease logging verbosity
  -h, --help         Print help
  -V, --version      Print version
```

## `check` — PR/dev gate

Runs `cargo-deny` policy checks plus a live `cargo-audit` scan. Both blocking; exit codes
aggregated and stderr surfaced.

```
jci-audit check [OPTIONS]

Options:
  --manifest-path <PATH>   Path to the Cargo.toml (or its directory) to check [default: .]
  --deny-warnings          Fail if the tools report any warning
```

## `release` — Release gate

Locks `cargo-deny` to a pinned advisory-db commit and runs it offline; `cargo-audit` runs live as
a non-blocking currency check. Writes the record locally to `.security/release-<VERSION>.json`.

```
jci-audit release [OPTIONS]

Options:
  --release-version <VERSION>   The release version being validated (e.g. "1.2.0")
  --version-env <VAR>           Env var holding the release version, used when
                                 --release-version is omitted [default: SEMVER]
  --advisory-db <PATH>          Advisory-db root; cargo-deny's checkout lives beneath it
                                 [default: ~/.cargo/advisory-db]
  --deny-warnings               Fail if the tools report any warning
```

## `sync` — Derive `.cargo/audit.toml` from `deny.toml`

```
jci-audit sync [OPTIONS]

Options:
  --check   Fail (non-zero) on drift instead of rewriting the file. For CI
```

## `prune` — Stale-ignore detector

Runs audit/deny against the naked advisory-db (no local ignores applied) to find configured
ignores that no longer fire.

```
jci-audit prune [OPTIONS]

Options:
  --check   Fail (non-zero) when a stale ignore is found. For CI
```

## `verify` — Re-verify a past release

Uses the policy (`deny.toml`) that was in force at release time. Run it from a checkout of the
released tag.

```
jci-audit verify [OPTIONS] --release-version <VERSION>

Options:
  --release-version <VERSION>   The released version to verify (e.g. "1.2.0")
  --advisory-db <PATH>          Advisory-db root; the checkout is moved to the recorded commit
                                 [default: ~/.cargo/advisory-db]
  --deny-warnings               Fail if the tools report any warning
```

## `init` — Scaffold a standard `deny.toml`

Non-interactive — every value in the template is fixed; edit the written files afterwards for
anything project-specific.

```
jci-audit init [OPTIONS]

Options:
  --force   Overwrite existing files without confirmation
```

## See Also

- [Getting Started](@/projects/jci-audit/getting-started.md) — install to running pipeline
- [Configuration Guide](@/projects/jci-audit/configuration-guide.md) — the `deny.toml`/`about.toml` fields jci-audit interacts with
- [Advanced Configuration Guide](@/projects/jci-audit/advanced-configuration.md) — release record storage, advisory-db overrides, troubleshooting
- [Repository](https://github.com/jerus-org/jci-audit) — source, docs, and issue tracking
