local M = {}

local function add_nav_mappings(map)
  local actions = require("telescope.actions")
  map("i", "<C-j>", actions.move_selection_next)
  map("i", "<C-k>", actions.move_selection_previous)
end

function M.tag_matches(tag, prefix)
  if prefix == "" then
    return true
  end
  local bare = prefix:match("^(.*)/+$") or prefix
  return tag == bare or tag:sub(1, #bare + 1) == bare .. "/"
end

function M.find_notes()
  local vault = require("totes.vault")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local handle = io.popen(string.format("find %q -name '*.md' -type f", vault.root))
  if not handle then
    return
  end
  local entries = {}
  for path in handle:lines() do
    local f = io.open(path, "r")
    local title = ""
    if f then
      local content = f:read("*a")
      f:close()
      title = content:match("^%-%-%-\n.-title:%s*'(.-)'") or ""
    end
    local filename = vim.fn.fnamemodify(path, ":t")
    entries[#entries + 1] = {
      display = filename .. "  |  " .. title,
      path = path,
      ordinal = filename .. " " .. title,
    }
  end
  handle:close()

  pickers
    .new({}, {
      prompt_title = "Find Notes",
      finder = finders.new_table({
        results = entries,
        entry_maker = function(e) return e end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(buf, map)
        add_nav_mappings(map)
        actions.select_default:replace(function()
          actions.close(buf)
          local sel = action_state.get_selected_entry()
          if sel then
            vim.cmd("edit " .. vim.fn.fnameescape(sel.path))
          end
        end)
        return true
      end,
    })
    :find()
end

function M.open_notes_for_tag(prefix)
  local vault = require("totes.vault")
  local tag_scanner = require("totes.tag_scanner")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local matching = tag_scanner.notes_for_tag(vault.root, prefix)
  pickers
    .new({}, {
      prompt_title = "Notes tagged: " .. prefix,
      finder = finders.new_table({ results = matching }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(_, map)
        add_nav_mappings(map)
        return true
      end,
    })
    :find()
end

function M.filter_by_tag()
  local vault = require("totes.vault")
  local tag_scanner = require("totes.tag_scanner")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local tags = tag_scanner.scan(vault.root)

  pickers
    .new({}, {
      prompt_title = "Filter by Tag",
      finder = finders.new_table({ results = tags }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(buf, map)
        add_nav_mappings(map)
        actions.select_default:replace(function()
          actions.close(buf)
          local selected = action_state.get_selected_entry()
          if not selected then
            return
          end
          M.open_notes_for_tag(selected.value)
        end)
        return true
      end,
    })
    :find()
end

function M.backlinks()
  local vault = require("totes.vault")
  local stem = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
  require("telescope.builtin").grep_string({
    search = "[[" .. stem .. "]]",
    cwd = vault.root,
    use_regex = false,
    attach_mappings = function(_, map)
      add_nav_mappings(map)
      return true
    end,
  })
end

function M.setup()
  vim.keymap.set("n", "<leader>ff", M.find_notes, { desc = "Find notes" })
  vim.keymap.set("n", "<leader>ft", M.filter_by_tag, { desc = "Filter by tag" })
  vim.keymap.set("n", "<leader>b", M.backlinks, { desc = "Backlinks" })
end

return M
