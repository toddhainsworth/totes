-- Stub vim and vault before loading daily, as vault calls vim.fn at load time
vim = vim or {}
vim.fn = vim.fn or { expand = function(p) return p end }

package.loaded["totes.vault"] = { root = "/tmp/totes-test" }

local daily = require("totes.daily")

describe("daily.today_date", function()
  it("returns a string matching YYYY-MM-DD format", function()
    local date = daily.today_date()
    assert.truthy(date:match("^%d%d%d%d%-%d%d%-%d%d$"))
  end)
end)
