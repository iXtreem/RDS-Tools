require 'lib.moonloader' --
require 'lib.sampfuncs' -- ��� ������� �� ��������������, � �� ���� ����������� � �����������, ���� �� ����� �����������
script_name 'RDS Tools'  -- ������� ������ � ���� �� ������, ���� ������� - �� �� ���� ����� � ����, ���� ���� �� �����������.
script_author 'Neon4ik' -- ���� ��������� - ���������� ��� � ��, ����� ���? - ����� � ��. 
local function recode(u8) return encoding.UTF8:decode(u8) end -- ���������� ��� ���������������
local version = 1.9
local imgui = require 'imgui' 
local sampev = require 'lib.samp.events'
local mimgui = require "mimgui"
local inicfg = require 'inicfg'
local directIni = 'RDSTools.ini'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local vkeys = require 'vkeys'
local ffi = require "ffi"
local mem = require "memory"
local font = require ("moonloader").font_flag
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local path_fastspawn = getWorkingDirectory() .. "\\resource\\FastSpawn.lua" -- ��������� ������� ��� �������� ������
local path_trassera = getWorkingDirectory() .. "\\resource\\trassera.lua" -- ��������� ������� ��� ���������
local mp = import "\\resource\\RDSToolsMP.lua" -- ��������� ������� ��� �����������
local fonts = renderCreateFont('TimesNewRoman', 12, 5) -- ����� ��� ��������
local st = { -- ������ ��� ��������
    bool = false,
    timer = -1,
    id = -1,
}
local spisok = { -- ������ ��� ��������
	'ban',
	'jail',
	'kick',
	'mute',
	'spawncars',
	'setweap',
	'mess',
	'aspawn',
	'tweap',
	'vvig'
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
local cfg = inicfg.load({ -- ������� ��������� �������
	settings = {
		autoonline = false,
		inputhelper = true,
		prefixma = '2E8B57',
		prefixa = '87CEEB',
		prefixsa = 'FF4500',
		doptext = true,
		automute = true,
		mytextreport = ' // �������� ���� �� RDS <3',
		customposx = false,
		customposy = false,
		keysync = true,
		ans = 'None',
		tr = 'None',
		wh = 'None',
		agm = 'None',
		rep = 'None',
		trassera = true,
		wallhack = true,
		automute = false,
		fastspawn = true,
		ansreport = true,
		bloknotik = '',
		acon = true,
		chatposx = nil,
		chatposy = nil,
		size = 10,
		autosave = false,
		limit = 5,
		slejkaform = false,
		texts = 'RDS Tools: ����� �������.',
		stylecolor = '{FFFFFF}',
		stylecolorform = '{FF0000}'
	},
	customotvet = {
	},
	osk = {
	},
	mat = {
	}
}, directIni)
inicfg.save(cfg,directIni)

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
local checked_test1 = imgui.ImBool(cfg.settings.automute)
local checked_test2 = imgui.ImBool(cfg.settings.keysync)
local checked_test3 = imgui.ImBool(cfg.settings.autoonline)
local checked_test4 = imgui.ImBool(cfg.settings.slejkaform)
local checked_test5 = imgui.ImBool(cfg.settings.autosave)
local checked_test6 = imgui.ImBool(cfg.settings.fastspawn)
local checked_test7 = imgui.ImBool(cfg.settings.ansreport)
local checked_test8 = imgui.ImBool(cfg.settings.acon)
local checked_test11 = imgui.ImBool(cfg.settings.trassera)
local checked_test13 = imgui.ImBool(cfg.settings.inputhelper)
local checked_test14 = imgui.ImBool(cfg.settings.wallhack)
local checked_test15 = imgui.ImBool(cfg.settings.doptext)
local selected_item = imgui.ImInt(cfg.settings.size)
local selected_item2 = imgui.ImInt(cfg.settings.limit)
local bloknotik = imgui.ImBuffer(cfg.settings.bloknotik, 4096)
local sw, sh = getScreenResolution()
local text_buffer = imgui.ImBuffer(256)
local customotv = imgui.ImBuffer(256)
local findcustomotv = imgui.ImBuffer(256)
local doptexts = imgui.ImBuffer(u8(cfg.settings.mytextreport), 256)
local PrefixMa = imgui.ImBuffer(cfg.settings.prefixma, 256)
local PrefixA = imgui.ImBuffer(cfg.settings.prefixa, 256)
local PrefixSa = imgui.ImBuffer(cfg.settings.prefixsa, 256)
local main_window_state = imgui.ImBool(false)
local tree_window_state = imgui.ImBool(false)
local four_window_state = imgui.ImBool(false)
local fourtwo_window_state = imgui.ImBool(false)
local five_window_state = imgui.ImBool(false)
local ban_window_state = imgui.ImBool(false)
local mute_window_state = imgui.ImBool(false)
local jail_window_state = imgui.ImBool(false)
local ansreport_window_state = imgui.ImBool(false)
local kick_window_state = imgui.ImBool(false)
local rmute_window_state = imgui.ImBool(false)
local custom_otvet_state = imgui.ImBool(false)
local ac_window_state = imgui.ImBool(false)
local dopcustomreport_window_state = imgui.ImBool(false)
function main() -- �������� �������� �������
	while not isSampAvailable() do wait(0) end
 	font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
	func0 = lua_thread.create_suspended(ac0)
	func1 = lua_thread.create_suspended(ac1)
	func2 = lua_thread.create_suspended(ac2)
	func3 = lua_thread.create_suspended(ac3)
	func4 = lua_thread.create_suspended(ac4)
	func5 = lua_thread.create_suspended(ac5)
	func = lua_thread.create_suspended(ao)
	funct = lua_thread.create_suspended(timer)
	funct:run()
	if cfg.settings.autoonline then
		func:run()
	end
	update_state = false
	font_watermark = renderCreateFont("Javanese Text", 10, font.BOLD + font.SHADOW)
	lua_thread.create(function()
		while true do 
			renderFontDrawText(font_watermark, "{FF0000}RDS Tools{FFFFFF}[" .. version .. "]", 10, sh-20, 0xCCFFFFFF)
			wait(1)
		end	
	end)
	dlstatus = require('moonloader').download_status
	update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.ini" -- ������ �� ������
	update_path = getWorkingDirectory() .. "/RDSTools.ini" -- � ��� �� �� ����� ������
	if cfg.settings.fastspawn then
		fastspawn = import(path_fastspawn) -- ��������� ������� ���������
	end
	if cfg.settings.trassera then
		trassera = import(path_trassera) -- ��������� ���������
	end
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            RDSTools = inicfg.load(nil, update_path)
            if tonumber(RDSTools.script.version) > version then
                update_state = true
			end
            os.remove(update_path)
			update_url = nil
			update_path = nil
        end
    end)
	sampRegisterChatCommand('update', function()
		local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.lua" -- ������ �� ��� ����
		local script_path = thisScript().path
		if update_state then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}������ ������� ��������.')
					showCursor(false,false)
					thisScript():reload()
				end
			end)
		else
			sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}� ��� ����������� ���������� ������.')
		end
	end)
	imgui.Process = false
	inputHelpText = renderCreateFont("Arial", 9, FCR_BORDER + FCR_BOLD) -- ����� ����� �������
	lua_thread.create(inputChat)
	while not sampIsLocalPlayerSpawned() do wait(100) end
	if cfg.settings.wallhack then
		local pStSet = sampGetServerSettingsPtr();
		NTdist = mem.getfloat(pStSet + 39)
		NTwalls = mem.getint8(pStSet + 47)
		NTshow = mem.getint8(pStSet + 56)
		mem.setfloat(pStSet + 39, 1400.0)
		mem.setint8(pStSet + 47, 0)
		mem.setint8(pStSet + 56, 1)
		nameTag = true
	end
	while true do
        wait(0)
		while sett do
			wait(0)
			if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendChat('/a ' .. cfg.settings.texts)
				if not styleform then
					if forumplease then
						cheater = string.match(forma, '%d[%d.,]*')
						sampSendChat('/ans ' .. cheater .. ' ��������� ' .. sampGetPlayerNickname(cheater) .. ', �� �������� ������� �������.')
						sampSendChat('/ans ' .. cheater .. ' ���� �� �� �������� � ����������, �������� ������ �� https://forumrds.ru')
					end
					sampSendChat(forma .. ' // ' .. nicknameform)
					forumplease = nil
					sett = nil
					forma = nil
					nicknameform = nil
					styleform = nil
					probid = nil
				else
					if forumplease then
						cheater = string.match(forma, '%d[%d.,]*')
						sampSendChat('/ans ' .. cheater .. ' ��������� ' .. sampGetPlayerNickname(cheater) .. ', �� �������� ������� �������.')
						sampSendChat('/ans ' .. cheater .. ' ���� �� �� �������� � ����������, �������� ������ �� https://forumrds.ru')
					end
					sampSendChat(forma)
					forumplease = nil
					sett = nil
					probid = nil
					forma = nil
					nicknameform = nil
					styleform = nil
				end
			end
			if isKeyDown(VK_J) and not sampIsChatInputActive() and not sampIsDialogActive() then
				forumplease = nil
				sett = nil
				forma = nil
				probid = nil
				nicknameform = nil
				styleform = nil
				sampAddChatMessage('{FF0000}AForm: {FAEBD7}����� ���������')
			end
		end
		if isKeyJustPressed(VK_F3) and not sampIsDialogActive() then  -- ������ ��������� ���� RDS Tools
			main_window_state.v = not main_window_state.v
			imgui.Process = true
			showCursor(true,false)
		end
		if cfg.settings.wallhack then
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
		if isKeyJustPressed(strToIdKeys(cfg.settings.ans)) and not isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() and not main_window_state.v then
			sampSendChat("/ans ")
			sampSendDialogResponse (2348, 1, 0)
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.tr)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not main_window_state.v then
			sampSendChat("/tr ")
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.wh)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not main_window_state.v then
			sampSetChatInputText('/wh ')
			sampSetChatInputEnabled(true)
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.agm)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not main_window_state.v then
			sampSendChat('/agm ')
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.rep)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not main_window_state.v then
			sampSendChat('/a /ANS /ANS /ANS /ANS /ANS /ANS ANS /ANS /ANS')
		end
	end
