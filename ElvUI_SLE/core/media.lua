﻿local SLE, T, E, L, V, P, G = unpack(select(2, ...))
local M = SLE.Media

--GLOBALS: hooksecurefunc
local _G = _G
local random = random
local FadingFrame_Show = FadingFrame_Show

M.Zones = L["SLE_MEDIA_ZONES"]
M.PvPInfo = L["SLE_MEDIA_PVP"]
M.Subzones = L["SLE_MEDIA_SUBZONES"]
M.PVPArena = L["SLE_MEDIA_PVPARENA"]

local Colors = {
	[1] = {0.41, 0.8, 0.94}, -- sanctuary
	[2] = {1.0, 0.1, 0.1}, -- hostile
	[3] = {0.1, 1.0, 0.1}, --friendly
	[4] = {1.0, 0.7, 0}, --contested
	[5] = {1.0, 0.9294, 0.7607}, --white
}

local ClassColor = RAID_CLASS_COLORS[E.myclass]

local function ZoneTextPos()
	_G["SubZoneTextString"]:ClearAllPoints()
	if ( _G["PVPInfoTextString"]:GetText() == "" ) then
		_G["SubZoneTextString"]:SetPoint("TOP", "ZoneTextString", "BOTTOM", 0, -E.db.sle.media.fonts.subzone.offset)
	else
		_G["SubZoneTextString"]:SetPoint("TOP", "PVPInfoTextString", "BOTTOM", 0, -E.db.sle.media.fonts.subzone.offset)
	end
end

local function MakeFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

