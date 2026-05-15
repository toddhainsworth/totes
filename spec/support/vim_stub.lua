-- Side-effect module: installs a minimal `vim` global so specs can require
-- modules that touch `vim.fn` at load time (e.g. `totes.vault`).
_G.vim = _G.vim or {}
_G.vim.fn = _G.vim.fn or { expand = function(p) return p end }

return true
