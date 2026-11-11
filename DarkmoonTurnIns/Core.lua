local ADDON_NAME, ns = ...

ns.PINK = { r = 1.0, g = 0.4, b = 0.8 }
ns.PINK_HEX = "ffff66cc"

local DEFAULTS = { minimap = { hide = false } }
local reported = {}

local function fillDefaults(target, defaults)
	for key, value in pairs(defaults) do
		if type(value) == "table" then
			if type(target[key]) ~= "table" then
				target[key] = {}
			end
			fillDefaults(target[key], value)
		elseif target[key] == nil then
			target[key] = value
		end
	end
end

function ns.Print(msg)
	local text = string.format("|c%s%s|r: %s", ns.PINK_HEX, ADDON_NAME, tostring(msg))
	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(text)
	end
end

function ns.ReportOnce(key, msg)
	if reported[key] then
		return false
	end
	reported[key] = true
	ns.Print(msg)
	return true
end

function ns.InitDB()
	if type(DarkmoonTurnInsDB) ~= "table" then
		DarkmoonTurnInsDB = {}
	end
	fillDefaults(DarkmoonTurnInsDB, DEFAULTS)
end

ns.events = CreateFrame("Frame")
ns.events:RegisterEvent("ADDON_LOADED")
ns.events:RegisterEvent("PLAYER_LOGIN")
ns.events:SetScript("OnEvent", function(_, event, name)
	if event == "ADDON_LOADED" and name == ADDON_NAME then
		ns.InitDB()
	elseif event == "PLAYER_LOGIN" then
		ns.OnLogin()
	elseif ns.Glow then
		ns.Glow.OnEvent(event)
	end
end)

ns.startup = {}

function ns.OnLogin()
	for _, fn in ipairs(ns.startup) do
		local ok = pcall(fn)
		if not ok then
			ns.ReportOnce("startup", ns.L.HOOK_FAILED)
		end
	end
end
