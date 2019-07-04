local VaNRLTGUI = VaNRLT:NewModule("GUI", {OnInitialize = "OnInitialize"}, "AceConsole-3.0")
local ac = VaNRLT
local agui = VaNRLTGUI
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")

agui.ModulesOptions = {}
agui.MenuButtons = {}

function agui:RefreshMenus()
	if InterfaceOptionsFramePanelContainer.displayedPanel then
		InterfaceOptionsFrame:Hide()
		InterfaceOptionsFrame_OpenToCategory(InterfaceOptionsFramePanelContainer.displayedPanel)
	end
end

local function InitMenus()
	local options = {
		type = "group",
		get = "GetValue",
		set = "SetValue",
		name = "Насторойки аддона",
		args = {
			h0 = {
				type = "header",
				name = "",
				order = 999,
			},
			hc = {
				type = "description",
				name = "Copyright Azewrath и Кадавр 2014-16\nПожалуйста прочитайте файл Copyright.txt в папке с основным аддоном",
				order = 1000,
				fontSize = "medium",
			},
			reset = {
				type = "execute",
				name = "Сбросить настройки",
				order = 1,
				confirm = function() return "Вы действительно хотите сбросить все настройки?" end,
				func = function() ac:ResetDBToDefault()  end,
			},
			h1 = {
				type = "header",
				name = "Общие настройки",
				order = 2,
			},
			colornick = {
				type = "toggle",
				name = "Выделять ники цветом",
				desc = "Выделение ников во всех сообщениях цветом, не используйте если это запрещено на вашем сервере",
				get = function(arg) return ac.db.global.ColorNick end,
				set = function(arg, val) ac.db.global.ColorNick = val end,
				order = 3,
			},
		}
	}
	
	acr:RegisterOptionsTable("VaNRLTGUI", options)
	agui.OptionsRef = acd:AddToBlizOptions("VaNRLTGUI", "VaNRLTGUI")
	
	for i, f in pairs(agui.ModulesOptions) do
		f.order = i
		acr:RegisterOptionsTable("VaNRLTGUI"..f.name, f)
		acd:AddToBlizOptions("VaNRLTGUI"..f.name, f.name, "VaNRLTGUI")
	end
	
	local menuframe = {
		type = "group",
		name = "Меню",
		args = agui.MenuButtons
	}
	
	acr:RegisterOptionsTable("VaNRLTGUIMenu", menuframe)
end

function VaNRLTGUI:ResetSettings()
	ac.db.global.Minimap = {
		["Dist"] = 80,
	}
	ac.db.global.ColorNick = false
	for name, module in VaNRLTGUI:IterateModules() do
		module:ResetSettings()
	end
	agui:RefreshMenus()
end

if not ac.db.global.Minimap then
	VaNRLTGUI:ResetSettings()
end

local mMinimap
local mMinimapDragging = false

local function VaNRLTGUI_MinimapButton_OnUpdate(self, elapsed)
	local mx, my = Minimap:GetCenter()
	local cx, cy = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	local angle = math.atan2(cy/scale - my, cx/scale - mx)
	local x, y = math.cos(angle) * ac.db.global.Minimap.Dist, math.sin(angle) * ac.db.global.Minimap.Dist
	mMinimap:SetPoint("CENTER", x, y)
end

function VaNRLTGUI_MinimapButton_OnClick(self, button, down)
	if(button == "LeftButton") then
		acd:Open("VaNRLTGUIMenu")
	elseif(button == "RightButton") then
		InterfaceOptionsFrame_OpenToCategory(agui.OptionsRef)
	end
end

function VaNRLTGUI:OnInitialize()
	--ac:UnregisterChatCommand("vanrlt");
	--agui:RegisterChatCommand("vanrlt", "SlashHandler")
	
	mMinimap = CreateFrame("BUTTON", "VaNRLTGUI_MinimapButton", Minimap)
	mMinimap:SetWidth(32)
    mMinimap:SetHeight(32)
    mMinimap:SetFrameStrata("LOW")
	local x, y = math.cos(0) * ac.db.global.Minimap.Dist, math.sin(0) * ac.db.global.Minimap.Dist
	mMinimap:SetPoint("CENTER", x, y)
	mMinimap:EnableMouse(true)
	mMinimap:RegisterForDrag("LeftButton")
	mMinimap:RegisterForClicks("AnyUp")
	mMinimap:SetScript("OnDragStart", function (self,button)
		mMinimapDragging = true
		mMinimap:SetScript("OnUpdate", VaNRLTGUI_MinimapButton_OnUpdate)
		GameTooltip:SetOwner(UIParent)
		GameTooltip:SetText("")
		HideUIPanel(GameTooltip)
	end)
	mMinimap:SetScript("OnDragStop", function (self)
		mMinimapDragging = false
		mMinimap:SetScript("OnUpdate", nil)
	end)
	mMinimap:SetScript("OnEnter", function (self, motion)
		if mMinimapDragging then do return end end
		GameTooltip:SetOwner(mMinimap)
		GameTooltip:SetText("VaNRLT GUI\nЛевый клик для меню\nПравый клик для настроек")
		
		ShowUIPanel(GameTooltip)
	end)
	mMinimap:SetScript("OnLeave", function (self, motion) 
		GameTooltip:SetOwner(UIParent)
		GameTooltip:SetText("")
		HideUIPanel(GameTooltip)
	end)
	mMinimap:SetScript("OnClick", VaNRLTGUI_MinimapButton_OnClick)
		
	mMinimap.icon = mMinimap:CreateTexture(nil, "BACKGROUND")
	mMinimap.icon:SetTexture("interface\\addons\\vanrltgui\\tex")
	mMinimap.icon:SetWidth(22);
    mMinimap.icon:SetHeight(22);
	mMinimap.icon:SetPoint("CENTER", 0, 0)
		
	mMinimap.border = mMinimap:CreateTexture(nil, "ARTWORK")
	mMinimap.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	mMinimap.border:SetTexCoord(0,0.6,0,0.6);
    mMinimap.border:SetAllPoints(mMinimap);
	
	agui:Print("Initialized")
end

--[[function VaNRLTGUI:SlashHandler(command)
	agui:Print("GUI включен, используйте его")
end]]

local function OnEnteringWorld(event)
	InitMenus()
end

local event = LibStub("AceEvent-3.0"):RegisterEvent("PLAYER_ENTERING_WORLD", OnEnteringWorld)