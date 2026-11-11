local _, ns = ...

ns.Glow = {}
local Glow = ns.Glow

local GLOW_TEXTURE = "Interface\\Buttons\\UI-ActionButton-Border"
local GLOW_SCALE = 1.8
local glows = setmetatable({}, { __mode = "k" })
local frames = {}

function Glow.ItemIDFrom(itemIDOrLink)
	if type(itemIDOrLink) == "number" then
		return itemIDOrLink
	end
	if type(itemIDOrLink) == "string" then
		local id = itemIDOrLink:match("item:(%d+)")
		return id and tonumber(id) or nil
	end
	return nil
end

local function createGlow(button)
	local texture = button:CreateTexture(nil, "OVERLAY")
	local pink = ns.PINK
	texture:SetTexture(GLOW_TEXTURE)
	texture:SetBlendMode("ADD")
	texture:SetVertexColor(pink.r, pink.g, pink.b, 0.8)
	texture:SetPoint("CENTER", button, "CENTER", 0, 0)
	local size = (button.GetWidth and button:GetWidth() or 37) * GLOW_SCALE
	texture:SetSize(size, size)
	return texture
end

function Glow.Update(button, itemID)
	if not button then
		return
	end
	local glow = glows[button]
	if ns.Data.IsTurnInItem(itemID) then
		if not glow then
			glow = createGlow(button)
			glows[button] = glow
		end
		glow:Show()
		if button.IconBorder then
			button.IconBorder:SetAlpha(0)
		end
	elseif glow then
		glow:Hide()
		if button.IconBorder then
			button.IconBorder:SetAlpha(1)
		end
	end
end

local function bagItemID(frame, button)
	local bag = button.GetBagID and button:GetBagID() or button.bagID or (frame.GetID and frame:GetID())
	local slot = button.GetID and button:GetID()
	if not bag or not slot or not C_Container or not C_Container.GetContainerItemID then
		return nil
	end
	return C_Container.GetContainerItemID(bag, slot)
end

local function eachButton(frame, fn)
	if frame.EnumerateValidItems then
		for _, button in frame:EnumerateValidItems() do
			fn(button)
		end
	elseif frame.Items then
		for _, button in ipairs(frame.Items) do
			fn(button)
		end
	else
		local name = frame.GetName and frame:GetName()
		for i = 1, 40 do
			local button = name and _G[name .. "Item" .. i]
			if button then
				fn(button)
			end
		end
	end
end

function Glow.RefreshBagFrame(frame)
	eachButton(frame, function(button)
		Glow.Update(button, bagItemID(frame, button))
	end)
end

function Glow.RefreshAll()
	for _, frame in ipairs(frames) do
		if not frame.IsShown or frame:IsShown() then
			Glow.RefreshBagFrame(frame)
		end
	end
end

local function hookFrame(frame)
	if not frame or not frame.Update then
		return false
	end
	frames[#frames + 1] = frame
	hooksecurefunc(frame, "Update", function()
		Glow.RefreshBagFrame(frame)
	end)
	return true
end

function Glow.Install()
	local function step(key, fn)
		if not pcall(fn) then
			ns.ReportOnce("glow-" .. key, ns.L.HOOK_FAILED)
		end
	end

	step("global", function()
		hooksecurefunc("SetItemButtonQuality", function(button, _, itemIDOrLink)
			Glow.Update(button, Glow.ItemIDFrom(itemIDOrLink))
		end)
	end)

	step("combined", function()
		hookFrame(_G.ContainerFrameCombinedBags)
	end)

	step("bags", function()
		for i = 1, _G.NUM_CONTAINER_FRAMES or 13 do
			hookFrame(_G["ContainerFrame" .. i])
		end
	end)

	step("mail", function()
		hooksecurefunc("InboxFrame_Update", function()
			for i = 1, _G.INBOXITEMS_TO_DISPLAY or 7 do
				local button = _G["MailItem" .. i .. "Button"]
				if button and not button.hasItem then
					Glow.Update(button, nil)
				end
			end
		end)
	end)

	step("events", function()
		ns.events:RegisterEvent("BAG_UPDATE_DELAYED")
	end)
end

function Glow.OnEvent(event)
	if event == "BAG_UPDATE_DELAYED" then
		Glow.RefreshAll()
	end
end

table.insert(ns.startup, Glow.Install)
