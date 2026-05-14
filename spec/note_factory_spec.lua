local factory = require("totes.note_factory")

describe("note_factory.slugify", function()
  it(
    "converts a normal title to kebab-case",
    function() assert.equal("my-thoughts-on-rust", factory.slugify("My Thoughts on Rust")) end
  )

  it("lowercases the result", function() assert.equal("hello-world", factory.slugify("HELLO WORLD")) end)

  it("strips punctuation", function() assert.equal("hello-world", factory.slugify("Hello, World!")) end)

  it(
    "collapses consecutive spaces",
    function() assert.equal("my-double-space", factory.slugify("My  Double  Space")) end
  )

  it("trims leading and trailing whitespace", function() assert.equal("my-note", factory.slugify("  My Note  ")) end)

  it("handles numbers in titles", function() assert.equal("note-42", factory.slugify("Note 42")) end)

  it("returns empty string for empty input", function() assert.equal("", factory.slugify("")) end)

  it("returns empty string for whitespace-only input", function() assert.equal("", factory.slugify("   ")) end)

  it("strips non-ASCII characters", function() assert.equal("caf-notes", factory.slugify("Café Notes")) end)

  it("handles titles that are only special characters", function() assert.equal("", factory.slugify("!!!")) end)
end)

describe("note_factory.timestamp", function()
  it("returns a string matching ISO 8601 UTC format", function()
    local ts = factory.timestamp()
    assert.truthy(ts:match("^%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%dZ$"))
  end)
end)

describe("note_factory.frontmatter", function()
  it("includes title, tags, and created fields", function()
    local fm = factory.frontmatter("My Note", {})
    assert.truthy(fm:match("title: 'My Note'"))
    assert.truthy(fm:match("tags: %[%]"))
    assert.truthy(fm:match("created: %d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%dZ"))
  end)

  it("wraps content in YAML front-matter delimiters", function()
    local fm = factory.frontmatter("Test", {})
    assert.truthy(fm:match("^---\n"))
    assert.truthy(fm:match("\n---\n"))
  end)

  it("renders an empty tag list as []", function()
    local fm = factory.frontmatter("Test", {})
    assert.truthy(fm:match("tags: %[%]"))
  end)

  it("renders a non-empty tag list as block sequence", function()
    local fm = factory.frontmatter("Test", { "project/totes", "area/health" })
    assert.truthy(fm:match("  %- project/totes"))
    assert.truthy(fm:match("  %- area/health"))
  end)

  it("uses empty tag list when tags is nil", function()
    local fm = factory.frontmatter("Test", nil)
    assert.truthy(fm:match("tags: %[%]"))
  end)

  it("quotes a title containing a colon", function()
    local fm = factory.frontmatter("My Note: Redux", {})
    assert.truthy(fm:match("title: 'My Note: Redux'"))
  end)

  it("escapes single quotes in title with doubled single quotes", function()
    local fm = factory.frontmatter("Todd's Note", {})
    assert.truthy(fm:match("title: 'Todd''s Note'"))
  end)
end)

describe("note_factory.create", function()
  it("returns a filename derived from the title", function()
    local note = factory.create("My Thoughts on Rust", {})
    assert.equal("my-thoughts-on-rust.md", note.filename)
  end)

  it("returns a frontmatter string", function()
    local note = factory.create("My Note", {})
    assert.truthy(note.frontmatter:match("title: 'My Note'"))
  end)

  it("defaults to empty tags when not provided", function()
    local note = factory.create("My Note")
    assert.truthy(note.frontmatter:match("tags: %[%]"))
  end)
end)
