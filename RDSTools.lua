require 'lib.moonloader'
require 'lib.sampfuncs'
script_name 'RDS Tools Lite' 
script_author 'Neon4ik'
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
local version = 1.0
local imgui = require 'imgui' 
local sampev = require 'lib.samp.events'
local mimgui = require "mimgui"
local se = require "samp.events"
local inicfg = require 'inicfg'
local directIni = 'RDSToolsLite.ini'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local ev = require 'lib.samp.events'
local vkeys = require 'vkeys'
local ffi = require "ffi"
local mem = require "memory"
local font = require ("moonloader").font_flag
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local path_fastspawn = getWorkingDirectory() .. "\\resource\\FastSpawn.lua" -- подгрузка скрипта для быстрого спавна
local path_trassera = getWorkingDirectory() .. "\\resource\\trassera.lua" -- подгрузка скрипта для трассеров

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
local cfg = inicfg.load({ -- базовые настройки скрипта
	settings = {
		autoonline = false,
		inputhelper = true,
		prefixma = '2E8B57',
		prefixa = '87CEEB',
		prefixsa = 'FF4500',
		doptext = true,
		mytextreport = ' // Приятной игры на RDS <3',
		customposx = false,
		customposy = false,
		keysync = true,
		ans = 'None',
		tr = 'None',
		wh = 'None',
		agm = 'None',
		rep = 'None',
		trassera = false,
		wallhack = true,
		fastspawn = false,
		bloknotik = '',
		acon = false,
		chatposx = nil,
		chatposy = nil,
		size = 10,
		limit = 5
	},
	script = {
		version = 1.0
	},
}, directIni)
inicfg.save(cfg,directIni)
local target = -1
local keys = {
	["onfoot"] = {},
	["vehicle"] = {}
}


local fontsize = nil
function imgui.BeforeDrawFrame()
    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 17, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
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

local checked_test1 = imgui.ImBool(cfg.settings.form)
local checked_test2 = imgui.ImBool(cfg.settings.keysync)
local checked_test3 = imgui.ImBool(cfg.settings.autoonline)
local checked_test4 = imgui.ImBool(cfg.settings.cleaner)
local checked_test5 = imgui.ImBool(cfg.settings.check_weapon_hack)
local checked_test6 = imgui.ImBool(cfg.settings.fastspawn)
local checked_test7 = imgui.ImBool(cfg.settings.fld)
local checked_test8 = imgui.ImBool(cfg.settings.acon)
local checked_test11 = imgui.ImBool(cfg.settings.trassera)
local checked_test13 = imgui.ImBool(cfg.settings.inputhelper)
local checked_test14 = imgui.ImBool(cfg.settings.wallhack)
local checked_test15 = imgui.ImBool(cfg.settings.doptext)
local selected_item = imgui.ImInt(cfg.settings.size)
local selected_item2 = imgui.ImInt(cfg.settings.limit)
local bloknotik = imgui.ImBuffer(cfg.settings.bloknotik, 1024)
local bloknotik_window_state = imgui.ImBool(false)
local fastcomand_window_state = imgui.ImBool(false)
local sw, sh = getScreenResolution()
local text_buffer = imgui.ImBuffer(256)
local main_window_state = imgui.ImBool(false)
local secondary_window_state = imgui.ImBool(false)
local tree_window_state = imgui.ImBool(false)
local four_window_state = imgui.ImBool(false)
local fourtwo_window_state = imgui.ImBool(false)
local five_window_state = imgui.ImBool(false)
local ban_window_state = imgui.ImBool(false)
local mute_window_state = imgui.ImBool(false)
local jail_window_state = imgui.ImBool(false)
local kick_window_state = imgui.ImBool(false)
local rmute_window_state = imgui.ImBool(false)
local floods_window_state = imgui.ImBool(false)
local ac_window_state = imgui.ImBool(false)
local afkstate = false
function main()
	while not isSampAvailable() do wait(0) end
	font_adminchat = renderCreateFont("Javanese Text", cfg.settings.size, font.BOLD + font.BORDER + font.SHADOW)
	func0 = lua_thread.create_suspended(ac0)
	func1 = lua_thread.create_suspended(ac1)
	func2 = lua_thread.create_suspended(ac2)
	func3 = lua_thread.create_suspended(ac3)
	func4 = lua_thread.create_suspended(ac4)
	func5 = lua_thread.create_suspended(ac5)
	func = lua_thread.create_suspended(ao)
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
	local dlstatus = require('moonloader').download_status
	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.ini" -- Ссылка на конфиг
	local update_path = getWorkingDirectory() .. "/RDSTools.ini" -- и тут ту же самую ссылку
	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.lua" -- Ссылка на сам файл
	local script_path = thisScript().path
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            RDSToolsLite = inicfg.load(nil, update_path)
            if tonumber(RDSToolsLite.script.version) > version then
                update_state = true
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Найдено обновление, загрузить можно командой {808080}/update', -1)
			end
            os.remove(update_path)
        end
    end)
	sampRegisterChatCommand('update', function(param)
		if update_state then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					wait(10000)
					sampShowDialog(1000, "xX RDS Tools Xx", '{FFFFFF}Была найдена новая версия - ' .. RDSToolsLite.script.version .. '\n{FFFFFF}В ней добавлено ' .. RDSTools.script.info, "Спасибо", "", 0)
					showCursor(false,false)
					thisScript():reload()
				end
			end)
		else
			sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}У вас установлена актуальная версия.')
		end
	end)
	imgui.Process = false
	inputHelpText = renderCreateFont("Arial", 9, FCR_BORDER + FCR_BOLD) -- шрифт инпут хелпера
	lua_thread.create(inputChat)
	if cfg.settings.fastspawn then
		local fastspawn = import(path_fastspawn) -- подгрузка скрипта фастспавн
	end
	if cfg.settings.trassera then
		local trassera = import(path_trassera) -- подгрузка трассеров
	end
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
		if isKeyJustPressed(VK_F3) and not sampIsDialogActive() then  -- кнопка активации окна RDS Tools
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
		if isKeyJustPressed(strToIdKeys(cfg.settings.ans)) and not sampIsChatInputActive() and not sampIsDialogActive() and not fastcomand_window_state.v then
			sampSendChat("/ans ")
			sampSendDialogResponse (2348, 1, 0)
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.tr)) and not sampIsChatInputActive() and not sampIsDialogActive() and not fastcomand_window_state.v then
			sampSendChat("/tr ")
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.wh)) and not sampIsChatInputActive() and not sampIsDialogActive() and not fastcomand_window_state.v then
			sampSetChatInputText('/wh ')
			sampSetChatInputEnabled(true)
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.agm)) and not sampIsChatInputActive() and not sampIsDialogActive() and not fastcomand_window_state.v then
			sampSendChat('/agm ')
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.rep)) and not sampIsChatInputActive() and not sampIsDialogActive() and not fastcomand_window_state.v then
			sampSendChat('/a /ANS /ANS /ANS /ANS /ANS /ANS ANS /ANS /ANS')
		end
	end
