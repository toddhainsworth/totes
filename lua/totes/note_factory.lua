local M = {}

function M.slugify(title)
  local s = title or ""
  s = s:lower()
  s = s:gsub("[^a-zA-Z0-9%s]", " ")  -- replace non-alphanumeric (ASCII) with space
  s = s:gsub("%s+", "-")         -- collapse whitespace runs to a single hyphen
  s = s:gsub("^%-+", ""):gsub("%-+$", "")  -- trim leading/trailing hyphens
  return s
end

function M.timestamp()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

function M.frontmatter(title, tags)
  local tag_lines
  if not tags or #tags == 0 then
    tag_lines = "tags: []"
  else
    local items = {}
    for _, t in ipairs(tags) do
      items[#items + 1] = "  - " .. t
    end
    tag_lines = "tags:\n" .. table.concat(items, "\n")
  end

  return table.concat({
    "---",
    "title: '" .. (title or ""):gsub("'", "''") .. "'",
    tag_lines,
    "created: " .. M.timestamp(),
    "---",
    "",
  }, "\n")
end

function M.create(title, tags)
  return {
    filename = M.slugify(title) .. ".md",
    frontmatter = M.frontmatter(title, tags),
  }
end

return M
