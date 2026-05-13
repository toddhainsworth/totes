local command = require("totes.command")

describe("command.is_newer", function()
  it("returns true when minor version is higher", function()
    assert.is_true(command.is_newer("v1.0.0", "v1.1.0"))
  end)

  it("returns true when major version is higher", function()
    assert.is_true(command.is_newer("v1.2.3", "v2.0.0"))
  end)

  it("returns true when patch version is higher", function()
    assert.is_true(command.is_newer("v1.0.0", "v1.0.1"))
  end)

  it("returns false when versions are equal", function()
    assert.is_false(command.is_newer("v1.0.0", "v1.0.0"))
  end)

  it("returns false when latest is older (minor)", function()
    assert.is_false(command.is_newer("v1.2.0", "v1.1.9"))
  end)

  it("returns false when latest is older (major)", function()
    assert.is_false(command.is_newer("v2.0.0", "v1.9.9"))
  end)

  it("returns false when latest is older (patch)", function()
    assert.is_false(command.is_newer("v1.0.5", "v1.0.4"))
  end)

  it("handles tags without v prefix", function()
    assert.is_true(command.is_newer("1.0.0", "1.1.0"))
  end)

  it("returns false for malformed current tag", function()
    assert.is_false(command.is_newer("bad", "v1.0.0"))
  end)

  it("returns false for malformed latest tag", function()
    assert.is_false(command.is_newer("v1.0.0", "bad"))
  end)
end)
