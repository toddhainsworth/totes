local resolver = require("totes.wikilink_resolver")

local vault = {
  "projects/totes.md",
  "areas/health.md",
  "resources/neovim.md",
  "daily/2026-05-13.md",
  "Inbox.md",
}

describe("wikilink_resolver.resolve", function()
  it("returns zero when no file matches", function()
    local r = resolver.resolve("nonexistent", vault)
    assert.equal("zero", r.kind)
    assert.is_nil(r.path)
    assert.is_nil(r.candidates)
  end)

  it("returns one with the resolved path on an exact match", function()
    local r = resolver.resolve("totes", vault)
    assert.equal("one", r.kind)
    assert.equal("projects/totes.md", r.path)
  end)

  it("returns one when the link includes [[ ]] brackets", function()
    local r = resolver.resolve("[[totes]]", vault)
    assert.equal("one", r.kind)
    assert.equal("projects/totes.md", r.path)
  end)

  it("matching is case-insensitive (link uppercased)", function()
    local r = resolver.resolve("TOTES", vault)
    assert.equal("one", r.kind)
    assert.equal("projects/totes.md", r.path)
  end)

  it("matching is case-insensitive (file mixed-case)", function()
    local r = resolver.resolve("inbox", vault)
    assert.equal("one", r.kind)
    assert.equal("Inbox.md", r.path)
  end)

  it("strips alias before matching", function()
    local r = resolver.resolve("[[totes|My Project]]", vault)
    assert.equal("one", r.kind)
    assert.equal("projects/totes.md", r.path)
  end)

  it("resolves files inside daily/", function()
    local r = resolver.resolve("2026-05-13", vault)
    assert.equal("one", r.kind)
    assert.equal("daily/2026-05-13.md", r.path)
  end)

  it("returns many with all candidates when multiple files share a stem", function()
    local dup_vault = {
      "projects/totes.md",
      "archive/totes.md",
    }
    local r = resolver.resolve("totes", dup_vault)
    assert.equal("many", r.kind)
    assert.is_nil(r.path)
    assert.equal(2, #r.candidates)
  end)

  it("returns zero for an empty vault", function()
    local r = resolver.resolve("totes", {})
    assert.equal("zero", r.kind)
  end)

  it("returns zero for a nil vault", function()
    local r = resolver.resolve("totes", nil)
    assert.equal("zero", r.kind)
  end)
end)
