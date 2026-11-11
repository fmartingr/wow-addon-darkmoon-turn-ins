local _, ns = ...

ns.Baganator = {}
local Module = ns.Baganator

local MARKER_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local MARKER_SIZE = 12

function Module.ItemIDOf(details)
	if type(details) ~= "table" then
		return nil
	end
	if type(details.itemID) == "number" then
		return details.itemID
	end
	return ns.Glow.ItemIDFrom(details.itemLink)
end

function Module.Register()
	if type(Baganator) ~= "table" or type(Baganator.API) ~= "table" or not Baganator.API.RegisterCornerWidget then
		return false
	end
	local ok, err = pcall(function()
		Baganator.API.RegisterCornerWidget(ns.L.WINDOW_TITLE, "darkmoonturnins", function(_, details)
			return ns.Data.IsTurnInItem(Module.ItemIDOf(details))
		end, function(itemButton)
			local marker = itemButton:CreateTexture(nil, "OVERLAY")
			marker:SetTexture(MARKER_TEXTURE)
			marker:SetVertexColor(ns.PINK.r, ns.PINK.g, ns.PINK.b, 1)
			marker:SetSize(MARKER_SIZE, MARKER_SIZE)
			return marker
		end, { corner = "top_left", priority = 1 }, true)
	end)
	if not ok then
		ns.ReportOnce("baganator", ns.L.HOOK_FAILED, err)
	end
	return ok
end

table.insert(ns.startup, Module.Register)
