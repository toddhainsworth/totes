# ADR-0004: WikiLink canonical text is the kebab-case filename stem

## Status
Accepted

## Context
A WikiLink is written as `[[...]]` and resolves to a Note on disk. Two distinct strings exist for every Note: the human-readable `title` frontmatter field (e.g. "My Thoughts on Rust") and the kebab-case filename stem derived from it (`my-thoughts-on-rust`). The text the user types between the brackets could in principle be either, and the original `CONTEXT.md` definition ("case-insensitive filename match") was silent on which.

This ambiguity surfaced when designing autocomplete inside `[[...`: the completion source needs a canonical thing to insert, and `<leader>b` (backlinks) already greps the Vault for `[[<filename-stem>]]`, implicitly assuming the stem form. Two parts of the tool were silently disagreeing about what the canonical bracket contents look like.

## Decision
The canonical text inside `[[...]]` is the kebab-case filename stem (without `.md`), matching the on-disk filename exactly. Human-readable display in prose is handled via the existing alias syntax: `[[my-thoughts-on-rust|My Thoughts on Rust]]`.

The resolver continues to match case-insensitively against stems, so `[[My-Thoughts-On-Rust]]` still resolves, but the canonical written form is all-lowercase kebab-case.

## Alternatives considered
- **Human title as canonical** (`[[My Thoughts on Rust]]`): reads more naturally in prose, but the current resolver compares lowercased input against lowercased stems — spaces don't match dashes, so this would silently break resolution. Fixing it would require normalising spaces↔dashes in both directions, and `<leader>b`'s grep-based backlinks would have to be rewritten because grepping for `[[My Thoughts on Rust]]` would miss `[[my-thoughts-on-rust]]` and vice-versa.
- **Both forms accepted** (display title, normalise on resolve): most flexible UX, but doubles the surface area — backlinks, autocomplete, and `gf` all need to understand two equivalent forms. Adds permanent complexity to avoid one keystroke pattern.

## Consequences
- The autocomplete source inserts only the stem; aliases are a deliberate, user-typed concern and are never auto-generated.
- `<leader>b`'s grep-for-stem implementation is correct as-is and stays simple.
- The corpus of links in the Vault is uniform — a future tool (renames, refactors, vault-wide find-and-replace) operates on a single canonical form.
- Users typing prose pay a small ergonomic cost (`[[my-thoughts-on-rust]]` rather than `[[My Thoughts on Rust]]`), mitigated by autocomplete and the alias escape hatch.
- Reversing this decision later would require rewriting every WikiLink in every user's Vault, which is why this is captured as an ADR rather than left implicit.
