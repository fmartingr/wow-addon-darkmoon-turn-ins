local _, ns = ...

ns.Counts = {}
local Counts = ns.Counts

local MAX_OTHERS = 10
local FIELDS = { "bags", "bank", "mail", "equipped", "void", "auctions" }

function Counts.GetOwned(itemID)
	local count
	if C_Item and C_Item.GetItemCount then
		count = C_Item.GetItemCount(itemID, true)
	elseif GetItemCount then
		count = GetItemCount(itemID, true)
	end
	return count or 0
end

function Counts.Status(entry)
	local have = Counts.GetOwned(entry.itemID)
	local need = entry.count
	return { have = have, need = need, ready = have >= need, missing = math.max(0, need - have) }
end

function Counts.Summary()
	local ready = 0
	for _, entry in ipairs(ns.Data.entries) do
		if Counts.Status(entry).ready then
			ready = ready + 1
		end
	end
	return { ready = ready, total = #ns.Data.entries }
end

local function fullName(info)
	local name = info.character
	if name and info.realmNormalized and info.realmNormalized ~= "" then
		return name .. "-" .. info.realmNormalized
	end
	return name
end

local function sum(info)
	local total = 0
	for _, field in ipairs(FIELDS) do
		total = total + (tonumber(info[field]) or 0)
	end
	return total
end

local function query(itemID)
	local current = Syndicator.API.GetCurrentCharacter and Syndicator.API.GetCurrentCharacter()
	local info = Syndicator.API.GetInventoryInfoByItemID(itemID, false, false)
	return current, info
end

--- Returns { { name, count }, ... }. A final { more = n } entry marks a cut list.
function Counts.GetOthers(itemID)
	local others = {}
	if type(Syndicator) ~= "table" or type(Syndicator.API) ~= "table" then
		return others
	end
	if not Syndicator.API.GetInventoryInfoByItemID then
		return others
	end
	local ok, current, info = pcall(query, itemID)
	if not ok then
		ns.ReportOnce("syndicator", ns.L.HOOK_FAILED, current)
		return others
	end
	if type(info) ~= "table" or type(info.characters) ~= "table" then
		return others
	end
	for _, character in ipairs(info.characters) do
		local name = fullName(character)
		local count = sum(character)
		if name and count > 0 and name ~= current then
			others[#others + 1] = { name = character.character or name, count = count }
		end
	end
	table.sort(others, function(a, b)
		if a.count ~= b.count then
			return a.count > b.count
		end
		return a.name < b.name
	end)
	if #others > MAX_OTHERS then
		local extra = #others - MAX_OTHERS
		for i = #others, MAX_OTHERS + 1, -1 do
			others[i] = nil
		end
		others[#others + 1] = { more = extra }
	end
	return others
end
