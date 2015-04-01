﻿local E, L, V, P, G = unpack(ElvUI);
local CH = E:GetModule('Chat')
local SLE = E:GetModule('SLE');
local LSM = LibStub("LibSharedMedia-3.0")
local CreatedFrames = 0;
local lfgRoles = {};
local chatFilters = {};
local lfgChannels = {
	"PARTY_LEADER",
	"PARTY",
	"RAID",
	"RAID_LEADER",
	"INSTANCE_CHAT",
	"INSTANCE_CHAT_LEADER",
}

local Myname = E.myname
local GetGuildRosterInfo = GetGuildRosterInfo
local IsInGuild = IsInGuild
local GuildMaster = ""
local GMName, GMRealm

local len, gsub, find, sub, gmatch, format, random = string.len, string.gsub, string.find, string.sub, string.gmatch, string.format, math.random
local tinsert, tremove, tsort, twipe, tconcat = table.insert, table.remove, table.sort, table.wipe, table.concat

local PLAYER_REALM = gsub(E.myrealm,'[%s%-]','')
local PLAYER_NAME = Myname.."-"..PLAYER_REALM

local rolePaths = {
	TANK = [[|TInterface\AddOns\ElvUI\media\textures\tank:15:15:0:0:64:64:2:56:2:56|t]],
	HEALER = [[|TInterface\AddOns\ElvUI\media\textures\healer:15:15:0:0:64:64:2:56:2:56|t]],
	DAMAGER = [[|TInterface\AddOns\ElvUI\media\textures\dps:15:15|t]]
}
local leader = [[|TInterface\GroupFrame\UI-Group-LeaderIcon:12:12|t]]
local specialChatIcons

--Damage Meter Spam stuff--
CH.MeterSpam = false
CH.ChannelEvents = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
}
CH.spamFirstLines = {
	"^Recount - (.*)$", --Recount
	"^Skada: (.*) for (.*):$", -- Skada enUS 
	"^Skada: (.*) por (.*):$", -- Skada esES/ptBR 
	"^Skada: (.*) für (.*):$", -- Skada deDE 
	"^Skada: (.*) pour (.*):$", -- Skada frFR 
	"^Skada: (.*) per (.*):$", -- Skada itIT 
	"^(.*) 의 Skada 보고 (.*):$", -- Skada koKR
	"^Отчёт Skada: (.*), с (.*):$", -- Skada ruRU
	"^Skada报告(.*)的(.*):$", -- Skada zhCN
	"^Skada:(.*)來自(.*):$", -- Skada zhTW
	"^(.*) Done for (.*)$", -- TinyDPS
	"^Numeration: (.*)$", -- Numeration
	"^Details! Report for (.*)$" -- Details!
}
CH.spamNextLines = {
	"^(%d+)\. (.*)$", --Recount, Details! and Skada
	"^(.*)   (.*)$", --Additional Skada
	"^Numeration: (.*)$", -- Numeration
	"^[+-]%d+.%d", -- Numeration Deathlog Details
	"^(%d+). (.*):(.*)(%d+)(.*)(%d+)%%(.*)%((%d+)%)$", -- TinyDPS
	"^(.+) (%d-%.%d-%w)$", -- Skada 2
}
CH.Meters = {}

local function Style(self, frame)
	CreatedFrames = frame:GetID()
end

--Replacement of chat tab position and size function
local PixelOff = E.PixelMode and 31 or 27

