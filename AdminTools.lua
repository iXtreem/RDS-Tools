require 'lib.moonloader' --
require 'lib.sampfuncs' 
script_name 'AdminTool'  
script_author 'Neon4ik' 
script_properties("work-in-pause") 
local version = 2.34
local function recode(u8) return encoding.UTF8:decode(u8) end -- ���������� ��� ���������������
local imgui = require 'imgui' 
local sampev = require 'lib.samp.events'
local mimgui = require "mimgui"
local inicfg = require 'inicfg'
local directIni = 'AdminTools.ini'
local notify = import("\\lib\\lib_imgui_notf.lua")
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local vkeys = require 'vkeys'
local ffi = require "ffi"
local mem = require "memory"
local font = require ("moonloader").font_flag
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local trassera = import ("\\resource\\trassera.lua") -- ��������� ���������
local mp = import ("\\resource\\AdminToolsMP.lua") -- ��������� ������� ��� �����������
local fastspawn = import ('\\resource\\AT_FastSpawn.lua')
local fonts = renderCreateFont('TimesNewRoman', 12, 5) -- ����� ��� ��������
local tag = '{2B6CC4}Admin Tools: {F0E68C}'
local cfg = inicfg.load({ -- ������� ��������� �������
	settings = {
		style = 0,
		autoonline = false,
		inputhelper = true,
		prefixma = '2E8B57',
		prefixa = '87CEEB',
		prefixsa = 'FF4500',
		weaponhack = false,
		doptext = true,
		automute = false,
		renderadminx = 20,
		renderadminy = 500,
		checkadmins = false,
		mytextreport = ' // �������� ���� �� RDS <3',
		customposx = false,
		customposy = false,
		keysync = true,
		ans = 'None',
		tr = 'None',
		wh = 'None',
		agm = 'None',
		rep = 'None',
		wallhack = true,
		ansreport = false,
		bloknotik = '',
		acon = false,
		chatposx = nil,
		chatposy = nil,
		size = 10,
		autosave = false,
		slejkaform = false,
		stylecolor = '{FFFFFF}',
		stylecolorform = '{FF0000}',
		ban = false,
        jail = false,
        mute = false,
        kick = false,
        prefix = false
	},
	customotvet = {

	},
	osk = {
		[1] = '���'	
	},
	mat = {
		[1] = '���'
	}
}, directIni)
inicfg.save(cfg,directIni)
local checkbox = {
	checked_test1 = imgui.ImBool(cfg.settings.automute),
	checked_test2 = imgui.ImBool(cfg.settings.keysync),
	checked_test3 = imgui.ImBool(cfg.settings.autoonline),
	checked_test4 = imgui.ImBool(cfg.settings.slejkaform),
	checked_test5 = imgui.ImBool(cfg.settings.autosave),
	checked_test6 = imgui.ImBool(cfg.settings.checkadmins),
	checked_test7 = imgui.ImBool(cfg.settings.ansreport),
	checked_test8 = imgui.ImBool(cfg.settings.acon),
	checked_test9 = imgui.ImBool(cfg.settings.ban),
	checked_test10 = imgui.ImBool(cfg.settings.jail),
	checked_test11 = imgui.ImBool(cfg.settings.mute),
	checked_test12 = imgui.ImBool(cfg.settings.kick),
	checked_test13 = imgui.ImBool(cfg.settings.inputhelper),
	checked_test14 = imgui.ImBool(cfg.settings.wallhack),
	checked_test15 = imgui.ImBool(cfg.settings.doptext),
	checked_test16 = imgui.ImBool(cfg.settings.prefix),
	checked_test17 = imgui.ImBool(cfg.settings.weaponhack)
}
local buffer = {
	text_buffer = imgui.ImBuffer(256),
	customotv = imgui.ImBuffer(256),
	findcustomotv = imgui.ImBuffer(256),
	newmat = imgui.ImBuffer(256),
	newosk = imgui.ImBuffer(256),
	doptexts = imgui.ImBuffer(u8(cfg.settings.mytextreport), 256),
	PrefixMa = imgui.ImBuffer(cfg.settings.prefixma, 256),
	PrefixA = imgui.ImBuffer(cfg.settings.prefixa, 256),
	PrefixSa = imgui.ImBuffer(cfg.settings.prefixsa, 256),
	bloknotik = imgui.ImBuffer(cfg.settings.bloknotik, 4096),
}
local windows = {
	main_window_state = imgui.ImBool(false),
	tree_window_state = imgui.ImBool(false),
	four_window_state = imgui.ImBool(false),
	fourtwo_window_state = imgui.ImBool(false),
	five_window_state = imgui.ImBool(false),
	ban_window_state = imgui.ImBool(false),
	mute_window_state = imgui.ImBool(false),
	jail_window_state = imgui.ImBool(false),
	helperma_window_state = imgui.ImBool(false),
	ansreport_window_state = imgui.ImBool(false),
	kick_window_state = imgui.ImBool(false),
	rmute_window_state = imgui.ImBool(false),
	custom_otvet_state = imgui.ImBool(false),
	ac_window_state = imgui.ImBool(false),
	dopcustomreport_window_state = imgui.ImBool(false),
	checkadm_window_state = imgui.ImBool(false),
	six_window_state = imgui.ImBool(false)
}
local answer = {}
local nakazatreport = {}
local style_selected = imgui.ImInt(cfg.settings.style)
local style_list = {u8"�����-����� ����", u8"������� ����", u8"������� ����", u8"��������� ����", u8"������� ����", u8"������� ����"}
local sw, sh = getScreenResolution()
local selected_item = imgui.ImInt(cfg.settings.size)
local st = { -- ������ ��� ��������
}
local spisok = { -- ������ ��� ��������
	'ban',
	'jail',
	'kick',
	'mute',
	'spawncars',
	'aspawn'
}
local spisokproject = { -- ������ �������� �� ������� ���� �������
	[1] = '������',
	[2] = '���� ����',
	[3] = '���� ����',
	[4] = '������',
	[5] = '������',
	[6] = '������',
	[7] = '���',
	[8] = 'arz'
}
local spisokoskrod = { -- ������ ���.��� �� ������� ���� �������
	[1] = 'mq',
	[2] = 'rnq'
}
local target = -1
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
 	font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
	func0 = lua_thread.create_suspended(ac0)
	func1 = lua_thread.create_suspended(ac1)
	func2 = lua_thread.create_suspended(ac2)
	func3 = lua_thread.create_suspended(ac3)
	func4 = lua_thread.create_suspended(ac4)
	func5 = lua_thread.create_suspended(ac5)
	func6 = lua_thread.create_suspended(HelperMA)
	if cfg.settings.ban or cfg.settings.mute or cfg.settings.jail or cfg.settings.mute then
		func6:run()
	end
	func = lua_thread.create_suspended(ao)
	funcadm = lua_thread.create_suspended(checkadmins)
	funct = lua_thread.create_suspended(timer)
	funct:run()
	func10 = lua_thread.create_suspended(warnings_form)
	if cfg.settings.autoonline then
		func:run()
	end
	if not cfg.settings.renderadminx then
		cfg.settings.renderadminx, cfg.settings.renderadminy = (100), (100)
	end
	font_watermark = renderCreateFont("Javanese Text", 8, font.BOLD + font.BORDER + font.SHADOW)
	lua_thread.create(function()
		while true do 
			wait(1)
			if not isPauseMenuActive() then
				renderFontDrawText(font_watermark, tag .. '{A9A9A9}version['.. version .. ']', 10, sh-20, 0xCCFFFFFF)
			end
		end	
	end)
	local dlstatus = require('moonloader').download_status
	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.ini" -- ������ �� ������
	local update_path = getWorkingDirectory() .. "/AdminTools.ini" -- � ��� �� �� ����� ������
	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.lua" -- ������ �� ��� ����
	local script_path = thisScript().path
    downloadUrlToFile(update_url, update_path, function(id, status)
		lua_thread.create(function()
			wait(1000)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				AdminTools = inicfg.load(nil, update_path)
				wait(1000)
				if tonumber(AdminTools.script.version) > version then
					update_state = true
				end
				wait(1000)
				os.remove(update_path)
			end
		end)
    end)
	sampRegisterChatCommand('update', function()
		if update_state then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage(tag .. '������ ������� ��������.')
					showCursor(false,false)
					thisScript():reload()
				end
			end)
		else
			sampAddChatMessage(tag .. '� ��� ����������� ���������� ������.')
		end
	end)
	imgui.Process = false
	lua_thread.create(inputChat)
	while not sampIsLocalPlayerSpawned() do wait(1000) end
	wait(2000)
	if sampGetCurrentServerAddress() == '46.174.52.246' then
		sampAddChatMessage(tag .. '������ ������� ��������. ��������� F3 ��� /tool', -1)
	elseif sampGetCurrentServerAddress() == '46.174.49.170' then
		sampAddChatMessage(tag .. '������ ������� ��������. ��������� F3 ��� /tool', -1)
		server03 = true
	elseif sampGetCurrentServerAddress() == '46.174.49.47' then
		sampAddChatMessage(tag .. '������ ������� ��������. ��������� F3 ��� /tool', -1)
	else
		sampAddChatMessage(tag .. '� ������������ ��� RDS, ��� � ���� ��������.', -1)
		if cfg.settings.wallhack then
			sampSendInputChat('/wh ')
		end
		wait(100)
		sampSendInputChat('/trasoff ')
		wait(100)
		sampSendInputChat('/fsoff ')
		showCursor(false,false)
		imgui.Process = false
		thisScript():unload()
	end
	if cfg.settings.checkadmins then
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
	while true do
        wait(0)
		if isPauseMenuActive() or isGamePaused() then
			activeam = true
		end
		if activeam and not (isPauseMenuActive() or isGamePaused()) then
			activeam = nil
		end
		if isKeyJustPressed(0x54 --[[VK_T]]) and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
			sampSetChatInputEnabled(true)
		end
		while st.sett do
			wait(50)
			if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() then
				if sampIsPlayerConnected(st.idadmin) then
					if st.forumplease then
						cheater = string.match(forma, '%d[%d.,]*')
						sampSendChat('/ans ' .. st.cheater .. ' ��������� ' .. sampGetPlayerNickname(st.cheater) .. ', �� �������� ������� �������.')
						sampSendChat('/ans ' .. st.cheater .. ' ���� �� �� �������� � ����������, �������� ������ �� https://forumrds.ru')
					end
					if not st.styleform then
						sampSendChat(forma .. ' // ' .. st.nicknameform)
					else
						sampSendChat(forma)
					end
					sampSendChat('/a Admin Tools: ����� ������.')
				else
					sampAddChatMessage(tag .. '������������� �� � ����.', -1)
				end
				forma = nil
				st = {}
			end
			if isKeyDown(VK_J) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampAddChatMessage(tag .. '����� ���������', -1)
				forma = nil
				st = {}
			end
		end
		if isKeyJustPressed(VK_F3) and not sampIsDialogActive() then  -- ������ ��������� ����
			windows.main_window_state.v = not windows.main_window_state.v
			imgui.Process = true
			showCursor(true,false)
		end
		if cfg.settings.wallhack and not activeam then
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
		if isKeyJustPressed(strToIdKeys(cfg.settings.ans)) and not isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() and not windows.main_window_state.v then
			sampSendChat("/ans")
			sampSendDialogResponse (2348, 1, 0)
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.tr)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not windows.main_window_state.v then
			sampSendChat("/tr")
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.wh)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not windows.main_window_state.v then
			sampSendChat('/spveh 100')
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.agm)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsDialogActive() and not windows.main_window_state.v then
			sampSetChatInputText(string.sub(sampGetChatInputText(), 1, -2) .. ' '.. cfg.settings.mytextreport)
			sampSetChatInputEnabled(true)
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.rep)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not windows.main_window_state.v then
			sampSendInputChat('/wh')
		end
	end
end

