+++
title = "gen-orb-mcp: Getting Started"
description = "Quick start guide for gen-orb-mcp — generate MCP servers from CircleCI orb definitions."
weight = 20

[taxonomies]
tags = ["Rust", "MCP", "CircleCI", "Code Generation", "CLI", "AI", "documentation"]
+++

A code generation tool that transforms CircleCI orb definitions into MCP (Model Context Protocol)
servers, enabling AI assistants to understand your private orb's commands, jobs, and executors —
and to guide users through breaking-change migrations interactively.

## Installation

### From Crates.io

```bash
cargo install gen-orb-mcp
```

### With cargo-binstall (pre-compiled binary)

```bash
cargo binstall gen-orb-mcp
```

### Verify Installation

```bash
gen-orb-mcp --version
```

---

## Scenario A: Basic orb documentation server

You have a private CircleCI orb and want Claude Code (or another AI assistant) to understand it.

### Step 1 — Generate the MCP server source code

```bash
gen-orb-mcp generate \
  --orb-path ./my-orb/src/@orb.yml \
  --output ./my-orb-mcp \
  --version 1.0.0
```

### Step 2 — Compile to a binary

```bash
cd my-orb-mcp && cargo build --release
# Binary is at: my-orb-mcp/target/release/my_orb_mcp
```

### Step 3 — Connect to Claude Code

Add the binary to `.claude.json` (project-level) or `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "my-orb": {
      "command": "/absolute/path/to/my_orb_mcp"
    }
  }
}
```

The AI assistant can now answer questions about your orb's commands, jobs, executors, and parameters.

---

## Scenario B: Multi-version server with migration Tools

You have a breaking change in your orb and want the AI assistant to help users migrate.

### Step 1 — Save the previous orb version

```bash
mkdir prior-versions
cp my-orb-4.7.1.yml prior-versions/4.7.1.yml
```

### Step 2 — Compute conformance rules

```bash
mkdir migrations
gen-orb-mcp diff \
  --current ./my-orb/src/@orb.yml \
  --previous ./prior-versions/4.7.1.yml \
  --since-version 5.0.0 \
  --output ./migrations/5.0.0.json
```

The output is a JSON file describing what changed: renamed jobs, removed parameters, absorbed
jobs, and so on.

### Step 3 — Generate the server with everything embedded

```bash
gen-orb-mcp generate \
  --orb-path ./my-orb/src/@orb.yml \
  --output ./my-orb-mcp \
  --version 5.0.0 \
  --migrations ./migrations/ \
  --prior-versions ./prior-versions/ \
  --force

cd my-orb-mcp && cargo build --release
```

The generated server now exposes:

- Current-version resources (`orb://commands/...`, `orb://jobs/...`)
- Prior-version resources (`orb://v4.7.1/commands/...`)
- A version index at `orb://versions`
- `plan_migration` and `apply_migration` MCP Tools

### Step 4 — Use with Claude Code

With the MCP server connected, you can ask Claude:

```
"My .circleci/config.yml uses my-orb@4.7.1. Plan a migration to 5.0.0."
```

Claude calls `plan_migration`, shows you the diff, and on approval calls `apply_migration`
to update the files in place.

---

## Scenario C: Automated history with `prime`

`prime` automates Scenario B's manual steps for an entire version history:

```bash
# Populate prior-versions/ and migrations/ from the last 6 months of git tags
gen-orb-mcp prime \
  --orb-path ./my-orb/src/@orb.yml

# Anchor at a specific earliest version (to cover your full install base)
gen-orb-mcp prime \
  --orb-path ./my-orb/src/@orb.yml \
  --earliest-version 4.1.0
```

`prime` discovers all semver tags in the repository, snapshots each version's orb YAML, and
computes conformance diffs between consecutive versions. It is idempotent — existing files are
not overwritten; out-of-window files are removed.

For use in CI with ephemeral paths:

```bash
eval "$(gen-orb-mcp prime \
  --orb-path ./src/@orb.yml \
  --earliest-version 4.1.0 \
  --ephemeral)"
# → PRIME_PV_DIR and PRIME_MIG_DIR are now set

gen-orb-mcp generate \
  --orb-path ./src/@orb.yml \
  --output ./mcp-build \
  --version "${ORB_VERSION}" \
  --prior-versions "${PRIME_PV_DIR}" \
  --migrations "${PRIME_MIG_DIR}"
```

---

## Scenario D: Bulk CLI migration (no MCP server needed)

Apply migration rules directly from the command line to update consumer CI directories:

```bash
# Dry run — see what would change without writing any files
gen-orb-mcp migrate \
  --ci-dir /path/to/consumer/.circleci \
  --orb my-orb \
  --rules ./migrations/5.0.0.json \
  --dry-run

# Apply changes
gen-orb-mcp migrate \
  --ci-dir /path/to/consumer/.circleci \
  --orb my-orb \
  --rules ./migrations/5.0.0.json
```

---

## Integrating into a release pipeline

In your orb's CircleCI release workflow, add steps after the orb is published:

```yaml
- run:
    name: Generate migration rules
    command: |
      gen-orb-mcp diff \
        --current src/@orb.yml \
        --previous prior-versions/$(cat previous-version.txt).yml \
        --since-version "$ORB_VERSION" \
        --output migrations/"$ORB_VERSION".json

- run:
    name: Generate and compile MCP server
    command: |
      gen-orb-mcp generate \
        --orb-path src/@orb.yml \
        --output dist/mcp \
        --version "$ORB_VERSION" \
        --migrations migrations/ \
        --prior-versions prior-versions/ \
        --force
      cd dist/mcp && cargo build --release
```

---

## See Also

- [CLI Reference](../cli-reference) — Full command and option documentation
- [Migration Guide](../migration-guide) — Conformance-based migration design and orb author guidance
- [Repository](https://github.com/jerus-org/gen-orb-mcp) — Source code and issue tracking
- [API Documentation](https://docs.rs/gen-orb-mcp) — Generated Rust API reference
