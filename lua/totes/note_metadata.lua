local M = {}

local function strip_quotes(value)
  local first = value:sub(1, 1)
  local last = value:sub(-1)
  if (first == '"' and last == '"') or (first == "'" and last == "'") then
    return value:sub(2, -2)
  end
  return value
end

local function parse_title_line(line)
  -- Match `title:` followed by the rest of the line; preserves colons in the value.
  local raw = line:match("^title:%s*(.*)$")
  if not raw then
    return nil
  end
  raw = raw:gsub("%s+$", "")
  if raw == "" then
    return nil
  end
  return strip_quotes(raw)
end

--- Return the `title:` value from a Note's frontmatter, or nil.
-- Streams the file line-by-line; reads only the frontmatter block.
function M.read_title(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local first = file:read("*l")
  if first ~= "---" then
    file:close()
    return nil
  end

  local title
  local closed = false
  for line in file:lines() do
    if line == "---" then
      closed = true
      break
    end
    if not title then
      title = parse_title_line(line)
    end
  end
  file:close()

  if not closed then
    return nil
  end
  return title
end

return M