function ao()
	while true do
		if cfg.settings.autoonline then
			wait(61000)
			while sampIsDialogActive() or sampIsChatInputActive() do
				wait(0)
			end
			wait(500)
			if not activeam then
				sampSendChat("/online")
			end
		end
	end
end

function sampSendInputChat(text) -- �������� � ��� ����� �6
	sampSetChatInputText(text)
	sampSetChatInputEnabled(true)
	setVirtualKeyDown(13, true)
	setVirtualKeyDown(13, false)
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
function color() -- ������ �������
    mcolor = ""
    math.randomseed( os.time() )
    for i = 1, 6 do
        local b = math.random(1, 16)
        if b == 1 then
            mcolor = mcolor .. "A"
        end
        if b == 2 then
            mcolor = mcolor .. "B"
        end
        if b == 3 then
            mcolor = mcolor .. "C"
        end
        if b == 4 then
            mcolor = mcolor .. "D"
        end
        if b == 5 then
            mcolor = mcolor .. "E"
        end
        if b == 6 then
            mcolor = mcolor .. "F"
        end
        if b == 7 then
            mcolor = mcolor .. "0"
        end
        if b == 8 then
            mcolor = mcolor .. "1"
        end
        if b == 9 then
            mcolor = mcolor .. "2"
        end
        if b == 10 then
            mcolor = mcolor .. "3"
        end
        if b == 11 then
            mcolor = mcolor .. "4"
        end
        if b == 12 then
            mcolor = mcolor .. "5"
        end
        if b == 13 then
            mcolor = mcolor .. "6"
        end
        if b == 14 then
            mcolor = mcolor .. "7"
        end
        if b == 15 then
            mcolor = mcolor .. "8"
        end
        if b == 16 then
            mcolor = mcolor .. "9"
        end
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
local w = { -- ������ ������ ��� �������
    second = 150,
}
local menu = {true, -- ����� ����
    false,
}
local menu2 = {true, -- ����� ����
    false,
	false,
	false,
	false,
	false,
	false,
}

