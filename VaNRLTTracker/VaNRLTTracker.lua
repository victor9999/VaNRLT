local VaNRLTTracker = VaNRLT:NewModule("Tracker", {OnInitialize = "OnInitialize"}, "AceConsole-3.0", "AceEvent-3.0")
local ac = VaNRLT
local at = VaNRLTTracker

local function Toggle(args)
	ac.db.global.Tracker.Enabled = not ac.db.global.Tracker.Enabled
	if ac.db.global.Tracker.Enabled then
		at:Print("Трекер включен")
	else
		at:Print("Трекер выключен")
	end
end

function VaNRLTTracker:ResetSettings()
	ac.db.global.Tracker = {
		["Enabled"] = true,
		["Debug"] = false,
		["SpellTable"] = {
			["SPELLS"] = {
				--Target
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(66115)), true}, -- "Длань свободы"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(1038)), true}, -- "Длань спасения"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(19752)), true}, -- "Божественное вмешательство"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(55975)), true}, -- "Истерия"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(49005)), true}, -- "Кровавая метка"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(29166)), true}, -- "Озарение"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(57934)), true}, -- "Маленькие хитрости"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(51722)), true}, -- "Долой оружие"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(676)), true}, -- "Разоружение"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(10060)), true}, -- "Придание сил"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(6346)), true}, -- "Защита от страха"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(33206)), true}, -- "Подавление боли"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(47788)), true}, -- "Оберегающий дух"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(34477)), true}, -- "Перенаправление"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(67518)), true}, -- "Пожирание магии"
				{"SPELL_RESURRECT", select(1,GetSpellInfo(48477)), true}, -- "Возрождение"
				{"SPELL_AURA_APPLIED", select(1,GetSpellInfo(27239)), true}, -- "Воскрешение камнем души"
				{"SPELL_AURA_APPLIED", select(1,GetSpellInfo(53359)), true}, -- "Выстрел химеры - сорпид"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(10278)), true}, -- "Длань защиты"
				
				--NoTarget
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(2825)), true}, -- "Жажда крови"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(32182)), true}, -- "Героизм"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(48447)), true}, -- "Спокойствие"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(64843)), true}, -- "Божественный гимн"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(64901)), true}, -- "Гимн надежды"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(16190)), true}, -- "Тотем прилива маны"
				{"SPELL_CAST_SUCCESS", select(1,GetSpellInfo(42650)), true}, -- "Войско мертвых"
			},
			["TANKS"] = {
				{select(1,GetSpellInfo(71638)), true}, -- "Эгида Даларана"
				{select(1,GetSpellInfo(71586)), true}, -- "Затвердевшая кожа"
				
				{select(1,GetSpellInfo(48792)), true}, -- "Незыблемость льда"
				{select(1,GetSpellInfo(48707)), true}, -- "Антимагический панцирь"
				{select(1,GetSpellInfo(55233)), true}, -- "Кровь вампира"
				{select(1,GetSpellInfo(70654)), true}, -- "Кровавый доспех"
				
				{select(1,GetSpellInfo(871)), true}, -- "Глухая оборона"
				{select(1,GetSpellInfo(12975)), true}, -- "Ни шагу назад"
				{select(1,GetSpellInfo(55694)), true}, -- "Безудержное восстановление"
				
				{select(1,GetSpellInfo(498)), true}, -- "Божественная защита"
				{select(1,GetSpellInfo(642)), true}, -- "Божественный щит"
				{select(1,GetSpellInfo(64205)), true}, -- "Священная жертва"
				
				{select(1,GetSpellInfo(70725)), true}, -- "Яростная защита"
				{select(1,GetSpellInfo(22842)), true}, -- "Неистовое восстановление"
				{select(1,GetSpellInfo(22812)), true}, -- "Дубовая кожа"
				{select(1,GetSpellInfo(61336)), true}, -- "Инстинкты выживания"
			},
			["DEBUG"] = {
			},
		}
	}
end


function VaNRLTTracker:OnInitialize()
	if not ac.db.global.Tracker then
		VaNRLTTracker:ResetSettings()
	end
	table.insert(ac.CommandsList, {"toggletracker", Toggle})
	at:Print("Initialized")
end

local skills = {
	fp = select(1,GetSpellInfo(48263)),
	rf = select(1,GetSpellInfo(25780)),
	bf = select(1,GetSpellInfo(9634)),
}

function checkIsTank(unit)
	local class, loc = UnitClass(unit)
	if (loc == "DEATHKNIGHT" and UnitBuff(unit, skills.fp))
		or 	(loc == "PALADIN" and UnitBuff(unit, skills.rf))
		or 	(loc == "DRUID" and UnitBuff(unit, skills.bf))
		or 	(loc == "WARRIOR")
	then
		return true
	end
end

function VaNRLTTracker:SpellCastHandler(unit,name,target,type,spellid)
	local n = ac:GetPetOwner(UnitGUID(unit))
	if (n ~= "Unknown") then unit = unit.." <"..n..">" end
	
	if ac.db.global.Tracker.Debug then
		if not unit then unit = "nil" end
		if not target then target = "nil" end
		for n,spell in pairs(ac.db.global.Tracker.SpellTable.DEBUG) do
			if (spell[2] and spell[1] == name) then
				local link = GetSpellLink(spellid)
				if (link==nil) then link = name end
				ac:SendRaidMessage("Debug unit=["..unit.."] spell=["..name.."] target=["..target.."] type=["..type.."]") 
			end 
		end
	else
		--Spells
		for n,spell in pairs(ac.db.global.Tracker.SpellTable.SPELLS) do
			if (spell[3] and spell[1] == type and spell[2] == name) then
				local link = GetSpellLink(spellid) or name
				if (target~=nil) then
					target = VaNRLT:GetNick(target)
					ac:SendRaidMessageWithNick("=> "..link.." => "..target, unit)
				else
					ac:SendRaidMessageWithNick("=> "..link, unit)
				end
			end 
		end
		--Tanks
		if checkIsTank(unit) then
			for n,spell in pairs(ac.db.global.Tracker.SpellTable.TANKS) do
				if (spell[2] and spell[1] == name and (unit == target or not target)) then
					local link = GetSpellLink(spellid)
					if (link==nil) then link = name end
					if type == "SPELL_AURA_APPLIED" then
						ac:SendRaidMessageWithNick(" +"..link, unit)
					elseif type == "SPELL_AURA_REMOVED" then
						ac:SendRaidMessageWithNick(" -"..link, unit)
					end
				end 
			end
		end
	end
end



function VaNRLTTracker:OnCombatLogEventUnfiltered(event, ...)
	if (ac.db.global.Tracker.Enabled==true and UnitPlayerOrPetInRaid(select(4, ...))==1) or ac.db.global.Tracker.Debug then
		VaNRLTTracker:SpellCastHandler(select(4, ...),select(10, ...),select(7, ...),select(2, ...),select(9, ...))
	end
end

at:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventUnfiltered")