local M = {}

-- Normalize a WikiLink string: strip [[ ]] brackets, alias, and lowercase.
local function normalize(link)
  local s = link:gsub("^%[%[", ""):gsub("%]%]$", "")
  s = s:match("^(.-)%|") or s
  return s:lower()
end

-- Extract the stem (filename without extension and leading path).
local function stem(filename)
  return (filename:match("([^/\\]+)%.md$") or filename:match("([^/\\]+)$") or filename):lower()
end

--- Resolve a WikiLink string against a flat list of Vault filenames.
--
-- @param link     string   WikiLink text, e.g. "My Note" or "[[My Note|Alias]]"
-- @param filenames table    List of relative Vault paths, e.g. {"projects/foo.md", "daily/2026-05-13.md"}
-- @return table  { kind = "zero"|"one"|"many", path = string|nil, candidates = table|nil }
function M.resolve(link, filenames)
  local target = normalize(link)
  local matches = {}
  for _, f in ipairs(filenames or {}) do
    if stem(f) == target then
      matches[#matches + 1] = f
    end
  end

  if #matches == 0 then
    return { kind = "zero" }
  elseif #matches == 1 then
    return { kind = "one", path = matches[1] }
  else
    return { kind = "many", candidates = matches }
  end
end

return M
