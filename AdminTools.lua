require 'lib.moonloader'
require 'lib.sampfuncs' 
script_name 'AdminTool'  
script_author 'Neon4ik' 
script_properties("work-in-pause") 
local version = 3.04 -- Версия скрипта
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
------=================== Подгрузка библиотек ===================----------------------
local imgui = require 'imgui' 
local sampev = require 'lib.samp.events'
local imadd = require 'imgui_addons'
local mimgui = require "mimgui"
local inicfg = require 'inicfg'
local directIni = 'AdminTools.ini'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local vkeys = require 'vkeys'
local ffi = require "ffi"
local mem = require "memory"
local font = require ("moonloader").font_flag
------=================== Подгрузка библиотек ===================----------------------
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local AT_MP = script.load("\\resource\\AT_MP.lua") -- подгрузка плагина для мероприятий
local AT_FastSpawn = script.load('\\resource\\AT_FastSpawn.lua') -- подгрузка быстрого спавна
local AT_Trassera = script.load('\\resource\\AT_Trassera.lua') -- подгрузка трассеров
local notify_report = import("\\resource\\lib_imgui_notf.lua") -- импорт уведомлений
local fonts = renderCreateFont('TimesNewRoman', 12, 5) -- текст для автоформ
local tag = '{2B6CC4}Admin Tools: {F0E68C}'
local sw, sh = getScreenResolution()
local pravila = {}
local cfg = inicfg.load({ 
	settings = {
		style = 0,
		autoonline = false,
		inputhelper = true,
		add_answer_report = true,
		notify_report = false,
		find_warning_weapon_hack = false,
		automute = false,
		smart_automute = false,
		render_admins_positionX = sw - 300,
		render_admins_positionY = sh - 300,
		render_admins = false,
		render_ears = false,
		mytextreport = ' // Приятной игры на RDS <3',
		position_recon_menu_x = sw - 270,
		position_recon_menu_y = 0,
		keysync = true,
		fast_key_ans = 'None',
		fast_key_takereport = 'None',
		fast_key_wallhack = 'None',
		fast_key_addText = 'None',
		fast_key_mytext = 'None',
		wallhack = true,
		answer_player_report = false,
		bloknotik = '',
		admin_chat = false,
		position_adminchat_x = -2,
		position_adminchat_y = (sh*0.5)-100,
		size_adminchat = 10,
		custom_answer_save = false,
		find_form = false,
		forma_na_ban = false,
        forma_na_jail = false,
        forma_na_mute = false,
        forma_na_kick = false,
        add_mynick_in_form = false,
		on_custom_recon_menu = true,
		on_custom_answer = true,
		strok_admin_chat = 6,
		position_ears_x = sw/2,
		position_ears_y = sh - 100,
		size_ears = 10,
		strok_ears = 6,
		keysyncx = sh/2 + 100,
		keysyncy = sw/2 + 20,
		versionFS = 10,
		versionMP = 10,
	},
	customotvet = {},
	osk = {},
	mat = {},
	myflood = {},
	my_command = {},
}, directIni)
inicfg.save(cfg,directIni) -- Если файла, или определенных настроек нет, добавляем их в файл AdminTools.ini

local windows = {
	menu_tools = imgui.ImBool(false),
	fast_report = imgui.ImBool(false),
	fast_rmute = imgui.ImBool(false),
	recon_menu = imgui.ImBool(false),
	recon_ban_menu = imgui.ImBool(false),
	recon_mute_menu = imgui.ImBool(false),
	recon_jail_menu = imgui.ImBool(false),
	recon_kick_menu = imgui.ImBool(false),
	actions_in_recon_menu = imgui.ImBool(false),
	help_young_admin = imgui.ImBool(false),
	answer_player_report = imgui.ImBool(false),
	custom_ans = imgui.ImBool(false),
	render_admins = imgui.ImBool(false),
	new_flood_mess = imgui.ImBool(false),
	new_position_recon_menu = imgui.ImBool(false),
	new_position_keylogger = imgui.ImBool(false),
	new_position_render_admins = imgui.ImBool(false),
	new_position_adminchat = imgui.ImBool(false),
	pravila = imgui.ImBool(false),
}

local checkbox = {
	check_automute = imgui.ImBool(cfg.settings.automute),
	check_keysync = imgui.ImBool(cfg.settings.keysync),
	check_autoonline = imgui.ImBool(cfg.settings.autoonline),
	check_find_form = imgui.ImBool(cfg.settings.find_form),
	check_save_answer = imgui.ImBool(cfg.settings.custom_answer_save),
	check_render_admins = imgui.ImBool(cfg.settings.render_admins),
	check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report),
	check_admin_chat = imgui.ImBool(cfg.settings.admin_chat),
	check_form_ban = imgui.ImBool(cfg.settings.forma_na_ban),
	check_form_jail = imgui.ImBool(cfg.settings.forma_na_jail),
	check_form_mute = imgui.ImBool(cfg.settings.forma_na_mute),
	check_form_kick = imgui.ImBool(cfg.settings.forma_na_kick),
	check_inputhelper = imgui.ImBool(cfg.settings.inputhelper),
	check_WallHack = imgui.ImBool(cfg.settings.wallhack),
	check_add_answer_report = imgui.ImBool(cfg.settings.add_answer_report),
	check_add_mynick_form = imgui.ImBool(cfg.settings.add_mynick_in_form),
	check_notify_report = imgui.ImBool(cfg.settings.notify_report),
	check_find_weapon_hack = imgui.ImBool(cfg.settings.find_warning_weapon_hack),
	check_smart_automute = imgui.ImBool(cfg.settings.smart_automute),
	check_on_custom_recon_menu = imgui.ImBool(cfg.settings.on_custom_recon_menu),
	check_on_custom_answer = imgui.ImBool(cfg.settings.on_custom_answer),
	check_render_ears = imgui.ImBool(cfg.settings.render_ears),
}
local buffer = {
	text_ans = imgui.ImBuffer(256),
	custom_answer = imgui.ImBuffer(256),
	find_custom_answer = imgui.ImBuffer(256),
	newmat = imgui.ImBuffer(256),
	newosk = imgui.ImBuffer(256),
	add_new_text = imgui.ImBuffer(u8(cfg.settings.mytextreport), 256),
	bloknotik = imgui.ImBuffer(cfg.settings.bloknotik, 4096),
	new_flood_mess = imgui.ImBuffer(4096),
	title_flood_mess = imgui.ImBuffer(256),
	new_command_title = imgui.ImBuffer(256),
	new_command = imgui.ImBuffer(4096),
	find_rules = imgui.ImBuffer(256),
}
local menu = {true, -- рекон меню
    false,
}
local menu2 = {true, -- основное меню
    false,
	false,
	false,
	false,
	false,
	false,
}
local textdraw = {} -- узнаем ид текстравов для взаимодействия с ними
local style_selected = imgui.ImInt(cfg.settings.style)
local style_list = {u8"Темно-Синяя тема", u8"Красная тема", u8"Зеленая тема", u8"Бирюзовая тема", u8"Розовая тема", u8"Голубая тема"}
local selected_item = imgui.ImInt(cfg.settings.size_adminchat)
local st = {}
local nakazatreport = {}
local answer = {}
local adminchat = {}
local ears = {}

local spisok = { -- список для автоформ
	'ban',
	'jail',
	'kick',
	'mute',
	'spawncars',
	'aspawn'
}
local spisokproject = { -- список проектов за который идет автомут
	'аризон',
	'блэк раша',
	'блек раша',
	'эвольв',
	'евольв',
	'монсер',
	'арз',
	'arz',
	'радмир',
	'родина рп'
}
local spisokoskrod = { -- список оск.род за который идет автомут
	'mq',
	'rnq'
}
local spisokrz = { -- список примерного розжига
	'слава укр',
	'слава росс',
}
local spisokor = { -- список возможных вариаций оскорбления родни (мат + что-то из этого списка, или что-то из списка и оск)
	'сын',
	'мать',
	'мам',
	'выблядок',
}
local keys = {
	["onfoot"] = {},
	["vehicle"] = {}
}

local fontsize = nil
--icon
local fa = require 'faicons'
local fa_glyph_ranges = imgui.ImGlyphRanges( {fa.min_range, fa.max_range} )
--icon
function imgui.BeforeDrawFrame()
    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 17.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- 17 razmer
    end
	--icon
	if fa_font == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end
	--icon
end
ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
]]
local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)
chars = {
	["й"] = "q", ["ц"] = "w", ["у"] = "e", ["к"] = "r", ["е"] = "t", ["н"] = "y", ["г"] = "u", ["ш"] = "i", ["щ"] = "o", ["з"] = "p", ["х"] = "[", ["ъ"] = "]", ["ф"] = "a",
	["ы"] = "s", ["в"] = "d", ["а"] = "f", ["п"] = "g", ["р"] = "h", ["о"] = "j", ["л"] = "k", ["д"] = "l", ["ж"] = ";", ["э"] = "'", ["я"] = "z", ["ч"] = "x", ["с"] = "c", ["м"] = "v",
	["и"] = "b", ["т"] = "n", ["ь"] = "m", ["б"] = ",", ["ю"] = ".", ["Й"] = "Q", ["Ц"] = "W", ["У"] = "E", ["К"] = "R", ["Е"] = "T", ["Н"] = "Y", ["Г"] = "U", ["Ш"] = "I",
	["Щ"] = "O", ["З"] = "P", ["Х"] = "{", ["Ъ"] = "}", ["Ф"] = "A", ["Ы"] = "S", ["В"] = "D", ["А"] = "F", ["П"] = "G", ["Р"] = "H", ["О"] = "J", ["Л"] = "K", ["Д"] = "L",
	["Ж"] = ":", ["Э"] = "\"", ["Я"] = "Z", ["Ч"] = "X", ["С"] = "C", ["М"] = "V", ["И"] = "B", ["Т"] = "N", ["Ь"] = "M", ["Б"] = "<", ["Ю"] = ">"
}
function sampev.onPlayerDeathNotification(killerId, killedId, reason) -------- Подпись ID в килл чате
	local kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)
	
	killer,killed,reasonkill = killerId,killedId,reason
	
	local n_killer = ( sampIsPlayerConnected(killerId) or killerId == myid ) and sampGetPlayerNickname(killerId) or nil
	local n_killed = ( sampIsPlayerConnected(killedId) or killedId == myid ) and sampGetPlayerNickname(killedId) or nil
	lua_thread.create(function()
	wait(0)
	if n_killer then kill.killEntry[4].szKiller = ffi.new('char[25]', ( n_killer .. '[' .. killerId .. ']' ):sub(1, 24) ) end
	if n_killed then kill.killEntry[4].szVictim = ffi.new('char[25]', ( n_killed .. '[' .. killedId .. ']' ):sub(1, 24) ) end
	end)
end
function main() -- основной сценарий скрипта
	while not isSampAvailable() do wait(0) end
	while not sampIsLocalPlayerSpawned() do wait(1000) end
	if sampGetCurrentServerAddress() == '46.174.52.246' then
		sampAddChatMessage(tag .. 'Скрипт успешно загружен. Активация F3 или /tool', -1)
	elseif sampGetCurrentServerAddress() == '46.174.49.170' then
		sampAddChatMessage(tag .. 'Скрипт успешно загружен. Активация F3 или /tool', -1)
		server03 = true
	else
		sampAddChatMessage(tag .. 'Я предназначен для RDS, там и буду работать.', -1)
		--ScriptExport()
	end
 	font_adminchat = renderCreateFont("Calibri", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW)
	font_earschat = renderCreateFont("Calibri", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)
	func6 = lua_thread.create_suspended(HelperMA)
	func1 = lua_thread.create_suspended(render_adminchat)
	func1:run()
	if cfg.settings.forma_na_ban or cfg.settings.forma_na_mute or cfg.settings.forma_na_jail or cfg.settings.forma_na_mute then
		func6:run()
	end
	func = lua_thread.create_suspended(autoonline)
	funcadm = lua_thread.create_suspended(render_admins)
	funct = lua_thread.create_suspended(timer)
	funct:run()
	if cfg.settings.autoonline then
		func:run()
	end
	lua_thread.create(function()
		local font_watermark = renderCreateFont("Javanese Text", 8, font.BOLD + font.BORDER + font.SHADOW)
		while true do 
			wait(1)
			renderFontDrawText(font_watermark, tag .. '{A9A9A9}version['.. version .. ']', 10, sh-20, 0xCCFFFFFF)
		end	
	end)
	dlstatus = require('moonloader').download_status
    downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.ini", getWorkingDirectory() .. '//AdminTools.ini', function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local AdminTools = inicfg.load(nil, getWorkingDirectory() .. '//AdminTools.ini')
			if AdminTools.script.version > version then
				update_state = true
			end
			if AdminTools.script.versionMP > cfg.settings.versionMP then
				update_state = true
			end
			if AdminTools.script.versionFS > cfg.settings.versionFS then
				update_state = true
			end
			os.remove(getWorkingDirectory() .. "/AdminTools.ini" )
		end
    end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", getWorkingDirectory() .. "//config//rules.txt", function(id, status) 
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			--------------------------- Правила ---------------------------
			rules = io.open(getWorkingDirectory() .. "\\config\\rules.txt","r")
			for line in rules:lines() do pravila[#pravila + 1] = u8:decode(line);end
			rules:close()
			--------------------------- Правила ---------------------------
		end
	end)
	lua_thread.create(inputChat)
	if cfg.settings.render_admins then
		funcadm:run()
	end
	if cfg.settings.wallhack then
		local pStSet = sampGetServerSettingsPtr();
		NTdist = mem.getfloat(pStSet + 39)
		NTwalls = mem.getint8(pStSet + 47)
		NTshow = mem.getint8(pStSet + 56)
		mem.setfloat(pStSet + 39, 500.0)
		mem.setint8(pStSet + 47, 0)
		mem.setint8(pStSet + 56, 1)
		nameTag = true
	end
	for k,v in pairs(cfg.my_command) do -- регистрация команд пользователя
		sampRegisterChatCommand(k, function(param)
			lua_thread.create(function()
				for a,b in pairs(textSplit(string.gsub(v, '_', param), '\n')) do
					if b:match('wait(%(%d+)%)') then
						wait(tonumber(b:match('%d+') .. '000'))
					else
						sampSendChat(b)
					end
				end
			end)
		end)
	end
	--mem.write(sampGetBase() + 643864, 37008, 2, true) худ в реконе
	while true do
        wait(0)
		if isPauseMenuActive() or isGamePaused() then
			AFK = true
		end
		if AFK and not (isPauseMenuActive() or isGamePaused()) then
			AFK = nil
		end
		if isKeyJustPressed(0x54 --[[VK_T]]) and not windows.fast_report.v and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
			sampSetChatInputEnabled(true)
		end
		if isKeyJustPressed(VK_F3) and not sampIsDialogActive() then  -- кнопка активации окна
			windows.menu_tools.v = not windows.menu_tools.v
			imgui.Process = true
			showCursor(true,false)
		end
		if cfg.settings.wallhack and not AFK then
			for i = 0, sampGetMaxPlayerId() do
				if sampIsPlayerConnected(i) then
					local result, cped = sampGetCharHandleBySampPlayerId(i)
					local color = sampGetPlayerColor(i)
					local aa, rr, gg, bb = explode_argb(color)
					local color = join_argb(255, rr, gg, bb)
					if result then
						if doesCharExist(cped) and isCharOnScreen(cped) then
							local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
							for v = 1, #t do
								pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], cped)
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, cped)
								pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
							end
							for v = 4, 5 do
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, cped)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
							end
							local t = {53, 43, 24, 34, 6}
							for v = 1, #t do
								posX, posY, posZ = getBodyPartCoordinates(t[v], cped)
								pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
							end
						end
					end
				end
			end
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_ans)) and not windows.fast_report.v and not windows.answer_player_report.v and not isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() and not windows.menu_tools.v then
			sampSendChat("/ans")
			sampSendDialogResponse (2348, 1, 0)
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_takereport)) and not windows.fast_report.v and not windows.answer_player_report.v and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not windows.menu_tools.v then
			sampSendChat("/tr")
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_wallhack)) and not windows.fast_report.v and not windows.answer_player_report.v  and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not windows.menu_tools.v then
			sampSendChat('/spveh 100')
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_addText)) and not windows.fast_report.v and not windows.answer_player_report.v  and not isKeyJustPressed(VK_RBUTTON)  and not sampIsDialogActive() and not windows.menu_tools.v then
			sampSetChatInputText(string.sub(sampGetChatInputText(), 1, -2) .. ' '.. cfg.settings.mytextreport)
			sampSetChatInputEnabled(true)
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_mytext)) and not windows.fast_report.v and not windows.answer_player_report.v  and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not windows.menu_tools.v then
			sampSendInputChat('/wh')
		end
	end
