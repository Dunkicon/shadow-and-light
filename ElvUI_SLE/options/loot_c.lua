﻿local E, L, V, P, G, _ = unpack(ElvUI);
local LT = E:GetModule('SLE_Loot')

local function configTable()
	E.Options.args.sle.args.options.args.loot = {
		order = 9,
		type = "group",
		name = L['Loot'],
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
				get = function(info) return E.db.sle.loot.enable end,
				set = function(info, value) E.db.sle.loot.enable = value; E:StaticPopup_Show("CONFIG_RL") end
			},
			space1 = {
				order = 2,
				type = 'description',
				name = "",
			},
			autoroll = {
				order = 1,
				type = "group",
				name = "Loot Auto Roll",
				args = {
					autoconfirm = {
						order = 3,
						type = "toggle",
						name = "Auto Confirm",
						desc = "Automatically click OK on BOP items",
						disabled = function() return not E.db.sle.loot.enable end,
						get = function(info) return E.db.sle.loot.autoconfirm end,
						set = function(info, value) E.db.sle.loot.autoconfirm = value; end,
					},
					autogreed = {
						order = 4,
						type = "toggle",
						name = "Auto Greed",
						desc = "Automatically greed uncommon (green) quality items at max level",
						disabled = function() return not E.db.sle.loot.enable end,
						get = function(info) return E.db.sle.loot.autogreed end,
						set = function(info, value) E.db.sle.loot.autogreed = value; end,
					},
					autode = {
						order = 5,
						type = "toggle",
						name = "Auto Disenchant",
						desc = "Automatically disenchant uncommon (green) quality items at max level",
						disabled = function() return not E.db.sle.loot.enable end,
						get = function(info) return E.db.sle.loot.autode end,
						set = function(info, value) E.db.sle.loot.autode = value; end,
					},
					bylevel = {
						order = 6,
						type = "toggle",
						name = "Roll based on level.",
						desc = "This will auto-roll if you are above the given level if: You cannot equip the item being rolled on, or the ilevel of your equipped item is higher than the item being rolled on or you have an heirloom equipped in that slot",
						disabled = function() return not E.db.sle.loot.enable end,
						get = function(info) return E.db.sle.loot.bylevel end,
						set = function(info, value) E.db.sle.loot.bylevel = value; end,
					},
					level = {
						order = 7,
						type = "range",
						name = "Level to start auto-rolling from",
						desc = "Automatically disenchant uncommon (green) quality items at max level",
						disabled = function() return not E.db.sle.loot.enable end,
						min = 1, max = GetMaxPlayerLevel(), step = 1,
						get = function(info) return E.db.sle.loot.level end,
						set = function(info, value) E.db.sle.loot.level = value; end,
					},
					autoqlty = {
						order = 9,
						type = "select",
						name = L["Loot Quality"],
						desc = "Sets the auto greed/disenchant quality\n\nUncommon: Rolls on Uncommon only\nRare: Rolls on Rares & Uncommon",
						disabled = function() return not E.db.sle.loot.enable end,
						get = function(info) return E.db.sle.loot.autoqlty end,
						set = function(info, value) E.db.sle.loot.autoqlty = value; end,
						values = {
							[4] = "|cffA335EE"..ITEM_QUALITY4_DESC.."|r",
							[3] = "|cff0070DD"..ITEM_QUALITY3_DESC.."|r",
							[2] = "|cff1EFF00"..ITEM_QUALITY2_DESC.."|r",
						},
					},
				},
			},
			announcer = {
				order = 9,
				type = "group",
				name = L["Loot Announcer"],
				args = {
					header = {
						order = 1,
						type = "header",
						name = L['Loot Announcer'],
					},
					info = {
						order = 2,
						type = "description",
						name = L["LOOT_DESC"],
					},
					enable = {
						order = 3,
						type = "toggle",
						name = L["Enable"],
						disabled = function() return not E.db.sle.loot.enable end,
						get = function(info) return E.db.sle.loot.announcer.enable end,
						set = function(info, value) E.db.sle.loot.announcer.enable = value; E:StaticPopup_Show("CONFIG_RL") end
					},
					auto = {
						order = 4,
						type = "toggle",
						name = L["Auto Announce"],
						desc = L["AUTOANNOUNCE_DESC"],
						disabled = function() return not E.db.sle.loot.enable or not E.db.sle.loot.announcer.enable end,
						get = function(info) return E.db.sle.loot.announcer.auto end,
						set = function(info, value) E.db.sle.loot.announcer.auto = value; end
					},
					spacer = {
						order = 5,
						type = "description",
						name = "",
					},
					quality = {
						order = 9,
						type = "select",
						name = L["Loot Quality"],
						desc = L["Sets the minimum loot threshold to announce."],
						disabled = function() return not E.db.sle.loot.enable or not E.db.sle.loot.announcer.enable end,
						get = function(info) return E.db.sle.loot.announcer.quality end,
						set = function(info, value) E.db.sle.loot.announcer.quality = value;  end,
						values = {
							['EPIC'] = "|cffA335EE"..ITEM_QUALITY4_DESC.."|r",
							['RARE'] = "|cff0070DD"..ITEM_QUALITY3_DESC.."|r",
							['UNCOMMON'] = "|cff1EFF00"..ITEM_QUALITY2_DESC.."|r",
						},
					},
					channel = {
						order = 10,
						type = "select",
						name = L["Chat"],
						desc = L["Select chat channel to announce loot to."],
						disabled = function() return not E.db.sle.loot.enable or not E.db.sle.loot.announcer.enable end,
						get = function(info) return E.db.sle.loot.announcer.channel end,
						set = function(info, value) E.db.sle.loot.announcer.channel = value;  end,
						values = {
							['RAID'] = "|cffFF7F00"..RAID.."|r",
							['PARTY'] = "|cffAAAAFF"..PARTY.."|r",
							['SAY'] = "|cffFFFFFF"..SAY.."|r",
						},
					},
				},
			},
			history = {
				order = 10,
				type = "group",
				name = L["Loot Roll History"],
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Loot Roll History"],
					},
					info = {
						order = 2,
						type = "description",
						name = L["LOOTH_DESC"],
					},
					window = {
						order = 3,
						type = "toggle",
						name = L["Auto hide"],
						desc = L["Automaticaly hides Loot Roll Histroy frame when leaving the instance."],
						disabled = function() return not E.db.sle.loot.enable end,
						get = function(info) return E.db.sle.loot.history.autohide end,
						set = function(info, value) E.db.sle.loot.history.autohide = value; LT:LootShow() end
					},
					alpha = {
						order = 4,
						type = "range",
						name = L['Alpha'],
						desc = L["Sets the alpha of Loot Roll Histroy frame."],
						min = 0.2, max = 1, step = 0.1,
						disabled = function() return not E.db.sle.loot.enable end,
						get = function(info) return E.db.sle.loot.history.alpha end,
						set = function(info, value) E.db.sle.loot.history.alpha = value; LT:LootShow() end,
					},
				},
			},
		},
	}
end

table.insert(E.SLEConfigs, configTable)