local VaNRLTSlowpokeDetector = VaNRLT:NewModule("SlowpokeDetector", {OnInitialize = "OnInitialize"}, "AceConsole-3.0", "AceEvent-3.0")
local ac = VaNRLT
local asd = VaNRLTSlowpokeDetector
local locale = ac.locale


function VaNRLTSlowpokeDetector:ResetSettings()
	ac.db.global.SlowpokeDetector = {
		["Enabled"] = true,
		["Sindragosa"] = true,
		["Prof"] = true,
		["Festergut"] = true,
		["ProfRed"] = true,
		["Prince"] = 10,
		["SindragosaMS"] = 6,
		["SindragosaRS"] = 3,
		["Autolink"] = true,
	}
end

function VaNRLTSlowpokeDetector:OnInitialize()
	if not ac.db.global.SlowpokeDetector then
		VaNRLTSlowpokeDetector:ResetSettings()
	end
	asd:Print("Initialized")
end

local Stat = {}

local function printsindr()
	ac:SendRaidMessage("Количество взрывов, Максимальное количество стаков")
	for k,v in pairs(Stat) do
		if v.countbangs > 0 or v.maxstacks > 0 then
			ac:SendRaidMessageWithNick("- "..v.countbangs..", "..v.maxstacks, k)
		end
	end
end

local function printprof()
	ac:SendRaidMessage("Количество пелеменей, Количество колб")
	for k,v in pairs(Stat) do
		if v.countpelmen > 0 or v.countkolb > 0 then
			ac:SendRaidMessageWithNick("- "..v.countpelmen..", "..v.countkolb, k)
		end
	end
end

local function printfestergut()
	ac:SendRaidMessage("Количество пелеменей")
	for k,v in pairs(Stat) do
		if v.countpelmen > 0 then
			ac:SendRaidMessageWithNick("- "..v.countpelmen, k)
		end
	end
end

local bosses = {
	[locale.sindragosa] = {locale.phrase_sindragosa, printsindr},
	[locale.prof] = {locale.phrase_prof, printprof},
	[locale.festergut] = {locale.phrase_festergut, printfestergut},
}

local inFight = false
local fname = nil

local function onFightEnd()
	if ac.db.global.SlowpokeDetector.Enabled and ac.db.global.SlowpokeDetector.Autolink then
		local pr = false
		for k,v in pairs(Stat) do --nick, table
			for k1,v1 in pairs(v) do --field, value
				if v1 > 0 then
					pr = true
					break
				end
			end
		end
		if pr then
			ac:SendRaidMessage("Отчет за последний бой:")
			bosses[fname][2]()
		end
	end
	fname = nil
end

local function checkWipe()
	local wipe = true
	for i = 1,40,1 do
		if UnitAffectingCombat("raid"..i) and not UnitIsDeadOrGhost("raid"..i) then
			wipe = false
			break
		end
	end
	if wipe and inFight then
		inFight = false
		onFightEnd()
	else
		VaNRLT:DelayFunc("checkWipe", 3, checkWipe)
	end
end

local function msg(event, message, unit)
	if not ac.db.global.SlowpokeDetector.Enabled then return end
	for k,v in pairs(bosses) do
		if k == unit then
			if string.find(message, v[1]) then
				if not inFight then
					inFight = true
					fname = k
					Stat = {}
					print("pulled mob "..unit)
				end
				VaNRLT:DelayFunc("checkWipe", 3, checkWipe)
			end
		end
	end
end

asd:RegisterEvent("CHAT_MSG_MONSTER_YELL", msg)

local function onUnitDied(name)
	if name == fname then
		inFight = false
		VaNRLT:DelayFunc("checkWipe", 0.1, function() end)
		onFightEnd()
	end
end


local OMPlayers = {}
local OMLastUnit


local function SindragosaWriteOMBang(t)
	ac:SendRaidMessageWithNick("Взорвал(а) "..t[2].." стаков и задел(а) этим "..t[3].." человек!", t[1])
	OMPlayers[t[1]].sstacks=0
	
	Stat[t[1]].countbangs = Stat[t[1]].countbangs + 1
	if t[2] > Stat[t[1]].maxstacks then Stat[t[1]].maxstacks = t[2] end
end

