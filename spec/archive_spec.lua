local archive = require("totes.archive")

describe("archive.write_archive_tag", function()
  local project_tag_content = table.concat({
    "---",
    "title: 'My Note'",
    "tags:",
    "  - project/totes",
    "created: 2026-01-01T00:00:00Z",
    "---",
    "Body text.",
    "",
  }, "\n")

  it("replaces a project PARA tag with its archive equivalent", function()
    local result = archive.write_archive_tag(project_tag_content, "archive/project/totes")
    assert.truthy(result:match("  %- archive/project/totes"))
    assert.is_nil(result:match("  %- project/totes\n"))
  end)

  it("adds archive tag when frontmatter has empty tags list", function()
    local content = table.concat({
      "---",
      "title: 'My Note'",
      "tags: []",
      "created: 2026-01-01T00:00:00Z",
      "---",
      "Body.",
      "",
    }, "\n")
    local result = archive.write_archive_tag(content, "archive/my-note")
    assert.truthy(result:match("  %- archive/my%-note"))
    assert.is_nil(result:match("tags: %[%]"))
  end)

  it("adds archive tag when only non-PARA tags exist", function()
    local content = table.concat({
      "---",
      "title: 'My Note'",
      "tags:",
      "  - other/tag",
      "created: 2026-01-01T00:00:00Z",
      "---",
      "Body.",
      "",
    }, "\n")
    local result = archive.write_archive_tag(content, "archive/my-note")
    assert.truthy(result:match("  %- archive/my%-note"))
    assert.truthy(result:match("  %- other/tag"))
  end)

  it("does not double-archive an already-archived tag", function()
    local content = table.concat({
      "---",
      "title: 'My Note'",
      "tags:",
      "  - archive/project/totes",
      "created: 2026-01-01T00:00:00Z",
      "---",
      "Body.",
      "",
    }, "\n")
    local result = archive.write_archive_tag(content, "archive/project/totes")
    local _, occurrences = result:gsub("archive/project/totes", "")
    assert.equal(1, occurrences)
  end)

  it("replaces an area PARA tag with its archive equivalent", function()
    local content = table.concat({
      "---",
      "title: 'My Note'",
      "tags:",
      "  - area/health",
      "created: 2026-01-01T00:00:00Z",
      "---",
      "Body.",
      "",
    }, "\n")
    local result = archive.write_archive_tag(content, "archive/area/health")
    assert.truthy(result:match("  %- archive/area/health"))
    assert.is_nil(result:match("  %- area/health\n"))
  end)
end)
