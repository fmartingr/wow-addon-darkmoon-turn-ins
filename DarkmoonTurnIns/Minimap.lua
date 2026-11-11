local _, ns = ...

ns.Minimap = {}
local Minimap = ns.Minimap

local OBJECT_NAME = "DarkmoonTurnIns"
local TICKET_ITEM_ID = 19182
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

function Minimap.OnTooltipShow(tooltip)
	local L = ns.L
	local summary = ns.Counts.Summary()
	tooltip:AddLine(L.WINDOW_TITLE)
	tooltip:AddLine(string.format(L.SUMMARY_READY, summary.ready, summary.total), 1, 1, 1)
	tooltip:AddLine(L.HINT_LEFT_CLICK, 0.8, 0.8, 0.8)
	tooltip:AddLine(L.HINT_DRAG, 0.8, 0.8, 0.8)
end

function Minimap.OnClick(_, button)
	if button == "LeftButton" then
		ns.Window.Toggle()
	end
end

function Minimap.Register()
	if type(LibStub) ~= "function" and type(LibStub) ~= "table" then
		return false
	end
	local ldb = LibStub("LibDataBroker-1.1", true)
	local icon = LibStub("LibDBIcon-1.0", true)
	if not ldb or not icon then
		return false
	end
	local texture = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(TICKET_ITEM_ID)
	local object = ldb:NewDataObject(OBJECT_NAME, {
		type = "launcher",
		icon = texture or FALLBACK_ICON,
		OnClick = Minimap.OnClick,
		OnTooltipShow = Minimap.OnTooltipShow,
	})
	Minimap.icon = icon
	icon:Register(OBJECT_NAME, object, DarkmoonTurnInsDB.minimap)
	return true
end

function Minimap.Toggle()
	local settings = DarkmoonTurnInsDB.minimap
	settings.hide = not settings.hide
	if Minimap.icon then
		if settings.hide then
			Minimap.icon:Hide(OBJECT_NAME)
		else
			Minimap.icon:Show(OBJECT_NAME)
		end
	end
	ns.Print(settings.hide and ns.L.MINIMAP_HIDDEN or ns.L.MINIMAP_SHOWN)
end

table.insert(ns.startup, Minimap.Register)
