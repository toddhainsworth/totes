local autogit = require("totes.autogit")

describe("autogit.parse_title", function()
  it("extracts title from YAML frontmatter", function()
    local content = "---\ntitle: 'My Note'\ntags: []\ncreated: 2026-01-01T00:00:00Z\n---\n"
    assert.equal("My Note", autogit.parse_title(content))
  end)

  it("returns untitled when there is no frontmatter", function()
    local content = "Just some plain text without frontmatter."
    assert.equal("untitled", autogit.parse_title(content))
  end)

  it("returns untitled when title field is missing", function()
    local content = "---\ntags: []\ncreated: 2026-01-01T00:00:00Z\n---\n"
    assert.equal("untitled", autogit.parse_title(content))
  end)

  it("returns untitled when title is empty", function()
    local content = "---\ntitle: ''\ntags: []\n---\n"
    assert.equal("untitled", autogit.parse_title(content))
  end)

  it("returns untitled for nil input", function() assert.equal("untitled", autogit.parse_title(nil)) end)

  it("unescapes doubled single quotes in title", function()
    local content = "---\ntitle: 'Todd''s Note'\ntags: []\n---\n"
    assert.equal("Todd's Note", autogit.parse_title(content))
  end)
end)