end


function ao() -- ����������
	if not isGamePaused() and not isPauseMenuActive() and not sampIsPlayerPaused(id) then
		online = true
	else
		online = false
	end
	while cfg.settings.autoonline do
		wait(60000)
		if online and not sampIsDialogActive() and not sampIsChatInputActive() then
			sampSendChat("/online")
			while not sampIsDialogActive() do
				wait(0)
			end
			local c = math.floor(sampGetPlayerCount(false) / 10)
			sampSendDialogResponse(1098, 1, c - 1)
			sampCloseCurrentDialogWithButton(0)
		end
	end
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
	tKeys = string.split(getDownKeys(), " ")
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
	tKeys = string.split(str, "+")
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
    local tKeys = string.split(keylist, " ")
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
function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end
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
	false,
}
-- imgui.WindowFlags.AlwaysAutoResize
function imgui.OnDrawFrame()
	if not main_window_state.v and not tree_window_state.v and not four_window_state.v and not fourtwo_window_state.v and not five_window_state.v and not ac_window_state.v and not ansreport_window_state.v and not ansreport_window_state.v and not dopcustomreport_window_state.v then
		imgui.Process = false
		sampSetChatInputText('/keysync off')
		sampSetChatInputEnabled(true)
		setVirtualKeyDown(13, true)
		setVirtualKeyDown(13, false)
		showCursor(false,false)
	end
	if main_window_state.v then -- ������ ���������� F3
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), (sh / 2)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(315, 355), imgui.Cond.FirstUseEver)
		imgui.Begin('xX   ' .. " RDS Tools " .. '  Xx', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
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
		if imgui.Button(fa.ICON_CLOUD, imgui.ImVec2(30, 30)) then uu2() menu2[8] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_BELL_O, imgui.ImVec2(30, 30)) then uu2() menu2[9] = true end 
        imgui.Separator()
        imgui.NewLine()
        imgui.SameLine(2)
		if menu2[1] then
			if imgui.IsWindowAppearing() then
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.SetCursorPosX(10)
			if imgui.Checkbox(u8'����.�������', checked_test2) then
				cfg.settings.keysync = not cfg.settings.keysync
				inicfg.save(cfg,directIni)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"autoonline", checked_test3) then
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
			if imgui.Checkbox(u8"Fast Spawn", checked_test6) then
				if cfg.settings.fastspawn then
					cfg.settings.fastspawn = not cfg.settings.fastspawn
					inicfg.save(cfg, directIni)
					sampSetChatInputText('/fsoff ')
					sampSetChatInputEnabled(true)
					setVirtualKeyDown(13, true)
					setVirtualKeyDown(13, false)
				else
					cfg.settings.fastspawn = not cfg.settings.fastspawn
					inicfg.save(cfg, directIni)
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}: ����� �������� ��� �����? �� ������ ���, �� ������ �������. ���������: /fs', -1)
					showCursor(false,false)
					thisScript():reload()
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"��������", checked_test11) then
				if cfg.settings.trassera then
					cfg.settings.trassera = not cfg.settings.trassera
					inicfg.save(cfg,directIni)
					sampSetChatInputText('/trasoff ')
					sampSetChatInputEnabled(true)
					setVirtualKeyDown(13, true)
					setVirtualKeyDown(13, false)
				else
					cfg.settings.trassera = not cfg.settings.trassera
					inicfg.save(cfg,directIni)
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}: �� ���� ������� �� ������ ������������! ���������: /trassera')
					showCursor(false,false)
					thisScript():reload()
				end
			end
			if imgui.Checkbox(u8"input helper", checked_test13) then
				cfg.settings.inputhelper = not cfg.settings.inputhelper
				inicfg.save(cfg,directIni)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"WallHack", checked_test14) then
				if cfg.settings.wallhack == true then
					sampSetChatInputText('/wh ')
					sampSetChatInputEnabled(true)
					setVirtualKeyDown(13, true)
					setVirtualKeyDown(13, false)
				else
					sampSetChatInputText('/wh ')
					sampSetChatInputEnabled(true)
					setVirtualKeyDown(13, true)
					setVirtualKeyDown(13, false)
				end
			end
			if imgui.Checkbox(u8"AdminChat", checked_test8) then
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
			if imgui.Checkbox(u8'���������', checked_test4) then
				cfg.settings.slejkaform  = not cfg.settings.slejkaform
				inicfg.save(cfg,directIni)
			end
			if imgui.Checkbox(u8'������� ���/���', checked_test1) then
				cfg.settings.automute  = not cfg.settings.automute
				inicfg.save(cfg,directIni)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"�������. ������", checked_test7) then
				cfg.settings.ansreport = not cfg.settings.ansreport
				inicfg.save(cfg,directIni)
			end
			if update_state then
				if imgui.Button(u8'�������� ������', imgui.ImVec2(300, 24)) then
					sampSetChatInputText('/update')
					sampSetChatInputEnabled(true)
					setVirtualKeyDown(13, true)
					setVirtualKeyDown(13, false)
					sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}���������� �����������, ��������.', -1)
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
			if imgui.InputText('   ', PrefixMa) then
				cfg.settings.prefixma = PrefixMa.v
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.SetCursorPosX(10)
			imgui.Text(u8'�������������')
			imgui.SameLine()
			imgui.SetCursorPosX(150)
			imgui.PushItemWidth(100)
			if imgui.InputText(' ', PrefixA) then
				cfg.settings.prefixa = PrefixA.v
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.SetCursorPosX(10)
			imgui.Text(u8'��.�������������')
			imgui.SameLine()
			imgui.SetCursorPosX(150)
			imgui.PushItemWidth(100)
			if imgui.InputText('  ', PrefixSa) then
				cfg.settings.prefixsa = PrefixSa.v
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.SetCursorPosX(10)
			imgui.Text(u8'\n\n')
			imgui.CenterText(u8'�������������� ����� ������')
			imgui.PushItemWidth(300)
			if imgui.InputText('', doptexts) then
				cfg.settings.mytextreport = u8:decode(doptexts.v)
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'��������� ������� Recon Menu', imgui.ImVec2(300, 24)) then
				if four_window_state.v then
					four_window_state.v = not four_window_state.v
					fourtwo_window_state.v = not fourtwo_window_state.v
				else
					sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}������� � ������ �� ��������� ����������', -1)
				end
			end
			imgui.SetCursorPosX(10)
			if cfg.settings.acon then
				if imgui.Button(u8'��������� ������� �����-����', imgui.ImVec2(300, 24)) then
					ac_window_state.v = not ac_window_state.v
				end
			end
			imgui.SetCursorPosX(10)
			if cfg.settings.keysync then
				if imgui.Button(u8'��������� ������� ����.������', imgui.ImVec2(300, 23)) then
					five_window_state.v = not five_window_state.v 
				end
			end
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'��������� ������ ' .. fa.ICON_POWER_OFF, imgui.ImVec2(300, 23)) then
				lua_thread.create(function()
					main_window_state.v = false
					if cfg.settings.wallhack then
						sampSetChatInputText('/wh ')
						sampSetChatInputEnabled(true)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end
					wait(100)
					if cfg.settings.trassera then
						sampSetChatInputText('/trasoff ')
						sampSetChatInputEnabled(true)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end
					wait(100)
					if cfg.settings.fastspawn then
						sampSetChatInputText('/fsoff ')
						sampSetChatInputEnabled(true)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end
					thisScript():unload()
				end)
			end
		end
		if menu2[4] then
			bloknotik.v = string.gsub(bloknotik.v, "\\n", "\n")
			if imgui.InputTextMultiline("#1", bloknotik, imgui.ImVec2(310, 280)) then
				bloknotik.v = string.gsub(bloknotik.v, "\n", "\\n")
				cfg.settings.bloknotik = bloknotik.v
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
			imgui.CenterText(u8"���/���� WallHack: ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.wh))
			if imgui.Button(u8"C�x�a����.", imgui.ImVec2(300, 24)) then
				cfg.settings.wh = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8"���/���� ����������: ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.agm))
			if imgui.Button(u8"Cox�a����.", imgui.ImVec2(300, 24)) then
				cfg.settings.agm = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8"����������� � �������: ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.rep))
			if imgui.Button(u8"��xpa����.", imgui.ImVec2(300, 24)) then
				cfg.settings.rep = getDownKeysText()
				inicfg.save(cfg,directIni)
				sampShowDialog(1000, "��������!", "������ ������� ������������� ��� ����, ����� ���������� /a /ANS /ANS /ANS /ANS /ANS\n�� ���� ���������� ������ ��������.", "�����", _)
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
				imgui.Text(u8'� ����������.')
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
				if imgui.Button(u8'������� ����������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 3 -------============= ���������� ==========-----------------')
					sampSendChat('/mess 2 ������ ���������� ��������? ������ ������� �������� ������ ��� ����?')
					sampSendChat('/mess 2 �� ��� ��������! ��������� /tp - ������ - ���������� � ������� ������ ����.')
					sampSendChat('/mess 2 � ���������� ��� ������� ����? ���������� � �������, ���� �������������� �� /autoyartp')
					sampSendChat('/mess 3 -------============= ���������� ==========-----------------')
				end
				if imgui.Button(u8'� /report', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 17 --------========== ����� � �������������� ==========----------')
					sampSendChat('/mess 13 ����� ������, ����������, ����������� ��� ��������� �����?')
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
			imgui.PushItemWidth(300)
			if imgui.Button(u8'�������� ���� �����', imgui.ImVec2(300, 24)) and #customotv.v~=0 then
				key = #cfg.customotvet + 1
				cfg.customotvet[key] = u8:decode(customotv.v)
				inicfg.save(cfg,directIni)
			end
			imgui.InputText('.', customotv)
			imgui.PopItemWidth()
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
			imgui.Text(u8'/tool - ������� ���� �������\n/wh - ���/���� ������� WallHack\n/add_mat - �������� ���\n/add_osk - �������� �����������\n/del_mat - ������� ���\n/del_osk - ������� �����������\n/textform - ��������� ���� ����� ����� ��������� �����\n/stylecolor - ��������� ���� ���� ������.\n/stylecolorform - ��������� ���� ����� �����.')
			imgui.Separator()
			imgui.CenterText(u8'��������������� �������')
			imgui.Text(u8'/n - �� ���� ��������� �� ������\n/nak - ����� �������\n/afk - ����� ��������� � ��� ��� ������������\n/pv - ������� ���\n/dp - ����� ������������\n/rep - �������� ������ � ������� ������� /report\n/c - �����(�) ������ ��� ����� �������\n/cl - ������ ����� ����\n/uj - ����� �����\n/nv - ����� �� � ����\n/prfma - ������ �������� ��.������\n/prfa - ������ ������� ������\n/prfsa - ������ ������� ��.������\n/prfpga - ������ ������� ���\n/prfzga - ������ ������� ���\n/prfga - ������ ������� ��\n/prfcpec - ������ ������� �����\n/stw - ������ �������\n/uu - ������� ������� ������ ����\n/al - ��������� �������������� ��� /alogin\n/as - ���������� ������\n/spp - ���������� ���� � �������\n/sbanip - ��� ������ ��� �� ���� � IP (��!)')
			imgui.Separator()
			imgui.CenterText(u8'������ ��� ����')
			imgui.Text(u8'/m - /m3 ���\n/ok - /ok3 �����������\n/fd - /fd3 ����\n/or - ���/���� ������\n/up - ���������� ������� � �������� ����\n/oa - ����������� �������������\n/kl - ������� �� �������������\n/po - /po3 - ����������������\n/rekl - �������\n/zs - ��������������� ���������\n/rz - ������\n/ia - ������ ���� �� �������������')
			imgui.Separator()
			imgui.CenterText(u8'������ ��� �������')
			imgui.Text(u8'/oft - /oft3 ������\n/cp - /cp3 ����\n/roa - ����������� �������������\n/ror - ���/���� ���\n/rzs - ��������������� ���������\n/rrz - ������\n/rpo - ����������������\n/rm - ���\n/rok - �����������')
			imgui.Separator()
			imgui.CenterText(u8'�������� � ������')
			imgui.Text(u8'/dz - ��/�� � ������� ����\n/zv - ��������������� VIP ��������\n/sk - �����-����\n/td - Car in /trade\n/jm - ��������� ������ ��\n/jcb - ������������� ����(������ ����)\n/jc - ���������� ����\n/baguse - ������\n/dk - �� ���� � ������� ����')
			imgui.Separator()
			imgui.CenterText(u8'������� ������')
			imgui.Text(u8'/cafk - ��� �� �����\n/kk1 - ������� ��� 1/3\n/kk2 - ������� ��� 2/3\n/kk3 - ������� ��� 3/3 (���)')
			imgui.Separator()
			imgui.CenterText(u8'���������� ��������')
			imgui.Text(u8'/ch - ����\n/bosk - ����������� �������\n/obm - �����/������\n/neadekv - ������������ ���������(3 ���)\n/oskhelper - ��������� ������ �������\n/reklama - �������')
			imgui.Separator()
			imgui.Text(u8'������ ��������� � �������� - /okf /mf /dzf')
		end
		if menu2[8] then
			imgui.CenterText(u8'� ����������.')
		end
		if menu2[9] then
			imgui.CenterText(u8'� ����������.')
		end
 		imgui.End()
	end
	if ac_window_state.v then -- ���������� ������� ����� ����
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'�����-���', ac_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
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
				font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 1 then
				cfg.settings.size = 10
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 2 then
				cfg.settings.size = 11
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 3 then
				cfg.settings.size = 12
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 4 then
				cfg.settings.size = 13
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 5 then
				cfg.settings.size = 14
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 6 then
				cfg.settings.size = 15
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 7 then
				cfg.settings.size = 16
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
			if selected_item.v == 8 then
				cfg.settings.size = 17
				inicfg.save(cfg,directIni)
				font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
			end
		end
		imgui.PopItemWidth()
		imgui.PopFont()
		imgui.End()
	end
	if tree_window_state.v then -- ������� ����� �� ������
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2) - 250, (sh / 2)-90), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'����� �� ������', tree_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8'������ �� ������ ' .. autor .. '[' ..autorid.. ']')
		imgui.TextWrapped(u8('������: ') .. u8(textreport))
		if imgui.IsWindowAppearing() then
			imgui.SetKeyboardFocusHere(-1)
		end
		imgui.NewInputText('##SearchBar', text_buffer, 370, nil, 2)
		imgui.SameLine()
		imgui.SetCursorPosX(383)
		if imgui.Button(u8'��������� ' .. fa.ICON_SHARE, imgui.ImVec2(120, 25)) then
			if cfg.settings.autosave then
				key = #cfg.customotvet + 1
				cfg.customotvet[key] = u8:decode(text_buffer.v)
				inicfg.save(cfg,directIni)
			end
			moiotvet = true
		end
		imgui.Separator()
		if imgui.Button(u8'�������', imgui.ImVec2(120, 25)) then
			rabotay = true
		end
		imgui.SameLine()
		if imgui.Button(u8'�����', imgui.ImVec2(120, 25)) then
			slejy = true
		end
		imgui.SameLine()
		if imgui.Button(u8'������ �����', imgui.ImVec2(120, 25)) then
			custom_otvet_state.v = not custom_otvet_state.v
		end
		imgui.SameLine()
		if imgui.Button(u8'��������', imgui.ImVec2(120, 25)) then
			peredamrep = true
		end
		if imgui.Button(u8'��������', imgui.ImVec2(120, 25)) then
			if tonumber(autorid) then
				nakajy = true
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}������ ����� �� � ����. ����������� /rmuteoff', -1)
			end
		end
		imgui.SameLine()
		if imgui.Button(u8'�������� ID', imgui.ImVec2(120, 25)) then
			uto4id = true
		end
		imgui.SameLine()
		if imgui.Button(u8'�����', imgui.ImVec2(120, 25)) then
			uto4 = true
		end
		imgui.SameLine()
		if imgui.Button(u8'���������', imgui.ImVec2(120, 25)) then
			otklon = true
		end
		imgui.Separator()
		if imgui.Checkbox(u8'�������� ��� ����� � ������ ' .. fa.ICON_COMMENTING_O, checked_test15) then
			cfg.settings.doptext = not cfg.settings.doptext
			inicfg.save(cfg,directIni)
		end
		if imgui.Checkbox(u8'��������� ������ � ���� ������ ������� ' .. fa.ICON_DATABASE, checked_test5) then
			cfg.settings.autosave = not cfg.settings.autosave
			inicfg.save(cfg,directIni)
		end
		imgui.PopFont()
		imgui.End()
	end
	if ban_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ���������� ��������", ban_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if not sampIsDialogActive() then
			if imgui.Button(u8'����', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/ch ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'�������������� ��������� (3)', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/iban ' .. playerrecon .. ' 3 ������������ ���������')
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'��������� ������ �������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/oskhelper ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'����������� �������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/bosk ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'�������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/reklama ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'�����', imgui.ImVec2(250, 25)) then
				sampSendChat('/siban ' .. playerrecon .. ' 30 �����/������')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'�������� �����', imgui.ImVec2(250, 25)) then
				sampSendChat('/iban ' .. playerrecon .. ' 7 �������� �����')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
		else
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}�������� ������, ����� ����������.', -1)
		end
		imgui.End()
	end
	if jail_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"�������� ������ � ������", jail_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if not sampIsDialogActive() then
			if imgui.Button(u8'DM/DB in ZZ', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/dz ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8"��������������� VIP'��", imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/zv ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'Spawn Kill', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/sk ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'car in trade/ZZ', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/td ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'���', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/jcb ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'��� ����������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/jc ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'�� ���� � ������� ����', imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. ' �� ���� � ������� ����')
				showCursor(false,false)
				jail_window_state.v = false
			end
		else
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}�������� ������, ����� ����������.', -1)
		end
		imgui.End()
	end
	if mute_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������������� ��� ������", mute_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if not sampIsDialogActive() then
			if imgui.Button(u8'�����������/��������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/ok ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8"���", imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/m ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8"����", imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/fd ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'����������������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/po ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'�����������/���������� ������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/or ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'����������� �������������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/oa ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'������� �� �������������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/kl ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'��������������� ���������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/zs ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'������ ���� �� ��������������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/ia ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'���������� ��������� ��������', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/up ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
		else
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}�������� ������, ����� ����������.', -1)
		end
		imgui.End()
	end
	if kick_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������� ������ � �������", kick_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�������� �������')
		if not sampIsDialogActive() then
			if imgui.Button(u8'AFK /arena', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/cafk ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				four_window_state.v = false
				kick_window_state.v = false
			end
			if imgui.Button(u8"Nick 1/3", imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/kk1 ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				four_window_state.v = false
				kick_window_state.v = false
			end
			if imgui.Button(u8"Nick 2/3", imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/kk2 ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				four_window_state.v = false
				kick_window_state.v = false
			end
			if imgui.Button(u8'Nick 3/3', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/kk3 ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				four_window_state.v = false
				kick_window_state.v = false
			end
		else
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}�������� ������, ����� ����������.', -1)
		end
		imgui.End()
	end
	if four_window_state.v then -- ������ ����� ����
		if cfg.settings.customposx then
			imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.customposx, cfg.settings.customposy))
		else
			imgui.SetNextWindowPos(imgui.ImVec2(sw-270, 0))
		end
		imgui.Begin(u8"�����", four_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'����� ' ..fa.ICON_MALE, imgui.ImVec2(120, 25)) then uu() menu[1] = true end imgui.SameLine()
        if imgui.Button(u8'� ������� ' .. fa.ICON_USERS, imgui.ImVec2(120, 25)) then uu() menu[2] = true end 
		imgui.PopFont()
        imgui.Separator()
        imgui.NewLine()
        imgui.SameLine(3)
        if menu[1] then
			imgui.PushFont(fontsize)
			imgui.SetCursorPosX(10)
			if imgui.Button(fa.ICON_FILES_O) then
				setClipboardText(nickplayerrecon)
				sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}��� ���������� � ������ ������.', -1)
			end
			if imgui.IsWindowAppearing() then
				imgui.SetKeyboardFocusHere(-1)
			end
			if ansreport_window_state.v then
				ansreport_window_state.v = false
				saveplayerrecon = false
			end
			imgui.SameLine()
			imgui.Text(u8('�����: ' .. nickplayerrecon) .. '[' .. playerrecon .. ']' )
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
			if ploss then
				imgui.Text(u8'P.Loss: ' .. u8(ploss))
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
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}� ��� ������ ������, �������� ���.', -1)
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
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}� ��� ������ ������, �������� ���.', -1)
				end
			end
			if imgui.Button(u8'���������� ������ ����������', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					sampSendClickTextdraw(165)
				else
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}� ��� ������ ������, �������� ���.', -1)
				end
			end
			if imgui.Button(u8'������������� ������', imgui.ImVec2(250, 25)) then
				ban_window_state.v = true
			end
			if imgui.Button(u8'�������� � �����', imgui.ImVec2(250, 25)) then
				jail_window_state.v = true
			end
			if imgui.Button(u8'������ ���', imgui.ImVec2(250, 25)) then
				mute_window_state.v = true
			end
			if imgui.Button(u8'������� ������', imgui.ImVec2(250, 25)) then
				kick_window_state.v = true
			end
			if imgui.Button(u8'�������������� ��������', imgui.ImVec2(250, 25)) then
				dopcustomreport_window_state.v = true
			end
			if isKeyJustPressed(VK_R) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(156)
				lua_thread.create(function()
					if cfg.settings.keysync then
						wait(1000)
						while sampIsDialogActive() or sampIsChatInputActive() do
							wait(0)
						end
						sampSetChatInputText('/keysync ' .. playerrecon)
						sampSetChatInputEnabled(true)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end
				end)
			end
			if isKeyJustPressed(VK_Q) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(177)
				four_window_state.v = false
				if cfg.settings.keysync then
					sampSetChatInputText('/keysync off')
					sampSetChatInputEnabled(true)
					setVirtualKeyDown(13, true)
					setVirtualKeyDown(13, false)
				end
			end
			if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
				lua_thread.create(function()
					setVirtualKeyDown(70, true)
					wait(150)
					setVirtualKeyDown(70, false)
				end)
			end
			imgui.PopFont()
			imgui.ShowCursor = false
        end
        if menu[2] then
			imgui.PushFont(fontsize)
			local playerzone = playersToStreamZone()
			for _,v in pairs(playerzone) do
				if v ~= playerrecon then
					imgui.SetCursorPosX(10)
					if imgui.Button(sampGetPlayerNickname(v) .. '[' .. v .. ']', imgui.ImVec2(250, 25)) then
						sampSendChat('/re ' .. v)
					end
				end
			end
			imgui.PopFont()
        end
		imgui.End()
	end
	if fourtwo_window_state.v then -- ���������� ������������ ������ ����� ����
		imgui.SetNextWindowSize(imgui.ImVec2(250, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"��������� ������", fourtwo_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'��������� ������� ' .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.customposx = pos.x
			cfg.settings.customposy = pos.y
			inicfg.save(cfg,directIni)
			fourtwo_window_state.v = false
			four_window_state.v = true
		end
		imgui.PopFont()
		imgui.End()
	end
	if five_window_state.v then -- ���������� ������������ keylogger
		imgui.SetNextWindowSize(imgui.ImVec2(400, 100), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"��������� keylog", five_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8"��������� ������������ " .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.keysyncx = pos.x
			cfg.settings.keysyncy = pos.y
			inicfg.save(cfg,directIni)
			five_window_state.v = false
			main_window_state.v = false
			showCursor(false,false)
		end
		imgui.PopFont()
		imgui.End()
	end
	if dopcustomreport_window_state.v then -- ��� �������� � ������ ����� ����
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"�������������� � �������", dopcustomreport_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
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
					dopcustomreport_window_state.v = false
					wait(3000)
					sampSendChat('/gethere ' .. playerrecon)
				end)
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�������� ������.')
			end
		end
		if imgui.Button(u8"��������������� � ����", imgui.ImVec2(250, 25)) then
			if not sampIsDialogActive() then
				lua_thread.create(function()
					sampSendChat('/reoff')
					dopcustomreport_window_state.v = false
					wait(3000)
					sampSendChat('/agt ' .. playerrecon)
				end)
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�������� ������.')
			end
		end
		imgui.End()
	end
	if rmute_window_state.v then -- �������� � ���� �������� �������
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ���������� �������", rmute_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.Button(u8'������', imgui.ImVec2(250, 25)) then
			oftop = true
		end
		if imgui.Button(u8'����', imgui.ImVec2(250, 25)) then
			capsrep = true
		end
		if imgui.Button(u8'����������� �������������', imgui.ImVec2(250, 25)) then
			oskadm = true
		end
		if imgui.Button(u8'������� �� �������������', imgui.ImVec2(250, 25)) then
			kl = true
		end
		if imgui.Button(u8'�����������/���������� ������', imgui.ImVec2(250, 25)) then
			oskrod = true
		end
		if imgui.Button(u8'����������������', imgui.ImVec2(250, 25)) then
			poprep = true
		end
		if imgui.Button(u8'�����������/��������', imgui.ImVec2(250, 25)) then
			oskrep = true
		end
		if imgui.Button(u8'����������� �������', imgui.ImVec2(250, 25)) then
			matrep = true
		end
		imgui.End()
	end
	if custom_otvet_state.v then -- ���� ����� � ������
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), (sh / 2)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'��� �����', custom_otvet_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushItemWidth(480)
		if imgui.IsWindowAppearing() then
			imgui.SetKeyboardFocusHere(-1)
		end
		imgui.InputText(',sss', findcustomotv) 
		imgui.PopItemWidth()
		imgui.Separator()
		if #findcustomotv.v ~= 0 then
			for k,v in pairs(cfg.customotvet) do
				if string.rlower(v):find(string.rlower(u8:decode(findcustomotv.v))) then
					if imgui.Button(u8(v), imgui.ImVec2(480, 24)) then
						customans = v
						custom_otvet_state.v = false
					end
				end
			end
		else
			for k,v in pairs(cfg.customotvet) do
				if imgui.Button(u8(v), imgui.ImVec2(480, 24)) then
					customans = v
					custom_otvet_state.v = false
				end
			end
		end
		imgui.End()
	end
	if ansreport_window_state.v then -- ������ ����� ������ � ������
		imgui.SetNextWindowPos(imgui.ImVec2(sw-250, 0), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ����� ������ �� ������", ansreport_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�� ��������� ������ �� �������')
		imgui.CenterText(u8'�������� ����������?')
		if imgui.Button(u8'��������� �� ��������', imgui.ImVec2(250, 25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSetChatInputText('/n ' .. saveplayerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}����� �� � ����.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'������ ����� ����', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSetChatInputText('/cl ' .. saveplayerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}����� �� � ����.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'����� �������.', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSetChatInputText('/nak ' .. saveplayerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}����� �� � ����.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'������� ���.', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSetChatInputText('/pv ' .. saveplayerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}����� �� � ����.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'����� AFK', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSetChatInputText('/afk ' .. saveplayerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}����� �� � ����.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'����� �� � ����', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSetChatInputText('/nv ' .. saveplayerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}����� �� � ����.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'��� �����-������������', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSetChatInputText('/dp ' .. saveplayerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}����� �� � ����.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
			if isCursorActive() then
				showCursor(false,false)
			else
				showCursor(true,false)
			end
		end
		imgui.CenterText(u8'���������/����������� �������')
		imgui.CenterText(u8'���')
		imgui.CenterText(u8'���� ������� 5 ������.')
		imgui.End()
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
	wait(500)
	if not four_window_state.v then
		while not four_window_state.v do
			wait(0)
		end
	end
	while four_window_state.v do
		wait(1000)
	end
	ansreport_window_state.v = true
	imgui.Process = ansreport_window_state
	showCursor(false,false)
	wait(5500)
	if ansreport_window_state.v then
		ansreport_window_state.v = false
		saveplayerrecon = false
	end
end
function timer() -- ������ ��� ��������
	while true do
		wait(0)
		if st.bool and st.timer ~= -1 and sett then
            timer = os.clock()-st.timer
			if probid and sampIsPlayerConnected(probid) then
           		renderFontDrawText(fonts, cfg.settings.stylecolor .. '����� U ����� ������� ��� J ����� ���������\n�����: ' .. cfg.settings.stylecolorform .. forma .. cfg.settings.stylecolor .. ' �� ������ '.. cfg.settings.stylecolorform .. nickid .. '[' .. probid .. ']'.. cfg.settings.stylecolor .. '\n������� �� �������� 8 ���, ������: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
			else
				renderFontDrawText(fonts, cfg.settings.stylecolor .. '����� U ����� ������� ��� J ����� ���������\n�����: ' .. cfg.settings.stylecolorform .. forma.. cfg.settings.stylecolor .. '\n������� �� �������� 8 ���, ������: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
			end
            if timer>8 then
				forumplease = nil
				probid = nil
				sett = nil
				forma = nil
				nicknameform = nil
				styleform = nil
                st.bool = false
                st.timer = -1
            end
        end
	end
end
local count = 0 -- ������� ���-�� ��������� � ��
----- ����� ��� ������� ����� ���� ---------------
function ac0()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac0, cfg.settings.chatposx, cfg.settings.chatposy, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac0, -2, (sh/2-100), 0xCCFFFFFF)
		end
	end
end
function ac1()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac1, cfg.settings.chatposx, cfg.settings.chatposy+20, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac1, -2, (sh/2-100)+20, 0xCCFFFFFF)
		end
	end
end
function ac2()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac2, cfg.settings.chatposx, cfg.settings.chatposy+40, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac2, -2, (sh/2-100)+40, 0xCCFFFFFF)
		end
	end
end
function ac3()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac3, cfg.settings.chatposx, cfg.settings.chatposy+60, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac3, -2, (sh/2-100)+60, 0xCCFFFFFF)
		end
	end
end
function ac4()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac4, cfg.settings.chatposx, cfg.settings.chatposy+80, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac4, -2, (sh/2-100)+80, 0xCCFFFFFF)
		end
	end
end
function ac5()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac5, cfg.settings.chatposx, cfg.settings.chatposy+100, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac5, -2, (sh/2-100)+100, 0xCCFFFFFF)
		end
	end
