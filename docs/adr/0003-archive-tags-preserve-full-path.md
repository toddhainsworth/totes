# ADR-0003: Archive tags preserve the full original PARA path

## Status
Accepted

## Context
Archiving a note via `<leader>a` must update its PARA tag to signal it is inactive. A naive approach swaps the category prefix: `project/totes` → `archive/totes`. This creates collisions — `project/totes` and `area/totes` would both archive to `archive/totes`, making it impossible to distinguish their provenance.

## Decision
Archive tags embed the original full PARA tag under `archive/`: `project/totes` → `archive/project/totes`, `area/totes` → `archive/area/totes`. Tags become three-level for archived notes only; active PARA tags remain two-level.

## Alternatives considered
- **Swap category prefix** (`project/totes` → `archive/totes`): simple, but collisions are possible when two notes share an item name across different PARA categories.
- **Append flat `archive` tag** (keep `project/totes`, add `archive`): avoids collision but leaves conflicting PARA signals on one note.

## Consequences
- The tag prefix matcher must handle arbitrary depth (not just two levels), since `archive/project/*` is a valid filter.
- Provenance is fully preserved — you can always tell which PARA bucket a note came from before archiving.
- Notes without a PARA tag at archive time fall back to `archive/<filename-stem>`.
