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

Plugin data isolated to `~/.local/share/totes/` (not the user's `~/.local/share/nvim/`). Isolation is achieved by setting `XDG_DATA_HOME=~/.local/share/totes` before launch, which causes NeoVim's `stdpath('data')` to resolve to `~/.local/share/totes/nvim/`. All management operations are handled by `:Totes` inside NeoVim.

## NeoVim version requirement

Minimum: NeoVim 0.10+. Required for `vim.system()` (async git) and `render-markdown.nvim`. A startup warning (not error) is shown if the running version is below 0.10. Older versions are unsupported.

## Installation

The totes tool installs to `~/.local/share/totes/`. An install script (in this repo) clones the repo there and adds the `totes` binary to `$PATH`. The `:Totes update` command knows to run `git fetch`/`git checkout` at that fixed location. Homebrew packaging is out of scope for now.

Directory layout at `~/.local/share/totes/` after first launch:
- `bin/`, `init.lua`, `lua/` — source files from the git clone
- `nvim/` — runtime data written by NeoVim (lazy.nvim plugins, state); git-ignored
- `lazy-lock.json` — lazy.nvim lock file; git-ignored (churns on every `:Totes update`)

## Two-repo model

There are exactly two git repositories involved:

1. **The totes tool** (this repo) — the NeoVim config, Lua plugins, and shell command. Hosted on GitHub, versioned with git tags, managed via `:Totes`.
2. **The Vault** — the user's notes directory (`~/totes/`). Entirely separate, local-only, no remote. Never part of this repo.

These must never be conflated.

## Search scope

Search is limited to filenames and note `title` frontmatter fields only. No full-text content search. Implemented via `telescope.nvim` with a custom source. Telescope also handles WikiLink disambiguation (ambiguous matches open a Telescope picker).

## Keybindings

Leader key: `\` (backslash). Set explicitly in the totes config; the user's personal leader is irrelevant since totes ignores the user's config.

- `<leader>n` — create new Note (prompts for title, lands in `inbox/`)
- `<leader>d` — open today's Daily Note in `daily/` (creates it if it doesn't exist, filename: `YYYY-MM-DD.md`)
- `<leader>p` — promote current Inbox Note to `notes/`. Opens a single `nui.nvim` popup: heading shows the target path, optional PARA tag input with live autocomplete hints (sourced from existing vault tags, Tab accepts top suggestion), Enter confirms and promotes (tag is optional). Blocked on Daily Notes — shows a notice directing the user to `<leader>n` instead
- `<leader>ff` — fuzzy find notes by filename/title
- `<leader>ft` — filter by tag, then list matching notes. Supports prefix matching for hierarchical tags (e.g. `project/` returns all notes under any project)
- `<leader>b` — show backlinks (Telescope picker, greps vault for `[[Current Note Name]]`)
- `gf` — follow WikiLink under cursor (broken link offers to create; ambiguous opens picker)
- `<leader>a` — archive current note. Opens a `nui.nvim` yes/no confirmation menu (arrow keys or Enter/Escape). On confirm, embeds the original full PARA tag under `archive/` (e.g. `project/totes` → `archive/project/totes`). If the note has no PARA tag, falls back to `archive/<filename-stem>`. Blocked on Daily Notes — shows a notice and does nothing.
- `<leader>t` — add a Task (prompts for text via `nui.nvim`, appends `- [ ] <text>` to the Task Note)
- `<leader>T` — open the Task Note (`notes/tasks.md`)
- `<C-o>` — navigate back (standard Vim jumplist)
- `jj` (insert) — exit insert mode (mapped to `<Esc>`)

## Plugin philosophy

Lean on existing NeoVim plugins for commodity features (markdown rendering, splash screen, plugin management). Only write custom Lua for behaviour that has no suitable existing plugin — specifically the `:Totes` command and WikiLink navigation. `obsidian.nvim` is explicitly excluded: too heavy and couples the tool to the Obsidian ecosystem. `neo-tree.nvim` is excluded — navigation is Telescope-first and a file tree adds weight without supporting any designed workflow.

Confirmed plugin selections:
- `lazy.nvim` — plugin manager
- `telescope.nvim` — fuzzy finder, WikiLink disambiguation, backlinks
- `render-markdown.nvim` — markdown rendering
- `nui.nvim` — custom UI components (used by `:Totes` command)
- `alpha-nvim` — splash screen with ASCII logo, random tagline from a fixed list, and a live inbox note count (e.g. "3 notes waiting in inbox"):
  - "Notes, by Todd"
  - "Lemme write that down"
  - "Yet another note tool?"

## Glossary

### Vault
The single, fixed directory on the user's filesystem where all notes are stored. There is exactly one Vault per user installation — no multi-vault support. Default location: `~/totes/`.

- Avoid: "workspace", "notebook", "library", "directory"
- Fixed top-level structure: `inbox/` (fleeting/unrefined), `notes/` (permanent), `daily/` (date-stamped daily notes, not expected to be promoted), `assets/` (non-markdown files)
- Cross-cutting organisation follows the PARA method (Projects, Areas, Resources, Archive) via frontmatter tags, not folders. Tag convention: `project/totes`, `area/health`, `resource/neovim` — two-level, hierarchical, kebab-case. Archive tags are three-level: `archive/project/totes`, `archive/area/health` — the original full tag is preserved under `archive/` to avoid collisions between same-named items in different PARA categories
- Automatically git-initialised on first `totes` launch. Notes are auto-committed on save, asynchronously (non-blocking). No remote. History is local-only.

### `:Totes` command
Custom NeoVim command for managing the totes tool. Built with `nui.nvim`.

- `:Totes` (no args) — opens the Changelog window (may gain additional windows in future)
- `:Totes update` — fetches tags from origin, checks out latest if newer, prompts user to restart
- `:Totes changelog` — alias for no-args behaviour
- Version selection (downgrade) is explicitly out of scope

### Note
A markdown file in the Vault. Has three required frontmatter fields, all auto-populated on creation: `title` (human-readable name), `tags` (list of strings), `created` (ISO timestamp). No `id` or `modified` field. Notes created via `<leader>n` always land in `inbox/`. Daily Notes (created via `<leader>d`) land in `daily/` and are a distinct type. Filenames are kebab-case derived from the title (e.g. "My Thoughts on Rust" → `my-thoughts-on-rust.md`).

- Avoid: "document", "file", "page", "entry"

### Inbox Note
A Note in `inbox/` — fleeting, unrefined, not yet processed. Promoted to `notes/` via a confirm prompt. No frontmatter changes on promotion.

### Permanent Note
A Note in `notes/` — processed and refined. Promoted from an Inbox Note via explicit command with confirmation.

- Avoid: "processed note", "final note"

### Daily Note
A date-stamped note in `daily/` opened via `<leader>d`. One file per calendar day (`YYYY-MM-DD.md`). Intended as an ephemeral junk drawer — not expected to be promoted. If something in a Daily Note is worth keeping, the workflow is: `<leader>n` to create a new Inbox Note, paste the relevant section, then promote or archive from there. Both `<leader>p` (promote) and `<leader>a` (archive) are blocked on Daily Notes — they show a notice and do nothing.

- Avoid: "journal", "log", "diary"

### WikiLink
A link between notes written as `[[Note Name]]` or `[[Note Name|Alias]]`. Resolved by case-insensitive filename match across the entire Vault. Zero matches = offer to create the Note in `inbox/`. Multiple matches = Telescope picker. Alias syntax supported.

- Avoid: "internal link", "note link"

### Task
A markdown checkbox line (`- [ ] <text>`) stored in the Task Note. Tasks are plain text — no special frontmatter, no dedicated file per task. The user is responsible for embedding any relevant context (e.g. a WikiLink) directly in the task text. Tasks are added from any Note via `<leader>t` and collected in a single global Task Note.

- Avoid: "to-do", "action item", "checklist item"

### Task Note
A single, fixed Permanent Note at `notes/tasks.md` that collects all Tasks. Created automatically on first `<leader>t` if it does not exist. Not promotable, not archivable (special-cased like Daily Notes). Opened directly via `<leader>T`.
