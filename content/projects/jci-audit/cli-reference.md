+++
title = "jci-audit CLI Reference"
description = "Full CLI reference for jci-audit — check, release-prep, sync, prune, verify, init, wire-ci, check-ci-wiring, and publish-record."
weight = 25

[taxonomies]
tags = ["Rust", "CircleCI", "Security", "CLI", "Orb", "documentation"]
+++

| Subcommand | Runs in | Purpose |
|------------|---------|---------|
| `check` | PR gate (CI), local to validate | `cargo-deny` policy, live `cargo-audit`, license-policy drift/resolution, all blocking |
| `release-prep` | Release gate (CI) | Reproducible validation against a pinned advisory-db |
| `sync` | `about.toml` half runs inside `check`; full sync is its own CI/local step | Derive `.cargo/audit.toml`/`about.toml` from `deny.toml` |
| `prune` | Orb job (any workflow), or local | Detect advisory ignores that no longer fire |
| `verify` | Local, from a released tag, or remote with no checkout | Re-check a past release against a real checkout, or a published release's signed record |
| `init` | Local, one-time scaffold | Write the standard `deny.toml` template, or add its missing keys to yours |
| `wire-ci` | Local, one-time or on drift | Wire the generated orb's job(s) into a consumer's CircleCI config |
| `check-ci-wiring` | PR gate (CI), local to validate | Detect drift between the CI config and what `wire-ci` would generate |
| `publish-record` | Release gate (CI) | Sign and upload a release-prep record as release assets |

Global flags on every subcommand: `-v`/`--verbose` and `-q`/`--quiet` (repeatable, adjust logging),
`-h`/`--help`, `-V`/`--version`.

## `check` — PR/dev gate

Runs `cargo-deny` policy checks, a live `cargo-audit` scan, a check that `about.toml` still
matches `deny.toml`'s license policy, and a check that `cargo-about` can resolve every
dependency's license — all four blocking; exit codes aggregated and stderr surfaced, a failure in
one never hides another.

```
jci-audit check [OPTIONS]

Input:
  --manifest-path <MANIFEST_PATH>   Path to the Cargo.toml (or its directory) to check [default: .]

Output:
  --deny-stale-exceptions   Fail if a configured [[bans.skip]] exception no longer fires
  --deny-unused-licenses    Fail if deny.toml allows a license nothing in the graph uses
  --deny-stale-notices      Fail if the license set changed since the committed notices — only
                             fails on a license substituted or added; a version bump or a new
                             dependency under an already-accepted license warns instead
  --deny-warnings           Fail if the tools report any warning
```

## `release-prep` — Release gate

Locks `cargo-deny` to a pinned advisory-db commit and runs it offline; `cargo-audit` runs live as
a non-blocking currency check. Writes the record to `.security/release-<VERSION>.json` **in the CI
job's own working directory** — it is not committed, signed, or pushed by this step. Persist it to
the workspace and hand it to `publish-record` to get a signed, durable copy — see the
[Advanced Configuration Guide](@/projects/jci-audit/advanced-configuration.md).

```
jci-audit release-prep [OPTIONS] <VERSION>

Arguments:
  <VERSION>   The release version being validated (e.g. "1.2.0")

Security:
  --advisory-db <ADVISORY_DB>   Advisory-db root; cargo-deny's checkout lives beneath it
                                 [default: ~/.cargo/advisory-db]

Input:
  -p, --package <PACKAGE>   The crate's package name (its [package].name in Cargo.toml). Scopes
                             the dependency digest and the record's own path to just this crate's
                             reachable graph, for a multi-crate workspace releasing individually.
                             Omit for a single-crate workspace's whole-graph record

Output:
  --deny-warnings   Fail if the tools report any warning
```

## `sync` — Derive `.cargo/audit.toml`/`about.toml` from `deny.toml`

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

