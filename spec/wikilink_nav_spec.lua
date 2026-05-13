-- Stub vim and vault before loading wikilink_nav, as vault calls vim.fn at load time.
vim = vim or {}
vim.fn = vim.fn or { expand = function(p) return p end }

package.loaded["totes.vault"] = { root = "/tmp/totes-test" }
package.loaded["totes.wikilink_resolver"] = require("totes.wikilink_resolver")

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
