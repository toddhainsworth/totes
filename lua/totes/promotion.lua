local M = {}

local PROMPT = "tag: "

function M.is_daily(filepath)
  return filepath:find("/daily/", 1, true) ~= nil
end

-- Returns content with tag appended to the frontmatter tags field.
-- If tag is nil or empty, returns content unchanged.
-- Handles both `tags: []` (empty list) and existing block sequence forms.
-- Only applies changes within the frontmatter block to avoid false matches in the body.
function M.update_frontmatter_tag(content, tag)
  if not tag or tag == "" then return content end

  local fm, rest = content:match("^(%-%-%-\n.-)%-%-%-\n(.*)$")
  if not fm then return content end

  -- Try replacing empty inline list form within frontmatter
  local new_fm, count = fm:gsub("tags: %[%]", "tags:\n  - " .. tag)
  if count > 0 then
    return "---\n" .. new_fm .. "---\n" .. rest
  end

  -- Block sequence form: find last tag item and insert after it
  local lines = {}
  for line in (fm .. "\n"):gmatch("([^\n]*)\n") do
    lines[#lines + 1] = line
  end
  local in_tags = false
  local last_tag_idx = nil
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
    table.insert(lines, last_tag_idx + 1, "  - " .. tag)
    return "---\n" .. table.concat(lines, "\n") .. "---\n" .. rest
  end

  return content
end

local function find_top_match(tags, value)
  if value == "" then return nil end
  for _, tag in ipairs(tags) do
    if tag:sub(1, #value) == value and tag ~= value then
      return tag
    end
  end
  return nil
end

local function move_file(src, dest)
  local ok = os.rename(src, dest)
  if not ok then
    -- os.rename fails across devices; fall back to copy+delete
    local src_f = io.open(src, "rb")
    if not src_f then return false, "cannot open source" end
    local data = src_f:read("*a")
    src_f:close()
    local dest_f = io.open(dest, "wb")
    if not dest_f then return false, "cannot open destination" end
    dest_f:write(data)
    dest_f:close()
    os.remove(src)
  end
  return true
end

local function perform_promotion(filepath, dest, tag)
  if tag and tag ~= "" then
    local f = io.open(filepath, "r")
    if f then
      local content = f:read("*a")
      f:close()
      local updated = M.update_frontmatter_tag(content, tag)
      local wf = io.open(filepath, "w")
      if not wf then
        vim.notify("totes: could not write updated frontmatter", vim.log.levels.ERROR)
        return
      end
      wf:write(updated)
      wf:close()
    end
  end

  local ok, err = move_file(filepath, dest)
  if not ok then
    vim.notify("totes: promotion failed — " .. (err or "unknown error"), vim.log.levels.ERROR)
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(dest))
  vim.notify("totes: promoted to " .. dest, vim.log.levels.INFO)
end

function M.promote()
  local filepath = vim.fn.expand("%:p")

  if M.is_daily(filepath) then
    vim.notify(
      "Daily Notes cannot be promoted. Use \\n to create a new note.",
      vim.log.levels.INFO
    )
    return
  end

  local tasks = require("totes.tasks")
  if tasks.is_task_note(filepath) then
    vim.notify("Task Note cannot be promoted.", vim.log.levels.INFO)
    return
  end

  local vault = require("totes.vault")
  local tag_scanner = require("totes.tag_scanner")
  local Input = require("nui.input")

  local filename = vim.fn.fnamemodify(filepath, ":t")
  local dest = vault.root .. "/notes/" .. filename
  local tags = tag_scanner.scan(vault.root)

  local current_value = ""

  local input = Input({
    position = "50%",
    size = { width = 60 },
    border = {
      style = "rounded",
      text = { top = " Add tag (Enter to skip) ", top_align = "center" },
    },
  }, {
    prompt = PROMPT,
    default_value = "",
    on_change = function(value)
      current_value = value
    end,
    on_submit = function(value)
      perform_promotion(filepath, dest, value)
    end,
  })

  input:mount()

  input:map("n", "<Esc>", function() input:unmount() end, { noremap = true })
  input:map("i", "<Esc>", function() input:unmount() end, { noremap = true })

  input:map("i", "<Tab>", function()
    local match = find_top_match(tags, current_value)
    if not match then return end
    -- Replace the input line content after the prompt
    local buf = input.bufnr
    local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    local prompt_len = #PROMPT
    local prefix = line:sub(1, prompt_len)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, { prefix .. match })
    vim.api.nvim_win_set_cursor(0, { 1, #prefix + #match })
    current_value = match
  end, { noremap = true })
end

function M.setup()
  vim.keymap.set("n", "<leader>p", M.promote, { desc = "Promote inbox note to notes/" })
end

return M