function imgui.OnDrawFrame()
	if not windows.checkadm_window_state.v and not windows.main_window_state.v and not windows.tree_window_state.v and not windows.four_window_state.v and not windows.helperma_window_state.v and not windows.fourtwo_window_state.v and not windows.five_window_state.v and not windows.ac_window_state.v and not windows.ansreport_window_state.v and not windows.dopcustomreport_window_state.v then
		if cfg.settings.keysync then
			sampSendInputChat('/keysync off')
		end
		showCursor(false,false)
		imgui.Process = false
		if cfg.settings.checkadmins then
			sampSendChat('/admins')
		end
	end
	if windows.main_window_state.v then -- ������ ���������� F3
		if windows.checkadm_window_state.v then
			windows.checkadm_window_state.v = false
		end
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(315, 355), imgui.Cond.FirstUseEver)
		imgui.Begin('xX   ' .. " Admin Tools " .. '  Xx', windows.main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
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
			if imgui.Checkbox(u8'����.�������', checkbox.checked_test2) then
				cfg.settings.keysync = not cfg.settings.keysync
				inicfg.save(cfg,directIni)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"autoonline", checkbox.checked_test3) then
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
			if imgui.Checkbox(u8"input helper", checkbox.checked_test13) then
				cfg.settings.inputhelper = not cfg.settings.inputhelper
				inicfg.save(cfg,directIni)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"WallHack", checkbox.checked_test14) then
				if cfg.settings.wallhack == true then
					sampSendInputChat('/wh ')
				else
					sampSendInputChat('/wh ')
				end
			end
			if imgui.Checkbox(u8"AdminChat", checkbox.checked_test8) then
				if cfg.settings.acon then
					cfg.settings.acon = not cfg.settings.acon
					inicfg.save(cfg,directIni)
					func0:terminate()
					func1:terminate()
					func2:terminate()
					func3:terminate()
					func4:terminate()
					func5:terminate()
				else
					cfg.settings.acon = not cfg.settings.acon
					inicfg.save(cfg,directIni)
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8'�����', checkbox.checked_test4) then
				if not server03 then
					cfg.settings.slejkaform  = not cfg.settings.slejkaform
					inicfg.save(cfg,directIni)
				else
					checkbox.checked_test4 = imgui.ImBool(false)
				end
			end
			if imgui.Checkbox(u8'�������', checkbox.checked_test1) then
				if cfg.settings.automute then
					cfg.settings.automute  = not cfg.settings.automute
					inicfg.save(cfg,directIni)
				else
					cfg.settings.automute  = not cfg.settings.automute
					inicfg.save(cfg,directIni)
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"�������.������", checkbox.checked_test7) then
				cfg.settings.ansreport = not cfg.settings.ansreport
				inicfg.save(cfg,directIni)
			end
			if imgui.Checkbox(u8"������ /admins", checkbox.checked_test6) then
				if cfg.settings.checkadmins then
					cfg.settings.checkadmins = not cfg.settings.checkadmins
					inicfg.save(cfg,directIni)
					admins = nil
					windows.checkadm_window_state.v = false
					funcadm:terminate()
				else
					cfg.settings.checkadmins = not cfg.settings.checkadmins
					inicfg.save(cfg,directIni)
					funcadm:run()
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"Weapon Hack", checkbox.checked_test17) then
				cfg.settings.weaponhack = not cfg.settings.weaponhack
				inicfg.save(cfg,directIni)
			end
			if update_state then
				if imgui.Button(u8'�������� ������', imgui.ImVec2(300, 24)) then
					windows.main_window_state.v = false
					imgui.Process = false
					sampSendInputChat('/update')
				end
			end
			imgui.Separator()
			imgui.Text(u8'����������� ������� - N.E.O.N [RDS 01]\n�������� ����� ������� ����\n')
			if imgui.Link("https://vk.com/alexandrkob", u8"�����, ����� ������� ������ � ��������") then
				os.execute(('explorer.exe "%s"'):format("https://vk.com/alexandrkob"))
			end
		end
		if menu2[3] then
			imgui.SetCursorPosX(10)
			imgui.Text(u8'��.�������������')
			imgui.SameLine()
			imgui.SetCursorPosX(150)
			imgui.PushItemWidth(100)
			if imgui.InputText('   ', buffer.PrefixMa) then
				cfg.settings.prefixma = buffer.PrefixMa.v
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.SetCursorPosX(10)
			imgui.Text(u8'�������������')
			imgui.SameLine()
			imgui.SetCursorPosX(150)
			imgui.PushItemWidth(100)
			if imgui.InputText(' ', buffer.PrefixA) then
				cfg.settings.prefixa = buffer.PrefixA.v
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.Text(u8'��.�������������')
			imgui.SameLine()
			imgui.SetCursorPosX(150)
			imgui.PushItemWidth(100)
			if imgui.InputText('  ', buffer.PrefixSa) then
				cfg.settings.prefixsa = buffer.PrefixSa.v
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.Text(u8'\n')
			imgui.CenterText(u8'�������������� ����� ������')
			imgui.PushItemWidth(300)
			if imgui.InputText('', buffer.doptexts) then
				cfg.settings.mytextreport = u8:decode(buffer.doptexts.v)
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			if imgui.Button(u8'��������� ������� Recon Menu', imgui.ImVec2(300, 24)) then
				if windows.four_window_state.v then
					windows.four_window_state.v = not windows.four_window_state.v
					windows.fourtwo_window_state.v = not windows.fourtwo_window_state.v
				else
					sampAddChatMessage(tag .. '������� � ������ �� ��������� ����������', -1)
				end
			end
			if cfg.settings.checkadmins then
				if imgui.Button(u8'��������� ������� ������� /admins', imgui.ImVec2(300, 24)) then
					windows.six_window_state.v = true
				end
			end
			if cfg.settings.acon then
				if imgui.Button(u8'��������� ������� �����-����', imgui.ImVec2(300, 24)) then
					windows.ac_window_state.v = not windows.ac_window_state.v
				end
			end
			if cfg.settings.keysync then
				if imgui.Button(u8'��������� ������� ����.������', imgui.ImVec2(300, 23)) then
					windows.five_window_state.v = not windows.five_window_state.v 
				end
			end
			if imgui.Button(u8'��������� ������ ' .. fa.ICON_POWER_OFF, imgui.ImVec2(300, 23)) then
				lua_thread.create(function()
					windows.main_window_state.v = false
					if cfg.settings.wallhack then
						sampSendInputChat('/wh ')
					end
					wait(100)
					sampSendInputChat('/trasoff ')
					showCursor(false,false)
					imgui.Process = false
					thisScript():unload()
				end)
			end
		end
		if menu2[4] then
			buffer.bloknotik.v = string.gsub(buffer.bloknotik.v, "\\n", "\n")
			if imgui.InputTextMultiline("#1", buffer.bloknotik, imgui.ImVec2(310, 280)) then
				buffer.bloknotik.v = string.gsub(buffer.bloknotik.v, "\n", "\\n")
				cfg.settings.bloknotik = buffer.bloknotik.v
				inicfg.save(cfg,directIni)	
			end
		end
		if menu2[5] then
			imgui.SetCursorPosX(10)
			imgui.CenterText(u8'�������� �������:')
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.ans))
			if imgui.Button(u8"�ox�a����.", imgui.ImVec2(300, 24)) then
				cfg.settings.ans = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8'���/���� �������� �������')
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.tr))
			if imgui.Button(u8"��x�a����.", imgui.ImVec2(300, 24)) then
				cfg.settings.tr = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8"������� ����������: ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.wh))
			if imgui.Button(u8"C�x�a����.", imgui.ImVec2(300, 24)) then
				cfg.settings.wh = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8"�������� � ��� ���.������")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.agm))
			if imgui.Button(u8"Cox�a����.", imgui.ImVec2(300, 24)) then
				cfg.settings.agm = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8"���/���� WallHack ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.rep))
			if imgui.Button(u8"��xpa����.", imgui.ImVec2(300, 24)) then
				cfg.settings.rep = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.Separator()
			if imgui.Button(u8"�������� ��� ��������.", imgui.ImVec2(300, 24)) then
				cfg.settings.rep = 'None'
				cfg.settings.ans = 'None'
				cfg.settings.wh = 'None'
				cfg.settings.agm = 'None'
				cfg.settings.tr = 'None'
				inicfg.save(cfg,directIni)
			end
		end
		if menu2[7] then
			imgui.Columns(2)
				imgui.SetColumnWidth(-1, w.second)
				imgui.Text(u8'      ����� �� /gw')
				if imgui.Button(u8'Aztecas vs Ballas', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Ballas Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Aztecas vs Grove', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Grove Street Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Aztecas vs Vagos', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Vagos Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Aztecas vs Rifa', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs The Rifa ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Ballas vs Grove', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Ballas Gang vs Grove Street Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Ballas vs Vagos', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Ballas Gang vs Vagos Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Ballas vs Rifa', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Ballas Gang vs The Rifa ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Grove vs Vagos', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Grove Street Gang vs Vagos Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Vagos vs Rifa', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Vagos Gang vs The Rifa ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				imgui.NextColumn()
				imgui.SetColumnWidth(-1, w.second)
				imgui.Text(u8'       ����� �����')
				if imgui.Button(u8'����� ����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 10 --------=================== Spawn Auto ================-----------')
					sampSendChat('/mess 15 �������������� �������� � ���������')
					sampSendChat('/mess 15 ����� 15 ������ ������ ������� ����� ���������� �� �������.')
					sampSendChat('/mess 15 ������� ���� ����� ���� �� ��������� ������ :3')
					sampSendChat('/mess 10 --------=================== Spawn Auto ================-----------')
					sampSendChat('/delcarall')
					sampSendChat('/spawncars 15')
				end
				if imgui.Button(u8'/trade', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 3 -----========================= ����� =====================-------')
					sampSendChat('/mess 0 ������ ���������� ����������� �� ���� ����?')
					sampSendChat('/mess 0 ������ � ������ ������������ �� ����� � �������� ��� ��������?')
					sampSendChat('/mess 0 ������ ����� /trade, ������� ����� ������������, ��� �� �������, ��� � �� �������!')
					sampSendChat('/mess 3 -----========================= ����� =====================-------')
				end
				if imgui.Button(u8'��������������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 16 --------=================== �������������� ================-----------')
					sampSendChat('/mess 17 ������ ������ ���������� ���� �� ���� ���������? �� ��������!')
					sampSendChat('/mess 17 � �������������� �� /tp - ������ - �������������� �������� � �� �����.')
					sampSendChat('/mess 17 ������ ������� ������ ��������� ��� ���� ���� � ����')
					sampSendChat('/mess 16 --------=================== �������������� ================-----------')
				end
				if imgui.Button(u8'������/�����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 -------============= ��������� �������� ==========-----------------')
					sampSendChat('/mess 7 � ������ ������� ������� ������ vk.�om/teamadmrds ...')
					sampSendChat('/mess 7 ... � ���� �����, �� ������� ������ ����� �������� ������ �� ������������� ��� �������.')
					sampSendChat('/mess 7 ����� �� ��������� � ���� ������ �������.')
					sampSendChat('/mess 11 -------============= ���������� ==========-----------------')
				end
				if imgui.Button(u8'VIP', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 13 --------============ ������������ VIP ===========------------------')
					sampSendChat('/mess 7 ������ ������ � �������� ��� �����������?')
					sampSendChat('/mess 7 ������ ������ ����������������� �� ����� � � �������, ����� ���� ������ ������?')
					sampSendChat('/mess 7 ������ �������� ������ PayDay ������ �� ���� �������? ���������� VIP-��������!')
					sampSendChat('/mess 13 --------============ ������������ VIP ===========------------------')
				end
				if imgui.Button(u8'�����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 12 -------============= PVP Arena ==========-----------------')
					sampSendChat('/mess 10 �� ������ ��� ��������? ������� ������ � ������� �������?')
					sampSendChat('/mess 10 ����� /arena � ������ �� ��� �� ��������!')
					sampSendChat('/mess 10 ����� ������������ ���������� ������, ������� ������ � ����� +C')
					sampSendChat('/mess 12 -------============= PVP Arena ==========-----------------')
				end
				if imgui.Button(u8'����������� ���', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------============ ���� ����������� ��� ===========------------------')
					sampSendChat('/mess 15 ������ ������? ��������� ���������� ����� � �������?')
					sampSendChat('/mess 15 ������� ������ ����� �� ������� �� ����� ������?')
					sampSendChat('/mess 15 ����� ����! ����� /dt [0-999] � ������ � ���������.')
					sampSendChat('/mess 8 --------============ ���� ����������� ��� ===========------------------')
				end
				if imgui.Button(u8'����� �� �������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 3 -------============= ����� �� ���� �������������� ==========-----------------')
					sampSendChat('/mess 2 ������ ������ �� ���� ��������������? ������� ������ �� ������� � �����������?')
					sampSendChat('/mess 2 �� ��� �������� � ���������� ��������� <3')
					sampSendChat('/mess 2 �� ����� ������ https://forumrds.ru/ ������ �����, ����� ������ ������, ���-�� ���� ����������.')
					sampSendChat('/mess 3 -------============= ����� �� ���� �������������� ==========-----------------')
				end
				if imgui.Button(u8'� /report', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 17 --------========== ����� � �������������� ==========----------')
					sampSendChat('/mess 13 ����� ������, ��������� ����������, �����, ��� ������ ������ ������?')
					sampSendChat('/mess 13 �������� ������ � ������������ ������� ��� ��� �������?')
					sampSendChat('/mess 13 ������������� �������! ���� /report � ���� ������/������')
					sampSendChat('/mess 17 --------========== ����� � �������������� ==========----------')
				end
				imgui.Separator()
				imgui.Text(u8'����������� /join')
				if imgui.Button(u8'�����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== ����������� ����� ================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� �����')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 1')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------=================== ����������� ����� ================-----------')
				end
				if imgui.Button(u8'������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== ����������� /parkour ================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ������')
					sampSendChat('/mess 0 ����� ������� ������� ����� /parkour ���� /join - 2')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------=================== ����������� /parkour ================-----------')
				end
				if imgui.Button(u8'PUBG', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== ����������� /pubg ================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� Pubg')
					sampSendChat('/mess 0 ����� ������� ������� ����� /pubg ���� /join - 3')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------=================== ����������� /pubg ================-----------')
				end
				if imgui.Button(u8'DAMAGE DEATHMATCH', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== ����������� /damagegm ================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� DAMAGE DEATHMATCH')
					sampSendChat('/mess 0 ����� ������� ������� ����� /damagegm ���� /join - 4')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------=================== ����������� /damagegm ================-----------')
				end
				if imgui.Button(u8'KILL DEATHMATCH', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== ����������� KILL DEATHMATCH ================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� DAMAGE DEATHMATCH')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 5')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------=================== ����������� KILL DEATHMATCH ================-----------')
				end
				if imgui.Button(u8'Paint Ball', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== ����������� Paint Ball ================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� Paint Ball')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 7')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------=================== ����������� Paint Ball ================-----------')
				end
				if imgui.Button(u8'����� vs �����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== ����� ������ ����� ================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ����� ������ �����')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 8')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------=================== ����� ������ ����� ================-----------')
				end
				if imgui.Button(u8'������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== ����������� ������ ================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ������')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 10')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------=================== ����������� ������ ================-----------')
				end
				if imgui.Button(u8'���������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== ����������� ��������� ================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ���������')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 11')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------=================== ����������� ��������� ================-----------')
				end
		end
		imgui.PopFont()
		if menu2[2] then
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'�������� ���� �����', imgui.ImVec2(300, 24)) and #buffer.customotv.v~=0 then
				key = #cfg.customotvet + 1
				cfg.customotvet[key] = u8:decode(buffer.customotv.v)
				inicfg.save(cfg,directIni)
				buffer.customotv.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.NewInputText('##SearchBar2', buffer.customotv, 300, u8'������� ��� �����.', 2)
			imgui.Separator()
			imgui.CenterText(u8'����������� ������')
			for k,v in pairs(cfg.customotvet) do
				if imgui.Button(u8(v), imgui.ImVec2(300, 24)) then
					cfg.customotvet[k] = nil
					cfg.customotvet[v] = nil
					inicfg.save(cfg,directIni)
				end
			end
		end
		if menu2[6] then
			imgui.CenterText(u8'������')
			imgui.Text(u8'/tool - ������� ���� �������\n/wh - ���/���� ������� WallHack')
			imgui.Separator()
			imgui.CenterText(u8'��������������� �������')
			imgui.Text(u8'/n - �� �������� ��������� �� ������\n/nak - ����� �������\n/fo - ���������� �� �����\n/afk - ����� ��������� � ��� ��� ������������\n/pmv - ������� ���\n/dpr - ����� ������������\n/rep - �������� ������ � ������� ������� /report\n/c - �����(�) ������ ��� ����� �������\n/cl - ������ ����� ����\n/uj - ����� �����\n/nv - ����� �� � ����\n/prfma - ������ �������� ��.������\n/prfa - ������ ������� ������\n/prfsa - ������ ������� ��.������\n/prfpga - ������ ������� ���\n/prfzga - ������ ������� ���\n/prfga - ������ ������� ��\n/prfcpec - ������ ������� �����\n/stw - ������ �������\n/ur - ����� ��� �������\n/uu - ������ ����\n/al - ��������� �������������� ��� /alogin\n/as - ���������� ������\n/spp - ���������� ���� � �������\n/sbanip - ��� ������ ��� �� ���� � IP (��!)')
			imgui.Separator()
			imgui.CenterText(u8'������ ��� ����')
			imgui.Text(u8'/m - /m3 ���\n/ok - /ok3 �����������\n/fd - /fd3 ����\n/nm - ������������ ���������(600)\n/or - ���/���� ������\n/up - ���������� ������� � �������� ����\n/oa - ����������� �������������\n/kl - ������� �� �������������\n/po - /po3 - ����������������\n/rekl - �������\n/zs - ��������������� ���������\n/rz - ������\n/ia - ������ ���� �� �������������')
			imgui.Separator()
			imgui.CenterText(u8'������ ��� �������')
			imgui.Text(u8'/oft - /oft3 ������\n/cp - /cp3 ����\n/roa - ����������� �������������\n/ror - ���/���� ���\n/rzs - ��������������� ���������\n/rrz - ������\n/rpo - ����������������\n/rm - ���\n/rok - �����������')
			imgui.Separator()
			imgui.CenterText(u8'�������� � ������')
			imgui.Text(u8'/dz-/dz3 - ��/�� � ������� ����\n/zv - ��������������� VIP ��������\n/sk - �����-����\n/dmp - ��������� ������ �� �����������\n/td - Car in /trade\n/jm - ��������� ������ ��\n/jcb - ������������� ����(������ ����)\n/jc - ���������� ����\n/baguse - ������\n/dk - �� ���� � ������� ����')
			imgui.Separator()
			imgui.CenterText(u8'������� ������')
			imgui.Text(u8'/cafk - ��� �� �����\n/jk - �� � ������\n/kk1 - ������� ��� 1/3\n/kk2 - ������� ��� 2/3\n/kk3 - ������� ��� 3/3 (���)')
			imgui.Separator()
			imgui.CenterText(u8'���������� ��������')
			imgui.Text(u8'/ch - ����\n/bosk - ����������� �������\n/obm - �����/������\n/nmb - ������������ ���������(3 ���)\n/oskhelper - ��������� ������ �������\n/reklama - �������')
			imgui.Separator()
			imgui.Text(u8'������ ��������� � �������� - /okf /mf /dzf')
		end
		if menu2[8] then
			imgui.CenterText(u8'�������� ��� (Enter ��� �������)')
			imgui.PushFont(fontsize)
			imgui.PushItemWidth(240)
			imgui.InputText('                      . ', buffer.newmat)
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(250)
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
					inicfg.save(cfg,directIni)
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. buffer.newmat.v .. ' {F0E68C}���� ������� ��������� � ������ �����.', -1)
					a = nil
				end
				buffer.newmat.v = u8(buffer.newmat.v)
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			if imgui.Button(fa.ICON_BAN, imgui.ImVec2(24,24)) and string.len(u8:decode(buffer.newmat.v)) >= 2 then
				buffer.newmat.v = u8:decode(buffer.newmat.v)
				buffer.newmat.v = buffer.newmat.v:lower()
				buffer.newmat.v = buffer.newmat.v:rlower()
				for k, v in pairs(cfg.mat) do
					if cfg.mat[k] ==buffer.newmat.v then
						cfg.mat[k] = nil
						inicfg.save(cfg,directIni)
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
			imgui.PopFont()
			imgui.CenterText(u8'�������� ����������� (Enter ��� �������)')
			imgui.PushFont(fontsize)
			imgui.PushItemWidth(240)
			imgui.InputText('                  , ', buffer.newosk)
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(250)
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
					inicfg.save(cfg,directIni)
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. buffer.newosk.v .. ' {F0E68C}���� ������� ��������� � ������ �����������', -1)
					a = false
				end
				buffer.newosk.v = u8(buffer.newosk.v)
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			if imgui.Button(fa.ICON_BAN .. ' ', imgui.ImVec2(24,24)) and string.len(u8:decode(buffer.newosk.v)) >= 2 then
				buffer.newosk.v = u8:decode(buffer.newosk.v)
				buffer.newosk.v = buffer.newosk.v:lower()
				buffer.newosk.v = buffer.newosk.v:rlower()
				for k, v in pairs(cfg.osk) do
					if cfg.osk[k] == buffer.newosk.v then
						cfg.osk[k] = nil
						inicfg.save(cfg,directIni)
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
			imgui.PushItemWidth(290)
			if imgui.Combo(u8"", style_selected, style_list, style_selected) then
				style(style_selected.v) -- ��������� ����� �� ��������� �����
				cfg.settings.style = style_selected.v 
				inicfg.save(cfg, directIni) 
			end
			imgui.PopItemWidth()
			imgui.PopFont()
			imgui.Text(u8'������� �������� �� �������� �����(����������).\n���� ��� ���� ������ �� ����� ����� �����\n���������� � ����� ������ ��� ������� %s')
			if imgui.Button(u8'�������������� �������� ����', imgui.ImVec2(300, 24)) and not server03 then
				windows.helperma_window_state.v = not windows.helperma_window_state.v
			end
			if imgui.Button(u8'������� ��������� ������', imgui.ImVec2(300, 24)) then
				sampSendInputChat('/fs')
			end
			if imgui.Button(u8'������� ��������� ���������', imgui.ImVec2(300, 24)) then
				sampSendInputChat('/trassera')
			end
		end
 		imgui.End()
	end
	if windows.ac_window_state.v then -- ���������� ������� ����� ����
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'�����-���', windows.ac_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'��������� ������� ' .. fa.ICON_ARROWS) then
			local pos = imgui.GetWindowPos()
			cfg.settings.chatposx = pos.x
			cfg.settings.chatposy = pos.y
			inicfg.save(cfg,directIni)
		end
		imgui.Text(u8'������: ')
		imgui.SameLine()
		imgui.PushItemWidth(20)
		if imgui.Combo(u8'', selected_item, {'1', '2', '3', '4', '5', '6', '7', '8', '9'}, 9) then
			if selected_item.v == 0 then
			  	cfg.settings.size = 9
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 1 then
				cfg.settings.size = 10
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 2 then
				cfg.settings.size = 11
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 3 then
				cfg.settings.size = 12
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 4 then
				cfg.settings.size = 13
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 5 then
				cfg.settings.size = 14
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 6 then
				cfg.settings.size = 15
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 7 then
				cfg.settings.size = 16
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 8 then
				cfg.settings.size = 17
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Calibri", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
		end
		imgui.PopItemWidth()
		imgui.PopFont()
		imgui.End()
	end
	if windows.tree_window_state.v then -- ������� ����� �� ������
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5) - 250, (sh * 0.5)-90), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'����� �� ������', windows.tree_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8'�����: ' .. autor .. '[' ..autorid.. ']')
		imgui.TextWrapped(u8('������: ') .. u8(textreport))
		if isKeyJustPressed(VK_SPACE) then
			imgui.SetKeyboardFocusHere(-1)
		end
		imgui.NewInputText('##SearchBar', buffer.text_buffer, 370, u8'������� ��� �����.', 2)
		imgui.SameLine()
		imgui.SetCursorPosX(383)
		imgui.Tooltip('Space')
		if imgui.Button(u8'��������� ' .. fa.ICON_SHARE, imgui.ImVec2(120, 25)) then
			if #(u8:decode(buffer.text_buffer.v)) >= 1 then
				if cfg.settings.autosave then
					key = #cfg.customotvet + 1
					cfg.customotvet[key] = u8:decode(buffer.text_buffer.v)
					inicfg.save(cfg,directIni)
				end
				answer.moiotvet = true
			else
				sampAddChatMessage(tag .. '����� �� ����� 1 �������.', -1)
			end
		end
		imgui.Tooltip('Enter')
		imgui.Separator()
		if imgui.Button(u8'�������', imgui.ImVec2(120, 25)) or isKeyJustPressed(VK_Q) then
			answer.rabotay = true
		end
		imgui.Tooltip('Q')
		imgui.SameLine()
		if imgui.Button(u8'�����', imgui.ImVec2(120, 25)) or isKeyJustPressed(VK_E) then
			answer.slejy = true
		end
		imgui.Tooltip(u8'E')
		imgui.SameLine()
		if imgui.Button(u8'������ �����', imgui.ImVec2(120, 25)) or isKeyJustPressed(VK_R) then
			windows.custom_otvet_state.v = not windows.custom_otvet_state.v
		end
		imgui.Tooltip('R')
		imgui.SameLine()
		if imgui.Button(u8'��������', imgui.ImVec2(120, 25)) or isKeyJustPressed(VK_V) then
			answer.peredamrep = true
		end
		imgui.Tooltip('V')
		if imgui.Button(u8'��������', imgui.ImVec2(120, 25)) or isKeyJustPressed(VK_G) then
			if tonumber(autorid) then
				windows.rmute_window_state.v = not windows.rmute_window_state.v
			else
				sampAddChatMessage(tag .. '������ ����� �� � ����. ����������� /rmuteoff', -1)
			end
		end
		imgui.Tooltip('G')
		imgui.SameLine()
		if imgui.Button(u8'�������� ID', imgui.ImVec2(120, 25)) or isKeyJustPressed(VK_T) then
			answer.uto4id = true
		end
		imgui.Tooltip('T')
		imgui.SameLine()
		if imgui.Button(u8'�����', imgui.ImVec2(120, 25)) or isKeyJustPressed(VK_F) then
			answer.uto4 = true
		end
		imgui.Tooltip('F')
		imgui.SameLine()
		if imgui.Button(u8'���������', imgui.ImVec2(120, 25)) then
			answer.otklon = true
		end
		imgui.Separator()
		if imgui.Checkbox(u8'�������� ��� ����� � ������ ' .. fa.ICON_COMMENTING_O, checkbox.checked_test15) or isKeyJustPressed(VK_X) then
			cfg.settings.doptext = not cfg.settings.doptext
			inicfg.save(cfg,directIni)
		end
		if imgui.Checkbox(u8'��������� ������ � ���� ������ ������� ' .. fa.ICON_DATABASE, checkbox.checked_test5) then
			cfg.settings.autosave = not cfg.settings.autosave
			inicfg.save(cfg,directIni)
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.ban_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ���������� ��������", windows.ban_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if not sampIsDialogActive() then
			if imgui.Button(u8'����', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/ch ' .. playerrecon)
				showCursor(false,false)
				windows.four_window_state.v = false
				windows.ban_window_state.v = false
			end
			if imgui.Button(u8'�������������� ��������� (3)', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/iban ' .. playerrecon .. ' 3 ������������ ���������')
				showCursor(false,false)
				windows.four_window_state.v = false
				windows.ban_window_state.v = false
			end
			if imgui.Button(u8'��������� ������ �������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/oskhelper ' .. playerrecon)
				showCursor(false,false)
				windows.four_window_state.v = false
				windows.ban_window_state.v = false
			end
			if imgui.Button(u8'����������� �������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/bosk ' .. playerrecon)
				showCursor(false,false)
				windows.four_window_state.v = false
				windows.ban_window_state.v = false
			end
			if imgui.Button(u8'�������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/reklama ' .. playerrecon)
				showCursor(false,false)
				windows.four_window_state.v = false
				windows.ban_window_state.v = false
			end
			if imgui.Button(u8'�����', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/obm ' .. playerrecon)
				showCursor(false,false)
				windows.four_window_state.v = false
				windows.ban_window_state.v = false
			end
			if imgui.Button(u8'�������� �����', imgui.ImVec2(250, 25)) then
				sampSendChat('/ban ' .. playerrecon .. ' 7 �������� �����')
				showCursor(false,false)
				windows.four_window_state.v = false
				windows.ban_window_state.v = false
			end
		else
			sampAddChatMessage(tag .. '{FFFFFF}�������� ������, ����� ����������.', -1)
		end
		imgui.End()
	end
	if windows.jail_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"�������� ������ � ������", windows.jail_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if not sampIsDialogActive() then
			if imgui.Button(u8'DM/DB in ZZ', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/dz ' .. playerrecon)
				showCursor(false,false)
				windows.jail_window_state.v = false
			end
			if imgui.Button(u8"��������������� VIP'��", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/zv ' .. playerrecon)
				showCursor(false,false)
				windows.jail_window_state.v = false
			end
			if imgui.Button(u8'Spawn Kill', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/sk ' .. playerrecon)
				showCursor(false,false)
				windows.jail_window_state.v = false
			end
			if imgui.Button(u8'Car in trade/ZZ', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/td ' .. playerrecon)
				showCursor(false,false)
				windows.jail_window_state.v = false
			end
			if imgui.Button(u8'���', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/jcb ' .. playerrecon)
				showCursor(false,false)
				windows.jail_window_state.v = false
			end
			if imgui.Button(u8'��� ����������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/jc ' .. playerrecon)
				showCursor(false,false)
				windows.jail_window_state.v = false
			end
			if imgui.Button(u8'�� ���� � ������� ����', imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. ' �� ���� � ������� ����')
				showCursor(false,false)
				windows.jail_window_state.v = false
			end
		else
			sampAddChatMessage(tag .. '�������� ������, ����� ����������.', -1)
		end
		imgui.End()
	end
	if windows.mute_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������������� ��� ������", windows.mute_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if not sampIsDialogActive() then
			if imgui.Button(u8'�����������/��������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/ok ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
			if imgui.Button(u8"���", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/m ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
			if imgui.Button(u8"����", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/fd ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
			if imgui.Button(u8'����������������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/po ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
			if imgui.Button(u8'�����������/���������� ������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/or ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
			if imgui.Button(u8'����������� �������������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/oa ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
			if imgui.Button(u8'������� �� �������������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/kl ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
			if imgui.Button(u8'��������������� ���������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/zs ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
			if imgui.Button(u8'������ ���� �� ��������������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/ia ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
			if imgui.Button(u8'���������� ��������� ��������', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/up ' .. playerrecon)
				showCursor(false,false)
				windows.mute_window_state.v = false
			end
		else
			sampAddChatMessage(tag .. '�������� ������, ����� ����������.', -1)
		end
		imgui.End()
	end
	if windows.kick_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������� ������ � �������", windows.kick_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if not sampIsDialogActive() then
			if imgui.Button(u8'AFK /arena', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/cafk ' .. playerrecon)
				four_window_state.v = false
				windows.kick_window_state.v = false
			end
			if imgui.Button(u8"Nick 1/3", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/kk1 ' .. playerrecon)
				four_window_state.v = false
				windows.kick_window_state.v = false
			end
			if imgui.Button(u8"Nick 2/3", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/kk2 ' .. playerrecon)
				four_window_state.v = false
				windows.kick_window_state.v = false
			end
			if imgui.Button(u8'Nick 3/3', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/kk3 ' .. playerrecon)
				four_window_state.v = false
				windows.kick_window_state.v = false
			end
		else
			sampAddChatMessage(tag .. '�������� ������, ����� ����������.', -1)
		end
		imgui.End()
	end
	if windows.four_window_state.v and not sampIsPlayerConnected(playerrecon) then
		windows.four_window_state.v = false
	end
	if windows.four_window_state.v then -- ������ ����� ����
		if windows.checkadm_window_state.v then
			windows.checkadm_window_state.v = false
		end
		if cfg.settings.customposx then
			imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.customposx, cfg.settings.customposy))
		else
			imgui.SetNextWindowPos(imgui.ImVec2(sw-270, 0))
		end
		if sw <= 1400 then
			imgui.SetNextWindowSize(imgui.ImVec2(265, 283), imgui.Cond.FirstUseEver)
			imgui.Begin(u8"�����", windows.four_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		else
			imgui.Begin(u8"�����", windows.four_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		end
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.ShowCursor = false
		imgui.PushFont(fontsize)
		if imgui.Button(u8'����� ' ..fa.ICON_MALE, imgui.ImVec2(120, 25)) then uu() menu[1] = true end imgui.SameLine()
        if imgui.Button(u8'� ������� ' .. fa.ICON_USERS, imgui.ImVec2(120, 25)) then uu() menu[2] = true end 
        imgui.Separator()
        imgui.NewLine()
        imgui.SameLine(3)
        if menu[1] then
			imgui.SetCursorPosX(10)
			if imgui.Button(fa.ICON_FILES_O) then
				setClipboardText(sampGetPlayerNickname(playerrecon))
				sampAddChatMessage(tag .. '��� ���������� � ������ ������.', -1)
			end
			if windows.ansreport_window_state.v then
				windows.ansreport_window_state.v = false
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
			if hpcar then
				imgui.Text(u8'�������� ����: ' .. u8(hpcar))
			end
			if speed then
				imgui.Text(u8'��������: ' .. u8(speed))
			end
			if ping then
				imgui.Text(u8'����: ' .. u8(ping))
			end
			if gun then
				imgui.Text(u8'������: ' .. u8(gun))
				if aim then
					imgui.Text(u8'��������: ' .. u8(aim))
				end
			end
			if afk then
				imgui.Text('AFK: ' .. u8(afk))
			end
			if vip then
				imgui.Text('VIP: ' .. u8(vip))
			end
			if passivemod then
				imgui.Text('Passive: ' .. u8(passivemod))
			end
			if turbo then
				imgui.Text(u8'����� �����: ' .. u8(turbo))
			end
			if collision then
				imgui.Text(u8'��������: ' .. u8(collision))
			end
			if imgui.Button(u8'���������� ����������', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					sampSendChat('/statpl ' .. playerrecon)
				else
					sampAddChatMessage(tag .. '� ��� ������ ������, �������� ���.', -1)
				end
			end
			if imgui.Button(u8'���������� /offstats ����������', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					lua_thread.create(function()
						sampSendChat('/offstats ' .. nickplayerrecon)
						while not sampIsDialogActive() do
							wait(0)
						end
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end)
				else
					sampAddChatMessage(tag .. '� ��� ������ ������, �������� ���.', -1)
				end
			end
			if imgui.Button(u8'���������� ������ ����������', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					sampSendClickTextdraw(165)
				else
					sampAddChatMessage(tag .. '� ��� ������ ������, �������� ���.', -1)
				end
			end
			if imgui.Button(u8'������������� ������', imgui.ImVec2(250, 25)) then
				windows.ban_window_state.v = true
			end
			if imgui.Button(u8'�������� � �����', imgui.ImVec2(250, 25)) then
				windows.jail_window_state.v = true
			end
			if imgui.Button(u8'������ ���', imgui.ImVec2(250, 25)) then
				windows.mute_window_state.v = true
			end
			if imgui.Button(u8'������� ������', imgui.ImVec2(250, 25)) then
				windows.kick_window_state.v = true
			end
			if imgui.Button(u8'�������������� ��������', imgui.ImVec2(250, 25)) then
				windows.dopcustomreport_window_state.v = true
			end
			if ansid ~= playerrecon then
				ansid = nil
				saveplayerrecon = nil
			end
			if isKeyJustPressed(VK_R) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(156)
				lua_thread.create(function()
					if cfg.settings.keysync then
						wait(1000)
						while sampIsDialogActive() or sampIsChatInputActive() do
							wait(0)
						end
						sampSendInputChat('/keysync ' .. playerrecon)
					end
				end)
			end
			if isKeyJustPressed(VK_Q) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(177)
				windows.four_window_state.v = false
				if cfg.settings.keysync then
					sampSendInputChat('/keysync off')
				end
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
	if windows.fourtwo_window_state.v then -- ���������� ������������ ������ ����� ����
		imgui.SetNextWindowSize(imgui.ImVec2(265, 283), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"��������� ������", windows.fourtwo_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'��������� ������� ' .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.customposx = pos.x
			cfg.settings.customposy = pos.y
			inicfg.save(cfg,directIni)
			windows.fourtwo_window_state.v = false
			windows.four_window_state.v = true
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.six_window_state.v then -- ���������� ������������ ������� ������
		imgui.SetNextWindowSize(imgui.ImVec2(250, 80), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"��������� rendera", windows.six_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8"��������� ������������ " .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.renderadminx = pos.x
			cfg.settings.renderadminy = pos.y
			inicfg.save(cfg,directIni)
			showCursor(false,false)
			thisScript():reload()
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.five_window_state.v then -- ���������� ������������ keylogger
		imgui.SetNextWindowSize(imgui.ImVec2(400, 100), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"��������� keylog", windows.five_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8"��������� ������������ " .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.keysyncx = pos.x
			cfg.settings.keysyncy = pos.y
			inicfg.save(cfg,directIni)
			windows.five_window_state.v = false
			windows.main_window_state.v = false
			showCursor(false,false)
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.dopcustomreport_window_state.v then -- ��� �������� � ������ ����� ����
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"�������������� � �������", windows.dopcustomreport_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� ��������')
		if imgui.Button(u8"��������", imgui.ImVec2(250, 25)) then
			sampSendChat('/slap ' .. playerrecon)
		end
		if imgui.Button(u8"����������", imgui.ImVec2(250, 25)) then
			sampSendChat('/aspawn ' .. playerrecon)
		end
		if imgui.Button(u8"����������", imgui.ImVec2(250, 25)) then
			sampSendChat('/freeze ' .. playerrecon)
		end
		if imgui.Button(u8"�����", imgui.ImVec2(250, 25)) then
			sampSendChat('/sethp ' .. playerrecon .. ' 0')
		end
		if imgui.Button(u8"��������������� � ����", imgui.ImVec2(250, 25)) then
			if not sampIsDialogActive() then
				lua_thread.create(function()
					sampSendChat('/reoff')
					windows.dopcustomreport_window_state.v = false
					wait(3000)
					sampSendChat('/gethere ' .. playerrecon)
				end)
			else
				sampAddChatMessage(tag .. '�������� ������.')
			end
		end
		if imgui.Button(u8"��������������� � ����", imgui.ImVec2(250, 25)) then
			if not sampIsDialogActive() then
				lua_thread.create(function()
					sampSendChat('/reoff')
					windows.dopcustomreport_window_state.v = false
					wait(3000)
					sampSendChat('/agt ' .. playerrecon)
				end)
			else
				sampAddChatMessage(tag .. '�������� ������.')
			end
		end
		imgui.End()
	end
	if windows.rmute_window_state.v then -- �������� � ���� �������� �������
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ���������� �������", windows.rmute_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.Button(u8'������', imgui.ImVec2(250, 25)) then
			nakazatreport.oftop = true
			answer.nakajy = true
		end
		if imgui.Button(u8'����', imgui.ImVec2(250, 25)) then
			nakazatreport.capsrep = true
			answer.nakajy = true
		end
		if imgui.Button(u8'����������� �������������', imgui.ImVec2(250, 25)) then
			nakazatreport.oskadm = true
			answer.nakajy = true
		end
		if imgui.Button(u8'������� �� �������������', imgui.ImVec2(250, 25)) then
			nakazatreport.kl = true
			answer.nakajy = true
		end
		if imgui.Button(u8'�����������/���������� ������', imgui.ImVec2(250, 25)) then
			nakazatreport.oskrod = true
			answer.nakajy = true
		end
		if imgui.Button(u8'����������������', imgui.ImVec2(250, 25)) then
			nakazatreport.poprep = true
			answer.nakajy = true
		end
		if imgui.Button(u8'�����������/��������', imgui.ImVec2(250, 25)) then
			nakazatreport.oskrep = true
			answer.nakajy = true
		end
		if imgui.Button(u8'����������� �������', imgui.ImVec2(250, 25)) then
			nakazatreport.matrep = true
			answer.nakajy = true
		end
		imgui.End()
	end
	if windows.custom_otvet_state.v then -- ���� ����� � ������
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'��� �����', windows.custom_otvet_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.IsWindowAppearing() then
			imgui.SetKeyboardFocusHere(-1)
		end
		imgui.NewInputText('##SearchBar3', buffer.findcustomotv, 480, u8'����� �� �������', 2)
		imgui.Separator()
		if #buffer.findcustomotv.v ~= 0 then
			for k,v in pairs(cfg.customotvet) do
				if string.rlower(v):find(string.rlower(u8:decode(buffer.findcustomotv.v))) then
					if imgui.Button(u8(v), imgui.ImVec2(480, 24)) then
						answer.customans = v
						windows.custom_otvet_state.v = false
					end
				end
			end
		else
			for k,v in pairs(cfg.customotvet) do
				if imgui.Button(u8(v), imgui.ImVec2(480, 24)) then
					answer.customans = v
					windows.custom_otvet_state.v = false
				end
			end
		end
		imgui.End()
	end
	if windows.ansreport_window_state.v then -- ������ ����� ������ � ������
		if windows.checkadm_window_state.v then
			windows.checkadm_window_state.v = false
		end
		imgui.SetNextWindowPos(imgui.ImVec2(sw-250, 0), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ����� ������ �� ������", windows.ansreport_window_state.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�� ��������� ������ �� �������')
		imgui.CenterText(u8'�������� ����������?')
		if imgui.Button(u8'��������� �� ��������', imgui.ImVec2(250, 25)) then
			sampSendInputChat('/n ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.ansreport_window_state.v = false
		end
		if imgui.Button(u8'������ ����� ����', imgui.ImVec2(250,25)) then
			sampSendInputChat('/cl ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.ansreport_window_state.v = false
		end
		if imgui.Button(u8'����� �������.', imgui.ImVec2(250,25)) then
			sampSendInputChat('/nak ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.ansreport_window_state.v = false
		end
		if imgui.Button(u8'������� ���.', imgui.ImVec2(250,25)) then
			sampSendInputChat('/pmv ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.ansreport_window_state.v = false
		end
		if imgui.Button(u8'����� AFK', imgui.ImVec2(250,25)) then
			sampSendInputChat('/afk ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.ansreport_window_state.v = false
		end
		if imgui.Button(u8'����� �� � ����', imgui.ImVec2(250,25)) then
			sampSendInputChat('/nv ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.ansreport_window_state.v = false
		end
		if imgui.Button(u8'��� �����-������������', imgui.ImVec2(250,25)) then
			sampSendInputChat('/dpr ' .. saveplayerrecon)
			saveplayerrecon = nil
			windows.ansreport_window_state.v = false
		end
		if (isKeyJustPressed(VK_RBUTTON) or isKeyJustPressed(VK_F)) and not sampIsChatInputActive() and not sampIsDialogActive() then
			if isCursorActive() then
				showCursor(false,false)
			else
				showCursor(true,false)
			end
		end
		imgui.CenterText(u8'���������/����������� �������')
		imgui.CenterText(u8'��� ��� F')
		imgui.CenterText(u8'���� ������� 5 ������.')
		imgui.End()
	end
	if windows.helperma_window_state.v then -- �������������� �������� ����
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5)-150, (sh * 0.5)-125), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'���������', windows.helperma_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
        imgui.Text(u8'����� �������� � ��� ���?')
        if imgui.Checkbox(u8'���', checkbox.checked_test9) then
            cfg.settings.ban  = not cfg.settings.ban
            inicfg.save(cfg,directIni)
        end
        if imgui.Checkbox(u8'�����', checkbox.checked_test10) then
            cfg.settings.jail  = not cfg.settings.jail
            inicfg.save(cfg,directIni)
        end
        if imgui.Checkbox(u8'���', checkbox.checked_test11) then
            cfg.settings.mute  = not cfg.settings.mute
            inicfg.save(cfg,directIni)
        end
        if imgui.Checkbox(u8'���', checkbox.checked_test12) then
            cfg.settings.kick  = not cfg.settings.kick
            inicfg.save(cfg,directIni)
        end
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if imgui.Checkbox(u8'��������� // ' .. sampGetPlayerNickname(myid), checkbox.checked_test16) then
            cfg.settings.prefix = not cfg.settings.prefix
            inicfg.save(cfg,directIni)
        end
		if cfg.settings.ban or cfg.settings.mute or cfg.settings.jail or cfg.settings.mute then
			func6:run()
		else
			func6:terminate()
		end
		imgui.PopFont()
        imgui.End()
	end
	if windows.checkadm_window_state.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.renderadminx, cfg.settings.renderadminy), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"��������������", windows.checkadm_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoInputs + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		for i = 1, #admins - 1 do
			imgui.Text(u8(admins[i]))
		end
        imgui.End()
	end
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
                    if arg1:find('ban') and cfg.settings.ban and isKeyJustPressed(VK_RETURN) then
                        if cfg.settings.prefix then
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4 .. ' // ' .. sampGetPlayerNickname(myid))
                        else
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4)
                        end
                    end
                    if arg1:find('jail') and cfg.settings.jail and isKeyJustPressed(VK_RETURN) then
                        if cfg.settings.prefix then
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4 .. ' // ' .. sampGetPlayerNickname(myid))
                        else
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4)
                        end
                    end
                    if arg1:find('mute') and cfg.settings.mute and isKeyJustPressed(VK_RETURN) then
                        if cfg.settings.prefix then
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4 .. ' // ' .. sampGetPlayerNickname(myid))
                        else
                            sampSendChat('/a ' .. arg1 .. ' '.. arg2 .. ' ' .. arg3 .. ' ' .. arg4)
                        end
                    end
                    if arg1:find('kick') and cfg.settings.kick and isKeyJustPressed(VK_RETURN) then
                        if cfg.settings.prefix then
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
function timerans()
	while saveplayerrecon do
		wait(500)
		if not windows.four_window_state.v then
			while not windows.four_window_state.v do
				wait(0)
			end
		end
		while windows.four_window_state.v do
			wait(2000)
		end
		if saveplayerrecon then
			if sampIsPlayerConnected(saveplayerrecon) then
				windows.ansreport_window_state.v = true
				showCursor(false,false)
				wait(5500)
				if windows.ansreport_window_state.v then
					windows.ansreport_window_state.v = false
					saveplayerrecon = nil
				end
			end
		end
	end
end
function timer() -- ������ ��� ��������
	while true do
		wait(0)
		if st.bool and st.timer and st.sett then
            timer = os.clock() - st.timer
			if st.probid then
				if sampIsPlayerConnected(st.probid) then
					renderFontDrawText(fonts, cfg.settings.stylecolor .. '����� U ����� ������� ��� J ����� ���������\n�����: ' .. cfg.settings.stylecolorform .. forma .. cfg.settings.stylecolor .. ' �� ������ '.. cfg.settings.stylecolorform .. nickid .. '[' .. st.probid .. ']'.. cfg.settings.stylecolor .. '\n������� �� �������� 8 ���, ������: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
				else
					renderFontDrawText(fonts, cfg.settings.stylecolor .. '����� U ����� ������� ��� J ����� ���������\n�����: ' .. cfg.settings.stylecolorform .. forma.. cfg.settings.stylecolor .. '\n������� �� �������� 8 ���, ������: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
				end
			else
				renderFontDrawText(fonts, cfg.settings.stylecolor .. '����� U ����� ������� ��� J ����� ���������\n�����: ' .. cfg.settings.stylecolorform .. forma.. cfg.settings.stylecolor .. '\n������� �� �������� 8 ���, ������: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
			end
            if timer>8 then
				st = {}
				forma = nil
            end
        end
	end
end
local count = 0 -- ������� ���-�� ��������� � ��
----- ����� ��� ������� ����� ���� ---------------
function ac0()
	while true do
		wait(5)
		if not isPauseMenuActive() then
			if cfg.settings.chatposx then
				renderFontDrawText(font_adminchat, ac0, cfg.settings.chatposx, cfg.settings.chatposy, 0xCCFFFFFF)
			else
				cfg.settings.chatposx = -2
				cfg.settings.chatposy = ((sh*0.5)-100)
				inicfg.save(cfg,directIni)
				renderFontDrawText(font_adminchat, ac0, cfg.settings.chatposx, cfg.settings.chatposy, 0xCCFFFFFF)
			end
		end
	end
end
function ac1()
	while true do
		wait(5)
		if not isPauseMenuActive() then
			renderFontDrawText(font_adminchat, ac1, cfg.settings.chatposx, cfg.settings.chatposy+17, 0xCCFFFFFF)
		end
	end
end
function ac2()
	while true do
		wait(5)
		if not isPauseMenuActive() then
			if cfg.settings.chatposx then
				renderFontDrawText(font_adminchat, ac2, cfg.settings.chatposx, cfg.settings.chatposy+34, 0xCCFFFFFF)
			end
		end
	end
end
function ac3()
	while true do
		wait(5)
		if not isPauseMenuActive() then
			if cfg.settings.chatposx then
				renderFontDrawText(font_adminchat, ac3, cfg.settings.chatposx, cfg.settings.chatposy+51, 0xCCFFFFFF)
			end
		end
	end
end
function ac4()
	while true do
		wait(5)
		if not isPauseMenuActive() then
			if cfg.settings.chatposx then
				renderFontDrawText(font_adminchat, ac4, cfg.settings.chatposx, cfg.settings.chatposy+68, 0xCCFFFFFF)
			end
		end
	end
end
function ac5()
	while true do
		wait(5)
		if not isPauseMenuActive() then
			if cfg.settings.chatposx then
				renderFontDrawText(font_adminchat, ac5, cfg.settings.chatposx, cfg.settings.chatposy+85, 0xCCFFFFFF)
			end
		end
	end
end
function sampev.onServerMessage(color,text) -- ����� ��������� �� ����
	if cfg.settings.weaponhack then
		if not activeam then
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
				sampAddChatMessage('{00FF00} ��������� ������� �� ���-������! ��������: {DCDCDC}' .. sampGetPlayerNickname(idwh) .. " [" .. idwh .. "]", -1)
				local idwh = nil
			end 
		end
	end
	if cfg.settings.checkadmins then
		if text:match('����� ������������������� �� �������:') or text:match('���� ���������:') or text:match('����� ������������� � ����:') then
			return false
		end
	end
	if cfg.settings.slejkaform then
		if not activeam then
			if text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)") then
				local poiskform = string.sub(text, 7)
				for i = 0, #spisok do
					if poiskform:find(tostring(spisok[i])) then
						st = {}
						st.idadmin = tonumber(poiskform:match('%[(%d+)%]'))
						st.nicknameform = sampGetPlayerNickname(st.idadmin)
						local d = string.len(poiskform)
						while d ~= 0 do
							poiskform = string.sub(poiskform, 2)
							local don = string.sub(poiskform, 1, 1)
							local d = d - 1
							if don == '/' then
								forma = poiskform
								if poiskform:find('unban') then
									st.bool = true
									st.timer = os.clock()
									st.sett = true
									st.styleform = true
									break
								end
								if v == 'ban' then
									st.forumplease = true
								end
								if poiskform:find('off') or poiskform:find('akk') then
									st.bool = true
									st.timer = os.clock()
									if (poiskform.sub(poiskform, 2)):find('//') then
										st.styleform = true
									end
									st.sett = true
									break
								end
								st.probid = string.match(forma, '%d[%d.,]*')
								if st.probid and sampIsPlayerConnected(st.probid) then
									st.bool = true
									st.timer = os.clock()
									nickid = sampGetPlayerNickname(st.probid)
									if (poiskform.sub(poiskform, 2)):find('//') then
										st.styleform = true
									end
									st.sett = true
									break
								else
									if cfg.settings.acon then
										func10:run()
										lua_thread.create(function()
											wait(6000)
											func10:terminate()
										end)
										st = {}
									else
										st = {}
										sampAddChatMessage(tag .. 'ID �� ���������, ���� ��������� ��� ����.', -1)
									end
									break
								end
							end
						end
					end
				end
				poiskform = nil
			end
		end
	end
	if cfg.settings.acon and text:match("%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)") then
		local admlvl, prefix, nickadm, idadm, admtext  = text:match('%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)')
		local messange = string.sub(prefix, 2) .. ' ' .. admlvl .. ' ' ..  nickadm .. '(' .. idadm .. '): '.. admtext
		if #messange >= 150 then
			messange = string.sub(messange, 1, 150) .. '...'
		end 
		local admlvl, prefix, nickadm, idadm, admtext = nil
		if maximum == true then
			func0:terminate()
			func1:terminate()
			func2:terminate()
			func3:terminate()
			func4:terminate()
			func5:terminate()
			ac0 = ac1
			ac1 = ac2
			ac2 = ac3 
			ac3 = ac4
			ac4 = ac5
			ac5 = messange
			func0:run()
			func1:run()
			func2:run()
			func3:run()
			func4:run()
			func5:run()
		end
		if count == 0 then
			ac0 = messange
			func0:run()
		end
		if count == 1 then
			ac1 = messange
			func1:run()
		end
		if count == 2 then
			ac2 = messange
			func2:run()
		end
		if count == 3 then
			ac3 = messange
			func3:run()
		end
		if count == 4 then
			ac4 = messange
			func4:run()
		end
		if count == 5 then
			if count == 5 then
				ac5 = messange
				func5:run()
				maximum = true
			else
				ac5 = messange
			    func5:run()
			end
		end
		messange = nil
		count = count + 1
		return false --
	end
	if cfg.settings.ban or cfg.settings.mute or cfg.settings.jail or cfg.settings.kick then
        if text:match('{FFFFFF}� ��� ��� ������� � ���� �������, ��� ������� {FFFFFF}��������� � ������ ��������������.') then
            return false
        end
    end
	if cfg.settings.automute and not activeam then 
		text = text:lower()
        text = text:rlower() .. ' '
		if text:match('������') then
			oskid = tonumber(text:match('%[(%d+)%]'))
			for i = 0, #spisokoskrod do
				if (text:match('%s'.. tostring(spisokoskrod[i])) or text:match('}'..tostring(spisokoskrod[i]))) or (text:match('%s'..tostring(spisokoskrod[i])) or text:match('}'..tostring(spisokoskrod[i]))) then
					sampAddChatMessage('{00FF00}[�������]{DCDCDC} ' .. text .. ' {00FF00}[�������]', -1)
					lua_thread.create(function()
						while sampIsDialogActive() or sampIsChatInputActive() do
							wait(200)
						end
					end)
					sampSendChat('/rmute ' .. oskid .. ' 5000 �����������/���������� ������')
					notify.addNotify('<�������>', '------------------------------------------------------\n������� ����������:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '���������� ������.', 2,1,10)
					return false
				end
			end
		end
        if (text:match("(.*)%((%d+)%):%s(.+)(.+)") or text:match("(.*)%[(%d+)%]:%s(.+)")) and not text:match("%[a%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)") and not text:match('������� %[(%d+)%]:') and not text:match('������� (.*)%[(%d+)%]: (.*)') and not text:match('������') then
            if tonumber(text:match('%((%d+)%)')) then
                oskid = tonumber(text:match('%((%d+)%)'))
            else
                oskid = tonumber(text:match('%[(%d+)%]'))
            end
			for i = 0, #spisokoskrod do
				if (text:match('%s'.. tostring(spisokoskrod[i])) or text:match('}'..tostring(spisokoskrod[i]))) or (text:match('%s'..tostring(spisokoskrod[i])) or text:match('}'..tostring(spisokoskrod[i]))) then
					sampAddChatMessage('{00FF00}[�������]{DCDCDC} ' .. text .. ' {00FF00}[�������]', -1)
					lua_thread.create(function()
						while sampIsDialogActive() or sampIsChatInputActive() do
							wait(200)
						end
					end)
					sampSendChat('/mute ' .. oskid .. ' 5000 �����������/���������� ������')
					notify.addNotify('<�������>', '------------------------------------------------------\n������� ����������:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '���������� ������.', 2,1,10)
					return false
				end
			end
			for i = 0, #spisokproject do
				if text:match('%s' .. tostring(spisokproject[i])) or text:match('}' .. tostring(spisokproject[i])) then
					sampAddChatMessage('{00FF00}[�������]{DCDCDC} ' .. text .. ' {00FF00}[�������]', -1)
					lua_thread.create(function()
						while sampIsDialogActive() or sampIsChatInputActive() do
							wait(200)
						end
					end)
					sampSendInputChat('/up ' .. oskid)
					notify.addNotify('<�������>', '------------------------------------------------------\n������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '����������� �����: ' .. tostring(spisokproject[i]), 2,1,10)
					return false
				end
			end
            for i = 0, #cfg.osk do
                if (text:match('%s'..tostring(cfg.osk[i])) or text:match('}'..tostring(cfg.osk[i]))) and not text:match('� ') then
                    sampAddChatMessage('{00FF00}[�������]{DCDCDC} ' .. text .. ' {00FF00}[�������]', -1)
                    lua_thread.create(function()
                        while sampIsDialogActive() or sampIsChatInputActive() do
                            wait(200)
                        end
                    end)
                    sampSendChat('/mute ' .. oskid .. ' 400 �����������/��������')
					notify.addNotify('<�������>', '------------------------------------------------------\n������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '����������� �����: ' .. tostring(cfg.osk[i]), 2,1,10)
                    return false
                end
            end
            for i = 0, #cfg.mat do
                if (text:match('%s'.. tostring(cfg.mat[i])) or text:match('}'..tostring(cfg.mat[i]))) then
                    sampAddChatMessage('{00FF00}[�������]{DCDCDC} ' .. text .. ' {00FF00}[�������]', -1)
                    lua_thread.create(function()
						while sampIsDialogActive() or sampIsChatInputActive() do
                            wait(200)
                        end
                    end)
                    sampSendChat('/mute ' .. oskid .. ' 300 ����������� �������')
					notify.addNotify('<�������>', '------------------------------------------------------\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '����������� �����: ' .. tostring(cfg.mat[i]), 2,1,10)
                    return false
                end
            end
        end
    end
end
function sampev.onShowTextDraw(id, data) -- ��������� ��������� ����������
	if id == 2052 then
		lua_thread.create(function()
			wait(100)
			playerrecon = sampTextdrawGetString(2052)
			sampTextdrawSetPos(2052, 2000, 0)
			playerrecon = tonumber(playerrecon:match('%((%d+)%)')) -- id ����������
			windows.four_window_state.v = true
			imgui.Process = true
			if cfg.settings.keysync then
				sampSendInputChat('/keysync ' .. playerrecon)
			end
		end)
	end
	if (id == 144 or id == 146 or id == 141 or id == 155 or id == 153 or id == 156 or id == 154 or id == 152  or id == 160  or id == 170 or id == 168 or id == 174 or id == 182 or id == 172 or id == 171 or id == 173 or id == 150 or id == 147 or id == 183 or id == 151  or id == 142 or id == 149 or id == 143 or id == 184 or id == 179 or id == 145 or id == 157 or id == 180 or id == 178 or id == 166 or id == 169 or id == 167 or id == 148 or id == 176 or id == 175 or id == 177 or id == 158 or id == 162 or id == 437 or id == 159 or id == 165 or id == 163 or id == 181 or id == 161 or id == 164 or id == 165) then
		return false
	end
	if id == 2059 then
		lua_thread.create(function()
			while id == 2059 do
				sampTextdrawSetPos(2059, 2000, 0)
				wait(800)
				inforeport = sampTextdrawGetString(2059)
				inforeport = textSplit(inforeport, "~n~")
				local i = 0
				for k, v in pairs(inforeport) do
					if i == 3 then
						hpcar = v
					end
					if i == 4 then
						speed = v
					end
					if i == 5 then
						ping = v
					end
					if i == 6 then
						gun = v
					end
					if i == 7 then
						aim = v
					end
					if i == 9 then
						afk = v
					end
					if i == 10 then
						ploss = v
					end
					if i == 11 then
						vip = v
					end
					if i == 12 then
						passivemod = v
					end
					if i == 13 then
						turbo = v
					end
					if i == 14 then
						collision = v
					end
					i = i + 1
				end
				if vip == '0' then
					vip = '�����������'
				end
				if vip == '1' then
					vip = '������������'
				end
				if vip == '2' then
					vip = 'Premium'
				end
				if vip == '3' then
					vip = 'Diamond'
				end
				if vip == '4' then
					vip = 'Platinum'
				end
				if vip == '5' then
					vip = 'Personal'
				end
				if passivemod == '0' then
					passivemod = '��������'
				else
					passivemod = '�����������'
				end
				if turbo == '0' then
					turbo = '��������'
				else
					turbo = '�����������'
				end
				if collision == '1' then
					collision = '������������'
				else
					collision = '���������'
				end
				if gun == '0 : 0 ' then
					gun = '�����������'
				end
				if hpcar == '-1' then
					hpcar = '-'
				end
			end
		end)
	end
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text) -- ������ � ��������� ���������
	if cfg.settings.checkadmins then
		if title:find('������������� �������') then
			admins = textSplit(text, '\n') 
			for i = 1, #admins - 1 do -- {FFFFFF}N.E.O.N(0) ({2E8B57}��.�������������{FFFFFF}) | �������: {ff8587}6{FFFFFF} | ��������: {ff8587}0 �� 3{FFFFFF} | ���������: {ff8587}
				admins[i] = string.gsub(admins[i], '{%w%w%w%w%w%w}', "")
				local afk = string.match(admins[i], 'AFK: (.+)')
				local name, id, rang, lvl, _, _ = string.match(admins[i], '(.+)%((%d+)%) (%(.+)%) | �������: (.+) | ��������: %d �� %d | ���������: (.+)')
				local name, id, rang, lvl = tostring(name), tostring(id), string.sub(tostring(rang), 2), tostring(lvl)
				admins[i] = string.gsub(admins[i], '| ��������: %d �� %d |', "")
				admins[i] = string.gsub(admins[i], '���������: (.+)', "")
				admins[i] = string.gsub(admins[i], '| �������: (.+)', "")
				if rang ~= 'il' then
					if afk then
						admins[i] = name .. '(' .. id .. ') ' .. rang .. ' ' .. lvl .. ' AFK: ' .. afk
					else
						admins[i] = name .. '(' .. id .. ') ' .. rang .. ' '.. lvl
					end
				else
					admins[i] = '[ ������������� ��� �������a ]'
				end
				local name, id, rang, lvl, afk = nil
			end
			imgui.Process = true
			windows.checkadm_window_state.v = true
			sampSendDialogResponse(dialogId, 1, 0)
			return false
		end
	end
	if dialogId == 1098 and cfg.settings.autoonline then
		local c = math.floor(sampGetPlayerCount(false) / 10)
		sampSendDialogResponse(1098, 1, c - 1)
		local c = nil
		sampCloseCurrentDialogWithButton(0)
		return false
	end
	if dialogId == 16190 then -- ���� /offstats ��� ����� ����� ����������� � ���� ������������ ��� /sbanip
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
	if dialogId == 16191 then -- ���� /offstats ������������ ��� /sbanip
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
				sampSendDialogResponse(16191,1,0)
			end
		end)
	end
	if dialogId == 2348 and windows.tree_window_state.v then
		windows.tree_window_state.v = false
	end
	if dialogId == 2349 then -- ���� � ����� ��������.
		windows.ansreport_window_state.v = false
		saveplayerrecon = nil
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
					textreport = string.sub(line, 9) -- ����� �������
					if string.match(line, '%d[%d.,]*') then
						reportid = tonumber(string.match(textreport, '%d[%d.,]*'))
						if sampIsPlayerConnected(reportid) then
							nickreportid = sampGetPlayerNickname(reportid) -- ��� ���� �� ���� ��������
						else
							_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						end
					end
				end
			end
		end
		windows.tree_window_state.v = true
		imgui.Process = true
		lua_thread.create(function()
			while not (answer.rabotay or answer.uto4 or answer.nakajy or answer.customans or answer.slejy or answer.jb or answer.ojid or answer.moiotvet or answer.uto4id or answer.nakazan or answer.otklon or answer.peredamrep) do -- ���� ������� �������
				wait(200)
			end
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end)
	end
	if dialogId == 2350 then -- ���� � ������������ ������� ��� ��������� ������
		windows.tree_window_state.v = false
		if ((u8:decode(buffer.text_buffer.v)) and #answer == 0) or answer.moiotvet then
			peremrep = (u8:decode(buffer.text_buffer.v))
			if #peremrep >= 80 then
				setClipboardText(peremrep)
				peremrep = '��� ����� �� ��������� � ���� �������, � ������ ��� �����'
				sampAddChatMessage(tag .. '��� ����� �������� � ������ ������.', -1)
			end
			if #peremrep <= 4 and not cfg.settings.mytextreport then
				peremrep = (u8:decode(buffer.text_buffer.v) .. '   ')
			end
			if cfg.settings.autosave then
				cfg.customotvet[ #cfg.customotvet + 1 ] = u8:decode(buffer.text_buffer.v)
				inicfg.save(cfg,directIni)
			end	
			answer.moiotvet = true
		end
		if answer.rabotay then
			peremrep = ('�����(�) ������ �� ����� ������!')
		end
		if answer.ojid then
			peremrep = ('��������, ����� �� �����.')
		end
		if answer.nakazan then
			peremrep = ('������ ����� ��� ��� �������.')
		end
		if answer.uto4id then
			peremrep = ('�������� ID ���������� � /report.')
		end
		if answer.nakajy then
			peremrep = ('������ �������� �� ��������� ������ /report')
			windows.rmute_window_state.v = true
			if nakazatreport.oftop or nakazatreport.oskadm or nakazatreport.matrep or nakazatreport.oskrep or nakazatreport.poprep or nakazatreport.oskrod or nakazatreport.capsrep then
				windows.rmute_window_state.v = false
			end  
		end
		if answer.jb then
			peremrep = ('�������� ������ �� forumrds.ru')
		end
		if answer.peredamrep then
			peremrep = ('������� ��� ������.')
		end
		if answer.rabotay then
			if not reportid then
				peremrep = ('�����(�) ������ �� ����� ������.')
			end
			if reportid and reportid ~= myid then
				if not sampIsPlayerConnected(reportid) then
					peremrep = ('��������� ���� ����� ��� ' .. reportid .. ' ID ��������� ��� ����.')
				else
					peremrep = ('�����(�) ������ �� ����� ������.')
				end
			end
			if reportid == myid then
				peremrep = ('�����(�) ������ �� ����� ������.')
			end
		end
		if answer.slejy then
			if not reportid then
				peremrep = ('������� ������.')
				answer.slejy = nil
			end
			if reportid and reportid ~= myid then
				if not sampIsPlayerConnected(reportid) then
					peremrep = ('��������� ���� ����� ��� ' .. reportid .. ' ID ��������� ��� ����.')
					answer.slejy = nil
				else
					peremrep = ('����������� � ������ �� ������� ' .. nickreportid .. '['..reportid..']')
				end
			end
			if myid then
				if reportid == myid then
					peremrep = ('�� ������� ��� ID :D')
					answer.slejy = nil
				end
			end
		end
		if answer.customans then
			peremrep = answer.customans
			if #peremrep >= 80 then
				setClipboardText(peremrep)
				peremrep = '��� ����� �� ��������� � ���� �������, � ������ ��� �����'
				sampAddChatMessage(tag .. '��� ����� �������� � ������ ������.', -1)
			end
			if #peremrep <= 4 then
				peremrep = (answer.customans .. '    ')
			end
		end
		if answer.uto4 then
			peremrep = ('���������� � ������ ��������� �� ����� https://forumrds.ru')
		end
		if answer.peredamrep or answer.moiotvet or answer.slejy or answer.rabotay or answer.ojid or answer.uto4 or answer.uto4id or answer.nakajy or answer.jb or answer.moiotvet or answer.nakazan or answer.customans then
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end
		if answer.otklon then
			sampSendDialogResponse(dialogId, 1, 2, _)
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end
	end
	if dialogId == 2351 and peremrep then -- ���� � ������� �� ������
		lua_thread.create(function()
			if cfg.settings.doptext then
				sampSendDialogResponse(dialogId, 1, _, peremrep .. ('{'..tostring(color())..'} ' .. cfg.settings.mytextreport))
			else
				sampSendDialogResponse(dialogId, 1, _, peremrep)
			end
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
			while sampIsDialogActive() do
				wait(0)
			end
			if answer.slejy then
				sampSendChat('/re ' .. reportid)
			end
			if answer.peredamrep then
				sampSendChat('/a ' .. autor .. '[' ..autorid.. ']: ' .. textreport)
			end
			if answer.nakajy then
				if nakazatreport.oftop then
					sampSendChat('/rmute ' .. autorid .. ' 120 ������ � /report')
				end
				if nakazatreport.oskadm then
					sampSendChat('/rmute ' .. autorid .. ' 2500 ����������� �������������')
				end
				if nakazatreport.oskrep then
					sampSendChat('/rmute ' .. autorid .. ' 400 �����������/��������')
				end
				if nakazatreport.poprep then
					sampSendChat('/rmute ' .. autorid .. ' 120 ����������������')
				end
				if nakazatreport.oskrod then
					sampSendChat('/rmute ' .. autorid .. ' 5000 �����������/���������� ������')
				end
				if nakazatreport.capsrep then
					sampSendChat('/rmute ' .. autorid .. ' 120 ���� � /report')
				end
				if nakazatreport.matrep then
					sampSendChat('/rmute ' .. autorid .. ' 300 ����������� �������')
				end
				if nakazatreport.kl then
					sampSendChat('/rmute ' .. autorid .. ' 3000 ������� �� �������������')
				end
				nakazatreport = {}
			end
			peremrep = nil
			buffer.text_buffer.v = ''
			if not saveplayerrecon and (tonumber(autorid) and answer.slejy) and cfg.settings.ansreport then
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
function sampev.onDisplayGameText(style, time, text) -- �������� ����� �� ������.
	if text:find('RECON') then
		return false
	end
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
function warnings_form()
	while func10:status() ~= 'yielded' do
		wait(0)
		if not isPauseMenuActive() and cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, tag .. 'ID �� ���������, ���� ��������� ��� ����.', cfg.settings.chatposx, cfg.settings.chatposy-17, 0xCCFFFFFF)
		elseif not isPauseMenuActive() then
			cfg.settings.chatposx = -2
			cfg.settings.chatposy = ((sh*0.5)-100)
			renderFontDrawText(font_adminchat, tag .. 'ID �� ���������, ���� ��������� ��� ����.', cfg.settings.chatposx, cfg.settings.chatposy-17, 0xCCFFFFFF)
		end
	end
end
function checkadmins()
	while true do
		while sampIsDialogActive() or sampIsChatInputActive() do
			wait(0)
		end
		wait(1000)
		if not activeam then
			sampSendChat('/admins')
		end
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
		if cfg.settings.keysyncx then
			mimgui.SetNextWindowPos(mimgui.ImVec2(cfg.settings.keysyncx + 200, cfg.settings.keysyncy + 50), mimgui.Cond.Always, mimgui.ImVec2(0.5, 0.5))
		else
			mimgui.SetNextWindowPos(mimgui.ImVec2(sW / 2, sH - 100), mimgui.Cond.Always, mimgui.ImVec2(0.5, 0.5))
		end
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
			else
				mimgui.Text(u8"����� �� ������������. �������� ����� ����� ������� R")
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
    	[226] = 162, [228] = 154, [225] = 151, [227] = 153, [248] = 165, [243] = 121, 
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
----======================= ������������� ��� ������� ===============------------------
sampRegisterChatCommand('wh' , function()
	if not cfg.settings.wallhack then
		cfg.settings.wallhack = true
		checked_test14 = imgui.ImBool(true)
		sampAddChatMessage(tag .. 'WallHack �������', -1)
		inicfg.save(cfg,directIni)
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
		checked_test14 = imgui.ImBool(false)
		sampAddChatMessage(tag .. 'WallHack ��������', -1)
		inicfg.save(cfg,directIni)
		local pStSet = sampGetServerSettingsPtr();
		mem.setfloat(pStSet + 39, 50)
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
	windows.main_window_state.v = not windows.main_window_state.v
	imgui.Process = windows.main_window_state.v
end)

----======================= ������������� ��������������� ===============------------------
sampRegisterChatCommand('spp', function()
	local playerid_to_stream = playersToStreamZone()
	for _, v in pairs(playerid_to_stream) do
	sampSendChat('/aspawn ' .. v)
	end
end)
sampRegisterChatCommand('n', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ot ' .. param .. ' �� �������� ��������� �� ������� ������. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' �� �������� ��������� �� ������� ������.')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dpr', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ot ' .. param .. ' � ������ ������� ������� �� /donate ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' � ������ ������� ������� �� /donate')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('c', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ot ' .. param .. ' �����(�) ������ ��� ����� �������. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' �����(�) ������ ��� ����� �������.')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cl', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ot ' .. param .. ' ������ ����� ����. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ������ ����� ����.')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('nak', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ot ' .. param .. ' ����� ��� �������, ������� �� ���������. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ����� ��� �������, ������� �� ���������.')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('pmv', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ot ' .. param .. ' ������� ���. ����������� ��� ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ������� ���. ����������� ���')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('afk', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ot ' .. param .. ' ����� ������������ ��� ��������� � AFK ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ����� ������������ ��� ��������� � AFK')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('nv', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ot ' .. param .. ' ����� �� � ���� ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ot ' .. param .. ' ����� �� � ����')
		end
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
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
sampRegisterChatCommand('stw', function(param) 
	if #param ~= 0 then
		sampSendChat("/setweap " .. param .. " 38 5000")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('fo', function(param)
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' ���������� � ������ ��������� �� ����� https://forumrds.ru')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('uu', function(param) 
	if #param ~= 0 then
		sampSendChat('/unmute ' .. param) 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('uj', function(param) 
	if #param ~= 0 then
		sampSendChat('/unjail ' .. param) 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ur', function(param) 
	if #param ~= 0 then
		sampSendChat('/unrmute ' .. param) 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('al', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' ������������! �� ������ ������ /alogin!') 
		sampSendChat('/ans ' .. param .. ' ������� ������� /alogin � ���� ������, ����������.')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rep', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' ������ ������ ��� ������������ �� ������ �� ������ � /report') 
		sampSendChat('/ans ' .. param .. ' ������������� ����� ����� ��� ������.')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('as', function(param) 
	if #param ~= 0 then
		sampSendChat('/aspawn ' .. param)
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand("sbanip", function(arg)
	if arg:find('(.+) (.+) (.+)') then
        arg1, arg2, arg3 = arg:match('(.+) (.+) (.+)')
		ipfind = true
		sampSendChat('/offstats ' .. arg1)
		lua_thread.create(function()
			while not regip or sampIsDialogActive() do
				wait(0)
			end
			sampSendChat('/banoff ' .. arg1 .. ' ' .. arg2 .. ' ' .. arg3)
			sampSendChat('/banip ' .. regip .. ' ' .. arg2 .. ' ' .. arg3)
			sampSendChat('/banip ' .. lastip .. ' ' .. arg2 .. ' ' .. arg3)
			lastip = nil
			regip = nil
		end)
    else
        sampAddChatMessage(tag .. '/banip [���] [�����] [�������]', -1)
    end
end)
----======================= ������������� ��� ����� ���� ===============------------------
sampRegisterChatCommand('m', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 300 ����������� �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('mf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 300 ����������� �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('m2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 600 ����������� ������� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('m3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 900 ����������� ������� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ok', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 400 �����������/��������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('okf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 400 �����������/��������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ok2', function(param) 
	if #param ~= 0 then
 		sampSendChat('/mute ' .. param .. ' 800 �����������/�������� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ok3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1200 �����������/�������� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('fd', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('fdf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('fd2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 240 ���� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('fd3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 ���� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('or', function(param) 
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 5000 �����������/���������� ������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('orf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 �����������/���������� ������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('up', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1000 ���������� ��������� ��������')
		sampAddChatMessage(tag .. '������������� �������� ��� �������� /cc', -1)
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('upf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 ���������� ��������� ��������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oa', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 2500 ����������� �������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 ����������� �������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('kl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 3000 ������� �� �������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('klf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 3000 ������� �� �������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('po', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 ����������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('pof', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 ����������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('po2', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 240 ���������������� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('po3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 ���������������� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('zs', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 600 ��������������� ���������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('zsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 600 ��������������� ���������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('nm', function(param)
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 600 ������������ ���������.')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rekl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 1000 �������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('reklf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rz', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 5000 ������ ���.���. �����")
	else 
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 ������ ���.���. �����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ia', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 2500 ������ ���� �� ��������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('iaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 ������ ���� �� ��������������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
----======================= ������������� ��� ����� ������� ===============------------------
sampRegisterChatCommand('oft', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oftf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oft2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Offtop in /report x2")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oft3', function(param) 
	if param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Offtop in /report x3")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cp', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cpf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cp2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Caps in /report x2")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cp3', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Caps in /report x3")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('roa', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 2500 ����������� �������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('roaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 2500 ����������� �������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ror', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 �����������/���������� ������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rorf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 �����������/���������� ������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rzs', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 600 ��������������� ���������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rzsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 600 ��������������� ���������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rrz', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 ������ ���.���. �����")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rrzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 ������ ���.���. �����")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rpo', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 ����������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rpof', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 ����������������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rm', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 300 ��� � /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 300 ����������� �������")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rok', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 400 ����������� � /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rokf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 400 ����������� � /report")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
----======================= ������������� ��� ������ ===============------------------
sampRegisterChatCommand('dz', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ��/�� � ������� ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ��/�� � ������� ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dz2', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 600 ��/�� � ������� ���� x2')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dz3', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 ��/�� � ������� ���� x3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('zv', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. " 3000 ��������������� VIP'��")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dmp', function(param)
	if #param ~= 0 then
		sampSendChat("/jail " .. param .. " 3000 ��������� ������ �� ��")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('zvf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 3000 ��������������� VIP'o�")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('sk', function(param)
	if #param ~= 0 then 
		sampSendChat('/jail ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('skf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dk', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 �� ���� � ������� ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dkf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 �� ���� � ������� ����')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('td', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 car in /trade')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('tdf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 300 Car in /trade")
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jcb', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 3000 ��������� ������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jcbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 3000 ��������� ������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jm', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ��������� ������ ��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ��������� ������ ��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jc', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 ��������� ������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jcf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 ��������� ������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('baguse', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('bagusef', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
----======================= ������������� ��� ���� ===============------------------
sampRegisterChatCommand('bosk', function(param) 
	if #param ~= 0 then
		sampSendChat('/siban ' .. param .. ' 999 ����������� �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('boskf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 ����������� �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('reklama', function(param) 
	if #param ~= 0 then
		sampSendChat('/siban ' .. param .. ' 999 �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('reklamaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 �������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('obm', function(param) 
	if #param ~= 0 then
		sampSendChat('/siban ' .. param .. ' 30 �����/������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('obmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 30 �����/������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('nmb', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 ������������ ���������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('nmbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 3 ������������ ���������')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ch', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' ��������� �����, �� �������� �� ��������� ������ �������.')
		sampSendChat('/ans ' .. param .. ' ���� �� �� �������� � �������� ����������, �������� ������ �� https://forumrds.ru')
		sampSendChat('/banc ' .. param)
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('chf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 7 ��������� ������/��')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oskhelper', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 ��������� ������ /helper')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
----======================= ������������� ��� ����� ===============------------------
sampRegisterChatCommand('cafk', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' AFK in /arena') 
		windows.four_window_state.v = false
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('kk1', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' ������� ��� 1/3') 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('kk2', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' ������� ��� 2/3')
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('kk3', function(param)
	if #param ~= 0 then 
		sampSendChat('/ban ' .. param .. ' 7 ������� ��� 3/3') 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jk', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' DM in jail') 
	else
		sampAddChatMessage(tag .. '�� �� ������� ��������.')
	end
end)


function style(id) -- ����
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
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