function M:SetBlizzFonts()
	if E.private.general.replaceBlizzFonts then
		local db = E.db.sle.media.fonts

		_G["ZoneTextString"]:SetFont(E.LSM:Fetch('font', db.zone.font), db.zone.size, db.zone.outline) -- Main zone name
		_G["PVPInfoTextString"]:SetFont(E.LSM:Fetch('font', db.pvp.font), db.pvp.size, db.pvp.outline) -- PvP status for main zone
		_G["PVPArenaTextString"]:SetFont(E.LSM:Fetch('font', db.pvp.font), db.pvp.size, db.pvp.outline) -- PvP status for subzone
		_G["SubZoneTextString"]:SetFont(E.LSM:Fetch('font', db.subzone.font), db.subzone.size, db.subzone.outline) -- Subzone name

		_G["SendMailBodyEditBox"]:SetFont(E.LSM:Fetch('font', db.mail.font), db.mail.size, db.mail.outline) --Writing letter text
		_G["OpenMailBodyText"]:SetFont(E.LSM:Fetch('font', db.mail.font), db.mail.size, db.mail.outline) --Received letter text
		_G["QuestFont"]:SetFont(E.LSM:Fetch('font', db.gossip.font), db.gossip.size) -- Font in Quest Log/Petitions and shit. It's fucking hedious with any outline so fuck it.
		-- _G["QuestFont_Large"]:SetFont(E.LSM:Fetch('font', db.questFontLarge.font), db.questFontLarge.size, db.questFontLarge.outline) -- No idea what that is for
		_G["QuestFont_Super_Huge"]:SetFont(E.LSM:Fetch('font', db.questFontSuperHuge.font), db.questFontSuperHuge.size, db.questFontSuperHuge.outline) -- No idea what that is for
		_G["QuestFont_Enormous"]:SetFont(E.LSM:Fetch('font', db.questFontSuperHuge.font), db.questFontSuperHuge.size, db.questFontSuperHuge.outline) -- No idea what that is for
		--Objective Frame
		if not SLE._Compatibility["ElvUI_MerathilisUI"] or (SLE._Compatibility["ElvUI_MerathilisUI"] and not E.private.muiSkins.blizzard.objectivetracker) then
			local COLOR
			if E.db.sle.skins.objectiveTracker.classHeader then
				COLOR = ClassColor
			else
				COLOR = E.db.sle.skins.objectiveTracker.colorHeader
			end

			if not _G["ObjectiveTrackerFrame"].SLEHookedFonts then
				hooksecurefunc("ObjectiveTracker_Update", function(reason, id)
					-- _G["ObjectiveTrackerFrame"].HeaderMenu.Title:SetFont(E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, db.objectiveHeader.outline)
					_G["ObjectiveTrackerBlocksFrame"].CampaignQuestHeader.Text:SetFont(E.LSM:Fetch('font', E.db.sle.media.fonts.objectiveHeader.font), E.db.sle.media.fonts.objectiveHeader.size, E.db.sle.media.fonts.objectiveHeader.outline)
					_G["ObjectiveTrackerBlocksFrame"].QuestHeader.Text:SetFont(E.LSM:Fetch('font', E.db.sle.media.fonts.objectiveHeader.font), E.db.sle.media.fonts.objectiveHeader.size, E.db.sle.media.fonts.objectiveHeader.outline)
					_G["ObjectiveTrackerBlocksFrame"].AchievementHeader.Text:SetFont(E.LSM:Fetch('font', E.db.sle.media.fonts.objectiveHeader.font), E.db.sle.media.fonts.objectiveHeader.size, E.db.sle.media.fonts.objectiveHeader.outline)
					_G["ObjectiveTrackerBlocksFrame"].ScenarioHeader.Text:SetFont(E.LSM:Fetch('font', E.db.sle.media.fonts.objectiveHeader.font), E.db.sle.media.fonts.objectiveHeader.size, E.db.sle.media.fonts.objectiveHeader.outline)
					_G["WORLD_QUEST_TRACKER_MODULE"].Header.Text:SetFont(E.LSM:Fetch('font', E.db.sle.media.fonts.objectiveHeader.font), E.db.sle.media.fonts.objectiveHeader.size, E.db.sle.media.fonts.objectiveHeader.outline)
					_G["BONUS_OBJECTIVE_TRACKER_MODULE"].Header.Text:SetFont(E.LSM:Fetch('font', E.db.sle.media.fonts.objectiveHeader.font), E.db.sle.media.fonts.objectiveHeader.size, E.db.sle.media.fonts.objectiveHeader.outline)
				end)
				_G["ObjectiveTrackerFrame"].SLEHookedFonts = true
			end
			_G["ObjectiveTrackerFrame"].HeaderMenu.Title:SetFont(E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, db.objectiveHeader.outline)
			_G["ObjectiveTrackerBlocksFrame"].CampaignQuestHeader.Text:SetFont(E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, db.objectiveHeader.outline)
			_G["ObjectiveTrackerBlocksFrame"].QuestHeader.Text:SetFont(E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, db.objectiveHeader.outline)
			_G["ObjectiveTrackerBlocksFrame"].AchievementHeader.Text:SetFont(E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, db.objectiveHeader.outline)
			_G["ObjectiveTrackerBlocksFrame"].ScenarioHeader.Text:SetFont(E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, db.objectiveHeader.outline)
			_G["BONUS_OBJECTIVE_TRACKER_MODULE"].Header.Text:SetFont(E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, db.objectiveHeader.outline)
			_G["WORLD_QUEST_TRACKER_MODULE"].Header.Text:SetFont(E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, db.objectiveHeader.outline)
			_G["ObjectiveTrackerFrame"].HeaderMenu.Title:SetTextColor(COLOR.r, COLOR.g, COLOR.b)
			_G["ObjectiveTrackerBlocksFrame"].CampaignQuestHeader.Text:SetTextColor(COLOR.r, COLOR.g, COLOR.b)
			_G["ObjectiveTrackerBlocksFrame"].QuestHeader.Text:SetTextColor(COLOR.r, COLOR.g, COLOR.b)
			_G["ObjectiveTrackerBlocksFrame"].AchievementHeader.Text:SetTextColor(COLOR.r, COLOR.g, COLOR.b)
			_G["ObjectiveTrackerBlocksFrame"].ScenarioHeader.Text:SetTextColor(COLOR.r, COLOR.g, COLOR.b)
			_G["BONUS_OBJECTIVE_TRACKER_MODULE"].Header.Text:SetTextColor(COLOR.r, COLOR.g, COLOR.b)
			_G["WORLD_QUEST_TRACKER_MODULE"].Header.Text:SetTextColor(COLOR.r, COLOR.g, COLOR.b)
			MakeFont(_G["ObjectiveFont"], E.LSM:Fetch('font', db.objective.font), db.objective.size, db.objective.outline)
			if M.BonusObjectiveBarText then M.BonusObjectiveBarText:SetFont(E.LSM:Fetch('font', db.objective.font), db.objective.size, db.objective.outline) end
		end
	end
end

function M:TextShow()
	local z, i, a, s, c = random(1, #M.Zones), random(1, #M.PvPInfo), random(1, #M.PVPArena), random(1, #M.Subzones), random(1, #Colors)
	local red, green, blue = unpack(Colors[c])

	--Setting texts--
	_G["ZoneTextString"]:SetText(M.Zones[z])
	_G["PVPInfoTextString"]:SetText(M.PvPInfo[i])
	_G["PVPArenaTextString"]:SetText(M.PVPArena[a])
	_G["SubZoneTextString"]:SetText(M.Subzones[s])

	ZoneTextPos()--nil, true)

	--Applying colors--
	_G["ZoneTextString"]:SetTextColor(red, green, blue)
	_G["PVPInfoTextString"]:SetTextColor(red, green, blue)
	_G["PVPArenaTextString"]:SetTextColor(red, green, blue)
	_G["SubZoneTextString"]:SetTextColor(red, green, blue)

	FadingFrame_Show(_G["ZoneTextFrame"])
	FadingFrame_Show(_G["SubZoneTextFrame"])
end

function M:Initialize()
	if not SLE.initialized or not E.private.sle.media.enable then return end
	hooksecurefunc(E, "UpdateBlizzardFonts", M.SetBlizzFonts)
	hooksecurefunc("SetZoneText", ZoneTextPos)
	M.SetBlizzFonts()
end

SLE:RegisterModule(M:GetName())
