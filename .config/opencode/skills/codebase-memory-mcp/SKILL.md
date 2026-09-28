---
name: Codebase Memory (MCP)
description: Structural code discovery through the codebase-memory-mcp knowledge graph. Load when the codebase-memory-mcp MCP tools are connected, for symbols, call graphs, routes, architecture, and impact analysis.
---

# Codebase Memory

Use the graph for code structure. Use text search for text.

## Precondition

These rules apply only while the `codebase-memory-mcp` tools are available in
the session. When the server is not connected, do not follow this workflow and
do not claim graph evidence. Use `grep` and `glob` instead.

The project `opencode.jsonc` owns the server connection. That file is the source
of truth for whether the server is enabled. Do not duplicate its settings here.

## Tool selection

| Task | Tool |
| --- | --- |
| Find a symbol by name pattern | `search_graph` |
| Find callers or callees | `trace_path` |
| Read one symbol's source | `get_code_snippet` |
| Check whether the index covers a path | `check_index_coverage` |
| Match a multi-step structure | `query_graph` |
| Orient in an unfamiliar project | `get_architecture` |
| Confirm the project and its freshness | `list_projects`, `index_status` |

Start with the narrowest tool that answers the question. Read exact source for
material claims.

## Evidence tiers

Choose one tier before you gather evidence, then stay in it. When the tier is
unclear, use Scout.

- **Scout** — a quick positive lookup. Mark the answer provisional. Make no
  negative or exhaustive claim.
- **Verify** — the default. Task-directed graph evidence, both relevant trace
  directions, exact snippets for material claims, and relevant pagination.
- **Auditor** — bounded-scope full verification for a release, a security
  review, or a similar high-stakes claim.

Read `references/evidence-tiers.md` before any negative or exhaustive claim, and
before you report an Auditor result.

## Coverage

After you know the candidate paths, call `check_index_coverage` once with every
evidence path. A clean result means no recorded gap, not proof of completeness.
For partial, skipped, excluded, stale, pending, or unknown coverage, read or
grep the reported ranges before you rely on the graph.

## Text search fallback

Use `grep` and `glob` for:

- String literals, error messages, and configuration values
- Files outside the graph, such as Dockerfiles, shell scripts, and configs
- Any case where the graph returns insufficient results

## Prohibitions

- Never claim that code is absent, unused, or dead from a Scout result.
- Never report a negative or exhaustive result without checking coverage and
  reading the reported gap ranges.
- Never assume a subagent inherits this session's MCP tools or conversation.
  Gather the graph evidence in the parent and pass the tier, project,
  generation, scope, queries, pagination state, qualified symbols, paths,
  call-chain findings, coverage evidence with ranges and reasons, the text
  search already done, and the open questions.
- A child without the MCP tools must not call them and must not claim graph
  access. It uses the supplied evidence and reads or greps the exact source,
  including every reported missed-coverage range.

## Examples

```text
Find a handler:   search_graph(name_pattern=".*OrderHandler.*")
Who calls it:     trace_path(function_name="OrderHandler", direction="inbound")
Read its source:  get_code_snippet(qualified_name="pkg/orders.OrderHandler")
```
