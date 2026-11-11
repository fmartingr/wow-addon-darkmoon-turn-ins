local wow = require("spec.helpers.wow")

describe("Glow", function()
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

	describe("ItemIDFrom", function()
		it("handles numbers, links, and other values", function()
			assert.equals(10, ns.Glow.ItemIDFrom(10))
			assert.equals(5134, ns.Glow.ItemIDFrom("|cffffffff|Hitem:5134::::|h[Small Furry Paw]|h|r"))
			assert.is_nil(ns.Glow.ItemIDFrom("|Hspell:1|h[x]|h"))
			assert.is_nil(ns.Glow.ItemIDFrom(nil))
			assert.is_nil(ns.Glow.ItemIDFrom({}))
		end)
	end)

	describe("Update", function()
		local function button()
			local b = wow.newFrame()
			b.IconBorder = wow.newFrame()
			return b
		end

		it("shows a pink glow and hides the icon border", function()
			local b = button()
			ns.Glow.Update(b, 10)
			local glow = b.children[1]
			assert.is_true(glow.shown)
			assert.equals(0, b.IconBorder.alpha)
			local color
			for _, call in ipairs(glow.calls) do
				if call[1] == "SetVertexColor" then
					color = { call[2], call[3], call[4] }
				end
			end
			assert.same({ 1.0, 0.4, 0.8 }, color)
		end)

		it("hides the glow and restores the border for other items and nil", function()
			local b = button()
			ns.Glow.Update(b, 10)
			ns.Glow.Update(b, 99)
			assert.is_false(b.children[1].shown)
			assert.equals(1, b.IconBorder.alpha)
			ns.Glow.Update(b, 10)
			ns.Glow.Update(b, nil)
			assert.is_false(b.children[1].shown)
		end)

		it("creates one texture over many calls and ignores a nil button", function()
			local b = button()
			for _ = 1, 100 do
				ns.Glow.Update(b, 10)
			end
			assert.equals(1, #b.children)
			assert.has_no.errors(function()
				ns.Glow.Update(nil, 10)
			end)
		end)

		it("works without IconBorder and for a non-turn-in item without a glow", function()
			local b = wow.newFrame()
			assert.has_no.errors(function()
				ns.Glow.Update(b, 10)
				ns.Glow.Update(b, nil)
			end)
			local c = wow.newFrame()
			ns.Glow.Update(c, 99)
			assert.equals(0, #c.children)
		end)
	end)

	describe("Install", function()
		local hooks, registered
		before_each(function()
			hooks = {}
			registered = {}
			_G.hooksecurefunc = function(target, name, fn)
				if type(target) == "string" then
					hooks[#hooks + 1] = { target = target, fn = name }
				else
					hooks[#hooks + 1] = { target = target, name = name, fn = fn }
				end
			end
			ns.events.RegisterEvent = function(_, event)
				registered[#registered + 1] = event
			end
			_G.NUM_CONTAINER_FRAMES = 3
		end)

		it("hooks the global and existing container frames", function()
			local combined = wow.newFrame()
			combined.Update = function() end
			_G.ContainerFrameCombinedBags = combined
			local one = wow.newFrame("ContainerFrame1")
			one.Update = function() end
			_G.ContainerFrame1 = one
			ns.Glow.Install()
			assert.equals("SetItemButtonQuality", hooks[1].target)
			assert.equals(4, #hooks)
			assert.same({ "BAG_UPDATE_DELAYED" }, registered)
		end)

		it("glows through the global hook", function()
			ns.Glow.Install()
			local b = wow.newFrame()
			hooks[1].fn(b, 1, "|Hitem:10::|h[x]|h")
			assert.is_true(b.children[1].shown)
		end)

		it("glows bag buttons on frame Update and on BAG_UPDATE_DELAYED", function()
			local frame = wow.newFrame("ContainerFrame2")
			frame.Update = function() end
			local b1, b2 = wow.newFrame(), wow.newFrame()
			b1.bagID, b2.bagID = 0, 0
			b1.GetID = function()
				return 1
			end
			b2.GetID = function()
				return 2
			end
			frame.Items = { b1, b2 }
			frame.shown = true
			_G.ContainerFrame2 = frame
			_G.C_Container = {
				GetContainerItemID = function(_, slot)
					return slot == 1 and 10 or nil
				end,
			}
			ns.Glow.Install()
			for _, h in ipairs(hooks) do
				if h.target == frame then
					h.fn()
				end
			end
			assert.is_true(b1.children[1].shown)
			assert.equals(0, #b2.children)
			b1.children[1].shown = false
			ns.events.scripts.OnEvent(ns.events, "BAG_UPDATE_DELAYED")
			assert.is_true(b1.children[1].shown)
		end)

		it("reads buttons by name when the frame has no item list", function()
			local frame = wow.newFrame("ContainerFrame3")
			frame.Update = function() end
			frame.GetID = function()
				return 0
			end
			local b = wow.newFrame()
			b.GetID = function()
				return 4
			end
			_G.ContainerFrame3Item1 = b
			_G.ContainerFrame3 = frame
			_G.C_Container = {
				GetContainerItemID = function(bag, slot)
					return bag == 0 and slot == 4 and 10 or nil
				end,
			}
			ns.Glow.Install()
			ns.Glow.RefreshBagFrame(frame)
			assert.is_true(b.children[1].shown)
		end)

		it("isolates a failing step and reports it once", function()
			_G.hooksecurefunc = function()
				error("boom")
			end
			local frame = wow.newFrame()
			frame.Update = function() end
			_G.ContainerFrameCombinedBags = frame
			ns.Glow.Install()
			assert.is_true(#_G.DEFAULT_CHAT_FRAME.lines >= 1)
			assert.is_true(#registered == 1)
		end)

		it("clears the glow on mail rows without an attachment", function()
			ns.Glow.Install()
			local hook
			for _, h in ipairs(hooks) do
				if h.target == "InboxFrame_Update" then
					hook = h.fn
				end
			end
			assert.is_function(hook)
			local b = wow.newFrame()
			ns.Glow.Update(b, 10)
			_G.MailItem1Button = b
			b.hasItem = true
			hook()
			assert.is_true(b.children[1].shown)
			b.hasItem = nil
			hook()
			assert.is_false(b.children[1].shown)
		end)

		it("ignores other events", function()
			assert.has_no.errors(function()
				ns.Glow.OnEvent("OTHER")
			end)
		end)
	end)
end)
