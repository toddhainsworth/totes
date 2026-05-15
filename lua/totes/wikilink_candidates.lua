local note_metadata = require("totes.note_metadata")
local vault = require("totes.vault")

local M = {}

local function is_under_daily(rel_path) return rel_path:sub(1, 6) == "daily/" end

local function stem(rel_path) return (rel_path:match("([^/]+)%.md$")) end

--- Collect WikiLink completion candidates for the Vault at `vault_root`.
-- Excludes Notes under `daily/`. Each record carries the kebab-case stem,
-- the frontmatter title (or nil), and the absolute file path.
function M.collect(vault_root)
  local results = {}
  local prefix_len = #vault_root + 2
  for _, path in ipairs(vault.scan_markdown(vault_root)) do
    local rel = path:sub(prefix_len)
    if not is_under_daily(rel) then
      local s = stem(rel)
      if s then
        results[#results + 1] = {
          stem = s,
          title = note_metadata.read_title(path),
          path = path,
        }
      end
    end
  end
  return results
end

return M
