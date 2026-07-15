+++
date = 2026-04-29
description = "The gen-orb-mcp CircleCI orb is now public — any orb project can add it and run generate, validate, diff, migrate, and prime as first-class jobs. And it generated itself: gen-circleci-orb produced the orb from the binary's --help output."
draft = false
title = "gen-orb-mcp now has a public CircleCI orb — and it generated itself"

[bluesky]
description = "The gen-orb-mcp CircleCI orb (jerus-org/gen-orb-mcp) is now public — any CircleCI project can use it. And it generated itself: gen-circleci-orb introspects --help output and produces the orb source. One line installs all five subcommands as jobs in your pipeline."

[linkedin]
created = 2026-05-08
description = """
The gen-orb-mcp CircleCI orb is now public — and it generated itself.

The orb (jerus-org/gen-orb-mcp) was produced by gen-circleci-orb, a tool that reads a binary's --help output and emits a complete, publishable CircleCI orb: commands, jobs, executor, Dockerfile, and CI pipeline wiring.

What this means: every gen-orb-mcp subcommand (generate, validate, diff, migrate, prime) is now available as a first-class CircleCI job to any orb project, not just ours. Add one line to your config and run them directly in your pipeline without installing anything manually.

The interesting part is the dogfooding loop: gen-circleci-orb introspects gen-orb-mcp's --help, maps every flag to an orb parameter, wraps each subcommand in a job, and wires the whole thing into the release pipeline with one init command. The orb source files I committed were written entirely by the tool, validated against the live binary.

Details in the blog post.
"""

[taxonomies]
categories = ["Tools", "Open Source"]
tags = ["circleci", "orb", "automation", "rust", "mcp"]
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
  --orb-namespace my-org
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

The `init` subcommand patches the CI configs additively. It is interactive — run it with
just the binary and it prompts for the rest — or pass everything up front to script it:

```bash
gen-circleci-orb init \
  --binary my-tool \
  --public-orb-namespace my-org \
  --docker-namespace my-docker-org \
  --build-workflow validation \
  --release-workflow release \
  --crate-tag-prefix my-tool-v \
  --requires-job common-tests \
  --release-after-job release-my-tool
```

This adds a `regenerate-orb` job to every build, followed by `orb-tools/pack` and
`orb-tools/review` to validate the output. On release it adds `build-container` (builds
and pushes the Docker image) and `orb-tools/publish` (publishes the orb to the CircleCI
registry), running after the crate release job.

The regeneration runs inside the pre-built `gen-circleci-orb` orb — nothing is installed
at build time — and works for any public open-source project without prior orb setup. No
circular dependency: `regenerate-orb` does not depend on the orb being published first.

## Using the orb — now public for any orb author

The `jerus-org/gen-orb-mcp` orb is **public**, so this is not just an internal convenience:
any CircleCI project can add it and run gen-orb-mcp's jobs. Add it to your
`.circleci/config.yml`:

```yaml
orbs:
  gen-orb-mcp: jerus-org/gen-orb-mcp@0.2.0
```

The subcommand jobs — `generate`, `validate`, `diff`, `migrate`, `build` — each map one-to-one
to a CLI subcommand and take the same parameters. There is also a composed job,
`build_mcp_server`, that runs the whole MCP-release pipeline (prime → generate → compile →
publish → commit back) in a single step, so a consumer treats it as one activity.

## Not everything generated itself

Here is the honest version of the headline. The per-subcommand jobs really did generate
themselves — gen-circleci-orb read gen-orb-mcp's `--help` and emitted a job for each subcommand.
But `build_mcp_server` has no matching subcommand: it is a *composed* job, hand-authored in
gen-circleci-orb's configuration from several of gen-orb-mcp's commands plus checkout, workspace,
and git-setup steps. The generator gives you the building blocks for free; assembling them into
one goal-oriented job is a deliberate act you own. See gen-circleci-orb's
[Advanced Configuration Guide](@/projects/gen-circleci-orb/advanced-configuration.md), where
`build_mcp_server` is the worked example.

If you adopt `build_mcp_server`, the env-var **names** its publish and save steps read are
configurable (via `--*-env` flags or a `gen-orb-mcp.toml` file), so you map them onto your own CI
secrets — there is no jerus-org-specific convention to inherit.

## The loop

gen-orb-mcp generates MCP servers from orbs. gen-circleci-orb generates orbs from
binaries. gen-orb-mcp now has an orb that was generated by gen-circleci-orb. That orb is
kept in sync by gen-circleci-orb running in CI on every build.

The tools close their own loop.
