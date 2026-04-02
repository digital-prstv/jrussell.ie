+++
title = "gen-orb-mcp Migration Guide"
description = "Conformance-based migration design and orb author guidance for gen-orb-mcp."
weight = 30

[taxonomies]
tags = ["Rust", "MCP", "CircleCI", "Code Generation", "CLI", "AI", "documentation"]
+++

This guide covers how gen-orb-mcp's migration system works, how to use it to update consumer
CI directories, and how to structure orb changes so that migration rules are generated
correctly.

## How Migrations Work

Migrations in gen-orb-mcp are **conformance-based**, not path-dependent. The `diff` command
computes what the target version's contract requires, regardless of which intermediate versions
a consumer has skipped. The `migrate` command (and the embedded MCP Tools) then inspect the
consumer's actual CI state and fix all non-conformant patterns in one pass.

This means migrating from v4.7.0 directly to v5.0.0 is handled correctly even if v4.8.0
through v4.11.0 were never used.

### Conformance Rules

The `diff` command produces a JSON array of `ConformanceRule` values. Each rule describes one
kind of change:

| Rule type | Meaning |
|-----------|---------|
| `JobRenamed` | A job was renamed; update all `- toolkit/old_name:` references |
| `ParameterRemoved` | A parameter was removed; remove all `param: value` usages |
| `JobAbsorbed` | A job's functionality was merged into another; migrate usages |

Rules are version-stamped with `--since-version`. Consumers migrating from any earlier version
to that version need to satisfy all rules with that stamp.

### MCP Tools in Generated Servers

When a server is generated with `--migrations`, it gains two tools:

- **`plan_migration`** — reads the consumer's `.circleci/` directory and returns a human-readable
  summary of all non-conformant patterns and the changes needed to fix them.
- **`apply_migration`** — applies the plan, optionally in dry-run mode.

An AI assistant like Claude Code calls these tools in sequence: present the plan to the user,
get confirmation, then apply.

---

## Using the CLI Migration Workflow

### Step 1 — Generate rules with `diff`

```bash
gen-orb-mcp diff \
  --current ./my-orb/src/@orb.yml \
  --previous ./prior-versions/4.7.1.yml \
  --since-version 5.0.0 \
  --output ./migrations/5.0.0.json
```

### Step 2 — Inspect the generated rules

```bash
# Show all rules
cat migrations/5.0.0.json | jq '.'

# Show only JobRenamed rules
cat migrations/5.0.0.json | \
  jq '.[] | select(.type == "JobRenamed") | .data | "\(.from) -> \(.to)"'
```

### Step 3 — Preview changes on a consumer

```bash
gen-orb-mcp migrate \
  --ci-dir /path/to/consumer/.circleci \
  --orb my-orb \
  --rules ./migrations/5.0.0.json \
  --dry-run
```

### Step 4 — Apply changes

```bash
gen-orb-mcp migrate \
  --ci-dir /path/to/consumer/.circleci \
  --orb my-orb \
  --rules ./migrations/5.0.0.json
```

---

## Automating History with `prime`

For an orb with many releases, `prime` automates the entire prior-version and migration
population process:

```bash
# Populate from the last 6 months of git tags (default)
gen-orb-mcp prime --orb-path ./src/@orb.yml

# Fixed anchor — covers your full install base
gen-orb-mcp prime \
  --orb-path ./src/@orb.yml \
  --earliest-version 4.1.0

# Dry run — see what would be created/removed without writing
gen-orb-mcp prime \
  --orb-path ./src/@orb.yml \
  --earliest-version 4.1.0 \
  --dry-run
```

After `prime` completes, inspect `migrations/<version>.json` before committing to ensure the
generated rules are correct (see the section on rename detection below).

---

## Orb Author Guide: Job Renames

`prime` uses two strategies to detect job renames, applied in priority order:

1. **Git rename hints** — `git log --diff-filter=R` is run against the orb repository. Any
   file pair that git reports as a rename is treated as an authoritative hint.
2. **Jaccard parameter fallback** — For removed jobs not covered by a git hint, the tool
   compares parameter-name sets (Jaccard similarity ≥ 0.7) against truly new jobs.

### The job-family swap problem

The most common source of incorrect rename detection is a **job-family swap** — a breaking
release where a rolling variant replaces the standard name:

| Intent | Old file | New file |
|--------|----------|----------|
| Old standard becomes `_pinned` | `common_tests.yml` (deleted) | `common_tests_pinned.yml` (added) |
| Old rolling becomes new standard | `common_tests_rolling.yml` (deleted) | `common_tests.yml` (modified) |

When **both renames are in one commit**, git can only pair one deleted file with the one added
file. The modification of `common_tests.yml` goes undetected as a rename source. The result is
a wrong rule: `JobRenamed { from: "common_tests_rolling", to: "common_tests_pinned" }`.

### Solution: two-commit rename

Split the swap across two commits so git can track each rename independently.

**Commit 1** — rename the standard job to `_pinned`:

```bash
git mv src/jobs/common_tests.yml src/jobs/common_tests_pinned.yml
# update content as needed
git commit -s -m "refactor: rename common_tests -> common_tests_pinned"
```

**Commit 2** — rename the rolling job to the standard name:

```bash
git mv src/jobs/common_tests_rolling.yml src/jobs/common_tests.yml
# update content as needed
git commit -s -m "refactor: rename common_tests_rolling -> common_tests"
```

With two commits, `git log --diff-filter=R` reports both rename pairs correctly and `prime`
generates:

```json
{ "type": "JobRenamed", "data": { "from": "common_tests_rolling", "to": "common_tests", "removed_parameters": [] } }
```

### When to use the two-commit rule

Apply it whenever a breaking release:

- Removes a job that previously existed under a simpler name *and* simultaneously adds a new
  job under that same name
- Renames a job to a name that was already occupied

For straightforward renames (old name gone, new name never existed before), a single commit is
fine — git detects the pair without ambiguity.

### Escape hatch: `--rename-map`

When history cannot be restructured (already tagged and pushed), inject authoritative hints
directly with `--rename-map`:

```bash
gen-orb-mcp prime \
  --orb-path ./src/@orb.yml \
  --rename-map "common_tests_rolling=common_tests" \
  --rename-map "required_builds_rolling=required_builds"
```

Manual entries take precedence over any git-detected hint for the same old name. The flag is
repeatable — supply one `--rename-map` entry per rename pair.

### Checking generated rules

After running `prime`, verify `migrations/<version>.json` before committing:

```bash
# Suspicious if "to" ends in _pinned or _rolling when you intended the plain standard name
jq '.[] | select(.type == "JobRenamed") | .data | "\(.from) -> \(.to)"' \
  migrations/6.0.0.json

# Cross-check against git rename history for that version range
git log v5.3.10..v6.0.0 --oneline --diff-filter=R --name-status -- 'src/jobs/*.yml'
```

| Scenario | Commit structure | Automation outcome |
|----------|------------------|--------------------|
| Simple rename: `foo → bar` | Single commit OK | Correct `JobRenamed` generated |
| Family swap: `foo → foo_pinned`, `foo_rolling → foo` | **Two commits required** | Correct rules generated |
| Family swap in one commit | Single commit | Wrong target (`→ foo_pinned`); use `--rename-map` to fix |
| Already released, history fixed | N/A | Use `--rename-map` override |

---

## See Also

- [Getting Started](../getting-started) — Step-by-step scenarios including CI pipeline integration
- [CLI Reference](../cli-reference) — Full `diff`, `prime`, and `migrate` option documentation
- [Repository](https://github.com/jerus-org/gen-orb-mcp) — Source code and issue tracking
