local wow = require("spec.helpers.wow")

describe("Baganator", function()
	local ns
	before_each(function()
		ns = wow.boot()
		ns.Data.SetGroups({
			{ key = "ANIMAL_PARTS", entries = { { itemID = 10, count = 5, quests = { 1 } } } },
		})
	end)
	after_each(function()
		wow.restore()
	end)

	it("registers one widget with the expected id and corner", function()
		local args
		_G.Baganator = {
			API = {
				RegisterCornerWidget = function(...)
					args = { ... }
				end,
			},
		}
		assert.is_true(ns.Baganator.Register())
		assert.equals("darkmoonturnins", args[2])
		assert.same({ corner = "top_left", priority = 1 }, args[5])
		assert.is_true(args[3](nil, { itemID = 10 }))
		assert.is_false(args[3](nil, { itemID = 99 }))
		assert.is_true(args[3](nil, { itemLink = "|Hitem:10::|h[x]|h" }))
		assert.is_false(args[3](nil, {}))
		assert.is_false(args[3](nil, nil))
		local marker = args[4](wow.newFrame())
		assert.is_table(marker)
	end)

	it("does nothing without Baganator", function()
		_G.Baganator = nil
		assert.is_false(ns.Baganator.Register())
		_G.Baganator = {}
		assert.is_false(ns.Baganator.Register())
		assert.equals(0, #_G.DEFAULT_CHAT_FRAME.lines)
	end)

	it("catches a raising registration", function()
		_G.Baganator = {
			API = {
				RegisterCornerWidget = function()
					error("boom")
				end,
			},
		}
		assert.is_false(ns.Baganator.Register())
		assert.equals(1, #_G.DEFAULT_CHAT_FRAME.lines)
	end)
end)
