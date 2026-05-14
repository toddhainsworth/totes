local M = {}

--- Decide whether completion should fire at `col` (0-based) on `line`.
-- True iff cursor sits between an opening `[[` and the next `|` or `]]`.
function M.should_trigger(line, col)
  local before = line:sub(1, col)
  local open = before:find("%[%[[^%[]*$")
  if not open then
    return false
  end
  local segment = before:sub(open + 2)
  if segment:find("|", 1, true) or segment:find("]]", 1, true) then
    return false
  end
  return true
end

local function is_under_daily(rel_path) return rel_path:sub(1, 6) == "daily/" end

local function stem(rel_path) return (rel_path:match("([^/]+)%.md$")) end

--- Scan the Vault and return WikiLink completion candidates.
-- Excludes Notes under `daily/`. Returns `{ { stem = "..." }, ... }`.
function M.candidates(vault_root)
  local results = {}
  local handle = io.popen(string.format("find %q -name '*.md' -type f 2>/dev/null", vault_root))
  if not handle then
    return results
  end
  local prefix_len = #vault_root + 2
  for path in handle:lines() do
    local rel = path:sub(prefix_len)
    if not is_under_daily(rel) then
      local s = stem(rel)
      if s then
        results[#results + 1] = { stem = s }
      end
    end
  end
  handle:close()
  return results
end

return M
