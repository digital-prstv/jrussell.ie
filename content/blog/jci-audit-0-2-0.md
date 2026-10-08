+++
date = 2026-10-06
description = "jci-audit 0.2.0 is a Rust security and license gate for pull requests and releases: cargo-audit, cargo-deny and cargo-about run together from one deny.toml, wired into CircleCI with one command, and every release leaves a record anyone can re-check."
draft = true
title = "jci-audit 0.2.0: one gate for your dependencies' security and licenses"

[taxonomies]
categories = ["Tools", "Open Source"]
tags = ["rust", "security", "licenses", "circleci", "cargo-deny", "cargo-audit", "cargo-about", "supply-chain"]
+++

[jci-audit](@/projects/jci-audit/index.md) runs [`cargo-audit`](https://crates.io/crates/cargo-audit),
[`cargo-deny`](https://crates.io/crates/cargo-deny) and
[`cargo-about`](https://crates.io/crates/cargo-about) as one gate. `cargo audit` checks the live
RustSec advisory database. `cargo deny` enforces your policy for advisories, bans, licenses and
sources. `cargo about` attributes every dependency's license, so the third-party notices you ship
are right. One file, `deny.toml`, drives all three, so they cannot disagree about what is allowed.

Version 0.2.0 is ready for a real project: add it to your CircleCI pipeline with one command, gate
every pull request on it, and leave a record with each release that anyone can re-check later.

## Get it

```bash
cargo binstall jci-audit
cargo binstall cargo-audit cargo-deny cargo-about
```

Or use the CircleCI orb, which brings the tools with it: `jerus-org/jci-audit@0.2.0`.

## Start from a policy, or complete the one you have

```bash
jci-audit init
```

`init` writes a standard `deny.toml`: vulnerabilities denied, a permissive license allow-list, and
copyleft licenses admitted only for the specific crates you name. If you already have a
`deny.toml`, `init` adds only the standard keys it lacks and lists each one. Your settings,
comments and exceptions stay exactly as they are. It also derives `.cargo/audit.toml` from your
`deny.toml`, so the tools share one set of justified ignores.

## Put it in your pipeline

```bash
jci-audit wire-ci
```

`wire-ci` adds the orb's jobs to your `.circleci/config.yml`. The first run asks which workflow
the check job should join and which optional checks to turn on, then writes a small
`jci-audit.toml` for you to review. Run it again to apply your edits. In CI, run
`jci-audit check-ci-wiring`: it fails if the wiring has drifted from your `jci-audit.toml`, and it
never writes anything.

## Gate every pull request

```bash
jci-audit check
```

One run does four things, and a failure in one never hides another:

- the `cargo deny` policy check;
- a live `cargo audit` scan;
- a check that each crate's `about.toml` still matches the license policy in `deny.toml`;
- a `cargo about` check that every dependency's license can still be attributed.

Add `--deny-stale-exceptions` to fail when a `[[bans.skip]]` exception no longer fires, and
`--deny-warnings` to turn every remaining warning into a failure.

## Keep your license notices honest

`cargo deny` and `cargo about` each read their own license configuration. Kept by hand, the two
drift, and the first you hear of it can be a release that cannot produce its notices. jci-audit
keeps one policy:

```bash
jci-audit sync
```

`sync` derives `.cargo/audit.toml` and each crate's `about.toml` from `deny.toml`. A crate's
`about.toml` lists only the licenses that crate's own dependencies use, so a workspace of several
crates gets the right notice for each. Anything you wrote by hand in `about.toml`, such as
attribution pins and comments, is left alone.

`check` fails if a crate's derived `about.toml` is out of date, and if `cargo about` can no longer
attribute a dependency's license. Two optional flags catch a licensing change early:

- `--deny-stale-notices` compares the licenses `cargo about` would list now with your committed
  notices. It fails when a license has been substituted or added. A version bump, or a new
  dependency under a license you already accept, only warns, because the point is to catch a
  licensing change, not to keep the file byte-identical.
- `--deny-unused-licenses` fails when your allow-list names a license nothing in the graph uses, so
  the list stays as short as your dependencies need.

Generating the notices themselves stays with `cargo about`, run the way you run it today.

## Release with a record you can check later

```bash
jci-audit release-prep 1.2.0
jci-audit publish-record 1.2.0 --tag v1.2.0 --owner my-org --repo my-repo
jci-audit verify 1.2.0
```

`release-prep` runs `cargo deny` against a pinned advisory-db commit, offline, and writes a record
of exactly what was checked, including digests of the policy files in force. `publish-record` signs it and
attaches it to the release. `verify` re-checks a past release against that record, either from a
checkout or straight from the published release with nothing checked out. In a workspace with
several crates, `--package <name>` scopes the record to one crate, so crates can release under
different versions in the same pipeline.

## Where it stands

jci-audit is pre-1.0. The commands above are the supported surface and are documented, but flags
and defaults may still change before 1.0, and any change will be noted in the release log. The
CircleCI orb is the only CI integration so far.

- [Getting started](@/projects/jci-audit/getting-started.md)
- [CLI reference](@/projects/jci-audit/cli-reference.md)
- [Configuration guide](@/projects/jci-audit/configuration-guide.md)
- [Source and issues](https://github.com/jerus-org/jci-audit)
