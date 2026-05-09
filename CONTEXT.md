# Totes — Domain Context

## CI/CD

GitHub Actions pipeline on every push + tag:
- `selene` — Lua static analysis
- `stylua` — Lua formatting check
- On git tag push (e.g. `v1.0.0`): automated GitHub Release created with changelog extracted from commits. This is what `:Totes update` polls against.

## `totes` shell command

A single-purpose launcher — no arguments, no subcommands. Invokes NeoVim with the totes config and opens the Vault:

```sh
nvim -u ~/.local/share/totes/init.lua ~/totes/
```

Plugin data isolated to `~/.local/share/totes/` (not the user's `~/.local/share/nvim/`). All management operations are handled by `:Totes` inside NeoVim.

## NeoVim version requirement

Minimum: NeoVim 0.10+. Required for `vim.system()` (async git) and `render-markdown.nvim`. A startup warning (not error) is shown if the running version is below 0.10. Older versions are unsupported.

## Installation

The totes tool installs to `~/.local/share/totes/`. An install script (in this repo) clones the repo there and adds the `totes` binary to `$PATH`. The `:Totes update` command knows to run `git fetch`/`git checkout` at that fixed location. Homebrew packaging is out of scope for now.

## Two-repo model

There are exactly two git repositories involved:

1. **The totes tool** (this repo) — the NeoVim config, Lua plugins, and shell command. Hosted on GitHub, versioned with git tags, managed via `:Totes`.
2. **The Vault** — the user's notes directory (`~/totes/`). Entirely separate, local-only, no remote. Never part of this repo.

These must never be conflated.

## Search scope

Search is limited to filenames and note `title` frontmatter fields only. No full-text content search. Implemented via `telescope.nvim` with a custom source. Telescope also handles WikiLink disambiguation (ambiguous matches open a Telescope picker).

## Keybindings

Leader key: `<Space>`. Set explicitly in the totes config; the user's personal leader is irrelevant since totes ignores the user's config.

- `<leader>n` — create new Note (prompts for title, lands in `inbox/`)
- `<leader>p` — promote current Inbox Note to `notes/` (with confirmation)
- `<leader>f` — fuzzy find notes by filename/title
- `<leader>ft` — filter by tag, then list matching notes
- `<leader>b` — show backlinks (Telescope picker, greps vault for `[[Current Note Name]]`)
- `gf` — follow WikiLink under cursor (broken link offers to create; ambiguous opens picker)
- `<C-o>` — navigate back (standard Vim jumplist)

## Plugin philosophy

Lean on existing NeoVim plugins for commodity features (markdown rendering, file tree, splash screen, plugin management). Only write custom Lua for behaviour that has no suitable existing plugin — specifically the `:Totes` command and WikiLink navigation. `obsidian.nvim` is explicitly excluded: too heavy and couples the tool to the Obsidian ecosystem.

Confirmed plugin selections:
- `lazy.nvim` — plugin manager
- `telescope.nvim` — fuzzy finder, WikiLink disambiguation, backlinks
- `render-markdown.nvim` — markdown rendering
- `neo-tree.nvim` — file tree
- `nui.nvim` — custom UI components (used by `:Totes` command)
- `alpha-nvim` — splash screen with ASCII logo and random tagline from a fixed list:
  - "Notes, by Todd"
  - "Lemme write that down"
  - "Yet another note tool?"

## Glossary

### Vault
The single, fixed directory on the user's filesystem where all notes are stored. There is exactly one Vault per user installation — no multi-vault support. Default location: `~/totes/`.

- Avoid: "workspace", "notebook", "library", "directory"
- Fixed top-level structure: `inbox/` (fleeting/unrefined), `notes/` (permanent), `assets/` (non-markdown files)
- Cross-cutting organisation is handled by frontmatter tags, not folders
- Automatically git-initialised on first `totes` launch. Notes are auto-committed on save, asynchronously (non-blocking). No remote. History is local-only.

### `:Totes` command
Custom NeoVim command for managing the totes tool. Built with `nui.nvim`.

- `:Totes` (no args) — opens the Changelog window (may gain additional windows in future)
- `:Totes update` — fetches tags from origin, checks out latest if newer, prompts user to restart
- `:Totes changelog` — alias for no-args behaviour
- Version selection (downgrade) is explicitly out of scope

### Note
A markdown file in the Vault. Has three required frontmatter fields, all auto-populated on creation: `title` (human-readable name), `tags` (list of strings), `created` (ISO timestamp). No `id` or `modified` field. New Notes always land in `inbox/`. A dedicated command promotes an `inbox/` Note to `notes/`. Filenames are kebab-case derived from the title (e.g. "My Thoughts on Rust" → `my-thoughts-on-rust.md`).

- Avoid: "document", "file", "page", "entry"

### Inbox Note
A Note in `inbox/` — fleeting, unrefined, not yet processed. Promoted to `notes/` via a confirm prompt. No frontmatter changes on promotion.

### Permanent Note
A Note in `notes/` — processed and refined. Promoted from an Inbox Note via explicit command with confirmation.

- Avoid: "processed note", "final note"

### WikiLink
A link between notes written as `[[Note Name]]` or `[[Note Name|Alias]]`. Resolved by case-insensitive filename match across the entire Vault. Zero matches = offer to create the Note in `inbox/`. Multiple matches = Telescope picker. Alias syntax supported.

- Avoid: "internal link", "note link"
