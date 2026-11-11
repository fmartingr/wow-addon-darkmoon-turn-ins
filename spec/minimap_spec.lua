local wow = require("spec.helpers.wow")

describe("Minimap", function()
	local ns, registered, icon
	before_each(function()
		ns = wow.boot()
		registered = {}
		icon = {
			Register = function(_, name, object, db)
				registered.icon = { name = name, object = object, db = db }
			end,
		}
		local ldb = {
			NewDataObject = function(_, name, object)
				registered.object = { name = name, object = object }
				return object
			end,
		}
		_G.LibStub = function(name)
			return name == "LibDataBroker-1.1" and ldb or icon
		end
		_G.DarkmoonTurnInsDB = { minimap = { hide = false } }
	end)
	after_each(function()
		wow.restore()
	end)

	it("registers one data object and the icon with the saved settings", function()
		assert.is_true(ns.Minimap.Register())
		assert.equals("DarkmoonTurnIns", registered.object.name)
		assert.equals("launcher", registered.object.object.type)
		assert.equals(_G.DarkmoonTurnInsDB.minimap, registered.icon.db)
		assert.equals("Interface\\Icons\\INV_Misc_QuestionMark", registered.object.object.icon)
	end)

	it("uses the ticket icon when the client has it", function()
		_G.C_Item.GetItemIconByID = function(id)
			return id == 19182 and 12345 or nil
		end
		ns.Minimap.Register()
		assert.equals(12345, registered.object.object.icon)
	end)

	it("does nothing without the libraries", function()
		_G.LibStub = nil
		assert.is_false(ns.Minimap.Register())
		_G.LibStub = function()
			return nil
		end
		assert.is_false(ns.Minimap.Register())
	end)

	it("opens the window on left-click only", function()
		local toggled = 0
		ns.Window.Toggle = function()
			toggled = toggled + 1
		end
		ns.Minimap.OnClick(nil, "LeftButton")
		ns.Minimap.OnClick(nil, "RightButton")
		assert.equals(1, toggled)
	end)

	it("adds the four tooltip lines", function()
		local tt = wow.fake_tooltip()
		ns.Minimap.OnTooltipShow(tt)
		assert.equals(4, #tt.lines)
		assert.equals("Darkmoon Turn-ins", tt.lines[1].text)
		assert.is_truthy(tt.lines[2].text:find("turn-ins ready", 1, true))
	end)

	it("toggle works without a registered icon", function()
		ns.Minimap.icon = nil
		assert.has_no.errors(function()
			ns.Minimap.Toggle()
		end)
		assert.is_true(_G.DarkmoonTurnInsDB.minimap.hide)
	end)
end)