end
----- ����� ��� ������� ����� ���� ---------------
function sampev.onServerMessage(color,text) -- ����� ��������� �� ����
	if cfg.settings.slejkaform then
		if text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)") then
			poiskform = text
			for k,v in pairs(spisok) do
				if poiskform:find(v) then
					local id = poiskform:match('%[(%d+)%]')
					if id then
						lua_thread.create(function()
							wait(200)
							name = sampGetPlayerNickname(tostring(id))
							nicknameform = name
						end)
						d = string.len(poiskform)
						while d ~= 0 do
							poiskform = string.sub(poiskform, 2)
							rev = string.reverse(poiskform)
							don = string.sub(rev, -1)
							d = d - 1
							if don == '/' then
								forma = poiskform
								if v == 'ban' and not poiskform:find('banoff') and not poiskform:find('offban') and not poiskform:find('banakk') and not poiskform:find('unban') then
									forumplease = true
								end
								if poiskform:find('unban') or poiskform:find('unjail') or poiskform:find('unmute') then
									st.bool = true
									st.timer = os.clock()
									sett = true
									break
								end
								if poiskform:find('off') or poiskform:find('akk') then
									st.bool = true
									st.timer = os.clock()
									if (poiskform.sub(poiskform, 2)):find('/') then
										styleform = true
									end
									sett = true
									break
								end
								probid = string.match(forma, '%d[%d.,]*')
								if probid and sampIsPlayerConnected(probid) then
									st.bool = true
									st.timer = os.clock()
									nickid = sampGetPlayerNickname(probid)
									if (poiskform.sub(poiskform, 2)):find('//') then
										styleform = true
									end
									sett = true
									break
								else
									sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}ID �� ���������, ���� ��������� ��� ����.', -1)
									break
								end
							end
						end
					end
				end
			end
		end
	end
	if cfg.settings.acon then
		lua_thread.create(function()
			while true do
				wait(1)
				if text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)") then
					local admlvl= string.match(string.sub(text, 1, 8), '%d[%d.,]*')
					if #admlvl == 2 then
						messange = ('['..admlvl..'] ' .. string.sub(text, 8))
					else
						messange = ('['..admlvl..'] ' .. string.sub(text, 7))
					end
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
						break
					end
					if count == 0 then
						count = count + 1
						ac0 = messange
						func0:run()
						break
					end
					if count == 1 then
						count = count + 1
						ac1 = messange
						func1:run()
						break
					end
					if count == 2 then
						count = count + 1
						ac2 = messange
						func2:run()
						break
					end
					if count == 3 then
						count = count + 1
						ac3 = messange
						func3:run()
						break
					end
					if count == 4 then
						count = count + 1
						ac4 = messange
						func4:run()
						break
					end
					if count == 5 then
						if count == cfg.settings.limit then
							count = count - 1
							func5:terminate()
							ac5 = messange
							func5:run()
							maximum = true
						else
							ac5 = messange
							func5:run()
						end
						count = count + 1
						break
					end
				end
			end
		end)
	end
	if text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)") and cfg.settings.acon then
		return false
	end
	if cfg.settings.automute then
		text = text:lower()
		text = text:rlower()
		if text:match('(.+)%((.+)%): {(.+)}(.+)') then
			for k,v in pairs(cfg.osk) do
				if text:match(v) and not text:match('%A%A' .. v) and not text:match('� ' .. V) then
					local oskid = tonumber(text:match('%((%d+)%)'))
					sampAddChatMessage('{00FF00}[�������]{DCDCDC} ' .. text .. ' {00FF00}[�������]', -1)
					lua_thread.create(function()
						while sampIsDialogActive() do
							wait(20)
						end
					end)
					if oskid and not isGamePaused() and not isPauseMenuActive() and not sampIsPlayerPaused(id) then
						sampSendChat('/mute ' .. oskid .. ' 400 �����������/��������')
					end
					return false
				end
			end
			for k,v in pairs(cfg.mat) do
				if text:match(v) and not text:match('%A%A' .. v) then
					local matid = tonumber(text:match('%((%d+)%)'))
					sampAddChatMessage('{00FF00}[�������]{DCDCDC} ' .. text .. ' {00FF00}[�������]', -1)
					lua_thread.create(function()
						while sampIsDialogActive() do
							wait(20)
						end
					end)
					if matid then
						sampSendChat('/mute ' .. matid .. ' 300 ����������� �������')
					end
					return false
				end
			end
		end
	end
--	if text:match("(.+)%[(%d+)%]: (.+)") then
end
function sampev.onShowTextDraw(id, data) -- ��������� ��������� ����������
	lua_thread.create(function()
		if id == 2052 then
			wait(100)
			sampTextdrawSetPos(2052, 2000, 0)
			imgui.Process = true
			playerrecon = sampTextdrawGetString(2052)
			playerrecon = tonumber(playerrecon:match('%((%d+)%)')) -- id ����������
			nickplayerrecon = sampGetPlayerNickname(playerrecon) -- ��� ����������
			four_window_state.v = true
			if cfg.settings.keysync then
				sampSetChatInputText('/keysync ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
			end
		end
	end)
	lua_thread.create(function()
		while id  == 2059 do
			sampTextdrawSetPos(2059, 2000, 0)
			sampTextdrawDelete(144)
			sampTextdrawDelete(146)
			sampTextdrawDelete(141)
			sampTextdrawDelete(155)
			sampTextdrawDelete(153)
			sampTextdrawDelete(156)
			sampTextdrawDelete(154)
			sampTextdrawDelete(152)
			sampTextdrawDelete(160)
			sampTextdrawDelete(170)
			sampTextdrawDelete(165)
			sampTextdrawDelete(159)
			sampTextdrawDelete(163)
			sampTextdrawDelete(164)
			sampTextdrawDelete(161)
			sampTextdrawDelete(181)
			sampTextdrawDelete(170)
			sampTextdrawDelete(168)
			sampTextdrawDelete(174)
			sampTextdrawDelete(182)
			sampTextdrawDelete(172)
			sampTextdrawDelete(171)
			sampTextdrawDelete(173)
			sampTextdrawDelete(150)
			sampTextdrawDelete(147)
			sampTextdrawDelete(150)
			sampTextdrawDelete(183)
			sampTextdrawDelete(151)
			sampTextdrawDelete(142)
			sampTextdrawDelete(149)
			sampTextdrawDelete(143)
			sampTextdrawDelete(184)
			sampTextdrawDelete(179)
			sampTextdrawDelete(145)
			sampTextdrawDelete(157)
			sampTextdrawDelete(180)
			sampTextdrawDelete(178)
			sampTextdrawDelete(166)
			sampTextdrawDelete(169)
			sampTextdrawDelete(167)
			sampTextdrawDelete(148)
			sampTextdrawDelete(176)
			sampTextdrawDelete(175)
			sampTextdrawDelete(177)
			sampTextdrawDelete(158)
			sampTextdrawDelete(162)
			sampTextdrawDelete(437)
			wait(500)
			inforeport = sampTextdrawGetString(2059)
			inforeport = textSplit(inforeport, "~n~")
			i = 0
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
				gun = false
			end
			if hpcar == '-1' then
				hpcar = false
			end
			if afk == '0' then
				afk = false
			end
		end
	end)
end
function sampGetPlayerIdByNickname(nick) -- ������ ID �� ����
	nick = tostring(nick)
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if nick == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 1003 do
	  	if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
			return i
	  	end
	end
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text) -- ������ � ��������� ���������
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
			ipfindclose = false
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
				ipfind = false
				sampSendDialogResponse(16191,1,0)
			end
		end)
	end
	if dialogId == 2348 and tree_window_state.v then
		tree_window_state.v = false
	end
	if dialogId == 2349 then -- ���� � ����� ��������.
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
					else
						reportid = false
					end
				end
			end
		end
		tree_window_state.v = not tree_window_state.v
		imgui.Process = tree_window_state
		lua_thread.create(function()
			while rabotay ~= 2 and uto4 ~= 2  and nakajy ~= 2 and not customans and slejy ~= 2 and jb ~= 2 and ojid ~= 2 and moiotvet ~= 2 and uto4id ~= 2 and helpest~= 2 and nakazan ~= 2 and otklon ~= 2 and peredamrep ~= 2 do -- ���� ������� �������
				wait(50)
				doptext = ('{'..tostring(color())..'} ' .. cfg.settings.mytextreport)
				if rabotay then
					peremrep = ('�����(�) ������ �� ����� ������!')
					rabotay = 2
				end
				if ojid then
					peremrep = ('��������, ����� �� �����.')
					ojid = 2
				end
				if nakazan then
					peremrep = ('������ ����� ��� ��� �������.')
					nakazan = 2
				end
				if helpest then
					peremrep = ('������ ���������� ������� � /help')
					helpest = 2
				end
				if otklon then
					otklon = 2
				end
				if peredamrep then
					peredamrep = 2
				end
				if uto4id then
					peremrep = ('�������� ID ���������� � /report.')
					uto4id = 2
				end
				if nakajy then
					peremrep = ('������ �������� �� ��������� ������ /report')
					rmute_window_state.v = true
					if oftop or oskadm or matrep or oskrep or poprep or oskrod or capsrep then
						nakajy = 2
						rmute_window_state.v = false
					end  
				end
				if jb then
					peremrep = ('�������� ������ �� forumrds.ru')
					jb = 2
				end
				if moiotvet then
					if cfg.settings.doptext then
						peremrep = (u8:decode(text_buffer.v) .. doptext)
						if #peremrep >= 80 then
							peremrep = (u8:decode(text_buffer.v))
							if #peremrep >= 80 then
								text_buffer.v = u8'��� ����� �� ��������� � ���� �������, � ������ ��� �����'
								moiotvet = true
							end
						end
						moiotvet = 2
					else
						peremrep = (u8:decode(text_buffer.v))
						if #peremrep >= 80 then
							text_buffer.v = u8'��� ����� �� ��������� � ���� �������, � ������ ��� �����'
						end
						if #peremrep <= 3 then
							peremrep = (u8:decode(text_buffer.v) .. '    ')
						end
						moiotvet = 2
					end
				end
				if slejy then
					slejy = 2
				end
				if uto4 then
					peremrep = ('���������� � ������ ��������� �� ����� https://forumrds.ru')
					uto4 = 2
				end
			end
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
			tree_window_state.v = not tree_window_state.v
			imgui.Process = tree_window_state
		end)
	end
	if dialogId == 2350 then -- ���� � ������������ ������� ��� ��������� ������
		tree_window_state.v = false
		if otklon == 2 then
			lua_thread.create(function()
				sampSendDialogResponse(dialogId, 1, 2, _)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				otklon = nil
			end)
		end
		if peredamrep or slejy or rabotay or ojid or uto4 or uto4id or helpest or nakajy or jb or moiotvet or nakazan or customans then
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end
	end
	if dialogId == 2351 then -- ���� � ������� �� ������
		lua_thread.create(function()
			if peredamrep == 2 then
				sampSendDialogResponse(dialogId, 1, _, '������� ��� ������.')
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				while sampIsDialogActive() do
					wait(0)
				end
				sampSendChat('/a ' .. autor .. '[' ..autorid.. ']: ' .. textreport)
				peredamrep = nil
			end
			if rabotay == 2 then
				if cfg.settings.doptext then
					if not reportid then
						peremrep = ('�����(�) ������ �� ����� ������.')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						rabotay = nil
					end
					if reportid and reportid ~= myid then
						if not sampIsPlayerConnected(reportid) then
							peremrep = ('��������� ���� ����� ��� ' .. reportid .. ' ID ��������� ��� ����.')
							sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							rabotay = nil
						else
							peremrep = ('�����(�) ������ �� ����� ������.')
							sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							while sampIsDialogActive() do
								wait(0)
							end
							sampSendChat('/re ' .. reportid)
						end
					end
					if reportid == myid then
						peremrep = ('�����(�) ������ �� ����� ������.')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						rabotay = nil
					end
				else
					if not reportid then
						peremrep = ('�����(�) ������ �� ����� ������.')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						rabotay = nil
					end
					if reportid and reportid ~= myid then
						if not sampIsPlayerConnected(reportid) then
							peremrep = ('��������� ���� ����� ��� ' .. reportid .. ' ID ��������� ��� ����.')
							sampSendDialogResponse(dialogId, 1, _, peremrep)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							rabotay = nil
						else
							peremrep = ('�����(�) ������ �� ����� ������.')
							sampSendDialogResponse(dialogId, 1, _, peremrep)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							while sampIsDialogActive() do
								wait(0)
							end
							sampSendChat('/re ' .. reportid)
						end
					end
					if reportid == myid then
						peremrep = ('�����(�) ������ �� ����� ������.')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						rabotay = nil
					end
				end
			end
			if slejy == 2 then
				if cfg.settings.doptext then
					if not reportid then
						peremrep = ('������� ������.')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						slejy = nil
					end
					if reportid and reportid ~= myid then
						if not sampIsPlayerConnected(reportid) then
							peremrep = ('��������� ���� ����� ��� ' .. reportid .. ' ID ��������� ��� ����.')
							sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							slejy = nil
						else
							peremrep = ('����������� � ������ �� ������� ' .. nickreportid .. '['..reportid..']')
							sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							while sampIsDialogActive() do
								wait(0)
							end
							sampSendChat('/re ' .. reportid)
						end
					end
					if reportid == myid then
						peremrep = ('�� ������� ��� ID :D')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						slejy = nil
					end
				else
					if not reportid then
						peremrep = ('������� ������.')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						slejy = nil
					end
					if reportid and reportid ~= myid then
						if not sampIsPlayerConnected(reportid) then
							peremrep = ('��������� ���� ����� ��� ' .. reportid .. ' ID ��������� ��� ����.')
							sampSendDialogResponse(dialogId, 1, _, peremrep)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							slejy = nil
						else
							peremrep = ('����������� � ������ �� ������� ' .. nickreportid .. '['..reportid..']')
							sampSendDialogResponse(dialogId, 1, _, peremrep)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							while sampIsDialogActive() do
								wait(0)
							end
							sampSendChat('/re ' .. reportid)
						end
					end
					if reportid == myid then
						peremrep = ('�� ������� ��� ID :D')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						slejy = nil
					end
				end
			end
			if ojid or uto4 or uto4id or helpest or jb or nakazan then
				if cfg.settings.doptext then
					sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
					setVirtualKeyDown(13, true)
					setVirtualKeyDown(13, false)
				else
					sampSendDialogResponse(dialogId, 1, _, peremrep)
					setVirtualKeyDown(13, true)
					setVirtualKeyDown(13, false)
				end
			end
			if moiotvet then
				sampSendDialogResponse(dialogId, 1, _, peremrep)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
			end
			if nakajy then
				sampSendDialogResponse(dialogId, 1, _, peremrep)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				while sampIsDialogActive() do
					wait(0)
				end
				wait(200)
				if oftop then
					sampSendChat('/rmute ' .. autorid .. ' 120 ������ � /report')
					oftop = false
				end
				if oskadm then
					sampSendChat('/rmute ' .. autorid .. ' 2500 ����������� �������������')
					oskadm = false
				end
				if oskrep then
					sampSendChat('/rmute ' .. autorid .. ' 400 �����������/��������')
					oskrep = false
				end
				if poprep then
					sampSendChat('/rmute ' .. autorid .. ' 120 ����������������')
					poprep = false
				end
				if oskrod then
					sampSendChat('/rmute ' .. autorid .. ' 5000 �����������/���������� ������')
					oskrod = false
				end
				if capsrep then
					sampSendChat('/rmute ' .. autorid .. ' 120 ���� � /report')
					capsrep = false
				end
				if matrep then
					sampSendChat('/rmute ' .. autorid .. ' 300 ����������� �������')
					matrep = false
				end
				if kl then
					sampSendChat('/rmute ' .. autorid .. ' 3000 ������� �� �������������')
					kl = false
				end
			end
			if customans then
				if cfg.settings.doptext then
					peremrep = (customans .. doptext)
					if #peremrep >= 80 then
						peremrep = customans
						if #peremrep >= 80 then
							peremrep = u8'��� ����� �� ��������� � ���� �������, � ������ ��� �����'
						end
					end
				else
					peremrep = customans
					if #peremrep >= 80 then
						peredamrep = u8'��� ����� �� ��������� � ���� �������, � ������ ��� �����'
					end
					if #peremrep <= 3 then
						peremrep = (customans .. '    ')
					end
				end
				sampSendDialogResponse(dialogId, 1, _, peremrep)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
			end
			if not saveplayerrecon and (tonumber(autorid) and (slejy or rabotay)) and cfg.settings.ansreport then
				saveplayerrecon = autorid
				timerans()
			end
			myid = nil
			customans = nil
			rabotay = nil
			slejy = nil
			text_buffer.v = ''
			autor = nil
			reportid = nil
			textreport = nil
			ojid = nil
			uto4 = nil
			uto4id = nil
			helpest = nil
			nakajy = nil
			jb = nil
			moiotvet = nil 
			nakazan = nil
		end)
	end
