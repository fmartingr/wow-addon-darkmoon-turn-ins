local M = {}

local ADDON_NAME = "DarkmoonTurnIns"
local ADDON_DIR = "DarkmoonTurnIns/"

local function newFrame(name)
	local frame = { name = name, calls = {}, scripts = {}, events = {}, shown = false, children = {} }
	local mt = {}
	mt.__index = function(_, key)
		if key == "GetName" then
			return function(self)
				return self.name
			end
		end
		local known = { Show = true, Hide = true, IsShown = true, GetWidth = true, GetHeight = true, GetAlpha = true }
		local prefixes = { "Set", "Register", "Unregister", "Create", "Enable", "Clear", "Add" }
		local isMethod = known[key]
		for _, prefix in ipairs(prefixes) do
			if type(key) == "string" and key:sub(1, #prefix) == prefix then
				isMethod = true
			end
		end
		if not isMethod then
			return nil
		end
		return function(self, ...)
			self.calls[#self.calls + 1] = { key, ... }
			if key == "SetScript" then
				local event, fn = ...
				self.scripts[event] = fn
			elseif key == "RegisterEvent" then
				self.events[(...)] = true
			elseif key == "UnregisterEvent" then
				self.events[(...)] = nil
			elseif key == "Show" then
				self.shown = true
			elseif key == "Hide" then
				self.shown = false
			elseif key == "IsShown" then
				return self.shown
			elseif key == "CreateTexture" or key == "CreateFontString" then
				local child = newFrame()
				self.children[#self.children + 1] = child
				return child
			elseif key == "GetAlpha" then
				return self.alpha or 1
			elseif key == "SetAlpha" then
				self.alpha = (...)
			elseif key == "GetWidth" or key == "GetHeight" then
				return 37
			end
			return nil
		end
	end
	return setmetatable(frame, mt)
end

M.newFrame = newFrame

function M.readToc()
	local files = {}
	local file = assert(io.open(ADDON_DIR .. ADDON_NAME .. ".toc", "r"))
	for line in file:lines() do
		line = line:gsub("\r", "")
		if line ~= "" and not line:match("^#") then
			files[#files + 1] = line
		end
	end
	file:close()
	return files
end

local saved

local function snapshot()
	saved = {}
	for k, v in pairs(_G) do
		saved[k] = v
	end
end

function M.restore()
	if not saved then
		return
	end
	for k in pairs(_G) do
		if saved[k] == nil then
			_G[k] = nil
		end
	end
	for k, v in pairs(saved) do
		_G[k] = v
	end
end

function M.installStubs()
	_G.CreateFrame = function(_, name)
		local frame = newFrame(name)
		if name then
			_G[name] = frame
		end
		return frame
	end
	_G.GetLocale = function()
		return M.locale or "enUS"
	end
	_G.hooksecurefunc = function() end
	_G.Enum = { TooltipDataType = { Item = 0 } }
	_G.C_Item = {}
	_G.UISpecialFrames = {}
	_G.SlashCmdList = {}
	_G.DEFAULT_CHAT_FRAME = {
		lines = {},
		AddMessage = function(self, text)
			self.lines[#self.lines + 1] = text
		end,
	}
end

--- Builds a fresh ns, installs stubs, and loads the TOC Lua files.
--- opts.only: list of file names to load (default: every Lua file in the TOC).
--- opts.stubs: function called after the default stubs are set up.
function M.boot(opts)
	opts = opts or {}
	snapshot()
	M.installStubs()
	if opts.stubs then
		opts.stubs()
	end
	local ns = {}
	local wanted
	if opts.only then
		wanted = {}
		for _, name in ipairs(opts.only) do
			wanted[name] = true
		end
	end
	for _, name in ipairs(M.readToc()) do
		if name:match("%.lua$") and not name:match("^Libs/") and (not wanted or wanted[name]) then
			assert(loadfile(ADDON_DIR .. name))(ADDON_NAME, ns)
		end
	end
	return ns
end

function M.pin_locale(locale, before_each, after_each)
	before_each(function()
		M.locale = locale
	end)
	after_each(function()
		M.locale = nil
	end)
end

function M.fake_tooltip()
	local tt = { lines = {}, doubles = {} }
	function tt:AddLine(text, r, g, b)
		self.lines[#self.lines + 1] = { text = text, r = r, g = g, b = b }
	end
	function tt:AddDoubleLine(left, right, lr, lg, lb, rr, rg, rb)
		self.doubles[#self.doubles + 1] =
			{ left = left, right = right, lr = lr, lg = lg, lb = lb, rr = rr, rg = rg, rb = rb }
	end
	return tt
end

return M
