require 'lib.moonloader'
require 'lib.sampfuncs' 
script_name 'AdminTool'  
script_author 'Neon4ik' 
script_properties("work-in-pause") 
local version = 3.4 -- ������ ������� ������� ��������� ���� ��� ���������� �����
local function recode(u8) return encoding.UTF8:decode(u8) end -- ���������� ��� ���������������
------=================== ��������� ��������� ===================----------------------
local imgui = require 'imgui' 
local sampev = require 'lib.samp.events'
local imadd = require 'imgui_addons'
local mimgui = require "mimgui"
local inicfg = require 'inicfg'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local vkeys = require 'vkeys'
local ffi = require "ffi"
local mem = require "memory"
local font = require ("moonloader").font_flag
------=================== ��������� ��������� ===================----------------------
local AT_MP = pcall(script.load, "\\resource\\AT_MP.lua") -- ��������� ������� ��� �����������
local AT_FastSpawn = pcall(script.load, "\\resource\\AT_FastSpawn.lua")  -- ��������� �������� ������
local AT_Trassera = pcall(script.load, "\\resource\\AT_Trassera.lua") -- ��������� ���������
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local notify_report = import("\\resource\\lib_imgui_notf.lua") -- ������ �����������
local tag = '{2B6CC4}Admin Tools: {F0E68C}'
local sw, sh = getScreenResolution()
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
		mytextreport = ' // �������� ���� �� RDS <3',
		position_recon_menu_x = sw - 270,
		position_recon_menu_y = 0,
		keysync = true,
		wallhack = true,
		answer_player_report = false,
		bloknotik = '',
		admin_chat = true,
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
		position_ears_x = sw/2 - 400,
		position_ears_y = sh - 200,
		size_ears = 10,
		strok_ears = 6,
		keysyncx = sh/2 + 100,
		keysyncy = sw/2 + 20,
		on_color_report = false,
		color_report = nil,
		fast_key_ans = 'None',
		fast_key_addText = 'None',
		fast_key_wallhack = 'None',
		prefixma = '2E8B57',
		prefixa = '87CEEB',
		prefixsa = 'FF4500',
		autoprefix = true,
	},
	customotvet = {},
	osk = {'���', '�����', '����', '�����', '�����', '������', '�����', '������', '������'},
	mat = {'���', '���', '����', '����', '����', '�����'},
	myflood = {},
	my_command = {},
	binder_key = {},
}, 'AT//AT_main.ini')
inicfg.save(cfg, 'AT//AT_main.ini')
local windows = {
	menu_tools = imgui.ImBool(false),
	fast_report = imgui.ImBool(false),
	fast_rmute = imgui.ImBool(false),
	recon_menu = imgui.ImBool(false),
	menu_in_recon = imgui.ImBool(false),
	recon_ban_menu = imgui.ImBool(false),
	recon_mute_menu = imgui.ImBool(false),
	recon_jail_menu = imgui.ImBool(false),
	recon_kick_menu = imgui.ImBool(false),
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
	fast_key = imgui.ImBool(false),
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
	check_color_report = imgui.ImBool(cfg.settings.on_color_report),
	checked_radio_button = imgui.ImInt(1),
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
	new_binder_key = imgui.ImBuffer(2056),
}
local menu = {true, -- ����� ����
    false,
}
local menu2 = {true, -- �������� ����
    false,
	false,
	false,
	false,
	false,
	false,
}
local textdraw = {} -- ������ �� ���������� ��� �������������� � ����
local style_selected = imgui.ImInt(cfg.settings.style)
local style_list = {u8"�����-����� ����", u8"������� ����", u8"������� ����", u8"��������� ����", u8"������� ����", u8"������� ����"}
local selected_item = imgui.ImInt(cfg.settings.size_adminchat)
local font_adminchat = renderCreateFont("Calibri", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW)
local font_earschat = renderCreateFont("Calibri", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)
local admin_form = {}
local nakazatreport = {}
local answer = {}
local adminchat = {}
local ears = {}
local inforeport = {}
local pravila = {}
local spisok_in_form = { -- ������ ��� ��������
	'ban',
	'jail',
	'kick',
	'mute',
	'spawncars',
	'aspawn'
}
local spisokproject = { -- ������ �������� �� ������� ���� �������
	'������',
	'���� ����',
	'���� ����',
	'������',
	'������',
	'������',
	'���',
	'arz',
	'������',
	'������ ��'
}
local spisokoskrod = { -- ������ ���.��� �� ������� ���� �������
	'mq',
	'rnq'
}
local spisokrz = { -- ������ ���������� �������
	'����� ���',
	'����� ����',
}
local spisokor = { -- ������ ��������� �������� ����������� ����� (��� + ���-�� �� ����� ������, ��� ���-�� �� ������ � ���)
	'���',
	'����',
	'���',
	'��������',
	'mamy',
	'mama',
	'������',
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
	["�"] = "q", ["�"] = "w", ["�"] = "e", ["�"] = "r", ["�"] = "t", ["�"] = "y", ["�"] = "u", ["�"] = "i", ["�"] = "o", ["�"] = "p", ["�"] = "[", ["�"] = "]", ["�"] = "a",
	["�"] = "s", ["�"] = "d", ["�"] = "f", ["�"] = "g", ["�"] = "h", ["�"] = "j", ["�"] = "k", ["�"] = "l", ["�"] = ";", ["�"] = "'", ["�"] = "z", ["�"] = "x", ["�"] = "c", ["�"] = "v",
	["�"] = "b", ["�"] = "n", ["�"] = "m", ["�"] = ",", ["�"] = ".", ["�"] = "Q", ["�"] = "W", ["�"] = "E", ["�"] = "R", ["�"] = "T", ["�"] = "Y", ["�"] = "U", ["�"] = "I",
	["�"] = "O", ["�"] = "P", ["�"] = "{", ["�"] = "}", ["�"] = "A", ["�"] = "S", ["�"] = "D", ["�"] = "F", ["�"] = "G", ["�"] = "H", ["�"] = "J", ["�"] = "K", ["�"] = "L",
	["�"] = ":", ["�"] = "\"", ["�"] = "Z", ["�"] = "X", ["�"] = "C", ["�"] = "V", ["�"] = "B", ["�"] = "N", ["�"] = "M", ["�"] = "<", ["�"] = ">"
}
function sampev.onPlayerDeathNotification(killerId, killedId, reason) -------- ������� ID � ���� ����
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
function main() -- �������� �������� �������
	while not isSampAvailable() do wait(0) end
	while not sampIsLocalPlayerSpawned() do wait(1000) end
	local dlstatus = require('moonloader').download_status
    downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.ini", getWorkingDirectory() .. '//AdminTools.ini', function(id, status) end)
	local AdminTools = inicfg.load(nil, getWorkingDirectory() .. '//AdminTools.ini')
	if AdminTools then
		if AdminTools.script.version > version then
			update_state = true
			if AdminTools.script.main then
				sampAddChatMessage(tag .. '���������� ����� {808080}������������ {F0E68C}���������� �������! ��������� ��������������.', -1)
				update()
			else
				sampAddChatMessage(tag .. '���������� ����� ������ ��������� ������� - ' .. AdminTools.script.version, -1)
				sampAddChatMessage(tag .. '���������� ����� � ���� F3 (/tool) - �������� ������', -1)
			end
		end
		if cfg.settings.versionFS and cfg.settings.versionMP then
			if AdminTools.script.versionMP > cfg.settings.versionMP then
				update_state = true
				sampAddChatMessage(tag .. '���������� ���������� �������������� ��������.', -1)
				sampAddChatMessage(tag .. '���������� ����� � ���� F3 (/tool) - �������� ������', -1)
			end
			if AdminTools.script.versionFS > cfg.settings.versionFS then
				update_state = true
				sampAddChatMessage(tag .. '���������� ���������� �������������� ��������.', -1)
				sampAddChatMessage(tag .. '���������� ����� � ���� F3 (/tool) - �������� ������', -1)
			end
		else
			sampAddChatMessage(tag .. '�������������� ������ �� ����������! �������� �� ���� ������������, ��� �������������� ������.', -1)
		end
	end
	os.remove(getWorkingDirectory() .. "/AdminTools.ini" )
	local AdminTools = nil
	if sampGetCurrentServerAddress() == '46.174.52.246' then
		if not update_state then sampAddChatMessage(tag .. '������ ������� ��������. ��������� F3 ��� /tool', -1) end
	elseif sampGetCurrentServerAddress() == '46.174.49.170' then if not update_state then sampAddChatMessage(tag .. '������ ������� ��������. ��������� F3 ��� /tool', -1) end
		server03 = true
	else
		sampAddChatMessage(tag .. '� ������������ ��� RDS, ��� � ���� ��������.', -1)
		ScriptExport()
	end
	--------------------============ ������� � ������� =====================---------------------------------
	if not doesCharExist(getWorkingDirectory() .. "\\config\\AT\\rules.txt") then
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", getWorkingDirectory() .. "//config//AT//rules.txt", function(id, status)  end)
	end
	local rules = io.open(getWorkingDirectory() .. "\\config\\AT\\rules.txt","r")
	if rules then
		for line in rules:lines() do pravila[#pravila + 1] = u8:decode(line);end
		rules:close()
	end
	local rules = nil
	--------------------============ ����� ���� ��� ������ ���������� =====================---------------------------------
	lua_thread.create(inputChat)
	func = lua_thread.create_suspended(autoonline)
	funcadm = lua_thread.create_suspended(render_admins)
	func1 = lua_thread.create_suspended(render_adminchat)
	func4 = lua_thread.create_suspended(binder_key)
	func6 = lua_thread.create_suspended(HelperMA)
	if cfg.settings.forma_na_ban or cfg.settings.forma_na_mute or cfg.settings.forma_na_jail or cfg.settings.forma_na_mute then func6:run() end
	if cfg.settings.render_admins then funcadm:run() end
	if cfg.settings.wallhack then on_wallhack() end
	if cfg.settings.autoonline then func:run() end
	func1:run()
	func4:run()
	lua_thread.create(function()
		local font_watermark = renderCreateFont("Javanese Text", 8, font.BOLD + font.BORDER + font.SHADOW)
		while true do 
			wait(1)
			renderFontDrawText(font_watermark, tag .. '{A9A9A9}version['.. version .. ']', 10, sh-20, 0xCCFFFFFF)
		end	
	end)
	for k,v in pairs(cfg.my_command) do -- ����������� ������ ������������
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
	--mem.write(sampGetBase() + 643864, 37008, 2, true) ��� � ������
	while true do
        wait(0)
		if isPauseMenuActive() or isGamePaused() then
			AFK = true
		end
		if AFK and not (isPauseMenuActive() or isGamePaused()) then
			AFK = false
		end
		if isKeyJustPressed(0x54 --[[VK_T]]) and not windows.fast_report.v and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
			sampSetChatInputEnabled(true)
		end
		if isKeyJustPressed(VK_F3) and not sampIsDialogActive() then  -- ������ ��������� ����
			windows.menu_tools.v = not windows.menu_tools.v
			imgui.Process = true
			showCursor(true,false)
		end
		while admin_form.sett do
			wait(50)
			if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() then
				if sampIsPlayerConnected(admin_form.idadmin) then
					if not admin_form.styleform then
						wait(500)
						sampSendChat(admin_form.forma .. ' // ' .. sampGetPlayerNickname(admin_form.idadmin))
					else
						wait(500)
						sampSendChat(admin_form.forma)
					end
					wait(500)
					sampSendChat('/a AT - �������.')
				else
					sampAddChatMessage(tag .. '������������� �� � ����.', -1)
				end
				admin_form = {}
				break
			end
			if isKeyDown(VK_J) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampAddChatMessage(tag .. '����� ���������', -1)
				admin_form = {}
				break
			end
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
	end
end


function imgui.OnDrawFrame()
	if not windows.fast_key.v and not windows.render_admins.v and not windows.menu_tools.v and not windows.pravila.v and not windows.fast_report.v and not windows.recon_menu.v and not windows.help_young_admin.v and not windows.new_position_recon_menu.v and not windows.new_position_keylogger.v and not windows.new_position_adminchat.v and not windows.answer_player_report.v then
		showCursor(false,false)
		imgui.Process = false
		if cfg.settings.render_admins then
			sampSendChat('/admins')
		end
	end
	if windows.menu_tools.v then -- ������ ���������� F3
		windows.render_admins.v = false
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(420, 400), imgui.Cond.FirstUseEver)
		imgui.Begin('xX   ' .. " Admin Tools " .. '  Xx', windows.menu_tools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text('               ')
		imgui.SameLine()
		if imgui.Button(fa.ICON_ADDRESS_BOOK, imgui.ImVec2(30, 30)) then uu2() menu2[1] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_COGS, imgui.ImVec2(30, 30)) then uu2() menu2[3] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_PENCIL_SQUARE, imgui.ImVec2(30, 30)) then uu2() menu2[4] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_CALENDAR_CHECK_O, imgui.ImVec2(30, 30)) then uu2() menu2[5] = true end imgui.SameLine()
		--if imgui.Button(fa.ICON_SEARCH, imgui.ImVec2(30, 30)) then uu2() menu2[6] = true end imgui.SameLine()
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
			imgui.Text(u8'�������. �������')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##autoonline", checkbox.check_autoonline) then
				if cfg.settings.autoonline then
					cfg.settings.autoonline = not cfg.settings.autoonline
					save()
					func:terminate()
				else
					cfg.settings.autoonline = not cfg.settings.autoonline
					save()
					func:run()
				end
			end
			imgui.SameLine()
			imgui.Text(u8'����-������ �� ������')
			if imadd.ToggleButton("##input helper", checkbox.check_inputhelper) then
				cfg.settings.inputhelper = not cfg.settings.inputhelper
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'������� ������')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##WallHack", checkbox.check_WallHack) then
				if cfg.settings.wallhack then off_wallhack() else on_wallhack() end
			end
			imgui.SameLine()
			imgui.Text('WallHack')
			if imadd.ToggleButton("##AdminChat", checkbox.check_admin_chat) then
				if cfg.settings.admin_chat then adminchat = {} end
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
					checkbox.check_find_form = imgui.ImBool(cfg.settings.find_form)
				else
					cfg.settings.find_form  = not cfg.settings.find_form
				end
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'������ �� �������')
			if imadd.ToggleButton('##automute', checkbox.check_automute) then
				if cfg.settings.automute and cfg.settings.smart_automute then
					cfg.settings.smart_automute = false
					checkbox.check_smart_automute = imgui.ImBool(cfg.settings.smart_automute)
				end
				cfg.settings.automute  = not cfg.settings.automute
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'�������')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##NotifyPlayer", checkbox.check_answer_player_report) then
				if not cfg.settings.on_custom_recon_menu then
					sampAddChatMessage(tag .. '������ ������� �������� ������ � ������ ����� ����', -1)
					cfg.settings.answer_player_report = false
					checkbox.check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report)
				else
					cfg.settings.answer_player_report = not cfg.settings.answer_player_report
				end
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'����������� ������')
			if imadd.ToggleButton("##SmartAutomute", checkbox.check_smart_automute) then
				if not cfg.settings.automute then
					cfg.settings.automute  = not cfg.settings.automute
					checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
				end
				cfg.settings.smart_automute = not cfg.settings.smart_automute
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'����� �������')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##NotifyReport", checkbox.check_notify_report) then
				cfg.settings.notify_report = not cfg.settings.notify_report
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'����������� � �������')
			if imadd.ToggleButton(u8"##TriggerWarning", checkbox.check_find_weapon_hack) then
				cfg.settings.find_warning_weapon_hack = not cfg.settings.find_warning_weapon_hack
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'������� �� ��������')
			imgui.SameLine()
			imgui.SetCursorPosX(200)
			if imadd.ToggleButton("##render/admins", checkbox.check_render_admins) then
				if cfg.settings.render_admins then
					cfg.settings.render_admins = not cfg.settings.render_admins
					admins = {}
					windows.render_admins.v = false
					funcadm:terminate()
				else
					cfg.settings.render_admins = not cfg.settings.render_admins
					funcadm:run()
				end
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'������ /admins')
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
			imgui.Text(u8'������ ����� ����')
			imgui.SameLine()
			if imadd.ToggleButton("##FastReport", checkbox.check_on_custom_answer) then
				cfg.settings.on_custom_answer = not cfg.settings.on_custom_answer
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'������ ����� �� ������')
			if imadd.ToggleButton("##renderEars", checkbox.check_render_ears) then
				if cfg.settings.render_ears then ears = {} end
				sampSendChat('/ears')
			end
			imgui.SameLine()
			imgui.Text(u8'������ /ears')
			imgui.Text('\n')
			imgui.Separator()
			imgui.Text(u8'����������� ������� - N.E.O.N [RDS 01].\n�������� ����� ����\n')
			imgui.Text('VK:')
			imgui.SameLine()
			if imgui.Link("https://vk.com/alexandrkob", u8"�����, ����� ������� ������ � ��������") then
				os.execute(('explorer.exe "%s"'):format("https://vk.com/alexandrkob"))
			end
			imgui.Text(u8'������ � VK:')
			imgui.SameLine()
			if imgui.Link("https://vk.com/club222702914", u8"�����, ����� ������� ������ � ��������") then
				os.execute(('explorer.exe "%s"'):format("https://vk.com/club222702914"))
			end
		end
		if menu2[3] then
			imgui.SetCursorPosX(8)
			if imgui.Button(u8'�������������� �������� ����', imgui.ImVec2(410, 24)) and not server03 then
				windows.menu_tools.v = false
				windows.help_young_admin.v = not windows.help_young_admin.v
			end
			if imgui.Button(u8'������� ��������� ������', imgui.ImVec2(410, 24)) then
				windows.menu_tools.v = false
				sampSendInputChat('/fs')
			end
			if imgui.Button(u8'������� ��������� ���������', imgui.ImVec2(410, 24)) then
				windows.menu_tools.v = false
				sampSendInputChat('/trassera')
			end
			if imgui.Button(u8'������� ��������� �����-����������', imgui.ImVec2(410, 24)) then
				sampSendInputChat('/state')
				windows.menu_tools.v = false
				showCursor(true,false)
			end
			imgui.CenterText(u8'�������������� ����� ������')
			imgui.PushItemWidth(410)
			if imgui.InputText('##doptextcommand', buffer.add_new_text) then
				cfg.settings.mytextreport = u8:decode(buffer.add_new_text.v)
				save()	
			end
			imgui.PopItemWidth()
			if imgui.Button(u8'��������� ������� Recon Menu', imgui.ImVec2(410, 24)) then
				if windows.recon_menu.v then
					windows.recon_menu.v = not windows.recon_menu.v
					windows.new_position_recon_menu.v = not windows.new_position_recon_menu.v
				else
					sampAddChatMessage(tag .. '������� � ������ �� ��������� ����������', -1)
				end
			end
			if cfg.settings.render_admins then
				if imgui.Button(u8'��������� ������� ������� /admins', imgui.ImVec2(410, 24)) then
					windows.new_position_render_admins.v = true
				end
			end
			if cfg.settings.admin_chat then
				if imgui.Button(u8'��������� ������� �������� ������', imgui.ImVec2(410, 24)) then
					windows.new_position_adminchat.v = not windows.new_position_adminchat.v
				end
			end
			if cfg.settings.keysync then
				if imgui.Button(u8'��������� ������� ����.������', imgui.ImVec2(410, 24)) then
					windows.new_position_keylogger.v = not windows.new_position_keylogger.v 
				end
			end
			if imgui.Button(u8'�������� ������', imgui.ImVec2(410, 24)) then
				if update_state then update()
				else sampAddChatMessage(tag .. '� ��� ����������� ���������� ������ AT.', -1) end
			end
			if imgui.Button(u8'��������� ������ ' .. fa.ICON_POWER_OFF, imgui.ImVec2(410, 24)) then
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
			if getDownKeysText() then imgui.CenterText(u8'������ �������: ' .. getDownKeysText())
			else imgui.CenterText(u8'��� ������� ������') end
			imgui.NewInputText('##SearchBar7', buffer.new_binder_key, 400, u8'����� �������', 2)
			if imgui.Button(u8'��������', imgui.ImVec2(200,24)) and #u8:decode(buffer.new_binder_key.v) ~= 0 then
				if getDownKeysText() then
					cfg.binder_key[getDownKeysText()] = u8:decode(buffer.new_binder_key.v)
					save()
				else
					sampAddChatMessage(tag .. '������� �������, �� ������� ������ ��������� ������', -1)
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'�������', imgui.ImVec2(200,24)) and #u8:decode(buffer.new_binder_key.v) ~= 0 then
				for k,v in pairs(cfg.binder_key) do
					if u8:decode(buffer.new_binder_key.v) == v then
						cfg.binder_key[k] = nil
						save()
						sampAddChatMessage(tag .. '������ ������.', -1)
					end
				end 
			end
			imgui.Separator()
			imgui.CenterText(u8'�������� �������:')
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_ans))
			if imgui.Button(u8"�ox�a����.", imgui.ImVec2(200, 24)) then
				if getDownKeysText() and not getDownKeysText():find('+') then
					cfg.settings.fast_key_ans = getDownKeysText()
					save()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'��������', imgui.ImVec2(200,24)) then
				cfg.settings.fast_key_ans = 'None'
				save()
			end
			imgui.CenterText(u8"�������� � ��� ���.������")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_addText))
			if imgui.Button(u8"Cox�a����.", imgui.ImVec2(200, 24)) then
				if getDownKeysText() and not getDownKeysText():find('+') then
					cfg.settings.fast_key_addText = getDownKeysText()
					save()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'��������', imgui.ImVec2(200,24)) then
				cfg.settings.fast_key_addText = 'None'
				save()
			end
			imgui.CenterText(u8"���/���� WallHack")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_wallhack))
			if imgui.Button(u8"Cox�a����.", imgui.ImVec2(200, 24)) then
				if getDownKeysText() and not getDownKeysText():find('+') then
					cfg.settings.fast_key_wallhack = getDownKeysText()
					save()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'��������', imgui.ImVec2(200,24)) then
				cfg.settings.fast_key_wallhack = 'None'
				save()
			end
			imgui.Separator()
			imgui.CenterText(u8'[��� ������� �������]')
			for k, v in pairs(cfg.binder_key) do
				imgui.Text(u8('[������� '..k..'] ='))
				imgui.SameLine()
				imgui.Text(u8(v))
			end
			if imgui.Button(u8"�������� ��� ��������.", imgui.ImVec2(410, 24)) then
				for k,v in pairs(cfg.binder_key) do cfg.binder_key[k] = nil end
				save()
			end
		end
		if menu2[7] then
			imgui.SetCursorPosX(8)
			if imgui.Button(u8'��� �����', imgui.ImVec2(410, 25)) then
				windows.new_flood_mess.v = not windows.new_flood_mess.v 
			end
			imgui.CenterText(u8'����� �� /gw')
			if imgui.Button(u8'Aztecas vs Ballas', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					wait(500)
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Ballas Gang ##')
					wait(500)
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Aztecas vs Grove', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					wait(500)
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Grove Street Gang ##')
					wait(500)
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Aztecas vs Vagos', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					wait(500)
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Vagos Gang ##')
					wait(500)
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			if imgui.Button(u8'Aztecas vs Rifa', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					wait(500)
					sampSendChat('/mess 14 ## Varios Los Aztecas vs The Rifa ##')
					wait(500)
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Ballas vs Grove', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					wait(500)
					sampSendChat('/mess 14 ## Ballas Gang vs Grove Street Gang ##')
					wait(500)
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Ballas vs Vagos', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					wait(500)
					sampSendChat('/mess 14 ## Ballas Gang vs Vagos Gang ##')
					wait(500)
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			if imgui.Button(u8'Ballas vs Rifa', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					wait(500)
					sampSendChat('/mess 14 ## Ballas Gang vs The Rifa ##')
					wait(500)
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Grove vs Vagos', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					wait(500)
					sampSendChat('/mess 14 ## Grove Street Gang vs Vagos Gang ##')
					wait(500)
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Vagos vs Rifa', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					wait(500)
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					wait(500)
					sampSendChat('/mess 14 ## Vagos Gang vs The Rifa ##')
					wait(500)
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					wait(500)
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end)
			end
			imgui.CenterText(u8'����� �����')
			if imgui.Button(u8'����� ����', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 10 --------===================| Spawn Auto |================-----------')
					wait(500)
					sampSendChat('/mess 15 �������������� �������� � ���������')
					wait(500)
					sampSendChat('/mess 15 ����� 15 ������ ������ ������� ����� ���������� �� �������.')
					wait(500)
					sampSendChat('/mess 15 ������� ���� ����� ���� �� ��������� ������ :3')
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
					sampSendChat('/mess 3 --------===================| ����� |================-----------')
					wait(500)
					sampSendChat('/mess 0 ������ ���������� ����������� �� ���� ����?')
					wait(500)
					sampSendChat('/mess 0 ������ � ������ ������������ �� ����� � �������� ��� ��������?')
					wait(500)
					sampSendChat('/mess 0 ������ ����� /trade, ������� ����� ������������, ��� �� �������, ��� � �� �������!')
					wait(500)
					sampSendChat('/mess 3 --------===================| ����� |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'��������������', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 16 --------===================| �������������� |================-----------')
					wait(500)
					sampSendChat('/mess 17 ������ ������ ���������� ���� �� ���� ���������? �� ��������!')
					wait(500)
					sampSendChat('/mess 17 � �������������� �� /tp - ������ - �������������� �������� � �� �����.')
					wait(500)
					sampSendChat('/mess 17 ������ ������� ������ ��������� ��� ���� ���� � ����')
					wait(500)
					sampSendChat('/mess 16 --------===================| �������������� |================-----------')
				end)
			end
			if imgui.Button(u8'������/�����', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 11 --------===================| ��������� �������� |================-----------')
					wait(500)
					sampSendChat('/mess 7 � ������ ������� ������� ������ vk.�om/teamadmrds ...')
					wait(500)
					sampSendChat('/mess 7 ... � ���� �����, �� ������� ������ ����� �������� ������ �� ������������� ��� �������.')
					wait(500)
					sampSendChat('/mess 7 ����� �� ��������� � ���� ������ �������.')
					wait(500)
					sampSendChat('/mess 11 --------===================| ��������� �������� |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'VIP', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 13 --------===================| ������������ VIP |================-----------')
					wait(500)
					sampSendChat('/mess 7 ������ ������ � �������� ��� �����������?')
					wait(500)
					sampSendChat('/mess 7 ������ ������ ����������������� �� ����� � � �������, ����� ���� ������ ������?')
					wait(500)
					sampSendChat('/mess 7 ������ �������� ������ PayDay ������ �� ���� �������? ���������� VIP-��������!')
					wait(500)
					sampSendChat('/mess 13 --------===================| ������������ VIP |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'�����', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 12 --------===================| PVP Arena |================-----------')
					wait(500)
					sampSendChat('/mess 10 �� ������ ��� ��������? ������� ������ � ������� �������?')
					wait(500)
					sampSendChat('/mess 10 ����� /arena � ������ �� ��� �� ��������!')
					wait(500)
					sampSendChat('/mess 10 ����� ������������ ���������� ������, ������� ������ � ����� +C')
					wait(500)
					sampSendChat('/mess 12 --------===================| PVP Arena |================-----------')
				end)
			end
			if imgui.Button(u8'����������� ���', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ���� ����������� ��� |================-----------')
					wait(500)
					sampSendChat('/mess 15 ������ ������? ��������� ���������� ����� � �������?')
					wait(500)
					sampSendChat('/mess 15 ������� ������ ����� �� ������� �� ����� ������?')
					wait(500)
					sampSendChat('/mess 15 ����� ����! ����� /dt [0-999] � ������ � ���������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ���� ����������� ��� |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'����� �� �������', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 3 --------===================| ����� �� ���� �������������� |================-----------')
					wait(500)
					sampSendChat('/mess 2 ������ ������ �� ���� ��������������? ������� ������ �� ������� � �����������?')
					wait(500)
					sampSendChat('/mess 2 �� ��� �������� � ���������� ��������� <3')
					wait(500)
					sampSendChat('/mess 2 �� ����� ������ https://forumrds.ru/ ������ �����, ����� ������ ������, ���-�� ���� ����������.')
					wait(500)
					sampSendChat('/mess 3 --------===================| ����� �� ���� �������������� |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'� /report', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 17 --------===================| ����� � �������������� |================-----------')
					wait(500)
					sampSendChat('/mess 13 ����� ������, ��������� ����������, �����, ��� ������ ������ ������?')
					wait(500)
					sampSendChat('/mess 13 �������� ������ � ������������ ������� ��� ��� ������������?')
					wait(500)
					sampSendChat('/mess 13 ������������� �������! ���� /report � ���� ������/������')
					wait(500)
					sampSendChat('/mess 17 --------===================| ����� � �������������� |================-----------')
				end)
			end
			imgui.CenterText(u8'����������� /join')
			if imgui.Button(u8'�����', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ����������� ����� |================-----------')
					wait(500)
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� �����')
					wait(500)
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 1')
					wait(500)
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ����������� ����� |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'������', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ����������� /parkour |================-----------')
					wait(500)
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ������')
					wait(500)
					sampSendChat('/mess 0 ����� ������� ������� ����� /parkour ���� /join - 2')
					wait(500)
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ����������� /parkour |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'PUBG', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ����������� /pubg |================-----------')
					wait(500)
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� Pubg')
					wait(500)
					sampSendChat('/mess 0 ����� ������� ������� ����� /pubg ���� /join - 3')
					wait(500)
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ����������� /pubg |================-----------')
				end)
			end
			if imgui.Button(u8'DAMAGE DEATHMATCH', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ����������� /damagegm |================-----------')
					wait(500)
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� DAMAGE DEATHMATCH')
					wait(500)
					sampSendChat('/mess 0 ����� ������� ������� ����� /damagegm ���� /join - 4')
					wait(500)
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ����������� /damagegm |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'KILL DEATHMATCH', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ����������� KILL DEATHMATCH |================-----------')
					wait(500)
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� DAMAGE DEATHMATCH')
					wait(500)
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 5')
					wait(500)
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ����������� KILL DEATHMATCH |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'Paint Ball', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ����������� Paint Ball |================-----------')
					wait(500)
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� Paint Ball')
					wait(500)
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 7')
					wait(500)
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ����������� Paint Ball |================-----------')
				end)
			end
			if imgui.Button(u8'����� vs �����', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ����� ������ ����� |================-----------')
					wait(500)
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ����� ������ �����')
					wait(500)
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 8')
					wait(500)
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ����� ������ ����� |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'������', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ����������� ������ |================-----------')
					wait(500)
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ������')
					wait(500)
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 10')
					wait(500)
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ����������� ������ |================-----------')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'���������', imgui.ImVec2(130, 25)) then
				lua_thread.create(function()
					sampSendChat('/mess 8 --------===================| ����������� ��������� |================-----------')
					wait(500)
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ���������')
					wait(500)
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 11')
					wait(500)
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					wait(500)
					sampSendChat('/mess 8 --------===================| ����������� ��������� |================-----------')
				end)
			end
		end
		if menu2[2] then
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'�������� ���� �����', imgui.ImVec2(410, 24)) and #buffer.custom_answer.v~=0 then
				key = #cfg.customotvet + 1
				cfg.customotvet[key] = u8:decode(buffer.custom_answer.v)
				save()
				buffer.custom_answer.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.NewInputText('##SearchBar2', buffer.custom_answer, 410, u8'������� ��� �����.', 2)
			imgui.Separator()
			imgui.CenterText(u8'����������� ������')
			for k,v in pairs(cfg.customotvet) do
				if imgui.Button(u8(v), imgui.ImVec2(405, 24)) then
					cfg.customotvet[k] = nil
					cfg.customotvet[v] = nil
					save()
				end
			end
		end
		--if menu2[6] then
		--end
		if menu2[8] then
			imgui.CenterText(u8'�������� ��� (Enter ��� �������)')
			imgui.SameLine()
			imgui.Text('(?)')
			imgui.Tooltip(u8'������� �������� �� �������� �����(����������).\n���� ��� ���� ������ ������������� �� ����� �����\n���������� � ����� ������ ��� ������� %s')
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
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. buffer.newmat.v .. ' {F0E68C}��� ������� � ������ �����.', -1)
						a = true
						break
					else    
						a = false
					end
				end
				if not a then
					cfg.mat[#cfg.mat + 1] = buffer.newmat.v
					save()
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. buffer.newmat.v .. ' {F0E68C}���� ������� ��������� � ������ �����.', -1)
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
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ��������� ���� �����{008000} ' .. buffer.newmat.v .. ' {F0E68C}���� ������� ������� �� ������ �����', -1)
						a = true
						break
					else    
						a = false
					end
				end
				if not a then
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ������ ����� � ������ ����� ���.', -1)
					a = nil
				end
				buffer.newmat.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.CenterText(u8'�������� ����������� (Enter ��� �������)')
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
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. buffer.newosk.v .. ' {F0E68C}��� ������� � ������ �����������.' , -1)
						a = true
						break
					else    
						a = false
					end
				end
				if not a then
					cfg.osk[#cfg.osk + 1] = buffer.newosk.v
					save()
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. buffer.newosk.v .. ' {F0E68C}���� ������� ��������� � ������ �����������', -1)
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
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ��������� ���� �����{008000} ' .. buffer.newosk.v .. ' {F0E68C}���� ������� ������� �� ������', -1)
						a = true
						break
					else    
						a = false
					end
				end
				if not a then
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ������ ����� � ������ ����������� ���.', -1)
					a = nil
				end
				buffer.newosk.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.CenterText(u8'�������� ���� ����������')
			imgui.PushItemWidth(400)
			if imgui.Combo("##selected", style_selected, style_list, style_selected) then
				style(style_selected.v) -- ��������� ����� �� ��������� �����
				cfg.settings.style = style_selected.v 
				save()
				sampAddChatMessage(tag ..'��������� ������������ ��� ������������ RGB ������...', -1)
				reloadScripts()
			end
			imgui.PopItemWidth()
			imgui.CenterText(u8'�������� ������� �������')
			imgui.SameLine()
			imgui.Text('(?)')
			imgui.Tooltip(u8'������ "_" ��� ������� ��������� ��������� ��������\n������� wait ��������� ��������, ������: wait(5) (��� 5 ���)\n������: /mute _ 400 �����������')
			imgui.NewInputText('##titlecommand5', buffer.new_command_title, 400, u8'������� (������: /ok, /dz, /ch)', 2)
			imgui.InputTextMultiline("##newcommand", buffer.new_command, imgui.ImVec2(400, 100))
			if imgui.Button(u8'����a����', imgui.ImVec2(200, 24)) then
				if #(u8:decode(buffer.new_command_title.v)) ~= 0 and #(u8:decode(buffer.new_command.v)) > 2 then
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
							sampAddChatMessage(tag .. '����� ������� /' .. buffer.new_command_title.v .. ' ������� �������.',-1)
							buffer.new_command.v, buffer.new_command_title.v = '',''
						end
					end
				else
					sampAddChatMessage(tag .. '��� �� ��������� ���������?', -1)
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'�������', imgui.ImVec2(190, 24)) then
				if #(buffer.new_command_title.v) == 0 then
					sampAddChatMessage(tag ..'�� �� ������� �������� �������, ��� �� ��������� �������?', -1)
				else
					buffer.new_command_title.v = string.gsub(u8:decode(buffer.new_command_title.v), '/', '')
					if cfg.my_command[buffer.new_command_title.v] then
						cfg.my_command[buffer.new_command_title.v] = nil
						sampAddChatMessage(tag .. '������� ���� ������� �������. ���������� ����������� ����� ������������ ����.', -1)
					else
						sampAddChatMessage(tag .. '����� ������� � ���� ������ ���.', -1)
					end
				end
			end
		end
		imgui.PopFont()
 		imgui.End()
	end
	if windows.fast_report.v then -- ������� ����� �� ������
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5) - 250, (sh * 0.5)-90), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'����� �� ������', windows.fast_report, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8'�����: ' .. autor .. '[' ..autorid.. ']')
		imgui.TextWrapped(u8('������: ' .. textreport))
		if isKeyJustPressed(VK_SPACE) then
			imgui.SetKeyboardFocusHere(-1)
		end
		imgui.NewInputText('##SearchBar', buffer.text_ans, 375, u8'������� ��� �����.', 2)
		imgui.SameLine()
		imgui.SetCursorPosX(392)
		imgui.Tooltip('Space')
		if imgui.Button(u8'��������� ' .. fa.ICON_SHARE, imgui.ImVec2(120, 25)) then
			if #(u8:decode(buffer.text_ans.v)) ~= 0 then
				answer.moiotvet = true
			else 
				sampAddChatMessage(tag .. '����� �� ����� 1 �������.', -1)
			end
		end
		imgui.Tooltip('Enter')
		imgui.Separator()
		if imgui.Button(u8'�������', imgui.ImVec2(120, 25)) or isKeyDown(VK_Q) then
			answer.rabotay = true
		end
		imgui.Tooltip('Q')
		imgui.SameLine()
		if imgui.Button(u8'�����', imgui.ImVec2(120, 25)) or isKeyDown(VK_E) then
			answer.slejy = true
		end
		imgui.Tooltip('E')
		imgui.SameLine()
		if imgui.Button(u8'������ �����', imgui.ImVec2(120, 25)) or isKeyDown(VK_R) then
			windows.custom_ans.v = not windows.custom_ans.v
		end
		imgui.Tooltip('R')
		imgui.SameLine()
		if imgui.Button(u8'��������', imgui.ImVec2(120, 25)) or isKeyDown(VK_V) then
			answer.peredamrep = true
		end
		imgui.Tooltip('V')
		if imgui.Button(u8'��������', imgui.ImVec2(120, 25)) or isKeyJustPressed(VK_G) then
			if tonumber(autorid) then
				windows.fast_rmute.v = not windows.fast_rmute.v
			else
				sampAddChatMessage(tag .. '������ ����� �� � ����. ����������� /rmuteoff', -1)
			end
		end
		imgui.Tooltip('G')
		imgui.SameLine()
		if imgui.Button(u8'�������� ID', imgui.ImVec2(120, 25)) or isKeyDown(VK_V) then
			answer.uto4id = true
		end
		imgui.Tooltip('V')
		imgui.SameLine()
		if imgui.Button(u8'�����', imgui.ImVec2(120, 25)) or isKeyDown(VK_F) then
			answer.uto4 = true
		end
		imgui.Tooltip('F')
		imgui.SameLine()
		if imgui.Button(u8'���������', imgui.ImVec2(120, 25)) or isKeyDown(VK_Y) then
			answer.otklon = true
		end
		imgui.Tooltip('Y')
		imgui.Separator()
		if imadd.ToggleButton('##doptextans' .. fa.ICON_COMMENTING_O, checkbox.check_add_answer_report) then
			cfg.settings.add_answer_report = not cfg.settings.add_answer_report
			save()
		end
		imgui.SameLine()
		imgui.Text(u8'�������� �������������� ����� � ������')
		if imadd.ToggleButton('##saveans' .. fa.ICON_DATABASE, checkbox.check_save_answer) then
			cfg.settings.custom_answer_save = not cfg.settings.custom_answer_save
			save()
		end
		imgui.Tooltip(u8'��������� ��� ����� � ������. �� ���������, ���� ���-�� �������� � ������ �������� ��������')
		imgui.SameLine()
		imgui.Text(u8'��������� ������ ����� � ���� ������ �������')
		if imadd.ToggleButton('##newcolor', checkbox.check_color_report) then
			if cfg.settings.color_report then
				cfg.settings.on_color_report = not cfg.settings.on_color_report
				save()
			else
				checkbox.check_color_report = imgui.ImBool(cfg.settings.on_color_report)
				sampAddChatMessage(tag .. '���� �� ������. ��������� ��������� ���� HTML ���� ����� ������� /color_report', -1)
				sampAddChatMessage(tag .. '������������� ������� �������� �� ������.',-1)
			end
		end
		imgui.Tooltip(u8'��������� ������� � ������. �� ���������, ���� ���-�� �������� � ������ �������� ��������')
		imgui.SameLine()
		imgui.Text(u8'����������� ���� ����� � ������ ����')
		imgui.PopFont()
		imgui.End()
	end
	if windows.recon_ban_menu.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ���������� ��������", windows.recon_ban_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if imgui.Button(u8'����', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/ch ' .. control_player_recon)
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'�������������� ��������� (3)', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/iban ' .. control_player_recon .. ' 3 ������������ ���������')
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'��������� ������ �������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/oskhelper ' .. control_player_recon)
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'����������� �������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/bosk ' .. control_player_recon)
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'�������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/reklama ' .. control_player_recon)
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'�����', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/obm ' .. control_player_recon)
			windows.recon_ban_menu.v = false
		end
		if imgui.Button(u8'�������� �����', imgui.ImVec2(250, 25)) then
			sampSendChat('/ban ' .. control_player_recon .. ' 7 �������� �����')
			windows.recon_ban_menu.v = false
		end
		imgui.End()
	end
	if windows.recon_jail_menu.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"�������� ������ � ������", windows.recon_jail_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if imgui.Button(u8'DM/DB in ZZ', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/dz ' .. control_player_recon)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8"��������������� VIP'��", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/zv ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'Spawn Kill', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/sk ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'Car in trade/ZZ', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/td ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'���', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/jcb ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'��� ����������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/jc ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		if imgui.Button(u8'�� ���� � ������� ����', imgui.ImVec2(250, 25)) then
			sampSendChat('/jail ' .. control_player_recon .. ' �� ���� � ������� ����')
			showCursor(false,false)
			windows.recon_jail_menu.v = false
		end
		imgui.End()
	end
	if windows.recon_mute_menu.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������������� ��� ������", windows.recon_mute_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if imgui.Button(u8'�����������/��������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/ok ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8"���", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/m ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8"����", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/fd ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'����������������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/po ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'�����������/���������� ������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/or ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'����������� �������������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/oa ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'������� �� �������������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/kl ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'��������������� ���������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/zs ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'������ ���� �� ��������������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/ia ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		if imgui.Button(u8'���������� ��������� ��������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/up ' .. control_player_recon)
			showCursor(false,false)
			windows.recon_mute_menu.v = false
		end
		imgui.End()
	end
	if windows.recon_kick_menu.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������� ������ � �������", windows.recon_kick_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if imgui.Button(u8'AFK /arena', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/cafk ' .. control_player_recon)
			windows.recon_menu.v = false
		end
		if imgui.Button(u8"Nick 1/3", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/kk1 ' .. control_player_recon)
			windows.recon_menu.v = false
		end
		if imgui.Button(u8"Nick 2/3", imgui.ImVec2(250, 25)) then
			sampSendInputChat('/kk2 ' .. control_player_recon)
			windows.recon_menu.v = false
		end
		if imgui.Button(u8'Nick 3/3', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/kk3 ' .. control_player_recon)
			windows.recon_menu.v = false
		end
		imgui.End()
	end
	if windows.recon_menu.v and not sampIsPlayerConnected(control_player_recon) then windows.recon_menu.v = false windows.menu_in_recon.v = false end
	if windows.recon_menu.v then -- ������ ����� ����
		windows.render_admins.v = false
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y))
		imgui.Begin("##recon", windows.recon_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.ShowCursor = false
		imgui.PushFont(fontsize)
		if imgui.Button(u8'����� ' ..fa.ICON_MALE, imgui.ImVec2(120, 25)) then uu() menu[1] = true end imgui.SameLine()
        if imgui.Button(u8'� ������� ' .. fa.ICON_USERS, imgui.ImVec2(120, 25)) then uu() menu[2] = true end 
        if menu[1] then
			imgui.SetCursorPosX(10)
			if imgui.Button(fa.ICON_FILES_O) then
				setClipboardText(sampGetPlayerNickname(control_player_recon))
				sampAddChatMessage(tag .. '��� ���������� � ������ ������.', -1)
			end
			imgui.SameLine()
			imgui.Text(sampGetPlayerNickname(control_player_recon) .. '[' .. control_player_recon .. ']')
			imgui.SameLine()
			imgui.SetCursorPosX(230)
			if mobile_player then imgui.Text(fa.ICON_MOBILE)
			else imgui.Text(fa.ICON_DESKTOP) end
			imgui.Separator()
			for i = 4, #inforeport do
				if i == 4 then imgui.Text(u8'�������� ����: ' .. inforeport[i])
				elseif i == 5 then imgui.Text(u8'��������: ' .. inforeport[i])
				elseif i == 7 then imgui.Text(u8'������: ' .. inforeport[i])
				elseif i == 8 then imgui.Text(u8'��������: ' .. inforeport[i])
				elseif i == 6 then imgui.Text('Ping: ' .. inforeport[i])
				elseif i == 10 then imgui.Text('AFK: ' .. inforeport[i])
				elseif i == 12 then imgui.Text('VIP: ' .. inforeport[i])
				elseif i == 13 then imgui.Text('Passive mode: ' .. inforeport[i])
				elseif i == 14 then imgui.Text(u8'����� �����: ' .. inforeport[i])
				elseif i == 15 then imgui.Text(u8'��������: ' .. inforeport[i]) end
			end
			if imgui.Button(u8'���������� ������ ����������', imgui.ImVec2(250, 25)) then
				sampAddChatMessage(tag .. '� ��� ������ ������, �������� ���.', -1)
			end
			if imgui.Button(u8'���������� ������ ����������', imgui.ImVec2(250, 25)) then
				sampSendClickTextdraw(textdraw.stats)
			end
			if imgui.Button(u8'���������� /offstats ����������', imgui.ImVec2(250, 25)) then
				sampSendChat('/offstats ' .. sampGetPlayerNickname(control_player_recon))
				sampSendDialogResponse(16196, 1, 0)
			end
			if isKeyJustPressed(VK_R) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(textdraw.refresh)
				if cfg.settings.keysync then
					lua_thread.create(function()
						wait(1000)
						while sampIsDialogActive() or sampIsChatInputActive() do wait(0) end
						sampSendInputChat('/keysync ' .. control_player_recon)
					end)
				end
			end
			if isKeyJustPressed(VK_Q) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(textdraw.close)
				windows.menu_in_recon.v = false
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
			for _,v in pairs(playersToStreamZone()) do
				if v ~= control_player_recon then
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
	if windows.menu_in_recon.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowPos(imgui.ImVec2((sw*0.5)-300, sh-60))
		imgui.Begin("##recon+", windows.menu_in_recon, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Button(u8'<- ����������') then
			lua_thread.create(function()
				if control_player_recon < sampGetMaxPlayerId() then
					control_player_recon = control_player_recon - 1
					sampSendChat('/re ' .. control_player_recon)
					while not sampIsPlayerConnected(control_player_recon) do wait(0) end
				end
			end)
		end
		imgui.Tooltip(u8'NumPad 4')
		imgui.SameLine()
		if imgui.Button(u8'�������� ������') then
			windows.recon_ban_menu.v = not windows.recon_ban_menu.v
		end
		imgui.SameLine()
		if imgui.Button(u8'�������� � ������') then
			windows.recon_jail_menu.v = not windows.recon_jail_menu.v
		end
		imgui.SameLine()
		if imgui.Button(u8'������ ���') then
			windows.recon_mute_menu.v = not windows.recon_mute_menu.v
		end
		imgui.SameLine()
		if imgui.Button(u8'������� ������') then
			windows.recon_kick_menu.v = not windows.recon_kick_menu.v
		end
		imgui.SameLine()
		if imgui.Button(u8'��������� ->') then
			lua_thread.create(function()
				if control_player_recon < sampGetMaxPlayerId() then
					sampSendChat('/re ' .. control_player_recon + 1)
					control_player_recon = control_player_recon + 1
					wait(250)
					while not sampIsPlayerConnected(control_player_recon + 1) and control_player_recon + 1 <= sampGetMaxPlayerId() do
						wait(250)
						control_player_recon = (control_player_recon + 1) + 1
						sampSendChat('/re ' .. (control_player_recon + 1))
					end
				end
			end)
		end
		imgui.Tooltip(u8'NumPad 6')
		imgui.SetCursorPosX(40)
		if imgui.Button(u8'�����') then
			sampSendChat('/reoff')
		end
		imgui.Tooltip(u8'Q')
		imgui.SameLine()
		if imgui.Button(u8'��������') then
			sampSendChat('/slap ' .. control_player_recon)
		end
		imgui.SameLine()
		if imgui.Button(u8'����������') then
			sampSendChat('/aspawn ' .. control_player_recon)
		end
		imgui.SameLine()
		if imgui.Button(u8'���������������') then
			lua_thread.create(function()
				sampSendChat('/reoff')
				wait(3000)
				sampSendChat('/gethere ' .. control_player_recon)
			end)
		end
		imgui.SameLine()
		if imgui.Button(u8'�����������������') then
			lua_thread.create(function()
				sampSendChat('/reoff')
				wait(3000)
				sampSendChat('/agt ' .. control_player_recon)
			end)
		end
		imgui.SameLine()
		if imgui.Button(u8'��������') then
			sampSendClickTextdraw(textdraw.refresh)
			if cfg.settings.keysync then
				lua_thread.create(function()
					wait(1000)
					while sampIsDialogActive() or sampIsChatInputActive() do wait(0) end
					sampSendInputChat('/keysync ' .. control_player_recon)
				end)
			end
		end
		imgui.Tooltip('R')
		imgui.End()
	end
	if windows.new_position_recon_menu.v then -- ���������� ������������ ������ ����� ����
		imgui.SetNextWindowSize(imgui.ImVec2(265, 283), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"��������� ������", windows.new_position_recon_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'��������� ������� ' .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			cfg.settings.position_recon_menu_x = imgui.GetWindowPos().x
			cfg.settings.position_recon_menu_y = imgui.GetWindowPos().y
			save()
			windows.new_position_recon_menu.v = false
			windows.recon_menu.v = true
		end
		if imgui.Button(u8'�� �������� �������', imgui.ImVec2(250, 25)) then
			windows.new_position_recon_menu.v = false
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.new_position_render_admins.v then -- ���������� ������������ ������� ������
		imgui.SetNextWindowSize(imgui.ImVec2(250, 80), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"��������� rendera", windows.new_position_render_admins, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8"��������� ������������ " .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			cfg.settings.render_admins_positionX = imgui.GetWindowPos().x
			cfg.settings.render_admins_positionY = imgui.GetWindowPos().y
			save()
			showCursor(false,false)
			sampAddChatMessage(tag .. '��� ���������� �������� ���������� ������������.', -1)
			thisScript():reload()
		end
		if imgui.Button(u8'�� �������� �������', imgui.ImVec2(250, 25)) then
			windows.new_position_render_admins.v = false
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.new_position_keylogger.v then -- ���������� ������������ keylogger
		imgui.SetNextWindowSize(imgui.ImVec2(400, 100), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"��������� keylog", windows.new_position_keylogger, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8"��������� ������������ " .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			cfg.settings.keysyncx = imgui.GetWindowPos().x + 200
			cfg.settings.keysyncy = imgui.GetWindowPos().y
			save()
			windows.new_position_keylogger.v = false
		end
		if imgui.Button(u8'�� �������� �������', imgui.ImVec2(250, 25)) then
			windows.new_position_keylogger.v = false
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.new_position_adminchat.v then -- ���������� ������� ����� ����
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'�����-���', windows.new_position_adminchat, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.CenterText(u8'����� ���')
		if imgui.Button(u8'��������� ������� ' .. fa.ICON_ARROWS) then
			cfg.settings.position_adminchat_x = imgui.GetWindowPos().x
			cfg.settings.position_adminchat_y = imgui.GetWindowPos().y
			save()
		end
		imgui.Text(u8'������: ')
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
		imgui.Text(u8'���-�� �����: ')
		imgui.SameLine()
		imgui.PushItemWidth(20)
		if imgui.Combo('##stroki', selected_item, {'3', '6', '9', '12'}, 4) then -- ���� �� -1 �����, �.� ���� ���� � 0
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
				for i = #adminchat, cfg.settings.strok_admin_chat do
					adminchat[i] = nil
				end
			end
			save()
		end
		imgui.PopItemWidth()
		imgui.CenterText(u8'��� /ears')
		if imgui.Button(u8'�o������� ������� ' .. fa.ICON_ARROWS) then
			cfg.settings.position_ears_x = imgui.GetWindowPos().x
			cfg.settings.position_ears_y = imgui.GetWindowPos().y
			save()
		end
		imgui.Text(u8'������: ')
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
		imgui.Text(u8'���-�� �����: ')
		imgui.SameLine()
		imgui.PushItemWidth(20)
		if imgui.Combo('##stroki2', selected_item, {'3', '6', '9', '12', '15','20'}, 6) then -- ���� �� -1 �����, �.� ���� ���� � 0
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
				for i = #ears, cfg.settings.strok_ears do
					ears[i] = nil
				end
			end
			save()
		end
		imgui.PopItemWidth()
		imgui.PopFont()
		imgui.End()
	end
	if windows.fast_rmute.v then -- �������� � ���� �������� �������
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ���������� �������", windows.fast_rmute, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.Button(u8'������ (1)', imgui.ImVec2(250, 25)) or isKeyDown(VK_1) then
			nakazatreport.oftop = true
			answer.nakajy = true
			windows.fast_rmute.v = false
		end
		if imgui.Button(u8'���� (2)', imgui.ImVec2(250, 25)) or isKeyDown(VK_2) then
			nakazatreport.capsrep = true
			answer.nakajy = true
			windows.fast_rmute.v = false
		end
		if imgui.Button(u8'����������� ������������� (3)', imgui.ImVec2(250, 25)) or isKeyDown(VK_3) then
			nakazatreport.oskadm = true
			answer.nakajy = true
			windows.fast_rmute.v = false
		end
		if imgui.Button(u8'������� �� ������������� (4)', imgui.ImVec2(250, 25)) or isKeyDown(VK_4) then
			nakazatreport.kl = true
			answer.nakajy = true
			windows.fast_rmute.v = false
		end
		if imgui.Button(u8'�����������/���������� ������ (5)', imgui.ImVec2(250, 25)) or isKeyDown(VK_5) then
			nakazatreport.oskrod = true
			answer.nakajy = true
			windows.fast_rmute.v = false
		end
		if imgui.Button(u8'���������������� (6)', imgui.ImVec2(250, 25)) or isKeyDown(VK_6) then
			nakazatreport.poprep = true
			answer.nakajy = true
			windows.fast_rmute.v = false
		end
		if imgui.Button(u8'�����������/�������� (7)', imgui.ImVec2(250, 25)) or isKeyDown(VK_7) then
			nakazatreport.oskrep = true
			answer.nakajy = true
			windows.fast_rmute.v = false
		end
		if imgui.Button(u8'����������� ������� (8)', imgui.ImVec2(250, 25)) or isKeyDown(VK_8) then
			nakazatreport.matrep = true
			answer.nakajy = true
			windows.fast_rmute.v = false
		end
		imgui.End()
	end
	if windows.custom_ans.v then -- ���� ����� � ������
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'��� �����', windows.custom_ans, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.IsWindowAppearing() then
			imgui.SetKeyboardFocusHere(-1)
		end
		imgui.NewInputText('##SearchBar3', buffer.find_custom_answer, 480, u8'����� �� �������', 2)
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
	if windows.answer_player_report.v then -- ������ ����� ������ � ������
		windows.render_admins.v = false
		imgui.SetNextWindowPos(imgui.ImVec2(sw-250, 0), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ����� ������ �� ������", windows.answer_player_report.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�� ��������� ������ �� �������')
		imgui.CenterText(u8'�������� ����������?')
		if imgui.Button(u8'��������� �� �������� (1)', imgui.ImVec2(250, 25)) or isKeyDown(VK_1) then
			sampSendInputChat('/n ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'������ ����� ���� (2)', imgui.ImVec2(250,25)) or isKeyDown(VK_2) then
			sampSendInputChat('/cl ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'����� �������. (3)', imgui.ImVec2(250,25)) or isKeyDown(VK_3) then
			sampSendInputChat('/nak ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'������� ���. (4)', imgui.ImVec2(250,25)) or isKeyJustPressed(VK_4) then
			sampSendInputChat('/pmv ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'����� AFK (5)', imgui.ImVec2(250,25)) or isKeyJustPressed(VK_5) then
			sampSendInputChat('/afk ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'����� �� � ���� (6)', imgui.ImVec2(250,25)) or isKeyJustPressed(VK_6) then
			sampSendInputChat('/nv ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'��� �����-������������ (7)', imgui.ImVec2(250,25)) or isKeyJustPressed(VK_7) then
			sampSendInputChat('/dpr ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if (isKeyJustPressed(VK_RBUTTON) or isKeyJustPressed(VK_F)) and not sampIsChatInputActive() then
			if isCursorActive() then
				showCursor(false,false)
			else
				showCursor(true,false)
			end
		end
		imgui.CenterText(u8'����� ������ �������, ���� ��������')
		imgui.CenterText(u8'���������: ��� ��� F')
		imgui.CenterText(u8'���� ������� 5 ������.')
		imgui.End()
	end
	if windows.help_young_admin.v then -- �������������� �������� ����
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5)-150, (sh * 0.5)-125), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'���������', windows.help_young_admin, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
        imgui.Text(u8'����� �������� � ��� ���?')
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
		imgui.Text(u8'��������� // ' .. sampGetPlayerNickname(myid))
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
		imgui.Begin(u8"��������������", windows.render_admins, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		for i = 1, #admins - 1 do
			imgui.TextColoredRGB(admins[i])
		end
        imgui.End()
	end
	if windows.new_flood_mess.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(265,340), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'����� ����', windows.new_flood_mess, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Button(u8'������ ��� ������� /mess\n��� ���� ���� ������� ����.', imgui.ImVec2(250,32)) then
			sampSendChat('/mcolors')
		end
		imgui.Text(u8'��������: ')
		imgui.PushItemWidth(250)
		imgui.InputText('##title_flood_mess', buffer.title_flood_mess)
		imgui.PopItemWidth()
		imgui.Text(u8'�����: ')
		imgui.InputTextMultiline("##5", buffer.new_flood_mess, imgui.ImVec2(250, 100))
		if imgui.Button(u8'���������', imgui.ImVec2(250, 24)) then
			if #(u8:decode(buffer.new_flood_mess.v)) > 3 and #(u8:decode(buffer.title_flood_mess.v)) ~= 0 then
				if buffer.new_flood_mess.v ~= 0 then
					cfg.myflood[u8:decode(buffer.title_flood_mess.v)] = u8:decode(buffer.new_flood_mess.v)
					save()
					buffer.title_flood_mess.v = ''
					buffer.new_flood_mess.v = ''
				else
					sampAddChatMessage(tag .. '�� �� ������� ����� �����', -1)
				end
			else
				sampAddChatMessage(tag .. '��� �� ��������� ���������?', -1)
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
				save()
			end
			imgui.PopFont()
		end
		imgui.End()
	end
	if windows.pravila.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw*0.5,sh*0.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'������', windows.pravila, imgui.WindowFlags.NoResize +imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.NewInputText('##SearchBar6', buffer.find_rules, sw*0.5, u8'����� �� ������', 2)
		imgui.Tooltip('Space')
		imgui.PushFont(fontsize)
		imgui.RadioButton(u8"�������", checkbox.checked_radio_button, 1)
		imgui.SameLine()
		imgui.RadioButton(u8"��������� �������", checkbox.checked_radio_button, 2)
		imgui.SameLine()
		imgui.RadioButton(u8"������� �������", checkbox.checked_radio_button, 3)
		if isKeyJustPressed(VK_SPACE) then
			imgui.SetKeyboardFocusHere(-1)
		end
		if checkbox.checked_radio_button.v == 1 then
			for i = 1, #pravila do
				if string.lower(string.rlower(pravila[i])):find(string.lower(string.rlower(u8:decode('%s'..buffer.find_rules.v)))) then
					if not u8(pravila[i]):find('%[(%d+) lvl%]') and not u8(pravila[i]):find('SCRIPT')  then
						imgui.TextWrapped(u8(pravila[i]))
					end
				end
			end
		elseif checkbox.checked_radio_button.v == 2 then
			for i = 1, #pravila do
				if string.lower(string.rlower(pravila[i])):find(string.lower(string.rlower(u8:decode('%s'..buffer.find_rules.v)))) then
					if u8(pravila[i]):find('%[(%d+) lvl%]') then
						imgui.TextWrapped(u8(pravila[i]))
					end
				end
			end
		elseif checkbox.checked_radio_button.v == 3 then
			if #(cfg.my_command) ~= 0 then imgui.Text(u8'[��� �������]') end
			for k,v in pairs(cfg.my_command) do
				imgui.TextWrapped(u8('/' .. k))
			end
			for i = 1, #pravila do
				if string.lower(string.rlower(pravila[i])):find(string.lower(string.rlower(u8:decode('%s'..buffer.find_rules.v)))) then
					if u8(pravila[i]):find('SCRIPT') then
						imgui.TextWrapped(u8(string.sub(pravila[i], 7)))
					end
				end
			end
		end
		imgui.PopFont()
		imgui.End()
	end
end
function render_adminchat()
	while true do
		wait(1)
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
function sampev.onServerMessage(color,text) -- ����� ��������� �� ����
	if cfg.settings.find_warning_weapon_hack and not AFK then
		if text:match('Weapon hack .code. 015.') then
			lua_thread.create(function()
				while sampIsDialogActive() or sampIsChatInputActive() do wait(0) end
				sampSendChat("/iwep " .. string.match(text, "%[(%d+)%]"))
			end)
		end 
	end
	if text:match('%[����������%] {FFFFFF}������ �� �� ������ ��������� �������') then
		cfg.settings.render_ears = false
		save()
		checkbox.check_render_ears = imgui.ImBool(cfg.settings.render_ears)
		if notify_report then
			notify_report.addNotify('{66CDAA}[AT] ������������ ��', '������������ ������ ���������\n���� ������� ��������������', 2,2,6)
		end
		return false
	end
	if text:match('%[����������%] {FFFFFF}������ �� ������ ��������� �������') then
		cfg.settings.render_ears = true
		save()
		checkbox.check_render_ears = imgui.ImBool(cfg.settings.render_ears)
		if notify_report then
			notify_report.addNotify('{66CDAA}[AT] ������������ ��', '������������ ������ ���������\n���� ������� ����������������', 2,2,6)
		end
		return false
	end
	if cfg.settings.render_admins then
		if text:match('����� ������������������� �� �������:') or text:match('���� ���������:') or text:match('����� ������������� � ����:') then
			return false
		end
	end
	if cfg.settings.forma_na_ban or cfg.settings.forma_na_mute or cfg.settings.forma_na_jail or cfg.settings.forma_na_kick then
        if text:match('{FFFFFF}� ��� ��� ������� � ���� �������, ��� ������� {FFFFFF}��������� � ������ ��������������.') then
            return false
        end
	end
	if cfg.settings.find_form and not AFK then
		if text:match("%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: ") then
			for i = 1, #spisok_in_form do
				if spisok_in_form[i] and text:find(spisok_in_form[i]) then
					while true do -- ���� ���� �� ����� �������
						admin_form = {}
						local find_admin_form = string.gsub(text, '%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: {%w%w%w%w%w%w}', '')
						if string.sub(find_admin_form, 1, 1) == '/' then
							admin_form.idadmin = tonumber(text:match('%[(%d+)%]'))
							admin_form.forma = find_admin_form
							if find_admin_form:find('unban') then
								admin_form.bool = true
								admin_form.timer = os.clock()
								admin_form.sett = true
								admin_form.styleform = true
								wait_accept_form()
								break
							end
							if find_admin_form:find('off') or find_admin_form:find('akk') then
								admin_form.bool = true
								admin_form.timer = os.clock()
								if (find_admin_form.sub(find_admin_form, 2)):find('//') then
									admin_form.styleform = true
								end
								admin_form.sett = true
								wait_accept_form()
								break
							end
							admin_form.probid = string.match(admin_form.forma, '%d[%d.,]*')
							if admin_form.probid and sampIsPlayerConnected(admin_form.probid) then
								admin_form.bool = true
								admin_form.timer = os.clock()
								admin_form.nickid = sampGetPlayerNickname(admin_form.probid)
								if (find_admin_form.sub(find_admin_form, 2)):find('//') then
									admin_form.styleform = true
								end
								admin_form.sett = true
								wait_accept_form()
								break
							else
								admin_form = {}
								sampAddChatMessage(tag .. 'ID �� ���������, ���� ��������� ��� ����.', -1)
								break
							end
						else
							break
						end
					end
				end
			end
		end
	end
	if cfg.settings.render_ears and (text:match('NEARBY CHAT: ') or text:match('SMS: ')) then
		local text = string.gsub(text, 'NEARBY CHAT:', '{4682B4}AT-NEAR:{FFFFFF}')
		local text = string.gsub(text, 'SMS:', '{4682B4}AT-SMS:{FFFFFF}')
		local text = string.gsub(text, ' �������� ', '')
		local text = string.gsub(text, ' ������ ', '->')
		local text = string.sub(text, 5) -- ������� [A]
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
			if text:match('������') then
				oskid = tonumber(text:match('%[(%d+)%]'))
				for i = 0, #spisokoskrod do
					if text:match('}'..tostring(spisokoskrod[i])) or text:match('%s'..tostring(spisokoskrod[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' .. text .. ' {00FF00}[��]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/rmute ' .. oskid .. ' 5000 �����������/���������� ������')
						if notify_report then
							notify_report.addNotify('{66CDAA}[AT-AutoMute]', '������� ����������:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '���������� ������.', 2,1,10)
						end
						return false
					end
				end
				for i = 0, #spisokrz do
					if text:match('}'..tostring(spisokrz[i])) or text:match('%s'..tostring(spisokrz[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' .. text .. ' {00FF00}[��]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/rmute ' .. oskid .. ' 5000 ������ ������.�����')
						if notify_report then
							notify_report.addNotify('{66CDAA}[AT-AutoMute]', '������� ����������:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '������ ������.�����', 2,1,10)
						end
						return false
					end
				end
			end
		end
        if (text:match("(.*)%((%d+)%):%s(.+)") or text:match("(.*)%[(%d+)%]:%s(.+)")) and not text:match("%[a%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)") and not text:match('������� %[(%d+)%]:') and not text:match('������� (.*)%[(%d+)%]: (.*)') and not text:match('������') then
            if text:match('%((%d+)%)') then
                oskid = text:match('%((%d+)%)')
            else
                oskid = text:match('%[(%d+)%]')
            end
			if cfg.settings.smart_automute then
				for i = 0, #spisokoskrod do
					if text:match('%s'.. tostring(spisokoskrod[i])) or text:match('}'..tostring(spisokoskrod[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' .. text .. ' {00FF00}[��]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/mute ' .. oskid .. ' 5000 �����������/���������� ������')
						if notify_report then
							notify_report.addNotify('{66CDAA}[AT-AutoMute]', '������� ����������:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '���������� ������.', 2,1,10)
						end
						return false
					end
				end
				for i = 0, #spisokrz do
					if text:match('}'..tostring(spisokrz[i])) or text:match('%s'..tostring(spisokrz[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' .. text .. ' {00FF00}[��]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/mute ' .. oskid .. ' 5000 ������ ������.�����')
						if notify_report then
							notify_report.addNotify('{66CDAA}[AT-AutoMute]', '������� ����������:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '������ ������.�����', 2,1,10)
						end
						return false
					end
				end
				for i = 0, #spisokproject do
					if text:match('%s' .. tostring(spisokproject[i])) or text:match('}' .. tostring(spisokproject[i])) then
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' .. text .. ' {00FF00}[��]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendInputChat('/up ' .. oskid)
						if notify_report then
							notify_report.addNotify('{66CDAA}[AT-AutoMute]', '������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. tostring(spisokproject[i]), 2,1,10)
						end
						return false
					end
				end
			end
            for i = 0, #cfg.osk do
                if text:match('%s'..tostring(cfg.osk[i])) or text:match('}'..tostring(cfg.osk[i])) and not text:match('� ' .. tostring(cfg.osk[i])) then
					if cfg.settings.smart_automute then
						for d = 0, #spisokor do
							if text:match('%s'.. tostring(spisokor[d])) or text:match('}'..tostring(spisokor[d])) then
								sampAddChatMessage('=======================================================', 0x00FF00)
								sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' .. text .. ' {00FF00}[��]', -1)
								sampAddChatMessage('=======================================================', 0x00FF00)
								sampSendChat('/mute ' .. oskid .. ' 5000 �����������/���������� ������')
								if notify_report then
									notify_report.addNotify('{66CDAA}[AT-AutoMute]', '' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. tostring(cfg.osk[i]) .. ' � ' .. tostring(spisokor[d]), 2,1,10)
								end
								return false
							end
						end
					end
					sampAddChatMessage('=======================================================', 0x00FF00)
					sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' .. text .. ' {00FF00}[��]', -1)
					sampAddChatMessage('=======================================================', 0x00FF00)
					sampSendChat('/mute ' .. oskid .. ' 400 �����������/��������')
					if notify_report then
						notify_report.addNotify('{66CDAA}[AT-AutoMute]', '������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. tostring(cfg.osk[i]), 2,1,10)
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
								sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' .. text .. ' {00FF00}[��]', -1)
								sampAddChatMessage('=======================================================', 0x00FF00)
								sampSendChat('/mute ' .. oskid .. ' 5000 �����������/���������� ������')
								if notify_report then
									notify_report.addNotify('{66CDAA}[AT-AutoMute]', '' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. tostring(cfg.mat[i]) .. ' � ' .. tostring(spisokor[d]), 2,1,10)
								end
								return false
							end
						end
					end
					sampAddChatMessage('=======================================================', 0x00FF00)
					sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' .. text .. ' {00FF00}[��]', -1)
					sampAddChatMessage('=======================================================', 0x00FF00)
					sampSendChat('/mute ' .. oskid .. ' 300 ����������� �������')
					if notify_report then
						notify_report.addNotify('{66CDAA}[AT-AutoMute]', '' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. tostring(cfg.mat[i]), 2,1,10)
					end						
					return false
                end
            end
        end
	end
end
function sampev.onShowTextDraw(id, data) -- ��������� ��������� ����������
	if cfg.settings.on_custom_recon_menu then
		for k,v in pairs(data) do
			v = tostring(v)
			if v == 'REFRESH' then
				textdraw.refresh = id  -- ���������� �� ������ �������� � ������
			elseif v:match('~n~') and not v:match('~g~') then 
				lua_thread.create(function()
					textdraw.inforeport = id  -- ���� ������ � ������
					while true do
						inforeport = textSplit(sampTextdrawGetString(textdraw.inforeport), "~n~") -- ���������� � ������, ���������� � �����������
						for i = 4, #inforeport do
							if i == 4 then
								if inforeport[i] == '-1' then -- �� ����
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
			elseif v:match('(.+)%((%d+)%)') then
				textdraw.name_report = id
				control_player_recon = tonumber(string.match(v, '%((%d+)%)')) -- ��� ������ � ������
				windows.recon_menu.v = true
				windows.menu_in_recon.v = true
				imgui.Process = true 
				if cfg.settings.keysync then
					sampSendInputChat('/keysync ' .. control_player_recon)
				end
				lua_thread.create(function()
					mobile_player = false
					while sampIsDialogActive() do wait(100) end
					wait(300)
					sampSendChat('/tonline ' .. control_player_recon)
				end)
			elseif v == 'STATS' then
				textdraw.stats = id
			elseif v == 'CLOSE' then
				lua_thread.create(function()
					textdraw.close = id
					wait(500)
					sampTextdrawSetPos(textdraw.close, 2000, 0)
					sampTextdrawSetPos(textdraw.stats, 2000, 0)
					sampTextdrawSetPos(textdraw.name_report, 2000, 0) -- ���������� � �������� ������
					sampTextdrawSetPos(textdraw.refresh,2000,0) -- ������ Refresh � ������
					sampTextdrawSetPos(textdraw.inforeport, 2000, 0) -- ����������
				end)
			end
		end
		if (id == 446 or id == 153 or id == 150 or id == 164 or id == 169 or id == 186
				or id == 161 or id == 164 or id == 162 or id == 169
				or id == 166 or id == 188 or id == 173 or id == 168
				or id == 189 or id == 170 or id == 173 or id == 189
				or id == 175 or id == 178 or id == 173 or id == 189
				or id == 178 or id == 190 or id == 179 or id == 177 or id == 175
				or id == 183 or id == 191 or id == 184 or id == 182 or id == 159
				or id == 159 or id == 192 or id == 156 or id == 160 or id == 158
				or id == 182 or id == 151 or id == 152 or id == 193 or id == 155
				or id == 167 or id == 174 or id == 171 or id == 187 or id == 176
				or id == 181 or id == 180 or id == 157 or id == 154 or id == 185
				or id == 444 or id == 148 or id == 165 or id == 149) then
			return false -- �������� ������ ���������� � ������
		end
	end
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text) -- ������ � ��������� ���������
	if text:match('Weapon') then
		lua_thread.create(function()
			text = textSplit(text, '\n')
			for i = 1, #text - 1 do
				local _,weapon, patron = text[i]:match('(%d+)	Weapon: (%d+)     Ammo: (.+)')
				if (text[i]:find('-')) or (weapon == '0' and patron ~= '0') then
					setVirtualKeyDown(119, true) -- screenshot F8
					setVirtualKeyDown(119, false)
					sampAddChatMessage(tag .. '������ (ID): ' .. weapon..'. �������: '..patron, -1)
					if notify_report then
						notify_report.addNotify('{66CDAA}[AT] ����-���', '������ (ID): ' .. weapon..'\n�������: '..patron, 2,2,10)
					end
					player_cheater = true
					break
				end
			end
			wait(0)
			sampCloseCurrentDialogWithButton(0)
			if player_cheater then
				while sampIsDialogActive() do wait(0) end
				player_cheater = nil
				sampSendChat('/iban '..sampGetPlayerIdByNickname(title)..' 7 ��� �� ������')
				if notify_report then
					notify_report.addNotify('{66CDAA}[AT] ����-���', '�������� /iwep ����� ����� �\n���������� ���� - ���������', 2,2,10)
				end
			else
				sampAddChatMessage(tag .. '[�������� ������] ������ ������ ' .. title .. '[' .. sampGetPlayerIdByNickname(title) .. ']. �������: ��� �� ���������.', -1)
			end
		end)
	end
	if title == 'Mobile' then -- �������� � ���� �� �����
		lua_thread.create(function()
			local text = textSplit(text, '\n')
			for i = 6, #text - 1 do
				if text[i] == (sampGetPlayerNickname(control_player_recon)..'('..control_player_recon..')') then
					mobile_player = true
					break
				end
			end
			wait(0)
			sampCloseCurrentDialogWithButton(0)
		end)
	end
	if dialogId == 3247 then -- /ahelp
		lua_thread.create(function()
			windows.pravila.v = not windows.pravila.v
			imgui.Process = true
			wait(0)
			sampCloseCurrentDialogWithButton(0)
		end)
	end
	if cfg.settings.render_admins and title:find('������������� �������') then
		admins = textSplit(text, '\n')
		local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		for i = 1, #admins - 1 do -- {FFFFFF}N.E.O.N(0) ({2E8B57}��.�������������{FFFFFF}) | �������: {ff8587}6{FFFFFF} | ��������: {ff8587}0 �� 3{FFFFFF} | ���������: {ff8587}
			local rang = string.sub(string.gsub(string.match(admins[i], '(%(.+)%)'), '(%(%d+)%)', ''), 3) --{FFFFFF}N.E.O.N(0) | �������: {ff8587}18{FFFFFF} | ��������: {ff8587}0 �� 3{FFFFFF} | ���������: {ff8587}60
			admins[i] = string.gsub(admins[i], '{%w%w%w%w%w%w}', "")
			local afk = string.match(admins[i], 'AFK: (.+)')
			local name, id, _, lvl, _, _ = string.match(admins[i], '(.+)%((%d+)%) (%(.+)%) | �������: (%d+) | ��������: 0 �� (%d+) | ���������: (.+)')
			local name, id, lvl = tostring(name), tostring(id), tostring(lvl)
			admins[i] = string.gsub(admins[i], '| ��������: %d �� %d |', "")
			admins[i] = string.gsub(admins[i], '���������: (.+)', "")
			if #rang > 2 then
				if afk then admins[i] = name .. '(' .. id .. ') ' .. rang .. ' ' .. lvl .. ' AFK: ' .. afk
				else admins[i] = name .. '(' .. id .. ') ' .. rang .. ' '.. lvl end
			else
				_, id, lvl = string.match(admins[i], '(.+)%((%d+)%) | �������: (%d+)')
				rang = '�����������'
			end
			if cfg.settings.autoprefix then
				local lvl, rang, id = tonumber(lvl), string.gsub(rang, '{%w%w%w%w%w%w}', ''), tonumber(id)
				if not management_team then
					if id == myid and lvl == 18 and rang ~= '��.�������������' then
						management_team = true
					end
				else
					if id ~= myid then
						lua_thread.create(function() -- �� ��������� �������� �������� ����
							if lvl <= 9 and lvl > 0 and rang ~= '��.�������������' then
								while sampIsDialogActive() do wait(0) end
								sampAddChatMessage(tag .. '� �������������� ' .. sampGetPlayerNickname(id) .. ' ��������� �������� �������.', -1)
								sampAddChatMessage(tag .. '��������� ������: ' .. rang .. ' -> {' .. cfg.settings.prefixma .. '}��.�������������', -1)
								wait(800) -- ��������� �������� �� �������
								sampSendChat('/prefix ' .. id .. ' ��.������������� ' .. cfg.settings.prefixma)
								wait(800) -- ��������� �������� �� �������
								sampSendChat('/admins')
								if notify_report then
									notify_report.addNotify('{FF6347}[AT] �������������� ������ ��������', '������������� '..sampGetPlayerNickname(id)..'['..id ..']\n��� ���������� ����� �������.\n' .. rang .. '-> ��.�������������.' , 2,2,15)
								end
							elseif lvl < 15 and lvl >= 10 and rang ~= '�������������' then
								while sampIsDialogActive() do wait(0) end
								sampAddChatMessage(tag .. '� �������������� ' .. sampGetPlayerNickname(id) .. ' ��������� �������� �������.', -1)
								sampAddChatMessage(tag .. '��������� ������: ' .. rang .. ' -> {' ..cfg.settings.prefixa..'}�������������', -1)
								wait(800) -- ��������� �������� �� �������
								sampSendChat('/prefix ' .. id .. ' ������������� ' .. cfg.settings.prefixa)
								wait(800) -- ��������� �������� �� �������
								if notify_report then
									notify_report.addNotify('{FF6347}[AT] �������������� ������ ��������', '������������� '..sampGetPlayerNickname(id)..'['..id ..']\n��� ���������� ����� �������.\n' .. rang .. '-> �������������.' , 2,2,15)
								end
								sampSendChat('/admins')
							elseif lvl < 18 and lvl >= 15 and rang ~= '��.�������������' then
								while sampIsDialogActive() do wait(0) end
								sampAddChatMessage(tag .. '� �������������� ' .. sampGetPlayerNickname(id) .. ' ��������� �������� �������.', -1)
								sampAddChatMessage(tag .. '��������� ������: ' .. rang .. ' -> {' .. cfg.settings.prefixsa..'}��.�������������', -1)
								wait(800) -- ��������� �������� �� �������
								sampSendChat('/prefix ' .. id .. ' ��.������������� ' .. cfg.settings.prefixsa)
								wait(800) -- ��������� �������� �� �������
								sampSendChat('/admins')
								if notify_report then
									notify_report.addNotify('{FF6347}[AT] �������������� ������ ��������', '������������� '..sampGetPlayerNickname(id)..'['..id ..']\n��� ���������� ����� �������.\n' .. rang .. '-> ��.�������������.' , 2,2,15)
								end
							end
						end)
					end
				end
			end
			local name, id, rang, lvl, afk, rang, myid = nil
		end
		imgui.Process = true
		windows.render_admins.v = true
		sampSendDialogResponse(dialogId, 1, 0)
		return false
	end
	if dialogId == 1098 and cfg.settings.autoonline then -- ����������
		sampSendDialogResponse(dialogId, 1, math.floor(sampGetPlayerCount(false) / 10) - 1)
		sampCloseCurrentDialogWithButton(0)
		return false
	end
	if dialogId == 16196 then -- ���� /offstats ��� ����� ����� ����������� � ���� ������������ ��� /sbanip
		if find_ip_player then
			sampSendDialogResponse(dialogId, 1, 0)
			return false
		end
		if regip then
			lua_thread.create(function()
				wait(0) -- ��� ����� ������-�� �� �����������
				sampCloseCurrentDialogWithButton(0)
			end)
		end
	end
	if dialogId == 16197 and find_ip_player then -- ���� /offstats ������������ ��� /sbanip
		lua_thread.create(function()
			for k,v in pairs(textSplit(text, '\n')) do
				if k == 12 then
					regip = string.sub(v, 17)
				elseif k == 13 then
					lastip = string.sub(v, 18)
				end
			end
			sampSendDialogResponse(dialogId,1,0)
			find_ip_player = nil
		end)
		return false
	end
	if dialogId == 2348 and windows.fast_report.v then
		windows.fast_report.v = false
	end
	if dialogId == 2349 then -- ���� � ����� ��������.
		answer, windows.answer_player_report.v, peremrep = {}, false, nil
		local lineIndex = -1
		for line in text:gmatch("[^\n]+") do
			lineIndex = lineIndex + 1
			if lineIndex == tonumber(1) - 1 then 
				don = string.sub(line, 1, 1)
				if don == '{' then
					autor = string.sub(line, 24) -- ��������� ������ ������
					if sampGetPlayerIdByNickname(autor) then
						autorid = sampGetPlayerIdByNickname(autor) -- ������ ��
					else
						autorid = (u8'�� � ����')
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
						if not sampIsPlayerConnected(reportid) then
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
			while not (answer.rabotay or answer.uto4 or answer.nakajy or answer.customans or answer.slejy or answer.jb or answer.ojid or answer.moiotvet or answer.uto4id or answer.nakazan or answer.otklon or answer.peredamrep) do -- ���� ������� �������
				wait(200)
			end
			sampSendDialogResponse(dialogId,1,0)
		end)
	end
	if dialogId == 2350 then -- ���� � ������������ ������� ��� ��������� ������
		if ((#(u8:decode(buffer.text_ans.v)) == 0) and #answer == 0) then
			windows.fast_report.v = true
		elseif ((#(u8:decode(buffer.text_ans.v)) ~= 0) and #answer == 0) or answer.moiotvet then
			peremrep = (u8:decode(buffer.text_ans.v))
			answer.moiotvet = true
		end
		if not peremrep then
			if answer.rabotay then
				peremrep = ('�����(�) ������ �� ����� ������!')
			elseif answer.slejy then
				if not reportid then
					peremrep = ('������� ������.')
					answer.slejy = nil
				elseif reportid and reportid ~= myid then
					if not sampIsPlayerConnected(reportid) then
						peremrep = ('��������� ���� ����� ��� ' .. reportid .. ' ID ��������� ��� ����.')
						answer.slejy = nil
					else
						peremrep = ('����������� � ������ �� ������� ' .. sampGetPlayerNickname(reportid) .. '['..reportid..']')
					end
				elseif myid then
					if reportid == myid then
						peremrep = ('�� ������� ��� ID :D')
						answer.slejy = nil
					end
				end
			elseif answer.nakazan then
				peremrep = ('������ ����� ��� ��� �������.')
			elseif answer.uto4id then
				peremrep = ('�������� ID ���������� � /report.')
			elseif answer.nakajy then
				windows.fast_rmute.v = true
				if nakazatreport.oftop or nakazatreport.oskadm or nakazatreport.matrep or nakazatreport.oskrep or nakazatreport.poprep or nakazatreport.oskrod or nakazatreport.capsrep then
					windows.fast_rmute.v = false
					peremrep = ('������ �������� �� ��������� ������ /report')
				end  
			elseif answer.jb then
				peremrep = ('�������� ������ �� forumrds.ru')
			elseif answer.peredamrep then
				peremrep = ('������� ��� ������.')
			elseif answer.rabotay then
				if not reportid then
					peremrep = ('�����(�) ������ �� ����� ������.')
				elseif reportid and reportid ~= myid then
					if not sampIsPlayerConnected(reportid) then
						peremrep = ('��������� ���� ����� ��� ' .. reportid .. ' ID ��������� ��� ����.')
					else
						peremrep = ('�����(�) ������ �� ����� ������.')
					end
				elseif reportid == myid then
					peremrep = ('�����(�) ������ �� ����� ������.')
				end
			elseif answer.customans then
				peremrep = answer.customans
			elseif answer.uto4 then
				peremrep = ('���������� � ������ ��������� �� ����� https://forumrds.ru')
			elseif answer.otklon then
				sampSendDialogResponse(dialogId, 1, 2, _)
				return false
			end
		end
		if peremrep then
			if #peremrep > 80 then
				sampAddChatMessage(tag .. '��� ����� �������� ������� �������, ���������� ��������� �����.',-1)
				peremrep = nil
			end
			if cfg.settings.add_answer_report and (#peremrep + #(cfg.settings.mytextreport)) < 80 then
				peremrep = peremrep .. ('{'..tostring(color())..'} ' .. cfg.settings.mytextreport)
			end
			if cfg.settings.on_color_report and (#peremrep + #(cfg.settings.color_report)) < 80 then
				peremrep = cfg.settings.color_report .. peremrep
			end
			if #peremrep < 3 then
				peremrep = peremrep .. '    '
			end
			if cfg.settings.custom_answer_save and answer.moiotvet then
				cfg.customotvet[ #cfg.customotvet + 1 ] = u8:decode(buffer.text_ans.v)
				save()
			end	
			sampSendDialogResponse(dialogId, 1, 0)
			return false
		end
	end
	if dialogId == 2351 and peremrep then -- ���� � ������� �� ������
		lua_thread.create(function()
			windows.fast_report.v = false
			sampSendDialogResponse(dialogId, 1, _, peremrep)
			sampCloseCurrentDialogWithButton(0)
			while sampIsDialogActive() do wait(0) end
			if answer.rabotay then
				sampSendChat('/re ' .. autorid)
			elseif answer.slejy then
				sampSendChat('/re ' .. reportid)
			elseif answer.peredamrep then
				sampSendChat('/a ' .. autor .. '[' .. autorid .. '] | ' .. textreport)
			elseif answer.nakajy then
				if nakazatreport.oftop then
					sampSendChat('/rmute ' .. autorid .. ' 120 ������ � /report')
				elseif nakazatreport.oskadm then
					sampSendChat('/rmute ' .. autorid .. ' 2500 ����������� �������������')
				elseif nakazatreport.oskrep then
					sampSendChat('/rmute ' .. autorid .. ' 400 �����������/��������')
				elseif nakazatreport.poprep then
					sampSendChat('/rmute ' .. autorid .. ' 120 ����������������')
				elseif nakazatreport.oskrod then
					sampSendChat('/rmute ' .. autorid .. ' 5000 �����������/���������� ������')
				elseif nakazatreport.capsrep then
					sampSendChat('/rmute ' .. autorid .. ' 120 ���� � /report')
				elseif nakazatreport.matrep then
					sampSendChat('/rmute ' .. autorid .. ' 300 ����������� �������')
				elseif nakazatreport.kl then
					sampSendChat('/rmute ' .. autorid .. ' 3000 ������� �� �������������')
				end
				nakazatreport = {}
			end
			buffer.text_ans.v = ''
			if not copies_player_recon and tonumber(autorid) and cfg.settings.answer_player_report then
				copies_player_recon = autorid
				ansid = reportid
				while not windows.recon_menu.v do wait(0) end
				while windows.recon_menu.v do wait(2000) end
				if copies_player_recon and copies_player_recon ~= control_player_recon then
					if sampIsPlayerConnected(copies_player_recon) then
						imgui.Process = true
						windows.answer_player_report.v = true
						showCursor(false,false)
						for i = 0, 10 do -- ������ � 10 ���
							wait(500)
							if ansid ~= control_player_recon then
								ansid = nil
								copies_player_recon = nil
								windows.menu_in_recon.v = false
							end
						end
						if windows.answer_player_report.v then
							windows.answer_player_report.v = false
							copies_player_recon = nil
						end
					else
						sampAddChatMessage(tag .. '�����, ���������� ������, ��������� ��� ����.', -1)
					end
				end
			else 
				copies_player_recon, ansid = nil,nil 
			end
		end)
		return false
	end
end
function sampev.onDisplayGameText(style, time, text) -- �������� ����� �� ������.
	if text:find('RECON') then
		windows.recon_menu.v = false
		return false
	end
	if text:find('REPORT') then
		if cfg.settings.notify_report and not AFK then
			if notify_report then
				notify_report.addNotify('{FF0000}[AT �����������]', '�������� ����� ������.', 2,2,8)
			end
		end
		return false
	end
end
function imgui.TextColoredRGB(text) -- ������� ������ ������
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
       imgui.BeginTooltip() -- ��������� ��� ��������� �� ������
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
local russian_characters = { -- ������� ������� ��� ������� ����
    [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
}
function string.rlower(s) -- ������� ������� ���� � ���������
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- �
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function uu() -- ��� �������
    for i = 0,2 do
        menu[i] = false
    end
end
function uu2() -- ��� �������
    for i = 0,10 do
        menu2[i] = false
    end
end
function textSplit(str, delim, plain) -- ��������� ������ �� ������������ ���������
    local tokens, pos, plain = {}, 1, not (plain == false)
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end
function sampGetPlayerIdByNickname(nick) -- ������ ID �� ����
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
		while sampIsDialogActive() do wait(0) end
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
 local keys = {
	["onfoot"] = {},
	["vehicle"] = {}
}
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
					windows.menu_in_recon.v = false
					sampSendInputChat('/keysync off')
				end
			else
				mimgui.Text(u8"����� �� ������������. �������� ����� ����� ������� R")
				if not windows.recon_menu.v then
					windows.menu_in_recon.v = false
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
function imgui.NewInputText(lable, val, width, hint, hintpos) -- ���� ����� � ����������
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
function onWindowMessage(msg, wparam, lparam) -- ���������� ALT + Enter
	if msg == 261 and wparam == 13 then consumeWindowMessage(true, true) end
end
function playersToStreamZone() -- ������ � �������
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
		wait(500)
		sampSendInputChat('/fsoff')
		wait(500)
		sampSendInputChat('/mpoff')
		imgui.Process = false
		showCursor(false,false)
		thisScript():unload()
	end)
end

function autoonline() 
	while true do
		wait(61000) 
		while sampIsDialogActive() or sampIsChatInputActive() do wait(0) end 
		wait(200) 
		if not AFK then sampSendChat("/online") end 
	end 
end

function sampSendInputChat(text) -- �������� � ��� ����� �6
	sampSetChatInputText(text)
	sampSetChatInputEnabled(true)
	setVirtualKeyDown(13, true)
	setVirtualKeyDown(13, false)
end
function save()
	inicfg.save(cfg,'AT//AT_main.ini')
end
function wait_accept_form()
	lua_thread.create(function()
		local fonts = renderCreateFont('TimesNewRoman', 12, 5) -- ����� ��� ��������
		while admin_form.forma do
			wait(0)
			if admin_form.bool and admin_form.timer and admin_form.sett then
				timer = os.clock() - admin_form.timer 
				if admin_form.probid then
					if sampIsPlayerConnected(admin_form.probid) then
						renderFontDrawText(fonts, '{FFFFFF}����� U ����� ������� ��� J ����� ���������\n�����: {F0E68C}' .. admin_form.forma .. '{FFFFFF}' .. ' �� ������ '.. '{F0E68C}' .. admin_form.nickid .. '[' .. admin_form.probid .. ']'.. '{FFFFFF}' .. '\n������� �� �������� 8 ���, ������: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
					else
						renderFontDrawText(fonts, '{FFFFFF}����� U ����� ������� ��� J ����� ���������\n�����: {F0E68C}' .. admin_form.forma.. '{FFFFFF}' .. '\n������� �� �������� 8 ���, ������: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
					end
				else
					renderFontDrawText(fonts, '{FFFFFF}����� U ����� ������� ��� J ����� ���������\n�����: {F0E68C}' .. admin_form.forma.. '{FFFFFF}' .. '\n������� �� �������� 8 ���, ������: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
				end
				if timer>8 then
					admin_form = {}
				end
			end
		end
	end)
end
function binder_key()
	while true do
		wait(1)
		if not windows.fast_report.v and not windows.answer_player_report.v and not isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() and not windows.menu_tools.v then
			if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_ans)) then
			sampSendChat("/ans")
			sampSendDialogResponse(2348, 1, 0)
			end
			if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_addText)) then
				sampSetChatInputText(string.sub(sampGetChatInputText(), 1, -2) .. ' '.. cfg.settings.mytextreport)
				sampSetChatInputEnabled(true)
			end
			if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_wallhack)) then
				sampSendInputChat("/wh")
			end
			for k,v in pairs(cfg.binder_key) do
				if isKeyJustPressed(strToIdKeys(k)) then
					sampSendChat(v)
				end
			end
		end
	end
end
function color() -- ������ �������
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
function imgui.CenterText(text) -- ������������� ������
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 ) 			
    imgui.Text(text)
end
function imgui.Link(label, description) -- �����������
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
---------------===================== ������������� ID ������� �������
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
---------------===================== ������������� ID ������� �������
function update()
	imgui.Process = false
	showCursor(false,false)
	local dlstatus = require('moonloader').download_status
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_MP.lua", getWorkingDirectory() .. "//resource//AT_MP.lua", function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(tag .. '������ ������ ���������. ������ ��������� �������.', -1)
		end
	end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_FastSpawn.lua", getWorkingDirectory() .. "//resource//AT_FastSpawn.lua", function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(tag .. '������ ������ ������� ���������. ������ �������� ��������� �������', -1)
		end
	end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", getWorkingDirectory() .. "//config//AT//rules.txt", function(id, status)  end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_Trassera.lua", getWorkingDirectory() .. "//resource//AT_Trassera.lua", function(id, status) end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.lua", thisScript().path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(tag .. '�������� ������ ������� ��������.',-1)
			update_state = false
			reloadScripts()
		end
	end)
end
function on_wallhack()
	local pStSet = sampGetServerSettingsPtr();
	NTdist = mem.getfloat(pStSet + 39)
	NTwalls = mem.getint8(pStSet + 47)
	NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 500.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
	nameTag = true
end
function off_wallhack()
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, 30)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
	nameTag = false
end

----======================= ������������� ��� ������� ===============------------------
sampRegisterChatCommand('wh' , function()
	if not cfg.settings.wallhack then
		cfg.settings.wallhack = true
		save()
		if notify_report then
			notify_report.addNotify('{66CDAA}[AT-WallHack]', '����� ������� ��������\n��������� ��������� ������� ���������', 2, 2, 5)
		end
		checkbox.check_WallHack = imgui.ImBool(cfg.settings.wallhack),
		on_wallhack()
	else
		cfg.settings.wallhack = false
		save()
		if notify_report then
			notify_report.addNotify('{66CDAA}[AT-WallHack]', '����� ������� ��������\n��������� ��������� ������� ���������', 2, 2, 5)
		end
		checkbox.check_WallHack = imgui.ImBool(cfg.settings.wallhack),
		off_wallhack()
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
sampRegisterChatCommand('color_report', function(param)
	if #param ~= 0 then
		if #param == 6 then
			cfg.settings.color_report = '{'..param..'}'
			save()
			sampAddChatMessage(tag ..cfg.settings.color_report.. '��������� ����', -1)
		else
			sampAddChatMessage(tag..'���� ������ �������. ������� HTML ���� ��������� �� 6 ��������', -1)
			sampAddChatMessage(tag ..'������: /color_report FF0000 (����� ������ ���� ' .. '{FF0000}�������' .. '{FFFFFF})', -1)
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������', -1)
	end
end)
sampRegisterChatCommand('autoprefix', function()
	if cfg.settings.autoprefix then
		sampAddChatMessage(tag .. '�������������� ������ �������� ������� ���������.', -1)
	else
		sampAddChatMessage(tag .. '�������������� ������ �������� ������� ��������.', -1)
	end
	cfg.settings.autoprefix = not cfg.settings.autoprefix
	save()
end)
sampRegisterChatCommand('newprf_ma', function(param)
	if #param == 6 then
		cfg.settings.prefixma = param
		save()
		sampAddChatMessage(tag .. '����� ������� {' .. cfg.settings.prefixma .. '}��.��������������', -1)
	else
		sampAddChatMessage(tag .. '���� ������ �������. ��������� HTML ���� �� 6 ��������.', -1)
	end
end)
sampRegisterChatCommand('newprf_a', function(param)
	if #param == 6 then
		cfg.settings.prefixa = param
		save()
		sampAddChatMessage(tag .. '����� ������� {' .. cfg.settings.prefixa .. '}��������������', -1)
	else
		sampAddChatMessage(tag .. '���� ������ �������. ��������� HTML ���� �� 6 ��������.', -1)
	end
end)
sampRegisterChatCommand('newprf_sa', function(param)
	if #param == 6 then
		cfg.settings.prefixsa = param
		save()
		sampAddChatMessage(tag .. '����� ������� {' .. cfg.settings.prefixsa .. '}��.��������������', -1)
	else
		sampAddChatMessage(tag .. '���� ������ �������. ��������� HTML ���� �� 6 ��������.', -1)
	end
end)
----======================= ������������� ��������������� ===============------------------
sampRegisterChatCommand('sbanip', function()
	lua_thread.create(function()
		sampShowDialog(6400, "������� ��� ����������", "", "�����������", nil, DIALOG_STYLE_INPUT) -- ��� ������
		while sampIsDialogActive(6400) do wait(300) end -- ��� ���� �� �������� �� ������
		local result, button, _, input = sampHasDialogRespond(6405)
		if not input:match('(.+) (.+)') and #input ~= 0 then 
			local nick_nakazyemogo = input
			result, button, input = nil
			sampShowDialog(6401, "������� ���������", "���������� ������� ���������� ���� ���������� ��������", "�����������", nil, DIALOG_STYLE_INPUT) -- ��� ������
			while sampIsDialogActive(6401) do wait(300) end -- ��� ���� �� �������� �� ������
			local result, button, _, input = sampHasDialogRespond(6405)
			if not input:match('(.+) (.+)') and #input ~= 0 then 
				local nakazanie = input
				result, button, input = nil
				sampShowDialog(6402, "������� �������", "���������� ������� ������� ����������", "�����������", nil, DIALOG_STYLE_INPUT) -- ��� ������
				while sampIsDialogActive(6402) do wait(300) end -- ��� ���� �� �������� �� ������
				local result, button, _, input = sampHasDialogRespond(6405)
				if input:match('(.+)') and #input ~= 0 then 
					local pri4ina = input
					result, button, input = nil
					find_ip_player = true
					sampSendChat('/offstats ' .. nick_nakazyemogo)
					while not regip do wait(100) end
					wait(1000)
					sampSendChat('/banoff ' .. nick_nakazyemogo .. ' ' .. nakazanie .. ' ' .. pri4ina)
					wait(1000)
					sampSendChat('/banip ' .. regip .. ' ' .. nakazanie .. ' ' .. pri4ina)
					wait(1000)
					sampSendChat('/banip ' .. lastip .. ' ' .. nakazanie .. ' ' .. pri4ina)
					lastip,regip,nick_nakazyemogo,pri4ina,nakazanie = nil
				else
					sampAddChatMessage(tag .. '������ ������� �����������.',-1)
				end
			else
				sampAddChatMessage(tag .. '������ ������� �����������.',-1)
			end
		else
			sampAddChatMessage(tag .. '������ ������� �����������.',-1)
		end
	end)
end)
sampRegisterChatCommand('prfma', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " ��.������������� " .. cfg.settings.prefixma)
	end
end)
sampRegisterChatCommand('prfa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " ������������� " .. cfg.settings.prefixa)
	end
end)
sampRegisterChatCommand('prfsa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " ��.������������� " .. cfg.settings.prefixsa)
	end
end)
sampRegisterChatCommand('prfpga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " ��������.����.�������������� " .. color())
	end
end)
sampRegisterChatCommand('prfzga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " ���.����.�������������� " .. color())
	end
end)
sampRegisterChatCommand('prfga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " �������-������������� " .. color())
	end
end)
sampRegisterChatCommand('prfcpec', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " ����.������������� " .. color())
	end
end)
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
			sampSendChat('/ot ' .. param .. ' �� �������� ��������� �� ������� ������. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' �� �������� ��������� �� ������� ������.')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('dpr', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' � ������ ������� ������� �� /donate ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' � ������ ������� ������� �� /donate')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('c', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' �����(�) ������ ��� ����� �������. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' �����(�) ������ ��� ����� �������.')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('cl', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' ������ ����� ����. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ������ ����� ����.')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('nak', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' ����� ��� �������, ������� �� ���������. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ����� ��� �������, ������� �� ���������.')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('pmv', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' ������� ���. ����������� ��� ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ������� ���. ����������� ���')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('afk', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' ����� ������������ ��� ��������� � AFK ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ����� ������������ ��� ��������� � AFK')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('nv', function(param) 
	if #param ~= 0 then
		if cfg.settings.add_answer_report then
			sampSendChat('/ot ' .. param .. ' ����� �� � ���� ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ����� �� � ����')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('stw', function(param) 
	if #param ~= 0 then
		sampSendChat("/setweap " .. param .. " 38 5000")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('fo', function(param)
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' ���������� � ������ ��������� �� ����� https://forumrds.ru')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('uu', function(param) 
	if #param ~= 0 then
		sampSendChat('/unmute ' .. param) 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('uj', function(param) 
	if #param ~= 0 then
		sampSendChat('/unjail ' .. param) 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('ur', function(param) 
	if #param ~= 0 then
		sampSendChat('/unrmute ' .. param) 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('al', function(param) 
	if #param ~= 0 then
		lua_thread.create(function()
			sampSendChat('/ans ' .. param .. ' ������������! �� ������ ������ /alogin!')
			wait(500)
			sampSendChat('/ans ' .. param .. ' ������� ������� /alogin � ���� ������, ����������.')
		end)
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rep', function(param) 
	if #param ~= 0 then
		lua_thread.create(function()
			sampSendChat('/ans ' .. param .. ' ������ ������ ��� ������������ �� ������ �� ������ � /report')
			wait(500) 
			sampSendChat('/ans ' .. param .. ' ������������� ����� ����� ��� ������.')
		end)
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('as', function(param) 
	if #param ~= 0 then
		sampSendChat('/aspawn ' .. param)
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)

----======================= ������������� ��� ����� ���� ===============------------------
sampRegisterChatCommand('m', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 300 ����������� �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('mf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 300 ����������� �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('m2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 600 ����������� ������� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('m3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 900 ����������� ������� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('ok', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 400 �����������/��������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('okf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 400 �����������/��������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('ok2', function(param) 
	if #param ~= 0 then
 		sampSendChat('/mute ' .. param .. ' 800 �����������/�������� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('ok3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1200 �����������/�������� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('fd', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('fdf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('fd2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 240 ���� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('fd3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 ���� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('or', function(param) 
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 5000 �����������/���������� ������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('orf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 �����������/���������� ������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('up', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1000 ���������� ��������� ��������')
		sampAddChatMessage(tag .. '������������� �������� ��� �������� /cc', -1)
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('upf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 ���������� ��������� ��������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('oa', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 2500 ����������� �������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('oaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 ����������� �������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('kl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 3000 ������� �� �������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('klf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 3000 ������� �� �������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('po', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 ����������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('pof', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 ����������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('po2', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 240 ���������������� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('po3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 ���������������� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('zs', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 600 ��������������� ���������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('zsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 600 ��������������� ���������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('nm', function(param)
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 600 ������������ ���������.')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rekl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 1000 �������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('reklf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rz', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 5000 ������ ������. �����")
	else 
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 ������ ������. �����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('ia', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 2500 ������ ���� �� ��������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('iaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 ������ ���� �� ��������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
----======================= ������������� ��� ����� ������� ===============------------------
sampRegisterChatCommand('oft', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('oftf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('oft2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Offtop in /report x2")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('oft3', function(param) 
	if param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Offtop in /report x3")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('cp', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('cpf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('cp2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Caps in /report x2")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('cp3', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Caps in /report x3")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('roa', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 2500 ����������� �������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('roaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 2500 ����������� �������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('ror', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 �����������/���������� ������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rorf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 �����������/���������� ������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rzs', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 600 ��������������� ���������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rzsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 600 ��������������� ���������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rrz', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 ������ ���.���. �����")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rrzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 ������ ���.���. �����")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rpo', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 ����������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rpof', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 ����������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rm', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 300 ��� � /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 300 ����������� �������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rok', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 400 ����������� � /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('rokf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 400 ����������� � /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
----======================= ������������� ��� ������ ===============------------------
sampRegisterChatCommand('dz', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ��/�� � ������� ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('dzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ��/�� � ������� ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('dz2', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 600 ��/�� � ������� ���� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('dz3', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 ��/�� � ������� ���� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('zv', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. " 3000 ��������������� VIP'��")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('dmp', function(param)
	if #param ~= 0 then
		sampSendChat("/jail " .. param .. " 3000 ��������� ������ �� ��")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('zvf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 3000 ��������������� VIP'o�")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('sk', function(param)
	if #param ~= 0 then 
		sampSendChat('/jail ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('skf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('dk', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 �� ���� � ������� ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('dkf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 �� ���� � ������� ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('td', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 car in /trade')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('tdf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 300 Car in /trade")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('jcb', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 3000 ���')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('jcbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 3000 ���')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('jm', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ��������� ������ ��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('jmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ��������� ������ ��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('jc', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 ��������� ������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('jc2', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 1800 ��������� ������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('jc3', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 2700 ��������� ������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('jcf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 ��������� ������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('bg', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('bgf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
----======================= ������������� ��� ���� ===============------------------
sampRegisterChatCommand('bosk', function(param) 
	if #param ~= 0 then
		sampSendChat('/siban ' .. param .. ' 999 ����������� �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('boskf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 ����������� �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('reklama', function(param) 
	if #param ~= 0 then
		sampSendChat('/siban ' .. param .. ' 999 �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('reklamaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('obm', function(param) 
	if #param ~= 0 then
		sampSendChat('/siban ' .. param .. ' 30 �����/������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('obmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 30 �����/������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('nmb', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 ������������ ���������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('nmbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 3 ������������ ���������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('ch', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 7 ������������� ���������� �������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('chf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 7 ������������� ���������� �������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('obh', function(param)
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 7 ����� �������� ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('oskhelper', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 ��������� ������ /helper')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
----======================= ������������� ��� ����� ===============------------------
sampRegisterChatCommand('cafk', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' AFK in /arena') 
		windows.recon_menu.v = false
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('kk1', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' ������� ��� 1/3') 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('kk2', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' ������� ��� 2/3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('kk3', function(param)
	if #param ~= 0 then 
		sampSendChat('/ban ' .. param .. ' 7 ������� ��� 3/3') 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)
sampRegisterChatCommand('jk', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' DM in jail') 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)
	end
end)


function style(id) -- ����
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.IndentSpacing = 25.0
    style.GrabMinSize = 15.0
    style.GrabRounding = 7.0
    style.ChildWindowRounding = 8.0
    style.FrameRounding = 6.0
    if id == 0 then -- �����-�����
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
    elseif id == 1 then -- �������
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
    elseif id == 2 then -- ������� ����
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
    elseif id == 3 then -- ���������
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
	elseif id == 4 then -- ������� ����
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
    elseif id == 5 then -- ������� ����
		colors[clr.Text]                   = ImVec4(2.00, 2.00, 2.00, 1.00)
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
		colors[clr.Button]                 = ImVec4(0.41, 0.55, 0.78, 0.50)
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
--------- ��� ID � ���� ���� ----------- (���� ������ ������ ���.)
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