end
function sampev.onDisplayGameText(style, time, text) -- �������� ����� �� ������.
   -- if text:find("REPORT++") then
   --     return false
   -- end
	if text:find('RECON') then
		four_window_state.v = false
		if cfg.settings.keysync then
			sampSetChatInputText('/keysync off')
			sampSetChatInputEnabled(true)
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end
		return false
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
		if(sampIsChatInputActive()) and cfg.settings.inputhelper then
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
		sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}WallHack �������', -1)
		inicfg.save(cfg,directIni)
		local pStSet = sampGetServerSettingsPtr();
		NTdist = mem.getfloat(pStSet + 39)
		NTwalls = mem.getint8(pStSet + 47)
		NTshow = mem.getint8(pStSet + 56)
		mem.setfloat(pStSet + 39, 1400.0)
		mem.setint8(pStSet + 47, 0)
		mem.setint8(pStSet + 56, 1)
		nameTag = true
	else
		cfg.settings.wallhack = false
		checked_test14 = imgui.ImBool(false)
		sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}WallHack ��������', -1)
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
sampRegisterChatCommand('add_mat', function(param)
	key = #cfg.osk + 1
	param = param:lower()
	param = param:rlower()
    for k, v in pairs(cfg.mat) do
        if cfg.mat[k] == param then
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. param .. ' {F0E68C}��� ������� � ������ �����.' , -1)
            a = true
            break
        else    
            a = false
        end
    end
    if not a then
		param = param:lower()
		param = param:rlower()
        cfg.mat[key] = param
        inicfg.save(cfg,directIni)
        sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. param .. ' {F0E68C}������� ��������� � ������ �����', -1)
        a = nil
    end
