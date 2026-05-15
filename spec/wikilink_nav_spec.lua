require("support.vim_stub")
local vault = require("totes.vault")
local nav = require("totes.wikilink_nav")

describe("wikilink_nav.wikilink_at_cursor", function()
  it("returns the WikiLink when cursor is inside [[My Note]]", function()
    local result = nav.wikilink_at_cursor("See [[My Note]] here", 7)
    assert.equal("[[My Note]]", result)
  end)

  it("returns the WikiLink when cursor is on the opening bracket", function()
    local result = nav.wikilink_at_cursor("[[My Note]]", 1)
    assert.equal("[[My Note]]", result)
  end)

  it("returns the WikiLink when cursor is on the closing bracket", function()
    local result = nav.wikilink_at_cursor("[[My Note]]", 11)
    assert.equal("[[My Note]]", result)
  end)

  it("returns the WikiLink for an aliased link [[Note|Alias]]", function()
    local result = nav.wikilink_at_cursor("[[Note|Alias]]", 5)
    assert.equal("[[Note|Alias]]", result)
  end)

  it("returns nil when cursor is before [[", function()
    local result = nav.wikilink_at_cursor("text [[My Note]]", 4)
    assert.is_nil(result)
  end)

  it("returns nil when cursor is after ]]", function()
    local result = nav.wikilink_at_cursor("[[My Note]] end", 13)
    assert.is_nil(result)
  end)

  it("returns the second WikiLink when cursor is in it", function()
    local result = nav.wikilink_at_cursor("[[First]] and [[Second]]", 17)
    assert.equal("[[Second]]", result)
  end)

  it("returns nil for plain text with no WikiLinks", function()
    local result = nav.wikilink_at_cursor("just plain text", 5)
    assert.is_nil(result)
  end)

  it("returns nil for an empty line", function()
    local result = nav.wikilink_at_cursor("", 1)
    assert.is_nil(result)
  end)
end)

describe("wikilink_nav.collect_vault_files", function()
  local original_scan = vault.scan_markdown
  local original_root = vault.root

  after_each(function()
    vault.scan_markdown = original_scan
    vault.root = original_root
  end)

  it("returns paths relative to vault.root (no leading slash)", function()
    vault.root = "/tmp/totes-test"
    vault.scan_markdown = function() return { "/tmp/totes-test/notes/foo.md", "/tmp/totes-test/inbox/bar.md" } end
    assert.same({ "notes/foo.md", "inbox/bar.md" }, nav.collect_vault_files())
  end)

  it("tolerates a trailing slash on vault.root", function()
    vault.root = "/tmp/totes-test/"
    vault.scan_markdown = function() return { "/tmp/totes-test/notes/foo.md" } end
    assert.same({ "notes/foo.md" }, nav.collect_vault_files())
  end)

  it("returns an empty list when the scanner finds nothing", function()
    vault.root = "/tmp/totes-test"
    vault.scan_markdown = function() return {} end
    assert.same({}, nav.collect_vault_files())
  end)
end)
