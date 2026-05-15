-- Side-effect module: installs a minimal `vim` global so specs can require
-- modules that touch `vim.fn` at load time (e.g. `totes.vault`).
_G.vim = _G.vim or {}
_G.vim.fn = _G.vim.fn or { expand = function(p) return p end }

-- Stand-in for `vim.fs.find` good enough for spec consumers: walks the real
-- filesystem so existing fs-based specs still exercise real I/O. Single-quote
-- the path so metacharacters round-trip into the child shell unmolested.
_G.vim.fs = _G.vim.fs
  or {
    find = function(predicate, opts)
      local quoted = "'" .. opts.path:gsub("'", "'\\''") .. "'"
      local handle = io.popen("find " .. quoted .. " -type f 2>/dev/null")
      if not handle then
        return {}
      end
      local results = {}
      for path in handle:lines() do
        local name = path:match("([^/]+)$")
        if predicate(name) then
          results[#results + 1] = path
        end
      end
      handle:close()
      return results
    end,
  }

return true
