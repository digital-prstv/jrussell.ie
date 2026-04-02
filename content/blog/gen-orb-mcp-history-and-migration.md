+++
title = "gen-orb-mcp: Teaching AI Your Orb's Full History — and How to Migrate It"
description = "Recent releases of gen-orb-mcp bring automated version-history population and conformance-based migration tooling. The `prime` command walks your git tags and builds the full prior-version archive in one step; generated MCP servers now expose `plan_migration` and `apply_migration` tools so an AI assistant can guide users through breaking changes interactively."
date = 2026-04-02
draft = false

[taxonomies]
categories = ["Open Source", "Developer Tools"]
tags = ["Rust", "MCP", "CircleCI", "AI", "code generation", "migration", "gen-orb-mcp"]
+++

Private CircleCI orbs are invisible to AI coding assistants. An orb can contain dozens of
jobs, commands, and executors with complex parameter sets — but because it isn't on the public
internet, an AI has no idea it exists. `gen-orb-mcp` fixes that by generating a standalone MCP
server directly from your orb's YAML definition, embedding the full documentation as static
resources that any MCP-aware assistant (Claude Code, Cursor, etc.) can query.

The core generator has been available since v0.1.0. What's new across recent releases is the
machinery for **version history** and **guided migration**.

<!-- more -->

## The problem with breaking changes

When an orb ships a breaking release — renamed jobs, removed parameters, changed defaults — the
blast radius is every consumer repo that hasn't updated yet. Historically this meant:

1. Writing a migration guide in a README nobody reads
2. Filing PRs across every consumer repo by hand
3. Watching CI fail for months as teams slowly catch up

The new tooling in gen-orb-mcp approaches this differently. Instead of writing instructions,
you encode the change as a **conformance rule**, embed it in the generated MCP server, and let
the AI assistant do the migration work.

---

## `prime`: one command to build the full history archive

The `prime` command was added in v0.1.3. It walks your orb repository's git tags, checks out
each version into a temporary worktree, saves the parsed orb YAML as a snapshot, and computes
conformance-rule diffs between consecutive versions.

```bash
# Rolling 6-month window — good for day-to-day use
gen-orb-mcp prime --orb-path ./src/@orb.yml

# Fixed anchor — covers your entire install base
gen-orb-mcp prime \
  --orb-path ./src/@orb.yml \
  --earliest-version 4.1.0
```

The output is two directories:

- `prior-versions/<version>.yml` — a snapshot of the orb at each discovered version
- `migrations/<version>.json` — conformance rules for what changed in that version

`prime` is idempotent: existing files are not overwritten, and snapshots that fall outside the
window are cleaned up automatically. Run it on every release CI job and the archive stays
current without manual intervention.

### Rename detection

`prime` uses git's rename history (`--diff-filter=R`) as the primary signal for `JobRenamed`
rules. This works well for straightforward renames where the old name disappears and a new name
appears. The tricky case is a **job-family swap** — where a rolling variant takes over the
standard name while the old standard becomes a `_pinned` variant:

```
# What you intend:
common_tests_rolling  →  common_tests   (rolling becomes the default)
common_tests          →  common_tests_pinned   (old default gets a suffix)
```

If both renames land in a single commit, git can only pair one deleted file with the one added
file. The second rename goes undetected. The fix is to split the swap across two commits — see
the [Migration Guide](/projects/gen-orb-mcp/migration-guide) for the full walkthrough.

When you can't restructure history (already tagged and pushed), the `--rename-map` flag added
in the unreleased branch injects authoritative hints directly, bypassing git detection:

```bash
gen-orb-mcp prime \
  --orb-path ./src/@orb.yml \
  --rename-map "common_tests_rolling=common_tests" \
  --rename-map "required_builds_rolling=required_builds"
```

---

## Generating a server with history and Tools

Once `prior-versions/` and `migrations/` are populated, pass them to `generate`:

```bash
gen-orb-mcp generate \
  --orb-path ./src/@orb.yml \
  --output ./my-orb-mcp \
  --version 5.0.0 \
  --prior-versions ./prior-versions/ \
  --migrations ./migrations/
```

The generated server now exposes:

- **Current-version resources** — `orb://commands/{name}`, `orb://jobs/{name}`, `orb://executors/{name}`
- **Prior-version resources** — `orb://v4.7.1/commands/{name}`, `orb://v4.7.1/jobs/{name}`, etc.
- **A version index** — `orb://versions`
- **`plan_migration` and `apply_migration` MCP Tools**

An AI assistant connected to this server can answer cross-version questions ("what parameters
did `common_tests` take in v4.7.1?") and guide users through migrations interactively.

---

## Interactive migration with an AI assistant

With the server running and connected to Claude Code, a user can ask:

> "My `.circleci/config.yml` uses circleci-toolkit@4.7.1. Plan a migration to 5.0.0."

Claude calls `plan_migration` with the path to the consumer's `.circleci/` directory. The tool
reads the YAML, evaluates all conformance rules that apply between those two versions, and
returns a structured summary of what needs to change.

The user reviews the plan. On confirmation, Claude calls `apply_migration`, which rewrites the
files in place.

No migration guide document. No manual PR. No version archaeology.

---

## CLI migration (no MCP server needed)

For scripted bulk migration — updating many consumer repos without an AI in the loop — the
`migrate` command applies rules directly:

```bash
# Preview
gen-orb-mcp migrate \
  --ci-dir /path/to/consumer/.circleci \
  --orb toolkit \
  --rules ./migrations/5.0.0.json \
  --dry-run

# Apply
gen-orb-mcp migrate \
  --ci-dir /path/to/consumer/.circleci \
  --orb toolkit \
  --rules ./migrations/5.0.0.json
```

Migrations are **conformance-based**: the rules describe the target version's contract, not a
series of sequential patches. A consumer migrating from v4.7.0 directly to v5.0.0 gets the
same result as one that went through every intermediate version.

---

## What's been fixed

Beyond the headline features, versions v0.1.6 through v0.1.9 addressed a number of edge cases
in the migrator:

- Sibling parameters now drain correctly when a parameter is removed
- Orphaned pipeline parameter declarations are cleaned up
- Normalised file path lookup so configs nested in subdirectories are found
- `UpdateOrbVersion` change type keeps the orb pin in sync during migration
- An LLVM out-of-memory issue on release builds caused by large inline literals — resolved by
  moving the embedded data to referenced statics

---

## Documentation

Full documentation is now available in the [gen-orb-mcp project pages](/projects/gen-orb-mcp):

- [Getting Started](/projects/gen-orb-mcp/getting-started) — step-by-step scenarios from basic
  docs server to CI pipeline integration
- [CLI Reference](/projects/gen-orb-mcp/cli-reference) — complete option tables for all five
  commands
- [Migration Guide](/projects/gen-orb-mcp/migration-guide) — conformance rule design, orb
  author guidance on rename detection, and the `--rename-map` escape hatch

The crate is on [crates.io](https://crates.io/crates/gen-orb-mcp). Install with:

```bash
cargo binstall gen-orb-mcp
# or
cargo install gen-orb-mcp
```
