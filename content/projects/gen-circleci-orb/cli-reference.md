+++
title = "gen-circleci-orb CLI Reference"
description = "Full CLI reference for gen-circleci-orb — the init, generate, update, and config commands and their options."
weight = 25

[taxonomies]
tags = ["Rust", "CircleCI", "Orb", "Code Generation", "CLI", "Automation", "documentation"]
+++

gen-circleci-orb generates a CircleCI orb from a Rust [clap](https://docs.rs/clap) CLI binary's
`--help` output. Four commands: `init` (the entry point — capture config, generate, and wire CI),
`generate` (rewrite the orb source from the captured config), `update` (re-sync the wiring), and
`config` (inspect/edit the generation settings). `init` writes `gen-circleci-orb.toml`; the other
commands read it.

## `init` — Set up config, orb, and CI

Captures your setup into `gen-circleci-orb.toml`, runs `generate`, and patches
`.circleci/config.yml`. **Interactive**: any required value not passed as a flag is prompted for,
pre-filled with a sensible default. Passing a flag skips its prompt; `--dry-run` (or no TTY)
forces non-interactive mode, in which case every required value must be supplied.

```
gen-circleci-orb init [OPTIONS] --binary <BINARY>

Required (prompted if omitted):
  --binary <BINARY>                Binary to introspect (must be on PATH)
  --public-orb-namespace <NS>      CircleCI orb namespace, public (repeatable)
  --private-orb-namespace <NS>     CircleCI orb namespace, private (repeatable)
                                   (supply at least one of public/private)
  --docker-namespace <NS>          Docker Hub (or registry) namespace for the image
  --build-workflow <WF>            Validation workflow name to patch
  --release-workflow <WF>          Release workflow name to patch
  --crate-tag-prefix <PREFIX>      Crate release tag prefix (e.g. my-tool-v); filters
                                   the orb-release: workflow trigger
  --release-after-job <JOB>        Job in the release workflow after which orb jobs run

Options:
  --requires-job <JOB>             Job that regenerate-orb should require
  --orb-dir <DIR>                  Orb output directory [default: orb]
  --ci-dir <DIR>                   CircleCI config directory [default: .circleci]
  --orb-tools-version <VER>        circleci/orb-tools pin [default: 12.3.3]
  --gen-circleci-orb-version <VER> jerus-org/gen-circleci-orb orb pin
                                   [default: running binary version]
  --docker-context <CTX>           Context for Docker Hub credentials
                                   [default: docker-credentials]
  --orb-context <CTX>              Context for orb publish credentials
                                   [default: orb-publishing]
  --mcp                            Wire in gen-orb-mcp MCP server generation + publish
  --gen-orb-mcp-version <VER>      jerus-org/gen-orb-mcp orb pin (with --mcp)
                                   [default: 0.1.48]
  --mcp-context <CTX>              Context for MCP server publish (with --mcp)
                                   [default: pcu-app]
  --dry-run                        Print planned changes, write nothing
```

## `generate` — (Re)generate orb source from a binary

Writes the unpacked orb (and Dockerfile) from a clap binary's `--help`. Does not touch CI. After
`init`, every value below falls back to the `[orb]` section of `gen-circleci-orb.toml`, so
`generate` can be run with no flags. Run it standalone (with flags) for a quick one-off before any
config exists.

```
gen-circleci-orb generate [OPTIONS]

Options (each falls back to gen-circleci-orb.toml [orb], then the built-in default):
  --binary <BINARY>           Binary to introspect (must be on PATH)
  --orb-namespace <NS>        CircleCI orb namespace (repeatable)
  --output <DIR>              Project root directory [default: .]
  --orb-dir <DIR>             Orb subdirectory within --output [default: orb]
  --install-method <METHOD>   binstall | apt [default: binstall]
  --base-image <IMAGE>        Docker base image [default: debian:13-slim]
  --home-url <URL>            Home URL for orb registry display
  --source-url <URL>          Source URL for orb registry display
  --config <FILE>             Path to gen-circleci-orb.toml
                              [default: <output>/gen-circleci-orb.toml]
  --dry-run                   Print planned files, write nothing
```

## `update` — Re-sync the managed CI wiring

Rewrites only the gen-circleci-orb-managed blocks in `config.yml` from the committed
`gen-circleci-orb.toml`, preserving your own jobs. Non-interactive: it never edits the config and
fails (pointing you at `init`) if a required value is missing.

```
gen-circleci-orb update [OPTIONS]

Options:
  --config <FILE>   Path to gen-circleci-orb.toml [default: gen-circleci-orb.toml]
  --ci-dir <DIR>    Path to the .circleci/ directory [default: .circleci]
  --check           Verify mode: write nothing and exit non-zero (with a diff and
                    guidance) when the wiring is out of date. For use in CI.
```

## `config` — Inspect and edit generation settings

Manages **orb-content generation** settings (which jobs are generated, composed job groups, and
parameter default overrides) without hand-editing TOML. It does not manage the CI wiring — for
that, edit `gen-circleci-orb.toml` directly or re-run `init`.

```
gen-circleci-orb config [--config <FILE>] <SUBCOMMAND>

  show                              Print the current configuration
  suppress-job <SUBCOMMAND>         Stop generating a job for a subcommand
  unsuppress-job <SUBCOMMAND>       Re-enable a previously suppressed job
  add-job-group --name <NAME> --steps <a,b,c> [--description <D>] [--parameters <p,q>]
                                    Compose several subcommand steps into one job
  set-parameter-default --subcommand <S> --parameter <P> --value <V>
                                    Override a generated parameter default
```

## The `gen-circleci-orb.toml` file

`init` writes this file; `generate` and `update` read it. It is the single source of truth for
the generated orb and CI.

| Section | Purpose |
|---------|---------|
| `[orb]` | The orb's own source and container: `binary`, `namespaces`, `orb_dir`, `base_image`, `builder_image`, `circleci_cli_version` |
| `[ci]` | Workflow/job wiring: `build_workflow`, `release_workflow`, `requires_job`, `release_after_job`, `crate_tag_prefix`, `docker_namespace`, `docker_context`, `orb_context`, the MCP fields, and `rust_image` |
| `[record]` | Optional auto-record: after `generate`, commit the regenerated orb source back (GPG-signed). Stores only env-var **names** — secrets stay in CI contexts |
| `[orbs]`, `[[job_group]]`, `[[extra_job]]`, `[subcommand.*]` | Extra orb pins, composed jobs, custom jobs, and per-subcommand overrides (e.g. `interactive`, `generate_job`) |

Two image knobs are distinct: `[orb].base_image` / `[orb].builder_image` configure the **orb's
own** generated Dockerfile, while `[ci].rust_image` configures the image the **CI build jobs**
compile in (set a clang-equipped, digest-pinned image there when a bindgen-based `-sys` crate is
in the tree).

## See Also

- [Getting Started](getting-started) — install to running pipeline
- [Repository](https://github.com/jerus-org/gen-circleci-orb) — source and issue tracking
- [API Documentation](https://docs.rs/gen-circleci-orb) — generated Rust API reference
