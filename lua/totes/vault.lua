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
  return vim.fs.find(function(name) return name:match("%.md$") end, {
    path = root,
    type = "file",
    limit = math.huge,
  })
end

--- Strip the Vault `root` prefix from an absolute path.
-- Tolerates a trailing slash on `root` so callers don't have to normalize.
function M.to_relative(root, absolute_path)
  local clean = root:gsub("/$", "")
  return absolute_path:sub(#clean + 2)
end

return M
