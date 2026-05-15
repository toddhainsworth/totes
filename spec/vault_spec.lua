require("support.vim_stub")
local fs = require("support.fs_helpers")
local vault = require("totes.vault")

describe("vault.scan_markdown", function()
  local dir

  before_each(function() dir = fs.tmpdir() end)

  after_each(function() fs.rmdir(dir) end)

  it("returns an empty list for an empty Vault", function() assert.same({}, vault.scan_markdown(dir)) end)

  it("returns the absolute path of a Note in inbox/", function()
    fs.write_file(dir, "inbox/foo.md", "")
    local result = vault.scan_markdown(dir)
    assert.equals(1, #result)
    assert.equals(dir .. "/inbox/foo.md", result[1])
  end)

  it("returns Notes across multiple subdirectories", function()
    fs.write_file(dir, "inbox/alpha.md", "")
    fs.write_file(dir, "notes/beta.md", "")
    fs.write_file(dir, "daily/2026-05-15.md", "")
    local result = vault.scan_markdown(dir)
    assert.equals(3, #result)
  end)

  it("includes Notes under daily/ (scanner does not filter)", function()
    fs.write_file(dir, "daily/2026-05-15.md", "")
    local result = vault.scan_markdown(dir)
    assert.equals(1, #result)
    assert.equals(dir .. "/daily/2026-05-15.md", result[1])
  end)

  it("ignores non-markdown files", function()
    fs.write_file(dir, "assets/image.png", "")
    fs.write_file(dir, "notes/keep.md", "")
    local result = vault.scan_markdown(dir)
    assert.equals(1, #result)
    assert.equals(dir .. "/notes/keep.md", result[1])
  end)
end)

describe("vault.to_relative", function()
  it(
    "strips the root prefix from an absolute path",
    function() assert.equals("inbox/foo.md", vault.to_relative("/home/me/totes", "/home/me/totes/inbox/foo.md")) end
  )

  it(
    "strips the root prefix when root has a trailing slash",
    function() assert.equals("inbox/foo.md", vault.to_relative("/home/me/totes/", "/home/me/totes/inbox/foo.md")) end
  )

  it(
    "works for deeply nested paths",
    function() assert.equals("notes/a/b/c.md", vault.to_relative("/home/me/totes", "/home/me/totes/notes/a/b/c.md")) end
  )
end)
