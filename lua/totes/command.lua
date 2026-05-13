local M = {}

local totes_tool = vim and vim.fn and vim.fn.expand("~/.local/share/totes")
  or (os.getenv("HOME") .. "/.local/share/totes")

local function parse_version(tag)
  local s = tag:gsub("^v", "")
  local major, minor, patch = s:match("^(%d+)%.(%d+)%.(%d+)$")
  if not major then return nil end
  return { tonumber(major), tonumber(minor), tonumber(patch) }
end

function M.is_newer(current, latest)
  local cv = parse_version(current)
  local lv = parse_version(latest)
  if not cv or not lv then return false end
  for i = 1, 3 do
    if lv[i] > cv[i] then return true end
    if lv[i] < cv[i] then return false end
  end
  return false
end

local function read_changelog()
  local path = totes_tool .. "/CHANGELOG.md"
  local f = io.open(path, "r")
  if not f then return { "No changelog available." } end
  local lines = {}
  for line in f:lines() do
    lines[#lines + 1] = line
  end
  f:close()
  return lines
end

function M.show_changelog()
  local Popup = require("nui.popup")
  local lines = read_changelog()

  local popup = Popup({
    position = "50%",
    size = { width = 80, height = 30 },
    border = { style = "rounded", text = { top = " Changelog ", top_align = "center" } },
    buf_options = { modifiable = true },
  })

  popup:mount()
  vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", false)
  popup:map("n", "q", function() popup:unmount() end, { noremap = true })
  popup:map("n", "<Esc>", function() popup:unmount() end, { noremap = true })
end

local function git(args)
  local cmd = string.format("git -C %q %s 2>&1", totes_tool, args)
  local handle = io.popen(cmd)
  if not handle then return nil end
  local out = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  return out
end

local function latest_tag()
  local out = git("tag --sort=-version:refname")
  if not out or out == "" then return nil end
  return out:match("^([^\n]+)")
end

local function current_tag()
  local out = git("describe --tags --abbrev=0")
  if not out or out:match("^fatal:") then return nil end
  return out
end

function M.update()
  local fetch_out = git("fetch --tags")
  if fetch_out and (fetch_out:match("^fatal:") or fetch_out:match("^error:")) then
    vim.notify("totes: fetch failed — " .. fetch_out, vim.log.levels.WARN)
    return
  end

  local current = current_tag()
  local latest = latest_tag()

  if not latest then
    vim.notify("totes: no tags found in remote", vim.log.levels.WARN)
    return
  end

  if not current or M.is_newer(current, latest) then
    vim.fn.system({ "git", "-C", totes_tool, "checkout", latest })
    vim.notify(
      string.format("totes: updated to %s — please restart NeoVim", latest),
      vim.log.levels.INFO
    )
  else
    vim.notify("totes: already up to date (" .. (current or "unknown") .. ")", vim.log.levels.INFO)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("Totes", function(opts)
    local arg = opts.args:match("^%s*(.-)%s*$")
    if arg == "" or arg == "changelog" then
      M.show_changelog()
    elseif arg == "update" then
      M.update()
    else
      vim.notify("totes: unknown subcommand '" .. arg .. "'", vim.log.levels.ERROR)
    end
  end, {
    nargs = "?",
    complete = function()
      return { "changelog", "update" }
    end,
    desc = "Totes: changelog | update",
  })
end

return M
