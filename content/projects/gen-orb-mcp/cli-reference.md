+++
title = "gen-orb-mcp CLI Reference"
description = "Full CLI reference for gen-orb-mcp — commands, options, and generated server resources."
weight = 25

[taxonomies]
tags = ["Rust", "MCP", "CircleCI", "Code Generation", "CLI", "AI", "documentation"]
+++

Command-line tool for generating MCP (Model Context Protocol) servers from CircleCI orb
definitions, computing conformance-based migration rules, and applying migrations to consumer
CI directories.

## Command Overview

```
gen-orb-mcp <COMMAND>

Commands:
  generate   Generate an MCP server from an orb definition
  validate   Validate an orb definition file
  diff       Compute conformance rules between two orb versions
  prime      Populate prior-versions/ and migrations/ from git history
  migrate    Apply migration rules to a consumer CI directory
```

### Global Options

- `-v, --verbose...`: Increase logging verbosity (repeatable)
- `-q, --quiet...`: Decrease logging verbosity
- `-h, --help`: Show help
- `-V, --version`: Show version

---

## `generate` — Generate an MCP server

Parse an orb YAML definition and emit a ready-to-compile Rust crate that serves the orb's
commands, jobs, and executors as MCP Resources.

```
gen-orb-mcp generate [OPTIONS] --orb-path <PATH>
```

### Options

| Flag | Description |
|------|-------------|
| `-p, --orb-path <PATH>` | Path to the orb YAML entry point (e.g. `src/@orb.yml`) |
| `-o, --output <DIR>` | Output directory \[default: `./dist`\] |
| `-f, --format <FORMAT>` | Output format: `source` \| `binary` \[default: `source`\] |
| `-n, --name <NAME>` | Orb name (defaults to directory or filename stem) |
| `-V, --version <VERSION>` | Version string for the generated crate (e.g. `1.0.0`) |
| `--force` | Overwrite existing output directory without confirmation |
| `--migrations <DIR>` | Directory of conformance rule JSON files to embed (enables `plan_migration` / `apply_migration` Tools) |
| `--prior-versions <DIR>` | Directory of prior orb YAML snapshots to embed (files named `<version>.yml`, e.g. `4.7.1.yml`) |

### Examples

**Generate source code only:**

```bash
gen-orb-mcp generate \
  --orb-path ./circleci-toolkit/src/@orb.yml \
  --output ./circleci-toolkit-mcp \
  --version 4.9.6
```

**Generate with prior versions and migration Tools embedded:**

```bash
gen-orb-mcp generate \
  --orb-path ./circleci-toolkit/src/@orb.yml \
  --output ./circleci-toolkit-mcp \
  --version 4.9.6 \
  --prior-versions ./prior-versions/ \
  --migrations ./migrations/
```

**Compile to binary directly:**

```bash
gen-orb-mcp generate \
  --orb-path ./src/@orb.yml \
  --format binary \
  --version 4.9.6
```

---

## `validate` — Validate an orb definition

Check that an orb YAML file is structurally valid before attempting to generate a server.

```
gen-orb-mcp validate --orb-path <PATH>
```

### Options

| Flag | Description |
|------|-------------|
| `-p, --orb-path <PATH>` | Path to the orb YAML file |

---

## `diff` — Compute conformance rules between two orb versions

Compare two orb YAML files and emit a JSON array of `ConformanceRule` values describing what
changed. These rules drive both the `migrate` CLI command and the MCP Tools in generated servers.

```
gen-orb-mcp diff --current <PATH> --previous <PATH> --since-version <VERSION> [--output <FILE>]
```

### Options

| Flag | Description |
|------|-------------|
| `--current <PATH>` | Path to the current (newer) orb YAML |
| `--previous <PATH>` | Path to the previous (older) orb YAML |
| `--since-version <VERSION>` | Version string to embed in the generated rules (e.g. `5.0.0`) |
| `--output <FILE>` | Write rules to this file instead of stdout |

### Example

```bash
gen-orb-mcp diff \
  --current ./circleci-toolkit/src/@orb.yml \
  --previous ./circleci-toolkit-4.7.1.yml \
  --since-version 4.9.6 \
  --output ./migrations/4.9.6.json
```

The output JSON describes changes such as renamed jobs (`JobRenamed`), removed parameters
(`ParameterRemoved`), and absorbed jobs (`JobAbsorbed`).

---

## `prime` — Populate prior-versions/ and migrations/ from git history

Walk the orb repository's git tags, snapshot each version's orb YAML, and compute conformance
rule diffs between consecutive versions — all in one step. Replaces the manual workflow of
running `git checkout`, copying YAML files, and invoking `diff` for each version pair.

```
gen-orb-mcp prime [OPTIONS]
```

### Options

| Flag | Description |
|------|-------------|
| `-p, --orb-path <PATH>` | Path to the orb YAML entry point \[default: `src/@orb.yml`\] |
| `--git-repo <PATH>` | Git repository root \[default: walk up from `--orb-path` to `.git`\] |
| `--tag-prefix <PREFIX>` | Git tag prefix to filter version tags \[default: `v`\] |
| `--earliest-version <VER>` | Fixed anchor version (e.g. `4.1.0`); conflicts with `--since` |
| `--since <DURATION>` | Rolling time window (e.g. `6 months`) \[default: `6 months`\] |
| `--prior-versions-dir <DIR>` | Output directory for version snapshots \[default: `prior-versions`\] |
| `--migrations-dir <DIR>` | Output directory for rule JSON files \[default: `migrations`\] |
| `--rename-map OLD=NEW` | Inject an authoritative rename hint (repeatable; overrides git detection) |
| `--ephemeral` | Write to `/tmp/gen-orb-mcp-prime-<pid>/` and print `PRIME_PV_DIR=...` / `PRIME_MIG_DIR=...` to stdout |
| `--dry-run` | Describe actions without writing any files |

