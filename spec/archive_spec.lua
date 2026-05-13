local FAKE_ROOT = "/tmp/totes-archive-test"
package.loaded["totes.vault"] = { root = FAKE_ROOT }

-- Stub vim in _G so required modules (archive, tasks) can access it at call time
_G.vim = _G.vim or {}
_G.vim.fn = _G.vim.fn or { expand = function(p) return p end, fnamemodify = function(p) return p end }
_G.vim.log = _G.vim.log or { levels = { INFO = 2, WARN = 3, ERROR = 4 } }
_G.vim.notify = _G.vim.notify or function() end

local archive = require("totes.archive")

describe("archive.archive Task Note guard", function()
  local notified

  before_each(function()
    notified = nil
    _G.vim.notify = function(msg) notified = msg end
    -- Reload tasks so it binds to the fake vault root set above
    package.loaded["totes.tasks"] = nil
    _G.vim.fn.expand = function() return FAKE_ROOT .. "/notes/tasks.md" end
  end)

  it("returns early with a notice when the current file is the Task Note", function()
    archive.archive()
    assert.truthy(notified and notified:find("Task Note"))
  end)
end)

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
