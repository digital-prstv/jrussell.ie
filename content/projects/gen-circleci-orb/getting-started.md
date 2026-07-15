+++
title = "gen-circleci-orb: Getting Started"
description = "Quick start for gen-circleci-orb — generate a CircleCI orb from a Rust clap CLI binary and wire it into CI."
weight = 20

[taxonomies]
tags = ["Rust", "CircleCI", "Orb", "Code Generation", "CLI", "Automation", "documentation"]
+++

gen-circleci-orb reads the `--help` output of a Rust [clap](https://docs.rs/clap) CLI and
generates a complete CircleCI orb for it — then, optionally, the CI wiring that keeps the orb in
sync with the binary on every release. A clap CLI already describes itself precisely: every flag
has a name, a type, a default, and a required/optional marker. That is exactly what an orb
parameter needs, so the whole orb is derivable from `--help`.

## Installation

### With cargo-binstall (pre-compiled binary)

```bash
cargo binstall gen-circleci-orb
```

### From crates.io

```bash
cargo install gen-circleci-orb
```

### Verify

```bash
gen-circleci-orb --version
```

---

## Start with `init`

`init` is the entry point. It captures your setup once — **interactively** — into a
`gen-circleci-orb.toml`, generates the orb source, and patches `.circleci/config.yml` so the orb
stays in sync automatically. Every later command reads that file, so this is the only step where
you supply values.

Run it with just the binary and it prompts for the required values it doesn't have — the build
and release workflow names, the orb and Docker namespaces, the crate tag prefix, the CI contexts
that hold your credentials, and (if enabled) auto-record — each pre-filled with a sensible default
you can accept or override:

```bash
gen-circleci-orb init --binary my-tool
```

Passing a flag skips its prompt, so the same command is fully scriptable for non-interactive
environments (CI, or `--dry-run`, which forces non-interactive mode) by supplying everything up
front:

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

`init` adds:

- a `build-binary` + `regenerate-orb` job pair that rebuilds the binary and re-generates the orb
  on every CI run, so the orb always reflects the current `--help`;
- `orb-tools/pack` + `orb-tools/review` steps to validate the generated orb;
- a tag-triggered `orb-release:` workflow that, on each `my-tool-v*` release tag, builds the
  container, registers the orb, and publishes it to the CircleCI registry.

Commit `gen-circleci-orb.toml` alongside the CI changes — it is the single source of truth for
every subsequent `generate` and `update`.

---

## Regenerate with `generate`

`generate` (re)writes the orb source from the binary's current `--help`. Once `init` has written
the config, it needs **no flags** — it reads the binary, namespaces, base image, and output
directory straight from `gen-circleci-orb.toml`:

```bash
gen-circleci-orb generate
```

This is what the `regenerate-orb` CI job runs on every build, so the published orb never drifts
from the binary. It writes the unpacked orb into the configured `orb/` subdirectory:

```
orb/
├── src/
│   ├── @orb.yml                 # orb metadata (version 2.1, description)
│   ├── commands/<subcommand>.yml
│   ├── jobs/<subcommand>.yml
│   └── executors/default.yml    # Docker executor with a tag parameter
└── Dockerfile                   # image that pre-installs your binary
```

You can also run `generate` **without** a config — for a quick look or to publish an orb by hand
without CI automation — but then you must supply the values (and know their defaults) explicitly:

```bash
gen-circleci-orb generate --binary my-tool --orb-namespace my-org
```

Verify the output locally with `circleci orb pack orb/src > /tmp/my-tool-orb.yml`.

---

## Keep the wiring current with `update`

As gen-circleci-orb itself evolves, the canonical CI it emits can change. `update` re-syncs only
the managed blocks in `config.yml` from your committed `gen-circleci-orb.toml`, preserving your
own jobs:

```bash
gen-circleci-orb update --check   # in CI: fail if the managed wiring is out of date
gen-circleci-orb update           # apply the re-sync locally
```

Add `update --check` to your validation workflow so a generator upgrade surfaces as a failing
check rather than silent drift. Unlike `init`, `update` is non-interactive: it relies entirely on
`gen-circleci-orb.toml` and fails (pointing you back at `init`) if a required value is missing,
rather than prompting. To change the wiring, edit `gen-circleci-orb.toml` and re-run `update`
(or re-run `init` to be re-prompted for the values).

---

## Optional — MCP for your generated orb

Pass `--mcp` to `init` to wire in [gen-orb-mcp](../gen-orb-mcp). Each release then generates a
migration-rules file and (optionally) an MCP server, so an AI assistant — or a human reading the
rules directly — can understand the orb and guide consumers through version upgrades.

---

## See Also

- [CLI Reference](cli-reference) — full command and option documentation
- [Repository](https://github.com/jerus-org/gen-circleci-orb) — source and issue tracking
- [API Documentation](https://docs.rs/gen-circleci-orb) — generated Rust API reference
