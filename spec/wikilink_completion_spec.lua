local completion = require("totes.wikilink_completion")

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
