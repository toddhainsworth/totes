local completion = require("totes.wikilink_completion")

local function tmpdir()
  local path = os.tmpname()
  os.remove(path)
  os.execute('mkdir -p "' .. path .. '"')
  return path
end

local function rmdir(path) os.execute('rm -rf "' .. path .. '"') end

local function write_note(dir, rel, content)
  local full = dir .. "/" .. rel
  os.execute('mkdir -p "' .. full:match("(.*)/") .. '"')
  local f = io.open(full, "w")
  f:write(content or "")
  f:close()
end

describe("wikilink_completion.should_trigger", function()
  it("returns true right after [[", function() assert.is_true(completion.should_trigger("See [[", 6)) end)

  it(
    "returns true when typing a partial stem inside [[abc",
    function() assert.is_true(completion.should_trigger("See [[abc", 9)) end
  )

  it(
    "returns false when there is no [[ before the cursor",
    function() assert.is_false(completion.should_trigger("just some text", 5)) end
  )

  it("returns false on an empty line", function() assert.is_false(completion.should_trigger("", 0)) end)

  it(
    "returns false when a | sits between [[ and cursor (alias text)",
    function() assert.is_false(completion.should_trigger("[[note|Alias", 12)) end
  )

  it(
    "returns false when ]] sits between [[ and cursor (closed link)",
    function() assert.is_false(completion.should_trigger("[[note]] after", 12)) end
  )

  it(
    "returns true inside the latest open WikiLink when an earlier one is closed",
    function() assert.is_true(completion.should_trigger("[[done]] and [[par", 18)) end
  )

  it(
    "returns false when cursor sits on the | itself",
    function() assert.is_false(completion.should_trigger("[[note|", 7)) end
  )
end)

describe("wikilink_completion.candidates", function()
  local dir

  before_each(function() dir = tmpdir() end)

  after_each(function() rmdir(dir) end)

  it("returns an empty list for an empty Vault", function() assert.same({}, completion.candidates(dir)) end)

  it("returns the kebab-case stem for a Note in inbox/", function()
    write_note(dir, "inbox/my-thoughts.md", "")
    local result = completion.candidates(dir)
    assert.equals(1, #result)
    assert.equals("my-thoughts", result[1].stem)
  end)

  it("returns stems for Notes across multiple subdirectories", function()
    write_note(dir, "inbox/alpha.md", "")
    write_note(dir, "notes/beta.md", "")
    local result = completion.candidates(dir)
    local stems = {}
    for _, c in ipairs(result) do
      stems[c.stem] = true
    end
    assert.is_true(stems["alpha"])
    assert.is_true(stems["beta"])
    assert.equals(2, #result)
  end)

  it("excludes Notes under daily/", function()
    write_note(dir, "notes/keep.md", "")
    write_note(dir, "daily/2026-05-15.md", "")
    local result = completion.candidates(dir)
    assert.equals(1, #result)
    assert.equals("keep", result[1].stem)
  end)

  it("excludes Notes in nested directories under daily/", function()
    write_note(dir, "daily/2026/05/15.md", "")
    write_note(dir, "notes/keep.md", "")
    local result = completion.candidates(dir)
    assert.equals(1, #result)
    assert.equals("keep", result[1].stem)
  end)

  it("ignores non-markdown files", function()
    write_note(dir, "assets/image.png", "")
    write_note(dir, "notes/keep.md", "")
    local result = completion.candidates(dir)
    assert.equals(1, #result)
    assert.equals("keep", result[1].stem)
  end)

  it("attaches the title from frontmatter to each candidate", function()
    write_note(dir, "notes/my-thoughts-on-rust.md", '---\ntitle: "My Thoughts on Rust"\ntags: []\n---\n')
    local result = completion.candidates(dir)
    assert.equals(1, #result)
    assert.equals("my-thoughts-on-rust", result[1].stem)
    assert.equals("My Thoughts on Rust", result[1].title)
  end)

  it("leaves title nil when the Note has no title frontmatter", function()
    write_note(dir, "notes/bare.md", "no frontmatter here\n")
    local result = completion.candidates(dir)
    assert.equals(1, #result)
    assert.is_nil(result[1].title)
  end)
end)
