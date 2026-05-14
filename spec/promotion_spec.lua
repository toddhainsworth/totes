local FAKE_ROOT = "/tmp/totes-promotion-test"
package.loaded["totes.vault"] = { root = FAKE_ROOT }

-- Stub vim in _G so required modules (promotion, tasks) can access it at call time
_G.vim = _G.vim or {}
_G.vim.fn = _G.vim.fn or { expand = function(p) return p end }
_G.vim.log = _G.vim.log or { levels = { INFO = 2, WARN = 3, ERROR = 4 } }
_G.vim.notify = _G.vim.notify or function() end

local promotion = require("totes.promotion")

describe("promotion.promote Task Note guard", function()
  local notified

  before_each(function()
    notified = nil
    _G.vim.notify = function(msg) notified = msg end
    -- Reload tasks so it binds to the fake vault root set above
    package.loaded["totes.tasks"] = nil
    _G.vim.fn.expand = function() return FAKE_ROOT .. "/notes/tasks.md" end
  end)

  it("returns early with a notice when the current file is the Task Note", function()
    promotion.promote()
    assert.truthy(notified and notified:find("Task Note"))
  end)
end)

describe("promotion.is_daily", function()
  it(
    "returns true for a path inside daily/",
    function() assert.is_true(promotion.is_daily("/home/user/totes/daily/2026-05-13.md")) end
  )

  it(
    "returns false for a path inside inbox/",
    function() assert.is_false(promotion.is_daily("/home/user/totes/inbox/my-note.md")) end
  )

  it(
    "returns false for a path inside notes/",
    function() assert.is_false(promotion.is_daily("/home/user/totes/notes/my-note.md")) end
  )
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
