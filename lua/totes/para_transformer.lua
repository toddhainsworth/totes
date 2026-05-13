local M = {}

local ARCHIVE_PREFIX = "archive/"
local PARA_PREFIXES = { "project/", "area/", "resource/", ARCHIVE_PREFIX }

local function is_para_tag(tag)
  for _, prefix in ipairs(PARA_PREFIXES) do
    if tag:sub(1, #prefix) == prefix then
      return true
    end
  end
  return false
end

local function find_para_tag(tags)
  for _, tag in ipairs(tags) do
    if is_para_tag(tag) then
      return tag
    end
  end
  return nil
end

-- Already-archived tags are returned as-is to prevent double-archiving.
function M.transform(tags, filename_stem)
  local para_tag = find_para_tag(tags)

  if not para_tag then
    return "archive/" .. filename_stem
  end

  if para_tag:sub(1, #ARCHIVE_PREFIX) == ARCHIVE_PREFIX then
    return para_tag
  end

  return "archive/" .. para_tag
end

return M
