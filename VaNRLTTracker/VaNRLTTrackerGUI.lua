local VaNRLTTrackerGUI
local _gui
local ac
local at
local atgui

local delNoTargetTable = {}
local delTargetTable = {}
local delDebugTable = {}
local catVal = 1

local function setOptSkills()
	atgui.moptions.args.optskills = {
		type = "group",
		name = "Настройки способностей",
		order = 3,
		args = {
			h0 = {
				type = "header",
				name = "Spells",
				order = 0,
			},
			h1 = {
				type = "header",
				name = "Tanks",
				order = 1000,
			},
		},
	}
	atgui.moptions.args.optdebug = {
		type = "group",
		name = "Отладка",
		order = 4,
		args = {
			debug = {
				type = "toggle",
				name = "Включить режим отладки",
				desc = "Режим отладки, используйте с умом (возможен флуд в рейд чат и зависания клиента если у вас слабый компьютер)",
				get = function(arg) return ac.db.global.Tracker.Debug end,
				set = function(arg, val) ac.db.global.Tracker.Debug = val end,
				order = 1,
			},
			h0 = {
				type = "header",
				name = "Способности для отладки",
				order = 2,
			},
		},
	}
	local options = atgui.moptions
	
	local j = #ac.db.global.Tracker.SpellTable.DEBUG
	for i = 1, j do
		options.args.optdebug.args[ac.db.global.Tracker.SpellTable.DEBUG[i][1]] = {
			type = "toggle",
			name = ac.db.global.Tracker.SpellTable.DEBUG[i][1],
			order = i+2,
			get = function(arg) return ac.db.global.Tracker.SpellTable.DEBUG[i][2] end,
			set = function(arg, val) ac.db.global.Tracker.SpellTable.DEBUG[i][2] = val end,
		}
	end
	
	j = #ac.db.global.Tracker.SpellTable.SPELLS
	for i = 1, j do
		local nm = ac.db.global.Tracker.SpellTable.SPELLS[i][2].."("..ac.db.global.Tracker.SpellTable.SPELLS[i][1]..")"
		options.args.optskills.args[nm] = {
			type = "toggle",
			name = ac.db.global.Tracker.SpellTable.SPELLS[i][2],
			desc = ac.db.global.Tracker.SpellTable.SPELLS[i][1],
			order = i,
			get = function(arg) return ac.db.global.Tracker.SpellTable.SPELLS[i][3] end,
			set = function(arg, val) ac.db.global.Tracker.SpellTable.SPELLS[i][3] = val end,
		}
	end
	j = #ac.db.global.Tracker.SpellTable.TANKS
	for i = 1, j do
		local nm = ac.db.global.Tracker.SpellTable.TANKS[i][1]
		options.args.optskills.args[nm] = {
			type = "toggle",
			name = ac.db.global.Tracker.SpellTable.TANKS[i][1],
			--desc = ac.db.global.Tracker.SpellTable.NOTARGET[i][1],
			order = i+1000,
			get = function(arg) return ac.db.global.Tracker.SpellTable.TANKS[i][2] end,
			set = function(arg, val) ac.db.global.Tracker.SpellTable.TANKS[i][2] = val end,
		}
	end
end

