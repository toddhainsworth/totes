local M = {}

math.randomseed(os.time())

local taglines = {
  "Notes, by Todd",
  "Lemme write that down",
  "Yet another note tool?",
}

local logo = {
  "  __        __       ",
  " / /__  ___/ /____   ",
  "/ __/ |/ / _  / -_)  ",
  "\\__/|___/\\_,_/\\__/   ",
}

function M.count_inbox_notes(inbox_path)
  local handle = io.popen(
    string.format("find %q -maxdepth 1 -name '*.md' -type f", inbox_path)
  )
  if not handle then return 0 end

  local count = 0
  for _ in handle:lines() do
    count = count + 1
  end
  handle:close()

  return count
end

local function random_tagline()
  return taglines[math.random(#taglines)]
end

local function build_config(inbox_count)
  local tagline = random_tagline()
  local count_label = string.format("  %d unprocessed in inbox", inbox_count)

  return {
    layout = {
      { type = "padding", val = 4 },
      { type = "text", val = logo, opts = { hl = "Type", position = "center" } },
      { type = "padding", val = 1 },
      { type = "text", val = tagline, opts = { hl = "Comment", position = "center" } },
      { type = "padding", val = 1 },
      { type = "text", val = { count_label }, opts = { hl = "WarningMsg", position = "center" } },
      { type = "padding", val = 4 },
    },
  }
end

function M.setup()
  local vault = vim.fn.expand("~/totes")
  local inbox_path = vault .. "/inbox"
  local count = M.count_inbox_notes(inbox_path)

  local alpha = require("alpha")
  alpha.setup(build_config(count))
end

return M
