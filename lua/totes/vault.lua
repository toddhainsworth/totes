local M = {}

local vault = vim.fn.expand("~/totes")

local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end
end

function M.init()
  ensure_dir(vault)

  for _, dir in ipairs({ "inbox", "notes", "daily", "assets" }) do
    ensure_dir(vault .. "/" .. dir)
  end

  if vim.fn.isdirectory(vault .. "/.git") == 0 then
    vim.fn.system({ "git", "-C", vault, "init" })
  end

  vim.fn.chdir(vault)
end

M.root = vault

--- List every `*.md` file under `root`, returning absolute paths.
-- Unfiltered: callers apply Daily exclusion / other policy on top.
function M.scan_markdown(root)
  local handle = io.popen(string.format("find %q -name '*.md' -type f 2>/dev/null", root))
  if not handle then
    return {}
  end
  local files = {}
  for path in handle:lines() do
    files[#files + 1] = path
  end
  handle:close()
  return files
end

return M
