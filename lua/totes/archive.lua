local M = {}

local PARA_PREFIXES = { "project/", "area/", "resource/" }

local function parse_tags(content)
  local fm = content:match("^%-%-%-\n(.-)%-%-%-\n")
  if not fm then return {} end

  local tags = {}
  local in_tags = false
  for line in (fm .. "\n"):gmatch("([^\n]*)\n") do
    if line:match("^tags:%s*$") then
      in_tags = true
    elseif in_tags then
      local tag = line:match("^  %- (.+)$")
      if tag then
        tags[#tags + 1] = tag
      else
        in_tags = false
      end
    end
  end
  return tags
end

local function is_para_tag(tag)
  for _, prefix in ipairs(PARA_PREFIXES) do
    if tag:sub(1, #prefix) == prefix then return true end
  end
  return false
end

function M.write_archive_tag(content, archive_tag)
  local fm, rest = content:match("^(%-%-%-\n.-)%-%-%-\n(.*)$")
  if not fm then return content end

  if fm:find("  - " .. archive_tag, 1, true) then
    return content
  end

  -- Replace existing PARA tag line within frontmatter
  local new_fm, count = fm:gsub("(  %- )([^\n]+)", function(prefix, tag)
    if is_para_tag(tag) then
      return prefix .. archive_tag
    end
    return prefix .. tag
  end)

  if count > 0 and new_fm ~= fm then
    return "---\n" .. new_fm .. "---\n" .. rest
  end

  -- No PARA tag found: fall back to adding archive_tag
  -- Handle empty inline list form
  local added_fm, n = fm:gsub("tags: %[%]", "tags:\n  - " .. archive_tag)
  if n > 0 then
    return "---\n" .. added_fm .. "---\n" .. rest
  end

  -- Block sequence: insert after the last tag item
  local lines = {}
  for line in (fm .. "\n"):gmatch("([^\n]*)\n") do
    lines[#lines + 1] = line
  end
  local in_tags, last_tag_idx = false, nil
  for i, line in ipairs(lines) do
    if line:match("^tags:%s*$") then
      in_tags = true
    elseif in_tags then
      if line:match("^  %- ") then
        last_tag_idx = i
      else
        in_tags = false
      end
    end
  end
  if last_tag_idx then
    table.insert(lines, last_tag_idx + 1, "  - " .. archive_tag)
    return "---\n" .. table.concat(lines, "\n") .. "---\n" .. rest
  end

  return content
end

function M.archive()
  local promotion = require("totes.promotion")
  local para_transformer = require("totes.para_transformer")
  local Menu = require("nui.menu")
  local event = require("nui.utils.autocmd").event

  local filepath = vim.fn.expand("%:p")

  if filepath == "" then
    vim.notify("totes: no file associated with this buffer", vim.log.levels.WARN)
    return
  end

  if promotion.is_daily(filepath) then
    vim.notify("Daily Notes cannot be archived.", vim.log.levels.INFO)
    return
  end

  local f = io.open(filepath, "r")
  if not f then
    vim.notify("totes: cannot read " .. filepath, vim.log.levels.ERROR)
    return
  end
  local content = f:read("*a")
  f:close()

  local tags = parse_tags(content)
  local filename_stem = vim.fn.fnamemodify(filepath, ":t:r")
  local archive_tag = para_transformer.transform(tags, filename_stem)

  local menu = Menu({
    position = "50%",
    size = { width = 40, height = 4 },
    border = {
      style = "rounded",
      text = { top = " Archive note? ", top_align = "center" },
    },
  }, {
    lines = {
      Menu.item("Yes"),
      Menu.item("No"),
    },
    max_width = 20,
    keymap = {
      focus_next = { "j", "<Down>" },
      focus_prev = { "k", "<Up>" },
      close = { "<Esc>", "q" },
      submit = { "<CR>" },
    },
    on_submit = function(item)
      if item.text ~= "Yes" then return end
      local updated = M.write_archive_tag(content, archive_tag)
      if updated == content then
        vim.notify("totes: could not update frontmatter", vim.log.levels.ERROR)
        return
      end
      local wf = io.open(filepath, "w")
      if not wf then
        vim.notify("totes: could not write " .. filepath, vim.log.levels.ERROR)
        return
      end
      wf:write(updated)
      wf:close()
      vim.cmd("edit!")
      vim.notify("totes: archived → " .. archive_tag, vim.log.levels.INFO)
    end,
  })

  menu:mount()
  menu:on(event.BufLeave, function() menu:unmount() end)
end

function M.setup()
  vim.keymap.set("n", "<leader>a", M.archive, { desc = "Archive current note" })
end

return M
