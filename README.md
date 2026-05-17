# totes

A stripped-back NeoVim environment for Zettelkasten note-taking, organised with the PARA method. Runs as a standalone command — isolated from your regular NeoVim config.

## Requirements

- NeoVim 0.10+
- Git

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/toddhainsworth/totes/main/install.sh | bash
```

This clones totes to `~/.local/share/totes/` and adds the `totes` binary to your `PATH` via your shell rc file. Restart your shell (or `source` your rc file) when done.

## Usage

```bash
totes
```

That's it. Opens NeoVim with your Vault (`~/totes/`) and the totes config. Your regular `~/.config/nvim/` is not loaded — the experience is consistent across machines.

On first launch, totes creates the Vault structure and initialises a local git repo:

```
~/totes/
  inbox/    ← new notes land here
  notes/    ← permanent notes
  daily/    ← day logs
  assets/   ← attachments
```

## Keybindings

Leader key is `\`.

### Notes

| Key | Action |
|-----|--------|
| `<leader>n` | Create a new Inbox Note (prompts for title) |
| `<leader>d` | Open today's Daily Note (creates it if needed) |
| `<leader>p` | Promote the current Inbox Note to `notes/` |
| `<leader>a` | Archive the current Permanent Note |

### Tasks

| Key | Action |
|-----|--------|
| `<leader>t` | Add a Task to the Task Note (prompts for task text) |
| `<leader>T` | Open the Task Note (`notes/tasks.md`) |
| `<leader>x` | Toggle the checkbox state on a task line (`- [ ]` ↔ `- [x]`) |

### Navigation

| Key | Action |
|-----|--------|
| `<leader>ff` | Fuzzy-find notes by filename or title |
| `<leader>ft` | Filter notes by tag (supports prefix matching, e.g. `project/`) |
| `<leader>b` | Show backlinks — notes that link to the current note |
| `gf` | Follow a `[[WikiLink]]` under the cursor |
| `<C-o>` | Navigate back through jump history |

### WikiLinks

Write links as `[[note-stem]]` — the canonical bracket contents are the kebab-case filename stem (without `.md`), e.g. `[[my-thoughts-on-rust]]`. For human-readable display in prose, use alias syntax: `[[my-thoughts-on-rust|My Thoughts on Rust]]`.

Following a link with `gf`:

- **One match** — opens the note directly
- **Multiple matches** — opens a Telescope picker
- **No match** — offers to create the note in `inbox/`

Autocomplete fires automatically as you type inside `[[`. The popup shows both the stem and the note's `title` frontmatter, and fuzzy-matching spans both (so typing `rust` finds `my-thoughts-on-rust` titled "My Thoughts on Rust"). Only the stem is inserted — aliases stay a deliberate, user-typed concern.

Daily Notes are excluded from autocomplete suggestions (their date filenames make poor link targets), but they remain linkable by hand and resolvable via `gf`.

## Note frontmatter

Every note has three auto-populated frontmatter fields:

```yaml
---
title: Totes Plugin Architecture
tags:
  - project/totes
created: 2026-05-13T09:00:00Z
---
```

Tags follow a two-level hierarchical kebab-case convention: `project/totes`, `area/health`, `resource/neovim`. Archive tags extend to three levels: `archive/project/totes`. A note with no tags has `tags: []`.

## Tasks

Tasks live in a single Task Note at `notes/tasks.md`. Each task is appended as a Markdown list item when you use `<leader>t`. You can embed WikiLinks (e.g. `[[my-thoughts-on-rust]]`) in task text to link tasks to related notes.

The Task Note is created automatically the first time you add a task or open it with `<leader>T`. It cannot be promoted or archived.

## How promotion and archiving work

**Promoting** (`<leader>p`) moves a note from `inbox/` to `notes/`. A popup lets you optionally assign a PARA tag (e.g. `project/totes`, `area/health`). Press `Tab` to accept the autocomplete suggestion, `Enter` to promote without a tag.

**Archiving** (`<leader>a`) transforms the note's PARA tag in-place, prefixing it with `archive/` (e.g. `project/totes` → `archive/project/totes`), then asks for confirmation before writing. The note stays in `notes/` — the tag change is the archive signal.

Daily Notes and the Task Note cannot be promoted or archived.

## Notes are auto-committed

Every save triggers an async `git commit` in the Vault repo. No manual git interaction needed.
