local VaNRLTRaidCooldownGUI
local _gui
local ac
--local arc
local arcgui

local function Init()
	_gui = VaNRLT:GetModule("GUI", true)
	if _gui then
		local VaNRLTRaidCooldownGUI = _gui:NewModule("RaidCooldownGUI", {OnInitialize = "OnInitialize"}, "AceConsole-3.0", "AceEvent-3.0")
		ac = VaNRLT
		--arc = VaNRLT:GetModule("RaidCooldown")
		arcgui = VaNRLTRaidCooldownGUI
		
		function VaNRLTRaidCooldownGUI:ResetSettings()
			ac.db.global.RaidCooldown = {
				enabled = false,
				maxincolumn = 10,
				maxcolumns = 3,
				rowscale = 12,
				posx = 0,
				posy = 0,
			}
		end
		
		function VaNRLTRaidCooldownGUI:OnInitialize()
			arcgui:Print("Initialized")
		end
		
		if not ac.db.global.RaidCooldown then VaNRLTRaidCooldownGUI:ResetSettings() end
		local arcdb = ac.db.global.RaidCooldown
		
		local global_cooldowns = {
			{
				name = select(1, GetSpellInfo(48477)),
				icon = select(3, GetSpellInfo(48477)),
				class = "DRUID",
				duration = 600,
				type = "_OnSucceded",
			},
			{
				name = select(1, GetSpellInfo(29166)),
				icon = select(3, GetSpellInfo(29166)),
				duration = 180,
				class = "DRUID",
				type = "SPELL_CAST_SUCCESS",
			},
			--[[{
				name = "Войско мертвых",
				icon = select(3, GetSpellInfo(42650)),
				class = "DEATHKNIGHT",
				duration = 600,
				adv_duration = {
					{
						spec = 3,
						pos = 13,
						ranks = {
							[1] = 480,
							[2] = 360,
						}
					},
				}
			},]]
			{
				name = select(1, GetSpellInfo(32182)),
				icon = select(3, GetSpellInfo(32182)),
				duration = 300,
				class = "SHAMAN",
				faction = "Alliance",
				type = "SPELL_CAST_SUCCESS",
			},
			{
				name = select(1, GetSpellInfo(2825)),
				icon = select(3, GetSpellInfo(2825)),
				duration = 300,
				class = "SHAMAN",
				faction = "Horde",
				type = "SPELL_CAST_SUCCESS",
			},
			--[[{
				name = "Перерождение",
				icon = select(3, GetSpellInfo(20608)),
				duration = 1800,
				class = "SHAMAN",
				adv_duration = {
					{
						spec = 3,
						pos = 3,
						ranks = {
							[1] = 1380,
							[2] = 900,
						}
					},
				}
			},]]
			{
				name = select(1, GetSpellInfo(64843)),
				icon = select(3, GetSpellInfo(64843)),
				class = "PRIEST",
				duration = 480,
				type = "SPELL_CAST_SUCCESS",
			},
			{
				name = select(1, GetSpellInfo(64901)),
				icon = select(3, GetSpellInfo(64901)),
				duration = 360,
				class = "PRIEST",
				type = "SPELL_CAST_SUCCESS",
			},
		}
		local current_cooldowns = {	}
		local cached_players = {UnitName("player")}
		
		local function on_iconbar_clicked(id)
			local remaining = global_cooldowns[current_cooldowns[id].id].duration+current_cooldowns[id].started - GetTime()
			if remaining < 0 then
				ac:SendRaidMessageWithNick(global_cooldowns[current_cooldowns[id].id].name.." ГОТОВО",current_cooldowns[id].player)
			else
				ac:SendRaidMessageWithNick(global_cooldowns[current_cooldowns[id].id].name.." "..(("%.2f"):format(floor(remaining/60)+(remaining%60)/100):replace(".", ":")),current_cooldowns[id].player)
			end
		end
		
		local function create_iconbar()
			local bar = CreateFrame("frame")
			bar:SetSize(120, 12)
			bar.id = -1
			
			bar.icon = bar:CreateTexture()
			bar.icon:SetPoint("TOPLEFT", bar, "TOPLEFT")
			bar.icon:SetSize(12, 12)
			bar.icon:SetTexture(defaulticon)
			
			bar.timer = bar:CreateFontString()
			bar.timer:SetTextColor(1, 1, 1)
			bar.timer:SetFont("Fonts\\ARIALN.TTF", 10)
			bar.timer:SetPoint("LEFT", bar.icon, "RIGHT", 0, 0)
			bar.timer:SetSize(36, 12)
			bar.timer:SetText("READY")
			
			bar.name = bar:CreateFontString()
			bar.name:SetTextColor(1, 1, 1)
			bar.name:SetFont("Fonts\\ARIALN.TTF", 10)
			bar.name:SetPoint("LEFT", bar.timer, "RIGHT")
			bar.name:SetSize(72, 12)
			bar.name:SetText("")
			
			bar.button = CreateFrame("button", nil, bar)
			bar:EnableMouse(true)
			bar.button:SetScript("OnClick", function() on_iconbar_clicked(bar.id) end)
			bar.button:SetAllPoints(bar)
			
			function bar:SetCooldownTime(time, status)
				if status == 2 then bar.timer:SetText("OFF") bar.timer:SetTextColor(1, 1, 1) return end
				if status == 1 then bar.timer:SetTextColor(1, 0, 0) else bar.timer:SetTextColor(0, 1, 0) end
				if time>0 then
					bar.timer:SetText(("%.2f"):format(floor(time/60)+time%60/100):replace(".", ":"))
				else
					bar.timer:SetText("READY")
				end
			end
			
			function bar:SetInfo(nick, icon, time)
				bar.name:SetText(nick)
				bar.icon:SetTexture(icon)
				bar:SetCooldownTime(time or 0, 0)
			end
			
			function bar:SetScale(scale)
				bar:SetSize(scale*10, scale)
				bar.icon:SetSize(scale, scale)
				bar.timer:SetFont("Fonts\\ARIALN.TTF", scale-2)
				bar.timer:SetSize(scale*3, scale)
				bar.name:SetFont("Fonts\\ARIALN.TTF", scale-1)
				bar.name:SetSize(scale*6, scale)
			end
			
			return bar
		end
		
		local function create_raid_stack()
			local stack = CreateFrame("Frame")
			stack.max_in_column = 1
			stack:SetSize(1, 1)
			stack.raidrows = {}
			stack.cachedrows = {}
			
			function stack:InsertRow()
				if #stack.cachedrows == 0 then
					local newbar = create_iconbar()
					newbar:SetParent(stack)
					table.insert(stack.cachedrows, newbar)
				end
				
				row = stack.cachedrows[1]
				table.remove(stack.cachedrows, 1)
				
				row:Show()
				row:SetScale(arcdb.rowscale)
				
				if #stack.raidrows == 0 then 
					table.insert(stack.raidrows, row)
					row.id = 1
					row:ClearAllPoints()
					row:SetPoint("TOPLEFT", stack, "TOPLEFT", 0, 0)
				else
					table.insert(stack.raidrows, row)
					row.id = #stack.raidrows
					row:ClearAllPoints()
					if (#stack.raidrows-1)%(stack.max_in_column)==0 then
						row:SetPoint("TOPLEFT", stack, "TOPLEFT", floor(#stack.raidrows/stack.max_in_column)*arcdb.rowscale*10, 0)
					else
						row:SetPoint("TOPLEFT", stack.raidrows[#stack.raidrows - 1], "BOTTOMLEFT", 0, 0)
					end
				end
			end
			
			function stack:RemoveRow()
				if #stack.raidrows == 0 then return end
				
				row = stack.raidrows[#stack.raidrows]
				table.remove(stack.raidrows, #stack.raidrows)
				
				row:Hide()
				row:ClearAllPoints()
				table.insert(stack.cachedrows, row)
			end
			
			function stack:SetRowCount(count, wipe)
				wipe = wipe or false
				while wipe and #stack.raidrows > 0 do
					stack:RemoveRow()
				end
				while #stack.raidrows > count do
					stack:RemoveRow()
				end
				while #stack.raidrows < count do
					stack:InsertRow()
				end					
			end
			
			return stack
		end
		
		fr = create_raid_stack()
		if arcdb.enabled then fr:Show() else fr:Hide() end
		
		--[[****************************************************************************]]--
		
		local n = UnitName("player")
		local c = select(2, UnitClass("player"))
		local f = UnitFactionGroup("player")
		for i=1,#global_cooldowns,1 do
			if global_cooldowns[i].class == c and (global_cooldowns[i].faction == f or global_cooldowns[i].faction == nil) then
				local t = {
					id = i,
					player = n,
					started = -1,
					status = 0
				}
				table.insert(current_cooldowns, t)
			end
		end
		
		local function sort_compare(i1, i2)
			if i1.status == i2.status then
				if i1.id == i2.id then
					return i1.player > i2.player
				end
				return i1.id > i2.id
			end
			return i1.status > i2.status
		end
		
		local function sort_current_cooldowns()
			for i=1,#current_cooldowns,1 do
				for j =i,#current_cooldowns, 1 do
					if sort_compare(current_cooldowns[i], current_cooldowns[j]) then
						current_cooldowns[i], current_cooldowns[j] = current_cooldowns[j], current_cooldowns[i]
					end
				end
			end
		end
			
		local function update_rows_info()
			local count = arcdb.maxincolumn * arcdb.maxcolumns
			if #current_cooldowns < count then count = #current_cooldowns end
			for i=1,count,1 do
				fr.raidrows[i]:SetInfo(current_cooldowns[i].player, global_cooldowns[current_cooldowns[i].id].icon, 0)
			end
		end
		
		local function update_status()
			for i=1,#current_cooldowns,1 do
				if not UnitIsConnected(current_cooldowns[i].player) then
					current_cooldowns[i].status = 2
				elseif UnitIsDeadOrGhost(current_cooldowns[i].player) then
					current_cooldowns[i].status = 1
				else
					current_cooldowns[i].status = 0
				end
			end
			sort_current_cooldowns()
			update_rows_info()
		end
		
		local function update_count()
			fr.max_in_column = arcdb.maxincolumn
			local count = arcdb.maxincolumn * arcdb.maxcolumns
			if #current_cooldowns < count then count = #current_cooldowns end
			fr:SetRowCount(count, true)
			update_rows_info()
		end
		
		local function update_timers()
			local count = #current_cooldowns
			for i=1,count,1 do
				if current_cooldowns[i].started == -1 then 
					fr.raidrows[i]:SetCooldownTime(0, current_cooldowns[i].status)
				else
					local remaining = global_cooldowns[current_cooldowns[i].id].duration+current_cooldowns[i].started - GetTime()
					if remaining < 0 then
						remaining = 0
						current_cooldowns[i].started = -1
					end
					fr.raidrows[i]:SetCooldownTime(remaining, current_cooldowns[i].status)
				end
			end
		end
		
		local tim = 0
		local function cycle_update()
			ac:DelayFunc("arc_update_timers", 0.5, cycle_update)
			update_status()
			update_timers()
		end
		
		local function move_stack()
			fr:ClearAllPoints()
			fr:SetPoint("TOPLEFT", UIParent, "TOPLEFT", arcdb.posx, -arcdb.posy)
		end
		
		local function update_cooldowns()
			ac:DelayFunc("arc_update_timers", 0.001, function() end)
			local pcount = #current_cooldowns
			local pln = UnitName("player")
			
			local i = 1
			while (i<=#current_cooldowns) do
				if not UnitInRaid(current_cooldowns[i].player) and current_cooldowns[i].player ~= pln then 
					local j = 1
					while j<= #cached_players do
						if cached_players[j] == current_cooldowns[i].player then
							table.remove(cached_players, j)
							j=j-1
						end
						j=j+1
					end
					table.remove(current_cooldowns, i)
					i=i-1
				end
				i=i+1
			end
			
			for i=1,40,1 do
				local k = function()
					for j=1,#cached_players,1 do
						if cached_players[j] == UnitName("raid"..i) then return true end
					end
					return false
				end
				if (not k()) then
					local n = UnitName("raid"..i)
					local c = select(2, UnitClass("raid"..i))
					local f = UnitFactionGroup("raid"..i)
					for j=1,#global_cooldowns,1 do
						if global_cooldowns[j].class == c and (global_cooldowns[j].faction == f or global_cooldowns[j].faction == nil) then
							local t = {
								id = j,
								player = n,
								started = -1,
								status = 0
							}
							table.insert(current_cooldowns, t)
						end
					end
					table.insert(cached_players, n)
				end
			end
			
			local ncount = #current_cooldowns
			if pcount ~= ncount then  fr:SetRowCount(ncount) end
			sort_current_cooldowns()
			update_rows_info()
			cycle_update()
		end
		
		arcgui:RegisterEvent("PARTY_MEMBERS_CHANGED", update_cooldowns)
		
		update_count()
		cycle_update()
		move_stack()
		update_cooldowns()
		
		local function SpellCastHandler(unit,name,target,type,spellid)			
			for i=1,#current_cooldowns,1 do
				if (current_cooldowns[i].player == unit and global_cooldowns[current_cooldowns[i].id].name == name and global_cooldowns[current_cooldowns[i].id].type == type) then
					current_cooldowns[i].started = GetTime()
				end 
			end
		end

		function OnCombatLogEventUnfiltered(event, ...)
			if (UnitPlayerOrPetInRaid(select(4, ...))==1) or select(4, ...) == UnitName("player") then
				SpellCastHandler(select(4, ...),select(10, ...),select(7, ...),select(2, ...),select(9, ...))
			end
		end
		function OnSpellCastSucceeded(event, ...)
			unitname = UnitName(select(1, ...))
			if (UnitPlayerOrPetInRaid(unitname)==1) or unitname == UnitName("player") then
				SpellCastHandler(unitname,select(2, ...),nil,"_OnSucceded",nil)
			end
		end

		arcgui:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", OnCombatLogEventUnfiltered)
		arcgui:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", OnSpellCastSucceeded)
				
		arcgui.moptions = {
			type = "group",
			name = "RaidCooldown",
			args = {
				setskills = {
					type = "toggle",
					name = "Show",
					get = function(arg) return arcdb.enabled end,
					set = function(arg, val) arcdb.enabled = val if val then fr:Show() else fr:Hide() end end,
					order = 1,
				},
				maxincolumn = {
					type = "range",
					name = "maxincolumn",
					get = function(arg) return arcdb.maxincolumn end,
					set = function(arg, val) arcdb.maxincolumn = val update_count() end,
					order = 3,
					min=2,
					max=50,
					step=1,
				},
				maxcolumns = {
					type = "range",
					name = "maxcolumns",
					get = function(arg) return arcdb.maxcolumns end,
					set = function(arg, val) arcdb.maxcolumns = val update_count() end,
					order = 4,
					min=1,
					max=10,
					step=1,
				},
				rowscale = {
					type = "range",
					name = "rowscale",
					get = function(arg) return arcdb.rowscale end,
					set = function(arg, val) arcdb.rowscale = val update_count() end,
					order = 2,
					min=8,
					max=16,
					step=1,
				},
				posx = {
					type = "range",
					name = "posx",
					get = function(arg) return arcdb.posx end,
					set = function(arg, val) arcdb.posx = val move_stack() end,
					order = 5,
					min=0,
					max=floor(GetScreenWidth() * UIParent:GetEffectiveScale()),
					step=1,
				},
				posy = {
					type = "range",
					name = "posy",
					get = function(arg) return arcdb.posy end,
					set = function(arg, val) arcdb.posy = val move_stack() end,
					order = 6,
					min=0,
					max=floor(GetScreenHeight() * UIParent:GetEffectiveScale()),
					step=1,
				},
			},
		}
		
		table.insert(_gui.ModulesOptions, arcgui.moptions)

		
	end
end

Init()

local function OnAddonLoaded(event, addon)
	if addon=="VaNRLTGUI" then Init() end
end

local event = LibStub("AceEvent-3.0"):RegisterEvent("ADDON_LOADED", OnAddonLoaded)