local VaNRLTRaidChecks = VaNRLT:NewModule("RaidChecks", {OnInitialize = "OnInitialize"}, "AceConsole-3.0", "AceEvent-3.0")
local ac = VaNRLT
local arch = VaNRLTRaidChecks

function VaNRLTRaidChecks:ResetSettings()
	ac.db.global.RaidChecks = {
		["Enabled"] = true,
		["Fish"] = true,
		["FishClick"] = true,
		["Portal"] = true,
	}
end

local skills = {
	fish = GetSpellInfo(57426), --Рыбный пир
	portal = GetSpellInfo(698), --Ритуал призыва
}


function VaNRLTRaidChecks:OnInitialize()
	if not ac.db.global.RaidChecks then
		VaNRLTRaidChecks:ResetSettings()
	end
	arch:Print("Initialized")
end

local fishclicks = {}

function VaNRLTRaidChecks:SpellCastHandler(unit,name,target,type,spellid)
	if name == skills.fish then
		if ac.db.global.RaidChecks.Fish and type == "SPELL_CREATE" then
			local link = GetSpellLink(spellid)
			if (link==nil) then link = name end
			ac:SendRaidMessageWithNick("=> "..link, unit)
		end
		if ac.db.global.RaidChecks.FishClick and type == "SPELL_CAST_SUCCESS" then
			if not fishclicks[unit] then fishclicks[unit] = 0 end
			fishclicks[unit] = fishclicks[unit] + 1
			if fishclicks[unit] >= 4 then 
				ac:SendRaidMessageWithNick("закликивает рыбу!", unit)
			end
			ac:DelayFunc("fishclick"..unit, 10, function() fishclicks[unit] = 0 end)
		end
	elseif ac.db.global.RaidChecks.Portal and name == skills.portal and type == "SPELL_CAST_SUCCESS" then
		local link = GetSpellLink(spellid)
		if (link==nil) then link = name end
		ac:SendRaidMessageWithNick("=> "..link, unit)
	end
end



function VaNRLTRaidChecks:OnCombatLogEventUnfiltered(event, ...)
	if (ac.db.global.RaidChecks.Enabled==true and UnitPlayerOrPetInRaid(select(4, ...))==1)then
		VaNRLTRaidChecks:SpellCastHandler(select(4, ...),select(10, ...),select(7, ...),select(2, ...),select(9, ...))
	end
end

arch:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventUnfiltered")