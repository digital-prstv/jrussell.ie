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
  --namespace jerus-org \
  --output orb
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
    default: ./out
steps:
  - run:
      name: generate
      command: >-
        gen-orb-mcp generate
        --orb-path "<< parameters.orb_path >>"
        <<# parameters.output >>--output "<< parameters.output >>"<</ parameters.output >>
```

Optional parameters use CircleCI's mustache conditional syntax so they're only included in
the command when set. Required parameters are always included without a conditional.

Validation passes immediately:

```
$ gen-orb-mcp validate --orb-path orb/src/@orb.yml
Orb validation successful!
  5 commands, 5 jobs, 1 executor
```

## Wiring into CI

The `init` subcommand does the heavy lifting of connecting the generated orb to the release
pipeline. Run it once from the repo root:

```bash
gen-circleci-orb init \
  --binary gen-orb-mcp \
  --namespace jerus-org \
  --build-workflow validation \
  --release-workflow release \
  --requires-job common-tests \
  --release-after-job release-gen-orb-mcp
```

It patches `.circleci/config.yml` and `.circleci/release.yml` additively — existing jobs and
workflows are untouched. On every build, a `regenerate-orb` job runs `gen-circleci-orb generate`
fresh, then `orb-tools/pack` and `orb-tools/validate` confirm the output is valid. On release,
`build-container` publishes the Docker image and `orb-tools/publish` publishes the orb.

The generated CI is self-bootstrapping — it installs `gen-circleci-orb` at runtime via
`cargo binstall`. It uses only standard public CircleCI orbs (`circleci/docker`,
`circleci/orb-tools`) and works for any public open-source project without prior setup.

Running `init` twice is safe: it checks for existing entries before inserting and skips
anything already present.

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

```bash
cargo binstall gen-circleci-orb
gen-circleci-orb generate --binary <your-binary> --namespace <your-namespace> --output orb
```

Full documentation at [docs/user-guide.md](https://github.com/jerus-org/gen-circleci-orb/blob/main/docs/user-guide.md)
and [docs/getting-started.md](https://github.com/jerus-org/gen-circleci-orb/blob/main/docs/getting-started.md).