function VaNRLTSlowpokeDetector:CastHandler(unit,name,target,type,spellid,timestamp)
	if not Stat[target] then
		Stat[target] = {}
		Stat[target].countpelmen = 0
		Stat[target].countkolb = 0
		Stat[target].countbangs = 0
		Stat[target].maxstacks = 0
	end
	if unit == locale.sindragosa then
		if ac.db.global.SlowpokeDetector.Sindragosa then
			if type=="SPELL_AURA_APPLIED" and name==locale.instability then
				OMPlayers[target] = {} 
				OMPlayers[target].stacks=1
				OMPlayers[target].targets=0
			elseif type=="SPELL_AURA_APPLIED_DOSE" and name==locale.instability then
				OMPlayers[target].stacks=OMPlayers[target].stacks+1
			elseif type=="SPELL_AURA_REMOVED" and name==locale.instability then
				OMLastUnit = target
				OMPlayers[OMLastUnit].sstacks=OMPlayers[OMLastUnit].stacks
				OMPlayers[OMLastUnit].stacks=1
			elseif type=="SPELL_DAMAGE" and name==locale.revengestrike and OMLastUnit~=target then
				OMPlayers[OMLastUnit].targets=OMPlayers[OMLastUnit].targets+1
				ac:DelayFunc("sindragosaombang"..OMLastUnit, 0.3, SindragosaWriteOMBang, {OMLastUnit, OMPlayers[OMLastUnit].sstacks, OMPlayers[OMLastUnit].targets})
			end
		end
		if ac.db.global.SlowpokeDetector.SindragosaMS>0 and (type=="SPELL_AURA_APPLIED_DOSE" or type=="SPELL_AURA_APPLIED") and name==locale.chill then
			local name, rank, icon, count = UnitDebuff(target, name)
			if count == ac.db.global.SlowpokeDetector.SindragosaMS then
				ac:SendRaidMessageWithNick("набрал(а) больше "..count.." стаков Обморожения!", target)
			end
		elseif ac.db.global.SlowpokeDetector.SindragosaRS>0 and (type=="SPELL_AURA_APPLIED_DOSE" or type=="SPELL_AURA_APPLIED") and name==locale.instability then
			local name, rank, icon, count = UnitDebuff(target, name)
			if count == ac.db.global.SlowpokeDetector.SindragosaRS then
				ac:SendRaidMessageWithNick("набрал(а) больше "..count.." стаков Неустойчивости!", target)
			end
		end
	elseif (ac.db.global.SlowpokeDetector.Prof and unit == locale.prof) then
		if (type=="SPELL_AURA_APPLIED" or type=="SPELL_AURA_REFRESH") and name==locale.ooze then
			ac:SendRaidMessageWithNick("поймал(а) вязкую гадость!", target)
			
			Stat[target].countpelmen = Stat[target].countpelmen + 1
		end
	elseif (ac.db.global.SlowpokeDetector.Prof and unit == nil) then
		if (type=="SPELL_AURA_APPLIED") and name==locale.gas then
			ac:SendRaidMessageWithNick("поймал(а) удушливый газ!", target)
			
			Stat[target].countkolb = Stat[target].countkolb + 1
		end
	elseif (ac.db.global.SlowpokeDetector.Festergut and unit == locale.prof) then
		if (type=="SPELL_AURA_APPLIED" or type=="SPELL_AURA_REFRESH") and name==locale.ooze then
			ac:SendRaidMessageWithNick("поймал(а) вязкую гадость!", target)
			
			Stat[target].countpelmen = Stat[target].countpelmen + 1
		end
	elseif (ac.db.global.SlowpokeDetector.Prince>0 and unit == locale.keleseth) then
		if type=="SPELL_AURA_APPLIED_DOSE" and name==locale.shadowprison then
			local name, rank, icon, count = UnitDebuff(target, name)
			if count == ac.db.global.SlowpokeDetector.Prince then
				ac:SendRaidMessageWithNick("набрал(а) больше "..count.." стаков Темницы Тьмы!", target)
			end
		end
	elseif (ac.db.global.SlowpokeDetector.ProfRed and unit ~= locale.festergut) then
		if type=="SPELL_AURA_APPLIED" and name==locale.gaseousbloat then
				ac:SendRaidMessageWithNick("Красный слизень", target)
		end
	end
end

function VaNRLTSlowpokeDetector:OnCombatLogEventUnfiltered(event, ...)
	local inst, type = IsInInstance()
	if ac.db.global.SlowpokeDetector.Enabled and inst then
		if not UnitPlayerOrPetInRaid(select(4, ...) or "nil") and UnitInRaid(select(7, ...)) then
			if string.find(select(2, ...) or "nil", "SPELL_") then
				VaNRLTSlowpokeDetector:CastHandler(select(4, ...),select(10, ...),select(7, ...),select(2, ...),select(9, ...),select(1, ...))
			end
		elseif string.find(select(2, ...) or "nil", "UNIT_DIED") then
			onUnitDied(select(7, ...))
		end
	end
end

asd:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventUnfiltered")