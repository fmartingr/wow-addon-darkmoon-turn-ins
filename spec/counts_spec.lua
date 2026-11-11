local wow = require("spec.helpers.wow")

local function char(name, counts)
	local c = { character = name, realmNormalized = "Realm" }
	for k, v in pairs(counts or {}) do
		c[k] = v
	end
	return c
end

describe("Counts", function()
	local ns
	before_each(function()
		ns = wow.boot()
		ns.Data.SetGroups({
			{
				key = "ANIMAL_PARTS",
				entries = {
					{ itemID = 10, count = 5, quests = { 1 } },
					{ itemID = 11, count = 2, quests = { 2 } },
				},
			},
		})
	end)
	after_each(function()
		wow.restore()
	end)

	describe("GetOwned", function()
		it("uses C_Item.GetItemCount with the bank flag", function()
			local args
			_G.C_Item.GetItemCount = function(...)
				args = { ... }
				return 7
			end
			assert.equals(7, ns.Counts.GetOwned(10))
			assert.same({ 10, true }, args)
		end)

		it("falls back to the global GetItemCount", function()
			_G.C_Item = nil
			_G.GetItemCount = function(_, bank)
				return bank and 4 or 0
			end
			assert.equals(4, ns.Counts.GetOwned(10))
		end)

		it("returns 0 without any API and for a nil result", function()
			_G.C_Item = nil
			_G.GetItemCount = nil
			assert.equals(0, ns.Counts.GetOwned(10))
			_G.C_Item = { GetItemCount = function() end }
			assert.equals(0, ns.Counts.GetOwned(10))
		end)
	end)

	describe("Status and Summary", function()
		local have
		before_each(function()
			have = {}
			_G.C_Item.GetItemCount = function(id)
				return have[id]
			end
		end)

		it("reports missing, ready and surplus", function()
			local entry = ns.Data.entries[1]
			have[10] = 4
			assert.same({ have = 4, need = 5, ready = false, missing = 1 }, ns.Counts.Status(entry))
			have[10] = 5
			assert.same({ have = 5, need = 5, ready = true, missing = 0 }, ns.Counts.Status(entry))
			have[10] = 9
			assert.same({ have = 9, need = 5, ready = true, missing = 0 }, ns.Counts.Status(entry))
		end)

		it("counts ready entries", function()
			have[11] = 2
			assert.same({ ready = 1, total = 2 }, ns.Counts.Summary())
		end)
	end)

	describe("GetOthers", function()
		local function syndicator(characters, current)
			_G.Syndicator = {
				API = {
					GetCurrentCharacter = function()
						return current or "Me-Realm"
					end,
					GetInventoryInfoByItemID = function()
						return { characters = characters }
					end,
				},
			}
		end

		it("returns an empty list without Syndicator or its API", function()
			assert.same({}, ns.Counts.GetOthers(10))
			_G.Syndicator = {}
			assert.same({}, ns.Counts.GetOthers(10))
			_G.Syndicator = { API = {} }
			assert.same({}, ns.Counts.GetOthers(10))
		end)

		it("returns an empty list for nil info and missing characters", function()
			_G.Syndicator = { API = { GetInventoryInfoByItemID = function() end } }
			assert.same({}, ns.Counts.GetOthers(10))
			_G.Syndicator = { API = {
				GetInventoryInfoByItemID = function()
					return {}
				end,
			} }
			assert.same({}, ns.Counts.GetOthers(10))
		end)

		it("catches an error and reports one time", function()
			_G.Syndicator = {
				API = {
					GetInventoryInfoByItemID = function()
						error("boom")
					end,
				},
			}
			assert.same({}, ns.Counts.GetOthers(10))
			assert.same({}, ns.Counts.GetOthers(10))
			assert.equals(1, #_G.DEFAULT_CHAT_FRAME.lines)
		end)

		it("sums all fields, skips the current character and zero sums, and sorts", function()
			syndicator({
				char("Me", { bags = 99 }),
				char("Zed", { bags = 1, bank = 1, mail = 1, equipped = 1, void = 1, auctions = 1 }),
				char("Amy", { bank = 6 }),
				char("Bob", { bags = 6 }),
				char("Nil", {}),
				char("Cat", { bags = 2, mail = nil }),
			})
			assert.same({
				{ name = "Amy", count = 6 },
				{ name = "Bob", count = 6 },
				{ name = "Zed", count = 6 },
				{ name = "Cat", count = 2 },
			}, ns.Counts.GetOthers(10))
		end)

		it("caps the list at 10 and adds a more entry", function()
			local list = {}
			for i = 1, 13 do
				list[i] = char(string.format("C%02d", i), { bags = i })
			end
			syndicator(list)
			local others = ns.Counts.GetOthers(10)
			assert.equals(11, #others)
			assert.equals(13, others[1].count)
			assert.same({ more = 3 }, others[11])
		end)
	end)
end)