### Behaviour

For each version tag within the configured window, `prime`:

1. Checks out the tag into a temporary git worktree (RAII cleanup)
2. Saves the parsed orb to `prior-versions/<version>.yml`
3. Computes a conformance-rule diff vs the previous version and writes
   `migrations/<version>.json` (only if non-empty)

Out-of-window snapshots and their matching migration files are removed. The command is
idempotent: existing files are not overwritten.

### Examples

```bash
# Rolling 6-month window (default)
gen-orb-mcp prime --orb-path ./src/@orb.yml

# Anchored at a fixed earliest version
gen-orb-mcp prime \
  --orb-path ./src/@orb.yml \
  --earliest-version 4.1.0

# Ephemeral mode for CI pipelines
eval "$(gen-orb-mcp prime \
  --orb-path ./src/@orb.yml \
  --earliest-version 4.1.0 \
  --ephemeral)"
# → PRIME_PV_DIR and PRIME_MIG_DIR exported; pass to generate:
gen-orb-mcp generate \
  --orb-path ./src/@orb.yml \
  --output ./mcp-build \
  --version "${ORB_VERSION}" \
  --prior-versions "${PRIME_PV_DIR}" \
  --migrations "${PRIME_MIG_DIR}"

# Override rename detection when history can't be restructured
gen-orb-mcp prime \
  --orb-path ./src/@orb.yml \
  --rename-map "common_tests_rolling=common_tests" \
  --rename-map "required_builds_rolling=required_builds"
```

---

## `migrate` — Apply migration rules to a consumer CI directory

Read a conformance rules JSON file (produced by `diff`) and update a consumer's
`.circleci/` directory to conform to the target version's requirements.

```
gen-orb-mcp migrate [OPTIONS] --orb <ALIAS> --rules <FILE>
```

### Options

| Flag | Description |
|------|-------------|
| `--ci-dir <DIR>` | Path to the consumer `.circleci/` directory \[default: `.circleci`\] |
| `--orb <ALIAS>` | Orb alias used in the consumer's `orbs:` section (e.g. `toolkit`) |
| `--rules <FILE>` | Path to conformance rules JSON (produced by `diff`) |
| `--dry-run` | Show planned changes without modifying any files |

### Examples

```bash
# Preview what will change
gen-orb-mcp migrate \
  --ci-dir ./.circleci \
  --orb toolkit \
  --rules ./migrations/4.9.6.json \
  --dry-run

# Apply changes
gen-orb-mcp migrate \
  --ci-dir ./.circleci \
  --orb toolkit \
  --rules ./migrations/4.9.6.json
```

---

## Generated MCP Server — Resources

The generated server exposes the following MCP Resources:

| URI pattern | Content |
|-------------|---------|
| `orb://overview` | Full markdown documentation of the orb |
| `orb://commands/{name}` | JSON definition of a command |
| `orb://jobs/{name}` | JSON definition of a job |
| `orb://executors/{name}` | JSON definition of an executor |
| `orb://versions` | List of all embedded versions (when prior versions are present) |
| `orb://v{version}/commands/{name}` | Command definition from a prior version |
| `orb://v{version}/jobs/{name}` | Job definition from a prior version |
| `orb://v{version}/executors/{name}` | Executor definition from a prior version |

---

## Generated MCP Server — Tools

Tools are only present in servers generated with `--migrations`:

| Tool | Description |
|------|-------------|
| `plan_migration` | Analyse a consumer `.circleci/` directory and return a summary of changes needed to reach the current orb version |
| `apply_migration` | Apply the migration plan; pass `dry_run: true` to preview without writing files |

Both tools accept:

- `ci_dir` — path to the consumer's `.circleci/` directory
- `orb_alias` — the alias used in the consumer's `orbs:` section

`apply_migration` additionally accepts `dry_run` (boolean, default `false`).

---

## Quick-reference: Common Options

| Flag | Commands | Description |
|------|----------|-------------|
| `--orb-path` | `generate`, `validate`, `prime` | Path to orb YAML entry point |
| `--output` | `generate` | Output directory |
| `--version` | `generate` | Version string for generated crate |
| `--format binary` | `generate` | Compile to binary instead of source |
| `--force` | `generate` | Overwrite existing output |
| `--migrations <dir>` | `generate` | Embed conformance rules; enables Tools |
| `--prior-versions <dir>` | `generate` | Embed prior orb YAML snapshots |
| `--current / --previous` | `diff` | Orb YAMLs to compare |
| `--since-version` | `diff` | Version string to embed in rules |
| `--earliest-version` | `prime` | Fixed anchor for version window |
| `--since` | `prime` | Rolling time window (default: 6 months) |
| `--ephemeral` | `prime` | Write to `/tmp`, export path env vars |
| `--rename-map OLD=NEW` | `prime` | Override git rename detection |
| `--ci-dir` | `migrate` | Consumer `.circleci/` directory |
| `--orb` | `migrate` | Orb alias in consumer config |
| `--rules` | `migrate` | Conformance rules JSON from `diff` |
| `--dry-run` | `migrate`, `prime` | Preview without writing files |

---

## Exit Codes

- **0**: Success
- **Non-zero**: Error (check stderr for details)

---

## See Also

- [Getting Started](../getting-started) — Step-by-step scenarios and CI integration
- [Migration Guide](../migration-guide) — Conformance migration design and orb author guidance
- [Repository](https://github.com/jerus-org/gen-orb-mcp) — Source code and issue tracking
- [API Documentation](https://docs.rs/gen-orb-mcp) — Generated Rust API reference
