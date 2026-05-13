-- Stub vim and vault before loading tasks, as vault calls vim.fn at load time
vim = vim or {}
vim.fn = vim.fn or { expand = function(p) return p end }

local FAKE_ROOT = "/tmp/totes-tasks-test"

package.loaded["totes.vault"] = { root = FAKE_ROOT }

local tasks = require("totes.tasks")

local function task_note_path(root)
  return (root or FAKE_ROOT) .. "/notes/tasks.md"
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

local function setup_notes_dir(root)
  os.execute("mkdir -p " .. (root or FAKE_ROOT) .. "/notes")
end

local function teardown_notes_dir(root)
  os.execute("rm -rf " .. (root or FAKE_ROOT) .. "/notes")
end

describe("tasks.is_task_note", function()
  it("returns true for the vault task note path", function()
    assert.is_true(tasks.is_task_note(FAKE_ROOT .. "/notes/tasks.md"))
  end)

  it("returns false for any other path", function()
    assert.is_false(tasks.is_task_note(FAKE_ROOT .. "/notes/other.md"))
    assert.is_false(tasks.is_task_note("/some/random/path.md"))
  end)
end)

describe("tasks.append", function()
  before_each(function()
    setup_notes_dir()
  end)

  after_each(function()
    teardown_notes_dir()
  end)

  it("creates the file with frontmatter and appends the task on first call", function()
    local ok, err = tasks.append("buy milk")
    assert.is_nil(err)
    assert.is_true(ok)

    local content = read_file(task_note_path())
    assert.is_not_nil(content)
    assert.truthy(content:match("^%-%-%-\n"))
    assert.truthy(content:match("title: 'Tasks'"))
    assert.truthy(content:match("tags: %[%]"))
    assert.truthy(content:match("created: %d%d%d%d"))
    assert.truthy(content:match("%- %[ %] buy milk\n"))
  end)

  it("appends without touching prior content on subsequent calls", function()
    tasks.append("first task")
    local after_first = read_file(task_note_path())

    tasks.append("second task")
    local after_second = read_file(task_note_path())

    assert.truthy(after_second:sub(1, #after_first) == after_first)
    assert.truthy(after_second:match("%- %[ %] second task\n"))
  end)

  it("returns false and an error when the file is not writable", function()
    local note_path = task_note_path()
    local f = io.open(note_path, "w")
    f:write("---\ntitle: 'Tasks'\ntags: []\ncreated: 2026-01-01T00:00:00Z\n---\n")
    f:close()
    os.execute("chmod 000 " .. note_path)

    local ok, err = tasks.append("should fail")
    assert.is_false(ok)
    assert.is_not_nil(err)

    os.execute("chmod 644 " .. note_path)
  end)
end)
