+++
title = "gen-orb-mcp"
description = "Generate MCP servers from CircleCI orb definitions so AI assistants can understand and migrate private orbs."
weight = 15

[taxonomies]
tags = ["Rust", "MCP", "CircleCI", "Code Generation", "CLI", "AI"]

[extra]
pinned = true
quick_navigation_buttons = true

local_image = "projects/gen-orb-mcp/gen-orb-mcp-logo.webp"
+++

**gen-orb-mcp** enables AI coding assistants to understand and work with private CircleCI orbs. It parses an orb YAML definition and generates a standalone MCP server that exposes the orb's commands, jobs, and executors as MCP Resources. When conformance rules are provided, the generated server also gains `plan_migration` and `apply_migration` MCP Tools, allowing an AI assistant to guide users through orb version migrations interactively.

The tool supports a full orb lifecycle workflow. `generate` produces a ready-to-compile Rust crate embedding the orb documentation as static resources. `prime` automates prior-version history by walking the orb repository's git tags, snapshotting each version, and computing conformance diffs — all in one step. `diff` and `migrate` provide conformance-based migration for scripted bulk updates, and `validate` checks orb definitions before generation.

[Getting Started](getting-started)

[CLI Reference](cli-reference)

[Migration Guide](migration-guide)
