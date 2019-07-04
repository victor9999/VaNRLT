local VaNRLTEPGPPenaltyGUI
local _gui
local ac
local aep
local aepgui

local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")

local function Init()
	local _gui = VaNRLT:GetModule("GUI", true)
	if _gui then
		local VaNRLTEPGPPenaltyGUI = _gui:NewModule("EPGPPenaltyGUI", {OnInitialize = "OnInitialize"}, "AceConsole-3.0")
		ac = VaNRLT
		aep = VaNRLT:GetModule("EPGPPenalty")
		aepgui = VaNRLTEPGPPenaltyGUI
		local options = {
			type = "group",
			name = "Штрафы",
			args = {
				difficulty = {
					type = "group",
					name = "Сложности",
					order = 1,
					args = {
					},
				},
				other = {
					type = "group",
					name = "Другое",
					order = 2,
					args = {
						low = {
							type = "input",
							name = "Мелкий косяк",
							get = function(arg) return tostring(ac.db.global.EPGPPenalty.low) end,
							set = function(arg, val) ac.db.global.EPGPPenalty.low = (tonumber(val) or tostring(ac.db.global.EPGPPenalty.low)) end,
							order = 1,
						},
						wipe = {
							type = "input",
							name = "Вайп",
							get = function(arg) return tostring(ac.db.global.EPGPPenalty.wipe) end,
							set = function(arg, val) ac.db.global.EPGPPenalty.wipe = (tonumber(val) or tostring(ac.db.global.EPGPPenalty.wipe)) end,
							order = 2,
						},
						bonus = {
							type = "input",
							name = "Босс без смертей",
							get = function(arg) return tostring(ac.db.global.EPGPPenalty.bonus) end,
							set = function(arg, val) ac.db.global.EPGPPenalty.bonus = (tonumber(val) or tostring(ac.db.global.EPGPPenalty.bonus)) end,
							order = 3,
						},
						t = {
							type = "select",
							name = "Юнит",
							get = function(arg) return ac.db.global.EPGPPenalty.type end,
							set = function(arg, val) ac.db.global.EPGPPenalty.type = val end,
							order = 4,
							values = {
								["mouseover"] = "mouseover",
								["target"] = "target",
							},
						},
						-- posx = {
						-- 	type = "input",
						-- 	name = "Позиция по умолчанию x",
						-- 	get = function(arg) return tostring(ac.db.global.EPGPPenalty.posx) end,
						-- 	set = function(arg, val) ac.db.global.EPGPPenalty.posx = (tonumber(val) or tostring(ac.db.global.EPGPPenalty.posx)) end,
						-- 	order = 5,
						-- },
						-- posy = {
						-- 	type = "input",
						-- 	name = "Позиция по умолчанию y",
						-- 	get = function(arg) return tostring(ac.db.global.EPGPPenalty.posy) end,
						-- 	set = function(arg, val) ac.db.global.EPGPPenalty.posy = (tonumber(val) or tostring(ac.db.global.EPGPPenalty.posy)) end,
						-- 	order = 6,
						-- },
					},
				},
			},
		}

		local idinst = 100
		for inst,insttable in pairs(ac.db.global.EPGPPenalty.bosses) do
			options.args[inst] = {
				type = "group",
				name = inst,
				order = idinst,
				args = {
				},
			}
			idinst = idinst + 1

			for i=1,#insttable do
				local boss = insttable[i][1]
				options.args[inst].args[boss] = {
					type = "input",
					name = boss,
					get = function(arg) return tostring(ac.db.global.EPGPPenalty.bosses[inst][i][2]) end,
					set = function(arg, val) ac.db.global.EPGPPenalty.bosses[inst][i][2] = (tonumber(val) or tostring(ac.db.global.EPGPPenalty.bosses[inst][i][2])) end,
					order = i,
				}
			end
		end

		for i=1,#ac.db.global.EPGPPenalty.difficulty do
			difficulty = ac.db.global.EPGPPenalty.difficulty[i][1]
			options.args.difficulty.args[difficulty] = {
				type = "input",
				name = difficulty,
				get = function(arg) return tostring(ac.db.global.EPGPPenalty.difficulty[i][2]) end,
				set = function(arg, val) ac.db.global.EPGPPenalty.difficulty[i][2] = (tonumber(val) or tostring(ac.db.global.EPGPPenalty.difficulty[i][2])) end,
				order = i,
			}
		end

		table.insert(_gui.ModulesOptions, options)

		local function get_base_ep(inst, boss_id, difficulty_id)
			local base_ep =  ac.db.global.EPGPPenalty.bosses[inst][boss_id][2]
			local difficulty_mul = ac.db.global.EPGPPenalty.difficulty[difficulty_id][2]
			local ep = base_ep * difficulty_mul
			return ep
		end

		local trackerframe = nil

		do
			local gui = LibStub("AceGUI-3.0")
			trackerframe = gui:Create("Frame")
			trackerframe:SetTitle("EPGP")
			trackerframe:SetLayout("List")
			trackerframe:SetCallback("OnClose", function(widget) end)
			trackerframe:SetHeight(230)
			trackerframe:SetWidth(200)
			trackerframe:Hide()
			-- trackerframe:SetPoint("topleft", UIParent, "topleft", ac.db.global.EPGPPenalty.posx, ac.db.global.EPGPPenalty.posy)

			-- trackerframe:SetCallback("OnClose",
			-- 	function() 
			-- 		point = {trackerframe:GetPoint("topleft", UIParent, "topleft")}
			-- 		ac.db.global.EPGPPenalty.posx, ac.db.global.EPGPPenalty.posy = point[4], point[5]
			-- 	end
			-- )

			local cur_inst = nil
			local cur_boss = nil

			local inst_dropdown = gui:Create("Dropdown")
			trackerframe:AddChild(inst_dropdown)
			inst_dropdown:SetList({})
			inst_dropdown:SetWidth(170)

			for inst,insttable in pairs(ac.db.global.EPGPPenalty.bosses) do
				inst_dropdown:AddItem(inst, inst)
				cur_inst = inst
			end

			local boss_dropdown = gui:Create("Dropdown")
			trackerframe:AddChild(boss_dropdown)
			boss_dropdown:SetWidth(170)

			local inst_changed = function(w, e, key) 
				cur_inst = key
				boss_dropdown:SetList({})
				for i=1,#ac.db.global.EPGPPenalty.bosses[key] do
					local boss = ac.db.global.EPGPPenalty.bosses[key][i][1]
					boss_dropdown:AddItem(i, boss)
				end
				boss_dropdown:SetValue(1)
				cur_boss = 1
			end

			inst_dropdown:SetCallback("OnValueChanged", inst_changed)

			local boss_changed = function(w, e, key) 
				cur_boss = key
			end

			boss_dropdown:SetCallback("OnValueChanged", boss_changed)

			inst_changed(nil, nil, cur_inst)
			inst_dropdown:SetValue(cur_inst)

			local give_ep = gui:Create("Button")
			trackerframe:AddChild(give_ep)
			give_ep:SetText("Начислить EP")
			give_ep:SetCallback("OnClick", 
				function()
					if not UnitInRaid("player") then return end
					local difficulty = GetRaidDifficulty()
					local ep = get_base_ep(cur_inst, cur_boss, difficulty)
					ep = math.floor(ep)
					EPGP:IncMassEPBy(cur_inst.." - "..ac.db.global.EPGPPenalty.bosses[cur_inst][cur_boss][1], ep)
				end
			)
			give_ep:SetWidth(170)

			local give_ep_no_deaths = gui:Create("Button")
			trackerframe:AddChild(give_ep_no_deaths)
			give_ep_no_deaths:SetText("Начислить EP(Без смертей)")
			give_ep_no_deaths:SetCallback("OnClick", 
				function()
					if not UnitInRaid("player") then return end
					local difficulty = GetRaidDifficulty()
					local ep = get_base_ep(cur_inst, cur_boss, difficulty) * ac.db.global.EPGPPenalty.bonus
					ep = math.floor(ep)
					EPGP:IncMassEPBy(cur_inst.." - "..ac.db.global.EPGPPenalty.bosses[cur_inst][cur_boss][1].." (Без смертей)", ep)
				end
			)
			give_ep_no_deaths:SetWidth(170)

			local next_boss = gui:Create("Button")
			trackerframe:AddChild(next_boss)
			next_boss:SetText("Следующий босс")
			next_boss:SetCallback("OnClick", 
				function()
					if cur_boss < #ac.db.global.EPGPPenalty.bosses[cur_inst] then
						cur_boss = cur_boss + 1
						boss_dropdown:SetValue(cur_boss)
					end
				end
			)
			next_boss:SetWidth(170)

			aep.low_penalty_signal:connect(
				function()
					local difficulty = GetRaidDifficulty()
					local ep = get_base_ep(cur_inst, cur_boss, difficulty) * ac.db.global.EPGPPenalty.low
					ep = math.floor(ep)
					local unit = UnitName(ac.db.global.EPGPPenalty.type)
					if unit ~= nil and ep > 0 then
						EPGP:IncEPBy(unit, cur_inst.." - "..ac.db.global.EPGPPenalty.bosses[cur_inst][cur_boss][1].." - Косяк", -ep)
					end
				end
			)
			aep.wipe_penalty_signal:connect(
				function()
					local difficulty = GetRaidDifficulty()
					local ep = get_base_ep(cur_inst, cur_boss, difficulty) * ac.db.global.EPGPPenalty.wipe
					ep = math.floor(ep)
					local unit = UnitName(ac.db.global.EPGPPenalty.type)
					if unit ~= nil and ep > 0 then
						EPGP:IncEPBy(unit, cur_inst.." - "..ac.db.global.EPGPPenalty.bosses[cur_inst][cur_boss][1].." - Вайп", -ep)
					end
				end
			)
		end

		local t = 1
		for _, _ in pairs(_gui.MenuButtons) do t=t+1 end

		_gui.MenuButtons["EPGPPenaltyHeader"] = {
			type = "header",
			name = "Штрафы",
			order=t,
		}

		_gui.MenuButtons["EPGPPenaltyButton"] = {
			type = "execute",
			name = "Штрафы",
			func = function(arg) HideUIPanel(GameTooltip) acd:Close("VaNRLTGUIMenu") trackerframe:Show() end,
			order=t+1,
		}

		
		
		function VaNRLTEPGPPenaltyGUI:OnInitialize()
			aepgui:Print("Initialized")
		end
		
		function VaNRLTEPGPPenaltyGUI:ResetSettings()
		
		end
	end
end

Init()

local function OnAddonLoaded(event, addon)
	if addon=="VaNRLTGUI" then Init() end
end

local event = LibStub("AceEvent-3.0"):RegisterEvent("ADDON_LOADED", OnAddonLoaded)