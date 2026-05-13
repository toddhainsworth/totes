local sources = require("totes.telescope_sources")

describe("telescope_sources.tag_matches", function()
  it("matches a tag under a prefix (hierarchical)", function()
    assert.is_true(sources.tag_matches("project/totes", "project/"))
  end)

  it("matches a tag exactly", function()
    assert.is_true(sources.tag_matches("project/totes", "project/totes"))
  end)

  it("does not match a tag from a different prefix", function()
    assert.is_false(sources.tag_matches("area/health", "project/"))
  end)

  it("does not match when prefix is deeper than the tag", function()
    assert.is_false(sources.tag_matches("project/totes", "project/totes/sub"))
  end)

  it("empty prefix matches anything", function()
    assert.is_true(sources.tag_matches("project/totes", ""))
    assert.is_true(sources.tag_matches("area/health", ""))
    assert.is_true(sources.tag_matches("", ""))
  end)

  it("matches a deeply nested tag under its ancestor prefix", function()
    assert.is_true(sources.tag_matches("archive/project/totes", "archive/"))
  end)
end)
