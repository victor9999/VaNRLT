local VaNRLTEPGPGUI
local _gui
local ac
local aepgp
local aepgpgui
local acd = LibStub("AceConfigDialog-3.0")

local function Init()
	_gui = VaNRLT:GetModule("GUI", true)
	if _gui then
		local VaNRLTEPGPGUI = _gui:NewModule("EPGPGUI", {OnInitialize = "OnInitialize"}, "AceConsole-3.0")
		ac = VaNRLT
		aepgp = VaNRLT:GetModule("EPGP")
		aepgpgui = VaNRLTEPGPGUI
		gui = LibStub("AceGUI-3.0")
		
		local mainWindow = nil
		local settingsWindow = nil
		local charSettingsWindow = nil
		local historyWindow = nil
	
		local function HideSideFrames()
			settingsWindow:Hide()
			charSettingsWindow:Hide()
			--historyWindow:Hide()
		end
		
		local function ShowSettingsFrame()
			HideSideFrames()
			settingsWindow:Show()
		end
		
		local function ShowCharSettingsFrame(player)
			HideSideFrames()
			charSettingsWindow:OpenToPlayer(player)
		end
		
		local function ShowHistoryFrame()
			HideSideFrames()
			historyWindow:Show()
		end

		local function CreateButton(parent)
			local button = CreateFrame("Button", nil, parent)
			local backdrop = {
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background.blp",
				edgeFile = "Interface\\BUTTONS\\WHITE8X8.BLP",
				tile = true,
				tileSize = 32,
				edgeSize = 1,
			}
			button:SetBackdrop(backdrop)
			button:SetBackdropBorderColor(0,0,0,1)
			button:SetBackdropColor(0.1,0.1,0.1,1)
			button:SetDisabledFontObject(GameFontDisable)
			button:SetHighlightFontObject(GameFontHighlight)
			button:SetNormalFontObject(GameFontNormal)

			local function OnEnter()
				button:SetBackdropBorderColor(1,1,1,1)
			end

			local function OnLeave()
				button:SetBackdropBorderColor(0,0,0,1)
			end

			button:SetScript("OnEnter", OnEnter)
			button:SetScript("OnLeave", OnLeave)

			return button
		end
		
		local function CreateBaseFrame()
			local frame = CreateFrame("Frame", nil, UIParent)
			frame:SetPoint("CENTER", 0, 0)
			frame:SetHeight(300)
			frame:SetWidth(300)
			frame:SetResizable(true)
			frame:EnableMouse(true)
			frame:SetMovable(true)
			frame:SetMinResize(300,300)
			
			local backdrop = {
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background.blp",
				edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border.blp",
				tile = true,
				tileSize = 32,
				edgeSize = 32,
				insets = {
					left = 6,
					right = 6,
					top = 6,
					bottom = 6
				}
			}
			frame:SetBackdrop(backdrop)
			
			local corner = frame:CreateTexture()
			corner:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner.blp")
			corner:SetPoint("topright", frame, "topright", -4, -4)
			
			local close_button = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
			close_button:SetPoint("topright", frame, "topright", 0, 0)
			
			local header = frame:CreateTexture()
			header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header.blp")
			header:SetPoint("top", frame, "top", 0, 14)
			
			local header_text = frame:CreateFontString(nil,nil,"GameFontNormal")
			header_text:SetPoint("top", frame, "top", 0, 0)
			
			local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = header:GetTexCoord()
			
			local move_region = CreateFrame("Button", nil, frame)
			move_region:SetPoint("top", frame, "top", 0, 8)
			move_region:SetSize(128, 28)
			move_region:RegisterForDrag("LeftButton")
			move_region:SetScript("OnDragStart", function(self, button) frame:StartMoving() end)
			move_region:SetScript("OnDragStop", function(self, button) frame:StopMovingOrSizing() end)
			
			local sizer_se = CreateFrame("Button", nil, frame)
			sizer_se:SetPoint("BOTTOMRIGHT")
			sizer_se:SetWidth(25)
			sizer_se:SetHeight(25)
			sizer_se:RegisterForDrag("LeftButton")
			sizer_se:SetScript("OnDragStart", function(self, button) frame:StartSizing() end)
			sizer_se:SetScript("OnDragStop", function(self, button) frame:StopMovingOrSizing() end)

			local line1 = sizer_se:CreateTexture(nil, "BACKGROUND")
			line1:SetWidth(14)
			line1:SetHeight(14)
			line1:SetPoint("BOTTOMRIGHT", -8, 8)
			line1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
			local x = 0.1 * 14/17
			line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

			local line2 = sizer_se:CreateTexture(nil, "BACKGROUND")
			line2:SetWidth(8)
			line2:SetHeight(8)
			line2:SetPoint("BOTTOMRIGHT", -8, 8)
			line2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
			local x = 0.1 * 8/17
			line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)
			
			function frame:SetTitle(title)
				header_text:SetText(title)
			end

			function frame:EnableHeader(enable)
				if enable then
					header:Show()
					header_text:Show()
				else
					header:Hide()
					header_text:Hide()
					frame:EnableMover(false)
				end
			end

			function frame:EnableMover(enable)
				if enable then
					move_region:Show()
					frame:EnableHeader(true)
				else
					move_region:Hide()
				end
			end
			
			function frame:EnableSizer(enable)
				if enable then
					sizer_se:Show()
				else
					sizer_se:Hide()
				end
			end

			return frame
		end
		
		local function CreateMainFrame()
			local margin = 4

			mainWindow = CreateBaseFrame()
			mainWindow:SetTitle("EPGP")
			mainWindow:SetMaxResize(450, 1000)
			mainWindow:SetMinResize(450, 400)
			mainWindow:SetSize(450, 500)
			-- mainWindow:EnableSizer(false)
			-- mainWindow:EnableHeader(false)

			mainWindow:SetScript("OnHide", HideSideFrames)

			local settings_additional_button = CreateFrame("Button", nil, mainWindow, "UIPanelButtonTemplate")
			settings_additional_button:SetPoint("topleft", mainWindow, "topleft", 16, -32)
			settings_additional_button:SetSize(100, 25)
			settings_additional_button:SetText("Настройки")
			settings_additional_button:SetScript("OnClick", ShowSettingsFrame)

			local epgp_editbox = CreateFrame("EditBox", nil, mainWindow, "InputBoxTemplate")
			epgp_editbox:SetPoint("left", settings_additional_button, "right", margin*16, 0)
			epgp_editbox:SetSize(50, 30)
			epgp_editbox:SetAutoFocus(false)
			--epgp_editbox:SetNumeric(true)
			--epgp_editbox:Hide()

			local ep_button = CreateFrame("Button", nil, mainWindow, "UIPanelButtonTemplate")
			ep_button:SetPoint("left", epgp_editbox, "right", margin, 0)
			ep_button:SetSize(50, 25)
			ep_button:SetText("EP")
			ep_button:SetScript("OnClick", function() aepgp:GiveMassEP(tonumber(epgp_editbox:GetText())) end)

			local gp_button = CreateFrame("Button", nil, mainWindow, "UIPanelButtonTemplate")
			gp_button:SetPoint("left", ep_button, "right", margin, 0)
			gp_button:SetSize(50, 25)
			gp_button:SetText("GP")
			gp_button:SetScript("OnClick", function() aepgp:GiveMassGP(tonumber(epgp_editbox:GetText())) end)

			local mercy_button = CreateFrame("Button", nil, mainWindow, "UIPanelButtonTemplate")
			mercy_button:SetPoint("left", gp_button, "right", margin, 0)
			mercy_button:SetSize(90, 25)
			mercy_button:SetText("Очиcтить GP")
			mercy_button:SetScript("OnClick", function() aepgp:ClearPunishList() end)

			local table_frame = CreateFrame("Frame", nil, mainWindow)
			local backdrop = {
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background.blp",
				--edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border.blp",
				tile = true,
				tileSize = 32,
				edgeSize = 32,
				-- insets = {
				-- 	left = 0,
				-- 	right = 6,
				-- 	top = 6,
				-- 	bottom = 6
				-- }
			}
			table_frame:SetBackdrop(backdrop)
			table_frame:SetBackdropColor(0,0,0,0.5)
			table_frame:SetPoint("topleft", settings_additional_button, "bottomleft", 0, -margin*2)
			table_frame:SetPoint("bottomright", mainWindow, "bottomright", -16, 16)

			local name_column_width = 150
			local ep_column_width = 55
			local gp_column_width = 55
			local pr_column_width = 55
			local status_column_width = 50

			local name_table_button = CreateButton(table_frame)
			name_table_button:SetPoint("topleft", table_frame, "topleft", margin, -margin)
			name_table_button:SetSize(name_column_width, 25)
			name_table_button:SetText("Имя")

			local ep_table_button = CreateButton(table_frame)
			ep_table_button:SetPoint("left", name_table_button, "right", margin, 0)
			ep_table_button:SetSize(ep_column_width, 25)
			ep_table_button:SetText("EP")

			local gp_table_button = CreateButton(table_frame)
			gp_table_button:SetPoint("left", ep_table_button, "right", margin, 0)
			gp_table_button:SetSize(gp_column_width, 25)
			gp_table_button:SetText("GP")

			local pr_table_button = CreateButton(table_frame)
			pr_table_button:SetPoint("left", gp_table_button, "right", margin, 0)
			pr_table_button:SetSize(pr_column_width, 25)
			pr_table_button:SetText("PR")

			local status_table_label = table_frame:CreateFontString(nil,nil,"GameFontNormal")
			status_table_label:SetPoint("left", pr_table_button, "right", margin, 0)
			status_table_label:SetSize(status_column_width, 25)
			status_table_label:SetText("Статус")
			status_table_label:SetJustifyH("CENTER")

			local table_area_frame = CreateFrame("ScrollFrame", "VaNRLTGUI_EPGP_ScrollFrame", table_frame, "UIPanelScrollFrameTemplate")
			table_area_frame:SetPoint("topleft", name_table_button, "bottomleft", 0, -margin)
			table_area_frame:SetPoint("bottomright", table_frame, "bottomright", -margin*6.5, margin+30)

			local table_scroll_frame = CreateFrame("Frame")
			table_area_frame:SetScrollChild(table_scroll_frame)
			table_scroll_frame:SetSize(table_area_frame:GetWidth(), 1)

			local raid_tab_button = CreateButton(table_frame)
			raid_tab_button:SetPoint("bottomleft", table_frame, "bottomleft", margin, margin)
			raid_tab_button:SetSize(100, 25)
			raid_tab_button:SetText("Рейд")

			local replacement_tab_button = CreateButton(table_frame)
			replacement_tab_button:SetPoint("left", raid_tab_button, "right", margin, 0)
			replacement_tab_button:SetSize(100, 25)
			replacement_tab_button:SetText("Замена")

			local guild_tab_button = CreateButton(table_frame)
			guild_tab_button:SetPoint("left", replacement_tab_button, "right", margin, 0)
			guild_tab_button:SetSize(100, 25)
			guild_tab_button:SetText("Гильдия")

			local punish_tab_button = CreateButton(table_frame)
			punish_tab_button:SetPoint("left", guild_tab_button, "right", margin, 0)
			punish_tab_button:SetSize(100, 25)
			punish_tab_button:SetText("Начисление GP")

			local current_player = nil
			local info = {}

			local dropdown_menu = CreateFrame("Frame", "VaNRLTGUI_EPGP_DropDown_Menu")
			dropdown_menu.displayMode = "MENU"
			dropdown_menu.initialize = function (self, level)
				if level == 1 then
					wipe(info)
					info.isTitle = true
					info.text = current_player
					info.notCheckable = 1
					UIDropDownMenu_AddButton(info, level)

					if aepgp:CanAddToReplacement(current_player) then
						wipe(info)
						info.text = "Добавить на замену"
						info.notCheckable = 1
						info.func = function()
							aepgp:AddToReplacement(current_player)
							CloseDropDownMenus()
						end
						UIDropDownMenu_AddButton(info, level)
					end

					if aepgp:CanRemoveFromReplacement(current_player) then
						wipe(info)
						info.text = "Убрать с замены"
						info.notCheckable = 1
						info.func = function()
							aepgp:RemoveFromReplacement(current_player)
							CloseDropDownMenus()
						end
						UIDropDownMenu_AddButton(info, level)
					end

					if aepgp:CanPunishUnit(current_player) then
						wipe(info)
						info.text = "Добавить к начислению GP"
						info.notCheckable = 1
						info.func = function()
							aepgp:PunishUnit(current_player)
							CloseDropDownMenus()
						end
						UIDropDownMenu_AddButton(info, level)
					end

					if aepgp:CanMercyUnit(current_player) then
						wipe(info)
						info.text = "Убрать с начисления GP"
						info.notCheckable = 1
						info.func = function()
							aepgp:MercyUnit(current_player)
							CloseDropDownMenus()
						end
						UIDropDownMenu_AddButton(info, level)
					end

					if aepgp:GetOnline(current_player) and not UnitInRaid(current_player) and not UnitInParty(current_player) and UnitName("player") ~= current_player then
						wipe(info)
						info.text = "Пригласить"
						info.notCheckable = 1
						info.func = function()
							InviteUnit(current_player)
							CloseDropDownMenus()
						end
						UIDropDownMenu_AddButton(info, level)
					end

					wipe(info)
					info.text = "Закрыть"
					info.notCheckable = 1
					info.func = function()
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(info, level)
				end
			end

			local row_height = 20

			local function CreateRow()
				local row = CreateButton(table_scroll_frame)
				row:SetSize(table_area_frame:GetWidth(), row_height)

				local name_label = row:CreateFontString(nil, nil, "GameFontNormal")
				name_label:SetPoint("left", row)
				name_label:SetSize(name_column_width, row_height)
				name_label:SetJustifyH("CENTER")

				local ep_label = row:CreateFontString(nil, nil, "GameFontNormal")
				ep_label:SetPoint("left", name_label, "right", margin, 0)
				ep_label:SetSize(ep_column_width, row_height)
				ep_label:SetJustifyH("CENTER")

				local gp_label = row:CreateFontString(nil, nil, "GameFontNormal")
				gp_label:SetPoint("left", ep_label, "right", margin, 0)
				gp_label:SetSize(gp_column_width, row_height)
				gp_label:SetJustifyH("CENTER")

				local pr_label = row:CreateFontString(nil, nil, "GameFontNormal")
				pr_label:SetPoint("left", gp_label, "right", margin, 0)
				pr_label:SetSize(pr_column_width, row_height)
				pr_label:SetJustifyH("CENTER")

				local status_label = row:CreateFontString(nil, nil, "GameFontNormal")
				status_label:SetPoint("left", name_label, "right", margin, 0)
				status_label:SetSize(pr_column_width+ep_column_width+gp_column_width+margin*2, row_height)
				status_label:SetJustifyH("CENTER")

				local short_status_label = row:CreateFontString(nil, nil, "GameFontNormal")
				short_status_label:SetPoint("left", pr_label, "right", margin, 0)
				short_status_label:SetSize(status_column_width, row_height)
				short_status_label:SetJustifyH("CENTER")

				local nick = nil

				local row_togglemode = false

				local function OnEnter()
					if row_togglemode then
						ep_label:Show()
						gp_label:Show()
						pr_label:Show()
						--short_status_label:Show()
						status_label:Hide()
					end

					local c_r, c_g, c_b = GameFontNormal:GetTextColor()

					GameTooltip_SetDefaultAnchor(GameTooltip, row)
					local class = aepgp:GetClass(nick)
				    if class then
						local cc = RAID_CLASS_COLORS[class]
				        GameTooltip:AddDoubleLine("Ник", nick, c_r, c_g, c_b, cc.r, cc.g, cc.b)
				    else
				    	GameTooltip:AddDoubleLine("Ник", nick, c_r, c_g, c_b, 1,1,1)
				    end
			        GameTooltip:AddDoubleLine("Звание", aepgp:GetRank(nick), c_r, c_g, c_b, c_r, c_g, c_b)
			        local note = aepgp:GetNote(nick)
				    if note then
			        	GameTooltip:AddDoubleLine("Заметка", note, c_r, c_g, c_b, 1,1,1)
			        end
					
					local main = aepgp:GetMainChar(nick)
			        if main ~= nick then
			        	GameTooltip:AddLine(" ")
			        	local cc = RAID_CLASS_COLORS[aepgp:GetClass(main)]
			        	GameTooltip:AddDoubleLine("Мейн", main, c_r, c_g, c_b, cc.r, cc.g, cc.b)
			        	local note = aepgp:GetNote(main)
					    if note then
				        	GameTooltip:AddDoubleLine("Заметка мейна", note, c_r, c_g, c_b, 1,1,1)
				        end
			        else
				        local alts = aepgp:GetAlts(main)
				        if #alts > 0 then
				        	GameTooltip:AddLine(" ")
				        	GameTooltip:AddDoubleLine("Альты", #alts, c_r, c_g, c_b, 1,1,1)
				        	for i=1,#alts do
				        		local class = aepgp:GetClass(alts[i])
				        		if class then
					        		local cc = RAID_CLASS_COLORS[class]
					        		GameTooltip:AddLine(alts[i], cc.r, cc.g, cc.b)
					        	else
					        		GameTooltip:AddLine(alts[i], 1,1,1)
					        	end
				        	end
				        end

				        -- local count = aepgp:GetNumTwinkies(nick)

				        -- if count > 0 then
				        -- 	alts = aepgp:GetTwinkies(nick)
				        -- 	GameTooltip:AddLine(" ")
				        -- 	GameTooltip:AddDoubleLine("Альты(не в гильдии)", count, c_r, c_g, c_b, 1,1,1)
				        -- 	for k,v in pairs(alts) do
				        -- 		GameTooltip:AddLine(k, 1,1,1)
				        -- 	end
				        -- end
				    end

			        GameTooltip:ClearAllPoints()
			        GameTooltip:SetPoint("TOPLEFT", row, "TOPRIGHT")
			        GameTooltip:Show()
				end

				local function OnLeave()
					if row_togglemode then
						ep_label:Hide()
						gp_label:Hide()
						pr_label:Hide()
						--short_status_label:Hide()
						status_label:Show()
					end

					GameTooltip:Hide()
				end

				local function DefaultVisibility(status)
					if status then
						ep_label:Hide()
						gp_label:Hide()
						pr_label:Hide()
						--short_status_label:Hide()
						status_label:Show()
					else
						ep_label:Show()
						gp_label:Show()
						pr_label:Show()
						--short_status_label:Show()
						status_label:Hide()
					end

				end

				row:HookScript("OnEnter", OnEnter)
				row:HookScript("OnLeave", OnLeave)

				function row:SetInfo( name, class, ep, gp, short_status, status )
					nick = name
					name_label:SetText(name)
					row_togglemode = false
					if class ~= nil then
						local color = RAID_CLASS_COLORS[class]
						name_label:SetTextColor(color.r, color.g, color.b)
					else
						name_label:SetTextColor(1,1,1)
					end

					status_label:SetText(status or "Что-то пошло не так")
					ep_label:SetText(ep)
					gp_label:SetText(gp)
					local pr = ep/gp
					if pr > 9999 then
						pr_label:SetText(math.floor(pr))
					else
						pr_label:SetFormattedText("%.3g", pr)
					end
					
					short_status_label:SetText(short_status or "")

					if gp == -1 then
						DefaultVisibility(true)
						status_label:SetText(status or "Неправильная заметка")
					elseif status ~= nil then
						row_togglemode = true
						if row.isMouseOver and row:isMouseOver() then
							OnEnter()
						else
							OnLeave()
						end
					else
						DefaultVisibility()
					end

				end

				local function OnClick(self, button)
					if button == "LeftButton" then
						ShowCharSettingsFrame(nick)
					elseif button == "RightButton" then
						current_player = nick
						ToggleDropDownMenu(1, nil, dropdown_menu, "cursor", 0, 0)
					end
				end

				row:SetScript("OnClick", OnClick)
				row:RegisterForClicks("RightButtonUp", "LeftButtonUp")

				return row
			end

			local function CreateHeaderRow()
				local row = CreateFrame("Frame")
				local backdrop = {
					bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background.blp",
					edgeFile = "Interface\\BUTTONS\\WHITE8X8.BLP",
					tile = true,
					tileSize = 32,
					edgeSize = 1,
				}
				row:SetBackdrop(backdrop)
				row:SetBackdropBorderColor(0,0,0,1)
				row:SetBackdropColor(0.1,0.1,0.1,1)
				row:SetSize(table_area_frame:GetWidth(), row_height)
				row:SetParent(table_scroll_frame)
				row:SetPoint("topleft", table_scroll_frame)

				local name_label = row:CreateFontString(nil, nil, "GameFontNormal")
				name_label:SetAllPoints(row)
				name_label:SetJustifyH("CENTER")

				function row:SetName(name)
					name_label:SetText(name)
				end

				return row
			end

			local rows = {}
			local header_row = CreateHeaderRow()

			local tabs = {
				guild = {
					name = "Гильдия", 
					selector = function(unit) return unit.visible end,
				},
				raid = {
					name = "Рейд", 
					selector = function(unit) return unit.visible and unit.raid end,
				},
				replacement = {
					name = "Замена", 
					selector = function(unit) return unit.replacement end,
				},
				punish = {
					name = "Список для начисления GP", 
					selector = function(unit) return unit.punish end,
				},
			}

			local function name_comparator(field, field2)
				return field.name > field2.name
				-- return field.rank > field2.rank
			end

			local function ep_comparator(field, field2)
				return field.ep < field2.ep
			end

			local function gp_comparator(field, field2)
				return field.gp < field2.gp
			end

			local function pr_comparator(field, field2)
				return (field.ep / field.gp) < (field2.ep / field2.gp)
			end

			local function sort_table( table, comparator )
				for i=1,#table do
					for j=i,#table do
						if comparator(table[i], table[j]) then
							table[i], table[j] = table[j], table[i]
						end
					end
				end
			end

			local current_tab = nil
			local current_sort = pr_comparator

			local function UpdateTable()
				local t = {}
				for name, unit in pairs(aepgp.guild_players) do
					if tabs[current_tab].selector(unit) then
						table.insert(t, unit)
					end
				end

				sort_table(t, current_sort)

				count = #t

				table_scroll_frame:SetSize(table_area_frame:GetWidth(), (row_height+1)*(count+1))

				header_row:SetName(tabs[current_tab].name)

				while #rows < count do
					table.insert(rows, CreateRow())
				end

				for i=1,#rows do
					rows[i]:ClearAllPoints()
					if i <= count then
						if i==1 then
							rows[i]:SetPoint("topleft", header_row, "bottomleft", 0, -2)
						else
							rows[i]:SetPoint("topleft", rows[i-1], "bottomleft", 0, -2)
						end

						short_status = ""
						if t[i].online then short_status = short_status.."О" end
						if t[i].raid then short_status = short_status.."Р" end
						if t[i].replacement then short_status = short_status.."З" end
						if t[i].punish then short_status = short_status.."Gp" end

						rows[i]:SetInfo(t[i].name, t[i].class, t[i].ep, t[i].gp, short_status, t[i].status)

						rows[i]:Show()
					else
						rows[i]:Hide()
					end
				end
			end

			

			local function UpdateTabs()
				if UnitInRaid("player") then
					raid_tab_button:Enable()
					replacement_tab_button:Enable()
				else
					raid_tab_button:Disable()
					replacement_tab_button:Disable()
					if current_tab == "raid" or current_tab == "replacement" then
						current_tab = "guild"
					end
				end
				UpdateTable()
			end

			aepgp.guild_cache_changed:connect(UpdateTabs)

			local function SetTab(tab)
				current_tab = tab
				UpdateTable()
			end

			SetTab("guild")

			UpdateTabs()

			

			raid_tab_button:SetScript("OnClick", function() SetTab("raid") end)
			replacement_tab_button:SetScript("OnClick", function() SetTab("replacement") end)
			guild_tab_button:SetScript("OnClick", function() SetTab("guild") end)
			punish_tab_button:SetScript("OnClick", function() SetTab("punish") end)

			name_table_button:SetScript("OnClick", function() current_sort = name_comparator UpdateTable() end)
			ep_table_button:SetScript("OnClick", function() current_sort = ep_comparator UpdateTable() end)
			gp_table_button:SetScript("OnClick", function() current_sort = gp_comparator UpdateTable() end)
			pr_table_button:SetScript("OnClick", function() current_sort = pr_comparator UpdateTable() end)
		end
		
		local function CreateSettingsMenu()
			local margin = 4

			settingsWindow = CreateBaseFrame()
			settingsWindow:SetTitle("Настройки")
			settingsWindow:SetSize(200, 215)
			settingsWindow:EnableSizer(false)
			settingsWindow:SetMovable(false)
			settingsWindow:SetPoint("topleft", mainWindow, "topright")
			settingsWindow:Hide()

			local base_settings_label = settingsWindow:CreateFontString(nil, nil, "GameFontNormal")
			base_settings_label:SetPoint("topleft", settingsWindow, "topleft", 24, -32)
			base_settings_label:SetSize(150+margin*2, 30)

			local function update_stats()
				base_settings_label:SetText(("Баз. GP = %s\nСнижение = %s"):format(aepgp.guild_info.base_gp, aepgp.guild_info.decay_p.."%"))
			end
			update_stats()
			aepgp.guild_cache_changed:connect(update_stats)
			
			local decay_button = CreateFrame("Button", nil, settingsWindow, "UIPanelButtonTemplate")
			decay_button:SetPoint("topleft", base_settings_label, "bottomleft", 0, -margin)
			decay_button:SetSize(150+margin*2, 25)
			decay_button:SetText("Снижение")
			decay_button:SetScript("OnClick", function() aepgp:Decay() end)
		end
		
		local function CreateCharSettingsMenu()
			local margin = 4

			charSettingsWindow = CreateBaseFrame()
			charSettingsWindow:SetTitle("")
			charSettingsWindow:SetSize(200, 215)
			charSettingsWindow:EnableSizer(false)
			charSettingsWindow:SetMovable(false)
			charSettingsWindow:SetPoint("topleft", mainWindow, "topright")
			charSettingsWindow:Hide()

			local reason_editbox = CreateFrame("EditBox", "VaNRLTGUI_EPGP_CharSettingsMenu_Reason_Textbox", charSettingsWindow, "InputBoxTemplate")
			reason_editbox:SetPoint("topleft", charSettingsWindow, "topleft", 24, -32)
			reason_editbox:SetSize(150+margin*2, 30)
			reason_editbox:SetAutoFocus(false)
			--reason_editbox:Hide()

			local epgp_editbox = CreateFrame("EditBox", "VaNRLTGUI_EPGP_CharSettingsMenu_EPGP_Textbox", charSettingsWindow, "InputBoxTemplate")
			epgp_editbox:SetPoint("topleft", reason_editbox, "bottomleft", 0, -margin)
			epgp_editbox:SetSize(50, 30)
			epgp_editbox:SetAutoFocus(false)
			--epgp_editbox:SetNumeric(true)
			--epgp_editbox:Hide()

			local ep_button = CreateFrame("Button", nil, charSettingsWindow, "UIPanelButtonTemplate")
			ep_button:SetPoint("left", epgp_editbox, "right", margin, 0)
			ep_button:SetSize(50, 25)
			ep_button:SetText("EP")

			local gp_button = CreateFrame("Button", nil, charSettingsWindow, "UIPanelButtonTemplate")
			gp_button:SetPoint("left", ep_button, "right", margin, 0)
			gp_button:SetSize(50, 25)
			gp_button:SetText("GP")

			local note_editbox = CreateFrame("EditBox", "VaNRLTGUI_EPGP_CharSettingsMetu_Note_Textbox", charSettingsWindow, "InputBoxTemplate")
			note_editbox:SetPoint("topleft", epgp_editbox, "bottomleft", 0, -margin)
			note_editbox:SetSize(150+margin*2, 30)
			note_editbox:SetAutoFocus(false)

			local twinkies_editbox = CreateFrame("EditBox", "VaNRLTGUI_EPGP_CharSettingsMenu_Twinkies_Textbox", charSettingsWindow, "InputBoxTemplate")
			twinkies_editbox:SetSize(150+margin*2, 30)
			twinkies_editbox:SetPoint("topleft", note_editbox, "bottomleft", 0, -margin)
			twinkies_editbox:SetAutoFocus(false)

			local twinkies_add_button = CreateFrame("Button", nil, charSettingsWindow, "UIPanelButtonTemplate")
			twinkies_add_button:SetPoint("topleft", twinkies_editbox, "bottomleft",0, -margin)
			twinkies_add_button:SetSize(75, 25)
			twinkies_add_button:SetText("Добавить")

			local twinkies_del_button = CreateFrame("Button", nil, charSettingsWindow, "UIPanelButtonTemplate")
			twinkies_del_button:SetPoint("left", twinkies_add_button, "right", margin, 0)
			twinkies_del_button:SetSize(75, 25)
			twinkies_del_button:SetText("Удалить")

			local current_player = nil

			local dropdown_menu = CreateFrame("Frame", "VaNRLTGUI_EPGP_CharSettingsMenu_Twinkies_DropDown_Menu")
			dropdown_menu.displayMode = "MENU"
			dropdown_menu.initialize = function (self, level)
				if level == 1 then
					wipe(info)
					info.isTitle = true
					info.text = "Удалить твинка"
					info.notCheckable = 1
					UIDropDownMenu_AddButton(info, level)

					for k,v in pairs(aepgp:GetTwinkies(current_player)) do
						wipe(info)
						info.text = k
						info.notCheckable = 1
						info.func = function()
							aepgp:RemoveTwinkie(current_player, k)
							CloseDropDownMenus()
						end
						UIDropDownMenu_AddButton(info, level)
					end

					wipe(info)
					info.text = "Закрыть"
					info.notCheckable = 1
					info.func = function()
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(info, level)
				end
			end

			function charSettingsWindow:OpenToPlayer(player)
				current_player = player
				charSettingsWindow:Show()
				charSettingsWindow:SetTitle(player)
				reason_editbox:SetText("")
				epgp_editbox:SetText("")
				note_editbox:SetText(aepgp:GetNote(current_player) or "")
				if aepgp:GetMainChar(current_player) ~= current_player then
					-- twinkies_editbox:Disable()
					twinkies_add_button:Disable()
					twinkies_del_button:Disable()
				else
					-- twinkies_editbox:Enable()
					twinkies_add_button:Enable()
					twinkies_del_button:Enable()
				end
			end

			ep_button:SetScript("OnClick", function() aepgp:GiveEP(current_player, tonumber(epgp_editbox:GetText()), reason_editbox:GetText()) end)
			gp_button:SetScript("OnClick", function() aepgp:GiveGP(current_player, tonumber(epgp_editbox:GetText()), reason_editbox:GetText()) end)
			note_editbox:SetScript("OnTextChanged",
			 	function(self, user) 
			 		local text = note_editbox:GetText()
			 		if text == "" then text = nil end
			 	 	aepgp:SetNote(current_player, text) 
			 	end
			)
			twinkies_add_button:SetScript("OnClick", function() aepgp:AddTwinkie(current_player, twinkies_editbox:GetText()) twinkies_editbox:SetText("") end)
			twinkies_del_button:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, dropdown_menu, "cursor", 0, 0) end)
		end
		
		local function CreateHistoryWindow()
			
		end
		
		aepgpgui.moptions = {
			type = "group",
			name = "EPGP",
			args = {
				whisper = {
					type = "toggle",
					name = "Шепот",
					desc = "Включить обработку шепота(v_epgp standby)",
					get = function(arg) return ac.db.global.EPGP.whisper_enabled end,
					set = function(arg, val) ac.db.global.EPGP.whisper_enabled = val end,
					order = 1,
				}
			},
		}
		
		table.insert(_gui.ModulesOptions, aepgpgui.moptions)
		
		local t = 1
		for _, _ in pairs(_gui.MenuButtons) do t=t+1 end
		
		_gui.MenuButtons["EPGPHeader"] = {
			type = "header",
			name = "EPGP",
			order=t,
		}
		
		_gui.MenuButtons["EPGPButtonShow"] = {
			type = "execute",
			name = "Показать",
			func = function(arg) HideUIPanel(GameTooltip) acd:Close("VaNRLTGUIMenu") mainWindow:Show() end,
			order=t+1,
		}
		
		function VaNRLTEPGPGUI:OnInitialize()
			CreateMainFrame()
			CreateSettingsMenu()
			CreateCharSettingsMenu()
			CreateHistoryWindow()

			mainWindow:SetPoint("topleft", UIParent, "topleft", 100, -100)
			
			mainWindow:Show()
			aepgpgui:Print("Initialized")
		end
		
		function VaNRLTEPGPGUI:ResetSettings()
			
		end
	end
end

Init()

local function OnAddonLoaded(event, addon)
	if addon=="VaNRLTGUI" then Init() end
end

local event = LibStub("AceEvent-3.0"):RegisterEvent("ADDON_LOADED", OnAddonLoaded)