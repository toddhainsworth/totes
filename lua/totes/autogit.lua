local M = {}

function M.parse_title(content)
  if not content then return "untitled" end
  local fm = content:match("^%-%-%-\n(.-)%-%-%-")
  if not fm then return "untitled" end
  local raw
  for line in (fm .. "\n"):gmatch("([^\n]*)\n") do
    raw = line:match("^title:%s*'(.*)'%s*$")
    if raw then break end
  end
  if not raw or raw == "" then return "untitled" end
  return raw:gsub("''", "'")
end

function M.commit(filepath)
  local f = io.open(filepath, "r")
  if not f then return end
  local content = f:read("*a")
  f:close()

  local title = M.parse_title(content)
  local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
  local message = title .. ": " .. timestamp

  vim.system({ "git", "-C", vim.fn.fnamemodify(filepath, ":h"), "add", filepath }, {}, function(add)
    if add.code ~= 0 then return end
    vim.system({ "git", "-C", vim.fn.fnamemodify(filepath, ":h"), "commit", "-m", message }, {}, function() end)
  end)
end

function M.setup()
  local vault = vim.fn.expand("~/totes")
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vault .. "/**",
    callback = function()
      M.commit(vim.fn.expand("<afile>:p"))
    end,
  })
end

return M
