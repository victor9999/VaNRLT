local VaNRLTEPGP = VaNRLT:NewModule("EPGP", {OnInitialize = "OnInitialize"}, "AceConsole-3.0", "AceEvent-3.0")
local ac = VaNRLT
local aepgp = VaNRLTEPGP

function VaNRLTEPGP:ResetSettings()
	ac.db.global.EPGP = {
		notes = {},
		non_guild_twinkies = {},
		whisper_enabled = true,
	}
end

local function OnChatMsgWhisper(e, message, sender)
	if not ac.db.global.EPGP.whisper_enabled then return end
	if string.sub(string.lower(message), 1, 14) == "v_epgp standby" then
		if aepgp:CanAddToReplacement(sender) then
			aepgp:AddToReplacement(sender)
			SendChatMessage(("VaNRLT_EPGP: %s добавлен(а) на замену."):format(sender), "WHISPER", nil, sender)
		elseif aepgp:IsOnReplacement(sender) then
			SendChatMessage(("VaNRLT_EPGP: %s уже находится на замене."):format(sender), "WHISPER", nil, sender)
		else
			SendChatMessage(("VaNRLT_EPGP: %s не может быть добавлен(а) на замену."):format(sender), "WHISPER", nil, sender)
		end
	end
end

function VaNRLTEPGP:OnInitialize()
	if not ac.db.global.EPGP or not ac.db.global.EPGP.notes or not ac.db.global.EPGP.non_guild_twinkies then
		VaNRLTEPGP:ResetSettings()
	end
	VaNRLTEPGP:RegisterEvent("CHAT_MSG_WHISPER", OnChatMsgWhisper)
	-- if EPGP then EPGP = nil end
	aepgp:Print("Initialized")
end

aepgp.guild_players = {}

aepgp.guild_info = {
	base_gp = 1,
	decay_p = 0,
}

aepgp.guild_cache_changed = VaNRLT:CreateEvent()

local function CheckUnit(n)
	if n == nil then return false end
	if not aepgp.guild_players[n] then 
		aepgp.guild_players[n] = {
			name = n,
			ep = 0,
			gp = -1,
			raid = false,
			replacement = false,
			visible = true,
			main = nil,
			class = nil,
			status = nil,
			punish = false,
			online = nil,
			rank = "",
		} 
	end
	return true
end

local function UnitVisible(unit, visible)
	CheckUnit(unit)
	aepgp.guild_players[unit].visible = visible
end

local function SetUnit(n, ep, gp)
	aepgp.guild_players[n].ep = ep
	aepgp.guild_players[n].gp = gp
	local in_raid = UnitInRaid(n)
	aepgp.guild_players[n].raid = in_raid
	if in_raid then aepgp.guild_players[n].replacement = false end
	aepgp.guild_players[n].visible = true
	aepgp.guild_players[n].status = nil
end

local opcodes = {
	["_"] = "EPGP Заморожено",
	["?"] = "Причина неизвестна",
}

local function CheckNote(note)
	if note == "" then return true, 0, 0 end
	local opcode, ep_note, gp_note = string.match(note,  "^(%D-)(%d+),(%d+)$")
	if opcode == "" then return true, tonumber(ep_note), tonumber(gp_note) end
	if opcodes[opcode] then return opcodes[opcode], tonumber(ep_note), tonumber(gp_note) end
	return nil
end

local stop_nicks = {}

local function RecursivelyCheckNotes(name)
	if aepgp.guild_players[name] and aepgp.guild_players[name].main then
		local main = aepgp.guild_players[name].main
		if aepgp.guild_players[main] and not stop_nicks[name] then
			if aepgp.guild_players[main].main or stop_nicks[main] then
				stop_nicks[name] = true
				SetUnit(name, 1, -1)
				RecursivelyCheckNotes(main)
			else
				SetUnit(name, aepgp.guild_players[main].ep, aepgp.guild_players[main].gp)
				aepgp.guild_players[name].visible = aepgp.guild_players[name].raid or aepgp.guild_players[name].online
				aepgp.guild_players[name].status = aepgp.guild_players[main].status
			end
		else
			SetUnit(name, 1, -1)
			aepgp.guild_players[name].main = nil
		end
	end
end

local function UpdateBaseInfo()
	local info = {string.split("\n", GetGuildInfoText())}
	for _,line in pairs(info) do
		local base_gp = string.match(line, "^@BASE_GP:(%d+)$")
		local decay_p = string.match(line, "^@DECAY_P:(%d+)$")
		base_gp = tonumber(base_gp)
		decay_p = tonumber(decay_p)
		if base_gp then aepgp.guild_info.base_gp = base_gp end
		if decay_p and decay_p>=0 and decay_p<=100 then aepgp.guild_info.decay_p = decay_p end
	end

	
end

local function UpdatePlayersCacheList()
	UpdateBaseInfo()
	for k,v in pairs(aepgp.guild_players) do
		if (( v.main and ac.db.global.EPGP.non_guild_twinkies[v.main] and not ac.db.global.EPGP.non_guild_twinkies[v.main][k]) or not v.main) and not UnitIsInMyGuild(k) then
			aepgp.guild_players[k] = nil
		end
	end
	if not UnitInRaid("player") then
		aepgp:ClearReplacement()
		aepgp:MovePunishmentsToMains()
	end
	local members = GetNumGuildMembers(true)
	for i=1,members do
		local n,rank,_,_,_,_,_,ofnote,online,_,class = GetGuildRosterInfo(i)
		if ofnote == "" then ofnote = "0,0" end

		if CheckUnit(n) then
			aepgp.guild_players[n].online = online
			aepgp.guild_players[n].class = class
			aepgp.guild_players[n].rank = rank
			local status, ep, gp = CheckNote(ofnote)

			if status ~= nil then
				SetUnit(n, ep, gp + aepgp.guild_info.base_gp)
				aepgp.guild_players[n].main = nil
				if status ~= true then
					aepgp.guild_players[n].status = status
				end
			else
				aepgp.guild_players[n].main = ofnote
			end
		end
	end
	wipe(stop_nicks)
	for k,v in pairs(aepgp.guild_players) do
		RecursivelyCheckNotes(k)
	end
	for k,v in pairs(stop_nicks) do
		aepgp.guild_players[k].main = nil
	end

	for k,v in pairs(ac.db.global.EPGP.non_guild_twinkies) do
		for n,_ in pairs(v) do
			if UnitIsInMyGuild(n) then 
				ac.db.global.EPGP.non_guild_twinkies[k][n]=nil
			elseif CheckUnit(n) then
				local ep, gp = aepgp:GetEPGP(k)
				aepgp.guild_players[n].online = nil
				aepgp.guild_players[n].class = nil
				aepgp.guild_players[n].rank = "Не в гильдии"
				SetUnit(n, ep, gp + aepgp.guild_info.base_gp)
				aepgp.guild_players[n].main = k
				aepgp.guild_players[n].visible = aepgp.guild_players[n].raid
			end
		end
	end

	aepgp.guild_cache_changed:emit()
end

VaNRLTEPGP:RegisterEvent("GUILD_ROSTER_UPDATE", UpdatePlayersCacheList)
VaNRLTEPGP:RegisterEvent("PARTY_MEMBERS_CHANGED", UpdatePlayersCacheList)

local announces = {
	ep = "VaNRLT_EPGP: Начислено %s EP %s для %s",
	gp = "VaNRLT_EPGP: Начислено %s GP %s для %s",
	massep = "VaNRLT_EPGP: Начислено %s EP %s для: ",
	massgp = "VaNRLT_EPGP: Начислено %s GP %s для: ",
	decay = "VaNRLT_EPGP: Уменьшение EP/GP на %s",
}

function VaNRLTEPGP:Announce(t, name, amount, reason)
	if reason~=nil and reason ~="" then reason = "("..reason..")" else reason = "" end
	if t == "ep" or t == "gp" then
		SendChatMessage((announces[t]):format(amount, reason, name), "GUILD")
	elseif t=="massep" or t=="massgp" then
		if #name == 0 then return end
		local messages = {}
		local current_message = (announces[t]):format(amount, reason)
		for i=1,#name do
			if #name[i] + #current_message + 2 <= 255 then
				current_message = current_message..(("%s, "):format(name[i]))
			else
				table.insert(messages, string.sub(current_message, 1, -3))
				current_message = ""
			end
		end
		table.insert(messages, string.sub(current_message, 1, -3))

		for i=1,#messages do
			SendChatMessage(messages[i], "GUILD")
		end
	elseif t=="decay" then
		SendChatMessage((announces[t]):format(aepgp.guild_info.decay_p.."%"), "GUILD")
	else
		aepgp:Print("Unknown announce type")
	end
end