function CH:PositionChat(override)
	if ((InCombatLockdown() and not override and self.initialMove) or (IsMouseButtonDown("LeftButton") and not override)) then return end
	if not RightChatPanel or not LeftChatPanel then return; end
	RightChatPanel:SetSize(E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth, E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight)
	LeftChatPanel:SetSize(E.db.chat.panelWidth, E.db.chat.panelHeight)	
	
	if not self.db.lockPositions or E.private.chat.enable ~= true then return end
		
	local chat, chatbg, tab, id, point, button, isDocked, chatFound
	for _, frameName in pairs(CHAT_FRAMES) do
		chat = _G[frameName]
		id = chat:GetID()
		point = GetChatWindowSavedPosition(id)
		
		if point == "BOTTOMRIGHT" and chat:IsShown() then
			chatFound = true
			break
		end
	end	

	if chatFound then
		self.RightChatWindowID = id
	else
		self.RightChatWindowID = nil
	end

	for i=1, CreatedFrames do
		local BASE_OFFSET = 60
		if E.PixelMode then
			BASE_OFFSET = BASE_OFFSET - 3
		end	
		chat = _G[format("ChatFrame%d", i)]
		chatbg = format("ChatFrame%dBackground", i)
		button = _G[format("ButtonCF%d", i)]
		id = chat:GetID()
		tab = _G[format("ChatFrame%sTab", i)]
		point = GetChatWindowSavedPosition(id)
		isDocked = chat.isDocked
		tab.isDocked = chat.isDocked
		tab.owner = chat
		if id > NUM_CHAT_WINDOWS then
			point = point or select(1, chat:GetPoint());
			if select(2, tab:GetPoint()):GetName() ~= bg then
				isDocked = true
			else
				isDocked = false
			end	
		end	

		
		if point == "BOTTOMRIGHT" and chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and id == self.RightChatWindowID then
			chat:ClearAllPoints()
			if E.db.sle.datatext.chathandle then 
				if E.db.datatexts.rightChatPanel then
					chat:Point("BOTTOMRIGHT", RightChatDataPanel, "TOPRIGHT", 10, 3)
				else
					BASE_OFFSET = BASE_OFFSET - 24
					chat:SetPoint("BOTTOMLEFT", RightChatPanel, "BOTTOMLEFT", 4, 4)
				end
				if id ~= 2 then
					chat:Size((E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth) - 11, ((E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight) - PixelOff))
				end
			else
				if E.db.datatexts.rightChatPanel then
					chat:SetPoint("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
				else
					BASE_OFFSET = BASE_OFFSET - 24
					chat:SetPoint("BOTTOMLEFT", RightChatDataPanel, "BOTTOMLEFT", 1, 1)
				end
				if id ~= 2 then
					chat:SetSize((E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth) - 11, (E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight) - BASE_OFFSET)
				else
					chat:SetSize(E.db.chat.panelWidth - 11, (E.db.chat.panelHeight - BASE_OFFSET) - CombatLogQuickButtonFrame_Custom:GetHeight())				
				end
			end
			
			FCF_SavePositionAndDimensions(chat)			
			
			tab:SetParent(RightChatPanel)
			chat:SetParent(RightChatPanel)
			
			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end
			if E.db.chat.panelBackdrop == 'HIDEBOTH' or E.db.chat.panelBackdrop == 'LEFT' then
				CH:SetupChatTabs(tab, true)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not isDocked and chat:IsShown() then
			tab:SetParent(UIParent)
			chat:SetParent(UIParent)
			
			local fade = E.db["chat"].fadeUndockedTabs
			CH:SetupChatTabs(tab, fade and true or false)
		else
			if E.db.sle.datatext.chathandle then 
				if id ~= 2 and not (id > NUM_CHAT_WINDOWS) then
					BASE_OFFSET = BASE_OFFSET - 24
					chat:SetPoint("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", 1, 4)
					chat:Size(E.db.chat.panelWidth - 11, E.db.chat.panelHeight - PixelOff)
				end
			else
				if id ~= 2 and not (id > NUM_CHAT_WINDOWS) then
					chat:ClearAllPoints()
					if E.db.datatexts.leftChatPanel then
						chat:SetPoint("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
					else
						BASE_OFFSET = BASE_OFFSET - 24
						chat:SetPoint("BOTTOMLEFT", LeftChatToggleButton, "BOTTOMLEFT", 1, 1)
					end
					chat:SetSize(E.db.chat.panelWidth - 11, (E.db.chat.panelHeight - BASE_OFFSET))
					FCF_SavePositionAndDimensions(chat)		
				end
			end
			chat:SetParent(LeftChatPanel)
			if i > 2 then
				tab:SetParent(GeneralDockManagerScrollFrameChild)
			else
				tab:SetParent(GeneralDockManager)
			end
			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end
			
			if E.db.chat.panelBackdrop == 'HIDEBOTH' or E.db.chat.panelBackdrop == 'RIGHT' then
				CH:SetupChatTabs(tab, true)
			else
				CH:SetupChatTabs(tab, false)
			end			
		end		
	end
	
	self.initialMove = true;
end

local function GetChatIcon(sender)
	local senderName, senderRealm
	if sender then
		senderName, senderRealm = string.split('-', sender)
	else
		senderName = Myname
	end
	senderRealm = senderRealm or PLAYER_REALM
	senderRealm = senderRealm:gsub(' ', '')
		
	--Disabling ALL special icons. IDK why Elv use that and why would we want to have that but whatever
	if specialChatIcons and specialChatIcons[PLAYER_REALM] and specialChatIcons[PLAYER_REALM][Myname] ~= true then
		if specialChatIcons[senderRealm] and specialChatIcons[senderRealm][senderName] then
			return specialChatIcons[senderRealm][senderName]
		end
	end
	
	if not IsInGuild() then return "" end
	if not E.db.sle.chat.guildmaster then return "" end
	if senderName == GMName and senderRealm == GMRealm then
		return leader 
	end
	
	return ""
end

function CH:GetPluginReplacementIcon(arg2, arg6, type)
	local icon = ""
	if arg6 and (strlen(arg6) > 0) then
		if ( arg6 == "GM" ) then
			--If it was a whisper, dispatch it to the GMChat addon.
			if ( type == "WHISPER" ) then
				return;
			end
			--Add Blizzard Icon, this was sent by a GM
			icon = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t ";
		elseif ( arg6 == "DEV" ) then
			--Add Blizzard Icon, this was sent by a Dev
			icon = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t ";
		elseif ( arg6 == "DND" or arg6 == "AFK") then
			icon = GetChatIcon(arg2).._G["CHAT_FLAG_"..arg6]
		else					
			icon = _G["CHAT_FLAG_"..arg6];
		end
	else
		icon = GetChatIcon(arg2)
		if(lfgRoles[arg2] and SLE:SimpleTable(lfgChannels, type)) then
			icon = lfgRoles[arg2]..icon
		end
	end
	if icon == "" then icon = nil end
	return icon, true
end

function CH:CheckLFGRoles()
	local isInGroup, isInRaid = IsInGroup(), IsInRaid()
	local unit = isInRaid and "raid" or "party"
	local name, realm
	twipe(lfgRoles)

	if(not isInGroup or not self.db.lfgIcons) then return end

	local role = UnitGroupRolesAssigned("player")
	if(role) then
		lfgRoles[PLAYER_NAME] = rolePaths[role]
	end

	for i=1, GetNumGroupMembers() do
		if(UnitExists(unit..i) and not UnitIsUnit(unit..i, "player")) then
			role = UnitGroupRolesAssigned(unit..i)
			local name, realm = UnitName(unit..i)
			if(role and name and realm) then
				name = realm ~= '' and name..'-'..realm or name ..'-'..PLAYER_REALM;
				lfgRoles[name] = rolePaths[role]
			end
		end
	end
end

local function GMCheck()
	local name, rank
	if GetNumGuildMembers() == 0 and IsInGuild() then E:Delay(2, GMCheck); return end
	if not IsInGuild() then GuildMaster = ""; GMName = ''; GMRealm = ''; return end
	for i = 1, GetNumGuildMembers() do
		name, _, rank = GetGuildRosterInfo(i)
		if rank == 0 then
			break
		end
	end
	
	GuildMaster = name
	if GuildMaster then
		GMName, GMRealm = string.split('-', GuildMaster)
	end
	GMRealm = GMRealm or PLAYER_REALM
	GMRealm = GMRealm:gsub(' ', '')
end

local function Roster(event, update)
 if update then GMCheck() end
end

function CH:GMIconUpdate()
	if E.private.chat.enable ~= true then return end
	if E.db.sle.chat.guildmaster then
		self:RegisterEvent('GUILD_ROSTER_UPDATE', Roster)
		GMCheck()
	else
		self:UnregisterEvent('GUILD_ROSTER_UPDATE')
		GuildMaster = ""
		GMName = ''
		GMRealm = ''
	end
end

function CH:filterLine(event, source, msg, ...)
	local isSpam = false
	for _, line in ipairs(CH.spamNextLines) do
		if msg:match(line) then
			local curTime = GetTime()
			for id, meter in ipairs(CH.Meters) do
				local elapsed = curTime - meter.time
				if meter.src == source and meter.evt == event and elapsed < 1 then
					-- found the meter, now check wheter this line is already in there
					local toInsert = true
					for a,b in ipairs(meter.data) do
						if (b == msg) then
							toInsert = false
						end
					end

					if toInsert then
						tinsert(meter.data,msg)
					end
					return true, false, nil
				end
			end
		end
	end

	for i, line in ipairs(CH.spamFirstLines) do
		local newID = 0
		if msg:match(line) then
			local curTime = GetTime();
			-- check wheter there's already a meter running (don't want duplicates)
			for id,meter in ipairs(CH.Meters) do
				local elapsed = curTime - meter.time
				if meter.src == source and meter.evt == event and elapsed < 1 then
					newID = id
					return true, true, string.format("|HSLD:%1$d|h|cFFFFFF00[%2$s]|r|h",newID or 0,msg or "nil")
				end
			end

			local newMeter = {src = source, evt = event, time = curTime, data = {}, title = msg, addon = addonName}
			tinsert(CH.Meters, newMeter)

			for id,meter in ipairs(CH.Meters) do
				if meter.src == source and meter.evt == event and meter.time == curTime then
					newID = id
				end
			end

			return true, true, string.format("|HSLD:%1$d|h|cFFFFFF00[%2$s]|r|h",newID or 0,msg or "nil")
		end
	end
	return false, false, nil
end

function CH:ParseChatEvent(event, msg, sender, ...)
	local hide = false
	for _,allevents in ipairs(CH.ChannelEvents) do
		if event == allevents then
			local isRecount, isFirstLine, newMessage = CH:filterLine(event, sender, msg)
			if isRecount then
				if isFirstLine then
					msg = newMessage
				else
					hide = true
				end
			end
		end
	end


	if not hide then
		return false, msg, sender, ...
	end
	return true
end

function CH:ParseLink(link, text, button, chatframe)
	if E.db.sle.chat.dpsSpam then
		local linktype, id = strsplit(":", link)
		if linktype == "SLD" then
			local meterID = tonumber(id)
			-- put stuff in the ItemRefTooltip from FrameXML
			ShowUIPanel(ItemRefTooltip);
			if ( not ItemRefTooltip:IsShown() ) then
				ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
			end
			ItemRefTooltip:ClearLines()
			ItemRefTooltip:AddLine(CH.Meters[meterID].title)
			ItemRefTooltip:AddLine(format(L["Reported by %s"],CH.Meters[meterID].src))
			for _,message in ipairs(CH.Meters[meterID].data) do
				ItemRefTooltip:AddLine(message,1,1,1)
			end
			ItemRefTooltip:Show()
		end
	end
end

function CH:SpamFilter()
	if E.db.sle.chat.dpsSpam then
		for _,event in ipairs(CH.ChannelEvents) do
			ChatFrame_AddMessageEventFilter(event, self.ParseChatEvent)
		end

		CH.MeterSpam = true
	else
		if CH.MeterSpam then
			for _,event in ipairs(CH.ChannelEvents) do
				ChatFrame_RemoveMessageEventFilter(event, self.ParseChatEvent)
			end
			CH.MeterSpam = false
		end
	end
end

--Previously layout.lua
local LO = E:GetModule('Layout');
local PANEL_HEIGHT = 22;
local SIDE_BUTTON_WIDTH = 16;
local function ChatPanels()
	if not E.db.sle.datatext.chathandle then return end
	
	if not E:HasMoverBeenMoved("LeftChatMover") and E.db.datatexts.leftChatPanel then
		if not E.db.movers then E.db.movers = {}; end
		if E.PixelMode then
			E.db.movers.LeftChatMover = "BOTTOMLEFTUIParentBOTTOMLEFT019"
		else
			E.db.movers.LeftChatMover = "BOTTOMLEFTUIParentBOTTOMLEFT021"
		end
		E:SetMoversPositions()
	end
	
	if not E:HasMoverBeenMoved("RightChatMover") and E.db.datatexts.rightChatPanel then
		if not E.db.movers then E.db.movers = {}; end
		if E.PixelMode then
			E.db.movers.RightChatMover = "BOTTOMRIGHTUIParentBOTTOMRIGHT019"
		else
			E.db.movers.RightChatMover = "BOTTOMRIGHTUIParentBOTTOMRIGHT021"
		end
		E:SetMoversPositions()
	end

	if E.db.chat.panelBackdrop == 'SHOWBOTH' then
		LeftChatPanel.backdrop:Show()
		RightChatPanel.backdrop:Show()

		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SIDE_BUTTON_WIDTH, (E.PixelMode and -19 or -21)) --lower line of datapanel
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMLEFT', 16 + E.db.sle.datatext.chatleft.width, (E.PixelMode and 1 or -1)) --upper line of datapanel		
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMRIGHT', - (E.db.sle.datatext.chatright.width + 16), (E.PixelMode and -19 or -21)) --lower-left corner of right datapanel
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SIDE_BUTTON_WIDTH, (E.PixelMode and 1 or -1))	--upper-right corner of right datapanel	
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', 0, (E.PixelMode and -19 or -21))
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, (E.PixelMode and -19 or -21))
		LO:ToggleChatTabPanels()
	elseif E.db.chat.panelBackdrop == 'HIDEBOTH' then
		LeftChatPanel.backdrop:Hide()
		RightChatPanel.backdrop:Hide()
		
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SIDE_BUTTON_WIDTH, (E.PixelMode and -19 or -21)) --lower line of datapanel
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMLEFT', 16 + E.db.sle.datatext.chatleft.width, (E.PixelMode and 1 or -1)) --upper line of datapanel		
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMRIGHT', - (E.db.sle.datatext.chatright.width + 16), (E.PixelMode and -19 or -21)) --lower-left corner of right datapanel
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SIDE_BUTTON_WIDTH, (E.PixelMode and 1 or -1))	--upper-right corner of right datapanel	
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', 0, (E.PixelMode and -19 or -21))
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, (E.PixelMode and -19 or -21))
		LO:ToggleChatTabPanels(true, true)
	elseif E.db.chat.panelBackdrop == 'LEFT' then
		LeftChatPanel.backdrop:Show()
		RightChatPanel.backdrop:Hide()
		
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SIDE_BUTTON_WIDTH, (E.PixelMode and -19 or -21)) --lower line of datapanel
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMLEFT', 16 + E.db.sle.datatext.chatleft.width, (E.PixelMode and 1 or -1)) --upper line of datapanel		
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMRIGHT', - (E.db.sle.datatext.chatright.width + 16), (E.PixelMode and -19 or -21)) --lower-left corner of right datapanel
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SIDE_BUTTON_WIDTH, (E.PixelMode and 1 or -1))	--upper-right corner of right datapanel	
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', 0, (E.PixelMode and -19 or -21))
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, (E.PixelMode and -19 or -21))
		LO:ToggleChatTabPanels(true)
	else
		LeftChatPanel.backdrop:Hide()
		RightChatPanel.backdrop:Show()
		
		LeftChatDataPanel:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', SIDE_BUTTON_WIDTH, (E.PixelMode and -19 or -21)) --lower line of datapanel
		LeftChatDataPanel:Point('TOPRIGHT', LeftChatPanel, 'BOTTOMLEFT', 16 + E.db.sle.datatext.chatleft.width, (E.PixelMode and 1 or -1)) --upper line of datapanel		
		RightChatDataPanel:Point('BOTTOMLEFT', RightChatPanel, 'BOTTOMRIGHT', - (E.db.sle.datatext.chatright.width + 16), (E.PixelMode and -19 or -21)) --lower-left corner of right datapanel
		RightChatDataPanel:Point('TOPRIGHT', RightChatPanel, 'BOTTOMRIGHT', -SIDE_BUTTON_WIDTH, (E.PixelMode and 1 or -1))	--upper-right corner of right datapanel	
		LeftChatToggleButton:Point('BOTTOMLEFT', LeftChatPanel, 'BOTTOMLEFT', 0, (E.PixelMode and -19 or -21))
		RightChatToggleButton:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, (E.PixelMode and -19 or -21))
		LO:ToggleChatTabPanels(nil, true)
	end
