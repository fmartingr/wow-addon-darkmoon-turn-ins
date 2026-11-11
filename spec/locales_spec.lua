local wow = require("spec.helpers.wow")

local LOCALES = { "enUS", "deDE", "esES", "esMX", "frFR", "itIT", "ptBR" }

local function count(s, pattern)
	return select(2, s:gsub(pattern, ""))
end

describe("Locales", function()
	after_each(function()
		wow.restore()
	end)

	it("gives every locale the key set of enUS", function()
		local ns = wow.boot()
		for _, name in ipairs(LOCALES) do
			for key in pairs(ns.locales.enUS) do
				assert.is_string(ns.locales[name][key], name .. " " .. key)
			end
			for key in pairs(ns.locales[name]) do
				assert.is_string(ns.locales.enUS[key], name .. " extra " .. key)
			end
		end
	end)

	it("keeps format markers and formats without error", function()
		local ns = wow.boot()
		for _, name in ipairs(LOCALES) do
			for _, key in ipairs({ "NEED_HAVE", "SUMMARY_READY" }) do
				local text = ns.locales[name][key]
				assert.equals(count(ns.locales.enUS[key], "%%d"), count(text, "%%d"), name .. key)
				assert.has_no.errors(function()
					string.format(text, 1, 2)
				end)
			end
			assert.equals(1, count(ns.locales[name].MORE_OTHERS, "%%d"))
		end
	end)

	it("has no Cyrillic bytes", function()
		local ns = wow.boot()
		for name, locale in pairs(ns.locales) do
			for key, text in pairs(locale) do
				assert.is_nil(text:find("[\208\209]"), name .. key)
			end
		end
	end)

	for _, name in ipairs(LOCALES) do
		describe(name, function()
			wow.pin_locale(name, before_each, after_each)
			it("returns its own NOTICE", function()
				local ns = wow.boot()
				assert.equals(ns.locales[name].NOTICE, ns.L.NOTICE)
			end)
		end)
	end

	for _, name in ipairs({ "ruRU", "koKR", "enGB" }) do
		describe(name, function()
			wow.pin_locale(name, before_each, after_each)
			it("falls back to enUS", function()
				local ns = wow.boot()
				assert.equals("Darkmoon Faire quest item", ns.L.NOTICE)
			end)
		end)
	end

	it("falls back per key and returns the key when unknown", function()
		local ns = wow.boot()
		assert.equals("NOPE", ns.L.NOPE)
		ns.debug = true
		assert.equals("NOPE", ns.L.NOPE)
		assert.equals("NOPE", ns.L.NOPE)
		assert.equals(1, #_G.DEFAULT_CHAT_FRAME.lines)
	end)
end)
