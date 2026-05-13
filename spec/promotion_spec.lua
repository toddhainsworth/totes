local promotion = require("totes.promotion")

describe("promotion.is_daily", function()
  it("returns true for a path inside daily/", function()
    assert.is_true(promotion.is_daily("/home/user/totes/daily/2026-05-13.md"))
  end)

  it("returns false for a path inside inbox/", function()
    assert.is_false(promotion.is_daily("/home/user/totes/inbox/my-note.md"))
  end)

  it("returns false for a path inside notes/", function()
    assert.is_false(promotion.is_daily("/home/user/totes/notes/my-note.md"))
  end)
end)

describe("promotion.update_frontmatter_tag", function()
  local empty_tags_content = table.concat({
    "---",
    "title: 'My Note'",
    "tags: []",
    "created: 2026-01-01T00:00:00Z",
    "---",
    "Body text.",
    "",
  }, "\n")

  local existing_tags_content = table.concat({
    "---",
    "title: 'My Note'",
    "tags:",
    "  - area/health",
    "created: 2026-01-01T00:00:00Z",
    "---",
    "Body text.",
    "",
  }, "\n")

  it("replaces empty tags list with a single tag entry", function()
    local result = promotion.update_frontmatter_tag(empty_tags_content, "project/totes")
    assert.truthy(result:match("tags:\n  %- project/totes"))
    assert.is_nil(result:match("tags: %[%]"))
  end)

  it("appends a tag to an existing block sequence", function()
    local result = promotion.update_frontmatter_tag(existing_tags_content, "project/totes")
    assert.truthy(result:match("  %- area/health"))
    assert.truthy(result:match("  %- project/totes"))
  end)

  it("returns content unchanged when tag is nil", function()
    local result = promotion.update_frontmatter_tag(empty_tags_content, nil)
    assert.equal(empty_tags_content, result)
  end)

  it("returns content unchanged when tag is empty string", function()
    local result = promotion.update_frontmatter_tag(empty_tags_content, "")
    assert.equal(empty_tags_content, result)
  end)

  it("does not modify content outside frontmatter", function()
    local result = promotion.update_frontmatter_tag(empty_tags_content, "project/totes")
    assert.truthy(result:match("Body text%."))
  end)
end)
