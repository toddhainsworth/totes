# ADR-0005: Prompt mechanism is chosen by input shape

## Status
Accepted

## Context
The tool has five distinct prompt sites — new note title, task text, promote-with-tag, archive confirmation, and broken-link "create or cancel" — and they had grown inconsistent. Two plain-text prompts disagreed (`<leader>n` used `vim.ui.input`, `<leader>t` used `nui.input`), and two yes/no-shaped prompts disagreed (`<leader>a` used `nui.menu`, the `gf`-create offer used `vim.ui.select`).

The repo is a single-user notes tool used daily; perceived cohesion of the UX matters more than internal cleanliness. A "make everything the same" instinct ran into the fact that `<leader>p` already does more than plain text — it provides live Tab-autocomplete against existing vault tags via an `nui.input` keymap, and that affordance is documented behaviour we did not want to drop.

## Decision
The prompt mechanism is determined by the **shape of the input being requested**, not by uniformity:

- **Plain text input** → `vim.ui.input` (command line).
- **Rich text input** — anything that needs in-prompt affordances such as autocomplete or live hints → `nui.input` popup.
- **Discrete choice** — every multi-option prompt, including binary yes/no → `nui.menu` popup.

The command line is the "type and move on" surface; the popup is the "answer this discrete question" surface. The split exists because the popup is the only surface that can host non-trivial in-prompt interaction, and once you accept that, you may as well let it own all discrete choices too — otherwise the popup becomes "only the consequential ones," which is a fuzzy line that drifts as features are added.

Concretely under this rule:
- `<leader>n` (new note title) — `vim.ui.input` ✓
- `<leader>t` (task text) — switches from `nui.input` to `vim.ui.input`
- `<leader>p` (promote with tag) — `nui.input` ✓ (Tab autocomplete justifies the popup)
- `<leader>a` (archive yes/no) — `nui.menu` ✓
- `gf`-create offer — switches from `vim.ui.select` to `nui.menu`

## Alternatives considered
- **One mechanism for all text inputs (drop `<leader>p` autocomplete).** Cleanest rule but regresses a documented affordance and removes a feature that demonstrably helps consistency of tagging across the vault. Trades real user value for code aesthetics.
- **One mechanism for all text inputs via `vim.fn.input` + `customlist`.** Preserves promote's autocomplete in the cmdline. Rejected because the cmdline feels like a "quick aside" surface; tagging on promotion is a deliberate, attention-worthy step and the popup matches that weight. Also the `customlist` API is older and Tab-completion in cmdline mode behaves differently from popup-driven completion.
- **Consequential-only popups (yes/no stays mixed).** Would let `gf`-create stay in `vim.ui.select`. Rejected because "consequential" is a moving target — what looks cheap today gains weight as flows compose, and we'd re-litigate the line every time a new prompt is added.

## Consequences
- The rule is mechanical: future prompts pick their surface from the input shape, not from "which mechanism feels nicer."
- `<leader>t` and the `gf`-create offer require small implementation changes; behaviour from the user's perspective stays equivalent (text-in or 2-choice).
- The popup load increases slightly — `gf` on a broken link now opens a small menu rather than a cmdline prompt. This is intentional: it matches the "you've left flow because the link was broken" moment.
- `nui.nvim` remains a load-bearing dependency; this ADR commits to that rather than treating nui as something to minimise.
- `CONTEXT.md` keybinding descriptions are kept behavioural ("prompts for X", "asks for confirmation"); mechanism choice lives in this ADR so the glossary does not encode implementation details.
