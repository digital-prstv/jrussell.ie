+++
date = 2026-04-22
description = "A new tool that generates CircleCI orbs directly from a CLI binary's --help output, eliminating the repetitive boilerplate of packaging every CLI tool as a reusable orb."
draft = false
title = "Introducing gen-circleci-orb"

[bluesky]
created = 2026-04-22

[taxonomies]
categories = ["Tools", "Open Source"]
tags = ["circleci", "orb", "automation", "rust"]
+++

Every time I publish a new CLI tool to crates.io, the same task appears on the list: write a
CircleCI orb for it. That means a command file per subcommand, a job file per subcommand, an
executor, a Dockerfile, and then the CI configuration to keep everything in sync. The output
is almost entirely derivable from the binary's own `--help` text — but until now I was writing
it by hand.

[gen-circleci-orb](https://github.com/jerus-org/gen-circleci-orb) automates this entirely.

## The core idea

A clap-generated CLI already describes itself precisely via `--help`. Every flag has a name,
a type (boolean, string, enum), an optional default, and a required/optional marker. That
information is exactly what a CircleCI orb needs: one parameter per flag, one `run:` step per
subcommand, a conditional mustache expression per optional flag.

`gen-circleci-orb` runs `<binary> --help` and `<binary> <subcommand> --help` for each subcommand,
parses the output, and emits the full unpacked orb:

```
orb/
├── src/
│   ├── @orb.yml                  # version: 2.1, description
│   ├── executors/default.yml     # Docker executor with << parameters.tag >>
│   ├── commands/generate.yml
│   ├── commands/validate.yml
│   ├── jobs/generate.yml
│   └── jobs/validate.yml
└── Dockerfile
```

The `@orb.yml` is metadata-only — `circleci orb pack` discovers everything else from the
subdirectories automatically.

## Demo: generating an orb for gen-orb-mcp

[gen-orb-mcp](https://github.com/jerus-org/gen-orb-mcp) is my tool for generating MCP servers
from CircleCI orb definitions. It has five subcommands: `generate`, `validate`, `diff`,
`migrate`, and `prime`.

```bash
gen-circleci-orb generate \
  --binary gen-orb-mcp \
  --orb-namespace my-org
```

Running that produces 13 files. The `commands/generate.yml` looks like this:

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
  force:
    type: boolean
    description: Overwrite existing output without confirmation
    default: false
steps:
  - run:
      name: generate
      command: <<include(scripts/generate.sh)>>
      environment:
        ORB_PATH: << parameters.orb_path >>
        OUTPUT: << parameters.output >>
        FORCE: << parameters.force >>
```

And the included `scripts/generate.sh`:

```bash
set -- gen-orb-mcp generate
set -- "$@" --orb-path "${ORB_PATH}"
[ -n "${OUTPUT:-}" ] && set -- "$@" --output "${OUTPUT}"
[ "${FORCE:-false}" = "true" ] && set -- "$@" --force
"$@"
```

Parameters are passed through an `environment:` block, where CircleCI substitutes
`<< parameters.x >>` at the YAML level before the step runs. The script reads them as
ordinary shell variables. Required parameters unconditionally append their flag; optional
string parameters use a shell guard (`[ -n "${VAR:-}" ]`) to skip the flag when the
variable is empty; boolean parameters compare to the string `"true"`. The long command
is kept in the script file, not inlined in the YAML, which satisfies the orb best-practice
review rule (RC009) requiring complex run steps to use `<<include(...)>>`.

Validation passes immediately:

```
$ gen-orb-mcp validate --orb-path orb/src/@orb.yml
Orb validation successful!
  5 commands, 5 jobs, 1 executor
```

## Wiring into CI

The `init` subcommand does the heavy lifting of connecting the generated orb to the release
pipeline. It is interactive: run it with just your binary and it prompts for the values it needs
— the workflow names, the orb and Docker namespaces, the crate tag prefix, and the CI contexts
holding your credentials — each pre-filled with a sensible default:

```bash
gen-circleci-orb init --binary my-tool
```

Prefer to script it? Pass everything up front and each prompt is skipped:

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

It patches `.circleci/config.yml` additively — existing jobs and workflows are untouched — and
records every value in a `gen-circleci-orb.toml`, so `generate` and `update` never need the flags
again. On every build, a `regenerate-orb` job runs `gen-circleci-orb generate` fresh, then
`orb-tools/pack` and `orb-tools/review` confirm the output is valid. On each release tag,
`build-container` publishes the Docker image and `orb-tools/publish` publishes the orb.

The regeneration runs inside the pre-built `gen-circleci-orb` orb, so a consumer declares the orb
and its own tool's image — there is nothing to install at build time.

Running `init` twice is safe: it reads the existing `gen-circleci-orb.toml` and only fills in
what is missing.

## Keeping it in sync

The generator keeps evolving, so the CI it emits can change shape between releases. That is what
the third subcommand, `update`, is for: it re-syncs only the gen-circleci-orb-managed blocks in
`config.yml` from your committed `gen-circleci-orb.toml`, leaving your own jobs untouched.

```bash
gen-circleci-orb update --check   # in CI: fail if the managed wiring is out of date
gen-circleci-orb update           # apply the re-sync
```

Wire `update --check` into your validation workflow and a generator upgrade shows up as a failing
check with a diff, rather than silent drift. This project uses it on itself — gen-circleci-orb's
own CI is generated by gen-circleci-orb — so the tool is exercised end to end on every change.

## Beyond one job per subcommand

One job per subcommand is the default, and for a simple CI it is enough. But the generated
*commands* are also building blocks: a bit of configuration can compose several of them — plus
checkout, workspace, and custom steps — into a single goal-oriented job, so consumers of your orb
run one job instead of wiring five. That is exactly how gen-orb-mcp's orb ships a `build_mcp_server`
job that primes, generates, compiles, publishes, and commits back in one step. The trade is that a
composed job is yours to maintain — it is not derived from `--help`. The
[Advanced Configuration Guide](@/projects/gen-circleci-orb/advanced-configuration.md) walks through
it, with `build_mcp_server` as the worked example.

## How it works

The help parser targets clap's output format:

- `Commands:` section → subcommand names and descriptions
- `Options:` section → one `Parameter` per flag
  - No `<VALUE>` metavar → `Boolean`
  - `Possible values:` continuation block → `Enum`
  - `[default: x]` in description → optional parameter with default
  - No default and has `<VALUE>` → required parameter

The parser is indentation-aware. The `Possible values:` text that follows an enum flag in
clap output is indented — it's part of the flag's description block, not a top-level section.
Getting that right required careful handling of clap's multi-line flag descriptions.

The orb generator maps the parsed `CliDefinition` to YAML directly. One edge case worth
noting: `circleci orb pack` expects `version: 2.1` as a YAML float, not a quoted string.
`serde_yaml` quotes strings by default, so `@orb.yml` is hand-formatted to guarantee the
correct YAML type.

## Getting started

`gen-circleci-orb` is now at its first pre-production release (0.1.x) — the generator, the
`gen-circleci-orb.toml` schema, and the generated CI are stable enough for real use, with the CLI
surface still free to evolve ahead of 1.0.

```bash
cargo binstall gen-circleci-orb
gen-circleci-orb init --binary <your-binary>   # interactive: captures config, orb, and CI
```

Full documentation at [docs/user-guide.md](https://github.com/jerus-org/gen-circleci-orb/blob/main/docs/user-guide.md)
and [docs/getting-started.md](https://github.com/jerus-org/gen-circleci-orb/blob/main/docs/getting-started.md).
