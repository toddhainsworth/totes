-- Stub vim before loading vault (transitively required by wikilink_candidates).
_G.vim = _G.vim or {}
_G.vim.fn = _G.vim.fn or { expand = function(p) return p end }

local candidates = require("totes.wikilink_candidates")

local function tmpdir()
  local path = os.tmpname()
  os.remove(path)
  os.execute('mkdir -p "' .. path .. '"')
  return path
end

local function rmdir(path) os.execute('rm -rf "' .. path .. '"') end

local function write_note(dir, rel, content)
  local full = dir .. "/" .. rel
  os.execute('mkdir -p "' .. full:match("(.*)/") .. '"')
  local f = io.open(full, "w")
  f:write(content or "")
  f:close()
end

describe("wikilink_candidates.collect", function()
  local dir

  before_each(function() dir = tmpdir() end)

  after_each(function() rmdir(dir) end)

  it("returns an empty list for an empty Vault", function() assert.same({}, candidates.collect(dir)) end)

  it("returns the kebab-case stem for a Note in inbox/", function()
    write_note(dir, "inbox/my-thoughts.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("my-thoughts", result[1].stem)
  end)

  it("returns stems for Notes across multiple subdirectories", function()
    write_note(dir, "inbox/alpha.md", "")
    write_note(dir, "notes/beta.md", "")
    local result = candidates.collect(dir)
    local stems = {}
    for _, c in ipairs(result) do
      stems[c.stem] = true
    end
    assert.is_true(stems["alpha"])
    assert.is_true(stems["beta"])
    assert.equals(2, #result)
  end)

  it("excludes Notes under daily/", function()
    write_note(dir, "notes/keep.md", "")
    write_note(dir, "daily/2026-05-15.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("keep", result[1].stem)
  end)

  it("excludes Notes in nested directories under daily/", function()
    write_note(dir, "daily/2026/05/15.md", "")
    write_note(dir, "notes/keep.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("keep", result[1].stem)
  end)

  it("ignores non-markdown files", function()
    write_note(dir, "assets/image.png", "")
    write_note(dir, "notes/keep.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("keep", result[1].stem)
  end)

  it("attaches the title from frontmatter to each candidate", function()
    write_note(dir, "notes/my-thoughts-on-rust.md", '---\ntitle: "My Thoughts on Rust"\ntags: []\n---\n')
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("my-thoughts-on-rust", result[1].stem)
    assert.equals("My Thoughts on Rust", result[1].title)
  end)

  it("leaves title nil when the Note has no title frontmatter", function()
    write_note(dir, "notes/bare.md", "no frontmatter here\n")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.is_nil(result[1].title)
  end)

  it("includes the absolute path on each record", function()
    write_note(dir, "notes/alpha.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals(dir .. "/notes/alpha.md", result[1].path)
  end)
end)
