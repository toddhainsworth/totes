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

return M
