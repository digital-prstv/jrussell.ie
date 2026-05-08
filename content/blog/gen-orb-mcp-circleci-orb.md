+++
date = 2026-04-29
description = "gen-orb-mcp now ships a CircleCI orb — generated automatically by gen-circleci-orb from the binary's --help output. One command adds generate, validate, diff, migrate, and prime jobs to any CircleCI pipeline."
draft = true
title = "gen-orb-mcp now has a CircleCI orb — and it generated itself"

[taxonomies]
categories = ["Tools", "Open Source"]
tags = ["circleci", "orb", "automation", "rust", "mcp"]

[bluesky]
description = "gen-orb-mcp now ships a CircleCI orb (jerus-org/gen-orb-mcp). The orb was generated automatically by gen-circleci-orb — the tool that introspects --help output and produces orb source. One command installs all five subcommands as jobs in your pipeline."

[linkedin]
description = """
gen-orb-mcp now ships a CircleCI orb — and it generated itself.

The orb (jerus-org/gen-orb-mcp) was produced by gen-circleci-orb, a new tool that reads a binary's --help output and emits a complete, publishable CircleCI orb: commands, jobs, executor, Dockerfile, and CI pipeline wiring.

What this means: every gen-orb-mcp subcommand (generate, validate, diff, migrate, prime) is now available as a first-class CircleCI job. Drop the orb into your config and run them directly in your pipeline without installing anything manually.

The interesting part is the dogfooding loop: gen-circleci-orb introspects gen-orb-mcp's --help, maps every flag to an orb parameter, wraps each subcommand in a job, and wires the whole thing into the release pipeline with one init command. The orb source files I committed were written entirely by the tool, validated against the live binary.

Details in the blog post.
"""
+++

[gen-orb-mcp](https://github.com/jerus-org/gen-orb-mcp) — the tool that generates MCP
servers from CircleCI orb definitions — now ships its own CircleCI orb. The orb is
published as `jerus-org/gen-orb-mcp` and exposes each subcommand as a reusable job.

The interesting part: the orb was generated automatically.

## The tool that generated the orb

[gen-circleci-orb](https://github.com/jerus-org/gen-circleci-orb) reads a binary's
`--help` output and produces a complete unpacked orb: one command file per subcommand,
one job file per subcommand, an executor, a Dockerfile, and optionally the CI pipeline
wiring to keep everything in sync.

```bash
gen-circleci-orb generate \
  --binary gen-orb-mcp \
  --namespace jerus-org \
  --output orb
```

That command produces 13 files. Here is `commands/generate.yml` as an example of what
comes out:

```yaml
description: Generate an MCP server from a CircleCI orb
parameters:
  orb_path:
    type: string
    description: Path to the orb YAML file
  output:
    type: string
    description: Output directory for the generated MCP server
    default: ./dist
  format:
    type: enum
    description: Output format
    enum:
      - source
      - binary
    default: source
  force:
    type: boolean
    description: Overwrite existing output without confirmation
    default: false
  migrations:
    type: string
    description: Directory of conformance rule JSON files to embed
    default: ''
steps:
- run:
    name: generate
    command: <<include(scripts/generate.sh)>>
    environment:
      ORB_PATH: << parameters.orb_path >>
      OUTPUT: << parameters.output >>
      FORMAT: << parameters.format >>
      FORCE: << parameters.force >>
      MIGRATIONS: << parameters.migrations >>
```

The companion `scripts/generate.sh` uses shell conditionals on the env vars:

```bash
set -- gen-orb-mcp generate
set -- "$@" --orb-path "${ORB_PATH}"
[ -n "${OUTPUT:-}" ] && set -- "$@" --output "${OUTPUT}"
[ -n "${FORMAT:-}" ] && set -- "$@" --format "${FORMAT}"
[ "${FORCE:-false}" = "true" ] && set -- "$@" --force
[ -n "${MIGRATIONS:-}" ] && set -- "$@" --migrations "${MIGRATIONS}"
"$@"
```

Parameters flow via `environment:` — CircleCI substitutes `<< parameters.x >>` in the
YAML block before the step runs, and the script reads them as ordinary shell variables.
The long command lives in the script file (not inlined in YAML) to satisfy the orb
best-practice review rule RC009. The parser determines required vs optional from the
CLI's `Usage:` line: `--orb-path` outside any `[...]` group is required (no `default:`
key); everything inside `[OPTIONS]` is optional (boolean → `default: false`, string →
`default: ''`, string with CLI default → that value).

## Wiring into the release pipeline

The `init` subcommand patches the CI configs additively:

```bash
gen-circleci-orb init \
  --binary gen-orb-mcp \
  --namespace jerus-org \
  --build-workflow validation \
  --release-workflow release \
  --requires-job common-tests \
  --release-after-job release-gen-orb-mcp
```

This adds a `regenerate-orb` job to every build, followed by `orb-tools/pack` and
`orb-tools/review` to validate the output. On release it adds `build-container` (builds
and pushes the Docker image) and `orb-tools/publish` (publishes the orb to the CircleCI
registry), running in parallel after the crate release job.

The generated CI is self-bootstrapping: it installs `gen-circleci-orb` at runtime via
`cargo binstall`, uses only standard public CircleCI orbs (`circleci/docker`,
`circleci/orb-tools`), and works for any public open-source project without prior orb
setup. No circular dependency: `regenerate-orb` does not depend on the orb being
published first.

## Using the orb

Add it to your `.circleci/config.yml`:

```yaml
orbs:
  gen-orb-mcp: jerus-org/gen-orb-mcp@<version>
```

Available jobs: `generate`, `validate`, `diff`, `migrate`, `prime`. Each job accepts the
same parameters as the corresponding CLI subcommand.

## The loop

gen-orb-mcp generates MCP servers from orbs. gen-circleci-orb generates orbs from
binaries. gen-orb-mcp now has an orb that was generated by gen-circleci-orb. That orb is
kept in sync by gen-circleci-orb running in CI on every build.

The tools close their own loop.
