std = "lua51"
max_line_length = 120
codes = true
exclude_files = { "DarkmoonTurnIns/Libs/", ".lua/", ".luarocks/" }
ignore = { "212/self", "211/_.*", "212/_.*" }

globals = {
	"DarkmoonTurnInsDB",
	"SLASH_DARKMOONTURNINS1",
	"SlashCmdList",
	"UISpecialFrames",
}

read_globals = {
	"Baganator",
	"ButtonFrameTemplate_HidePortrait",
	"C_Container",
	"C_Item",
	"ContainerFrameCombinedBags",
	"CreateFrame",
	"DEFAULT_CHAT_FRAME",
	"Enum",
	"GameTooltip",
	"GetItemCount",
	"GetLocale",
	"ItemRefTooltip",
	"LibStub",
	"INBOXITEMS_TO_DISPLAY",
	"NUM_CONTAINER_FRAMES",
	"Syndicator",
	"TooltipDataProcessor",
	"UIParent",
	"hooksecurefunc",
}
