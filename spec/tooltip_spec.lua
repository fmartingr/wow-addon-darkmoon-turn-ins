local wow = require("spec.helpers.wow")

describe("Tooltip", function()
	local ns
	before_each(function()
		ns = wow.boot()
		ns.Data.SetGroups({
			{
				key = "ANIMAL_PARTS",
				entries = {
					{ itemID = 10, count = 5, quests = { 1 } },
					{ itemID = 10, count = 3, quests = { 2 } },
				},
			},
		})
		_G.C_Item.GetItemCount = function()
			return 2
		end
	end)
	after_each(function()
		wow.restore()
	end)

	local function pink(line)
		assert.same({ 1.0, 0.4, 0.8 }, { line.r, line.g, line.b })
	end

	it("adds the notice and need/have in pink for a turn-in item", function()
		local tt = wow.fake_tooltip()
		ns.Tooltip.Append(tt, 10)
		assert.equals(2, #tt.lines)
		assert.equals("Darkmoon Faire quest item", tt.lines[1].text)
		assert.equals("Turn in 3 - you have 2", tt.lines[2].text)
		pink(tt.lines[1])
		pink(tt.lines[2])
		assert.equals(0, #tt.doubles)
	end)

	it("adds nothing for other items and nil", function()
		local tt = wow.fake_tooltip()
		ns.Tooltip.Append(tt, 99)
		ns.Tooltip.Append(tt, nil)
		assert.equals(0, #tt.lines)
	end)

	it("adds other characters when present", function()
		ns.Counts.GetOthers = function()
			return { { name = "Amy", count = 6 }, { more = 2 } }
		end
		local tt = wow.fake_tooltip()
		ns.Tooltip.Append(tt, 10)
		assert.equals("Other characters:", tt.lines[3].text)
		assert.equals("Amy", tt.doubles[1].left)
		assert.equals(6, tt.doubles[1].right)
		assert.equals("+2 more", tt.lines[4].text)
	end)

	describe("deDE", function()
		wow.pin_locale("deDE", before_each, after_each)
		it("uses the locale text", function()
			local de = wow.boot()
			de.Data.SetGroups(ns.Data.groups)
			local tt = wow.fake_tooltip()
			de.Tooltip.Append(tt, 10)
			assert.equals(de.locales.deDE.NOTICE, tt.lines[1].text)
		end)
	end)

	describe("Install", function()
		it("registers one callback and filters tooltips", function()
			local callbacks = {}
			_G.TooltipDataProcessor = {
				AddTooltipPostCall = function(kind, fn)
					callbacks[#callbacks + 1] = { kind = kind, fn = fn }
				end,
			}
			_G.GameTooltip = wow.fake_tooltip()
			_G.ItemRefTooltip = wow.fake_tooltip()
			local other = wow.fake_tooltip()
			assert.is_true(ns.Tooltip.Install())
			assert.equals(1, #callbacks)
			assert.equals(0, callbacks[1].kind)
			callbacks[1].fn(other, { id = 10 })
			assert.equals(0, #other.lines)
			callbacks[1].fn(_G.GameTooltip, nil)
			callbacks[1].fn(_G.GameTooltip, {})
			assert.equals(0, #_G.GameTooltip.lines)
			callbacks[1].fn(_G.GameTooltip, { id = 10 })
			callbacks[1].fn(_G.ItemRefTooltip, { id = 10 })
			assert.equals(2, #_G.GameTooltip.lines)
			assert.equals(2, #_G.ItemRefTooltip.lines)
		end)

		it("reports a raising Append one time", function()
			local fn
			_G.TooltipDataProcessor = {
				AddTooltipPostCall = function(_, f)
					fn = f
				end,
			}
			_G.GameTooltip = {
				AddLine = function()
					error("boom")
				end,
			}
			ns.Tooltip.Install()
			fn(_G.GameTooltip, { id = 10 })
			fn(_G.GameTooltip, { id = 10 })
			assert.equals(1, #_G.DEFAULT_CHAT_FRAME.lines)
		end)

		it("reports one time without TooltipDataProcessor", function()
			_G.TooltipDataProcessor = nil
			assert.is_false(ns.Tooltip.Install())
			assert.is_false(ns.Tooltip.Install())
			assert.equals(1, #_G.DEFAULT_CHAT_FRAME.lines)
		end)
	end)

	it("runs startup functions on PLAYER_LOGIN and isolates failures", function()
		ns.startup = {}
		local ran = 0
		table.insert(ns.startup, function()
			error("x")
		end)
		table.insert(ns.startup, function()
			ran = ran + 1
		end)
		ns.events.scripts.OnEvent(ns.events, "PLAYER_LOGIN")
		assert.equals(1, ran)
		assert.equals(1, #_G.DEFAULT_CHAT_FRAME.lines)
	end)
end)
