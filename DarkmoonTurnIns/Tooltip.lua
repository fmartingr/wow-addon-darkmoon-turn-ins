local _, ns = ...

ns.Tooltip = {}
local Tooltip = ns.Tooltip

local function pinkLine(tooltip, text)
	local pink = ns.PINK
	tooltip:AddLine(text, pink.r, pink.g, pink.b)
end

function Tooltip.Append(tooltip, itemID)
	if not ns.Data.IsTurnInItem(itemID) then
		return
	end
	local L = ns.L
	local pink = ns.PINK
	pinkLine(tooltip, L.NOTICE)
	pinkLine(tooltip, string.format(L.NEED_HAVE, ns.Data.GetNeed(itemID), ns.Counts.GetOwned(itemID)))
	local others = ns.Counts.GetOthers(itemID)
	if #others == 0 then
		return
	end
	pinkLine(tooltip, L.OTHER_CHARACTERS .. ":")
	for _, other in ipairs(others) do
		if other.more then
			tooltip:AddLine(string.format(L.MORE_OTHERS, other.more), 1, 1, 1)
		else
			tooltip:AddDoubleLine(other.name, other.count, 1, 1, 1, pink.r, pink.g, pink.b)
		end
	end
end

function Tooltip.Install()
	local L = ns.L
	if
		not (
			TooltipDataProcessor
			and TooltipDataProcessor.AddTooltipPostCall
			and Enum
			and Enum.TooltipDataType
			and Enum.TooltipDataType.Item
		)
	then
		ns.ReportOnce("tooltip-api", L.HOOK_FAILED)
		return false
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
		if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then
			return
		end
		if type(data) ~= "table" or type(data.id) ~= "number" then
			return
		end
		local ok, err = pcall(Tooltip.Append, tooltip, data.id)
		if not ok then
			ns.ReportOnce("tooltip", L.HOOK_FAILED, err)
		end
	end)
	return true
end
table.insert(ns.startup, ns.Tooltip.Install)
