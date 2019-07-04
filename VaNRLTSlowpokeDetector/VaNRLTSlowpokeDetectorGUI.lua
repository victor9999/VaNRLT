local VaNRLTSlowpokeDetectorGUI
local _gui
local ac
local asd
local asdgui

local function Init()
	local _gui = VaNRLT:GetModule("GUI", true)
	if _gui then
		local VaNRLTSlowpokeDetectorGUI = _gui:NewModule("SlowpokeDetectorGUI", {OnInitialize = "OnInitialize"}, "AceConsole-3.0")
		ac = VaNRLT
		asd = VaNRLT:GetModule("SlowpokeDetector")
		asdgui = VaNRLTSlowpokeDetectorGUI
		local options = {
			type = "group",
			name = "Детектор слакеров",
			args = {
				enable = {
					type = "toggle",
					name = "Включить отслеживание слакеров",
					desc = "Отображает членов рейда которые \'слакают\'",
					get = function(arg) return ac.db.global.SlowpokeDetector.Enabled end,
					set = function(arg, val) ac.db.global.SlowpokeDetector.Enabled = val end,
					order = 1,
				},
				bosses = {
					type = "group",
					name = "Цитадель ледяной короны",
					order = 2,
					args = {
						sindragosa = {
							type = "toggle",
							name = "Синдрагоса",
							desc = "Отображение взрывов освобожденной магии",
							get = function(arg) return ac.db.global.SlowpokeDetector.Sindragosa end,
							set = function(arg, val) ac.db.global.SlowpokeDetector.Sindragosa = val end,
							order = 1,
						},
						prof = {
							type = "toggle",
							name = "Профессор мерзоцид",
							desc = "Отображение тех кто поймал вязкую гадость и удушливый газ",
							get = function(arg) return ac.db.global.SlowpokeDetector.Prof end,
							set = function(arg, val) ac.db.global.SlowpokeDetector.Prof = val end,
							order = 2,
						},
						festergut = {
							type = "toggle",
							name = "Тухлопуз",
							desc = "Отображение тех кто поймал вязкую гадость",
							get = function(arg) return ac.db.global.SlowpokeDetector.Festergut end,
							set = function(arg, val) ac.db.global.SlowpokeDetector.Festergut = val end,
							order = 3,
						},
						h0 = {
							type = "header",
							name = "",
							order = 19,
						},
						prince = {
							type = "range",
							name = "Кровавый совет",
							desc = "Отображение тех кто набрал много стаков от передвижения(укажите количество стаков для отображения, 0 - отключить)",
							get = function(arg) return ac.db.global.SlowpokeDetector.Prince end,
							set = function(arg, val) ac.db.global.SlowpokeDetector.Prince = val end,
							order = 20,
							min = 0,
							max = 20,
							step = 1,
						},
						SindragosaMS = {
							type = "range",
							name = "Синдрагоса(стаки обморожения)",
							desc = "Отображение тех кто набрал много стаков от обморожения(укажите количество стаков для отображения, 0 - отключить)",
							get = function(arg) return ac.db.global.SlowpokeDetector.SindragosaMS end,
							set = function(arg, val) ac.db.global.SlowpokeDetector.SindragosaMS = val end,
							order = 21,
							min = 0,
							max = 20,
							step = 1,
						},
						SindragosaRS = {
							type = "range",
							name = "Синдрагоса(стаки освобожденной магии)",
							desc = "Отображение тех кто набрал много стаков от Освобожденной магии(укажите количество стаков для отображения, 0 - отключить)",
							get = function(arg) return ac.db.global.SlowpokeDetector.SindragosaRS end,
							set = function(arg, val) ac.db.global.SlowpokeDetector.SindragosaRS = val end,
							order = 22,
							min = 0,
							max = 20,
							step = 1,
						},
						ProfRed = {
							type = "toggle",
							name = "Красный слизень",
							desc = "Отображение тех кого выбрал красный слизень",
							get = function(arg) return ac.db.global.SlowpokeDetector.ProfRed end,
							set = function(arg, val) ac.db.global.SlowpokeDetector.ProfRed = val end,
							order = 4,
						},
						Autolink = {
							type = "toggle",
							name = "Автоматический отчет",
							desc = "Автоматическое отображение статистики в конце боя",
							get = function(arg) return ac.db.global.SlowpokeDetector.Autolink end,
							set = function(arg, val) ac.db.global.SlowpokeDetector.Autolink = val end,
							order = 0,
						},
					},
				}
			},
		}
		table.insert(_gui.ModulesOptions, options)
		
		function VaNRLTSlowpokeDetectorGUI:OnInitialize()
			asdgui:Print("Initialized")
		end
		
		function VaNRLTSlowpokeDetectorGUI:ResetSettings()
		
		end
	end
end

Init()

local function OnAddonLoaded(event, addon)
	if addon=="VaNRLTGUI" then Init() end
end

local event = LibStub("AceEvent-3.0"):RegisterEvent("ADDON_LOADED", OnAddonLoaded)