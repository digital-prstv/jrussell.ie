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

## How the release record is stored and retrieved

`jci-audit release-prep` writes `.security/release-<VERSION>.json` to the working directory and
does nothing else with it there — no git commit, no push, no signing. "Local" means **the CI
job's own ephemeral working directory** — not your repo clone, and not the GitHub release. A
subsequent job needs the record handed to it explicitly.

`jci-audit publish-record` is that handoff: it generates a one-use minisign keypair, signs the
record, and uploads the record/`.sig`/`.pub` as named assets on the release — a fully
self-contained path ([jerus-org/jci-audit#75](https://github.com/jerus-org/jci-audit/issues/75)
phase 2) needing nothing beyond this orb and a GitHub token with permission to upload (and,
with `--publish`, publish) the release. `verify`'s remote-fetch path then fetches and
signature-checks that record with no local checkout at all. The full three-job chain:

```yaml
workflows:
  release:
    jobs:
      - jci-audit/release_prep:
          name: record-release
          version: "1.2.0"
          post-steps:
            - persist_to_workspace:
                root: .
                paths: [.security]

      - your-draft-release-job:
          requires: [record-release]

      - jci-audit/publish_record:
          name: publish-security-record
          requires: [your-draft-release-job]
          context: [github-release-write]
          attach_workspace: true
          version: "1.2.0"
          tag: "myapp-v1.2.0"
          owner: "your-org"
          repo: "your-repo"
          record_path: "/tmp/workspace/.security/release-1.2.0.json"
          publish: true
```

`release_prep` persists the record to the workspace rather than committing it; `publish_record`
attaches that workspace, signs the persisted record, and uploads it once your own job has created
the (draft) release to attach assets to. The private signing key is generated, used, and discarded
entirely inside the `publish_record` job — it never appears in the record's own job or in any
other step. Set the GitHub token via a context on the `publish_record` job, never as a parameter,
so it never appears on a command line or in a CI log.

Every jci-audit release since `jci-audit-v0.1.1` uses this path — see
[jerus-org/jci-audit's own `.circleci/release.yml`](https://github.com/jerus-org/jci-audit/blob/main/.circleci/release.yml)
for the real, currently-running wiring. The crate's currently published version
(`cargo info jci-audit` or [crates.io](https://crates.io/crates/jci-audit)) is not yanked, and its
record is retrievable through this path — the historical retention gap described in earlier
drafts of this guide (`jci-audit-v0.1.0`'s record was genuinely lost, before `publish-record`
existed) no longer applies to any release cut since.

---

## Overriding the advisory-db location

`release-prep` and `verify` both accept `--advisory-db <PATH>`, treated the same way: it's the
advisory-db **root** (not a specific checkout), passed straight through to `deny.toml`'s
`[advisories].db-path` — the directory beneath which `cargo-deny` nests its own managed checkout
as `advisory-db-<hash>`. Default `~/.cargo/advisory-db`.

- **`release-prep`** discovers/refreshes that checkout and pins the release to its resulting commit.
- **`verify`** discovers the existing checkout beneath the given root and moves it to the commit
  recorded in `.security/release-<VERSION>.json`.

Pointing either flag at a specific pre-checked-out commit directory (rather than its parent) is a
common mistake — you'll see `no advisory-db checkout found under '<path>'`, since jci-audit looks
one level down for the `advisory-db-<hash>` subdirectory.

---

## `--deny-warnings`

Present on `check`, `release-prep`, and `verify`. `cargo-deny` reports some conditions (e.g.
`unmaintained = "all"`) as warnings rather than hard errors by default. Pass `--deny-warnings` to
escalate every warning to a failure. Without it, warnings are still surfaced (counted and printed)
but don't affect the exit code.

---

## Troubleshooting a `verify` mismatch

`jci-audit verify <VERSION>` prints one line per input it couldn't verify or that
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
  (`cargo deny fetch`, or re-run `jci-audit check`/`release-prep` once to let cargo-deny refresh it) and
  retry.
- **Every recorded input still matches, but the gate's pass/fail verdict doesn't** — e.g. a newer
  `cargo-deny` evaluates the same pinned inputs differently than the one that produced the record.
  `verify` still prints its `verifying release ...` banner and any `not verified` lines, then fails
  with `verification failed: the gate did not reproduce the recorded verdict` instead of printing
  `reproduced`. There's nothing to search for in the output here — the inputs genuinely agree; the
  tool's own behavior is what changed.

---

## Multi-crate workspaces

`sync`'s `about.toml` derivation scopes each crate's `accepted` list to its own dependency graph,
and honours that crate's own `about.toml` `ignore-build-dependencies`/`ignore-transitive-dependencies`
settings ([#63](https://github.com/jerus-org/jci-audit/issues/63)) — it does not copy the
workspace-wide policy into every crate verbatim.

`release-prep`/`verify` take a `-p`/`--package <NAME>` flag to scope the dependency digest and the
record's own path (`.security/<package>-release-<VERSION>.json`) to just one crate's reachable
graph, so a workspace can release its crates individually, in dependency order, without different
crates' records colliding in the same pipeline run
([#62](https://github.com/jerus-org/jci-audit/issues/62)). `publish-record` and `verify`'s
remote-fetch path don't take a per-package record path yet — this org's own workspaces are still
single-crate, so that extension is deferred until a real multi-crate consumer needs it.

---

## See Also

- [Getting Started](@/projects/jci-audit/getting-started.md) — install to running pipeline
- [Configuration Guide](@/projects/jci-audit/configuration-guide.md) — the `deny.toml`/`about.toml` fields jci-audit interacts with
- [CLI Reference](@/projects/jci-audit/cli-reference.md) — full command and option documentation
- [Repository](https://github.com/jerus-org/jci-audit) — source, docs, and issue tracking
