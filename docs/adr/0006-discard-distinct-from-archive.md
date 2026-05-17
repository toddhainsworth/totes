# ADR-0006: Discard is distinct from archive

## Status
Accepted

## Context
Triaging an Inbox Note has so far had two outcomes: promote (`<leader>p`, moves to `notes/`) and archive (`<leader>a`, retags the frontmatter to `archive/...`). Archive does not move the file — it only updates the tag. As a result, archiving an Inbox Note leaves the file sitting in `inbox/`, so archive is not actually a working triage outcome for inbox: it does not clear the inbox view.

Beyond that gap, there is a separate user need that archive has never served. Some Inbox Notes are not "valuable but inactive" — they are mistakes, half-thoughts that turned out to be nothing, captures the user immediately regretted. Keeping a retagged copy of every such note in perpetuity adds noise to the Vault and is unlikely to ever be revisited.

The Vault is auto-committed on save via async git (see ADR-0001). That history is local-only and has no remote, but it does exist, so any file that gets removed from disk is still recoverable by `git restore` or `git log -- <path>`.

## Decision
Introduce a third triage primitive — **discard** (`<leader>D`) — as a hard delete from disk. Discard is **inbox-only**: it acts on Inbox Notes and is blocked with a notice on Permanent Notes, Daily Notes, and the Task Note. The confirmation prompt is a `nui.menu` Y/N (per ADR-0005) with the focus defaulting to `No`. After deletion, the buffer is closed with `:bdelete!`.

The semantic split is:
- **Archive** = "this is no longer active, but it's worth keeping around." Preserves the file, retags its frontmatter.
- **Discard** = "this was a mistake; I never actually wanted this." Removes the file. Recovery is via autogit.

Archive's existing scope (everything except Daily / Task Note) is unchanged. The two operations remain orthogonal — archive is not modified to also move files, and discard does not subsume archive.

## Alternatives considered
- **Soft-trash to a `~/totes/.trash/` directory.** Adds a recoverable-by-hand path that does not require the user to know git. Rejected because autogit (ADR-0001) is already the recovery mechanism, and introducing a parallel one means two systems of record for "deleted" notes. Also adds a new top-level Vault location that would have to be documented and maintained alongside `inbox/`, `notes/`, `daily/`, `assets/`.
- **Tag-only "discard"** (mirror archive's mechanism, add a `discarded/` or `trash/` tag, no file move). Cheapest, most consistent with archive — but defeats the purpose. The user's stated need is to *not refer back to these notes*, and leaving them on disk with a different tag does not achieve that.
- **Extend archive to move files, drop discard.** Make `<leader>a` on an Inbox Note both retag *and* move to `notes/` (similar to how `<leader>p` retags and moves). Closes the "archive doesn't clear the inbox" gap with one change and avoids adding a new primitive. Rejected because it conflates two distinct user intents — "park this for posterity" and "this was rubbish" — into one operation. The user explicitly wanted a way to express "I truly don't want this," and archive-with-move would preserve every rejected note forever.
- **Make discard work on Permanent Notes too.** Symmetry with archive's scope. Rejected because the justification for discard ("if I truly don't want it I won't refer back to the archived copy") is specifically about un-vetted notes. A Permanent Note has, by definition, already passed a "is this worth keeping?" filter — discarding it later is a different action (more like "I changed my mind") that archive already serves adequately.

## Consequences
- The triage vocabulary becomes three-outcome: promote / archive / discard. Each maps to a distinct semantic and a distinct keybinding. `CONTEXT.md`'s Inbox Note glossary entry enumerates all three.
- Archive's existing behaviour is preserved. The "archive doesn't clear the inbox" property is now an explicit design choice rather than an oversight — archive is a *signal* (this note is inactive), not a *triage outcome*. Discard is the triage outcome for the "reject" case.
- Hard delete relies on autogit for recovery. The tool does not surface git history, so a user who wants to recover a discarded note has to use `git log` and `git restore` directly inside `~/totes/`. This is acceptable for a single-user power-tool but is the main cost of (a) over soft-trash.
- The Y/N confirmation defaults to `No` rather than `Yes` (archive defaults to `Yes`). The asymmetry is deliberate — archive is reversible (just edit the tag back), discard is not (without git knowledge).
- Permanent Notes, Daily Notes, and the Task Note are blocked from discard with a notice. The Permanent Note notice directs the user to `<leader>a` archive instead, mirroring the way `<leader>p` on a Daily Note directs the user to `<leader>n`.
