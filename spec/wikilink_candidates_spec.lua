require("support.vim_stub")
local fs = require("support.fs_helpers")
local candidates = require("totes.wikilink_candidates")

describe("wikilink_candidates.collect", function()
  local dir

  before_each(function() dir = fs.tmpdir() end)

  after_each(function() fs.rmdir(dir) end)

  it("returns an empty list for an empty Vault", function() assert.same({}, candidates.collect(dir)) end)

  it("returns the kebab-case stem for a Note in inbox/", function()
    fs.write_file(dir, "inbox/my-thoughts.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("my-thoughts", result[1].stem)
  end)

  it("returns stems for Notes across multiple subdirectories", function()
    fs.write_file(dir, "inbox/alpha.md", "")
    fs.write_file(dir, "notes/beta.md", "")
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
    fs.write_file(dir, "notes/keep.md", "")
    fs.write_file(dir, "daily/2026-05-15.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("keep", result[1].stem)
  end)

  it("excludes Notes in nested directories under daily/", function()
    fs.write_file(dir, "daily/2026/05/15.md", "")
    fs.write_file(dir, "notes/keep.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("keep", result[1].stem)
  end)

  it("ignores non-markdown files", function()
    fs.write_file(dir, "assets/image.png", "")
    fs.write_file(dir, "notes/keep.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("keep", result[1].stem)
  end)

  it("attaches the title from frontmatter to each candidate", function()
    fs.write_file(dir, "notes/my-thoughts-on-rust.md", '---\ntitle: "My Thoughts on Rust"\ntags: []\n---\n')
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals("my-thoughts-on-rust", result[1].stem)
    assert.equals("My Thoughts on Rust", result[1].title)
  end)

  it("leaves title nil when the Note has no title frontmatter", function()
    fs.write_file(dir, "notes/bare.md", "no frontmatter here\n")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.is_nil(result[1].title)
  end)

  it("includes the absolute path on each record", function()
    fs.write_file(dir, "notes/alpha.md", "")
    local result = candidates.collect(dir)
    assert.equals(1, #result)
    assert.equals(dir .. "/notes/alpha.md", result[1].path)
  end)

  it("derives correct stems when vault_root has a trailing slash", function()
    fs.write_file(dir, "notes/alpha.md", "")
    local result = candidates.collect(dir .. "/")
    assert.equals(1, #result)
    assert.equals("alpha", result[1].stem)
  end)
end)
