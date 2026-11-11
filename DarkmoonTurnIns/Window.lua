local _, ns = ...

ns.Window = {}
local Window = ns.Window

local FRAME_NAME = "DarkmoonTurnInsFrame"
local ROW_HEIGHT = 24
local HEADER_HEIGHT = 22
local COLORS = {
	complete = { 0.2, 1.0, 0.2 },
	partial = { 1.0, 0.82, 0.0 },
	empty = { 0.6, 0.6, 0.6 },
}
local EVENTS = {
	"BAG_UPDATE_DELAYED",
	"BANKFRAME_OPENED",
	"PLAYERBANKSLOTS_CHANGED",
	"PLAYERBANKBAGSLOTS_CHANGED",
}

local frame
local headers, rows = {}, {}
local requested = {}

local function stateOf(have, need)
	if have >= need then
		return "complete"
	elseif have > 0 then
		return "partial"
	end
	return "empty"
end

function Window.BuildModel()
	local model = { groups = {}, ready = 0, total = 0 }
	for _, group in ipairs(ns.Data.GetGroups()) do
		if #group.entries > 0 then
			local out = { key = group.key, title = ns.L["GROUP_" .. group.key], rows = {} }
			for _, entry in ipairs(group.entries) do
				local status = ns.Counts.Status(entry)
				out.rows[#out.rows + 1] =
					{ entry = entry, have = status.have, need = status.need, state = stateOf(status.have, status.need) }
				model.total = model.total + 1
				if status.ready then
					model.ready = model.ready + 1
				end
			end
			model.groups[#model.groups + 1] = out
		end
	end
	return model
end

function Window.ItemName(itemID)
	local name = C_Item and C_Item.GetItemInfo and C_Item.GetItemInfo(itemID)
	if not name then
		if not requested[itemID] and C_Item and C_Item.RequestLoadItemDataByID then
			requested[itemID] = true
			C_Item.RequestLoadItemDataByID(itemID)
		end
		return "..."
	end
	return name
end

-- luacov: disable
local function getHeader(content, index)
	local header = headers[index]
	if not header then
		header = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		header:SetJustifyH("LEFT")
		headers[index] = header
	end
	return header
end

local function getRow(content, index)
	local row = rows[index]
	if row then
		return row
	end
	row = CreateFrame("Button", nil, content)
	row:SetSize(300, ROW_HEIGHT)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(20, 20)
	row.icon:SetPoint("LEFT", row, "LEFT", 4, 0)
	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
	row.name:SetWidth(170)
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)
	row.have = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.have:SetPoint("RIGHT", row, "RIGHT", -44, 0)
	row.have:SetWidth(36)
	row.have:SetJustifyH("RIGHT")
	row.need = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.need:SetPoint("RIGHT", row, "RIGHT", -4, 0)
	row.need:SetWidth(36)
	row.need:SetJustifyH("RIGHT")
	row:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetItemByID(self.itemID)
		GameTooltip:Show()
	end)
	row:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	rows[index] = row
	return row
end

local function render()
	local model = Window.BuildModel()
	local content = frame.content
	local y, headerIndex, rowIndex = 0, 0, 0
	for _, group in ipairs(model.groups) do
		headerIndex = headerIndex + 1
		local header = getHeader(content, headerIndex)
		header:ClearAllPoints()
		header:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -y)
		header:SetText(group.title)
		header:Show()
		y = y + HEADER_HEIGHT
		for _, item in ipairs(group.rows) do
			rowIndex = rowIndex + 1
			local row = getRow(content, rowIndex)
			local color = COLORS[item.state]
			row.itemID = item.entry.itemID
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
			row.icon:SetTexture(C_Item.GetItemIconByID(item.entry.itemID))
			row.name:SetText(Window.ItemName(item.entry.itemID))
			row.name:SetTextColor(color[1], color[2], color[3])
			row.have:SetText(item.have)
			row.have:SetTextColor(color[1], color[2], color[3])
			row.need:SetText(item.need)
			row.need:SetTextColor(color[1], color[2], color[3])
			row:Show()
			y = y + ROW_HEIGHT
		end
	end
	for i = headerIndex + 1, #headers do
		headers[i]:Hide()
	end
	for i = rowIndex + 1, #rows do
		rows[i]:Hide()
	end
	content:SetHeight(math.max(y, 1))
	frame.summary:SetText(string.format(ns.L.SUMMARY_READY, model.ready, model.total))
end
-- luacov: enable

local function createFrame()
	local ok, created = pcall(CreateFrame, "Frame", FRAME_NAME, UIParent, "ButtonFrameTemplate")
	if not ok or not created then
		created = CreateFrame("Frame", FRAME_NAME, UIParent, "BasicFrameTemplateWithInset")
	end
	return created
end

local function registerEvents(target)
	for _, event in ipairs(EVENTS) do
		pcall(target.RegisterEvent, target, event)
	end
end

function Window.Create()
	if frame then
		return frame
	end
	frame = createFrame()
	frame:SetSize(360, 480)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	if ButtonFrameTemplate_HidePortrait then
		pcall(ButtonFrameTemplate_HidePortrait, frame)
	end
	if frame.SetTitle then
		frame:SetTitle(ns.L.WINDOW_TITLE)
	elseif frame.TitleText then
		frame.TitleText:SetText(ns.L.WINDOW_TITLE)
	end

	local found = false
	for _, name in ipairs(UISpecialFrames) do
		found = found or name == FRAME_NAME
	end
	if not found then
		table.insert(UISpecialFrames, FRAME_NAME)
	end

	-- luacov: disable
	local scroll = CreateFrame("ScrollFrame", FRAME_NAME .. "Scroll", frame, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -84)
	scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -32, 44)
	frame.content = CreateFrame("Frame", nil, scroll)
	frame.content:SetSize(300, 1)
	scroll:SetScrollChild(frame.content)

	local headerY = -62
	local item = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	item:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, headerY)
	item:SetText(ns.L.COL_ITEM)
	local have = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	have:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -76, headerY)
	have:SetText(ns.L.COL_HAVE)
	local need = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	need:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -36, headerY)
	need:SetText(ns.L.COL_NEED)

	frame.summary = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.summary:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 24)
	local footer = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 10)
	footer:SetText(ns.L.FOOTER_BANK)
	-- luacov: enable

	registerEvents(frame)
	pcall(frame.RegisterEvent, frame, "GET_ITEM_INFO_RECEIVED")
	frame:SetScript("OnEvent", function(_, event, itemID, success)
		if event == "GET_ITEM_INFO_RECEIVED" and not (success and ns.Data.IsTurnInItem(itemID)) then
			return
		end
		Window.Refresh()
	end)
	frame:SetScript("OnShow", function()
		Window.Refresh()
	end)
	frame:Hide()
	return frame
end

function Window.Refresh()
	if not frame or not frame:IsShown() then
		return false
	end
	render()
	return true
end

function Window.Toggle()
	local window = Window.Create()
	if window:IsShown() then
		window:Hide()
	else
		window:Show()
	end
end

function Window.HandleSlash(msg)
	local arg = tostring(msg or ""):lower():match("^%s*(.-)%s*$")
	if arg == "" then
		Window.Toggle()
	elseif arg == "minimap" then
		ns.Minimap.Toggle()
	else
		ns.Print(ns.L.SLASH_HELP)
	end
end

SLASH_DARKMOONTURNINS1 = "/dmft"
SlashCmdList["DARKMOONTURNINS"] = Window.HandleSlash

function Window.Reset()
	frame = nil
	headers, rows = {}, {}
	requested = {}
end
