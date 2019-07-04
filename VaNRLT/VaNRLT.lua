VaNRLT = LibStub("AceAddon-3.0"):NewAddon("VaNRLT", "AceConsole-3.0","AceEvent-3.0")
local ac = VaNRLT
local nicks={}
ac.locale={}

local skillname = GetSpellInfo(2457)

table.indexof = function( t, object )
    if "table" == type( t ) then
        for i = 1, #t do
            if object == t[i] then
                return i
            end
        end
        return nil
    else
            error("table.indexOf expects table for first argument, " .. type(t) .. " given")
    end
end


local function ReCacheNicks()
	for i=1,40 do
		local unit = "raid"..i
		if(UnitInRaid(unit)) then
			local name = UnitName(unit)
			if(nicks[name]==nil) then
				nicks[name] = string.gsub(GetSpellLink(2457),skillname,name)
			end
		end
	end
end

function VaNRLT:OnInitialize()
	ac.db = LibStub("AceDB-3.0"):New("VaNRLTDB")
	local loadLink = GetSpellLink(2457)
			
	ac:RegisterChatCommand("vanrlt", "SlashHandler")
	ac:RegisterEvent("PARTY_MEMBERS_CHANGED", ReCacheNicks)
	ReCacheNicks()
	ac:Print("Initialized")
end

VaNRLT.CommandsList = {}

local function ShowHelpMesage(args)
	local s = "Команды:"
	for k,v in pairs(VaNRLT.CommandsList) do
		s = s.."\n"..v[1]
	end
	ac:Print(s)
end

table.insert(VaNRLT.CommandsList, {"help", ShowHelpMesage})

function VaNRLT:SlashHandler(command)
	if command=="" then ShowHelpMesage(command) do return end end
 	local c = ac:GetArgs(command)
	for _,v in pairs(VaNRLT.CommandsList) do
		if v[1]==c then
			v[2](command)
			do return end
		end
	end
	ac:Print("Нет такой команды")
end

function VaNRLT:SendRaidMessage(message)
	if(UnitInRaid('player')~=nil) then SendChatMessage("VaNRLT: "..message, "RAID") do return end end
end
function VaNRLT:SendRaidMessageWithNick(message,nick)
	if ac.db.global.ColorNick then
		nick = nicks[nick] or ("["..(nick or "UNKNOWN").."]")
	else
		nick = "["..(nick or "UNKNOWN").."]"
	end
	if(UnitInRaid('player')~=nil) then SendChatMessage("VaNRLT: "..nick.." "..message, "RAID") do return end end
end
function VaNRLT:GetNick(nick)
	if ac.db.global.ColorNick then
		return nicks[nick] or string.gsub(GetSpellLink(2457),skillname,nick) or ("["..(nick or "UNKNOWN").."]")
	else
		return "["..(nick or "UNKNOWN").."]"
	end
end



do --Delayed functions			VaNRLT:DelayFunc(name, time, func, ...)
	local delayedFrame = CreateFrame("FRAME")
	local dflist={}

	local function dfAdd(n,t,f, ...)
		for k,v in pairs(dflist) do
			if v.n == n then table.remove(dflist, k) end
		end
		table.insert(dflist,{["n"]=n,["t"]=t,["f"]=f,["a"]=...})
	end

	local function dfOnUpdate(self, elapsed)
		for k,v in pairs(dflist) do
			v.t=v.t-elapsed
			if v.t<=0 then
				table.remove(dflist, k)
				v.f(v.a)
			end
		end
	end

	delayedFrame:SetScript("OnUpdate", dfOnUpdate)
	
	function VaNRLT:DelayFunc(name, time, func, ...)
		dfAdd(name,time,func, ...)
	end
end

function VaNRLT:GetPetOwner(pet)
	if(UnitInRaid("player")) then
		for i=1,40,1 do
			if(UnitGUID("raidpet"..i) == pet) then
				return UnitName("raid"..i);
			end
		end
	else
		if(UnitGUID("pet") == pet) then return UnitName("player"); end
		for i=1,4,1 do
			if(UnitGUID("partypet"..i) == pet) then
				return UnitName("party"..i);
			end
		end
	end
	return "Unknown";
end

function VaNRLT:ResetDBToDefault()
	for name, module in VaNRLT:IterateModules() do
		module:ResetSettings()
	end
end

local base_event = {
	emit = function(self,  ... )
		for i=1,#self.functions do
			self.functions[i](...)
		end
	end,
	connect = function(self, f) table.insert(self.functions, f) end,
}



function VaNRLT:CreateEvent()
	local event = {}
	setmetatable(event, {
		__index = base_event
	})
	event.functions = {}
	return event
end
