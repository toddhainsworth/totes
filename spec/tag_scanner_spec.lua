local scanner = require("totes.tag_scanner")

local function tmpdir()
  local path = os.tmpname()
  os.remove(path)
  os.execute('mkdir -p "' .. path .. '"')
  return path
end

local function write_note(dir, name, content)
  local f = io.open(dir .. "/" .. name, "w")
  f:write(content)
  f:close()
end

local function rmdir(path)
  os.execute('rm -rf "' .. path .. '"')
end

describe("tag_scanner.parse_tags", function()
  it("returns a single tag from frontmatter", function()
    local content = "---\ntitle: 'My Note'\ntags:\n  - project/totes\ncreated: 2026-01-01T00:00:00Z\n---\n"
    assert.same({ "project/totes" }, scanner.parse_tags(content))
  end)

  it("returns multiple tags from frontmatter", function()
    local content = "---\ntitle: 'My Note'\ntags:\n  - project/totes\n  - area/health\ncreated: 2026-01-01T00:00:00Z\n---\n"
    assert.same({ "project/totes", "area/health" }, scanner.parse_tags(content))
  end)

  it("returns empty table when tags field is empty list", function()
    local content = "---\ntitle: 'My Note'\ntags: []\ncreated: 2026-01-01T00:00:00Z\n---\n"
    assert.same({}, scanner.parse_tags(content))
  end)

  it("returns empty table when tags field is absent", function()
    local content = "---\ntitle: 'My Note'\ncreated: 2026-01-01T00:00:00Z\n---\n"
    assert.same({}, scanner.parse_tags(content))
  end)

  it("returns empty table when frontmatter delimiters are missing", function()
    local content = "title: 'My Note'\ntags:\n  - project/totes\n"
    assert.same({}, scanner.parse_tags(content))
  end)

  it("parses hierarchical tags correctly", function()
    local content = "---\ntags:\n  - archive/project/totes\n---\n"
    assert.same({ "archive/project/totes" }, scanner.parse_tags(content))
  end)
end)

describe("tag_scanner.scan", function()
  local dir

  before_each(function()
    dir = tmpdir()
  end)

  after_each(function()
    rmdir(dir)
  end)

  it("returns tags from a single file", function()
    write_note(dir, "one.md", "---\ntags:\n  - project/totes\n---\n")
    assert.same({ "project/totes" }, scanner.scan(dir))
  end)

  it("returns a sorted, deduplicated list across multiple files", function()
    write_note(dir, "a.md", "---\ntags:\n  - project/totes\n  - area/health\n---\n")
    write_note(dir, "b.md", "---\ntags:\n  - area/health\n  - resource/neovim\n---\n")
    assert.same({ "area/health", "project/totes", "resource/neovim" }, scanner.scan(dir))
  end)

  it("silently skips files with no tags", function()
    write_note(dir, "no-tags.md", "---\ntitle: 'Empty'\ntags: []\n---\n")
    assert.same({}, scanner.scan(dir))
  end)
end)
