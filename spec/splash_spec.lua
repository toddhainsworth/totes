local splash = require("totes.splash")

local function tmpdir()
  local path = os.tmpname()
  os.remove(path)
  os.execute('mkdir -p "' .. path .. '"')
  return path
end

local function touch(path)
  local f = assert(io.open(path, "w"))
  f:write("")
  f:close()
end

local function rmdir(path)
  os.execute('rm -rf "' .. path .. '"')
end

describe("splash.count_inbox_notes", function()
  local dir

  before_each(function()
    dir = tmpdir()
  end)

  after_each(function()
    rmdir(dir)
  end)

  it("returns 0 for an empty inbox", function()
    assert.equal(0, splash.count_inbox_notes(dir))
  end)

  it("counts .md files directly in the inbox", function()
    touch(dir .. "/note-one.md")
    touch(dir .. "/note-two.md")
    assert.equal(2, splash.count_inbox_notes(dir))
  end)

  it("ignores non-.md files", function()
    touch(dir .. "/image.png")
    touch(dir .. "/note.md")
    assert.equal(1, splash.count_inbox_notes(dir))
  end)

  it("does not count files in subdirectories", function()
    os.execute('mkdir -p "' .. dir .. '/subdir"')
    touch(dir .. "/subdir/nested.md")
    touch(dir .. "/top-level.md")
    assert.equal(1, splash.count_inbox_notes(dir))
  end)

  it("returns 0 when the path has no .md files at all", function()
    touch(dir .. "/readme.txt")
    assert.equal(0, splash.count_inbox_notes(dir))
  end)
end)
