﻿local E, L, V, P, G =  unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local CH = E:GetModule('Chat')

local selectedName
local selectedChannel
local names
local channels


E.Options.args.sle.args.chat = {
	order = 8,
	type = "group",
	name = L["Chat"],
	args = {
		header = {
			order = 1,
			type = "header",
			name = L["Chat Options"],
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			guiInline = true,
			args = {
				chatwindowfade = {
					order = 1,
					type = "toggle",
					name = L["Chat Fade"],
					desc = L["Enable/Disable the text fading in the chat window."],
					get = function(info) return E.db.sle.chat.fade end,
					set = function(info, value) E.db.sle.chat.fade = value; CH:FadeUpdate() end, 
				},
				editboxhistory = {
					order = 2,
					type = "range",
					name = L["Chat Editbox History"],
					desc = L["Amount of messages to save. Set to 0 to disable."],
					min = 0, max = 20, step = 1,
					get = function(info) return E.db.chat.editboxhistory end,
					set = function(info, value)	E.db.chat.editboxhistory = value; end,
				},
			},
		},
	},
}