end
function imgui.OnDrawFrame()
	if not windows.render_admins.v and not windows.menu_tools.v and not windows.pravila.v and not windows.fast_report.v and not windows.recon_menu.v and not windows.help_young_admin.v and not windows.new_position_recon_menu.v and not windows.new_position_keylogger.v and not windows.new_position_adminchat.v and not windows.answer_player_report.v and not windows.actions_in_recon_menu.v then
		showCursor(false,false)
		imgui.Process = false
		if cfg.settings.render_admins then
			sampSendChat('/admins')
		end
	end
	if windows.menu_tools.v then -- КНОПКИ ИНТЕРФЕЙСА F3
		if windows.render_admins.v then
			windows.render_admins.v = false
		end
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(420, 400), imgui.Cond.FirstUseEver)
		imgui.Begin('xX   ' .. " Admin Tools " .. '  Xx', windows.menu_tools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text('           ')
		imgui.SameLine()
		if imgui.Button(fa.ICON_ADDRESS_BOOK, imgui.ImVec2(30, 30)) then uu2() menu2[1] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_COGS, imgui.ImVec2(30, 30)) then uu2() menu2[3] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_PENCIL_SQUARE, imgui.ImVec2(30, 30)) then uu2() menu2[4] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_CALENDAR_CHECK_O, imgui.ImVec2(30, 30)) then uu2() menu2[5] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_SEARCH, imgui.ImVec2(30, 30)) then uu2() menu2[6] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_RSS, imgui.ImVec2(30, 30)) then uu2() menu2[7] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_BOOKMARK, imgui.ImVec2(30, 30)) then uu2() menu2[2] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_CLOUD, imgui.ImVec2(30, 30)) then uu2() menu2[8] = true end
        imgui.Separator()
        imgui.NewLine()
        imgui.SameLine(2)
		if menu2[1] then
			imgui.SetCursorPosX(8)
			if imadd.ToggleButton("##virtualkey", checkbox.check_keysync) then
				cfg.settings.keysync = not cfg.settings.keysync
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Виртуал. клавиши')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##autoonline", checkbox.check_autoonline) then
				if cfg.settings.autoonline then
					cfg.settings.autoonline = not cfg.settings.autoonline
					inicfg.save(cfg, directIni)
					func:terminate()
				else
					cfg.settings.autoonline = not cfg.settings.autoonline
					inicfg.save(cfg, directIni)
					func:run()
				end
			end
			imgui.SameLine()
			imgui.Text('autoonline')
			if imadd.ToggleButton("##input helper", checkbox.check_inputhelper) then
				cfg.settings.inputhelper = not cfg.settings.inputhelper
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Перевод команд')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##WallHack", checkbox.check_WallHack) then
				sampSendInputChat('/wh ')
			end
			imgui.SameLine()
			imgui.Text('WallHack')
			if imadd.ToggleButton("##AdminChat", checkbox.check_admin_chat) then
				if cfg.settings.admin_chat then
					adminchat = {}
				end
				cfg.settings.admin_chat = not cfg.settings.admin_chat
				save()
			end
			imgui.SameLine()
			imgui.Text('Admin Chat')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton('##find_form', checkbox.check_find_form) then
				if server03 then
					cfg.settings.find_form  = false
					save()
					checkbox.check_find_form = imgui.ImBool(cfg.settings.find_form)
				else
					cfg.settings.find_form  = not cfg.settings.find_form
					save()
				end
			end
			imgui.SameLine()
			imgui.Text(u8'Слежка за формами')
			if imadd.ToggleButton('##automute', checkbox.check_automute) then
				cfg.settings.automute  = not cfg.settings.automute
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Автомут')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##NotifyPlayer", checkbox.check_answer_player_report) then
				if not cfg.settings.on_custom_recon_menu then
					sampAddChatMessage(tag .. 'Данная функция работает только с кастом рекон меню', -1)
					cfg.settings.answer_player_report = false
					save()
					checkbox.check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report)
				else
					cfg.settings.answer_player_report = not cfg.settings.answer_player_report
					save()
				end
			end
			imgui.SameLine()
			imgui.Text(u8'Уведомление игрока')
			if imadd.ToggleButton("##SmartAutomute", checkbox.check_smart_automute) then
				if not cfg.settings.automute then
					cfg.settings.automute  = not cfg.settings.automute
					save()
					checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
				end
				cfg.settings.smart_automute = not cfg.settings.smart_automute
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Умный автомут')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##NotifyReport", checkbox.check_notify_report) then
				cfg.settings.notify_report = not cfg.settings.notify_report
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Уведомление о репорте')
			if imadd.ToggleButton(u8"##TriggerWarning", checkbox.check_find_weapon_hack) then
				cfg.settings.find_warning_weapon_hack = not cfg.settings.find_warning_weapon_hack
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Реакция на варнинги')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##render/admins", checkbox.check_render_admins) then
				if cfg.settings.render_admins then
					cfg.settings.render_admins = not cfg.settings.render_admins
					save()
					admins = nil
					windows.render_admins.v = false
					funcadm:terminate()
				else
					cfg.settings.render_admins = not cfg.settings.render_admins
					save()
					funcadm:run()
				end
			end
			imgui.SameLine()
			imgui.Text(u8'Рендер /admins')
			if imadd.ToggleButton("##CustomReconMenu", checkbox.check_on_custom_recon_menu) then
				if cfg.settings.on_custom_recon_menu and cfg.settings.answer_player_report then
					cfg.settings.answer_player_report = false
					save()
					checkbox.check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report)
				end
				cfg.settings.on_custom_recon_menu = not cfg.settings.on_custom_recon_menu
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Кастом рекон меню')
			imgui.SameLine()
			if imadd.ToggleButton("##FastReport", checkbox.check_on_custom_answer) then
				cfg.settings.on_custom_answer = not cfg.settings.on_custom_answer
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Кастом ответ на репорт')
			if imadd.ToggleButton("##renderEars", checkbox.check_render_ears) then
				if cfg.settings.render_ears then
					ears = {}
				end
				cfg.settings.render_ears = not cfg.settings.render_ears
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Рендер /ears')
			if update_state then
				if imgui.Button(u8'Обновить скрипт', imgui.ImVec2(410,24)) then
					imgui.Process = false
					showCursor(false,false)
					downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_MP.lua", getWorkingDirectory() .. "//resource//AT_MP.lua", function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							sampAddChatMessage(tag .. 'Первый плагин подгружен. Ожидаю подгрузку второго.', -1)
						end
					end)
					downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_FastSpawn.lua", getWorkingDirectory() .. "//resource//AT_FastSpawn.lua", function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							sampAddChatMessage(tag .. 'Второй плагин успешно обновлены. Ожидаю загрузку основного скрипта', -1)
						end
					end)
					downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.lua", thisScript().path, function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							sampAddChatMessage(tag .. 'Основной скрипт успешно обновлен.')
							reloadScripts()
						end
					end)
				end
			end
			imgui.Text('\n')
			imgui.Separator()
			imgui.Text(u8'Разработчик скрипта - N.E.O.N [RDS 01].\nОбратная связь ниже\n')
			imgui.Text('VK:')
			imgui.SameLine()
			if imgui.Link("https://vk.com/alexandrkob", u8"Нажми, чтобы открыть ссылку в браузере") then
				os.execute(('explorer.exe "%s"'):format("https://vk.com/alexandrkob"))
			end
			imgui.Text(u8'Группа в VK:')
			imgui.SameLine()
			if imgui.Link("https://vk.com/club222702914", u8"Нажми, чтобы открыть ссылку в браузере") then
				os.execute(('explorer.exe "%s"'):format("https://vk.com/club222702914"))
			end
		end
		if menu2[3] then
			imgui.SetCursorPosX(8)
			if imgui.Button(u8'Автоматическая отправка форм', imgui.ImVec2(410, 24)) and not server03 then
				windows.menu_tools.v = false
				windows.help_young_admin.v = not windows.help_young_admin.v
			end
			if imgui.Button(u8'Открыть настройки спавна', imgui.ImVec2(410, 24)) then
				windows.menu_tools.v = false
				sampSendInputChat('/fs')
			end
			if imgui.Button(u8'Открыть настройки трассеров', imgui.ImVec2(410, 24)) then
				windows.menu_tools.v = false
				sampSendInputChat('/trassera')
			end
			if imgui.Button(u8'Открыть настройки админ-статистики', imgui.ImVec2(410, 24)) then
				sampSendInputChat('/state')
				windows.menu_tools.v = false
				showCursor(true,false)
			end
			imgui.Text('\n\n')
			imgui.CenterText(u8'Дополнительный текст команд')
			imgui.PushItemWidth(410)
			if imgui.InputText('##doptextcommand', buffer.add_new_text) then
				cfg.settings.mytextreport = u8:decode(buffer.add_new_text.v)
				save()	
			end
			imgui.PopItemWidth()
			if imgui.Button(u8'Сохранить позицию Recon Menu', imgui.ImVec2(410, 24)) then
				if windows.recon_menu.v then
					windows.recon_menu.v = not windows.recon_menu.v
					windows.new_position_recon_menu.v = not windows.new_position_recon_menu.v
				else
					sampAddChatMessage(tag .. 'Зайдите в слежку во избежания рассихрона', -1)
				end
			end
			if cfg.settings.render_admins then
				if imgui.Button(u8'Сохранить позицию рендера /admins', imgui.ImVec2(410, 24)) then
					windows.new_position_render_admins.v = true
				end
			end
			if cfg.settings.admin_chat then
				if imgui.Button(u8'Сохранить позицию рендеров текста', imgui.ImVec2(410, 24)) then
					windows.new_position_adminchat.v = not windows.new_position_adminchat.v
				end
			end
			if cfg.settings.keysync then
				if imgui.Button(u8'Сохранить позицию вирт.клавиш', imgui.ImVec2(410, 23)) then
					windows.new_position_keylogger.v = not windows.new_position_keylogger.v 
				end
			end
			if imgui.Button(u8'Выгрузить скрипт ' .. fa.ICON_POWER_OFF, imgui.ImVec2(410, 23)) then
				ScriptExport()
			end
		end
		if menu2[4] then
			buffer.bloknotik.v = string.gsub(buffer.bloknotik.v, "\\n", "\n")
			if imgui.InputTextMultiline("##1", buffer.bloknotik, imgui.ImVec2(410, 390)) then
				buffer.bloknotik.v = string.gsub(buffer.bloknotik.v, "\n", "\\n")
				cfg.settings.bloknotik = buffer.bloknotik.v
				save()	
			end
		end
		if menu2[5] then
			imgui.SetCursorPosX(10)
			imgui.CenterText(u8'Открытие репорта:')
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_ans))
			if imgui.Button(u8"Сoxрaнить.", imgui.ImVec2(410, 24)) then
				if getDownKeysText() then
					cfg.settings.fast_key_ans = getDownKeysText()
					save()
				end
			end
			imgui.CenterText(u8'Вкл/выкл быстрого репорта')
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_takereport))
			if imgui.Button(u8"Соxрaнить.", imgui.ImVec2(410, 24)) then
				if getDownKeysText() then
					cfg.settings.fast_key_takereport = getDownKeysText()
					save()
				end
			end
			imgui.CenterText(u8"Очистка транспорта: ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_wallhack))
			if imgui.Button(u8"Cоxрaнить.", imgui.ImVec2(410, 24)) then
				if getDownKeysText() then
					cfg.settings.fast_key_wallhack = getDownKeysText()
					save()
				end
			end
			imgui.CenterText(u8"Отправка в чат доп.текста")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_addText))
			if imgui.Button(u8"Coxрaнить.", imgui.ImVec2(410, 24)) then
				if getDownKeysText() then
					cfg.settings.fast_key_addText = getDownKeysText()
					save()
				end
			end
			imgui.CenterText(u8"Вкл/выкл WallHack ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_mytext))
			if imgui.Button(u8"Соxpaнить.", imgui.ImVec2(410, 24)) then
				if getDownKeysText() then
					cfg.settings.fast_key_mytext = getDownKeysText()
					save()
				end
			end
			imgui.Separator()
			if imgui.Button(u8"Сбросить все значения.", imgui.ImVec2(410, 24)) then
				cfg.settings.fast_key_mytext = 'None'
				cfg.settings.fast_key_ans = 'None'
				cfg.settings.fast_key_wallhack = 'None'
				cfg.settings.fast_key_addText = 'None'
				cfg.settings.fast_key_takereport = 'None'
				save()
			end
		end
		if menu2[7] then
			imgui.SetCursorPosX(8)
			if imgui.Button(u8'Мои флуды', imgui.ImVec2(410, 25)) then
				windows.new_flood_mess.v = not windows.new_flood_mess.v 
			end
			imgui.CenterText(u8'Флуды об /gw')
			if imgui.Button(u8'Aztecas vs Ballas', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
					wait(500)
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Ballas Gang ##')
					wait(500)
					sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Aztecas vs Grove', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
					wait(500)
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Grove Street Gang ##')
					wait(500)
					sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Aztecas vs Vagos', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
					wait(500)
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Vagos Gang ##')
					wait(500)
					sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			if imgui.Button(u8'Aztecas vs Rifa', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
					wait(500)
					sampSendChat('/mess 14 ## Varios Los Aztecas vs The Rifa ##')
					wait(500)
					sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Ballas vs Grove', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
					wait(500)
					sampSendChat('/mess 14 ## Ballas Gang vs Grove Street Gang ##')
					wait(500)
					sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Ballas vs Vagos', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
					wait(500)
					sampSendChat('/mess 14 ## Ballas Gang vs Vagos Gang ##')
					wait(500)
					sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			if imgui.Button(u8'Ballas vs Rifa', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
					wait(500)
					sampSendChat('/mess 14 ## Ballas Gang vs The Rifa ##')
					wait(500)
					sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Grove vs Vagos', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
					wait(500)
					sampSendChat('/mess 14 ## Grove Street Gang vs Vagos Gang ##')
					wait(500)
					sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Vagos vs Rifa', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
					wait(500)
					sampSendChat('/mess 14 ## Vagos Gang vs The Rifa ##')
					wait(500)
					sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.CenterText(u8'Общие флуды')
			if imgui.Button(u8'Спавн авто', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 10 --------===================| Spawn Auto |================-----------')
					wait(500)
					sampSendChat('/mess 15 Многоуважаемые дрифтеры и дрифтерши')
					wait(500)
					sampSendChat('/mess 15 Через 15 секунд пройдёт респавн всего транспорта на сервере.')
					wait(500)
					sampSendChat('/mess 15 Займите свои супер кары во избежания потери :3')
					wait(500)
					sampSendChat('/mess 10 --------===================| Spawn Auto |================-----------')
					wait(500)
					sampSendChat('/delcarall')
					wait(500)
					sampSendChat('/spawncars 15')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'/trade', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 3 --------===================| Рынок |================-----------')
					wait(500)
					sampSendChat('/mess 0 Мечтал приобрести акксессуары на свой скин?')
					wait(500)
					sampSendChat('/mess 0 Бегать с ручным попугайчиком на плече и светится как боженька?')
					wait(500)
					sampSendChat('/mess 0 Скорей вводи /trade, большой выбор ассортимента, как от сервера, так и от игроков!')
					wait(500)
					sampSendChat('/mess 3 --------===================| Рынок |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Автомастерская', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 16 --------===================| Автомастерская |================-----------')
					wait(500)
					sampSendChat('/mess 17 Всегда мечтал приобрести ковш на свой кибертрак? Не проблема!')
					wait(500)
					sampSendChat('/mess 17 В автомастерских из /tp - разное - автомастерские найдется и не такое.')
					wait(500)
					sampSendChat('/mess 17 Сделай апгрейд своего любимчика под свой вкус и цвет')
					wait(500)
					sampSendChat('/mess 16 --------===================| Автомастерская |================-----------')
				end)
			end
			if imgui.Button(u8'Группа/Форум', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| Сторонние площадки |================-----------')
					wait(500)
					sampSendChat('/mess 7 У нашего проекта имеется группа vk.сom/teamadmrds ...')
					wait(500)
					sampSendChat('/mess 7 ... и даже форум, на котором игроки могут оставить жалобу на администрацию или игроков.')
					wait(500)
					sampSendChat('/mess 7 Следи за новостями и будь вкурсе событий.')
					wait(500)
					sampSendChat('/mess 11 --------===================| Сторонние площадки |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'VIP', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 13 --------===================| Преимущества VIP |================-----------')
					wait(500)
					sampSendChat('/mess 7 Хочешь играть с друзьями без дискомфорта?')
					wait(500)
					sampSendChat('/mess 7 Хочешь всегда телепортироваться по карте и к друзьям, чтобы быть всегда вместе?')
					wait(500)
					sampSendChat('/mess 7 Хочешь получать каждый PayDay плюшки на свой аккаунт? Обзаведись VIP-статусом!')
					wait(500)
					sampSendChat('/mess 13 --------===================| Преимущества VIP |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Арене', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 12 --------===================| PVP Arena |================-----------')
					wait(500)
					sampSendChat('/mess 10 Не знаешь чем заняться? Хочется экшена и быстрой реакции?')
					wait(500)
					sampSendChat('/mess 10 Вводи /arena и покажи на что ты способен!')
					wait(500)
					sampSendChat('/mess 10 Набей максимальное количество киллов, добейся идеала в своем +C')
					wait(500)
					sampSendChat('/mess 12 --------===================| PVP Arena |================-----------')
				end)
			end
			if imgui.Button(u8'Виртуальный мир', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Твой виртуальный мир |================-----------')
					wait(500)
					sampSendChat('/mess 15 Мешают играть? Постоянно преследуют танки и самолёты?')
					wait(500)
					sampSendChat('/mess 15 Обычный пассив режим не спасает во время дрифта?')
					wait(500)
					sampSendChat('/mess 15 Выход есть! Вводи /dt [0-999] и дрифти с комфортом.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Твой виртуальный мир |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Набор на админку', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 3 --------===================| Набор на пост администратора |================-----------')
					wait(500)
					sampSendChat('/mess 2 Мечтал встать на пост администратора? Чистить сервер от читеров и нарушителей?')
					wait(500)
					sampSendChat('/mess 2 Всё это возможно и совершенно бесплатно <3')
					wait(500)
					sampSendChat('/mess 2 На нашем форуме https://forumrds.ru/ открыт набор, успей подать заявку, кол-во мест ограничено.')
					wait(500)
					sampSendChat('/mess 3 --------===================| Набор на пост администратора |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'О /report', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 17 --------===================| Связь с администрацией |================-----------')
					wait(500)
					sampSendChat('/mess 13 Нашел читера, злостного нарушителя, ДМера, или просто мешают играть?')
					wait(500)
					sampSendChat('/mess 13 Появился вопрос о возможностях сервера или его особенностей?')
					wait(500)
					sampSendChat('/mess 13 Администрация поможет! Пиши /report и свою жалобу/вопрос')
					wait(500)
					sampSendChat('/mess 17 --------===================| Связь с администрацией |================-----------')
				end)
			end
			imgui.CenterText(u8'Мероприятия /join')
			if imgui.Button(u8'Дерби', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Мероприятие Дерби |================-----------')
					wait(500)
					sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Дерби')
					wait(500)
					sampSendChat('/mess 0 Чтобы принять участие вводи /join - 1')
					wait(500)
					sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Мероприятие Дерби |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Паркур', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Мероприятие /parkour |================-----------')
					wait(500)
					sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Паркур')
					wait(500)
					sampSendChat('/mess 0 Чтобы принять участие вводи /parkour либо /join - 2')
					wait(500)
					sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Мероприятие /parkour |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'PUBG', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Мероприятие /pubg |================-----------')
					wait(500)
					sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Pubg')
					wait(500)
					sampSendChat('/mess 0 Чтобы принять участие вводи /pubg либо /join - 3')
					wait(500)
					sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Мероприятие /pubg |================-----------')
				end)
			end
			if imgui.Button(u8'DAMAGE DEATHMATCH', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Мероприятие /damagegm |================-----------')
					wait(500)
					sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие DAMAGE DEATHMATCH')
					wait(500)
					sampSendChat('/mess 0 Чтобы принять участие вводи /damagegm либо /join - 4')
					wait(500)
					sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Мероприятие /damagegm |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'KILL DEATHMATCH', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Мероприятие KILL DEATHMATCH |================-----------')
					wait(500)
					sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие DAMAGE DEATHMATCH')
					wait(500)
					sampSendChat('/mess 0 Чтобы принять участие вводи /join - 5')
					wait(500)
					sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Мероприятие KILL DEATHMATCH |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Paint Ball', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Мероприятие Paint Ball |================-----------')
					wait(500)
					sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Paint Ball')
					wait(500)
					sampSendChat('/mess 0 Чтобы принять участие вводи /join - 7')
					wait(500)
					sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Мероприятие Paint Ball |================-----------')
				end)
			end
			if imgui.Button(u8'Зомби vs Людей', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Зомби против людей |================-----------')
					wait(500)
					sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Зомби против людей')
					wait(500)
					sampSendChat('/mess 0 Чтобы принять участие вводи /join - 8')
					wait(500)
					sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Зомби против людей |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Прятки', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Мероприятие Прятки |================-----------')
					wait(500)
					sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Прятки')
					wait(500)
					sampSendChat('/mess 0 Чтобы принять участие вводи /join - 10')
					wait(500)
					sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Мероприятие Прятки |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Догонялки', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| Мероприятие Догонялки |================-----------')
					wait(500)
					sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Догонялки')
					wait(500)
					sampSendChat('/mess 0 Чтобы принять участие вводи /join - 11')
					wait(500)
					sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
					wait(500)
					sampSendChat('/mess 8 --------===================| Мероприятие Догонялки |================-----------')
				end)
			end
		end
		if menu2[2] then
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'Добавить свой ответ', imgui.ImVec2(410, 24)) and #buffer.custom_answer.v~=0 then
				key = #cfg.customotvet + 1
				cfg.customotvet[key] = u8:decode(buffer.custom_answer.v)
				save()
				buffer.custom_answer.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.NewInputText('##SearchBar2', buffer.custom_answer, 410, u8'Введите ваш ответ.', 2)
			imgui.Separator()
			imgui.CenterText(u8'Сохраненные ответы')
			for k,v in pairs(cfg.customotvet) do
				if imgui.Button(u8(v), imgui.ImVec2(405, 24)) then
					cfg.customotvet[k] = nil
					cfg.customotvet[v] = nil
					save()
				end
			end
		end
		if menu2[6] then
			imgui.CenterText(u8'Скрипт')
			imgui.Text(u8'/pravila - посмотреть актуальные правила\n/tool - открыть меню скрипта\n/wh - вкл/выкл функцию WallHack')
			imgui.Separator()
			imgui.CenterText(u8'Вспомогательные команды')
			imgui.Text(u8'/n - Не наблюдаю нарушений от игрока\n/nak - игрок наказан\n/fo - обратитесь на форум\n/afk - игрок находится в афк или бездействует\n/pmv - Помогли вам\n/dpr - донат преимущества\n/rep - сообщить игроку о наличии команды /report\n/c - начал(а) работу над вашей жалобой\n/cl - данный игрок чист\n/uj - снять джайл\n/nv - Игрок не в сети\n/stw - выдать миниган\n/ur - снять мут репорта\n/uu - снятие мута\n/al - Напомнить администратору про /alogin\n/as - заспавнить игрока\n/spp - заспавнить всех в радиусе\n/sbanip - бан игрока офф по нику с IP (ФД!)')
			imgui.Separator()
			imgui.CenterText(u8'Выдать мут чата')
			imgui.Text(u8'/m - /m3 мат\n/ok - /ok3 оскорбление\n/fd - /fd3 флуд\n/nm - неадекватное поведение(600)\n/or - оск/упом родных\n/up - упоминание проекта с очисткой чата\n/oa - оскорбление администрации\n/kl - клевета на администрацию\n/po - /po3 - попрошайничество\n/rekl - реклама\n/zs - злоупотребление символами\n/rz - розжиг\n/ia - выдача себя за администрацию')
			imgui.Separator()
			imgui.CenterText(u8'Выдать мут репорта')
			imgui.Text(u8'/oft - /oft3 оффтоп\n/cp - /cp3 капс\n/roa - оскорбление администрации\n/ror - оск/упом род\n/rzs - злоупотребление символами\n/rrz - розжиг\n/rpo - попрошайничество\n/rm - мат\n/rok - оскорбление')
			imgui.Separator()
			imgui.CenterText(u8'Посадить в тюрьму')
			imgui.Text(u8'/dz-/dz3 - ДМ/ДБ в зеленой зоне\n/zv - Злоупотребление VIP статусом\n/sk - Спавн-Килл\n/dmp - серьезная помеха на мероприятии\n/td - Car in /trade\n/jm - нарушение правил мп\n/jcb - вредительские читы(вместо бана)\n/jc - безвредные читы\n/bg - багоюз\n/dk - ДБ Ковш в зеленой зоне')
			imgui.Separator()
			imgui.CenterText(u8'Кикнуть игрока')
			imgui.Text(u8'/cafk - Афк на арене\n/jk - ДМ в джайле\n/kk1 - Смените ник 1/3\n/kk2 - Смените ник 2/3\n/kk3 - Смените ник 3/3 (бан)')
			imgui.Separator()
			imgui.CenterText(u8'Блокировка аккаунта')
			imgui.Text(u8'/ch - читы\n/bosk - оскорбление проекта\n/obm - Обман/развод\n/obh - обход бана\n/nmb - Неадекватное поведение(3 дня)\n/oskhelper - Нарушение правил хелпера\n/reklama - реклама')
			imgui.Separator()
			imgui.Text(u8'Выдача наказания в оффлайне - /okf /mf /dzf')
		end
		if menu2[8] then
			imgui.CenterText(u8'Добавить мат (Enter или кнопкой)')
			imgui.SameLine()
			imgui.Text('(?)')
			imgui.Tooltip(u8'Автомут работает по принципу Слово(Дополнение).\nЕсли вам надо мутить исключительно за целое слово\nДобавляйте в конец строки без пробела %s')
			imgui.PushItemWidth(350)
			imgui.InputText('##newmat', buffer.newmat)
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(360)
			if (imgui.Button(fa.ICON_CHECK, imgui.ImVec2(24,24)) and (string.len(u8:decode(buffer.newmat.v))>=2)) or (isKeyJustPressed(VK_RETURN) and (string.len(u8:decode(buffer.newmat.v))>=2)) then
				buffer.newmat.v = u8:decode(buffer.newmat.v)
				buffer.newmat.v = buffer.newmat.v:lower()
				buffer.newmat.v = buffer.newmat.v:rlower()
				for k, v in pairs(cfg.mat) do
					if cfg.mat[k] == buffer.newmat.v then
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newmat.v .. ' {F0E68C}уже имеется в списке матов.', -1)
						a = true
						break
					else    
						a = false
					end
				end
				if not a then
					cfg.mat[#cfg.mat + 1] = buffer.newmat.v
					save()
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newmat.v .. ' {F0E68C}было успешно добавлено в список матов.', -1)
					a = nil
				end
				buffer.newmat.v = u8(buffer.newmat.v)
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(385)
			if imgui.Button(fa.ICON_BAN, imgui.ImVec2(24,24)) and string.len(u8:decode(buffer.newmat.v)) >= 2 then
				buffer.newmat.v = u8:decode(buffer.newmat.v)
				buffer.newmat.v = buffer.newmat.v:lower()
				buffer.newmat.v = buffer.newmat.v:rlower()
				for k, v in pairs(cfg.mat) do
					if cfg.mat[k] ==buffer.newmat.v then
						cfg.mat[k] = nil
						save()
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Выбранное вами слово{008000} ' .. buffer.newmat.v .. ' {F0E68C}было успешно удалено из списка матов', -1)
						a = true
						break
					else    
						a = false
					end
				end
				if not a then
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Такого слова в списке матов нет.', -1)
					a = nil
				end
				buffer.newmat.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.CenterText(u8'Добавить оскорбление (Enter или кнопкой)')
			imgui.PushItemWidth(350)
			imgui.InputText('##newosk', buffer.newosk)
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(360)
			if (imgui.Button(fa.ICON_CHECK .. ' ', imgui.ImVec2(24,24)) and (string.len(u8:decode(buffer.newosk.v))>=2)) or (isKeyJustPressed(VK_RETURN) and (string.len(u8:decode(buffer.newosk.v))>=2)) then
				buffer.newosk.v = u8:decode(buffer.newosk.v)
				buffer.newosk.v = buffer.newosk.v:lower()
				buffer.newosk.v = buffer.newosk.v:rlower()
				for k, v in pairs(cfg.osk) do
					if cfg.osk[k] == buffer.newosk.v then
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newosk.v .. ' {F0E68C}уже имеется в списке оскорблений.' , -1)
						a = true
						break
					else    
						a = false
					end
				end
				if not a then
					cfg.osk[#cfg.osk + 1] = buffer.newosk.v
					save()
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newosk.v .. ' {F0E68C}было успешно добавлено в список оскорблений', -1)
					a = nil
				end
				buffer.newosk.v = u8(buffer.newosk.v)
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(385)
			if imgui.Button(fa.ICON_BAN .. ' ', imgui.ImVec2(24,24)) and string.len(u8:decode(buffer.newosk.v)) >= 2 then
				buffer.newosk.v = u8:decode(buffer.newosk.v)
				buffer.newosk.v = buffer.newosk.v:lower()
				buffer.newosk.v = buffer.newosk.v:rlower()
				for k, v in pairs(cfg.osk) do
					if cfg.osk[k] == buffer.newosk.v then
						cfg.osk[k] = nil
						save()
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Выбранное вами слово{008000} ' .. buffer.newosk.v .. ' {F0E68C}было успешно удалено из списка', -1)
						a = true
						break
					else    
						a = false
					end
				end
				if not a then
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Такого слова в списке оскорблений нет.', -1)
					a = nil
				end
				buffer.newosk.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.CenterText(u8'Выберите тему оформления')
			imgui.PushItemWidth(400)
			if imgui.Combo("##selected", style_selected, style_list, style_selected) then
				style(style_selected.v) -- Применяем сразу же выбранный стиль
				cfg.settings.style = style_selected.v 
				inicfg.save(cfg, directIni) 
			end
			imgui.PopItemWidth()
			imgui.CenterText(u8'Добавить быструю команду')
			imgui.SameLine()
			imgui.Text('(?)')
			imgui.Tooltip(u8'Символ "_" без кавычек принимает введенный аргумент\nКоманда wait добавляет задержку, пример: wait(5) (это 5 сек)')
			imgui.NewInputText('##titlecommand5', buffer.new_command_title, 400, u8'Команда (пример: /ok, /dz, /ch)', 2)
			imgui.InputTextMultiline("##newcommand", buffer.new_command, imgui.ImVec2(400, 100))
			if imgui.Button(u8'Сохрaнить') then
				buffer.new_command_title.v = string.gsub(u8:decode(buffer.new_command_title.v), '/', '')
				cfg.my_command[buffer.new_command_title.v] = u8:decode(buffer.new_command.v)
				save()
				for k,v in pairs(cfg.my_command) do
					if k == buffer.new_command_title.v then
						sampRegisterChatCommand(k, function(param)
							lua_thread.create(function()
								for a,b in pairs(textSplit(string.gsub(v, '_', param), '\n')) do
									if b:match('wait(%(%d+)%)') then
										wait(tonumber(b:match('%d+') .. '000'))
									else
										sampSendChat(b)
									end
								end
								param = nil
							end)
						end)
						sampAddChatMessage(tag .. 'Новая команда /' .. buffer.new_command_title.v .. ' успешно создана.',-1)
						buffer.new_command.v, buffer.new_command_title.v = '',''
					end
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'Вывести мои команды в чат') then
				for k,v in pairs(cfg.my_command) do
					sampAddChatMessage(tag .. 'Команда - /' .. k, -1)
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'Удалить') then
				if #(buffer.new_command_title.v) == 0 then
					sampAddChatMessage(tag ..'Вы не указали название команды, что вы собрались удалять?', -1)
				else
					buffer.new_command_title.v = string.gsub(u8:decode(buffer.new_command_title.v), '/', '')
					if cfg.my_command[buffer.new_command_title.v] then
						cfg.my_command[buffer.new_command_title.v] = nil
						sampAddChatMessage(tag .. 'Команда была успешно удалена. Перестанет действовать после перезагрузки игры.', -1)
					else
						sampAddChatMessage(tag .. 'Такой команды в базе данных нет.', -1)
					end
				end
			end
		end
		imgui.PopFont()
 		imgui.End()
	end
	if windows.fast_report.v then -- быстрый ответ на репорт
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5) - 250, (sh * 0.5)-90), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Ответ на репорт', windows.fast_report, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8'Игрок: ' .. autor .. '[' ..autorid.. ']')
		imgui.TextWrapped(u8('Жалоба: ' .. textreport))
		if isKeyJustPressed(VK_SPACE) then
			imgui.SetKeyboardFocusHere(-1)
		end
		imgui.NewInputText('##SearchBar', buffer.text_ans, 375, u8'Введите ваш ответ.', 2)
		imgui.SameLine()
		imgui.SetCursorPosX(392)
		imgui.Tooltip('Space')
		if imgui.Button(u8'Отправить ' .. fa.ICON_SHARE, imgui.ImVec2(120, 25)) then
			if #(u8:decode(buffer.text_ans.v)) > 0 then
				if cfg.settings.custom_answer_save then
					cfg.customotvet[#cfg.customotvet + 1] = u8:decode(buffer.text_ans.v)
					save()
				end
				answer.moiotvet = true
			else
				sampAddChatMessage(tag .. 'Ответ не менее 1 символа.', -1)
			end
		end
		imgui.Tooltip('Enter')
		imgui.Separator()
		if imgui.Button(u8'Работаю', imgui.ImVec2(120, 25)) or isKeyDown(VK_Q) then
			answer.rabotay = true
		end
		imgui.Tooltip('Q')
		imgui.SameLine()
		if imgui.Button(u8'Слежу', imgui.ImVec2(120, 25)) or isKeyDown(VK_E) then
			answer.slejy = true
		end
		imgui.Tooltip('E')
		imgui.SameLine()
		if imgui.Button(u8'Список своих', imgui.ImVec2(120, 25)) or isKeyDown(VK_R) then
			windows.custom_ans.v = not windows.custom_ans.v
		end
		imgui.Tooltip('R')
		imgui.SameLine()
		if imgui.Button(u8'Передать', imgui.ImVec2(120, 25)) or isKeyDown(VK_V) then
			answer.peredamrep = true
		end
		imgui.Tooltip('V')
		if imgui.Button(u8'Наказать', imgui.ImVec2(120, 25)) or isKeyDown(VK_G) then
			if tonumber(autorid) then
				windows.fast_rmute.v = not windows.fast_rmute.v
			else
				sampAddChatMessage(tag .. 'Данный игрок не в сети. Используйте /rmuteoff', -1)
			end
		end
		imgui.Tooltip('G')
		imgui.SameLine()
		if imgui.Button(u8'Уточните ID', imgui.ImVec2(120, 25)) or isKeyDown(VK_T) then
			answer.uto4id = true
		end
		imgui.Tooltip('T')
		imgui.SameLine()
		if imgui.Button(u8'Форум', imgui.ImVec2(120, 25)) or isKeyDown(VK_F) then
			answer.uto4 = true
		end
		imgui.Tooltip('F')
		imgui.SameLine()
		if imgui.Button(u8'Отклонить', imgui.ImVec2(120, 25)) then
			answer.otklon = true
		end
		imgui.Separator()
		if imadd.ToggleButton('##doptextans' .. fa.ICON_COMMENTING_O, checkbox.check_add_answer_report) then
			cfg.settings.add_answer_report = not cfg.settings.add_answer_report
			save()
		end
		imgui.SameLine()
		imgui.Text(u8'Добавить дополнительный текст к ответу')
		if imadd.ToggleButton('##saveans' .. fa.ICON_DATABASE, checkbox.check_save_answer) then
			cfg.settings.custom_answer_save = not cfg.settings.custom_answer_save
			save()
		end
		imgui.SameLine()
		imgui.Text(u8'Сохранить данный ответ в базу данных скрипта')
		imgui.PopFont()
		imgui.End()
	end
	if windows.recon_ban_menu.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Выдать блокировку аккаунта", windows.recon_ban_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Выберите причину')
		if imgui.Button(u8'Читы', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/ch ' .. playerrecon)
			windows.recon_menu.v = false
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'Многочисленные нарушения (3)', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/iban ' .. playerrecon .. ' 3 Неадекватное поведение')
			windows.recon_menu.v = false
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'Нарушение правил хелпера', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/oskhelper ' .. playerrecon)
			windows.recon_menu.v = false
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'Оскорбление проекта', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/bosk ' .. playerrecon)
			windows.recon_menu.v = false
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'Реклама', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/reklama ' .. playerrecon)
			windows.recon_menu.v = false
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'Обман', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/obm ' .. playerrecon)
			windows.recon_menu.v = false
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'Название банды', imgui.ImVec2(250, 25)) then
			sampSendChat('/ban ' .. playerrecon .. ' 7 Название банды')
			windows.recon_menu.v = false
			windows.recon_ban_menu.v = false
		end
		imgui.End()
	end
	if windows.recon_jail_menu.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Посадить игрока в тюрьму", windows.recon_jail_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Выберите причину')
		if imgui.Button(u8'DM/DB in ZZ', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/dz ' .. playerrecon)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8"Злоупотребление VIP'ом", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/zv ' .. playerrecon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'Spawn Kill', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/sk ' .. playerrecon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'Car in trade/ZZ', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/td ' .. playerrecon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'Чит', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/jcb ' .. playerrecon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'Чит безвредный', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/jc ' .. playerrecon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'ДБ ковш в зеленой зоне', imgui.ImVec2(250, 25)) then
			sampSendChat('/jail ' .. playerrecon .. ' ДБ ковш в зеленой зоне')
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		imgui.End()
	end
	if windows.recon_mute_menu.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Заблокировать чат игроку", windows.recon_mute_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Выберите причину')
		if imgui.Button(u8'Оскорбление/Унижение', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/ok ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8"Мат", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/m ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8"Флуд", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/fd ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'Попрошайничество', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/po ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'Оскорбление/Упоминание родных', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/or ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'Оскорбление администрации', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/oa ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'Клевета на администрацию', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/kl ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'Злоупотребление символами', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/zs ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'Выдача себя за администратора', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/ia ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'Упоминание сторонних проектов', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/up ' .. playerrecon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		imgui.End()
	end
	if windows.recon_kick_menu.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Кикнуть игрока с сервера", windows.recon_kick_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Выберите причину')
		if imgui.Button(u8'AFK /arena', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/cafk ' .. playerrecon)
			windows.recon_menu.v = false
		end
		if imgui.Button(u8"Nick 1/3", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/kk1 ' .. playerrecon)
			windows.recon_menu.v = false
		end
		if imgui.Button(u8"Nick 2/3", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/kk2 ' .. playerrecon)
			windows.recon_menu.v = false
		end
		if imgui.Button(u8'Nick 3/3', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/kk3 ' .. playerrecon)
			windows.recon_menu.v = false
		end
		imgui.End()
	end
	if windows.recon_menu.v and not sampIsPlayerConnected(playerrecon) then
		windows.recon_menu.v = false
	end
	if windows.recon_menu.v then -- кастом рекон меню
		if windows.render_admins.v then
			windows.render_admins.v = false
		end
		imgui.SetNextWindowPos(imgui.ImVec2(tonumber(cfg.settings.position_recon_menu_x), tonumber(cfg.settings.position_recon_menu_y)))
		if sw <= 1400 then
			imgui.SetNextWindowSize(imgui.ImVec2(265, 283), imgui.Cond.FirstUseEver)
			imgui.Begin(u8"Рекон", windows.recon_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		else
			imgui.Begin(u8"Рекон", windows.recon_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		end
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.ShowCursor = false
		imgui.PushFont(fontsize)
		if imgui.Button(u8'Игрок ' ..fa.ICON_MALE, imgui.ImVec2(120, 25)) then uu() menu[1] = true end imgui.SameLine()
        if imgui.Button(u8'В радиусе ' .. fa.ICON_USERS, imgui.ImVec2(120, 25)) then uu() menu[2] = true end 
        imgui.Separator()
        imgui.NewLine()
        imgui.SameLine(3)
        if menu[1] then
			imgui.SetCursorPosX(10)
			if imgui.Button(fa.ICON_FILES_O) then
				setClipboardText(sampGetPlayerNickname(playerrecon))
				sampAddChatMessage(tag .. 'Ник скопирован в буффер обмена.', -1)
			end
			if windows.answer_player_report.v then
				windows.answer_player_report.v = false
				saveplayerrecon = nil
			end
			imgui.SameLine()
			imgui.Text((sampGetPlayerNickname(playerrecon)) .. '[' .. playerrecon .. ']')
			imgui.SameLine()
			imgui.SetCursorPosX(235)
			if imgui.Button(fa.ICON_ARROW_RIGHT) then
				lua_thread.create(function()
					if not sampIsDialogActive() and playerrecon <= sampGetMaxPlayerId() - 1 then
						sampSendChat('/re ' .. playerrecon + 1)
						playerrecon = playerrecon + 1
						wait(100)
						while not sampIsPlayerConnected(playerrecon) and playerrecon <= sampGetMaxPlayerId() do
							wait(100)
							playerrecon = playerrecon + 1
							sampSendChat('/re ' .. playerrecon)
						end
					end
				end)
			end
			imgui.Separator()
			for i = 4, #inforeport do
				if i == 4 then
					imgui.Text(u8'Здоровье авто: ' .. inforeport[i])
				end
				if i == 5 then
					imgui.Text(u8'Скорость: ' .. inforeport[i])
				end
				if i == 7 then -- gun
					imgui.Text(u8'Оружие: ' .. inforeport[i])
				end
				if i == 8 then
					imgui.Text(u8'Точность: ' .. inforeport[i])
				end
				if i == 6 then -- ping
					imgui.Text('Ping: ' .. inforeport[i])
				end
				if i == 10 then -- afk
					imgui.Text('AFK: ' .. inforeport[i])
				end
				if i == 12 then -- vip
					imgui.Text(u8'VIP: ' .. inforeport[i])
				end
				if i == 15 then -- collision
					imgui.Text(u8'Коллизия: ' .. inforeport[i])
				end
				if i == 14 then -- turbo
					imgui.Text(u8'Турбо пакет: ' .. inforeport[i])
				end
				if i == 13 then -- passive mode
					imgui.Text('Passive mode: ' .. inforeport[i])
				end
			end
			if imgui.Button(u8'Посмотреть статистику', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					sampSendChat('/statpl ' .. playerrecon)
				else
					sampAddChatMessage(tag .. 'У вас открыт диалог, закройте его.', -1)
				end
			end
			if imgui.Button(u8'Посмотреть /offstats статистику', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					lua_thread.create(function()
						sampSendChat('/offstats ' .. sampGetPlayerNickname(playerrecon))
						while not sampIsDialogActive() do
							wait(0)
						end
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end)
				else
					sampAddChatMessage(tag .. 'У вас открыт диалог, закройте его.', -1)
				end
			end
			if imgui.Button(u8'Посмотреть вторую статистику', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					sampSendClickTextdraw(textdraw.stats)
				else
					sampAddChatMessage(tag .. 'У вас открыт диалог, закройте его.', -1)
				end
			end
			if imgui.Button(u8'Заблокировать игрока', imgui.ImVec2(250, 25)) then
				windows.recon_ban_menu.v = not windows.recon_ban_menu.v
			end
			if imgui.Button(u8'Посадить в джайл', imgui.ImVec2(250, 25)) then
				windows.recon_jail_menu.v = not windows.recon_jail_menu.v
			end
			if imgui.Button(u8'Выдать мут', imgui.ImVec2(250, 25)) then
				windows.recon_mute_menu.v = not windows.recon_mute_menu.v
			end
			if imgui.Button(u8'Кикнуть игрока', imgui.ImVec2(250, 25)) then
				windows.recon_kick_menu.v = not windows.recon_kick_menu.v
			end
			if imgui.Button(u8'Дополнительные действия', imgui.ImVec2(250, 25)) then
				windows.actions_in_recon_menu.v = not windows.actions_in_recon_menu.v
			end
			if ansid ~= playerrecon then
				ansid = nil
				saveplayerrecon = nil
			end
			if isKeyJustPressed(VK_R) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(textdraw.refresh)
				if cfg.settings.keysync then
					lua_thread.create(function()
						wait(1000)
						while sampIsDialogActive() or sampIsChatInputActive() do
							wait(0)
						end
						sampSendInputChat('/keysync ' .. playerrecon)
					end)
				end
			end
			if isKeyJustPressed(VK_Q) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(textdraw.close)
			end
			if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
				lua_thread.create(function()
					setVirtualKeyDown(70, true)
					wait(150)
					setVirtualKeyDown(70, false)
				end)
			end
        end
        if menu[2] then
			local playerzone = playersToStreamZone()
			for _,v in pairs(playerzone) do
				if v ~= playerrecon then
					imgui.SetCursorPosX(10)
					if imgui.Button(sampGetPlayerNickname(v) .. '[' .. v .. ']', imgui.ImVec2(250, 25)) then
						sampSendChat('/re ' .. v)
					end
				end
			end
        end
		imgui.PopFont()
		imgui.End()
	end
	if windows.new_position_recon_menu.v then -- Сохранения расположения кастом рекон меню
		imgui.SetNextWindowSize(imgui.ImVec2(265, 283), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Настройки рекона", windows.new_position_recon_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'Сохранить позицию ' .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.position_recon_menu_x = pos.x
			cfg.settings.position_recon_menu_y = pos.y
			save()
			windows.new_position_recon_menu.v = false
			windows.recon_menu.v = true
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.new_position_render_admins.v then -- Сохранение расположения рендера админс
		imgui.SetNextWindowSize(imgui.ImVec2(250, 80), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Настройки rendera", windows.new_position_render_admins, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8"Сохранить расположение " .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.render_admins_positionX = pos.x
			cfg.settings.render_admins_positionY = pos.y
			save()
			showCursor(false,false)
			thisScript():reload()
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.new_position_keylogger.v then -- Сохранение расположения keylogger
		imgui.SetNextWindowSize(imgui.ImVec2(400, 100), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Настройки keylog", windows.new_position_keylogger, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8"Сохранить расположение " .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.keysyncx = pos.x + 200
			cfg.settings.keysyncy = pos.y
			save()
			windows.new_position_keylogger.v = false
			windows.menu_tools.v = false
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.new_position_adminchat.v then -- сохранение позиции админ чата
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Админ-чат', windows.new_position_adminchat, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.CenterText(u8'| Админ чат |')
		if imgui.Button(u8'Сохранить позицию ' .. fa.ICON_ARROWS) then
			local pos = imgui.GetWindowPos()
			cfg.settings.position_adminchat_x = pos.x
			cfg.settings.position_adminchat_y = pos.y
			save()
		end
		imgui.Text(u8'Размер: ')
		imgui.SameLine()
		imgui.PushItemWidth(20)
		if imgui.Combo('##color', selected_item, {'1', '2', '3', '4', '5', '6', '7', '8', '9'}, 9) then
			if selected_item.v == 0 then
			  	cfg.settings.size_adminchat = 9
			elseif selected_item.v == 1 then
				cfg.settings.size_adminchat = 10
			elseif selected_item.v == 2 then
				cfg.settings.size_adminchat = 11
			elseif selected_item.v == 3 then
				cfg.settings.size_adminchat = 12
			elseif selected_item.v == 4 then
				cfg.settings.size_adminchat = 13
			elseif selected_item.v == 5 then
				cfg.settings.size_adminchat = 14
			elseif selected_item.v == 6 then
				cfg.settings.size_adminchat = 15
			elseif selected_item.v == 7 then
				cfg.settings.size_adminchat = 16
			elseif selected_item.v == 8 then
				cfg.settings.size_adminchat = 17
			end
			save()
			font_adminchat = renderCreateFont("Calibri", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW)
		end
		imgui.PopItemWidth()
		imgui.Text(u8'Кол-во строк: ')
		imgui.SameLine()
		imgui.PushItemWidth(20)
		if imgui.Combo('##stroki', selected_item, {'3', '6', '9', '12'}, 4) then -- счет на -1 число, т.к счет идет с 0
			if selected_item.v == 0 then
				cfg.settings.strok_admin_chat = 2
			elseif selected_item.v == 1 then
				cfg.settings.strok_admin_chat = 5
			elseif selected_item.v == 2 then
				cfg.settings.strok_admin_chat = 8
			elseif selected_item.v == 3 then
				cfg.settings.strok_admin_chat = 11
			end
			if #adminchat > cfg.settings.strok_admin_chat then
				adminchat = {}
				sampAddChatMessage(tag .. 'Текст чата был сброшен.', -1)
			end
			save()
		end
		imgui.PopItemWidth()
		imgui.CenterText(u8'| Чат /ears |')
		if imgui.Button(u8'Сoхранить позицию ' .. fa.ICON_ARROWS) then
			local pos = imgui.GetWindowPos()
			cfg.settings.position_ears_x = pos.x
			cfg.settings.position_ears_y = pos.y
			save()
		end
		imgui.Text(u8'Размер: ')
		imgui.SameLine()
		imgui.PushItemWidth(20)
		if imgui.Combo('##color2', selected_item, {'1', '2', '3', '4', '5', '6', '7', '8', '9'}, 9) then
			if selected_item.v == 0 then
			  	cfg.settings.size_ears = 9
			elseif selected_item.v == 1 then
				cfg.settings.size_ears = 10
			elseif selected_item.v == 2 then
				cfg.settings.size_ears = 11
			elseif selected_item.v == 3 then
				cfg.settings.size_ears = 12
			elseif selected_item.v == 4 then
				cfg.settings.size_ears = 13
			elseif selected_item.v == 5 then
				cfg.settings.size_ears = 14
			elseif selected_item.v == 6 then
				cfg.settings.size_ears = 15
			elseif selected_item.v == 7 then
				cfg.settings.size_ears = 16
			elseif selected_item.v == 8 then
				cfg.settings.size_ears = 17
			end
			save()
			font_earschat = renderCreateFont("Calibri", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)
		end
		imgui.PopItemWidth()
		imgui.Text(u8'Кол-во строк: ')
		imgui.SameLine()
		imgui.PushItemWidth(20)
		if imgui.Combo('##stroki2', selected_item, {'3', '6', '9', '12', '15','20'}, 6) then -- счет на -1 число, т.к счет идет с 0
			if selected_item.v == 0 then
				cfg.settings.strok_ears = 2
			elseif selected_item.v == 1 then
				cfg.settings.strok_ears = 5
			elseif selected_item.v == 2 then
				cfg.settings.strok_ears = 8
			elseif selected_item.v == 3 then
				cfg.settings.strok_ears = 11
			elseif selected_item.v == 4 then
				cfg.settings.strok_ears = 14
			elseif selected_item.v == 5 then
				cfg.settings.strok_ears = 19
			end
			if #ears > cfg.settings.strok_ears then
				ears = {}
				sampAddChatMessage(tag .. 'Текст чата был сброшен.', -1)
			end
			save()
		end
		imgui.PopItemWidth()
		imgui.PopFont()
		imgui.End()
	end
	if windows.actions_in_recon_menu.v then -- доп действия в кастом рекон меню
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Взаимодействие с игроком", windows.actions_in_recon_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Выберите действие')
		if imgui.Button(u8"Слапнуть", imgui.ImVec2(250, 25)) then
			sampSendChat('/slap ' .. playerrecon)
		end
		if imgui.Button(u8"Заспавнить", imgui.ImVec2(250, 25)) then
			sampSendChat('/aspawn ' .. playerrecon)
		end
		if imgui.Button(u8"Заморозить", imgui.ImVec2(250, 25)) then
			sampSendChat('/freeze ' .. playerrecon)
		end
		if imgui.Button(u8"Убить", imgui.ImVec2(250, 25)) then
			sampSendChat('/sethp ' .. playerrecon .. ' 0')
		end
		if imgui.Button(u8"Телепортировать к себе", imgui.ImVec2(250, 25)) then
			if not sampIsDialogActive() then
				lua_thread.create(function()
					sampSendChat('/reoff')
					windows.actions_in_recon_menu.v = false
					wait(3000)
					sampSendChat('/gethere ' .. playerrecon)
				end)
			else
				sampAddChatMessage(tag .. 'Закройте диалог.')
			end
		end
		if imgui.Button(u8"Телепортировать к нему", imgui.ImVec2(250, 25)) then
			if not sampIsDialogActive() then
				lua_thread.create(function()
					sampSendChat('/reoff')
					windows.actions_in_recon_menu.v = false
					wait(3000)
					sampSendChat('/agt ' .. playerrecon)
				end)
			else
				sampAddChatMessage(tag .. 'Закройте диалог.')
			end
		end
		imgui.End()
	end
	if windows.fast_rmute.v then -- Наказать в окне быстрого репорта
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Выдать блокировку репорта", windows.fast_rmute, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.Button(u8'Оффтоп (1)', imgui.ImVec2(250, 25)) or isKeyDown(VK_1) then
			nakazatreport.oftop = true
			answer.nakajy = true
		end
		if imgui.Button(u8'Капс (2)', imgui.ImVec2(250, 25)) or isKeyDown(VK_2) then
			nakazatreport.capsrep = true
			answer.nakajy = true
		end
		if imgui.Button(u8'Оскорбление администрации (3)', imgui.ImVec2(250, 25)) or isKeyDown(VK_3) then
			nakazatreport.oskadm = true
			answer.nakajy = true
		end
		if imgui.Button(u8'Клевета на администрацию (4)', imgui.ImVec2(250, 25)) or isKeyDown(VK_4) then
			nakazatreport.kl = true
			answer.nakajy = true
		end
		if imgui.Button(u8'Оскорбление/Упоминание родных (5)', imgui.ImVec2(250, 25)) or isKeyDown(VK_5) then
			nakazatreport.oskrod = true
			answer.nakajy = true
		end
		if imgui.Button(u8'Попрошайничество (6)', imgui.ImVec2(250, 25)) or isKeyDown(VK_6) then
			nakazatreport.poprep = true
			answer.nakajy = true
		end
		if imgui.Button(u8'Оскорбление/Унижение (7)', imgui.ImVec2(250, 25)) or isKeyDown(VK_7) then
			nakazatreport.oskrep = true
			answer.nakajy = true
		end
		if imgui.Button(u8'Нецензурная лексика (8)', imgui.ImVec2(250, 25)) or isKeyDown(VK_8) then
			nakazatreport.matrep = true
			answer.nakajy = true
		end
		imgui.End()
	end
	if windows.custom_ans.v then -- свой ответ в репорт
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Мой ответ', windows.custom_ans, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.IsWindowAppearing() then
			imgui.SetKeyboardFocusHere(-1)
		end
		imgui.NewInputText('##SearchBar3', buffer.find_custom_answer, 480, u8'Поиск по ответам', 2)
		imgui.Separator()
		for k,v in pairs(cfg.customotvet) do
			if string.rlower(v):find(string.rlower(u8:decode(buffer.find_custom_answer.v))) then	
				if imgui.Button(u8(v), imgui.ImVec2(480, 24)) then
					answer.customans = v
					buffer.find_custom_answer.v = ''
					windows.custom_ans.v = false
				end
			end
		end
		imgui.End()
	end
	if windows.answer_player_report.v then -- помощь после слежки в реконе
		if windows.render_admins.v then
			windows.render_admins.v = false
		end
		imgui.SetNextWindowPos(imgui.ImVec2(sw-250, 0), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Помощь после выхода из рекона", windows.answer_player_report.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Вы закончили слежку по репорту')
		imgui.CenterText(u8'Доложить информацию?')
		if imgui.Button(u8'Нарушений не наблюдаю (1)', imgui.ImVec2(250, 25)) or isKeyDown(VK_1) then
			sampSendInputChat('/n ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Данный игрок чист (2)', imgui.ImVec2(250,25)) or isKeyDown(VK_2) then
			sampSendInputChat('/cl ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Игрок наказан. (3)', imgui.ImVec2(250,25)) or isKeyDown(VK_3) then
			sampSendInputChat('/nak ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Помогли вам. (4)', imgui.ImVec2(250,25)) or isKeyJustPressed(VK_4) then
			sampSendInputChat('/pmv ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Игрок AFK (5)', imgui.ImVec2(250,25)) or isKeyJustPressed(VK_5) then
			sampSendInputChat('/afk ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Игрок не в сети (6)', imgui.ImVec2(250,25)) or isKeyJustPressed(VK_6) then
			sampSendInputChat('/nv ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Это донат-преимущества (7)', imgui.ImVec2(250,25)) or isKeyJustPressed(VK_7) then
			sampSendInputChat('/dpr ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.answer_player_report.v = false
		end
		if (isKeyJustPressed(VK_RBUTTON) or isKeyJustPressed(VK_F)) and not sampIsChatInputActive() then
			if isCursorActive() then
				showCursor(false,false)
			else
				showCursor(true,false)
			end
		end
		imgui.CenterText(u8'Активация курсора')
		imgui.CenterText(u8'ПКМ или F')
		imgui.CenterText(u8'Меню активно 5 секунд.')
		imgui.End()
	end
	if windows.help_young_admin.v then -- автоматическая отправка форм
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5)-150, (sh * 0.5)-125), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Автоформы', windows.help_young_admin, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
        imgui.Text(u8'Каких доступов у вас нет?')
        if imadd.ToggleButton('##ban', checkbox.check_form_ban) then
            cfg.settings.forma_na_ban  = not cfg.settings.forma_na_ban
            save()
        end
		imgui.SameLine()
		imgui.Text('ban')
        if imadd.ToggleButton('##jail', checkbox.check_form_jail) then
            cfg.settings.forma_na_jail  = not cfg.settings.forma_na_jail
            save()
        end
		imgui.SameLine()
		imgui.Text('jail')
        if imadd.ToggleButton('##mute', checkbox.check_form_mute) then
            cfg.settings.forma_na_mute  = not cfg.settings.forma_na_mute
            save()
        end
		imgui.SameLine()
		imgui.Text('mute')
        if imadd.ToggleButton('##kick', checkbox.check_form_kick) then
            cfg.settings.forma_na_kick  = not cfg.settings.forma_na_kick
            save()
        end
		imgui.SameLine()
		imgui.Text('kick')
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if imadd.ToggleButton('##addnick', checkbox.check_add_mynick_form) then
            cfg.settings.add_mynick_in_form = not cfg.settings.add_mynick_in_form
            save()
        end
		imgui.SameLine()
		imgui.Text(u8'Добавлять // ' .. sampGetPlayerNickname(myid))
		if cfg.settings.forma_na_ban or cfg.settings.forma_na_mute or cfg.settings.forma_na_jail or cfg.settings.forma_na_mute then
			func6:run()
		else
			func6:terminate()
		end
		imgui.PopFont()
        imgui.End()
	end
	if windows.render_admins.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.render_admins_positionX, cfg.settings.render_admins_positionY), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Администраторы", windows.render_admins, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoInputs + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		for i = 1, #admins - 1 do
			imgui.TextColoredRGB(admins[i])
		end
        imgui.End()
	end
	if windows.new_flood_mess.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(265,340), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Новый флуд', windows.new_flood_mess, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Button(u8'Скрипт сам допишет /mess\nВам лишь надо указать цвет.', imgui.ImVec2(250,32)) then
			sampSendChat('/mcolors')
		end
		imgui.Text(u8'Название: ')
		imgui.PushItemWidth(250)
		imgui.InputText('##title_flood_mess', buffer.title_flood_mess)
		imgui.PopItemWidth()
		imgui.Text(u8'Текст: ')
		imgui.InputTextMultiline("##5", buffer.new_flood_mess, imgui.ImVec2(250, 100))
		if imgui.Button(u8'Сохранить', imgui.ImVec2(250, 24)) then
			if #(u8:decode(buffer.new_flood_mess.v)) > 3 and #(u8:decode(buffer.title_flood_mess.v)) ~= 0 then
				if buffer.new_flood_mess.v ~= 0 then
					cfg.myflood[u8:decode(buffer.title_flood_mess.v)] = u8:decode(buffer.new_flood_mess.v)
					inicfg.save(cfg, directIni)
					buffer.title_flood_mess.v = ''
					buffer.new_flood_mess.v = ''
				else
					sampAddChatMessage(tag .. 'Вы не указали номер цвета', -1)
				end
			else
				sampAddChatMessage(tag .. 'Что вы собрались сохранять?', -1)
			end
		end
		for k,v in pairs(cfg.myflood) do
			if imgui.Button(u8(k), imgui.ImVec2(225, 24)) then
				lua_thread.create(function()
					v = textSplit(v, '\n')
					for _,v in pairs(v) do
						sampSendChat('/mess ' .. v)
						wait(500)
					end
				end)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(235)
			imgui.PushFont(fontsize)
			if imgui.Button(fa.ICON_BAN ..'    ' .. k, imgui.ImVec2(24,24)) then
				cfg.myflood[k] = nil
				inicfg.save(cfg, directIni)
			end
			imgui.PopFont()
		end
		imgui.End()
	end
	if windows.pravila.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw*0.5,sh*0.6), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Актуальные правила', windows.pravila, imgui.WindowFlags.NoResize +imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.NewInputText('##SearchBar6', buffer.find_rules, sw*0.5, u8'Поиск по списку', 2)
		for i = 1, #pravila do
			if string.rlower(pravila[i]):find(string.rlower(u8:decode('%s'..buffer.find_rules.v))) then
				imgui.TextWrapped(u8(pravila[i]))
			end
		end
		imgui.End()
	end
end
function render_adminchat()
	while true do
		wait(5)
		if not isPauseMenuActive() then
			for i = 0, #adminchat do
				if adminchat[i] then
					renderFontDrawText(font_adminchat, adminchat[i], cfg.settings.position_adminchat_x, cfg.settings.position_adminchat_y + (i*15), 0xCCFFFFFF)
				end
			end
			for i = 0, #ears do
				if ears[i] then
					renderFontDrawText(font_earschat, ears[i], cfg.settings.position_ears_x, cfg.settings.position_ears_y + (i*15), 0xCCFFFFFF)
				end
			end
		end
	end
end
function sampev.onServerMessage(color,text) -- Поиск сообщений из чата
	if cfg.settings.find_warning_weapon_hack then
		if not AFK then
			if text:match('Weapon hack .code. 015.') then
				if sampIsDialogActive() or sampIsChatInputActive() then
					lua_thread.create(function()
						while not (sampIsDialogActive() and sampIsChatInputActive()) do
							wait(0)
						end
					end)
				end
				local idwh = string.match(text, "%[(%d+)%]")
				sampSendChat("/iwep " .. idwh)
				sampAddChatMessage(tag .. 'Обнаружен варнинг на чит-оружие! Пробиваю: {DCDCDC}' .. sampGetPlayerNickname(idwh) .. " [" .. idwh .. "]", -1)
				local idwh = nil
			end 
		end
	end
	if cfg.settings.render_admins then
		if text:match('Время администратирования за сегодня:') or text:match('Ваша репутация:') or text:match('Всего администрации в сети:') then
			return false
		end
	end
	if cfg.settings.forma_na_ban or cfg.settings.forma_na_mute or cfg.settings.forma_na_jail or cfg.settings.forma_na_kick then
        if text:match('{FFFFFF}У Вас нет доступа к этой команде, для покупки {FFFFFF}перейдите в панель администратора.') then
            return false
        end
	end
	if cfg.settings.find_form then
		if not AFK then
			if text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)") then
				local poiskform = string.sub(text, 7)
				for i = 0, #spisok do
					if poiskform:find(tostring(spisok[i])) then
						st = {}
						st.idadmin = tonumber(poiskform:match('%[(%d+)%]'))
						local d = string.len(poiskform)
						while d ~= 0 do
							poiskform = string.sub(poiskform, 2)
							local don = string.sub(poiskform, 1, 1)
							local d = d - 1
							if don == '/' then
								st.forma = poiskform
								if poiskform:find('unban') then
									st.bool = true
									st.timer = os.clock()
									st.sett = true
									st.styleform = true
									wait_accept_form()
									break
								end
								if poiskform:find('off') or poiskform:find('akk') then
									st.bool = true
									st.timer = os.clock()
									if (poiskform.sub(poiskform, 2)):find('//') then
										st.styleform = true
									end
									st.sett = true
									wait_accept_form()
									break
								end
								if spisok[i] == 'ban' then
									st.forumplease = true
								end
								st.probid = string.match(st.forma, '%d[%d.,]*')
								if st.probid and sampIsPlayerConnected(st.probid) then
									st.bool = true
									st.timer = os.clock()
									nickid = sampGetPlayerNickname(st.probid)
									if (poiskform.sub(poiskform, 2)):find('//') then
										st.styleform = true
									end
									st.sett = true
									wait_accept_form()
									break
								else
									st = {}
									sampAddChatMessage(tag .. 'ID не обнаружен, либо находится вне сети.', -1)
									break
								end
							end
						end
					end
				end
			end
		end
	end
	if cfg.settings.render_ears then
		if text:match('NEARBY CHAT: ') or text:match('SMS: ') then
			text = string.gsub(text, 'отправил', '')
			text = string.gsub(text, ' игроку ', '->')
			text = string.sub(text, 5) -- удаляем [A]
			text = string.gsub(text, '  ', ' ')
			if #ears == cfg.settings.strok_ears then
				for i = 0, #ears do
					if i ~= #ears then
						ears[i] = ears[i + 1]
					else
						ears[#ears] = text
					end
				end
			else
				ears[#ears + 1] = text
			end
			return false
		end
	end
	if cfg.settings.admin_chat and text:match("%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)") then
		local admlvl, prefix, nickadm, idadm, admtext  = text:match('%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)')
		local messange = string.sub(prefix, 2) .. ' ' .. admlvl .. ' ' ..  nickadm .. '(' .. idadm .. '): '.. admtext
		if #messange >= 160 then
			messange = string.sub(messange, 1, 160) .. '...'
		end
		if #adminchat == cfg.settings.strok_admin_chat then
			for i = 0, #adminchat do
				if i ~= #adminchat then
					adminchat[i] = adminchat[i+1]
				else
					adminchat[#adminchat] = messange
				end
			end
		else
			adminchat[#adminchat + 1] = messange
		end
		local admlvl, prefix, nickadm, idadm, admtext = nil
		return false --
	end
	if cfg.settings.automute and not AFK then 
		text = text:lower()
        text = text:rlower() .. ' '
		if cfg.settings.smart_automute then
			if text:match('жалоба') then
				oskid = tonumber(text:match('%[(%d+)%]'))
				for i = 0, #spisokoskrod do
					if text:match('}'..tostring(spisokoskrod[i])) or text:match('%s'..tostring(spisokoskrod[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/rmute ' .. oskid .. ' 5000 Оскорбление/Упоминание родных')
						if notify_report then
							notify_report.addNotify('{FF7F50}<Автомут>', '------------------------------------------------------\nВыявлен нарушитель:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Упоминание родных.', 2,1,10)
						end
						return false
					end
				end
				for i = 0, #spisokrz do
					if text:match('}'..tostring(spisokrz[i])) or text:match('%s'..tostring(spisokrz[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/rmute ' .. oskid .. ' 5000 Розжиг межнац.розни')
						if notify_report then
							notify_report.addNotify('{FF7F50}<Автомут>', '------------------------------------------------------\nВыявлен нарушитель:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Розжиг межнац.розни', 2,1,10)
						end
						return false
					end
				end
			end
		end
        if (text:match("(.*)%((%d+)%):%s(.+)") or text:match("(.*)%[(%d+)%]:%s(.+)")) and not text:match("%[a%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)") and not text:match('написал %[(%d+)%]:') and not text:match('ответил (.*)%[(%d+)%]: (.*)') and not text:match('жалоба') then
            if text:match('%((%d+)%)') then
                oskid = text:match('%((%d+)%)')
            else
                oskid = text:match('%[(%d+)%]')
            end
			if cfg.settings.smart_automute then
				for i = 0, #spisokoskrod do
					if text:match('%s'.. tostring(spisokoskrod[i])) or text:match('}'..tostring(spisokoskrod[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/mute ' .. oskid .. ' 5000 Оскорбление/Упоминание родных')
						if notify_report then
							notify_report.addNotify('{FF7F50}<Автомут>', '------------------------------------------------------\nВыявлен нарушитель:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Упоминание родных.', 2,1,10)
						end
						return false
					end
				end
				for i = 0, #spisokrz do
					if text:match('}'..tostring(spisokrz[i])) or text:match('%s'..tostring(spisokrz[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/mute ' .. oskid .. ' 5000 Розжиг межнац.розни')
						if notify_report then
							notify_report.addNotify('{FF7F50}<Автомут>', '------------------------------------------------------\nВыявлен нарушитель:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Розжиг межнац.розни', 2,1,10)
						end
						return false
					end
				end
				for i = 0, #spisokproject do
					if text:match('%s' .. tostring(spisokproject[i])) or text:match('}' .. tostring(spisokproject[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendInputChat('/up ' .. oskid)
						if notify_report then
							notify_report.addNotify('<Автомут>', '------------------------------------------------------\nВыявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(spisokproject[i]), 2,1,10)
						end
						return false
					end
				end
			end
            for i = 0, #cfg.osk do
                if text:match('%s'..tostring(cfg.osk[i])) or text:match('}'..tostring(cfg.osk[i])) and not text:match('я ' .. tostring(cfg.osk[i])) then
					if cfg.settings.smart_automute then
						for d = 0, #spisokor do
							if text:match('%s'.. tostring(spisokor[d])) or text:match('}'..tostring(spisokor[d])) then
								sampAddChatMessage('=======================================================', 0x00FF00)
								sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
								sampAddChatMessage('=======================================================', 0x00FF00)
								sampSendChat('/mute ' .. oskid .. ' 5000 Оскорбление/упоминание родных')
								if notify_report then
									notify_report.addNotify('{FF7F50}<Автомут>', '------------------------------------------------------\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(cfg.osk[i]) .. ' и ' .. tostring(spisokor[d]), 2,1,10)
								end
								return false
							end
						end
					end
					sampAddChatMessage('=======================================================', 0x00FF00)
					sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
					sampAddChatMessage('=======================================================', 0x00FF00)
					sampSendChat('/mute ' .. oskid .. ' 400 Оскорбление/Унижение')
					if notify_report then
						notify_report.addNotify('{FF7F50}<Автомут>', '------------------------------------------------------\nВыявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(cfg.osk[i]), 2,1,10)
					end
					return false
                end
            end
            for i = 0, #cfg.mat do
                if text:match('%s'.. tostring(cfg.mat[i])) or text:match('}'..tostring(cfg.mat[i])) then
					if cfg.settings.smart_automute then
						for d = 0, #spisokor do
							if text:match('%s'.. tostring(spisokor[d])) or text:match('}'..tostring(spisokor[d])) then
								sampAddChatMessage('=======================================================', 0x00FF00)
								sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
								sampAddChatMessage('=======================================================', 0x00FF00)
								sampSendChat('/mute ' .. oskid .. ' 5000 Оскорбление/упоминание родных')
								if notify_report then
									notify_report.addNotify('{FF7F50}<Автомут>', '------------------------------------------------------\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(cfg.mat[i]) .. ' и ' .. tostring(spisokor[d]), 2,1,10)
								end
								return false
							end
						end
					end
					sampAddChatMessage('=======================================================', 0x00FF00)
					sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
					sampAddChatMessage('=======================================================', 0x00FF00)
					sampSendChat('/mute ' .. oskid .. ' 300 Нецензурная лексика')
					if notify_report then
						notify_report.addNotify('{FF7F50}<Автомут>', '------------------------------------------------------\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(cfg.mat[i]), 2,1,10)
					end						
					return false
                end
            end
        end
	end
end
function sampev.onShowTextDraw(id, data) -- Считываем серверные текстдравы
	if cfg.settings.on_custom_recon_menu then
		for k,v in pairs(data) do
			v = tostring(v)
			if v == 'REFRESH' then textdraw.refresh = id  -- записываем ид кнопки обновить в реконе
			elseif v:match('~') and v:match('0') then textdraw.inforeport = id  -- инфо панель в реконе
			elseif v:match('(%(%d+)%)') then textdraw.name_report = id -- ник игрока в реконе
			elseif v == 'STATS' then textdraw.stats = id sampTextdrawSetPos(id, 2000, 0) 
			elseif v == 'CLOSE' then textdraw.close = id sampTextdrawSetPos(id, 2000, 0)
			end
		end
		if id == textdraw.name_report then
			lua_thread.create(function()
				wait(500)
				playerrecon = tonumber(string.match(sampTextdrawGetString(textdraw.name_report), '%((%d+)%)')) -- id нарушителя
				while not inforeport do
					wait(0)
				end
				sampTextdrawSetPos(textdraw.inforeport, 2000, 0) -- информация
				sampTextdrawSetPos(textdraw.refresh,2000,0) -- кнопка Refresh в реконе
				sampTextdrawSetPos(textdraw.name_report, 2000, 0) -- информация о никнейме игрока
				windows.recon_menu.v = true
				imgui.Process = true
				if cfg.settings.keysync then
					sampSendInputChat('/keysync ' .. playerrecon)
				end
			end)
		end
		if id == textdraw.inforeport then
			lua_thread.create(function()
				while id == textdraw.inforeport do
					inforeport = textSplit(sampTextdrawGetString(textdraw.inforeport), "~n~") -- информация о игроке, считывание с текстрдрава
					for i = 4, #inforeport do
						if i == 4 then
							if inforeport[i] == '-1' then -- хп авто
								inforeport[i] = '-'
							end
						elseif i == 7 then -- gun
							if inforeport[i] == '0 : 0 ' then
								inforeport[i] = '-'
							end
						elseif i == 12 then -- vip
							if inforeport[i] == '0' then
								inforeport[i] = '-'
							elseif inforeport[i] == '1' then
								inforeport[i] = 'Standart'
							elseif inforeport[i] == '2' then
								inforeport[i] = 'Premium'
							elseif inforeport[i] == '3' then
								inforeport[i] = 'Diamond'
							elseif inforeport[i]== '4' then
								inforeport[i] = 'Platinum'
							elseif inforeport[i] == '5' then
								inforeport[i] = 'Personal'
							end
						end
					end
					wait(1000)
				end
			end)
		end
		if (id == 446 or id == 153 or id == 150 or id == 164 or id == 169 or id == 186
			or id == 161 or id == 164 or id == 162 or id == 163 or id == 169
			or id == 166 or id == 188 or id == 168 or id == 188 or id == 173
			or id == 189 or id == 170 or id == 173 or id == 189 or id == 189
			or id == 189 or id == 175 or id == 178 or id == 173 or id == 172
			or id == 178 or id == 190 or id == 179 or id == 177 or id == 175
			or id == 183 or id == 191 or id == 184 or id == 182 or id == 159
			or id == 159 or id == 192 or id == 156 or id == 160 or id == 158
			or id == 182 or id == 151 or id == 152 or id == 193 or id == 155
			or id == 167 or id == 174 or id == 171 or id == 187 or id == 176
			or id == 181 or id == 180 or id == 157 or id == 154 or id == 185
			or id == 444 or id == 148 or id == 165 or id == 149) then
			return false -- удаление лишних текстравов в реконе
		end
	end
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text) -- Работа с открытими ДИАЛОГАМИ
	if cfg.settings.render_admins then
		if title:find('Администрация проекта') then
			admins = textSplit(text, '\n') 
			for i = 1, #admins - 1 do -- {FFFFFF}N.E.O.N(0) ({2E8B57}Мл.Администратор{FFFFFF}) | Уровень: {ff8587}6{FFFFFF} | Выговоры: {ff8587}0 из 3{FFFFFF} | Репутация: {ff8587}
				local rang = string.sub(string.gsub(string.match(admins[i], '(%(.+)%)'), '(%(%d+)%)', ''), 3) --{FFFFFF}N.E.O.N(0) | Уровень: {ff8587}18{FFFFFF} | Выговоры: {ff8587}0 из 3{FFFFFF} | Репутация: {ff8587}60
				admins[i] = string.gsub(admins[i], '{%w%w%w%w%w%w}', "")
				local afk = string.match(admins[i], 'AFK: (.+)')
				local name, id, _, lvl, _, _ = string.match(admins[i], '(.+)%((%d+)%) (%(.+)%) | Уровень: (%d+) | Выговоры: (%d+) из (%d+) | Репутация: (%d+)')
				local name, id, lvl = tostring(name), tostring(id), tostring(lvl)
				admins[i] = string.gsub(admins[i], '| Выговоры: %d из %d |', "")
				admins[i] = string.gsub(admins[i], 'Репутация: (.+)', "")
				if #rang>2 then
					if afk then
						admins[i] = name .. '(' .. id .. ') ' .. rang .. ' ' .. lvl .. ' AFK: ' .. afk
					else
						admins[i] = name .. '(' .. id .. ') ' .. rang .. ' '.. lvl
					end
				end
				local name, id, rang, lvl, afk, rang = nil
			end
			imgui.Process = true
			windows.render_admins.v = true
			sampSendDialogResponse(dialogId, 1, 0)
			return false
		end
	end
	if dialogId == 1098 and cfg.settings.autoonline then -- автоонлайн
		local c = math.floor(sampGetPlayerCount(false) / 10)
		sampSendDialogResponse(dialogId, 1, c - 1)
		local c = nil
		sampCloseCurrentDialogWithButton(0)
		return false
	end
	if dialogId == 16190 then -- окно /offstats где выбор между статистикой и авто используется для /sbanip
		if ipfind then
			sampSendDialogResponse(16190,1,0)
		end
		if ipfindclose then
			lua_thread.create(function()
				while sampIsDialogActive() do
					wait(0)
					setVirtualKeyDown(27, true)
					setVirtualKeyDown(27, false)
				end
			end)
			ipfindclose = nil
		end
	end
	if dialogId == 16191 then -- окно /offstats используется для /sbanip
		lua_thread.create(function()
			if ipfind then
				while not sampIsDialogActive() do
					wait(0)
				end
				offstat = textSplit(text, '\n')
				for k,v in pairs(offstat) do
					wait(0)
					if k == 12 then
						v = string.sub(v, 17)
						regip = v
					end
					if k == 13 then
						v = string.sub(v, 18)
						lastip = v
					end
				end
				ipfindclose = true
				ipfind = nil
				sampSendDialogResponse(dialogId,1,0)
			end
		end)
	end
	if dialogId == 2348 and windows.fast_report.v then
		windows.fast_report.v = false
	end
	if dialogId == 2349 then -- окно с самим репортом.
		answer = {}
		windows.answer_player_report.v = false
		saveplayerrecon = nil
		local lineIndex = -1
		for line in text:gmatch("[^\n]+") do
			lineIndex = lineIndex + 1
			if lineIndex == tonumber(1) - 1 then 
				don = string.sub(line, 1, 1)
				if don == '{' then
					autor = string.sub(line, 24) -- считываем автора жалобы
					if sampGetPlayerIdByNickname(autor) then
						autorid = sampGetPlayerIdByNickname(autor) -- узнаем ид
					else
						autorid = (u8'НЕ В СЕТИ')
					end
				end
			end
		end
		local lineIndex = -1
		for line in text:gmatch("[^\n]+") do
			lineIndex = lineIndex + 1
			if lineIndex == tonumber(3) - 1 then 
				don = string.sub(line, 1, 1)
				if don == '{' then
					textreport = string.gsub(string.sub(line, 9), '{%w%w%w%w%w%w}', "") -- text report
					if string.match(line, '%d[%d.,]*') then
						reportid = tonumber(string.match(textreport, '%d[%d.,]*'))
						if sampIsPlayerConnected(reportid) then
							nickreportid = sampGetPlayerNickname(reportid) -- ник того на кого жалуются
						else
							_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						end
					end
				end
			end
		end
		if cfg.settings.on_custom_answer then
			windows.fast_report.v = true
			imgui.Process = true
		end
		lua_thread.create(function()
			while not (answer.rabotay or answer.uto4 or answer.nakajy or answer.customans or answer.slejy or answer.jb or answer.ojid or answer.moiotvet or answer.uto4id or answer.nakazan or answer.otklon or answer.peredamrep) do -- ждем нажатия клавиши
				wait(200)
			end
			sampSendDialogResponse(dialogId,1,0)
		end)
	end
	if dialogId == 2350 then -- окно с возможностью принять или отклонить репорт
		windows.fast_report.v = false
		if ((#(u8:decode(buffer.text_ans.v)) ~= 0) and #answer == 0) or answer.moiotvet then
			peremrep = (u8:decode(buffer.text_ans.v))
			if #peremrep >= 80 then
				setClipboardText(peremrep)
				sampAddChatMessage(tag .. 'Ваш ответ оказался слишком длинным и сохранен в буффер обмена.', -1)
			elseif #peremrep <= 4 and not cfg.settings.mytextreport then
				peremrep = (u8:decode(buffer.text_ans.v) .. '   ')
			end
			if peremrep then
				if cfg.settings.custom_answer_save then
					cfg.customotvet[ #cfg.customotvet + 1 ] = u8:decode(buffer.text_ans.v)
					save()
				end	
				answer.moiotvet = true
			end
		end
		if answer.rabotay then
			peremrep = ('Начал(а) работу по вашей жалобе!')
		end
		if answer.ojid then
			peremrep = ('Ожидайте, скоро всё будет.')
		end
		if answer.nakazan then
			peremrep = ('Данный игрок уже был наказан.')
		end
		if answer.uto4id then
			peremrep = ('Уточните ID нарушителя в /report.')
		end
		if answer.nakajy then
			peremrep = ('Будете наказаны за нарушение правил /report')
			windows.fast_rmute.v = true
			if nakazatreport.oftop or nakazatreport.oskadm or nakazatreport.matrep or nakazatreport.oskrep or nakazatreport.poprep or nakazatreport.oskrod or nakazatreport.capsrep then
				windows.fast_rmute.v = false
			end  
		end
		if answer.jb then
			peremrep = ('Напишите жалобу на forumrds.ru')
		end
		if answer.peredamrep then
			peremrep = ('Передам ваш репорт.')
		end
		if answer.rabotay then
			if not reportid then
				peremrep = ('Начал(а) работу по вашей жалобе.')
			end
			if reportid and reportid ~= myid then
				if not sampIsPlayerConnected(reportid) then
					peremrep = ('Указанный вами игрок под ' .. reportid .. ' ID находится вне сети.')
				else
					peremrep = ('Начал(а) работу по вашей жалобе.')
				end
			end
			if reportid == myid then
				peremrep = ('Начал(а) работу по вашей жалобе.')
			end
		end
		if answer.slejy then
			if not reportid then
				peremrep = ('Начинаю слежку.')
				answer.slejy = nil
			end
			if reportid and reportid ~= myid then
				if not sampIsPlayerConnected(reportid) then
					peremrep = ('Указанный вами игрок под ' .. reportid .. ' ID находится вне сети.')
					answer.slejy = nil
				else
					peremrep = ('Отправляюсь в слежку за игроком ' .. nickreportid .. '['..reportid..']')
				end
			end
			if myid then
				if reportid == myid then
					peremrep = ('Вы указали мой ID :D')
					answer.slejy = nil
				end
			end
		end
		if answer.customans then
			peremrep = answer.customans
			if #peremrep >= 80 then
				setClipboardText(peremrep)
				peremrep = 'Мой ответ не вмещается в окно репорта, я отпишу вам лично'
				sampAddChatMessage(tag .. 'Ваш ответ сохранен в буффер обмена.', -1)
			end
			if #peremrep < 4 then
				peremrep = (answer.customans .. '    ')
			end
		end
		if answer.uto4 then
			peremrep = ('Обратитесь с данной проблемой на форум https://forumrds.ru')
		end
		if answer.otklon then
			sampSendDialogResponse(dialogId, 1, 2, _)
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
			answer = {}
		end
		if (answer.rabotay or answer.uto4 or answer.nakajy or answer.customans or answer.slejy or answer.jb or answer.ojid or answer.moiotvet or answer.uto4id or answer.nakazan or answer.otklon or answer.peredamrep) then -- ждем нажатия клавиши
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end
	end
	if dialogId == 2351 and peremrep then -- окно с ответом на репорт
		lua_thread.create(function()
			if cfg.settings.add_answer_report then
				sampSendDialogResponse(dialogId, 1, _, peremrep .. ('{'..tostring(color())..'} ' .. cfg.settings.mytextreport))
			else
				sampSendDialogResponse(dialogId, 1, _, peremrep)
			end
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
			while sampIsDialogActive() do
				wait(0)
			end
			wait(300)
			if answer.rabotay then
				sampSendChat('/re ' .. autor)
			end
			if answer.slejy then
				sampSendChat('/re ' .. reportid)
			end
			if answer.peredamrep then
				sampSendChat('/a ' .. autor .. '[' .. u8(autorid) .. '] | ' .. textreport)
			end
			if answer.nakajy then
				if nakazatreport.oftop then
					sampSendChat('/rmute ' .. autorid .. ' 120 оффтоп в /report')
				end
				if nakazatreport.oskadm then
					sampSendChat('/rmute ' .. autorid .. ' 2500 Оскорбление администрации')
				end
				if nakazatreport.oskrep then
					sampSendChat('/rmute ' .. autorid .. ' 400 Оскорбление/Унижение')
				end
				if nakazatreport.poprep then
					sampSendChat('/rmute ' .. autorid .. ' 120 Попрошайничество')
				end
				if nakazatreport.oskrod then
					sampSendChat('/rmute ' .. autorid .. ' 5000 Оскорбление/Упоминание родных')
				end
				if nakazatreport.capsrep then
					sampSendChat('/rmute ' .. autorid .. ' 120 Капс в /report')
				end
				if nakazatreport.matrep then
					sampSendChat('/rmute ' .. autorid .. ' 300 Нецензурная лексика')
				end
				if nakazatreport.kl then
					sampSendChat('/rmute ' .. autorid .. ' 3000 Клевета на администрацию')
				end
				nakazatreport = {}
			end
			peremrep = nil
			buffer.text_ans.v = ''
			if not saveplayerrecon and (tonumber(autorid) and answer.slejy) and cfg.settings.answer_player_report then
				saveplayerrecon = autorid
				ansid = reportid
				answer = {}
				timerans()
			else
				saveplayerrecon = nil
				ansid = nil
				answer = {}
			end
		end)
	end
end
function sampev.onDisplayGameText(style, time, text) -- скрывает текст на экране.
	if text:find('RECON') then
		windows.recon_menu.v = false
		return false
	end
	if text:find('REPORT') then
		if cfg.settings.notify_report and not AFK then
			if notify_report then
				notify_report.addNotify('{FF0000}[AT Уведомление]', '------------------------------------------------------\nПоступил новый репорт.', 2,2,8)
			end
		end
		return false
	end
end
function wait_accept_form()
	lua_thread.create(function()
		while st.sett do
			wait(50)
			if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() then
				if sampIsPlayerConnected(st.idadmin) then
					if st.forumplease then
						st.cheater = string.match(st.forma, '%d[%d.,]*')
						sampSendChat('/ans ' .. st.cheater .. ' Уважаемый игрок, Вы наказаны по форме администратора ' .. sampGetPlayerNickname(st.idadmin))
						wait(500)
						sampSendChat('/ans ' .. st.cheater .. ' Если Вы не согласны с наказанием, напишите жалобу на форум https://forumrds.ru')
					end
					if not st.styleform then
						wait(500)
						sampSendChat(st.forma .. ' // ' .. sampGetPlayerNickname(st.idadmin))
					else
						wait(500)
						sampSendChat(st.forma)
					end
					wait(500)
					sampSendChat('/a AT - Одобрено.')
				else
					sampAddChatMessage(tag .. 'Администратор не в сети.', -1)
				end
				st.forma = nil
				st = {}
				break
			end
			if isKeyDown(VK_J) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampAddChatMessage(tag .. 'форма отклонена', -1)
				st.forma = nil
				st = {}
				break
			end
		end
	end)
end
function imgui.TextColoredRGB(text) -- цветной рендер админс
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end
function imgui.Tooltip(text)
    if imgui.IsItemHovered() then
       imgui.BeginTooltip() -- подсказка при наведении на кнопку
       imgui.Text(text)
       imgui.EndTooltip()
    end
end
function HelperMA()
	while true do
		wait(0)
		if sampIsChatInputActive() then
			local getInput = sampGetChatInputText()
			if #getInput > 0 then
                if getInput:find('(.+) (.+) (.+) (.+)') then
                    arg1, arg2, arg3, arg4 = getInput:match('(.+) (.+) (.+) (.+)')
					local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    if arg1:find('ban') and cfg.settings.forma_na_ban and isKeyJustPressed(VK_RETURN) then
                        if cfg.settings.add_mynick_in_form then
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4 .. ' // ' .. sampGetPlayerNickname(myid))
                        else
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4)
                        end
                    end
                    if arg1:find('jail') and cfg.settings.forma_na_jail and isKeyJustPressed(VK_RETURN) then
                        if cfg.settings.add_mynick_in_form then
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4 .. ' // ' .. sampGetPlayerNickname(myid))
                        else
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4)
                        end
                    end
                    if arg1:find('mute') and cfg.settings.forma_na_mute and isKeyJustPressed(VK_RETURN) then
                        if cfg.settings.add_mynick_in_form then
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4 .. ' // ' .. sampGetPlayerNickname(myid))
                        else
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4)
                        end
                    end
                    if arg1:find('kick') and cfg.settings.forma_na_kick and isKeyJustPressed(VK_RETURN) then
                        if cfg.settings.add_mynick_in_form then
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4 .. ' // ' .. sampGetPlayerNickname(myid))
                        else
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4)
                        end
                    end
                end
			end
		end
	end
end
local russian_characters = { -- русские буковки для функции ниже
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s) -- перевод русских букв в прописные
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function uu() -- для вкладок
    for i = 0,2 do
        menu[i] = false
    end
end
function uu2() -- для вкладок
    for i = 0,10 do
        menu2[i] = false
    end
end
function textSplit(str, delim, plain) -- разбиение текста по определенным триггерам
    local tokens, pos, plain = {}, 1, not (plain == false)
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end
function sampGetPlayerIdByNickname(nick) -- узнать ID по нику
	nick = tostring(nick)
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if nick == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 301 do
	  	if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
			return i
	  	end
	end
end
function render_admins()
	while true do
		while sampIsDialogActive() or sampIsChatInputActive() do wait(0) end
		if not AFK then sampSendChat('/admins') end
		wait(20000)
	end
end
------------- Input Helper -------------
function translite(text)
	for k, v in pairs(chars) do
		text = string.gsub(text, k, v)
	end
	return text
end
function inputChat()
	while true do
		wait(0)
		if sampIsChatInputActive() and cfg.settings.inputhelper then
			local getInput = sampGetChatInputText()
			if(oldText ~= getInput and #getInput > 0)then
				local firstChar = string.sub(getInput, 1, 1)
				if(firstChar == "." or firstChar == "/")then
					local cmd, text = string.match(getInput, "^([^ ]+)(.*)")
					local nText = "/" .. translite(string.sub(cmd, 2)) .. text
					local chatInfoPtr = sampGetInputInfoPtr()
					local chatBoxInfo = getStructElement(chatInfoPtr, 0x8, 4)
					local lastPos = mem.getint8(chatBoxInfo + 0x11E)
					sampSetChatInputText(nText)
					mem.setint8(chatBoxInfo + 0x11E, lastPos)
					mem.setint8(chatBoxInfo + 0x119, lastPos)
					oldText = nText
				end
			end
		end
	end
end
------------- Input Helper -------------
 ------------- KEYSYNC ----------------
local target = -1
function sampev.onPlayerSync(playerId, data)
	local result, id = sampGetPlayerIdByCharHandle(target)
	if result and id == playerId then
		keys["onfoot"] = {}

		keys["onfoot"]["W"] = (data.upDownKeys == 65408) or nil
		keys["onfoot"]["A"] = (data.leftRightKeys == 65408) or nil
		keys["onfoot"]["S"] = (data.upDownKeys == 00128) or nil
		keys["onfoot"]["D"] = (data.leftRightKeys == 00128) or nil

		keys["onfoot"]["Alt"] = (bit.band(data.keysData, 1024) == 1024) or nil
		keys["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["onfoot"]["Space"] = (bit.band(data.keysData, 32) == 32) or nil
		keys["onfoot"]["F"] = (bit.band(data.keysData, 16) == 16) or nil
		keys["onfoot"]["C"] = (bit.band(data.keysData, 2) == 2) or nil

		keys["onfoot"]["RKM"] = (bit.band(data.keysData, 4) == 4) or nil
		keys["onfoot"]["LKM"] = (bit.band(data.keysData, 128) == 128) or nil
	end
end
function sampev.onVehicleSync(playerId, vehicleId, data)
	local result, id = sampGetPlayerIdByCharHandle(target)
	if result and id == playerId then
		keys["vehicle"] = {}
		keys["vehicle"]["W"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["vehicle"]["A"] = (data.leftRightKeys == 65408) or nil
		keys["vehicle"]["S"] = (bit.band(data.keysData, 32) == 32) or nil
		keys["vehicle"]["D"] = (data.leftRightKeys == 00128) or nil

		keys["vehicle"]["H"] = (bit.band(data.keysData, 2) == 2) or nil
		keys["vehicle"]["Space"] = (bit.band(data.keysData, 128) == 128) or nil
		keys["vehicle"]["Ctrl"] = (bit.band(data.keysData, 1) == 1) or nil
		keys["vehicle"]["Alt"] = (bit.band(data.keysData, 4) == 4) or nil
		keys["vehicle"]["Q"] = (bit.band(data.keysData, 256) == 256) or nil
		keys["vehicle"]["E"] = (bit.band(data.keysData, 64) == 64) or nil
		keys["vehicle"]["F"] = (bit.band(data.keysData, 16) == 16) or nil

		keys["vehicle"]["Up"] = (data.upDownKeys == 65408) or nil
		keys["vehicle"]["Down"] = (data.upDownKeys == 00128) or nil
	end
end
mimgui.OnInitialize(function()
	sW, sH = getScreenResolution()
	u32 = mimgui.ColorConvertFloat4ToU32

	mimgui.SwitchContext()
	mimgui.GetStyle().WindowPadding = mimgui.ImVec2(10, 10)
	mimgui.GetStyle().ItemSpacing = mimgui.ImVec2(5, 5)
	mimgui.GetStyle().WindowRounding = 5.0
	mimgui.GetStyle().Colors[mimgui.Col.WindowBg] = mimgui.ImVec4(0.16, 0.16, 0.22, 0.50)
end)
mimgui.OnFrame(
    function() return target ~= -1 end,
    function(self)
    	self.HideCursor = true
		mimgui.SetNextWindowPos(mimgui.ImVec2(cfg.settings.keysyncx, cfg.settings.keysyncy), mimgui.Cond.Always, mimgui.ImVec2(0.5, 0.5))
		mimgui.Begin("##KEYS", nil, mimgui.WindowFlags.NoTitleBar + mimgui.WindowFlags.AlwaysAutoResize)
			if doesCharExist(target) then
				local plState = (isCharOnFoot(target) and "onfoot" or "vehicle")
				mimgui.BeginGroup()
					mimgui.SetCursorPosX(10 + 30 + 5)
					KeyCap("W", (keys[plState]["W"] ~= nil), mimgui.ImVec2(30, 30))
					KeyCap("A", (keys[plState]["A"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("S", (keys[plState]["S"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("D", (keys[plState]["D"] ~= nil), mimgui.ImVec2(30, 30))
				mimgui.EndGroup()
				mimgui.SameLine(nil, 20)

				if plState == "onfoot" then
					mimgui.BeginGroup()
						KeyCap("Shift", (keys[plState]["Shift"] ~= nil), mimgui.ImVec2(75, 30)); mimgui.SameLine()
						KeyCap("Alt", (keys[plState]["Alt"] ~= nil), mimgui.ImVec2(55, 30))
						KeyCap("Space", (keys[plState]["Space"] ~= nil), mimgui.ImVec2(135, 30))
					mimgui.EndGroup()
					mimgui.SameLine()
					mimgui.BeginGroup()
						KeyCap("C", (keys[plState]["C"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
						KeyCap("F", (keys[plState]["F"] ~= nil), mimgui.ImVec2(30, 30))
						KeyCap("RM", (keys[plState]["RKM"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
						KeyCap("LM", (keys[plState]["LKM"] ~= nil), mimgui.ImVec2(30, 30))		
					mimgui.EndGroup()
				else
					mimgui.BeginGroup()
						KeyCap("Ctrl", (keys[plState]["Ctrl"] ~= nil), mimgui.ImVec2(65, 30)); mimgui.SameLine()
						KeyCap("Alt", (keys[plState]["Alt"] ~= nil), mimgui.ImVec2(65, 30))
						KeyCap("Space", (keys[plState]["Space"] ~= nil), mimgui.ImVec2(135, 30))
					mimgui.EndGroup()
					mimgui.SameLine()
					mimgui.BeginGroup()
						KeyCap("Up", (keys[plState]["Up"] ~= nil), mimgui.ImVec2(40, 30))
						KeyCap("Down", (keys[plState]["Down"] ~= nil), mimgui.ImVec2(40, 30))	
					mimgui.EndGroup()
					mimgui.SameLine()
					mimgui.BeginGroup()
						KeyCap("H", (keys[plState]["H"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
						KeyCap("F", (keys[plState]["F"] ~= nil), mimgui.ImVec2(30, 30))
						KeyCap("Q", (keys[plState]["Q"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
						KeyCap("E", (keys[plState]["E"] ~= nil), mimgui.ImVec2(30, 30))
					mimgui.EndGroup()
				end
				if not windows.recon_menu.v then
					sampSendInputChat('/keysync off')
				end
			else
				mimgui.Text(u8"Игрок не зафиксирован. Обновите рекон нажав клавишу R")
				if not windows.recon_menu.v then
					sampSendInputChat('/keysync off')
				end
			end
		mimgui.End()
    end
)
function KeyCap(keyName, isPressed, size)
	local DL = mimgui.GetWindowDrawList()
	local p = mimgui.GetCursorScreenPos()
	local colors = {
		[true] = mimgui.ImVec4(0.60, 0.60, 1.00, 1.00),
		[false] = mimgui.ImVec4(0.60, 0.60, 1.00, 0.10)
	}
	if KEYCAP == nil then KEYCAP = {} end
	if KEYCAP[keyName] == nil then
		KEYCAP[keyName] = {
			status = isPressed,
			color = colors[isPressed],
			timer = nil
		}
	end
	local K = KEYCAP[keyName]
	if isPressed ~= K.status then
		K.status = isPressed
		K.timer = os.clock()
	end
	local rounding = 3.0
	local A = mimgui.ImVec2(p.x, p.y)
	local B = mimgui.ImVec2(p.x + size.x, p.y + size.y)
	if K.timer ~= nil then
		K.color = bringVec4To(colors[not isPressed], colors[isPressed], K.timer, 0.1)
	end
	local ts = mimgui.CalcTextSize(keyName)
	local text_pos = mimgui.ImVec2(p.x + (size.x / 2) - (ts.x / 2), p.y + (size.y / 2) - (ts.y / 2))

	mimgui.Dummy(size)
	DL:AddRectFilled(A, B, u32(K.color), rounding)
	DL:AddRect(A, B, u32(colors[true]), rounding, _, 1)
	DL:AddText(text_pos, 0xFFFFFFFF, keyName)
end
function cyrillic(text)
    local convtbl = {
    	[230] = 155, [231] = 159, [247] = 164, [234] = 107, [250] = 144, [251] = 168,
    	[254] = 171, [253] = 170, [255] = 172, [224] = 097, [240] = 112, [241] = 099, 
    	[226] = 162, [228] = 154, [225] = 151, [227] = 153, [248] = textdraw.refresh, [243] = 121, 
    	[184] = 101, [235] = 158, [238] = 111, [245] = 120, [233] = 157, [242] = 166, 
    	[239] = 163, [244] = 063, [237] = 174, [229] = 101, [246] = 036, [236] = 175, 
    	[232] = 156, [249] = 161, [252] = 169, [215] = 141, [202] = 075, [204] = 077, 
    	[220] = 146, [221] = 147, [222] = 148, [192] = 065, [193] = 128, [209] = 067, 
    	[194] = 139, [195] = 130, [197] = 069, [206] = 079, [213] = 088, [168] = 069, 
    	[223] = 149, [207] = 140, [203] = 135, [201] = 133, [199] = 136, [196] = 131, 
    	[208] = 080, [200] = 133, [198] = 132, [210] = 143, [211] = 089, [216] = 142, 
    	[212] = 129, [214] = 137, [205] = 072, [217] = 138, [218] = 167, [219] = 145
    }
    local result = {}
    for i = 1, string.len(text) do
        local c = text:byte(i)
        result[i] = string.char(convtbl[c] or c)
    end
    return table.concat(result)
end
function bringVec4To(from, dest, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return mimgui.ImVec4(
            from.x + (count * (dest.x - from.x) / 100),
            from.y + (count * (dest.y - from.y) / 100),
            from.z + (count * (dest.z - from.z) / 100),
            from.w + (count * (dest.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and dest or from, false
end
 ------------- KEYSYNC ----------------
function imgui.NewInputText(lable, val, width, hint, hintpos) -- Поле ввода с подсказкой
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    local result = imgui.InputText(lable, val)
    if #val.v == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end
function onWindowMessage(msg, wparam, lparam) -- блокировка ALT + Enter
	if msg == 261 and wparam == 13 then consumeWindowMessage(true, true) end
end
function playersToStreamZone() -- игроки в радиусе
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(control_recon_playerid) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end
function ScriptExport()
	lua_thread.create(function()
		if cfg.settings.wallhack then
			sampSendInputChat('/wh ')
		end
		wait(300)
		sampSendInputChat('/fsoff')
		wait(300)
		sampSendInputChat('/mpoff')
		imgui.Process = false
		showCursor(false,false)
		thisScript():unload()
	end)
end
function autoonline()
	while true do
		wait(61000)
		while sampIsDialogActive() or sampIsChatInputActive() do
			wait(0)
		end
		wait(200)
		if not AFK then
			sampSendChat("/online")
		end
	end
end
function sampSendInputChat(text) -- отправка в чат через ф6
	sampSetChatInputText(text)
	sampSetChatInputEnabled(true)
	setVirtualKeyDown(13, true)
	setVirtualKeyDown(13, false)
end
---------------===================== Определенение ID нажатой клавиши
 function getDownKeys()
    local curkeys = ""
    local bool = false
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
            if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
                curkeys = v
            end
        end
    end
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
            if tostring(curkeys):len() == 0 then
                curkeys = v
            else
                curkeys = curkeys .. " " .. v
            end
            bool = true
        end
    end
    return curkeys, bool
end

function getDownKeysText()
	tKeys = textSplit(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.id_to_name(tonumber(tKeys[i]))
			else
				str = str .. "+" .. vkeys.id_to_name(tonumber(tKeys[i]))
			end
		end
		return str
	else
		return "None"
	end
end

function strToIdKeys(str)
	tKeys = textSplit(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.name_to_id(tKeys[i], false)
			else
				str = str .. " " .. vkeys.name_to_id(tKeys[i], false)
			end
		end
		return tostring(str)
	else
		return "(("
	end
end

function isKeysDown(keylist, pressed)
    local tKeys = textSplit(keylist, " ")
    if pressed == nil then
        pressed = false
    end
    if tKeys[1] == nil then
        return false
    end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    else
        if isKeyDown(modified) and not wasKeyReleased(modified) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    end
    if nextLockKey == keylist then
        if pressed and not wasKeyReleased(key) then
            bool = false
        else
            bool = false
            nextLockKey = ""
        end
    end
    return bool
end
---------------===================== Определенение ID нажатой клавиши
function save()
	inicfg.save(cfg,directIni)
end
function timerans()
	while saveplayerrecon do
		wait(500)
		if not windows.recon_menu.v then
			while not windows.recon_menu.v do
				wait(0)
			end
		end
		while windows.recon_menu.v do
			wait(2000)
		end
		if saveplayerrecon then
			if sampIsPlayerConnected(saveplayerrecon) then
				imgui.Process = true
				windows.answer_player_report.v = true
				showCursor(false,false)
				wait(5500)
				if windows.answer_player_report.v then
					windows.answer_player_report.v = false
					saveplayerrecon = nil
				end
			else
				sampAddChatMessage(tag .. 'Игрок, написавший репорт, находится вне сети.', -1)
			end
		end
	end
end
function timer() -- таймер для автоформ
	while true do
		wait(0)
		if st.bool and st.timer and st.sett then
            timer = os.clock() - st.timer
			if st.probid then
				if sampIsPlayerConnected(st.probid) then
					renderFontDrawText(fonts, '{FFFFFF}' .. 'Нажми U чтобы принять или J чтобы отклонить\nФорма: ' .. '{F0E68C}' .. st.forma .. '{FFFFFF}' .. ' на игрока '.. '{F0E68C}' .. nickid .. '[' .. st.probid .. ']'.. '{FFFFFF}' .. '\nВремени на раздумья 8 сек, прошло: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
				else
					renderFontDrawText(fonts, '{FFFFFF}' .. 'Нажми U чтобы принять или J чтобы отклонить\nФорма: ' .. '{F0E68C}' .. st.forma.. '{FFFFFF}' .. '\nВремени на раздумья 8 сек, прошло: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
				end
			else
				renderFontDrawText(fonts, '{FFFFFF}' .. 'Нажми U чтобы принять или J чтобы отклонить\nФорма: ' .. '{F0E68C}' .. st.forma.. '{FFFFFF}' .. '\nВремени на раздумья 8 сек, прошло: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
			end
            if timer>8 then
				st = {}
				st.forma = nil
            end
        end
	end
end
function color() -- рандом префикс
    mcolor = ""
    math.randomseed( os.time() )
    for i = 1, 6 do
		local b = math.random(1, 16)
        if b == 1 then mcolor = mcolor .. "A" elseif b == 2 then mcolor = mcolor .. "B" elseif b == 3 then mcolor = mcolor .. "C" elseif b == 4 then mcolor = mcolor .. "D" elseif b == 5 then mcolor = mcolor .. "E" elseif b == 6 then mcolor = mcolor .. "F" elseif b == 7 then mcolor = mcolor .. "0" elseif b == 8 then mcolor = mcolor .. "1" elseif b == 9 then mcolor = mcolor .. "2" elseif b == 10 then mcolor = mcolor .. "3" elseif b == 11 then mcolor = mcolor .. "4" elseif b == 12 then mcolor = mcolor .. "5" elseif b == 13 then mcolor = mcolor .. "6" elseif b == 14 then mcolor = mcolor .. "7" elseif b == 15 then mcolor = mcolor .. "8" elseif b == 16 then mcolor = mcolor .. "9" end
    end
    return mcolor
end
----------Wall hack --------------
function getBodyPartCoordinates(id, handle)
	local pedptr = getCharPointer(handle)
	local vec = ffi.new("float[3]")
	getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
	return vec[0], vec[1], vec[2]
end
function join_argb(a, r, g, b)
	local argb = b  -- b
	argb = bit.bor(argb, bit.lshift(g, 8))  -- g
	argb = bit.bor(argb, bit.lshift(r, 16)) -- r
	argb = bit.bor(argb, bit.lshift(a, 24)) -- a
	return argb
end
function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end
----------Wall hack --------------
function imgui.CenterText(text) -- центрирование текста
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 ) 			
    imgui.Text(text)
end
function imgui.Link(label, description) -- гиперссылка
    local size = imgui.CalcTextSize(label)
    local p = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local result = imgui.InvisibleButton(label, size)
    imgui.SetCursorPos(p2)
    if imgui.IsItemHovered() then
        if description then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
            imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()

        end
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.CheckMark]))
    else
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
	end
    return result
end
----======================= Исключительно для скрипта ===============------------------
sampRegisterChatCommand('wh' , function()
	if not cfg.settings.wallhack then
		cfg.settings.wallhack = true
		sampAddChatMessage(tag .. 'WallHack включен', -1)
		save()
		local pStSet = sampGetServerSettingsPtr();
		NTdist = mem.getfloat(pStSet + 39)
		NTwalls = mem.getint8(pStSet + 47)
		NTshow = mem.getint8(pStSet + 56)
		mem.setfloat(pStSet + 39, 500.0)
		mem.setint8(pStSet + 47, 0)
		mem.setint8(pStSet + 56, 1)
		nameTag = true
	else
		cfg.settings.wallhack = false
		sampAddChatMessage(tag .. 'WallHack выключен', -1)
		save()
		local pStSet = sampGetServerSettingsPtr();
		mem.setfloat(pStSet + 39, 30)
		mem.setint8(pStSet + 47, 0)
		mem.setint8(pStSet + 56, 1)
		nameTag = false
	end
end)
sampRegisterChatCommand("keysync", function(playerId)
	if playerId == "off" then
		target = -1
		return
	else
		playerId = tonumber(playerId)
		if playerId ~= nil then
			local pedExist, ped = sampGetCharHandleBySampPlayerId(playerId)
			if pedExist then
				target = ped
				return true
			end
			return
		end
	end
end)
sampRegisterChatCommand('tool', function()
	windows.menu_tools.v = not windows.menu_tools.v
	imgui.Process = windows.menu_tools.v
end)
sampRegisterChatCommand('pravila', function()
	windows.pravila.v = not windows.pravila.v
	imgui.Process = true
end)
----======================= Исключительно вспомогательные ===============------------------
sampRegisterChatCommand('spp', function()
	lua_thread.create(function()
		local playerid_to_stream = playersToStreamZone()
		for _, v in pairs(playerid_to_stream) do
			wait(500)
			sampSendChat('/aspawn ' .. v)
		end
	end)
end)
sampRegisterChatCommand('n', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' Не наблюдаю нарушений со стороны игрока. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' Не наблюдаю нарушений со стороны игрока.')
		end
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('dpr', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' У игрока куплены функции за /donate ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' У игрока куплены функции за /donate')
		end
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('c', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' Начал(а) работу над вашей жалобой. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' Начал(а) работу над вашей жалобой.')
		end
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('cl', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' Данный игрок чист. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' Данный игрок чист.')
		end
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('nak', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' Игрок был наказан, спасибо за обращение. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' Игрок был наказан, спасибо за обращение.')
		end
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('pmv', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' Помогли вам. Обращайтесь ещё ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' Помогли вам. Обращайтесь ещё')
		end
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('afk', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' Игрок бездействует или находится в AFK ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' Игрок бездействует или находится в AFK')
		end
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('nv', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' Игрок не в сети ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' Игрок не в сети')
		end
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('stw', function(param) 
	if #param ~= 0 then
		sampSendChat("/setweap " .. param .. " 38 5000")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('fo', function(param)
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' Обратитесь с данной проблемой на форум https://forumrds.ru')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('uu', function(param) 
	if #param ~= 0 then
		sampSendChat('/unmute ' .. param) 
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('uj', function(param) 
	if #param ~= 0 then
		sampSendChat('/unjail ' .. param) 
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('ur', function(param) 
	if #param ~= 0 then
		sampSendChat('/unrmute ' .. param) 
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('al', function(param) 
	if #param ~= 0 then
		lua_thread.create(function()
			sampSendChat('/ans ' .. param .. ' Здравствуйте! Вы забыли ввести /alogin!') 
			sampSendChat('/ans ' .. param .. ' Введите команду /alogin и свой пароль, пожалуйста.')
		end)
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rep', function(param) 
	if #param ~= 0 then
		lua_thread.create(function()
			sampSendChat('/ans ' .. param .. ' Задать вопрос или пожаловаться на игрока вы можете в /report')
			wait(500) 
			sampSendChat('/ans ' .. param .. ' Администрация сразу решит ваш вопрос.')
		end)
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('as', function(param) 
	if #param ~= 0 then
		sampSendChat('/aspawn ' .. param)
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('sbanip', function()
	lua_thread.create(function()
		sampShowDialog(6400, "Введите ник нарушителя", "", "Подтвердить", nil, DIALOG_STYLE_INPUT) -- сам диалог
		while sampIsDialogActive(6400) do wait(300) end -- ждёт пока вы ответите на диалог
		local result, button, _, input = sampHasDialogRespond(6405)
		if not input:match('(.+) (.+)') and #input ~= 0 then 
			local nick_nakazyemogo = input
			result, button, input = nil
			sampShowDialog(6401, "Введите наказание", "Необходимо указать количество дней блокировки аккаунта", "Подтвердить", nil, DIALOG_STYLE_INPUT) -- сам диалог
			while sampIsDialogActive(6401) do wait(300) end -- ждёт пока вы ответите на диалог
			local result, button, _, input = sampHasDialogRespond(6405)
			if not input:match('(.+) (.+)') and #input ~= 0 then 
				local nakazanie = input
				result, button, input = nil
				sampShowDialog(6402, "Введите причину", "Необходимо указать причину блокировки", "Подтвердить", nil, DIALOG_STYLE_INPUT) -- сам диалог
				while sampIsDialogActive(6402) do wait(300) end -- ждёт пока вы ответите на диалог
				local result, button, _, input = sampHasDialogRespond(6405)
				if input:match('(.+)') and #input ~= 0 then 
					local pri4ina = input
					result, button, input = nil
					ipfind = true
					sampSendChat('/offstats ' .. nick_nakazyemogo)
					while not regip or sampIsDialogActive() do wait(200) end
					wait(1000)
					sampSendChat('/banoff ' .. nick_nakazyemogo .. ' ' .. nakazanie .. ' ' .. pri4ina)
					wait(1000)
					sampSendChat('/banip ' .. regip .. ' ' .. nakazanie .. ' ' .. pri4ina)
					wait(1000)
					sampSendChat('/banip ' .. lastip .. ' ' .. nakazanie .. ' ' .. pri4ina)
					lastip,regip,nick_nakazyemogo,pri4ina,nakazanie = nil
				else
					sampAddChatMessage(tag .. 'Данные введены некорректно.',-1)
				end
			else
				sampAddChatMessage(tag .. 'Данные введены некорректно.',-1)
			end
		else
			sampAddChatMessage(tag .. 'Данные введены некорректно.',-1)
		end
	end)
end)

----======================= Исключительно для МУТОВ ЧАТА ===============------------------
sampRegisterChatCommand('m', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 300 Нецензурная лексика')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('mf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 300 Нецензурная лексика')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('m2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 600 Нецензурная лексика x2')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('m3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 900 Нецензурная лексика x3')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('ok', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 400 Оскорбление/Унижение')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('okf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 400 Оскорбление/Унижение')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('ok2', function(param) 
	if #param ~= 0 then
 		sampSendChat('/mute ' .. param .. ' 800 Оскорбление/Унижение x2')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('ok3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1200 Оскорбление/Унижение x3')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('fd', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 Флуд')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('fdf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 Флуд')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('fd2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 240 Флуд x2')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('fd3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 Флуд x3')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('or', function(param) 
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 5000 Оскорбление/Упоминание родных')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('orf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 Оскорбление/Упоминание родных')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('up', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1000 Упоминание сторонних проектов')
		sampAddChatMessage(tag .. 'рекомендуется очистить чат командой /cc', -1)
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('upf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 Упоминание сторонних проектов')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('oa', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 2500 Оскорбление администрации')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('oaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 Оскорбление администрации')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('kl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 3000 Клевета на администрацию')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('klf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 3000 Клевета на администрацию')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('po', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 Попрошайничество')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('pof', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 Попрошайничество')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('po2', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 240 Попрошайничество x2')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('po3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 Попрошайничество x3')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('zs', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 600 Злоупотребление символами")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('zsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 600 Злоупотребление символами')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('nm', function(param)
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 600 неадекватное поведение.')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rekl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 1000 Реклама")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('reklf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 Реклама')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rz', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 5000 Розжиг межнац. розни")
	else 
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 Розжиг межнац. розни')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('ia', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 2500 Выдача себя за администратора")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('iaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 Выдача себя за администратора')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
----======================= Исключительно для МУТОВ РЕПОРТА ===============------------------
sampRegisterChatCommand('oft', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('oftf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('oft2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Offtop in /report x2")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('oft3', function(param) 
	if param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Offtop in /report x3")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('cp', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('cpf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('cp2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Caps in /report x2")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('cp3', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Caps in /report x3")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('roa', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 2500 Оскорбление администрации")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('roaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 2500 Оскорбление администрации")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('ror', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 Оскорбление/Упоминание родных")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rorf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 Оскорбление/Упоминание родных")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rzs', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 600 Злоупотребление символами")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rzsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 600 Злоупотребление символами")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rrz', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 Розжиг меж.нац. розни")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rrzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 Розжиг меж.нац. розни")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rpo', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Попрошайничество")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rpof', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Попрошайничество")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rm', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 300 Мат в /report")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 300 Нецензурная лексика")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rok', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 400 Оскорбление в /report")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('rokf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 400 Оскорбление в /report")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
----======================= Исключительно для ДЖАЙЛА ===============------------------
sampRegisterChatCommand('dz', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ДМ/ДБ в зеленой зоне')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('dzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ДМ/ДБ в зеленой зоне')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('dz2', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 600 ДМ/ДБ в зеленой зоне x2')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('dz3', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 ДМ/ДБ в зеленой зоне x3')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('zv', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. " 3000 Злоупотребление VIP'ом")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('dmp', function(param)
	if #param ~= 0 then
		sampSendChat("/jail " .. param .. " 3000 Серьезная помеха на МП")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('zvf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 3000 Злоупотребление VIP'oм")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('sk', function(param)
	if #param ~= 0 then 
		sampSendChat('/jail ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('skf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('dk', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 ДБ Ковш в зеленой зоне')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('dkf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 ДБ Ковш в зеленой зоне')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('td', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 car in /trade')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('tdf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 300 Car in /trade")
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('jcb', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 3000 чит')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('jcbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 3000 чит')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('jm', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 Нарушение правил МП')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('jmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 Нарушение правил МП')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('jc', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 сторонний скрипт/ПО')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('jc2', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 1800 сторонний скрипт/ПО')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('jc3', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 2700 сторонний скрипт/ПО')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('jcf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 сторонний скрипт/ПО')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('bg', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 Багоюз')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('bgf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 Багоюз')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
----======================= Исключительно для БАНА ===============------------------
sampRegisterChatCommand('bosk', function(param) 
	if #param ~= 0 then
		sampSendChat('/siban ' .. param .. ' 999 Оскорбление проекта')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('boskf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 Оскорбление проекта')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('reklama', function(param) 
	if #param ~= 0 then
		sampSendChat('/siban ' .. param .. ' 999 Реклама')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('reklamaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 Реклама')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('obm', function(param) 
	if #param ~= 0 then
		sampSendChat('/siban ' .. param .. ' 30 Обман/Развод')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('obmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 30 Обман/Развод')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('nmb', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 Неадекватное поведение')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('nmbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 3 Неадекватное поведение')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('ch', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 7 читерский скрипт/ПО')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('chf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 7 читерский скрипт/ПО')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('obh', function(param)
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 7 Обход прошлого бана')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('oskhelper', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 Нарушение правил /helper')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
----======================= Исключительно для КИКОВ ===============------------------
sampRegisterChatCommand('cafk', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' AFK in /arena') 
		windows.recon_menu.v = false
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('kk1', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' Смените ник 1/3') 
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('kk2', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' Смените ник 2/3')
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('kk3', function(param)
	if #param ~= 0 then 
		sampSendChat('/ban ' .. param .. ' 7 Смените ник 3/3') 
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)
sampRegisterChatCommand('jk', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' DM in jail') 
	else
		sampAddChatMessage(tag .. 'Вы не указали значение.', -1)
	end
end)


function style(id) -- ТЕМЫ
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    if id == 0 then -- Темно-Синяя
		colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.00, 0.00, 0.00, 0.94)
		colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.26, 0.37, 0.98, 0.54)
		colors[clr.FrameBgHovered]       = ImVec4(0.33, 0.33, 0.93, 0.40)
		colors[clr.FrameBgActive]        = ImVec4(0.44, 0.44, 0.99, 0.67)
		colors[clr.TitleBg]              = ImVec4(0.30, 0.33, 0.95, 0.67)
		colors[clr.TitleBgActive]        = ImVec4(0.00, 0.16, 1.00, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.22, 0.19, 1.00, 0.67)
		colors[clr.MenuBarBg]            = ImVec4(0.39, 0.56, 1.00, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
		colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.30, 0.41, 0.99, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(0.52, 0.52, 0.97, 1.00)
		colors[clr.Button]               = ImVec4(0.11, 0.13, 0.93, 0.65)
		colors[clr.ButtonHovered]        = ImVec4(0.41, 0.57, 1.00, 0.65)
		colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
		colors[clr.Header]               = ImVec4(0.15, 0.19, 1.00, 0.54)
		colors[clr.HeaderHovered]        = ImVec4(0.03, 0.24, 0.57, 0.65)
		colors[clr.HeaderActive]         = ImVec4(0.36, 0.40, 0.95, 0.00)
		colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.SeparatorHovered]     = ImVec4(0.20, 0.42, 0.98, 0.54)
		colors[clr.SeparatorActive]      = ImVec4(0.20, 0.40, 0.93, 0.54)
		colors[clr.ResizeGrip]           = ImVec4(0.01, 0.17, 1.00, 0.54)
		colors[clr.ResizeGripHovered]    = ImVec4(0.21, 0.51, 0.98, 0.45)
		colors[clr.ResizeGripActive]     = ImVec4(0.04, 0.55, 0.95, 0.66)
		colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.CloseButtonHovered]   = ImVec4(0.10, 0.21, 0.98, 1.00)
		colors[clr.CloseButtonActive]    = ImVec4(0.02, 0.26, 1.00, 1.00)
		colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]     = ImVec4(0.18, 0.15, 1.00, 1.00)
		colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
		colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif id == 1 then -- Красная
		colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
		colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
		colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
		colors[clr.TitleBg]                = ImVec4(0.48, 0.16, 0.16, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.48, 0.16, 0.16, 1.00)
		colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.70)
		colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
		colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
		colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
		colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.Separator]              = colors[clr.Border]
		colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
		colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
		colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
		colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
		colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
		colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.ComboBg]                = colors[clr.PopupBg]
		colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
		colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif id == 2 then -- зеленая тема
		colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 1.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
		colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.60)
		colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 0.60)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
		colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
		colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
		colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
		colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
		colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
		colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
		colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
		colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
		colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
		colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
    elseif id == 3 then -- бирюзовая
        colors[clr.Text]                 = ImVec4(0.86, 0.93, 0.89, 0.78)
		colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
		colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
		colors[clr.ComboBg]                = colors[clr.PopupBg]
		colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
		colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.35)
		colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 0.50)
		colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 0.50)
		colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
		colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
		colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
		colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
		colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
		colors[clr.ResizeGrip]           = ImVec4(0.26, 0.59, 0.98, 0.25)
		colors[clr.ResizeGripHovered]    = ImVec4(0.26, 0.59, 0.98, 0.67)
		colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
	elseif id == 4 then -- Розовая тема
		colors[clr.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
		colors[clr.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
		colors[clr.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.Separator]              = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
		colors[clr.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
		colors[clr.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
		colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]                 = ImVec4(0.49, 0.14, 0.31, 1.00)
		colors[clr.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00)
		colors[clr.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
		colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif id == 5 then -- голубая тема
		colors[clr.Text]                   = ImVec4(2.00, 2.00, 2.00, 2.00)
		colors[clr.TextDisabled]           = ImVec4(0.28, 0.30, 0.35, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.16, 0.18, 0.22, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(0.19, 0.22, 0.26, 1)
		colors[clr.PopupBg]                = ImVec4(0.05, 0.05, 0.10, 0.90)
		colors[clr.Border]                 = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]                = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.22, 0.25, 0.30, 1.00)
		colors[clr.FrameBgActive]          = ImVec4(0.22, 0.25, 0.29, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.19, 0.22, 0.26, 0.59)
		colors[clr.MenuBarBg]              = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.20, 0.25, 0.30, 0.60)
		colors[clr.ScrollbarGrab]          = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.49, 0.63, 0.86, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.49, 0.63, 0.86, 1.00)
		colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
		colors[clr.CheckMark]              = ImVec4(0.90, 0.90, 0.90, 0.50)
		colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.30)
		colors[clr.SliderGrabActive]       = ImVec4(0.80, 0.50, 0.50, 1.00)
		colors[clr.Button]                 = ImVec4(0.41, 0.55, 0.78, 0.60)
		colors[clr.ButtonHovered]          = ImVec4(0.49, 0.62, 0.85, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.49, 0.62, 0.85, 1.00)
		colors[clr.Header]                 = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(0.22, 0.24, 0.28, 1.00)
		colors[clr.HeaderActive]           = ImVec4(0.22, 0.24, 0.28, 1.00)
		colors[clr.Separator]              = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.SeparatorHovered]       = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.SeparatorActive]        = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.ResizeGripHovered]      = ImVec4(0.49, 0.61, 0.83, 1.00)
		colors[clr.ResizeGripActive]       = ImVec4(0.49, 0.62, 0.83, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.CloseButtonHovered]     = ImVec4(0.50, 0.63, 0.84, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.16, 0.18, 0.22, 0.76)
	end
end
style(style_selected.v)
--------- ДЛЯ ID В КИЛЛ ЧАТЕ ----------- (НИЖЕ БОЛЬШЕ НИЧЕГО НЕТ.)
ffi.cdef[[
struct stKillEntry
{
char szKiller[25];
char szVictim[25];
uint32_t clKillerColor; // D3DCOLOR
uint32_t clVictimColor; // D3DCOLOR
uint8_t byteType;
} __attribute__ ((packed));

struct stKillInfo
{
int iEnabled;
struct stKillEntry killEntry[5];
int iLongestNickLength;
int iOffsetX;
int iOffsetY;
void *pD3DFont; // ID3DXFont
void *pWeaponFont1; // ID3DXFont
void *pWeaponFont2; // ID3DXFont
void *pSprite;
void *pD3DDevice;
int iAuxFontInited;
void *pAuxFont1; // ID3DXFont
void *pAuxFont2; // ID3DXFont
} __attribute__ ((packed));
]]
colours = {
"0x080808FF", "0xF5F5F5FF", "0x2A77A1FF", "0x840410FF", "0x263739FF", "0x86446EFF", "0xD78E10FF", "0x4C75B7FF", "0xBDBEC6FF", "0x5E7072FF",
"0x46597AFF", "0x656A79FF", "0x5D7E8DFF", "0x58595AFF", "0xD6DAD6FF", "0x9CA1A3FF", "0x335F3FFF", "0x730E1AFF", "0x7B0A2AFF", "0x9F9D94FF",
"0x3B4E78FF", "0x732E3EFF", "0x691E3BFF", "0x96918CFF", "0x515459FF", "0x3F3E45FF", "0xA5A9A7FF", "0x635C5AFF", "0x3D4A68FF", "0x979592FF",
"0x421F21FF", "0x5F272BFF", "0x8494ABFF", "0x767B7CFF", "0x646464FF", "0x5A5752FF", "0x252527FF", "0x2D3A35FF", "0x93A396FF", "0x6D7A88FF",
"0x221918FF", "0x6F675FFF", "0x7C1C2AFF", "0x5F0A15FF", "0x193826FF", "0x5D1B20FF", "0x9D9872FF", "0x7A7560FF", "0x989586FF", "0xADB0B0FF",
"0x848988FF", "0x304F45FF", "0x4D6268FF", "0x162248FF", "0x272F4BFF", "0x7D6256FF", "0x9EA4ABFF", "0x9C8D71FF", "0x6D1822FF", "0x4E6881FF",
"0x9C9C98FF", "0x917347FF", "0x661C26FF", "0x949D9FFF", "0xA4A7A5FF", "0x8E8C46FF", "0x341A1EFF", "0x6A7A8CFF", "0xAAAD8EFF", "0xAB988FFF",
"0x851F2EFF", "0x6F8297FF", "0x585853FF", "0x9AA790FF", "0x601A23FF", "0x20202CFF", "0xA4A096FF", "0xAA9D84FF", "0x78222BFF", "0x0E316DFF",
"0x722A3FFF", "0x7B715EFF", "0x741D28FF", "0x1E2E32FF", "0x4D322FFF", "0x7C1B44FF", "0x2E5B20FF", "0x395A83FF", "0x6D2837FF", "0xA7A28FFF",
"0xAFB1B1FF", "0x364155FF", "0x6D6C6EFF", "0x0F6A89FF", "0x204B6BFF", "0x2B3E57FF", "0x9B9F9DFF", "0x6C8495FF", "0x4D8495FF", "0xAE9B7FFF",
"0x406C8FFF", "0x1F253BFF", "0xAB9276FF", "0x134573FF", "0x96816CFF", "0x64686AFF", "0x105082FF", "0xA19983FF", "0x385694FF", "0x525661FF",
"0x7F6956FF", "0x8C929AFF", "0x596E87FF", "0x473532FF", "0x44624FFF", "0x730A27FF", "0x223457FF", "0x640D1BFF", "0xA3ADC6FF", "0x695853FF",
"0x9B8B80FF", "0x620B1CFF", "0x5B5D5EFF", "0x624428FF", "0x731827FF", "0x1B376DFF", "0xEC6AAEFF", "0x000000FF",
"0x177517FF", "0x210606FF", "0x125478FF", "0x452A0DFF", "0x571E1EFF", "0x010701FF", "0x25225AFF", "0x2C89AAFF", "0x8A4DBDFF", "0x35963AFF",
"0xB7B7B7FF", "0x464C8DFF", "0x84888CFF", "0x817867FF", "0x817A26FF", "0x6A506FFF", "0x583E6FFF", "0x8CB972FF", "0x824F78FF", "0x6D276AFF",
"0x1E1D13FF", "0x1E1306FF", "0x1F2518FF", "0x2C4531FF", "0x1E4C99FF", "0x2E5F43FF", "0x1E9948FF", "0x1E9999FF", "0x999976FF", "0x7C8499FF",
"0x992E1EFF", "0x2C1E08FF", "0x142407FF", "0x993E4DFF", "0x1E4C99FF", "0x198181FF", "0x1A292AFF", "0x16616FFF", "0x1B6687FF", "0x6C3F99FF",
"0x481A0EFF", "0x7A7399FF", "0x746D99FF", "0x53387EFF", "0x222407FF", "0x3E190CFF", "0x46210EFF", "0x991E1EFF", "0x8D4C8DFF", "0x805B80FF",
"0x7B3E7EFF", "0x3C1737FF", "0x733517FF", "0x781818FF", "0x83341AFF", "0x8E2F1CFF", "0x7E3E53FF", "0x7C6D7CFF", "0x020C02FF", "0x072407FF",
"0x163012FF", "0x16301BFF", "0x642B4FFF", "0x368452FF", "0x999590FF", "0x818D96FF", "0x99991EFF", "0x7F994CFF", "0x839292FF", "0x788222FF",
"0x2B3C99FF", "0x3A3A0BFF", "0x8A794EFF", "0x0E1F49FF", "0x15371CFF", "0x15273AFF", "0x375775FF", "0x060820FF", "0x071326FF", "0x20394BFF",
"0x2C5089FF", "0x15426CFF", "0x103250FF", "0x241663FF", "0x692015FF", "0x8C8D94FF", "0x516013FF", "0x090F02FF", "0x8C573AFF", "0x52888EFF",
"0x995C52FF", "0x99581EFF", "0x993A63FF", "0x998F4EFF", "0x99311EFF", "0x0D1842FF", "0x521E1EFF", "0x42420DFF", "0x4C991EFF", "0x082A1DFF",
"0x96821DFF", "0x197F19FF", "0x3B141FFF", "0x745217FF", "0x893F8DFF", "0x7E1A6CFF", "0x0B370BFF", "0x27450DFF", "0x071F24FF", "0x784573FF",
"0x8A653AFF", "0x732617FF", "0x319490FF", "0x56941DFF", "0x59163DFF", "0x1B8A2FFF", "0x38160BFF", "0x041804FF", "0x355D8EFF", "0x2E3F5BFF",
"0x561A28FF", "0x4E0E27FF", "0x706C67FF", "0x3B3E42FF", "0x2E2D33FF", "0x7B7E7DFF", "0x4A4442FF", "0x28344EFF"
}
