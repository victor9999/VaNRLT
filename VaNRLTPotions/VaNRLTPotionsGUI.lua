local VaNRLTPotionsGUI
local _gui
local ac
local apgui
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local locale = VaNRLT.locale


local PotionsTrade = false
local textView1

local function getslotid(itemname)
	local t={}
	for bag = 0, 4 do
		for item = 1, GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag, item)
			local _, _, _, _, Id, _, _, _, _, _, _, _, _, _, _,  Name =
				string.find(itemLink or "", "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
			if Name == itemname then table.insert(t, {bag,item}) end
		end
	end
	return t
end

local function addLog(str)
	ac.db.global.Potions.frametext=ac.db.global.Potions.frametext..str.."\n"
	textView1:SetText(ac.db.global.Potions.frametext)
end

local nick, spec = "", ""
local optionsopen = false
local logopen = false

local function OnTradeAcceptUpdate(role,event,arg1,arg2)
	if arg1 == 1 and arg2 == 1 then
		apgui:UnregisterEvent("TRADE_ACCEPT_UPDATE")
		addLog("Выдан набор ["..role.."] для персонажа ["..nick.."] спек ["..spec.."]")
		ac.db.global.Potions.charsgiven[nick]=1
	end
end

local GivePotOperations={}
local selectroleframe = nil

local function OnTradeClosed()
	ClearCursor()
	ac:DelayFunc("gpo", 0.01, function() end)
	if selectroleframe then
		selectroleframe:Hide()
	end
end

local function ifOnUpdate()
	local operation = GivePotOperations[1]
	if operation[1] == "pickcount" then
		SplitContainerItem(operation[2], operation[3], operation[4])
		if not CursorHasItem() then ac:DelayFunc("gpo", 0.01, ifOnUpdate) do return end end
	elseif operation[1] == "pick" then
		PickupContainerItem(operation[2], operation[3])
		if not CursorHasItem() then ac:DelayFunc("gpo", 0.01, ifOnUpdate) do return end end
	elseif operation[1] == "place" then
		PickupContainerItem(operation[2], operation[3])
		if CursorHasItem() then ac:DelayFunc("gpo", 0.01, ifOnUpdate) do return end end
	elseif operation[1] == "placetrade" then
		ClickTradeButton(operation[2])
		if CursorHasItem() then ac:DelayFunc("gpo", 0.01, ifOnUpdate) do return end end
	end
	table.remove(GivePotOperations, 1)
	if #GivePotOperations >0 then ac:DelayFunc("gpo", 0.01, ifOnUpdate) end
end



local function GivePot(role)
	ClearCursor()
	GivePotOperations={}
	local emptyslots = getslotid(nil)
	if #emptyslots < #ac.db.global.Potions.rolespotions[role] then apgui:Print("Not enough space in bags") CancelTrade() do return end end
	for i = 1,#ac.db.global.Potions.rolespotions[role] do
		if ac.db.global.Potions.rolespotions[role][i][2] > 0 then
			local itemslot = getslotid(ac.db.global.Potions.rolespotions[role][i][1])
			if #itemslot == 0 or GetItemCount(ac.db.global.Potions.rolespotions[role][i][1])<ac.db.global.Potions.rolespotions[role][i][2] then apgui:Print("Not enough items in bags") CancelTrade() do return end end
			
			local _,count = GetContainerItemInfo(itemslot[1][1],itemslot[1][2])
			while true do
				if count<ac.db.global.Potions.rolespotions[role][i][2] then
					table.insert(GivePotOperations, {"pick", itemslot[#itemslot][1],itemslot[#itemslot][2]})
					table.insert(GivePotOperations, {"place", itemslot[1][1],itemslot[1][2]})
					local _,count1 = GetContainerItemInfo(itemslot[#itemslot][1],itemslot[#itemslot][2])
					count=count+count1
					if count>=ac.db.global.Potions.rolespotions[role][i][2] then break
					elseif count<=20 then table.remove(itemslot, #itemslot)
					end
				else
					break
				end
			end
			
			table.insert(GivePotOperations, {"pickcount", itemslot[1][1],itemslot[1][2],ac.db.global.Potions.rolespotions[role][i][2]})
			table.insert(GivePotOperations, {"place", emptyslots[i][1],emptyslots[i][2]})
			table.insert(GivePotOperations, {"pick", emptyslots[i][1],emptyslots[i][2]})
			table.insert(GivePotOperations, {"placetrade",i})
		end
	end
	ac:DelayFunc("gpo", 0.01, ifOnUpdate)
	apgui:RegisterEvent("TRADE_ACCEPT_UPDATE", OnTradeAcceptUpdate, role)
end

local function ShowSelectRoleMenu(vars)
	HideUIPanel(GameTooltip)
	local gui = LibStub("AceGUI-3.0")
	local frame = gui:Create("Frame")
	frame:SetTitle("Выберите роль")
	frame:SetLayout("List")
	frame:SetHeight(300)
	frame:SetWidth(300)
	frame.notcanceltrade=false
	frame:SetCallback("OnClose", 
		function(widget)
			selectroleframe = nil
			if not widget.notcanceltrade then CancelTrade() end
			gui:Release(widget)
		end
	)
	
	local nickLabel = gui:Create("Label")
	nickLabel:SetText(nick)
	frame:AddChild(nickLabel)
	for i = 1, #vars do
		local roleButton = gui:Create("Button")
		roleButton:SetText(vars[i])
		frame:AddChild(roleButton)
		roleButton:SetCallback("OnClick", function() frame.notcanceltrade=true frame:Hide() GivePot(vars[i])end)
	end
	
	selectroleframe = frame
end

local function OnInspectTalentReady()
	if nick then
		apgui:UnregisterEvent("INSPECT_TALENT_READY")
		local _,_,s1,n1 = GetTalentTabInfo(1,true,false,GetActiveTalentGroup(true))
		local _,_,s2,n2 = GetTalentTabInfo(2,true,false,GetActiveTalentGroup(true))
		local _,_,s3,n3 = GetTalentTabInfo(3,true,false,GetActiveTalentGroup(true))
		if s1>s2 and s1>s3 then 
			spec = n1 
		elseif s2>s3 and s2>s1 then
			spec = n2
		elseif s3>s1 and s3>s2 then
			spec = n3
		else
			spec = "Unknown"
			ShowSelectRoleMenu({"ap","spd","heal","tank"})
			do return end
		end
		if #ac.db.global.Potions.specsroles[spec] >1 then
			ShowSelectRoleMenu(ac.db.global.Potions.specsroles[spec])
		else
			GivePot(ac.db.global.Potions.specsroles[spec][1])
		end
	end
end

local function OnTradeShow()
	if not PotionsTrade then do return end end 
	nick = GetUnitName("NPC")
	if ac.db.global.Potions.charsgiven[nick]~=nil then CancelTrade() do return end end
	
	if CheckInteractDistance(nick, 1) and CanInspect(nick) then
		apgui:RegisterEvent("INSPECT_TALENT_READY", OnInspectTalentReady)
		NotifyInspect(nick)
	else
		CancelTrade()
	end
end

local refshowoptions

local function ShowForm()
	if logopen then do return end end
	logopen = true
	acd:Close("VaNRLTGUIMenu")
	HideUIPanel(GameTooltip)
	
	local gui = LibStub("AceGUI-3.0")
	local frame = gui:Create("Frame")
	frame:SetTitle("Идет раздача зелий")
	frame:SetLayout("List")
	frame:SetHeight(500)
	frame:SetWidth(500)
	
	local scrollContainer = gui:Create("SimpleGroup")
	scrollContainer:SetFullWidth(true)
	scrollContainer:SetFullHeight(true)
	scrollContainer:SetHeight(400)
	
	scrollContainer:SetLayout("Fill")
	frame:AddChild(scrollContainer)
	
	local scroll = gui:Create("ScrollFrame")
	scroll:SetLayout("List")
	scrollContainer:AddChild(scroll)
	
	textView1 = gui:Create("Label")
	textView1:SetText(ac.db.global.Potions.frametext)
	textView1:SetFullWidth(true)
	textView1:SetFullHeight(true)
	scroll:AddChild(textView1)
	
	local stop = gui:Create("Button")
	stop:SetText("Завершить раздачу")
	frame:AddChild(stop)
	stop:SetCallback("OnClick", 
		function() 
			PotionsTrade = false
			_gui.MenuButtons["PotionsButton"].name = "Начать раздачу зелий"
			_gui.MenuButtons["PotionsButton"].func = function(arg) refshowoptions() end
			optionsopen=false
			logopen = false
			apgui:UnregisterEvent("TRADE_SHOW")
			frame:Hide()
			apgui:Print("Раздача окончена")
		end
	)
	frame:SetCallback("OnClose", 
		function(widget) 
			logopen=false
			gui:Release(widget)
		end
	)
end

local function ShowOptions()
	if optionsopen then do return end end
	optionsopen=true
	acd:Close("VaNRLTGUIMenu")
	HideUIPanel(GameTooltip)
		
	local gui = LibStub("AceGUI-3.0")
	local frame = gui:Create("Frame")
	frame:SetTitle("Настройки раздачи зелий")
	frame:SetLayout("List")
	frame:SetCallback("OnClose", function(widget) optionsopen = false gui:Release(widget) end)
	frame:SetHeight(450)
	frame:SetWidth(300)
	
	local scrollContainer = gui:Create("SimpleGroup")
	scrollContainer:SetFullWidth(true)
	scrollContainer:SetFullHeight(true)
	scrollContainer:SetHeight(360)
	
	scrollContainer:SetLayout("Fill")
	frame:AddChild(scrollContainer)
	
	local scroll = gui:Create("ScrollFrame")
	scroll:SetLayout("List")
	scrollContainer:AddChild(scroll)
		
	for rp, _ in pairs(ac.db.global.Potions.rolespotions) do
		local h = gui:Create("Label")
		h:SetText(rp)
		scroll:AddChild(h)
		for f = 1, #ac.db.global.Potions.rolespotions[rp] do
			local cb = gui:Create("Slider")
			cb:SetLabel(ac.db.global.Potions.rolespotions[rp][f][1])
			cb:SetValue(ac.db.global.Potions.rolespotions[rp][f][2])
			cb:SetSliderValues(0,20,1)
			cb:SetCallback("OnValueChanged",
				function(widget,event, val)
					ac.db.global.Potions.rolespotions[rp][f][2] = val
				end
			)
			scroll:AddChild(cb)
		end
	end
	
	
	local sb = gui:Create("Button")
	sb:SetText("Начать раздачу")
	sb:SetCallback("OnClick",
		function()
			PotionsTrade = true
			_gui.MenuButtons["PotionsButton"].name = "Показать статус раздачи"
			_gui.MenuButtons["PotionsButton"].func = function(arg) ShowForm() end
			apgui:RegisterEvent("TRADE_SHOW", OnTradeShow)
			apgui:RegisterEvent("TRADE_CLOSED", OnTradeClosed)
			frame:Hide()
			ShowForm()
			apgui:Print("Раздача начата")
		end
	)
	frame:AddChild(sb)
end

local function clearlog()
	ac.db.global.Potions.charsgiven={}
	ac.db.global.Potions.frametext = "Список людей получивших зелья:\n"
	if textView1 then
		textView1:SetText(ac.db.global.Potions.frametext)
	end
end

local function refreshmenus()
	apgui.options.args.pot_roles.args={}
	--[[apgui.options.args.pot_roles.disabled = true
	if ac.db.global.Potions then
		if ac.db.global.Potions.rolespotions then
			local t = 0
			for _,_ in pairs(ac.db.global.Potions.rolespotions) do t=t+1 end
			if t>0 then
				apgui.options.args.pot_roles.disabled = false
			end
		end
	end]]
	--if apgui.options.args.pot_roles.disabled == false then
		local t=1
		--[[apgui.options.args.pot_roles.args["_addnew"]={
			type = "input",
			name = "Добавить набор",
			order = t,
			get = function(arg) return "" end,
			set = function(arg,value) if value ~= "" then ac.db.global.Potions.rolespotions[value]={} refreshmenus() end end,
		}
		t=t+1]]
		for k,_ in pairs(ac.db.global.Potions.rolespotions) do
			apgui.options.args.pot_roles.args[k.."_header"]={
				type = "header",
				name = k,
				order = t,
			}
			t=t+1
			--[[apgui.options.args.pot_roles.args[k.."_delButton"]={
				type = "execute",
				name = "Удалить набор",
				order = t,
				func = function()ac.db.global.Potions.rolespotions[k]=nil refreshmenus() end,
			}
			t=t+1]]
			apgui.options.args.pot_roles.args[k.."_break"]={
				type = "description",
				name = "",
				order = t,
			}
			t=t+1
			for i=1,#ac.db.global.Potions.rolespotions[k] do
				apgui.options.args.pot_roles.args[k..ac.db.global.Potions.rolespotions[k][i][1]]={
					type = "input",
					name = "",
					order = t,
					get = function(arg) return ac.db.global.Potions.rolespotions[k][i][1] end,
					set = function(arg,value) if value == "" then table.remove(ac.db.global.Potions.rolespotions[k], i) refreshmenus() else ac.db.global.Potions.rolespotions[k][i][1] = value end end,
				}
				t=t+1
				apgui.options.args.pot_roles.args[k..ac.db.global.Potions.rolespotions[k][i][1].."_break"]={
					type = "description",
					name = "",
					order = t,
				}
				t=t+1
			end
			if #ac.db.global.Potions.rolespotions[k]<6 then
				apgui.options.args.pot_roles.args[k.."_addnew"]={
					type = "input",
					name = "Добавить предмет",
					order = t,
					get = function(arg) return "" end,
					set = function(arg,value) if value ~= "" then table.insert(ac.db.global.Potions.rolespotions[k], {value, 0}) refreshmenus() end end,
				}
				t=t+1
			end
		end
	--end
	
	--[[apgui.options.args.spec_roles.args={}
	if apgui.options.args.spec_roles.disabled == false then
		local t=1
		for k,_ in pairs(ac.db.global.Potions.specsroles) do
				apgui.options.args.spec_roles.args[k]={
					type = "input",
					name = "",
					order = t,
					get = function(arg) return k end,
					set = function(arg,value) if value == "" then apgui:Print("Название спека не может быть пустым") else ac.db.global.Potions.specsroles[value] = ac.db.global.Potions.specsroles[k] ac.db.global.Potions.specsroles[k] = nil refreshmenus() end end,
				}
				t=t+1
				
				apgui.options.args.spec_roles.args[k.."_break"]={
					type = "description",
					name = "",
					order = t,
				}
				t=t+1
		end
	end]]
	
	_gui:RefreshMenus()
end

local function Init()
	_gui = VaNRLT:GetModule("GUI", true)
	if _gui then
		VaNRLTPotionsGUI = _gui:NewModule("PotionsGUI", {OnInitialize = "OnInitialize"}, "AceConsole-3.0", "AceEvent-3.0")
		ac = VaNRLT
		apgui = VaNRLTPotionsGUI
		
		refshowoptions=ShowOptions
		local t = 1
		for _, _ in pairs(_gui.MenuButtons) do t=t+1 end
		
		_gui.MenuButtons["PotionsHeader"] = {
			type = "header",
			name = "Раздача зелий",
			order=t,
		}
		
		_gui.MenuButtons["PotionsButtonClear"] = {
			type = "execute",
			name = "Очистить список людей, которым выданы зелья",
			func = function(arg) clearlog() apgui:Print("Очищено") end,
			order=t+2,
		}
		_gui.MenuButtons["PotionsButton"] = {
			type = "execute",
			name = "Начать раздачу зелий",
			func = function(arg) ShowOptions() end,
			order=t+1,
		}
		
		function VaNRLTPotionsGUI:ResetSettings1()
			ac.db.global.Potions={}
			ac.db.global.Potions.rolespotions={
				ap={
					{locale.flask_ap,2},
					{locale.flask_haste,2},
				},
				spd={
					{locale.flask_spd,2},
					{locale.flask_critspd,2},
				},
				heal={
					{locale.flask_spd,2},
					{locale.flask_mana,5},
				},
				tank={
					{locale.flask_hp,2},
					{locale.flask_armor,5},
				},
			}

			ac.db.global.Potions.specsroles = {
				["DeathKnightBlood"]={"ap","tank"},
				["DeathKnightFrost"]={"ap","tank"},
				["DeathKnightUnholy"]={"ap","tank"},
				
				["DruidBalance"]={"spd"},
				["DruidFeralCombat"]={"ap","tank"},
				["DruidRestoration"]={"heal"},
				
				["HunterBeastMastery"]={"ap"},
				["HunterMarksmanship"]={"ap"},
				["HunterSurvival"]={"ap"},
				
				["MageArcane"]={"spd"},
				["MageFire"]={"spd"},
				["MageFrost"]={"spd"},
				
				["PaladinHoly"]={"heal"},
				["PaladinProtection"]={"tank"},
				["PaladinCombat"]={"ap"},
				
				["PriestDiscipline"]={"heal"},
				["PriestHoly"]={"heal",},
				["PriestShadow"]={"spd"},
				
				["RogueAssassination"]={"ap"},
				["RogueCombat"]={"ap"},
				["RogueSubtlety"]={"ap"},
				
				["ShamanElementalCombat"]={"spd"},
				["ShamanEnhancement"]={"ap"},
				["ShamanRestoration"]={"heal"},
				
				["WarlockCurses"]={"spd"},
				["WarlockSummoning"]={"spd"},
				["WarlockDestruction"]={"spd"},
				
				["WarriorArms"]={"ap"},
				["WarriorFury"]={"ap"},
				["WarriorProtection"]={"tank"},
			}
			clearlog()
		end
		
		
		apgui.options = {
			type = "group",
			name = "Раздача зелий",
			args = {
				reset_settings = {
					type = "execute",
					name = "Загрузить настройки по умолчанию",
					func = function(arg) VaNRLTPotionsGUI:ResetSettings1() refreshmenus() end,
					order = 1,
				},
				pot_roles = {
					type = "group",
					name = "Наборы зелий",
					order = 2,
					args = {
					},
				},
				--[[spec_roles = {
					type = "group",
					name = "Спеки",
					order = 3,
					args = {
					},
				}]]
			},
		}
		table.insert(_gui.ModulesOptions, apgui.options)
		refreshmenus()
		
		function VaNRLTPotionsGUI:OnInitialize()
			apgui:Print("Initialized")
		end
		
		function VaNRLTPotionsGUI:ResetSettings()
			apgui:Print("Общий сброс настроек не трогает настройки этого модуля")
		end
		
		
		if not ac.db.global.Potions then VaNRLTPotionsGUI:ResetSettings1() end
	end
end

Init()

local function OnAddonLoaded(event, addon)
	if addon=="VaNRLTGUI" then Init() end
end


local event = LibStub("AceEvent-3.0"):RegisterEvent("ADDON_LOADED", OnAddonLoaded)