end)
sampRegisterChatCommand('del_mat', function(param)
	key = #cfg.osk + 1
	param = param:lower()
	param = param:rlower()
    for k, v in pairs(cfg.mat) do
        if cfg.mat[k] == param then
            cfg.mat[k] = nil
            inicfg.save(cfg,directIni)
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ��������� ���� �����{008000} ' .. param .. ' {F0E68C}���� ������� ������� �� ������ �����', -1)
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
end)


sampRegisterChatCommand('add_osk', function(param)
	key = #cfg.osk + 1
	param = param:lower()
	param = param:rlower()
    for k, v in pairs(cfg.osk) do
        if cfg.osk[k] == param then
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. param .. ' {F0E68C}��� ������� � ������ �����������.' , -1)
            a = true
            break
        else    
            a = false
        end
    end
    if not a then
        key = #cfg.osk + 1
        cfg.osk[key] = param
        inicfg.save(cfg,directIni)
        sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. param .. ' {F0E68C}���� ������� ��������� � ������ �����������', -1)
        a = false
    end
end)

sampRegisterChatCommand('del_osk', function(param)
	key = #cfg.osk + 1
	param = param:lower()
	param = param:rlower()
    for k, v in pairs(cfg.osk) do
        if cfg.osk[k] == param then
            cfg.osk[k] = nil
            inicfg.save(cfg,directIni)
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ��������� ���� �����{008000} ' .. param .. ' {F0E68C}���� ������� ������� �� ������', -1)
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
end)
sampRegisterChatCommand('tool', function()
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end)
sampRegisterChatCommand('textform', function(param) 
	cfg.settings.texts = param
	inicfg.save(cfg,directIni)
	sampAddChatMessage('{C0C0C0}RDS Tools: {FAEBD7}����� �������� ����� ��������', -1)
end)
sampRegisterChatCommand('stylecolor', function(param)
	cfg.settings.stylecolor = ('{' .. param .. '}')
	inicfg.save(cfg,directIni)
	sett = true
	st.bool = true
	st.timer = os.clock()
	forma = ('//iban 75 7 cheat // Administrator')
end)
sampRegisterChatCommand('stylecolorform', function(param)
	cfg.settings.stylecolorform = ('{' .. param .. '}')
	inicfg.save(cfg,directIni)
	sett = true
	st.bool = true
	st.timer = os.clock()
	forma = ('//iban 75 7 cheat // Administrator')
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
			sampSendChat('/ans ' .. param .. ' �� ���� ��������� �� ������� ������. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' �� ���� ��������� �� ������� ������.')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dp', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' � ������ ������� ������� �� /donate ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' � ������ ������� ������� �� /donate')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('c', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' �����(�) ������ ��� ����� �������. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' �����(�) ������ ��� ����� �������.')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cl', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' ������ ����� ����. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' ������ ����� ����.')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('nak', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' ����� ��� �������, ������� �� ���������. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' ����� ��� �������, ������� �� ���������.')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('pv', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' ������� ���. ����������� ��� ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' ������� ���. ����������� ���')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('afk', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' ����� ������������ ��� ��������� � AFK ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' ����� ������������ ��� ��������� � AFK')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('nv', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' ����� �� � ���� ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' ����� �� � ����')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
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
		sampSendChat("/prefix " .. param .. " �������-������������� " .. color())
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
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('uu', function(param) 
	if #param ~= 0 then
		sampSendChat('/unmute ' .. param) 
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('uj', function(param) 
	if #param ~= 0 then
		sampSendChat('/unjail ' .. param) 
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('al', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' ������������! �� ������ ������ /alogin!') 
		sampSendChat('/ans ' .. param .. ' ������� ������� /alogin � ���� ������, ����������.')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rep', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' ������ ������ ��� ������������ �� ������ �� ������ � /report') 
		sampSendChat('/ans ' .. param .. ' ������������� ����� ����� ��� ������.')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('as', function(param) 
	if #param ~= 0 then
		sampSendChat('/aspawn ' .. param)
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
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
        sampAddChatMessage('/banip [���] [�����] [�������]', -1)
    end
end)
----======================= ������������� ��� ����� ���� ===============------------------
sampRegisterChatCommand('m', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 300 ����������� �������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('mf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 300 ����������� �������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('m2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 600 ����������� ������� x2')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('m3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 900 ����������� ������� x3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ok', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 400 �����������/��������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('okf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 400 �����������/��������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ok2', function(param) 
	if #param ~= 0 then
 		sampSendChat('/mute ' .. param .. ' 800 �����������/�������� x2')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ok3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1200 �����������/�������� x3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('fd', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 ����')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('fdf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 ����')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('fd2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 240 ���� x2')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('fd3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 ���� x3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('or', function(param) 
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 5000 �����������/���������� ������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('orf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 �����������/���������� ������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('up', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1000 ���������� ��������� ��������')
		sampSendChat('/cc')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('upf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 ���������� ��������� ��������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oa', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 2500 ����������� �������������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 ����������� �������������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('kl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 3000 ������� �� �������������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('klf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 3000 ������� �� �������������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('po', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 ����������������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('pof', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 ����������������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('po2', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 240 ���������������� x2')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('po3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 ���������������� x3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('zs', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 600 ��������������� ���������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('zsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 600 ��������������� ���������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rekl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 1000 �������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('reklf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 �������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rz', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 5000 ������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 ������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ia', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 2500 ������ ���� �� ��������������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('iaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 ������ ���� �� ��������������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
----======================= ������������� ��� ����� ������� ===============------------------
sampRegisterChatCommand('oft', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oftf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oft2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Offtop in /report x2")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oft3', function(param) 
	if param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Offtop in /report x3")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cp', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cpf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cp2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Caps in /report x2")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('cp3', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Caps in /report x3")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('roa', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 2500 ����������� �������������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('roaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 2500 ����������� �������������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ror', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 �����������/���������� ������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rorf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 �����������/���������� ������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rzs', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 600 ��������������� ���������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rzsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 600 ��������������� ���������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rrz', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 ������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rrzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 ������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rpo', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 ����������������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rpof', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 ����������������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rm', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 300 ��� � /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 300 ����������� �������")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rok', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 400 ����������� � /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('rokf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 400 ����������� � /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
----======================= ������������� ��� ������ ===============------------------
sampRegisterChatCommand('dz', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ��/�� � ������� ����')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ��/�� � ������� ����')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('zv', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. " 3000 ��������������� VIP'��")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('zvf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 3000 ��������������� VIP'o�")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('sk', function(param)
	if #param ~= 0 then 
		sampSendChat('/jail ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('skf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dk', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 �� ���� � ������� ����')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('dkf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 �� ���� � ������� ����')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('td', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 car in /trade')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('tdf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 300 Car in /trade")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jcb', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 3000 ��������� ������/��')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jcbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 3000 ��������� ������/��')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jm', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ��������� ������ ��')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ��������� ������ ��')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jc', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 ��������� ������/��')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('jcf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 ��������� ������/��')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('baguse', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('bagusef', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
----======================= ������������� ��� ���� ===============------------------
sampRegisterChatCommand('bosk', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 999 ����������� �������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('boskf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 ����������� �������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('reklama', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 999 �������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('reklamaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 �������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('obm', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 30 �����/������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('obmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 30 �����/������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('nmb', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 ������������ ���������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('nmbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 3 ������������ ���������')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('ch', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' ��������� �����, �� �������� �� ��������� ������ �������.')
		sampSendChat('/ans ' .. param .. ' ���� �� �� �������� � �������� ����������, �������� ������ �� https://forumrds.ru')
		sampSendChat('/iban ' .. param .. ' 7 ��������� ������/��')
		if tonumber(playerrecon) == tonumber(param) then
			four_window_state.v = false
			lua_thread.create(function()
				wait(500)
				sampSetChatInputText('/keysync off')
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
			end)
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('chf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 7 ��������� ������/��')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('oskhelper', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 ��������� ������ /helper')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
----======================= ������������� ��� ����� ===============------------------
sampRegisterChatCommand('cafk', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' AFK in /arena') 
		four_window_state.v = false
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('kk1', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' ������� ��� 1/3') 
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('kk2', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' ������� ��� 2/3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)
sampRegisterChatCommand('kk3', function(param)
	if #param ~= 0 then 
		sampSendChat('/ban ' .. param .. ' 7 ������� ��� 3/3') 
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}�� �� ������� ��������.')
	end
end)


function style() -- ����� �����
    imgui.SwitchContext()
    local style  = imgui.GetStyle()
    local colors = style.Colors
    local clr    = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding       = ImVec2(10, 10)
    style.WindowRounding      = 10
    style.ChildWindowRounding = 2
    style.FramePadding        = ImVec2(5, 4)
    style.FrameRounding       = 11
    style.ItemSpacing         = ImVec2(4, 4)
    style.TouchExtraPadding   = ImVec2(0, 0)
    style.IndentSpacing       = 21
    style.ScrollbarSize       = 16
    style.ScrollbarRounding   = 16
    style.GrabMinSize         = 11
    style.GrabRounding        = 16
    style.WindowTitleAlign    = ImVec2(0.5, 0.5)
    style.ButtonTextAlign     = ImVec2(0.5, 0.5)

    colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.94)
    colors[clr.ChildWindowBg]        = ImVec4(10.00, 10.00, 10.00, 0.01)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.00, 0.39, 1.00, 0.65)
    colors[clr.FrameBgHovered]       = ImVec4(0.11, 0.40, 0.69, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.11, 0.40, 0.69, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(0.00, 0.24, 0.54, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.22, 1.00, 0.67)
    colors[clr.MenuBarBg]            = ImVec4(0.08, 0.44, 1.00, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.34, 0.67, 1.00, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.84, 0.66, 0.66, 1.00)
    colors[clr.Button]               = ImVec4(0.00, 0.39, 1.00, 0.65)
    colors[clr.ButtonHovered]        = ImVec4(0.00, 0.64, 1.00, 0.65)
    colors[clr.ButtonActive]         = ImVec4(0.00, 0.53, 1.00, 0.50)
    colors[clr.Header]               = ImVec4(0.00, 0.62, 1.00, 0.54)
    colors[clr.HeaderHovered]        = ImVec4(0.00, 0.36, 1.00, 0.65)
    colors[clr.HeaderActive]         = ImVec4(0.00, 0.53, 1.00, 0.00)
    colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.SeparatorHovered]     = ImVec4(0.71, 0.39, 0.39, 0.54)
    colors[clr.SeparatorActive]      = ImVec4(0.71, 0.39, 0.39, 0.54)
    colors[clr.ResizeGrip]           = ImVec4(0.71, 0.39, 0.39, 0.54)
    colors[clr.ResizeGripHovered]    = ImVec4(0.84, 0.66, 0.66, 0.66)
    colors[clr.ResizeGripActive]     = ImVec4(0.84, 0.66, 0.66, 0.66)
    colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end
style()


local function get_loaded_scripts()
    local all = get_files(getWorkingDirectory(), { '*.lua', '*.luac' })
    local loaded, unloaded = script.list(), {}
    for i = 1, #all do
        local b = false
        for l = 1, #loaded do
            if get_name_of_path(loaded[l].path) == all[i] then
                b = true
                break
            end
        end
        if not b then unloaded[#unloaded + 1] = all[i] end
    end
    return loaded, unloaded
end




















---------- ��� ID � ���� ���� ----------- (���� ������ ������ ���.)
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
