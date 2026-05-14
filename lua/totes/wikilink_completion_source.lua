local completion = require("totes.wikilink_completion")
local vault = require("totes.vault")

--- blink.cmp custom source: WikiLink stem autocomplete inside `[[...`.
-- Vault is rescanned per invocation (no cache) to stay in sync with disk.
local Source = {}
Source.__index = Source

function Source.new() return setmetatable({}, Source) end

function Source:enabled() return vim.bo.filetype == "markdown" end

function Source:get_trigger_characters() return { "[" } end

local function to_items(candidates)
  local items = {}
  for _, c in ipairs(candidates) do
    items[#items + 1] = {
      label = c.stem,
      insertText = c.stem,
      kind = vim.lsp.protocol.CompletionItemKind.File,
    }
  end
  return items
end

function Source:get_completions(ctx, callback)
  local line = ctx.line or vim.api.nvim_get_current_line()
  local col = ctx.cursor and ctx.cursor[2] or vim.api.nvim_win_get_cursor(0)[2]
  if not completion.should_trigger(line, col) then
    callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = {} })
    return
  end
  local items = to_items(completion.candidates(vault.root))
  callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = items })
end

-- blink.cmp loads the source by requiring this module and calling `.new()`.
return Source
