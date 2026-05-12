# ADR-0002: The `totes` shell command is a launcher only

## Status
Accepted

## Context
The `totes` binary could expose subcommands (e.g. `totes update`, `totes --version`) as is conventional for CLI tools. The `:Totes` NeoVim command already handles version management and changelog.

## Decision
The `totes` shell command does one thing: invoke NeoVim with the totes config and open the Vault. It accepts no arguments and exposes no subcommands. All management operations go through `:Totes` inside NeoVim.

Invocation:
```sh
nvim -u ~/.local/share/totes/init.lua ~/totes/
```

Plugin data is isolated to `~/.local/share/totes/` to avoid mixing with the user's own NeoVim plugins. Isolation is implemented by setting `XDG_DATA_HOME=~/.local/share/totes` in the launcher script, which redirects NeoVim's `stdpath('data')` without touching lazy.nvim's internals.

## Alternatives considered
- **Shell subcommands** (`totes update`, `totes changelog`): conventional, discoverable via `--help`, but duplicates the `:Totes` interface and splits the management surface across two contexts.
- **Explicit lazy.nvim `root` option**: sets plugin dir directly in Lua without touching XDG. Rejected because `XDG_DATA_HOME` also isolates NeoVim state and cache dirs, giving fuller separation with one env var.

## Consequences
- Users must open totes to manage it — no shell-level scripting of update/changelog.
- The shell script stays trivially simple and stable; all complexity lives in Lua.
- `~/.local/share/totes/nvim/` (NeoVim runtime data) and `lazy-lock.json` must be git-ignored in the totes repo, since the install dir and the git working tree are the same path.
