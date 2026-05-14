local M = {}

local vault = require("totes.vault")
local note_factory = require("totes.note_factory")

function M.today_date() return os.date("%Y-%m-%d") end

function M.open()
  local date = M.today_date()
  local daily_path = vault.root .. "/daily/" .. date .. ".md"

  local existing = io.open(daily_path, "r")
  if existing then
    existing:close()
    vim.cmd("edit " .. vim.fn.fnameescape(daily_path))
    return
  end

  vim.fn.mkdir(vault.root .. "/daily", "p")
  local file = io.open(daily_path, "w")
  if not file then
    vim.notify("totes: could not create " .. daily_path, vim.log.levels.ERROR)
    return
  end
  file:write(note_factory.frontmatter(date, { "daily" }) .. "# " .. date .. "\n")
  file:close()
  vim.cmd("edit " .. vim.fn.fnameescape(daily_path))
end

function M.setup() vim.keymap.set("n", "<leader>d", M.open, { desc = "Open daily note" }) end

return M