end


function ao() -- автоонлайн
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
---------------===================== Определенение ID нажатой клавиши
function color() -- рандом префикс
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
function imgui.CenterText(text) -- центрирование текста
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 ) 			
    imgui.Text(text)
end
local w = { -- задаем ширину для флудера
    second = 150,
}
local menu = {true, -- рекон меню
    false,
}
local menu2 = {true, -- рекон меню
    false,
}
function imgui.OnDrawFrame()
	if not main_window_state.v and not tree_window_state.v and not four_window_state.v and not fourtwo_window_state.v and not five_window_state.v and not secondary_window_state.v and not floods_window_state.v and not fastcomand_window_state.v and not ac_window_state.v then
		imgui.Process = false
		showCursor(false,false)
	end
	if main_window_state.v then -- КНОПКИ ИНТЕРФЕЙСА F3
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2)-150, (sh / 2)-125), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('xX   ' .. " RDS Tools " .. '  Xx', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Button(u8"Вкл/выкл", imgui.ImVec2(125, 20)) then uu2() menu2[1] = true end imgui.SameLine()
        if imgui.Button(u8'Дополнение', imgui.ImVec2(125, 20)) then uu2() menu2[2] = true end 
		imgui.PushFont(fontsize)
        imgui.Separator()
        imgui.NewLine()
        imgui.SameLine(2)
		if menu2[1] then
			imgui.SetCursorPosX(10)
			if imgui.Checkbox(u8'Вирт.клавиши', checked_test2) then
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
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}: Зачем париться при входе? Всё сделаю сам, ты только настрой. Активация: /fs', -1)
					showCursor(false,false)
					thisScript():reload()
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"Трассера", checked_test11) then
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
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}: Ни один выстрел не пройдёт незамеченным! Активация: /trassera')
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
		end
		if menu2[2] then
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'Открыть команды', imgui.ImVec2(250, 24)) then
				secondary_window_state.v = not secondary_window_state.v
			end
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'Открыть флуды', imgui.ImVec2(250, 24)) then
				floods_window_state.v = not floods_window_state.v
			end
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'Открыть блокнот', imgui.ImVec2(250, 24)) then
				bloknotik_window_state.v = not bloknotik_window_state.v
			end
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'Открыть быстрые клавиши', imgui.ImVec2(250, 24)) then
				fastcomand_window_state.v = not fastcomand_window_state.v
			end
			imgui.SetCursorPosX(10)
			imgui.Separator()
			if imgui.Button(u8'Сохранить позицию Recon Menu', imgui.ImVec2(250, 24)) then
				fourtwo_window_state.v = not fourtwo_window_state.v
			end
			imgui.SetCursorPosX(10)
			if cfg.settings.acon then
				if imgui.Button(u8'Настройка админ-чата', imgui.ImVec2(250, 24)) then
					ac_window_state.v = not ac_window_state.v
				end
			end
			imgui.SetCursorPosX(10)
			if cfg.settings.keysync then
				if imgui.Button(u8'Сохранить позицию вирт.клавиш', imgui.ImVec2(250, 24)) then
					five_window_state.v = not five_window_state.v 
				end
			end
			imgui.SetCursorPosX(10)
		end
		imgui.PopFont()
		imgui.End()
	end
	if ac_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Админ-чат', ac_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Button(u8'Сохранить позицию') then
			local pos = imgui.GetWindowPos()
			cfg.settings.chatposx = pos.x
			cfg.settings.chatposy = pos.y
			inicfg.save(cfg,directIni)
		end
		imgui.Text(u8'Размер: ')
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
		imgui.End()
	end
	if fastcomand_window_state.v then -- быстрые клавиши
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Зажми и сохрани", fastcomand_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.Text(u8'Открытие репорта:')
		imgui.SameLine()
		imgui.Text(u8(cfg.settings.ans))
		if imgui.Button(u8"Сoxрaнить.", imgui.ImVec2(230, 0)) then
			cfg.settings.ans = getDownKeysText()
			inicfg.save(cfg,directIni)
		end
		imgui.Text(u8'Вкл/выкл быстрого репорта')
		imgui.SameLine()
		imgui.Text(u8(cfg.settings.tr))
		if imgui.Button(u8"Соxрaнить.", imgui.ImVec2(230, 0)) then
			cfg.settings.tr = getDownKeysText()
			inicfg.save(cfg,directIni)
		end
		imgui.Text(u8"Вкл/выкл WallHack: ")
		imgui.SameLine()
		imgui.Text(u8(cfg.settings.wh))
		if imgui.Button(u8"Cоxрaнить.", imgui.ImVec2(230, 0)) then
			cfg.settings.wh = getDownKeysText()
			inicfg.save(cfg,directIni)
		end
		imgui.Text(u8"Вкл/выкл бессмертия: ")
		imgui.SameLine()
		imgui.Text(u8(cfg.settings.agm))
		if imgui.Button(u8"Coxрaнить.", imgui.ImVec2(230, 0)) then
			cfg.settings.agm = getDownKeysText()
			inicfg.save(cfg,directIni)
		end
		imgui.Text(u8"Напоминание в /a о репорте: ")
		imgui.SameLine()
		imgui.Text(u8(cfg.settings.rep))
		if imgui.Button(u8"Соxpaнить.", imgui.ImVec2(230, 0)) then
			cfg.settings.rep = getDownKeysText()
			inicfg.save(cfg,directIni)
		end
		imgui.Separator()
		if imgui.Button(u8"Сбросить все значения.", imgui.ImVec2(230, 0)) then
			cfg.settings.rep = 'None'
			cfg.settings.ans = 'None'
			cfg.settings.wh = 'None'
			cfg.settings.agm = 'None'
			cfg.settings.tr = 'None'
			inicfg.save(cfg,directIni)
		end
		imgui.End()
	end
	if secondary_window_state.v then -- быстрые команды
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Быстрые команды", secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.CenterText(u8'Скрипт')
		imgui.Text(u8'/tool - открыть меню скрипта\n/wh - вкл/выкл функцию WallHack\n/mytextreport - поставить свой текст после ответа на репорта\n/newprfma - новый цвет префикса Мл.Администратора\n/newprfa - новый префикса Администратора\n/newprfsa - новый префикс Старшего Администратора')
		imgui.Separator()
		imgui.CenterText(u8'Вспомогательные команды')
		imgui.Text(u8'/n - Не вижу нарушений от игрока\n/c - начал(а) работу над вашей жалобой\n/cl - данный игрок чист\n/nv - Игрок не в сети\n/prfma - выдать префикса Мл.Администратору\n/prfa - Выдать префикс Администратору\n/prfsa - выдать префикс Ст.Администратору\n/prfpga - выдать префикс ПГА\n/prfzga - выдать префикс ЗГА\n/prfga - выдать префикс ГА\n/prfcpec - Выдать префикс Спец.Администратора\n/stw - выдать миниган\n/uu - краткая команда снятия мута\n/al - Напомнить администратору про /alogin\n/as - заспавнить игрока\n/spp - заспавнить всех в радиусе\n/sbanip - заблокировать игрока по нику в оффлайне с IP (ФД!)')
		imgui.Separator()
		imgui.CenterText(u8'Выдать мут чата')
		imgui.Text(u8'/m - /m3 мат\n/ok - /ok3 оскорбление\n/fd - /fd3 флуд\n/or - оск/упом родных\n/up - упоминание родных с очисткой чата\n/oa - оскорбление администрации\n/kl - клевета на администрацию\n/po - /po3 - попрошайничество\n/rekl - реклама\n/zs - злоупотребление символами\n/rz - розжиг\n/ia - выдача себя за администрацию')
		imgui.Separator()
		imgui.CenterText(u8'Выдать мут репорта')
		imgui.Text(u8'/oft - /oft3 оффтоп\n/cp - /cp3 капс\n/roa - оскорбление администрации\n/ror - оск/упом род\n/rzs - злоупотребление символами\n/rrz - розжиг\n/rpo - попрошайничество\n/rm - мат\n/rok - оскорбление')
		imgui.Separator()
		imgui.CenterText(u8'Посадить в тюрьму')
		imgui.Text(u8'/dz - ДМ/ДБ в зеленой зоне\n/zv - Злоупотребление VIP статусом\n/sk - Спавн-Килл\n/td - Car in /trade\n/jcb - вредительские читы(альтернатива бану)\n/jc - безвредные читы\n/baguse - багоюз')
		imgui.Separator()
		imgui.CenterText(u8'Кикнуть игрока')
		imgui.Text(u8'/cafk - Афк на арене\n/kk1 - Смените ник 1/3\n/kk2 - Смените ник 2/3\n/kk3 - Смените ник 3/3 (бан)')
		imgui.Separator()
		imgui.CenterText(u8'Блокировка аккаунта')
		imgui.CenterText(u8'Максимальное наказание команд - 7 дней.')
		imgui.Text(u8'/ch - читы\n/bosk - оскорбление проекта\n/obm - Обман/развод\n/neadekv - Неадекватное поведение(3 дня)\n/oskhelper - Нарушение правил хелпера\n/reklama - реклама')
		imgui.End()
	end
	if tree_window_state.v then -- быстрый ответ на репорт
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2) - 250, (sh / 2)-90), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Ответ на репорт", tree_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8'Репорт от игрока ' .. autor .. '[' ..autorid.. ']: ')
		imgui.Text(u8'Жалоба: ' .. u8(textreport))
		imgui.NewInputText('##SearchBar', text_buffer, 200, u8' ', 2)
		imgui.SameLine()
		imgui.SetCursorPosX(210)
		if imgui.Checkbox(' ', checked_test15) then
			cfg.settings.doptext = not cfg.settings.doptext
			inicfg.save(cfg,directIni)
		end
		imgui.SameLine()
		imgui.SetCursorPosX(240)
		if imgui.Button(u8'Отправить', imgui.ImVec2(120, 25)) then
			moiotvet = true
		end
		imgui.Separator()
		if imgui.Button(u8'Работаю', imgui.ImVec2(120, 25)) then
			rabotay = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Слежу', imgui.ImVec2(120, 25)) then
			slejy = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Уточните', imgui.ImVec2(120, 25)) then
			uto4 = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Передам', imgui.ImVec2(120, 25)) then
			peredamrep = true
		end
		if imgui.Button(u8'Наказать автора', imgui.ImVec2(120, 25)) then
			nakajy = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Форум', imgui.ImVec2(120, 25)) then
			jb = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Ожидайте', imgui.ImVec2(120, 25)) then
			ojid = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Интернет', imgui.ImVec2(120, 25)) then
			internet = true
		end
		if imgui.Button(u8'Уточните ID', imgui.ImVec2(120, 25)) then
			uto4id = true
		end
		imgui.SameLine()
		if imgui.Button(u8'/help', imgui.ImVec2(120, 25)) then
			helpest = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Игрок наказан', imgui.ImVec2(120, 25)) then
			nakazan = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Отклонить', imgui.ImVec2(120, 25)) then
			otklon = true
		end
		imgui.PopFont()
		imgui.Separator()
		imgui.End()
	end
	if bloknotik_window_state.v then -- блокнот
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2)-200, (sh / 2)-250), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Блокнот", bloknotik_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		bloknotik.v = string.gsub(bloknotik.v, "\\n", "\n")
		if imgui.InputTextMultiline("#1", bloknotik, imgui.ImVec2(400, 500)) then
			bloknotik.v = string.gsub(bloknotik.v, "\n", "\\n")
			cfg.settings.bloknotik = bloknotik.v
			inicfg.save(cfg,directIni)	
		end
		imgui.End()
	end
	if ban_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Выдать блокировку аккаунта", ban_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.Text(u8'Выберите причину:')
		if not sampIsDialogActive() then
			if imgui.Button(u8'Читы', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/ch ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Многочисленные нарушения (3)', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/iban ' .. playerrecon .. ' 3 Неадекватное поведение')
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Нарушение правил хелпера', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/oskhelper ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Оскорбление проекта', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/bosk ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Реклама', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/reklama ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Обман', imgui.ImVec2(250, 25)) then
				sampSendChat('/siban ' .. playerrecon .. ' 30 Обман/развод')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Название банды', imgui.ImVec2(250, 25)) then
				sampSendChat('/iban ' .. playerrecon .. ' 7 Название банды')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
		else
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}Закройте диалог, чтобы продолжить.', -1)
		end
		imgui.End()
	end
	if jail_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Посадить игрока в тюрьму", jail_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.Text(u8'Выберите причину:')
		if not sampIsDialogActive() then
			if imgui.Button(u8'DM/DB in ZZ', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/dz ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8"Злоупотребление VIP'ом", imgui.ImVec2(250, 25)) then
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
			if imgui.Button(u8'Car in /trade', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/td ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'Чит', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/jcb ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'Чит безвредный', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/jc ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'ДБ ковш в зеленой зоне', imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. ' ДБ ковш в зеленой зоне')
				showCursor(false,false)
				jail_window_state.v = false
			end
		else
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}Закройте диалог, чтобы продолжить.', -1)
		end
		imgui.End()
	end
	if mute_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Заблокировать чат игроку", mute_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.Text(u8'Выберите причину:')
		if not sampIsDialogActive() then
			if imgui.Button(u8'Оскорбление', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/ok ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8"Мат", imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/m ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8"Флуд", imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/fd ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Попрошайничество', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/po ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Оскорбление родных', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/or ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Оскорбление администрации', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/oa ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Клевета на администрацию', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/kl ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Злоупотребление символами', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/zs ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Выдача себя за администратора', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/ia ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Упоминание сторонних проектов', imgui.ImVec2(250, 25)) then
				sampSetChatInputText('/up ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				showCursor(false,false)
				mute_window_state.v = false
			end
		else
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}Закройте диалог, чтобы продолжить.', -1)
		end
		imgui.End()
	end
	if kick_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Кикнуть игрока с сервера", kick_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.Text(u8'Выберите причину:')
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
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}Закройте диалог, чтобы продолжить.', -1)
		end
		imgui.End()
	end
	if four_window_state.v then -- кастом рекон меню
		if cfg.settings.customposx then
			imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.customposx, cfg.settings.customposy))
		else
			imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		end
		imgui.Begin(u8"Рекон", four_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Button(u8"Основная вкладка", imgui.ImVec2(125, 20)) then uu() menu[1] = true end imgui.SameLine()
        if imgui.Button(u8'Игроки в радиусе', imgui.ImVec2(125, 20)) then uu() menu[2] = true end 
        imgui.Separator()
        imgui.NewLine()
        imgui.SameLine(3)
        if menu[1] then
			imgui.PushFont(fontsize)
			if imgui.Button(u8'+', imgui.ImVec2(20, 20)) then
				setClipboardText(nickplayerrecon)
				sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}Ник скопирован в буффер обмена.', -1)
			end
			imgui.SameLine()
			imgui.Text(u8('Игрок: ' .. nickplayerrecon) .. '[' .. playerrecon .. ']' )
			imgui.SameLine()
			imgui.SetCursorPosX(235)
			if imgui.Button('->') then
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
				imgui.Text(u8'Здоровье авто: ' .. u8(hpcar))
			end
			if speed then
				imgui.Text(u8'Скорость: ' .. u8(speed))
			end
			if ping then
				imgui.Text(u8'Пинг: ' .. u8(ping))
			end
			if ploss then
				imgui.Text(u8'P.Loss: ' .. u8(ploss))
			end
			if gun then
				imgui.Text(u8'Оружие: ' .. u8(gun))
				if aim then
					imgui.Text(u8'Точность: ' .. u8(aim))
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
				imgui.Text(u8'Турбо пакет: ' .. u8(turbo))
			end
			if collision then
				imgui.Text(u8'Коллизия: ' .. u8(collision))
			end
			if imgui.Button(u8'Посмотреть статистику', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					sampSendChat('/statpl ' .. playerrecon)
				else
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}У вас открыт диалог, закройте его.', -1)
				end
			end
			if imgui.Button(u8'Посмотреть offline статистику', imgui.ImVec2(250, 25)) then
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
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}У вас открыт диалог, закройте его.', -1)
				end
			end
			if imgui.Button(u8'Посмотреть вторую статистику', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					sampSendClickTextdraw(165)
				else
					sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}У вас открыт диалог, закройте его.', -1)
				end
			end
			if imgui.Button(u8'Открыть быстрые команды', imgui.ImVec2(250, 25)) then
				secondary_window_state.v = true
			end
			if imgui.Button(u8'Заблокировать игрока', imgui.ImVec2(250, 25)) then
				ban_window_state.v = true
			end
			if imgui.Button(u8'Посадить в джайл', imgui.ImVec2(250, 25)) then
				jail_window_state.v = true
			end
			if imgui.Button(u8'Выдать мут', imgui.ImVec2(250, 25)) then
				mute_window_state.v = true
			end
			if imgui.Button(u8'Кикнуть игрока', imgui.ImVec2(250, 25)) then
				kick_window_state.v = true
			end
			if isKeyJustPressed(VK_R) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(156)
				lua_thread.create(function()
					if cfg.settings.keysync then
						wait(1000)
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
					wait(70)
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
	if fourtwo_window_state.v then -- Сохранения расположения кастом рекон меню
		imgui.SetNextWindowSize(imgui.ImVec2(250, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Настройки рекона", fourtwo_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.Button(u8'Сохранить выбранную позицию.', imgui.ImVec2(250, 25)) then
			if four_window_state.v then
				local pos = imgui.GetWindowPos()
				cfg.settings.customposx = pos.x
				cfg.settings.customposy = pos.y
				inicfg.save(cfg,directIni)
				fourtwo_window_state.v = false
				four_window_state.v = true
			else
				sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: Зайдите в рекон за кем-нибудь во избежания рассихрона')
			end
		end
		imgui.End()
	end
	if five_window_state.v then -- Сохранение расположения keylogger
		imgui.SetNextWindowSize(imgui.ImVec2(400, 100), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Настройки keylog", five_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.Button(u8"Сохранить расположение", imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.keysyncx = pos.x
			cfg.settings.keysyncy = pos.y
			inicfg.save(cfg,directIni)
			five_window_state.v = false
			main_window_state.v = false
			showCursor(false,false)
		end
		imgui.End()
	end
	if rmute_window_state.v then -- Наказать в окне быстрого репорта
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Выдать блокировку репорта", rmute_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.Button(u8'Оффтоп', imgui.ImVec2(250, 25)) then
			oftop = true
		end
		if imgui.Button(u8'Капс', imgui.ImVec2(250, 25)) then
			capsrep = true
		end
		if imgui.Button(u8'Оскорбление администрации', imgui.ImVec2(250, 25)) then
			oskadm = true
		end
		if imgui.Button(u8'Оскорбление родных', imgui.ImVec2(250, 25)) then
			oskrod = true
		end
		if imgui.Button(u8'Попрошайничество', imgui.ImVec2(250, 25)) then
			poprep = true
		end
		if imgui.Button(u8'Оскорбление', imgui.ImVec2(250, 25)) then
			oskrep = true
		end
		if imgui.Button(u8'Нецензурная лексика', imgui.ImVec2(250, 25)) then
			matrep = true
		end
		imgui.End()
	end
	if floods_window_state.v then -- флуды
		imgui.SetNextWindowSize(imgui.ImVec2(450, 325), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Флуды /mess", floods_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.Columns(3)
			imgui.SetColumnWidth(-1, w.second)
			imgui.Text(u8'      Флуды об /gw')
			if imgui.Button(u8'Aztecas vs Ballas', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Varios Los Aztecas vs Ballas Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
			end
			if imgui.Button(u8'Aztecas vs Grove', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Varios Los Aztecas vs Grove Street Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
			end
			if imgui.Button(u8'Aztecas vs Vagos', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Varios Los Aztecas vs Vagos Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
			end
			if imgui.Button(u8'Aztecas vs Rifa', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Varios Los Aztecas vs The Rifa ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
			end
			if imgui.Button(u8'Ballas vs Grove', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Ballas Gang vs Grove Street Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
			end
			if imgui.Button(u8'Ballas vs Vagos', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Ballas Gang vs Vagos Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
			end
			if imgui.Button(u8'Ballas vs Rifa', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Ballas Gang vs The Rifa ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
			end
			if imgui.Button(u8'Grove vs Vagos', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Grove Street Gang vs Vagos Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
			end
			if imgui.Button(u8'Vagos vs Rifa', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Vagos Gang vs The Rifa ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------=================== GangWar ================-----------')
			end
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, w.second)
			imgui.Text(u8'       Общие флуды')
			if imgui.Button(u8'Спавн авто', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 10 --------=================== Spawn Auto ================-----------')
				sampSendChat('/mess 15 Многоуважаемые дрифтеры и дрифтерши')
				sampSendChat('/mess 15 Через 15 секунд пройдёт респавн всего транспорта на сервере.')
				sampSendChat('/mess 15 Займите свои супер кары во избежания потери :3')
				sampSendChat('/mess 10 --------=================== Spawn Auto ================-----------')
				sampSendChat('/delcarall')
				sampSendChat('/spawncars 15')
			end
			if imgui.Button(u8'/trade', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 3 -----========================= Рынок =====================-------')
				sampSendChat('/mess 0 Мечтал приобрести акксессуары на свой скин?')
				sampSendChat('/mess 0 Бегать с ручным попугайчиком на плече и светится как боженька?')
				sampSendChat('/mess 0 Скорей вводи /trade, большой выбор ассортимента, как от сервера, так и от игроков!')
				sampSendChat('/mess 3 -----========================= Рынок =====================-------')
			end
			if imgui.Button(u8'Автомастерская', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 16 --------=================== Автомастерская ================-----------')
				sampSendChat('/mess 17 Всегда мечтал приобрести ковш на свой кибертрак? Не проблема!')
				sampSendChat('/mess 17 В автомастерских из /tp - разное - автомастерские найдется и не такое.')
				sampSendChat('/mess 17 Сделай апгрейд своего любимчика под свой вкус и цвет')
				sampSendChat('/mess 16 --------=================== Автомастерская ================-----------')
			end
			if imgui.Button(u8'О форуме и группе', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 -------============= Сторонние площадки ==========-----------------')
				sampSendChat('/mess 7 У нашего проекта имеется группа vk.сom/teamadmrds ...')
				sampSendChat('/mess 7 ... и даже форум, на котором игроки могут оставить жалобу на администрацию или игроков.')
				sampSendChat('/mess 7 Следи за новостями и будь вкурсе событий.')
				sampSendChat('/mess 11 -------============= Автомобиль ==========-----------------')
			end
			if imgui.Button(u8'VIP', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 13 --------============ Преимущества VIP ===========------------------')
				sampSendChat('/mess 7 Хочешь играть с друзьями без дискомфорта?')
				sampSendChat('/mess 7 Хочешь всегда телепортироваться по карте и к друзьям, чтобы быть всегда вместе?')
				sampSendChat('/mess 7 Хочешь получать каждый PayDay плюшки на свой аккаунт? Обзаведись VIP-статусом!')
				sampSendChat('/mess 13 --------============ Преимущества VIP ===========------------------')
			end
			if imgui.Button(u8'Арене', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 12 -------============= PVP Arena ==========-----------------')
				sampSendChat('/mess 10 Не знаешь чем заняться? Хочется экшена и быстрой реакции?')
				sampSendChat('/mess 10 Вводи /arena и покажи на что ты способен!')
				sampSendChat('/mess 10 Набей максимальное количество киллов, добейся идеала в своем +C')
				sampSendChat('/mess 12 -------============= PVP Arena ==========-----------------')
			end
			if imgui.Button(u8'Виртуальный мир', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------============ Твой виртуальный мир ===========------------------')
				sampSendChat('/mess 15 Мешают играть? Постоянно преследуют танки и самолёты?')
				sampSendChat('/mess 15 Обычный пассив режим не спасает во время дрифта?')
				sampSendChat('/mess 15 Выход есть! Вводи /dt [0-999] и дрифти с комфортом.')
				sampSendChat('/mess 8 --------============ Твой виртуальный мир ===========------------------')
			end
			if imgui.Button(u8'Покупка автомобиля', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 3 -------============= Автомобиль ==========-----------------')
				sampSendChat('/mess 2 Мечтал приобрести суперкар? Мечтал сделать шикарный тюнинг под себя?')
				sampSendChat('/mess 2 Всё это возможно! Используй /tp - разное - автосалоны и покупай нужное авто.')
				sampSendChat('/mess 2 В автосалоне нет нужного авто? Договорись с игроком, либо телепортируйся на /autoyartp')
				sampSendChat('/mess 3 -------============= Автомобиль ==========-----------------')
			end
			if imgui.Button(u8'О /report', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 17 --------========== Связь с администрацией ==========----------')
				sampSendChat('/mess 13 Нашел читера, нарушителя, матершиника или злостного ДМера?')
				sampSendChat('/mess 13 Появился вопрос о возможностях сервера или его ньансах?')
				sampSendChat('/mess 13 Администрация поможет! Пиши /report и свою жалобу/вопрос')
				sampSendChat('/mess 17 --------========== Связь с администрацией ==========----------')
			end
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, w.second)
			imgui.Text(u8'   Мероприятия /join')
			if imgui.Button(u8'Дерби', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------=================== Мероприятие Дерби ================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Дерби')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 1')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------=================== Мероприятие Дерби ================-----------')
			end
			if imgui.Button(u8'Паркур', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------=================== Мероприятие /parkour ================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Паркур')
				sampSendChat('/mess 0 Чтобы принять участие вводи /parkour либо /join - 2')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------=================== Мероприятие /parkour ================-----------')
			end
			if imgui.Button(u8'PUBG', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------=================== Мероприятие /pubg ================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Pubg')
				sampSendChat('/mess 0 Чтобы принять участие вводи /pubg либо /join - 3')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------=================== Мероприятие /pubg ================-----------')
			end
			if imgui.Button(u8'DAMAGE DEATHMATCH', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------=================== Мероприятие /damagegm ================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие DAMAGE DEATHMATCH')
				sampSendChat('/mess 0 Чтобы принять участие вводи /damagegm либо /join - 4')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------=================== Мероприятие /damagegm ================-----------')
			end
			if imgui.Button(u8'KILL DEATHMATCH', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------=================== Мероприятие KILL DEATHMATCH ================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие DAMAGE DEATHMATCH')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 5')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------=================== Мероприятие KILL DEATHMATCH ================-----------')
			end
			if imgui.Button(u8'Paint Ball', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------=================== Мероприятие Paint Ball ================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Paint Ball')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 7')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------=================== Мероприятие Paint Ball ================-----------')
			end
			if imgui.Button(u8'Зомби vs Людей', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------=================== Зомби против людей ================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Зомби против людей')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 8')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------=================== Зомби против людей ================-----------')
			end
			if imgui.Button(u8'Прятки', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------=================== Мероприятие Прятки ================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Прятки')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 10')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------=================== Мероприятие Прятки ================-----------')
			end
	imgui.End()
	end
end
function uu() -- для вкладок
    for i = 0,2 do
        menu[i] = false
    end
end
function uu2() -- для вкладок
    for i = 0,2 do
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
local count = 0
----- Поток для рендера админ чата ---------------
function ac0()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac0, cfg.settings.chatposx, cfg.settings.chatposy, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac0, 10, sh/2, 0xFFFFFF)
		end
	end
end
function ac1()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac1, cfg.settings.chatposx, cfg.settings.chatposy+20, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac1, 10, sh/2, 0xCCFFFFFF)
		end
	end
end
function ac2()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac2, cfg.settings.chatposx, cfg.settings.chatposy+40, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac2, 10, sh/2, 0xCCFFFFFF)
		end
	end
end
function ac3()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac3, cfg.settings.chatposx, cfg.settings.chatposy+60, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac3, 10, sh/2, 0xCCFFFFFF)
		end
	end
end
function ac4()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac4, cfg.settings.chatposx, cfg.settings.chatposy+80, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac4, 10, sh/2, 0xCCFFFFFF)
		end
	end
end
function ac5()
	while true do
		wait(5)
		if cfg.settings.chatposx then
			renderFontDrawText(font_adminchat, ac5, cfg.settings.chatposx, cfg.settings.chatposy+100, 0xCCFFFFFF)
		else
			renderFontDrawText(font_adminchat, ac5, 10, sh/2, 0xCCFFFFFF)
		end
	end
end
----- Поток для рендера админ чата ---------------
function sampev.onServerMessage(color,text) -- поиск сообщений из админ-чата
	if cfg.settings.acon then
		lua_thread.create(function()
			while true do
				wait(1)
				if text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)") then
					if stop == true then
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
						ac5 = text
						func0:run()
						func1:run()
						func2:run()
						func3:run()
						func4:run()
						func5:run()
						break
					end
					if count == 0 then
						func0:run()
						count = count + 1
						ac0 = text
						break
					end
					if count == 1 then
						func1:run()
						count = count + 1
						ac1 = text
						break
					end
					if count == 2 then
						func2:run()
						count = count + 1
						ac2 = text
						break
					end
					if count == 3 then
						func3:run()
						count = count + 1
						ac3 = text
						break
					end
					if count == 4 then
						func4:run()
						count = count + 1
						ac4 = text
						break
					end
					if count == 5 then
						if count == cfg.settings.limit then
							count = count - 1
							func5:terminate()
							ac5 = text
							func5:run()
							stop = true
						else
							ac5 = text
							func5:run()
						end
						count = count + 1
						break
					end
				end
			end
		end)
		if text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)") then
			return false
		end
	end
end
function sampev.onShowTextDraw(id, data) -- Считываем серверные текстдравы
	lua_thread.create(function()
		if id == 2052 then
			wait(100)
			sampTextdrawSetPos(2052, 2000, 0)
			imgui.Process = true
			playerrecon = sampTextdrawGetString(2052)
			playerrecon = tonumber(playerrecon:match('%((%d+)%)')) -- id нарушителя
			nickplayerrecon = sampGetPlayerNickname(playerrecon) -- ник нарушителя
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
				vip = 'Отсутствует'
			end
			if vip == '1' then
				vip = 'Обыкновенный'
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
				passivemod = 'Выключен'
			else
				passivemod = 'Активирован'
			end
			if turbo == '0' then
				turbo = 'Выключен'
			else
				turbo = 'Активирован'
			end
			if collision == '1' then
				collision = 'Активирована'
			else
				collision = 'Выключена'
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
------------- Input Helper -------------
function getStrByState(keyState)
	if keyState == 0 then
		return "{ffeeaa}Выкл{ffffff}"
	end
	return "{9EC73D}Вкл{ffffff}"
end
function translite(text)
	for k, v in pairs(chars) do
		text = string.gsub(text, k, v)
	end
	return text
end
function inputChat()
	while true do
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
		wait(0)
	end
end
------------- Input Helper -------------
function sampGetPlayerIdByNickname(nick) -- узнать ID по нику
	nick = tostring(nick)
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if nick == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 1003 do
	  if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
		return i
	  end
	end
  end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text) -- Работа с открытими ДИАЛОГАМИ
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
			ipfindclose = false
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
				ipfind = false
				sampSendDialogResponse(16191,1,0)
			end
		end)
	end
	if dialogId == 2349 then -- окно с самим репортом.
		local lineIndex = -1
		for line in text:gmatch("[^\n]+") do
			lineIndex = lineIndex + 1
			if lineIndex == tonumber(1) - 1 then 
				autor = line
				rev = string.reverse(autor)
				don = string.sub(rev, -1)
				if don == '{' then
					autor = string.sub(autor, 24) -- считываем автора жалобы
					autorid = sampGetPlayerIdByNickname(autor)
				end
			end
		end
		local lineIndex = -1
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED) -- узнаем свой ид
		for line in text:gmatch("[^\n]+") do
			lineIndex = lineIndex + 1
			if lineIndex == tonumber(3) - 1 then 
				textreport = line
				rev = string.reverse(textreport)
				don = string.sub(rev, -1)
				if don == '{' then
					textreport = string.sub(textreport, 9) -- текст репорта
					if string.match(textreport, '%d[%d.,]*') then
						if tonumber(string.match(textreport, '%d[%d.,]*')) < 300 then
							reportid = tonumber(string.match(textreport, '%d[%d.,]*'))
							if sampIsPlayerConnected(reportid) then
								nickreportid = sampGetPlayerNickname(reportid) -- ник того на кого жалуются
							end
						end
					end
				end
			end
		end
		tree_window_state.v = not tree_window_state.v
		imgui.Process = tree_window_state
		lua_thread.create(function()
			while rabotay ~= 2 and uto4 ~= 2  and nakajy ~= 2 and slejy ~= 2 and jb ~= 2 and ojid ~= 2 and moiotvet ~= 2 and internet ~= 2 and uto4id ~= 2 and helpest~= 2 and nakazan ~= 2 and otklon ~= 2 and peredamrep ~= 2 do -- ждем нажатия клавиши
				wait(50)
				doptext = ('{'..tostring(color())..'} ' .. cfg.settings.mytextreport)
				if rabotay then
					peremrep = ('Начал(а) работу по вашей жалобе!')
					rabotay = 2
				end
				if ojid then
					peremrep = ('Ожидайте, скоро всё будет.')
					ojid = 2
				end
				if nakazan then
					peremrep = ('Данный игрок уже был наказан.')
					nakazan = 2
				end
				if helpest then
					peremrep = ('Данная информация имеется в /help')
					helpest = 2
				end
				if otklon then
					otklon = 2
				end
				if peredamrep then
					peredamrep = 2
				end
				if uto4id then
					peremrep = ('Уточните ID нарушителя в /report.')
					uto4id = 2
				end
				if nakajy then
					peremrep = ('Будете наказаны за нарушения правил /report')
					rmute_window_state.v = true
					if oftop or oskadm or matrep or oskrep or poprep or oskrod or capsrep then
						nakajy = 2
						rmute_window_state.v = false
					end  
				end
				if jb then
					peremrep = ('Напишите жалобу на forumrds.ru')
					jb = 2
				end
				if internet then
					peremrep = ('С данной информацией вы можете ознакомиться в интернете.')
					internet = 2
				end
				if moiotvet then
					if cfg.settings.doptext then
						peremrep = (u8:decode(text_buffer.v) .. doptext)
						if #peremrep >= 80 then
							peremrep = (u8:decode(text_buffer.v))
							if #peremrep >= 80 then
								text_buffer.v = u8'Мой ответ не вмещается в окно репорта, я отпишу вам лично'
								moiotvet = true
							end
						end
						moiotvet = 2
					else
						peremrep = (u8:decode(text_buffer.v))
						if #peremrep >= 80 then
							text_buffer.v = u8'Мой ответ не вмещается в окно репорта, я отпишу вам лично'
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
					peremrep = ('Уточните вашу жалобу/вопрос.')
					uto4 = 2
				end
			end
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
			tree_window_state.v = not tree_window_state.v
			imgui.Process = tree_window_state
		end)
	end
	if dialogId == 2350 then -- окно с возможностью принять или отклонить репорт
		tree_window_state.v = false
		if otklon == 2 then
			lua_thread.create(function()
				sampSendDialogResponse(dialogId, 1, 2, _)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				otklon = nil
			end)
		end
		if peredamrep or slejy or rabotay or ojid or internet or uto4 or uto4id or helpest or nakajy or jb or moiotvet or nakazan then
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end
	end
	if dialogId == 2351 then -- окно с ответом на репорт
		lua_thread.create(function()
			if peredamrep == 2 then
				sampSendDialogResponse(dialogId, 1, _, 'Передам ваш репорт.')
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
					if reportid and reportid ~= myid then
						peremrep = ('Начал(а) работу по вашей жалобе!')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						while sampIsDialogActive() do
							wait(0)
						end
						sampSendChat('/re ' .. reportid)
					elseif not sampIsPlayerConnected(reportid) and reportid ~= myid then
						peremrep = ('Указанный вами игрок под ' .. reportid .. ' ID находится вне сети.')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					elseif reportid == myid then
						peremrep = ('Вы указали мой ID :D')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					else 
						peremrep = ('Начал(а) работу по вашей жалобе!')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end
				else
					if reportid and reportid ~= myid then
						peremrep = ('Начал(а) работу по вашей жалобе!')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						while sampIsDialogActive() do
							wait(0)
						end
						sampSendChat('/re ' .. reportid)
					elseif not sampIsPlayerConnected(reportid) and reportid ~= myid then
						peremrep = ('Указанный вами игрок под ' .. reportid .. ' ID находится вне сети.')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					else 
						peremrep = ('Начал(а) работу по вашей жалобе!')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end
				end
			end
			if slejy == 2 then
				if cfg.settings.doptext then
					if reportid and reportid ~= myid then
						peremrep = ('Отправляюсь в слежку за игроком ' .. nickreportid .. '['..reportid..']')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						while sampIsDialogActive() do
							wait(0)
						end
						sampSendChat('/re ' .. reportid)
					elseif not sampIsPlayerConnected(reportid) and reportid ~= myid then
						peremrep = ('Указанный вами игрок под ' .. reportid .. ' ID находится вне сети.')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					elseif reportid == myid then
						peremrep = ('Вы указали мой ID :D')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					else 
						peremrep = ('Начинаю слежку.')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end
				else
					if reportid and reportid ~= myid then
						peremrep = ('Отправляюсь в слежку за игроком ' .. nickreportid .. '['..reportid..']')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						while sampIsDialogActive() do
							wait(0)
						end
						sampSendChat('/re ' .. reportid)
					elseif not sampIsPlayerConnected(reportid) and reportid ~= myid then
						peremrep = ('Указанный вами игрок под ' .. reportid .. ' ID находится вне сети.')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					elseif reportid == myid then
						peremrep = ('Вы указали мой ID :D')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					else 
						peremrep = ('Начинаю слежку.')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
					end
				end
			end
			if ojid or internet or uto4 or uto4id or helpest or jb or nakazan then
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
					sampSendChat('/rmute ' .. autorid .. ' 120 оффтоп в /report')
					oftop = false
				end
				if oskadm then
					sampSendChat('/rmute ' .. autorid .. ' 2500 Оскорбление администрации')
					oskadm = false
				end
				if oskrep then
					sampSendChat('/rmute ' .. autorid .. ' 400 Оскорбление')
					oskrep = false
				end
				if poprep then
					sampSendChat('/rmute ' .. autorid .. ' 120 Попрошайничество')
					poprep = false
				end
				if oskrod then
					sampSendChat('/rmute ' .. autorid .. ' 5000 Оскорбление/упоминание родни')
					oskrod = false
				end
				if capsrep then
					sampSendChat('/rmute ' .. autorid .. ' 120 Капс в /report')
					capsrep = false
				end
				if matrep then
					sampSendChat('/rmute ' .. autorid .. ' 300 Нецензурная лексика')
					matrep = false
				end
			end
			myid = nil
			rabotay = nil
			slejy = nil
			text_buffer.v = ''
			autor = nil
			reportid = nil
			textreport = nil
			ojid = nil
			internet = nil
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
function ev.onDisplayGameText(style, time, text) -- скрывает текст на экране.
    if text:find("REPORT++") then
        return false
    end
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
 ------------- KEYSYNC ----------------
function se.onPlayerSync(playerId, data)
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
function se.onVehicleSync(playerId, vehicleId, data)
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
				mimgui.Text(u8"Игрок не зафиксирован. Обновите рекон нажав клавишу R")
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

----======================= Исключительно для скрипта ===============------------------
sampRegisterChatCommand('wh' , function()
	if not cfg.settings.wallhack then
		cfg.settings.wallhack = true
		checked_test14 = imgui.ImBool(true)
		sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}WallHack включен', -1)
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
		sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}WallHack выключен', -1)
		inicfg.save(cfg,directIni)
		local pStSet = sampGetServerSettingsPtr();
		mem.setfloat(pStSet + 39, mem.getfloat(pStSet + 39))
		mem.setint8(pStSet + 47, mem.getint8(pStSet + 47))
		mem.setint8(pStSet + 56, mem.getint8(pStSet + 56))
		nameTag = false
	end
end)
sampRegisterChatCommand('mytextreport', function(param)
	if #param ~= 0  then 
		cfg.settings.mytextreport = param
		inicfg.save(cfg, directIni)
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Новый дополнительный текст после ответа в репорт - ' .. param, -1)
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('newprfma', function(param) 
	if #param ~= 0 then
		cfg.settings.prefixma = param
		sampAddChatMessage('Новый цвет префикса для младших администраторов: ' .. param, 0xCCCC33)
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('newprfa', function(param) 
	if #param ~= 0 then
		cfg.settings.prefixa = param
		sampAddChatMessage('Новый цвет префикса для администраторов: ' .. param, 0xCCCC33)
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('newprfsa', function(param) 
	if #param ~= 0 then
		cfg.settings.prefixsa = param
		sampAddChatMessage('Новый цвет префикса для старших администраторов: ' .. param, 0xCCCC33)
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
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
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end)

----======================= Исключительно вспомогательные ===============------------------
sampRegisterChatCommand('spp', function()
	local playerid_to_stream = playersToStreamZone()
	for _, v in pairs(playerid_to_stream) do
	sampSendChat('/aspawn ' .. v)
	end
end)
sampRegisterChatCommand('n', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Не вижу нарушений со стороны игрока.' .. doptext)
		else
			sampSendChat('/ans ' .. param .. ' Не вижу нарушений со стороны игрока.')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('c', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Начал(а) работу над вашей жалобой.' .. doptext)
		else
			sampSendChat('/ans ' .. param .. ' Начал(а) работу над вашей жалобой.')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('cl', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Данный игрок чист.' .. doptext)
		else
			sampSendChat('/ans ' .. param .. ' Данный игрок чист.' .. doptext)
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('nv', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Игрок не в сети' .. doptext)
		else
			sampSendChat('/ans ' .. param .. ' Игрок не в сети')
		end
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('prfma', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Мл.Администратор " .. cfg.settings.prefixma)
	end
end)
sampRegisterChatCommand('prfa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Администратор " .. cfg.settings.prefixa)
	end
end)
sampRegisterChatCommand('prfsa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Ст.Администратор " .. cfg.settings.prefixsa)
	end
end)
sampRegisterChatCommand('prfpga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Главный-Администратор " .. color())
	end
end)
sampRegisterChatCommand('prfzga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Зам.Глав.Администратора " .. color())
	end
end)
sampRegisterChatCommand('prfga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Главный-Администратор " .. color())
	end
end)
sampRegisterChatCommand('prfcpec', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Спец.Администратор " .. color())
	end
end)
sampRegisterChatCommand('stw', function(param) 
	if #param ~= 0 then
		sampSendChat("/setweap " .. param .. " 38 5000")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('uu', function(param) 
	if #param ~= 0 then
		sampSendChat('/unmute ' .. param) 
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('al', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. '  Здравствуйте! Вы забыли ввести /alogin!') 
		sampSendChat('/ans ' .. param .. ' Введите команду /alogin и свой пароль, пожалуйста.')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('as', function(param) 
	if #param ~= 0 then
		sampSendChat('/aspawn ' .. param)
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
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
        sampAddChatMessage('/banip [ник] [число] [причина]', -1)
    end
end)
----======================= Исключительно для МУТОВ ЧАТА ===============------------------
sampRegisterChatCommand('m', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 300 Нецензурная лексика')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('m2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 600 Нецензурная лексика x2')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('m3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 900 Нецензурная лексика x3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('ok', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 400 Оскорбление')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('ok2', function(param) 
	if #param ~= 0 then
 		sampSendChat('/mute ' .. param .. ' 800 Оскорбление x2')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('ok3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1200 Оскорбление x3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('fd', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 Флуд')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('fd2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 240 Флуд x2')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('fd3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 Флуд x3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('or', function(param) 
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 5000 Оскорбление/Упоминание родни')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('up', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1000 Упоминание сторонних проектов')
		sampSendChat('/cc')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('oa', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 2500 Оскорбление администрации')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('kl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 3000 Клевета на администрацию')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('po', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 Попрошайничество')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('po2', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 240 Попрошайничество x2')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('po3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 Попрошайничество x3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('zs', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 600 Злоупотребление символами")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('rekl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 1000 Реклама")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('rz', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 5000 Розжиг")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('ia', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 2500 Выдача себя за администратора")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
----======================= Исключительно для МУТОВ РЕПОРТА ===============------------------
sampRegisterChatCommand('oft', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('oft2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Offtop in /report x2")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('oft3', function(param) 
	if param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Offtop in /report x3")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('cp', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('cp2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Caps in /report x2")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('cp3', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Caps in /report x3")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('roa', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 2500 Оскорбление администрации")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('ror', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 Оскорбление/Упоминание Родни")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('rzs', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 600 Злоупотребление символами")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('rrz', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 Розжиг")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('rpo', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Попрошайничество")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('rm', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 300 Мат в /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('rok', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 400 Оскорбление в /report")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
----======================= Исключительно для ДЖАЙЛА ===============------------------
sampRegisterChatCommand('dz', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ДМ/ДБ в зеленой зоне')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('zv', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. " 3000 Злоупотребление VIP'ом")
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('sk', function(param)
	if #param ~= 0 then 
		sampSendChat('/jail ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('td', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 car in /trade')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('jcb', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 3000 читерский скрипт/ПО')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('jc', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 читерский скрипт/ПО')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('baguse', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 Багоюз')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
----======================= Исключительно для БАНА ===============------------------
sampRegisterChatCommand('bosk', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 7 Оскорбление проекта')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('reklama', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 7 Реклама')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('obm', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 7 Обман/Развод')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('ch', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 7 читерский скрипт/ПО')
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
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('neadekv', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 3 Неадекватное поведение')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('oskhelper', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 Нарушение правил /helper')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
----======================= Исключительно для КИКОВ ===============------------------
sampRegisterChatCommand('cafk', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' AFK in /arena') 
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('kk1', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' Смените ник 1/3') 
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('kk2', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' Смените ник 2/3')
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)
sampRegisterChatCommand('kk3', function(param)
	if #param ~= 0 then 
		sampSendChat('/ban ' .. param .. ' 7 Смените ник 3/3') 
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)


function style() -- СТИЛЬ ИМГУИ
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

sampRegisterChatCommand('sss', function(param)
	if #param ~= 0 then 
		sampAddChatMessage(get_loaded_scripts()) 
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Вы не указали значение.')
	end
end)



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




















---------- ДЛЯ ID В КИЛЛ ЧАТЕ ----------- (НИЖЕ БОЛЬШЕ НИЧЕГО НЕТ.)
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
