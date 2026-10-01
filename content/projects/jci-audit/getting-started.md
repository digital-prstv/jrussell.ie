+++
title = "jci-audit: Getting Started"
description = "Install jci-audit, scaffold a deny.toml policy, and wire the PR/dev and release gates."
weight = 20

[taxonomies]
tags = ["Rust", "CircleCI", "Security", "CLI", "Orb", "documentation"]
+++

jci-audit is a CLI and a CircleCI orb: the CLI (see [Architecture](@/projects/jci-audit/index.md#architecture))
does the actual work — `cargo audit`/`cargo deny` orchestration, policy derivation, reproducible
release validation — and the orb wires it into your pipeline so it runs on every PR and release.
Running the CLI locally is for validating a policy change before you push it, or troubleshooting
something CI reported — not the primary way it's meant to run.

## Installation

### With cargo-binstall (pre-compiled binary)

```bash
cargo binstall jci-audit
cargo binstall cargo-audit cargo-deny cargo-about
```

### From crates.io

```bash
cargo install jci-audit
cargo install cargo-audit cargo-deny cargo-about
```

`cargo-about` is only needed for `jci-audit check`'s license-notices resolution/staleness checks
(see [CLI Reference](@/projects/jci-audit/cli-reference.md)) — skip it if you only run `sync`,
`prune`, or `init`.

Every subcommand that shells out to any of these tools checks for it first and reports, with
actionable install guidance, if it's missing. In CI, the generated orb's container already has
all three — see below.

---

## Scaffold a policy with `init`

```bash
jci-audit init
```

Writes a standard `deny.toml` (advisories, licenses, bans, sources) plus the `.cargo/audit.toml`
derived from it, into the current directory — that's all `init` does. It doesn't sync any crate's
`about.toml` (see [Keep derived files in sync](#keep-derived-files-in-sync) below), and it doesn't
touch your CI config. If you already have a `deny.toml`, `init` adds the standard keys it lacks
and lists each one; your existing settings, comments and exceptions are left as they are
(`--force` replaces the file with the template instead). An existing `.cargo/audit.toml` is
overwritten with the version derived from `deny.toml`, with a warning. The template denies all licenses except an explicit allow-list, and leaves `[advisories].ignore`
empty — see the [Configuration Guide](@/projects/jci-audit/configuration-guide.md) for what each
section means.

**`jci-audit wire-ci` wires the orb into your CircleCI config for you** — it writes (or resyncs)
the managed job block the next section shows by hand, the same way `gen-circleci-orb init`/`update`
does for its own consumers:

```bash
jci-audit wire-ci
jci-audit check-ci-wiring   # CI: fail if the wiring has drifted from what wire-ci would generate
```

On a first run with no `jci-audit.toml`, `wire-ci` asks which workflow the check job should join
and which optional checks to enable, then writes the file for you to review. From a script it
uses defaults, or take `--workflow` and the `--deny-*` flags (see the
[CLI Reference](@/projects/jci-audit/cli-reference.md)). `wire-ci` is for local use and refuses to
run when `$CI` is set; run `check-ci-wiring` in CI.

The next section shows the underlying YAML shape it produces, for when you want to see what's
actually being wired or extend it by hand.

---

## Wire the container and CI scripting (CircleCI)

Add the orb — it currently delivers both the execution container and the CircleCI job
definitions together (see [Architecture](@/projects/jci-audit/index.md#architecture)):

```yaml
version: 2.1

orbs:
  jci-audit: jerus-org/jci-audit@0.1.23

workflows:
  validation:
    jobs:
      - jci-audit/check
```

That's the PR/dev gate. For the release gate, run `jci-audit/release_prep` before your actual
release job and store the record it writes so it's retrievable afterwards — the record lands in
the job's own working directory and isn't committed or pushed (see
[Advanced Configuration](@/projects/jci-audit/advanced-configuration.md)):

```yaml
  release:
    jobs:
      - jci-audit/release_prep:
          name: record-release
          version: "1.2.0"
          post-steps:
            - store_artifacts:
                path: .security
                destination: security-record

      - your-release-job:
          requires: [record-release]
```

`store_artifacts` above keeps the unsigned record attached to the CI job run itself — enough to
inspect it, but not enough for `jci-audit verify`'s no-checkout path, which needs a **signed**
copy published as a GitHub release asset. `jci-audit/publish_record` does that signing and upload;
see the full three-job chain (`release_prep` → your release job → `publish_record`) in the
[Advanced Configuration Guide](@/projects/jci-audit/advanced-configuration.md).

---

## Run the PR/dev gate

```bash
jci-audit check
```

This is what `jci-audit/check` runs in CI. Runs `cargo deny check advisories bans licenses
sources` (policy), a **live** `cargo audit` scan (fresh RustSec advisories), a check that
`about.toml` still matches `deny.toml`'s license policy, and a check that `cargo-about` can
resolve every dependency's license — all four independently blocking, aggregated so a failure in
one never hides another. A fifth, opt-in check (`--deny-stale-notices`) compares a fresh
`cargo-about` render's license names against the committed `THIRD-PARTY-LICENSES.md`: it only
fails if the set grew (a license substituted or added), and warns instead on a version bump or a
new dependency under an already-accepted license — see the
[CLI Reference](@/projects/jci-audit/cli-reference.md) for the full flag list. Run `jci-audit
check` locally to reproduce a CI failure or validate a `deny.toml` change before pushing.

---

## Keep derived files in sync

`.cargo/audit.toml`, and every crate's `about.toml` if you use
[`cargo-about`](https://github.com/EmbarkStudios/cargo-about) for license notices, are **derived**
from `deny.toml` — never hand-edit them:

```bash
jci-audit sync             # regenerate
jci-audit sync --check     # CI: fail instead of writing, if they've drifted
```

`jci-audit check` already checks the `about.toml` half of this as part of the PR gate above — the
`.cargo/audit.toml` drift check is separate and needs its own `sync --check` step in your CI
config. A crate with no `about.toml` isn't required to have one — `sync` simply finds nothing to
derive there and leaves it alone; only crates that already opted in to cargo-about notices are
touched.

---

## Catch ignores that no longer fire

```bash
jci-audit prune --check
```

`deny.toml [advisories].ignore` accumulates over time — an advisory gets fixed upstream, or a
dependency is dropped, and its ignore entry just sits there, no longer doing anything. `prune`
runs audit/deny against the naked advisory-db (no local ignores applied) and flags any configured
ignore that no longer fires, so stale entries get noticed and removed instead of quietly
accumulating. `jci-audit/prune` is a standard orb job — add it to whichever workflow you want (a
PR job, or a scheduled one for early warning on already-shipped lockfiles):

```yaml
      - jci-audit/prune:
          check: true
```

---

## Run the release gate

```bash
jci-audit release-prep 1.2.0
```

This is what `jci-audit/release_prep` runs in CI (see [Wire the container and CI scripting](#wire-the-container-and-ci-scripting-circleci)
above). Locks `cargo-deny` to a **pinned advisory-db commit** and runs it offline for
reproducibility, then runs a **live** `cargo audit` as a non-blocking currency check, and writes
`.security/release-1.2.0.json` — a record of exactly what was checked, in the job's own working
directory.

To confirm a past release still checks out against what's on disk today:

```bash
jci-audit verify 1.2.0
```

Run this from a checkout of the released tag.

---

## See Also

- [Configuration Guide](@/projects/jci-audit/configuration-guide.md) — the `deny.toml`/`about.toml` fields jci-audit interacts with
- [Advanced Configuration Guide](@/projects/jci-audit/advanced-configuration.md) — the release record's storage model, advisory-db overrides, troubleshooting
- [CLI Reference](@/projects/jci-audit/cli-reference.md) — full command and option documentation
- [Repository](https://github.com/jerus-org/jci-audit) — source, docs, and issue tracking
