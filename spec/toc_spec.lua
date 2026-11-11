local wow = require("spec.helpers.wow")

local function listLuaFiles()
	local p = io.popen("ls DarkmoonTurnIns/*.lua")
	local files = {}
	for line in p:lines() do
		files[#files + 1] = line:gsub("^DarkmoonTurnIns/", "")
	end
	p:close()
	return files
end

local function exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
	end
	return f ~= nil
end

describe("TOC", function()
	local toc
	setup(function()
		local f = assert(io.open("DarkmoonTurnIns/DarkmoonTurnIns.toc", "r"))
		toc = f:read("*a")
		f:close()
	end)

	it("targets Forever", function()
		assert.is_truthy(toc:find("## Interface: 16001", 1, true))
		assert.is_truthy(toc:find("## AllowLoadGameType: camelot", 1, true))
	end)

	it("lists only files that exist", function()
		for _, name in ipairs(wow.readToc()) do
			assert.is_true(exists("DarkmoonTurnIns/" .. name), name)
		end
	end)

	it("lists every addon Lua file", function()
		local listed = {}
		for _, name in ipairs(wow.readToc()) do
			listed[name] = true
		end
		for _, name in ipairs(listLuaFiles()) do
			assert.is_true(listed[name] == true, name)
		end
	end)
end)

describe("Core", function()
	after_each(function()
		wow.restore()
	end)

	it("loads and keeps the pink hex equal to the pink RGB", function()
		local ns = wow.boot()
		local c = ns.PINK
		local hex = string.format(
			"ff%02x%02x%02x",
			math.floor(c.r * 255 + 0.5),
			math.floor(c.g * 255 + 0.5),
			math.floor(c.b * 255 + 0.5)
		)
		assert.equals(hex, ns.PINK_HEX)
	end)

	it("fills the saved variable defaults", function()
		local ns = wow.boot()
		_G.DarkmoonTurnInsDB = { minimap = { minimapPos = 10 } }
		ns.InitDB()
		assert.is_false(_G.DarkmoonTurnInsDB.minimap.hide)
		assert.equals(10, _G.DarkmoonTurnInsDB.minimap.minimapPos)
		_G.DarkmoonTurnInsDB = nil
		ns.InitDB()
		assert.is_false(_G.DarkmoonTurnInsDB.minimap.hide)
	end)

	it("runs InitDB on ADDON_LOADED for this addon only", function()
		local ns = wow.boot()
		_G.DarkmoonTurnInsDB = nil
		ns.events.scripts.OnEvent(ns.events, "ADDON_LOADED", "Other")
		assert.is_nil(_G.DarkmoonTurnInsDB)
		ns.events.scripts.OnEvent(ns.events, "ADDON_LOADED", "DarkmoonTurnIns")
		assert.is_table(_G.DarkmoonTurnInsDB)
	end)

	it("reports a key one time", function()
		local ns = wow.boot()
		assert.is_true(ns.ReportOnce("k", "msg"))
		assert.is_false(ns.ReportOnce("k", "msg"))
		assert.equals(1, #_G.DEFAULT_CHAT_FRAME.lines)
		assert.is_truthy(_G.DEFAULT_CHAT_FRAME.lines[1]:find("DarkmoonTurnIns", 1, true))
	end)
end)

describe("Version", function()
	it("matches the top CHANGELOG heading", function()
		local f = assert(io.open("DarkmoonTurnIns/DarkmoonTurnIns.toc", "r"))
		local version = f:read("*a"):match("## Version: ([^\r\n]+)")
		f:close()
		local c = assert(io.open("CHANGELOG.md", "r"))
		local heading = c:read("*a"):match("## ([%d%.]+)")
		c:close()
		assert.equals(version, heading)
	end)
end)
