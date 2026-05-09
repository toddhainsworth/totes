# ADR-0001: Async, non-blocking git commits for Vault auto-save

## Status
Accepted

## Context
The Vault is automatically git-tracked. Notes are committed on every save so that `modified` history is available without a frontmatter field. The commit must not introduce perceptible latency in the editor.

## Decision
Use `vim.system()` (async) to run `git add` + `git commit` after each buffer write. The result is fire-and-forget — errors are logged silently (no UI interruption). Commit messages are auto-generated from the note title and timestamp.

## Alternatives considered
- **Synchronous `os.execute`**: simpler, but blocks the editor on every save — unacceptable UX.
- **Debounced batch commits**: commits multiple saves at once. Reduces git noise but delays history granularity. Rejected in favour of per-save simplicity for now.

## Consequences
- Git history granularity is per-save, which may be noisy. Acceptable for a local-only repo.
- Commit failures (e.g., nothing to commit) must be silently swallowed.
- Requires NeoVim 0.10+ for stable `vim.system()` API.
