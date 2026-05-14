local M = {}

math.randomseed(os.time())

local taglines = {
  "Notes, by Todd",
  "Lemme write that down",
  "Yet another note tool?",
}

local logo = {
  " _____ _____ _____ _____ _____ ",
  "|_   _|  _  |_   _|  ___/  ___|",
  "  | | | | | | | | | |__ \\ `--. ",
  "  | | | | | | | | |  __| `--. \\",
  "  | | \\ \\_/ / | | | |___/\\__/ /",
  "  \\_/  \\___/  \\_/ \\____/\\____/ ",
}

function M.count_inbox_notes(inbox_path)
  local handle = io.popen(string.format("find %q -maxdepth 1 -name '*.md' -type f", inbox_path))
  if not handle then
    return 0
  end

  local count = 0
  for _ in handle:lines() do
    count = count + 1
  end
  handle:close()

  return count
end

function M.count_open_tasks(task_note_path)
  local f = io.open(task_note_path, "r")
  if not f then
    return 0
  end

  local count = 0
  for line in f:lines() do
    if line:match("^%s*%- %[ %]") then
      count = count + 1
    end
  end
  f:close()

  return count
end

local function random_tagline() return taglines[math.random(#taglines)] end

local function build_config(inbox_count, task_count)
  local tagline = random_tagline()
  local inbox_label = string.format("  %d unprocessed in inbox", inbox_count)
  local task_label = string.format("  %d open task%s", task_count, task_count == 1 and "" or "s")

  return {
    layout = {
      { type = "padding", val = 4 },
      { type = "text", val = logo, opts = { hl = "Type", position = "center" } },
      { type = "padding", val = 1 },
      { type = "text", val = tagline, opts = { hl = "Comment", position = "center" } },
      { type = "padding", val = 1 },
      { type = "text", val = { inbox_label }, opts = { hl = "WarningMsg", position = "center" } },
      { type = "text", val = { task_label }, opts = { hl = "WarningMsg", position = "center" } },
      { type = "padding", val = 4 },
    },
  }
end

function M.setup()
  local vault = require("totes.vault")
  local inbox_count = M.count_inbox_notes(vault.root .. "/inbox")
  local task_count = M.count_open_tasks(require("totes.tasks").path())

  local alpha = require("alpha")
  alpha.setup(build_config(inbox_count, task_count))
end

return M
