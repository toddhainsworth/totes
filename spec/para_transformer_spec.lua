local transformer = require("totes.para_transformer")

describe("para_transformer.transform", function()
  it("prefixes a project tag with archive/", function()
    assert.equal("archive/project/totes", transformer.transform({ "project/totes" }, "my-note"))
  end)

  it("prefixes an area tag with archive/", function()
    assert.equal("archive/area/health", transformer.transform({ "area/health" }, "my-note"))
  end)

  it("prefixes a resource tag with archive/", function()
    assert.equal("archive/resource/neovim", transformer.transform({ "resource/neovim" }, "my-note"))
  end)

  it("falls back to archive/<filename-stem> when no PARA tag is present", function()
    assert.equal("archive/my-note", transformer.transform({}, "my-note"))
  end)

  it("falls back when tags exist but none are PARA tags", function()
    assert.equal("archive/my-note", transformer.transform({ "other/tag" }, "my-note"))
  end)

  it("does not double-archive an already-archived tag", function()
    assert.equal("archive/project/totes", transformer.transform({ "archive/project/totes" }, "my-note"))
  end)

  it("uses the first PARA tag when multiple are present", function()
    assert.equal("archive/project/totes", transformer.transform({ "project/totes", "area/health" }, "my-note"))
  end)
end)
