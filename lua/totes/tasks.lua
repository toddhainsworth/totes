local M = {}

local TASK_NOTE_REL = "notes/tasks.md"

function M.path()
  local vault = require("totes.vault")
  return vault.root .. "/" .. TASK_NOTE_REL
end

local function build_frontmatter()
  local note_factory = require("totes.note_factory")
  return note_factory.frontmatter("Tasks", {})
end

function M.is_task_note(filepath)
  return filepath == M.path()
end

function M.append(text)
  local path = M.path()

  local exists = io.open(path, "r")
  if not exists then
    local wf = io.open(path, "w")
    if not wf then
      return false, "cannot create " .. path
    end
    wf:write(build_frontmatter())
    wf:close()
  else
    exists:close()
  end

  local af = io.open(path, "a")
  if not af then
    return false, "cannot write to " .. path
  end
  af:write("- [ ] " .. text .. "\n")
  af:close()

  return true
end

function M.open()
  vim.cmd("edit " .. vim.fn.fnameescape(M.path()))
end

function M.add()
  local Input = require("nui.input")

  local input = Input({
    position = "50%",
    size = { width = 60 },
    border = {
      style = "rounded",
      text = { top = " New task ", top_align = "center" },
    },
  }, {
    prompt = "> ",
    default_value = "",
    on_submit = function(value)
      if not value or value == "" then return end
      local ok, err = M.append(value)
      if ok then
        vim.notify("totes: task added", vim.log.levels.INFO)
      else
        vim.notify("totes: could not save task — " .. (err or "unknown error"), vim.log.levels.ERROR)
      end
    end,
  })

  input:mount()
  input:map("n", "<Esc>", function() input:unmount() end, { noremap = true })
  input:map("i", "<Esc>", function() input:unmount() end, { noremap = true })
end

function M.setup()
  vim.keymap.set("n", "<leader>t", M.add, { desc = "Add a new task" })
  vim.keymap.set("n", "<leader>T", M.open, { desc = "Open task note" })
end

return M
