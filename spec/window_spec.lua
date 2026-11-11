local wow = require("spec.helpers.wow")

local FIXTURE = {
	{
		key = "ANIMAL_PARTS",
		entries = {
			{ itemID = 10, count = 5, quests = { 1 } },
			{ itemID = 11, count = 2, quests = { 2 } },
		},
	},
	{ key = "BLACKSMITHING", entries = {} },
	{ key = "ENGINEERING", entries = { { itemID = 12, count = 3, quests = { 3 } } } },
}

describe("Window", function()
	local ns, have
	before_each(function()
		ns = wow.boot()
		ns.Data.SetGroups(FIXTURE)
		have = {}
		_G.C_Item.GetItemCount = function(id)
			return have[id] or 0
		end
		ns.Window.Reset()
	end)
	after_each(function()
		wow.restore()
	end)

	describe("BuildModel", function()
		it("orders groups, omits empty groups, and counts ready", function()
			have[10], have[11], have[12] = 4, 2, 0
			local model = ns.Window.BuildModel()
			assert.equals(2, #model.groups)
			assert.equals("ANIMAL_PARTS", model.groups[1].key)
			assert.equals("Animal parts", model.groups[1].title)
			assert.equals("ENGINEERING", model.groups[2].key)
			assert.equals(1, model.ready)
			assert.equals(3, model.total)
		end)

		it("sets the state at 0, need - 1, and need", function()
			have[10], have[11], have[12] = 0, 1, 3
			local model = ns.Window.BuildModel()
			assert.equals("empty", model.groups[1].rows[1].state)
			assert.equals("partial", model.groups[1].rows[2].state)
			assert.equals("complete", model.groups[2].rows[1].state)
			have[10] = 4
			assert.equals("partial", ns.Window.BuildModel().groups[1].rows[1].state)
			have[10] = 5
			assert.equals("complete", ns.Window.BuildModel().groups[1].rows[1].state)
		end)

		for _, locale in ipairs({ "enUS", "deDE", "esES", "esMX", "frFR", "itIT", "ptBR" }) do
			describe(locale, function()
				wow.pin_locale(locale, before_each, after_each)
				it("takes group titles from the locale", function()
					local n = wow.boot()
					n.Data.SetGroups(FIXTURE)
					_G.C_Item.GetItemCount = function()
						return 0
					end
					assert.equals(n.locales[locale].GROUP_ANIMAL_PARTS, n.Window.BuildModel().groups[1].title)
				end)
			end)
		end
	end)

	describe("ItemName", function()
		it("returns the name, or a placeholder and a load request", function()
			_G.C_Item.GetItemInfo = function(id)
				return id == 10 and "Paw" or nil
			end
			local requested
			_G.C_Item.RequestLoadItemDataByID = function(id)
				requested = id
			end
			assert.equals("Paw", ns.Window.ItemName(10))
			assert.equals("...", ns.Window.ItemName(11))
			assert.equals(11, requested)
		end)

		it("returns the placeholder without any item API", function()
			_G.C_Item = nil
			assert.equals("...", ns.Window.ItemName(10))
		end)
	end)

	describe("Create", function()
		it("retries with BasicFrameTemplateWithInset", function()
			local templates = {}
			local original = _G.CreateFrame
			_G.CreateFrame = function(kind, name, parent, template)
				if name == "DarkmoonTurnInsFrame" then
					templates[#templates + 1] = template
					if template == "ButtonFrameTemplate" then
						error("missing template")
					end
				end
				return original(kind, name, parent, template)
			end
			ns.Window.Create()
			assert.same({ "ButtonFrameTemplate", "BasicFrameTemplateWithInset" }, templates)
		end)

		it("adds the name to UISpecialFrames once", function()
			ns.Window.Create()
			ns.Window.Create()
			local count = 0
			for _, name in ipairs(_G.UISpecialFrames) do
				if name == "DarkmoonTurnInsFrame" then
					count = count + 1
				end
			end
			assert.equals(1, count)
		end)

		it("survives an unknown event name", function()
			local original = _G.CreateFrame
			_G.CreateFrame = function(...)
				local created = original(...)
				created.RegisterEvent = function(_, event)
					if event == "PLAYERBANKSLOTS_CHANGED" then
						error("unknown event")
					end
				end
				return created
			end
			assert.has_no.errors(function()
				ns.Window.Create()
			end)
		end)
	end)

	describe("Refresh and Toggle", function()
		it("does nothing while the window is hidden", function()
			assert.is_false(ns.Window.Refresh())
			ns.Window.Create()
			assert.is_false(ns.Window.Refresh())
		end)

		it("toggles the shown state", function()
			ns.Window.Toggle()
			assert.is_true(_G.DarkmoonTurnInsFrame:IsShown())
			ns.Window.Toggle()
			assert.is_false(_G.DarkmoonTurnInsFrame:IsShown())
		end)
	end)

	describe("slash", function()
		it("toggles on an empty argument", function()
			ns.Window.HandleSlash("")
			assert.is_true(_G.DarkmoonTurnInsFrame:IsShown())
			ns.Window.HandleSlash(nil)
			assert.is_false(_G.DarkmoonTurnInsFrame:IsShown())
		end)

		it("flips the minimap flag for padded and upper-case input", function()
			_G.DarkmoonTurnInsDB = { minimap = { hide = false } }
			local calls = {}
			ns.Minimap.icon = {
				Hide = function()
					calls[#calls + 1] = "Hide"
				end,
				Show = function()
					calls[#calls + 1] = "Show"
				end,
			}
			ns.Window.HandleSlash("minimap")
			assert.is_true(_G.DarkmoonTurnInsDB.minimap.hide)
			ns.Window.HandleSlash("  MINIMAP ")
			assert.is_false(_G.DarkmoonTurnInsDB.minimap.hide)
			assert.same({ "Hide", "Show" }, calls)
		end)

		it("prints help for other input", function()
			ns.Window.HandleSlash("help")
			assert.is_truthy(_G.DEFAULT_CHAT_FRAME.lines[1]:find("/dmft", 1, true))
		end)

		it("registers the slash command", function()
			assert.equals("/dmft", _G.SLASH_DARKMOONTURNINS1)
			assert.equals(ns.Window.HandleSlash, _G.SlashCmdList.DARKMOONTURNINS)
		end)
	end)
end)
