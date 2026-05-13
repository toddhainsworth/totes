local M = {}

local function extract_frontmatter(content)
  local fm = content:match("^%-%-%-\n(.-)%-%-%-")
  return fm
end

local function parse_yaml_tags(fm)
  local tags = {}
  local in_tags = false
  for line in fm:gmatch("[^\n]+") do
    if line:match("^tags:%s*$") then
      in_tags = true
    elseif in_tags then
      local tag = line:match("^%s+%-%s+(.+)")
      if tag then
        tags[#tags + 1] = tag:gsub("%s+$", "")
      else
        in_tags = false
      end
    end
  end
  return tags
end

function M.parse_tags(content)
  local fm = extract_frontmatter(content)
  if not fm then return {} end
  return parse_yaml_tags(fm)
end

local function prefix_matches(tag, prefix)
  if prefix == "" then return true end
  local bare = prefix:match("^(.*)/+$") or prefix
  return tag == bare or tag:sub(1, #bare + 1) == bare .. "/"
end

function M.notes_for_tag(vault_path, prefix)
  local results = {}
  local handle = io.popen(string.format("find %q -name '*.md' -type f", vault_path))
  if not handle then return results end
  for path in handle:lines() do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      for _, tag in ipairs(M.parse_tags(content)) do
        if prefix_matches(tag, prefix) then
          results[#results + 1] = path
          break
        end
      end
    end
  end
  handle:close()
  return results
end

function M.scan(vault_path)
  local tags_seen = {}
  local result = {}

  local handle = io.popen(string.format("find %q -name '*.md' -type f", vault_path))
  if not handle then return result end

  for path in handle:lines() do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      for _, tag in ipairs(M.parse_tags(content)) do
        if not tags_seen[tag] then
          tags_seen[tag] = true
          result[#result + 1] = tag
        end
      end
    end
  end
  handle:close()

  table.sort(result)
  return result
end

return M
