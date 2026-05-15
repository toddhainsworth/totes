-- Stub vim before loading vault, as it calls vim.fn at load time.
_G.vim = _G.vim or {}
_G.vim.fn = _G.vim.fn or { expand = function(p) return p end }

local vault = require("totes.vault")

local function tmpdir()
  local path = os.tmpname()
  os.remove(path)
  os.execute('mkdir -p "' .. path .. '"')
  return path
end

local function rmdir(path) os.execute('rm -rf "' .. path .. '"') end

local function write_file(dir, rel, content)
  local full = dir .. "/" .. rel
  os.execute('mkdir -p "' .. full:match("(.*)/") .. '"')
  local f = io.open(full, "w")
  f:write(content or "")
  f:close()
end

describe("vault.scan_markdown", function()
  local dir

  before_each(function() dir = tmpdir() end)

  after_each(function() rmdir(dir) end)

  it("returns an empty list for an empty Vault", function() assert.same({}, vault.scan_markdown(dir)) end)

  it("returns the absolute path of a Note in inbox/", function()
    write_file(dir, "inbox/foo.md", "")
    local result = vault.scan_markdown(dir)
    assert.equals(1, #result)
    assert.equals(dir .. "/inbox/foo.md", result[1])
  end)

  it("returns Notes across multiple subdirectories", function()
    write_file(dir, "inbox/alpha.md", "")
    write_file(dir, "notes/beta.md", "")
    write_file(dir, "daily/2026-05-15.md", "")
    local result = vault.scan_markdown(dir)
    assert.equals(3, #result)
  end)

  it("includes Notes under daily/ (scanner does not filter)", function()
    write_file(dir, "daily/2026-05-15.md", "")
    local result = vault.scan_markdown(dir)
    assert.equals(1, #result)
    assert.equals(dir .. "/daily/2026-05-15.md", result[1])
  end)

  it("ignores non-markdown files", function()
    write_file(dir, "assets/image.png", "")
    write_file(dir, "notes/keep.md", "")
    local result = vault.scan_markdown(dir)
    assert.equals(1, #result)
    assert.equals(dir .. "/notes/keep.md", result[1])
  end)
end)