Re-derives a past release's recorded inputs and compares them against what's on disk (or, with no
local record and `--owner`/`--repo`/`--tag-prefix`, fetches and signature-checks a published
release's record instead — no checkout needed for that path). Run the local-checkout form from a
checkout of the released tag.

```
jci-audit verify [OPTIONS] <VERSION>

Arguments:
  <VERSION>   The released version to verify (e.g. "1.2.0")

Security:
  --advisory-db <ADVISORY_DB>   Advisory-db root; the checkout is moved to the recorded commit

Remote release (no local record found):
  --owner <OWNER>            GitHub repository owner that published the release (e.g. "jerus-org")
  --repo <REPO>               GitHub repository name that published the release (e.g. "jci-audit")
  --tag-prefix <TAG_PREFIX>   Release tag prefix (e.g. "jci-audit-v"); combined with the version to
                               form the tag to fetch

Input:
  -p, --package <PACKAGE>   The crate's package name. Must match whatever `release-prep --package`
                             (if any) the record was written under

Output:
  --deny-warnings   Fail if the tools report any warning
```

## `init` — Scaffold a standard `deny.toml`

Writes a standard `deny.toml` and the `.cargo/audit.toml` derived from it. Non-interactive — edit
`deny.toml` afterwards for anything project-specific.

With a `deny.toml` already in place, `init` adds the standard keys it lacks and lists each one;
nothing already in the file is changed or removed, so your ignores, license exceptions and
comments stay as written. Each added key is a default you can edit or delete — jci-audit runs
without any of them except `[licenses] allow`, which cargo-deny itself needs to admit any
license. A file that already has every key is left untouched.

`.cargo/audit.toml` is derived from the resulting `deny.toml`, so your existing advisory ignores
carry into it. If an `audit.toml` already exists and differs, `init` overwrites it and warns that
it did: it is kept in sync with `deny.toml` from then on, so make changes in `deny.toml`, not in
`audit.toml`.

```
jci-audit init [OPTIONS]

Options:
  --force   Replace an existing deny.toml with the standard template instead of adding to it
```

## `wire-ci` — Wire the orb into your CircleCI config

Writes (or resyncs) the managed job block for whichever `jci-audit.toml`-declared jobs need
wiring, generated from the orb's own published job definitions — so the config never drifts from
what the CLI's own `--help` output describes.

```
jci-audit wire-ci [OPTIONS]

Input:
  --config <CONFIG>   Path to the jci-audit.toml-shaped wiring spec to read (and, if it has no
                       [[ci.jobs]] entries yet, scaffold an example into)

Scaffold (first run only):
  --workflow <WORKFLOW>                  Which workflow the example check job joins
  --deny-unused-licenses <true|false>    Whether the example enables --deny-unused-licenses
  --deny-stale-exceptions <true|false>   Whether the example enables --deny-stale-exceptions
  --deny-stale-notices <true|false>      Whether the example enables --deny-stale-notices
```

The four scaffold flags only shape the first-run `jci-audit.toml`, never one that already exists.
With a terminal attached and nothing set, scaffolding prompts for the workflow (offering any
workflow names already in your CircleCI config, alongside `validation`) and each check flag. With
no terminal (a script, a redirected stderr) it uses the defaults instead of prompting:
`validation`, `deny_unused_licenses` and `deny_stale_exceptions` on, `deny_stale_notices` off. Set
the flags to choose something else.

`wire-ci` writes files and is for local use. It refuses to run when `$CI` is set (anything but
empty, `false` or `0`) and exits non-zero, because a CI job running it would only change its own
throwaway checkout. In CI, use `check-ci-wiring`.

## `check-ci-wiring` — Detect CI-wiring drift

Check-only — takes no `--check` flag, because it never writes; a mismatch just fails. Run it in
your PR gate so a manual edit to the managed CI region, or an orb version bump, gets caught before
`wire-ci` needs to be re-run.

```
jci-audit check-ci-wiring [OPTIONS]

Input:
  --config <CONFIG>   Path to the jci-audit.toml-shaped wiring spec to read. Same resolution rules
                       as wire-ci --config
```

## `publish-record` — Sign and upload the release record

Self-contained: generates a one-use minisign keypair, signs a `release-prep`-written record, and
uploads the record/`.sig`/`.pub` as assets on the given release tag. The private key never leaves
this one job. Needs a GitHub token with permission to upload (and, with `--publish`, publish) the
release — supply that via CI context/env, never as a command-line argument.

```
jci-audit publish-record [OPTIONS] --tag <TAG> --owner <OWNER> --repo <REPO> <VERSION>

Arguments:
  <VERSION>   The release version whose record to publish (e.g. "1.2.0")

Remote release:
  --tag <TAG>       The exact release tag to attach assets to (e.g. "myapp-v1.2.0")
  --owner <OWNER>   GitHub repository owner that owns the release
  --repo <REPO>     GitHub repository name that owns the release

Record:
  --publish              Un-draft the release once the assets are attached
  --record-path <PATH>   Where to find the record to sign and upload
```

## See Also

- [Getting Started](@/projects/jci-audit/getting-started.md) — install to running pipeline
- [Configuration Guide](@/projects/jci-audit/configuration-guide.md) — the `deny.toml`/`about.toml` fields jci-audit interacts with
- [Advanced Configuration Guide](@/projects/jci-audit/advanced-configuration.md) — release record storage, advisory-db overrides, troubleshooting
- [Repository](https://github.com/jerus-org/jci-audit) — source, docs, and issue tracking