end

local function CreateChatPanels()
	--Left Chat Tab
	LeftChatTab:Point('TOPLEFT', LeftChatPanel, 'TOPLEFT', 2, -2)
	LeftChatTab:Point('BOTTOMRIGHT', LeftChatPanel, 'TOPRIGHT', -2, -PANEL_HEIGHT)
	--Preventing left chat datapanel fading
	ChatFrame1EditBox:Hide()
	--Right Chat Tab
	RightChatTab:Point('TOPRIGHT', RightChatPanel, 'TOPRIGHT', -2, -2)
	RightChatTab:Point('BOTTOMLEFT', RightChatPanel, 'TOPLEFT', 2, -PANEL_HEIGHT)
end

local function ChatTextures()
	if not E.db['general'] or not E.private['general'] then return end --Prevent rare nil value errors
	if not E.db.sle.chat.textureAlpha.enable then return end --our option enable check
	
	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		local a = E.db.sle.chat.textureAlpha.alpha or 0.5
		LeftChatPanel.tex:SetAlpha(a)
		RightChatPanel.tex:SetAlpha(a)
	end
end

hooksecurefunc(LO, "ToggleChatPanels", ChatPanels)
hooksecurefunc(LO, "CreateChatPanels", CreateChatPanels)
hooksecurefunc(CH, "StyleChat", Style)

hooksecurefunc(CH, "Initialize", function(self)
	if not E.private.chat.enable then return end
	if E.db.sle.chat.guildmaster then
		self:RegisterEvent('GUILD_ROSTER_UPDATE', Roster)
		GMCheck()
	end
	SLE:GetRegion()
	specialChatIcons = SLE.SpecialChatIcons[SLE.region]

	CH:SpamFilter()

	self:SecureHook("SetItemRef","ParseLink")
	hooksecurefunc(E, "UpdateMedia", ChatTextures)
	-- Borrowed from Deadly Boss Mods
	do
		local old = ItemRefTooltip.SetHyperlink -- we have to hook this function since the default ChatFrame code assumes that all links except for player and channel links are valid arguments for this function
		function ItemRefTooltip:SetHyperlink(link, ...)
			if link:sub(0, 4) == "SLD:" then
				return
			end
			return old(self, link, ...)
		end
	end
end)