function VaNRLTEPGP:GiveEP(name, amount, reason, noannounce)
	if not CanEditOfficerNote() or aepgp.guild_players[name].status or amount==nil or name == nil then
		return false
	end

	local given = false

	if aepgp.guild_players[name].main then name = aepgp.guild_players[name].main end

	local members = GetNumGuildMembers(true)
	for i=1,members do
		local n,rank,_,_,_,_,_,ofnote,online,_,class = GetGuildRosterInfo(i)
		if ofnote == "" then ofnote = "0,0" end

		if n == name and CheckUnit(n) then
			local status, ep, gp = CheckNote(ofnote)
			if not ep then return false end
			ep = ep + amount
			if ep < 0 then ep = 0 end
			GuildRosterSetOfficerNote(i, ("%i,%i"):format(ep, gp))
			given = true
			break
		end
	end

	if given and not noannounce then
		aepgp:Announce("ep", name, amount, reason)
	end

	return given
end

function VaNRLTEPGP:GiveGP(name, amount, reason, noannounce)
	if not CanEditOfficerNote() or aepgp.guild_players[name].status or amount==nil or name == nil then
		return false
	end

	local given = false

	if aepgp.guild_players[name].main then name = aepgp.guild_players[name].main end

	local members = GetNumGuildMembers(true)
	for i=1,members do
		local n,rank,_,_,_,_,_,ofnote,online,_,class = GetGuildRosterInfo(i)
		if ofnote == "" then ofnote = "0,0" end

		if n == name and CheckUnit(n) then
			local status, ep, gp = CheckNote(ofnote)
			if not gp then return false end
			gp = gp + amount
			if gp < 0 then gp = 0 end
			GuildRosterSetOfficerNote(i, ("%i,%i"):format(ep, gp))
			given = true
			break
		end
	end

	if given and not noannounce then
		aepgp:Announce("gp", name, amount, reason)
	end

	return given
end

function VaNRLTEPGP:GetEPGP(name)
	if aepgp.guild_players[name].main then name = aepgp.guild_players[name].main end

	local members = GetNumGuildMembers(true)
	for i=1,members do
		local n,rank,_,_,_,_,_,ofnote,online,_,class = GetGuildRosterInfo(i)
		if ofnote == "" then ofnote = "0,0" end

		if n == name and CheckUnit(n) then
			local status, ep, gp = CheckNote(ofnote)
			if not ep or not gp then return nil, nil end
			return ep, gp
		end
	end
end

function VaNRLTEPGP:AddToReplacement(name)
	aepgp.guild_players[name].replacement = true
	aepgp.guild_cache_changed:emit()
end

function VaNRLTEPGP:RemoveFromReplacement(name)
	aepgp.guild_players[name].replacement = false
	aepgp.guild_cache_changed:emit()
end

function VaNRLTEPGP:CanAddToReplacement(name)
	if aepgp.guild_players[name] and aepgp.guild_players[name].replacement == false and not aepgp.guild_players[name].raid and UnitInRaid("player") then
		return true
	else
		return false
	end
end

function VaNRLTEPGP:CanRemoveFromReplacement(name)
	if aepgp.guild_players[name].replacement == true and UnitInRaid("player") then
		return true
	else
		return false
	end
end

function VaNRLTEPGP:IsOnReplacement(name)
	if aepgp.guild_players[name] and aepgp.guild_players[name].replacement == true then
		return true
	else
		return false
	end
end

function VaNRLTEPGP:PunishUnit(name)
	aepgp.guild_players[name].punish = true
	aepgp.guild_cache_changed:emit()
end

function VaNRLTEPGP:CanPunishUnit(name)
	if aepgp.guild_players[name].punish == false and aepgp.guild_players[name].gp >= 0 then
		return true
	else
		return false
	end
end

function VaNRLTEPGP:MercyUnit(name)
	aepgp.guild_players[name].punish = false
	aepgp.guild_cache_changed:emit()
end

function VaNRLTEPGP:CanMercyUnit(name)
	if aepgp.guild_players[name].punish == true then
		return true
	else
		return false
	end
end

function VaNRLTEPGP:ClearReplacement()
	for k,v in pairs(aepgp.guild_players) do
		aepgp.guild_players[k].replacement = false
	end
	aepgp.guild_cache_changed:emit()
end

function VaNRLTEPGP:ClearPunishList()
	for k,v in pairs(aepgp.guild_players) do
		aepgp.guild_players[k].punish = false
	end
	aepgp.guild_cache_changed:emit()
end

function VaNRLTEPGP:GetMainChar(name)
	return aepgp.guild_players[name].main or name
end

function VaNRLTEPGP:MovePunishmentsToMains()
	for k,v in pairs(aepgp.guild_players) do
		if v.punish then
			v.punish = false
			aepgp.guild_players[VaNRLTEPGP:GetMainChar(k)].punish = true
		end
	end
	aepgp.guild_cache_changed:emit()
end

function VaNRLTEPGP:GiveMassEP(count, reason)
	if not count then return end
	local award = {}
	
	if not UnitInRaid("player") then
		for k,v in pairs(aepgp.guild_players) do
			if not v.main and not v.status and v.gp >= 0 then
				award[k] = count
			end
		end
	else
		for k,v in pairs(aepgp.guild_players) do
			if v.replacement then
				award[VaNRLTEPGP:GetMainChar(k)] = count * 1
			end
			if v.raid then
				award[VaNRLTEPGP:GetMainChar(k)] = count
			end
		end
	end

	local awarded = {}

	for k,v in pairs(award) do
		if aepgp:GiveEP(k, v, reason, true) then
			table.insert(awarded, k)
		end
	end

	aepgp:Announce("massep", awarded, count, reason)

	aepgp:ClearReplacement()
	
	aepgp.guild_cache_changed:emit()
end

function VaNRLTEPGP:GiveMassGP(count, reason)
	if not count then return end
	award = {}
	for k,v in pairs(aepgp.guild_players) do
		if v.punish then
			award[VaNRLTEPGP:GetMainChar(k)] = count
		end
	end
	
	local awarded = {}

	for k,v in pairs(award) do
		if aepgp:GiveGP(k, v, reason, true) then
			table.insert(awarded, k)
		end
	end

	aepgp:Announce("massgp", awarded, count, reason)

	aepgp:ClearPunishList()
	
	aepgp.guild_cache_changed:emit()
end

function VaNRLTEPGP:GetNumAlts(name)
	local num = 0
	for k,v in pairs(aepgp.guild_players) do
		if v.main == name then
			num = num + 1
		end
	end
	return num
end

function VaNRLTEPGP:GetAlts(name)
	alts = {}
	for k,v in pairs(aepgp.guild_players) do
		if v.main == name then
			table.insert(alts, k)
		end
	end
	return alts
end

function VaNRLTEPGP:GetClass(name)
	return aepgp.guild_players[name].class
end

function VaNRLTEPGP:GetNote(name)
	return ac.db.global.EPGP.notes[name]
end

function VaNRLTEPGP:SetNote(name, note)
	ac.db.global.EPGP.notes[name] = note
end

function VaNRLTEPGP:GetOnline(name)
	return aepgp.guild_players[name].online
end

function VaNRLTEPGP:GetRank(name)
	return aepgp.guild_players[name].rank
end

local function check_tw_main(name)
	if not ac.db.global.EPGP.non_guild_twinkies[name] then
		ac.db.global.EPGP.non_guild_twinkies[name] = {}
	end
end

function VaNRLTEPGP:AddTwinkie(name, tname)
	check_tw_main(name)
	if tname == "" or aepgp.guild_players[name].main then return end
	ac.db.global.EPGP.non_guild_twinkies[name][tname] = true
	UpdatePlayersCacheList()
end

function VaNRLTEPGP:RemoveTwinkie(name, tname)
	check_tw_main(name)
	ac.db.global.EPGP.non_guild_twinkies[name][tname] = nil
	aepgp.guild_players[tname] = nil
	UpdatePlayersCacheList()
end

function VaNRLTEPGP:GetTwinkies(name)
	check_tw_main(name)
	return ac.db.global.EPGP.non_guild_twinkies[name]
end

function VaNRLTEPGP:GetNumTwinkies(name)
	check_tw_main(name)
	local i = 0
	for k,v in pairs(ac.db.global.EPGP.non_guild_twinkies[name]) do
		i = i+1
	end
	return i
end

function VaNRLTEPGP:Decay()
	local members = GetNumGuildMembers(true)
	for i=1,members do
		local n,rank,_,_,_,_,_,ofnote,online,_,class = GetGuildRosterInfo(i)
		if ofnote == "" then ofnote = "0,0" end
		local status, ep, gp = CheckNote(ofnote)

		if status == true and ep then
			ep = ep * (100 - aepgp.guild_info.decay_p) / 100
			gp = (gp + aepgp.guild_info.base_gp) * (100 - aepgp.guild_info.decay_p) / 100 - aepgp.guild_info.base_gp
			if ep < 0 then ep = 0 end
			if gp < 0 then gp = 0 end
			GuildRosterSetOfficerNote(i, ("%i,%i"):format(ep, gp))
		end
	end
	aepgp:Announce("decay")
end