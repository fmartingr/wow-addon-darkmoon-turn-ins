-- Darkmoon Faire turn-in data, built from public sources.
-- Sources (accessed 2026-11-11):
--   https://www.wowhead.com/classic/quest=<questID> for each quest ID listed below (item ID and count).
--   Questie quest ID list (cross-check only): Database/Corrections/Holidays/quests/DarkmoonFaire.lua
-- Groups are our own sorting by profession or item kind. Wowhead does not label the quests by profession.
local _, ns = ...

ns.Data = {}
local Data = ns.Data

Data.groups = {
	{
		key = "ANIMAL_PARTS",
		entries = {
			{ itemID = 5134, count = 5, quests = { 7899 } },
			{ itemID = 11407, count = 5, quests = { 7900 } },
			{ itemID = 4582, count = 5, quests = { 7901 } },
			{ itemID = 5117, count = 5, quests = { 7902 } },
			{ itemID = 11404, count = 10, quests = { 7903, 7943 } },
			{ itemID = 19933, count = 10, quests = { 8222, 8223 } },
		},
	},
	{
		key = "BLACKSMITHING",
		entries = {
			{ itemID = 3240, count = 10, quests = { 7889 } },
			{ itemID = 3486, count = 7, quests = { 7890 } },
			{ itemID = 3835, count = 3, quests = { 7891 } },
			{ itemID = 7945, count = 1, quests = { 7892 } },
			{ itemID = 12644, count = 8, quests = { 7893, 7939 } },
		},
	},
	{
		key = "ENGINEERING",
		entries = {
			{ itemID = 4363, count = 5, quests = { 7894 } },
			{ itemID = 4375, count = 7, quests = { 7895 } },
			{ itemID = 9313, count = 36, quests = { 7896 } },
			{ itemID = 11590, count = 6, quests = { 7897 } },
			{ itemID = 15994, count = 6, quests = { 7898, 7942 } },
		},
	},
	{
		key = "LEATHERWORKING",
		entries = {
			{ itemID = 2309, count = 3, quests = { 7881 } },
			{ itemID = 2314, count = 3, quests = { 7882 } },
			{ itemID = 5739, count = 3, quests = { 7883 } },
			{ itemID = 8185, count = 1, quests = { 7884 } },
			{ itemID = 15564, count = 8, quests = { 7885, 7941 } },
		},
	},
}

--- Builds the lookups from a group list. Called once at load; tests call it with a fixture.
function Data.SetGroups(groups)
	Data.groups = groups
	Data.byItem = {}
	Data.entries = {}
	for _, group in ipairs(groups) do
		for _, entry in ipairs(group.entries) do
			Data.entries[#Data.entries + 1] = entry
			local list = Data.byItem[entry.itemID]
			if not list then
				list = {}
				Data.byItem[entry.itemID] = list
			end
			list[#list + 1] = entry
		end
	end
end

function Data.IsTurnInItem(itemID)
	if type(itemID) ~= "number" then
		return false
	end
	return Data.byItem[itemID] ~= nil
end

function Data.GetEntries(itemID)
	if type(itemID) ~= "number" then
		return nil
	end
	return Data.byItem[itemID]
end

function Data.GetNeed(itemID)
	local list = Data.GetEntries(itemID)
	if not list then
		return nil
	end
	local need
	for _, entry in ipairs(list) do
		if not need or entry.count < need then
			need = entry.count
		end
	end
	return need
end

function Data.GetGroups()
	return Data.groups
end

Data.SetGroups(Data.groups)
