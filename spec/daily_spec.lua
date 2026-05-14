_G.vim = _G.vim or {}
_G.vim.fn = _G.vim.fn or {}
_G.vim.fn.expand = _G.vim.fn.expand or function(p) return p end
_G.vim.log = _G.vim.log or { levels = { ERROR = 4 } }
_G.vim.notify = _G.vim.notify or function() end
_G.vim.cmd = _G.vim.cmd or function() end

local FAKE_ROOT = "/tmp/totes-daily-test"

local daily

describe("daily.today_date", function()
  it("returns a string matching YYYY-MM-DD format", function()
    package.loaded["totes.vault"] = { root = FAKE_ROOT }
    package.loaded["totes.daily"] = nil
    daily = require("totes.daily")
    local date = daily.today_date()
    assert.truthy(date:match("^%d%d%d%d%-%d%d%-%d%d$"))
  end)
end)

describe("daily.open (new file)", function()
  local daily_dir = FAKE_ROOT .. "/daily"

  before_each(function()
    package.loaded["totes.vault"] = { root = FAKE_ROOT }
    package.loaded["totes.daily"] = nil
    daily = require("totes.daily")
    _G.vim.fn.mkdir = function() end
    _G.vim.fn.fnameescape = function(p) return p end
    _G.vim.cmd = function() end
    os.execute("mkdir -p " .. daily_dir)
  end)

  after_each(function() os.execute("rm -rf " .. daily_dir) end)

  it("creates a daily note with a daily tag and a date heading", function()
    daily.open()

    local date = daily.today_date()
    local path = daily_dir .. "/" .. date .. ".md"
    local f = io.open(path, "r")
    assert.is_not_nil(f)
    local content = f:read("*a")
    f:close()

    assert.truthy(content:match("tags:"))
    assert.truthy(content:match("-%s+daily"))
    assert.truthy(content:find("# " .. date, 1, true))
  end)
end)
