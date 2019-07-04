local VaNRLTEPGPPenalty = VaNRLT:NewModule("EPGPPenalty", {OnInitialize = "OnInitialize"}, "AceConsole-3.0", "AceEvent-3.0")
local ac = VaNRLT
local aep = VaNRLTEPGPPenalty


function VaNRLTEPGPPenalty:ResetSettings()
	ac.db.global.EPGPPenalty = {
		bosses = {
			["Цитадель Ледяной Короны"] = {
				{"Лорд Ребрад", 70},
				{"Леди Смертный Шепот", 70},
				{"Бой на кораблях", 30},
				{"Саурфанг смертоносный", 90},
				{"Тухлопуз", 100},
				{"Гниломорд", 110},
				{"Профессор Мерзоцид", 120},
				{"Кровавый Совет", 100},
				{"Кровавая королева Лана'тель", 120},
				{"Валитрия Сноходица", 100},
				{"Синдрагоса", 150},
				{"Король-лич", 250},
			},
			["Рубиновое Святилище"] = {
				{"Балтар Рожденный в Битве", 100},
				{"Савиана Огненная пропасть", 50},
				{"Генерал Заритриан", 50},
				{"Халион, Сумеречный Разрушитель", 300},
			},
			["Испытание Крестоносца"] = {
				{"Чудища Нордскола", 60},
				{"Лорд Джараксус", 60},
				{"Чемпионы Фракций", 120},
				{"Валь'киры-Близнецы", 60},
				{"Ануб'Арак", 100},
			},
		},
		difficulty = {
			{"10 Об", 1},
			{"25 Об", 1.5},
			{"10 Хм", 1.5},
			{"25 Хм", 2},
		},

		type = "mouseover",

		["low"] = 0.5,
		["wipe"] = 2,
		bonus = 1.5,

		-- posx = 200,
		-- posy = -200,
	}
end

function VaNRLTEPGPPenalty:OnInitialize()
	if not ac.db.global.EPGPPenalty then
		VaNRLTEPGPPenalty:ResetSettings()
	end
	aep:Print("Initialized")
end

aep.low_penalty_signal = ac:CreateEvent()
aep.wipe_penalty_signal = ac:CreateEvent()