local function setSkills()
	HideUIPanel(GameTooltip)
	
	local j = 0
	
	local gui = LibStub("AceGUI-3.0")
	local frame = gui:Create("Frame")
	frame:SetTitle("Настройки способностей")
	frame:SetLayout("List")
	frame:SetCallback("OnClose", function(widget) gui:Release(widget) setOptSkills()end)
	frame:SetHeight(470)
	frame:SetWidth(500)
		
	local delHeader = gui:Create("Label")
	delHeader:SetText("\nУдаление способностей из отслеживания\n")
	frame:AddChild(delHeader)
	
	local delTarget = gui:Create("Dropdown")
	delTarget:SetLabel("Spells")
	delTarget:SetMultiselect(true)
	delTarget:SetWidth(470)
	frame:AddChild(delTarget)
	
	local delNoTarget = gui:Create("Dropdown")
	delNoTarget:SetLabel("Tanks")
	delNoTarget:SetMultiselect(true)
	delNoTarget:SetWidth(470)
	frame:AddChild(delNoTarget)
	
	local delDebug = gui:Create("Dropdown")
	delDebug:SetLabel("Debug")
	delDebug:SetMultiselect(true)
	delDebug:SetWidth(470)
	frame:AddChild(delDebug)
	
	local delButton = gui:Create("Button")
	delButton:SetText("Удалить")
	frame:AddChild(delButton)
	
	local addHeader = gui:Create("Label")
	addHeader:SetText("\nДобавление способностей для отслеживания\n")
	frame:AddChild(addHeader)
	
	local setCat = gui:Create("Dropdown")
	setCat:SetLabel("Категория")
	frame:AddChild(setCat)
	
	local setType = gui:Create("EditBox")
	setType:SetLabel("Тип")
	frame:AddChild(setType)
	
	local setName = gui:Create("EditBox")
	setName:SetLabel("Название")
	frame:AddChild(setName)
	
	local addButton = gui:Create("Button")
	addButton:SetText("Добавить")
	frame:AddChild(addButton)
	
	delNoTargetTable = {}
	delTargetTable = {}
	delDebugTable = {}
	catVal = 1
	
	local t ={}
	j = #ac.db.global.Tracker.SpellTable.DEBUG
	for i = 1, j do
		table.insert(t,ac.db.global.Tracker.SpellTable.DEBUG[i][1])
		table.insert(delDebugTable,{en=false,name=ac.db.global.Tracker.SpellTable.DEBUG[i][1]})
	end
	delDebug:SetList(t)
	
	t ={}
	j = #ac.db.global.Tracker.SpellTable.SPELLS
	for i = 1, j do
		table.insert(t,ac.db.global.Tracker.SpellTable.SPELLS[i][2].."("..ac.db.global.Tracker.SpellTable.SPELLS[i][1]..")")
		table.insert(delTargetTable,{en=false,name=ac.db.global.Tracker.SpellTable.SPELLS[i][2],type=ac.db.global.Tracker.SpellTable.SPELLS[i][1]})
	end
	delTarget:SetList(t)
	
	t ={}
	j = #ac.db.global.Tracker.SpellTable.TANKS
	for i = 1, j do
		table.insert(t,ac.db.global.Tracker.SpellTable.TANKS[i][1])
		table.insert(delNoTargetTable,{en=false,name=ac.db.global.Tracker.SpellTable.TANKS[i][1]})
	end
	delNoTarget:SetList(t)
	
	setCat:SetList({"Spells", "Tanks", "Debug"})
	setCat:SetValue(1)
	
	local i = 0
	delButton:SetCallback("OnClick",
		function (obj, event)
			local b = false
			for k, v in pairs(delNoTargetTable) do
				if v.en then
					j = #ac.db.global.Tracker.SpellTable.TANKS
					i=1
					while i<=j do
						if ac.db.global.Tracker.SpellTable.TANKS[i][1]==v.name then
							table.remove(ac.db.global.Tracker.SpellTable.TANKS,i)
							i=i-1
							j=j-1
							b = true
						end
						i=i+1
					end
				end
			end
			for k, v in pairs(delTargetTable) do
				if v.en then
					j = #ac.db.global.Tracker.SpellTable.SPELLS
					i=1
					while i<=j do
						if ac.db.global.Tracker.SpellTable.SPELLS[i][2]==v.name and ac.db.global.Tracker.SpellTable.SPELLS[i][1]==v.type then
							table.remove(ac.db.global.Tracker.SpellTable.SPELLS,i)
							i=i-1
							j=j-1
							b = true
						end
						i=i+1
					end
				end
			end
			for k, v in pairs(delDebugTable) do
				if v.en then
					j = #ac.db.global.Tracker.SpellTable.DEBUG
					i=1
					while i<=j do
						if ac.db.global.Tracker.SpellTable.DEBUG[i][1]==v.name then
							table.remove(ac.db.global.Tracker.SpellTable.DEBUG, i)
							i=i-1
							j=j-1
							b = true
						end
						i=i+1
					end
				end
			end
			if b then
				frame:Hide()
				_gui:RefreshMenus()
			end
		end
	)
	
	delNoTarget:SetCallback("OnValueChanged",
		function (obj, event, key)
			delNoTargetTable[key].en = not delNoTargetTable[key].en
		end
	)
	delTarget:SetCallback("OnValueChanged",
		function (obj, event, key)
			delTargetTable[key].en = not delTargetTable[key].en
		end
	)
	delDebug:SetCallback("OnValueChanged",
		function (obj, event, key)
			delDebugTable[key].en = not delDebugTable[key].en
		end
	)
	setCat:SetCallback("OnValueChanged",
		function (obj, event, key)
			catVal=key
			if key == 3 or key == 2 then
				setType:SetDisabled(true)
				setType:SetText("")
			else
				setType:SetDisabled(false)
			end
		end
	)
	addButton:SetCallback("OnClick",
		function (obj, event)
			local typeText = setType:GetText()
			local nameText = setName:GetText()
			if catVal == 3 and nameText~="" then
				j = #ac.db.global.Tracker.SpellTable.DEBUG
				local b = true
				for i = 1, j do
					if ac.db.global.Tracker.SpellTable.DEBUG[i][1] == nameText then b = false end
				end
				if b then
					table.insert(ac.db.global.Tracker.SpellTable.DEBUG, {nameText, true})
					frame:Hide()
					_gui:RefreshMenus()
				end
			elseif nameText~="" and typeText~="" then
				if catVal == 1 then
					j = #ac.db.global.Tracker.SpellTable.SPELLS
					local b = true
					for i = 1, j do
						if ac.db.global.Tracker.SpellTable.SPELLS[i][2] == nameText and ac.db.global.Tracker.SpellTable.SPELLS[i][1] == typeText then b = false end
					end
					if b then
						table.insert(ac.db.global.Tracker.SpellTable.SPELLS, {typeText, nameText, true})
						frame:Hide()
						_gui:RefreshMenus()
					end
				else
					j = #ac.db.global.Tracker.SpellTable.TANKS
					local b = true
					for i = 1, j do
						if ac.db.global.Tracker.SpellTable.TANKS[i][1] == nameText then b = false end
					end
					if b then
						table.insert(ac.db.global.Tracker.SpellTable.TANKS, {nameText, true})
						frame:Hide()
						_gui:RefreshMenus()
					end
				end
			end
		end
	)
