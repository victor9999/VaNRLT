local VaNRLTRaidChecksGUI
local _gui
local ac
local arch
local archgui

local function Init()
	_gui = VaNRLT:GetModule("GUI", true)
	if _gui then
		local VaNRLTRaidChecksGUI = _gui:NewModule("RaidChecksGUI", {OnInitialize = "OnInitialize"}, "AceConsole-3.0")
		ac = VaNRLT
		arch = VaNRLT:GetModule("RaidChecks")
		archgui = VaNRLTRaidChecksGUI
		
		archgui.moptions = {
			type = "group",
			name = "Рейд",
			args = {
				enable = {
					type = "toggle",
					name = "Включить",
					desc = "",
					get = function(arg) return ac.db.global.RaidChecks.Enabled end,
					set = function(arg, val) ac.db.global.RaidChecks.Enabled = val end,
					order = 1,
				},
				he = {
					type = "header",
					name = "Настройки",
					order = 2,
				},
				fish = {
					type = "toggle",
					name = "Отображение рыбы",
					desc = "Отображение поставленного рыбного пира",
					get = function(arg) return ac.db.global.RaidChecks.Fish end,
					set = function(arg, val) ac.db.global.RaidChecks.Fish = val end,
					order = 3,
				},
				fishclick = {
					type = "toggle",
					name = "Отображение 'закликивания' рыбы",
					desc = "Отображение 'закликивания' рыбного пира",
					get = function(arg) return ac.db.global.RaidChecks.FishClick end,
					set = function(arg, val) ac.db.global.RaidChecks.FishClick = val end,
					order = 4,
				},
				portal = {
					type = "toggle",
					name = "Отображение портала призыва",
					desc = "Отображение поставленного портала призыва",
					get = function(arg) return ac.db.global.RaidChecks.Portal end,
					set = function(arg, val) ac.db.global.RaidChecks.Portal = val end,
					order = 5,
				},
			},
		}
		
		table.insert(_gui.ModulesOptions, archgui.moptions)
		
		function VaNRLTRaidChecksGUI:OnInitialize()
			archgui:Print("Initialized")
		end
		
		function VaNRLTRaidChecksGUI:ResetSettings()
			
		end
	end
end

Init()

local function OnAddonLoaded(event, addon)
	if addon=="VaNRLTGUI" then Init() end
end

local event = LibStub("AceEvent-3.0"):RegisterEvent("ADDON_LOADED", OnAddonLoaded)