local fs = require("support.fs_helpers")
local note_metadata = require("totes.note_metadata")

describe("note_metadata.read_title", function()
  it("returns the unquoted title from frontmatter", function()
    fs.with_file(
      "---\ntitle: My Note\ntags: []\n---\nbody\n",
      function(path) assert.equal("My Note", note_metadata.read_title(path)) end
    )
  end)

  it("returns a double-quoted title with quotes stripped", function()
    fs.with_file(
      '---\ntitle: "My Note"\ntags: []\n---\n',
      function(path) assert.equal("My Note", note_metadata.read_title(path)) end
    )
  end)

  it("returns a single-quoted title with quotes stripped", function()
    fs.with_file(
      "---\ntitle: 'My Note'\ntags: []\n---\n",
      function(path) assert.equal("My Note", note_metadata.read_title(path)) end
    )
  end)

  it("preserves colons inside a quoted title", function()
    fs.with_file(
      '---\ntitle: "Notes: Part 1"\ntags: []\n---\n',
      function(path) assert.equal("Notes: Part 1", note_metadata.read_title(path)) end
    )
  end)

  it("preserves brackets inside a quoted title", function()
    fs.with_file(
      '---\ntitle: "[Draft] Ideas"\ntags: []\n---\n',
      function(path) assert.equal("[Draft] Ideas", note_metadata.read_title(path)) end
    )
  end)

  it("finds the title field when it appears after other fields", function()
    fs.with_file(
      "---\ntags: []\ncreated: 2026-05-15T00:00:00Z\ntitle: Late Title\n---\n",
      function(path) assert.equal("Late Title", note_metadata.read_title(path)) end
    )
  end)

  it("returns nil when the frontmatter has no title field", function()
    fs.with_file(
      "---\ntags: []\ncreated: 2026-05-15T00:00:00Z\n---\nbody\n",
      function(path) assert.is_nil(note_metadata.read_title(path)) end
    )
  end)

  it("returns nil when the file has no frontmatter", function()
    fs.with_file("just a body, no frontmatter\n", function(path) assert.is_nil(note_metadata.read_title(path)) end)
  end)

  it("returns nil when the frontmatter has no closing ---", function()
    fs.with_file(
      "---\ntitle: Never Closed\ntags: []\nstill no closer\n",
      function(path) assert.is_nil(note_metadata.read_title(path)) end
    )
  end)

  it(
    "returns nil for a non-existent file",
    function() assert.is_nil(note_metadata.read_title("/tmp/totes-does-not-exist-xyz.md")) end
  )

  it("ignores a title: line outside the frontmatter block", function()
    fs.with_file(
      "---\ntags: []\n---\ntitle: Not In Frontmatter\n",
      function(path) assert.is_nil(note_metadata.read_title(path)) end
    )
  end)

  it("trims surrounding whitespace from unquoted titles", function()
    fs.with_file(
      "---\ntitle:   Spaced Out   \n---\n",
      function(path) assert.equal("Spaced Out", note_metadata.read_title(path)) end
    )
  end)
end)
