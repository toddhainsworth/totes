local M = {}
local note_factory = require("totes.note_factory")
local vault = require("totes.vault")

function M.create_inbox_note()
  vim.ui.input({ prompt = "Note title: " }, function(title)
    if not title or title == "" then return end

    local note = note_factory.create(title, {})

    if note.filename == ".md" then
      vim.notify("totes: title produces an empty filename", vim.log.levels.WARN)
      return
    end

    local inbox = vault.root .. "/inbox/"
    local filepath = inbox .. note.filename

    local file = io.open(filepath, "w")
    if not file then
      vim.notify("totes: could not create " .. filepath, vim.log.levels.ERROR)
      return
    end
    file:write(note.frontmatter)
    file:close()

    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  end)
end

function M.setup()
  vim.keymap.set("n", "<leader>n", M.create_inbox_note, { desc = "New inbox note" })
end

return M