end

local function Init()
	_gui = VaNRLT:GetModule("GUI", true)
	if _gui then
		local VaNRLTTrackerGUI = _gui:NewModule("TrackerGUI", {OnInitialize = "OnInitialize"}, "AceConsole-3.0")
		ac = VaNRLT
		at = VaNRLT:GetModule("Tracker")
		atgui = VaNRLTTrackerGUI
		
		atgui.moptions = {
			type = "group",
			name = "Трекер",
			args = {
				enable = {
					type = "toggle",
					name = "Включить трекер",
					desc = "Отображает наиболее важные способности, использованные участниками рейда",
					get = function(arg) return ac.db.global.Tracker.Enabled end,
					set = function(arg, val) ac.db.global.Tracker.Enabled = val end,
					order = 1,
				},
				setskills = {
					type = "execute",
					name = "Редактировать способности",
					func = setSkills,
					order = 2,
				},
			},
		}
		
		setOptSkills()
		
		table.insert(_gui.ModulesOptions, atgui.moptions)
		
		function VaNRLTTrackerGUI:OnInitialize()
			atgui:Print("Initialized")
		end
		
		function VaNRLTTrackerGUI:ResetSettings()
		setOptSkills()
		end
	end
end

Init()

local function OnAddonLoaded(event, addon)
	if addon=="VaNRLTGUI" then Init() end
end

local event = LibStub("AceEvent-3.0"):RegisterEvent("ADDON_LOADED", OnAddonLoaded)