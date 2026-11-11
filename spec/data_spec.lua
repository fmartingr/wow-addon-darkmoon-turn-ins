local wow = require("spec.helpers.wow")
local questie = dofile("spec/fixtures/questie_quest_ids.lua")

describe("Data", function()
	local ns
	before_each(function()
		ns = wow.boot()
	end)
	after_each(function()
		wow.restore()
	end)

	it("has positive integer item IDs and counts, and quests per entry", function()
		local seen = {}
		for _, entry in ipairs(ns.Data.entries) do
			assert.is_true(entry.itemID > 0 and entry.itemID % 1 == 0)
			assert.is_true(entry.count > 0 and entry.count % 1 == 0)
			assert.is_true(#entry.quests >= 1)
			local key = entry.itemID .. ":" .. entry.count
			assert.is_nil(seen[key], key)
			seen[key] = true
		end
	end)

	it("only uses quest IDs that Questie lists", function()
		local known = {}
		for _, id in ipairs(questie) do
			known[id] = true
		end
		for _, entry in ipairs(ns.Data.entries) do
			for _, quest in ipairs(entry.quests) do
				assert.is_true(known[quest], tostring(quest))
			end
		end
	end)

	it("answers IsTurnInItem for data items and bad input", function()
		for _, entry in ipairs(ns.Data.entries) do
			assert.is_true(ns.Data.IsTurnInItem(entry.itemID))
		end
		assert.is_false(ns.Data.IsTurnInItem(0))
		assert.is_false(ns.Data.IsTurnInItem(nil))
		assert.is_false(ns.Data.IsTurnInItem("5134"))
		assert.is_nil(ns.Data.GetEntries("5134"))
		assert.is_nil(ns.Data.GetNeed(nil))
		assert.is_nil(ns.Data.GetNeed(1))
	end)

	it("returns the lowest count as need", function()
		ns.Data.SetGroups({
			{
				key = "ANIMAL_PARTS",
				entries = {
					{ itemID = 1, count = 5, quests = { 1 } },
					{ itemID = 1, count = 3, quests = { 2 } },
				},
			},
		})
		assert.equals(3, ns.Data.GetNeed(1))
		assert.equals(2, #ns.Data.GetEntries(1))
		assert.equals(1, #ns.Data.GetGroups())
	end)

	it("has a locale string for every group key", function()
		for _, group in ipairs(ns.Data.GetGroups()) do
			for name, locale in pairs(ns.locales) do
				assert.is_string(locale["GROUP_" .. group.key], name .. " " .. group.key)
			end
		end
	end)
end)
