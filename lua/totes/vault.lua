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
end

M.root = vault

return M
