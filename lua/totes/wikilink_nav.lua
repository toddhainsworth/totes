local M = {}

local resolver = require("totes.wikilink_resolver")
local vault = require("totes.vault")

--- Find the WikiLink [[...]] text that contains column `col` (1-based) in `line`.
-- @param line string  The full line of text.
-- @param col  number  1-based cursor column.
-- @return string|nil  The matched "[[...]]" text, or nil.
function M.wikilink_at_cursor(line, col)
  local init = 1
  while true do
    local s, e = line:find("%[%[.-%]%]", init)
    if not s then
      return nil
    end
    if col >= s and col <= e then
      return line:sub(s, e)
    end
    init = e + 1
  end
end

local function collect_vault_files()
  local handle = io.popen(string.format("find %q -name '*.md' -type f 2>/dev/null", vault.root))
  if not handle then
    return {}
  end
  local files = {}
  for line in handle:lines() do
    local rel = line:sub(#vault.root + 2)
    files[#files + 1] = rel
  end
  handle:close()
  return files
end

local function open_telescope_picker(candidates)
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("totes: Telescope not available for multiple matches", vim.log.levels.WARN)
    return
  end
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers
    .new({}, {
      prompt_title = "WikiLink matches",
      finder = finders.new_table({ results = candidates }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(buf, map)
        actions.select_default:replace(function()
          actions.close(buf)
          local sel = action_state.get_selected_entry()
          if sel then
            vim.cmd("edit " .. vim.fn.fnameescape(vault.root .. "/" .. sel.value))
          end
        end)
        return true
      end,
    })
    :find()
end

local function strip_wikilink(link)
  local s = link:gsub("^%[%[", ""):gsub("%]%]$", "")
  return s:match("^(.-)%|") or s
end

local function offer_create(link)
  vim.ui.select({ "Create note", "Cancel" }, { prompt = "No note found for '" .. link .. "'" }, function(choice)
    if choice == "Create note" then
      require("totes.notes").create_inbox_note(strip_wikilink(link))
    end
  end)
end

--- Follow the WikiLink under the cursor, or fall back to default gf.
function M.follow()
  local line = vim.api.nvim_get_current_line()
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- nvim_win_get_cursor returns 0-based col; wikilink_at_cursor expects 1-based.
  local link = M.wikilink_at_cursor(line, col + 1)

  if not link then
    vim.cmd("normal! gf")
    return
  end

  local files = collect_vault_files()
  local result = resolver.resolve(link, files)

  if result.kind == "one" then
    vim.cmd("edit " .. vim.fn.fnameescape(vault.root .. "/" .. result.path))
  elseif result.kind == "many" then
    open_telescope_picker(result.candidates)
  else
    offer_create(link)
  end
end

--- Register the gf keymap for markdown buffers.
function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function() vim.keymap.set("n", "gf", M.follow, { buffer = true, desc = "Follow WikiLink" }) end,
  })
end

return M
