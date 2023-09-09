require 'lib.moonloader' --
require 'lib.sampfuncs' -- Êîä íàïèñàí íå ïðîôåññèîíàëîì, ÿ íå õî÷ó óãëóáëÿòüñÿ â îïòèìèçàöèþ, ïîêà íå áóäåò ïîòðåáíîñòè
script_name 'AdminTool'  -- Ïðîñüáà íè÷åãî â êîäå íå ìåíÿòü, åñëè ìåíÿåòå - òî íà ñâîé ñòðàõ è ðèñê, ìåíÿ äàæå íå ñïðàøèâàéòå.
script_version '2.0'
script_author 'Neon4ik' -- Åñòü ïîæåëàíèå - ïðåäëîæèòå ìíå â ëñ, íàøëè áàã? - òàêæå â ëñ. 
local function recode(u8) return encoding.UTF8:decode(u8) end -- äåøèôðîâêà ïðè àâòîîîáíîâëåíèè
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
local path_fastspawn = getWorkingDirectory() .. "\\resource\\FastSpawn.lua" -- ïîäãðóçêà ñêðèïòà äëÿ áûñòðîãî ñïàâíà
local path_trassera = getWorkingDirectory() .. "\\resource\\trassera.lua" -- ïîäãðóçêà ñêðèïòà äëÿ òðàññåðîâ
local mp = import "\\resource\\AdminToolsMP.lua" -- ïîäãðóçêà ïëàãèíà äëÿ ìåðîïðèÿòèé
local fonts = renderCreateFont('TimesNewRoman', 12, 5) -- òåêñò äëÿ àâòîôîðì
local tag = '{2B6CC4}Admin Tools: {F0E68C}'
local st = { -- òàéìåð äëÿ àâòîôîðì
    bool = false,
    timer = -1,
    id = -1,
}
local spisok = { -- ñïèñîê äëÿ àâòîôîðì
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

function sampev.onPlayerDeathNotification(killerId, killedId, reason) -------- Ïîäïèñü ID â êèëë ÷àòå
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
local cfg = inicfg.load({ -- áàçîâûå íàñòðîéêè ñêðèïòà
	settings = {
		style = 0,
		autoonline = false,
		inputhelper = true,
		prefixma = '2E8B57',
		prefixa = '87CEEB',
		prefixsa = 'FF4500',
		doptext = true,
		automute = true,
		mytextreport = ' // Ïðèÿòíîé èãðû íà RDS <3',
		customposx = false,
		customposy = false,
		keysync = true,
		ans = 'None',
		tr = 'None',
		wh = 'None',
		agm = 'None',
		rep = 'None',
		wallhack = true,
		ansreport = true,
		bloknotik = '',
		acon = true,
		chatposx = nil,
		chatposy = nil,
		size = 10,
		autosave = false,
		limit = 5,
		slejkaform = false,
		texts = 'Admin Tools: Ôîðìó ïðèíÿë.',
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

local style_selected = imgui.ImInt(cfg.settings.style) -- Áåð¸ì ñòàíäàðòíîå çíà÷åíèå ñòèëÿ èç êîíôèãà
local style_list = {u8"Òåìíî-Ñèíÿÿ òåìà", u8"Êðàñíàÿ òåìà", u8"Çåëåíàÿ òåìà", u8"Áèðþçîâàÿ òåìà", u8"Âèøíåâàÿ òåìà", u8"Ãîëóáàÿ òåìà"}

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
	["é"] = "q", ["ö"] = "w", ["ó"] = "e", ["ê"] = "r", ["å"] = "t", ["í"] = "y", ["ã"] = "u", ["ø"] = "i", ["ù"] = "o", ["ç"] = "p", ["õ"] = "[", ["ú"] = "]", ["ô"] = "a",
	["û"] = "s", ["â"] = "d", ["à"] = "f", ["ï"] = "g", ["ð"] = "h", ["î"] = "j", ["ë"] = "k", ["ä"] = "l", ["æ"] = ";", ["ý"] = "'", ["ÿ"] = "z", ["÷"] = "x", ["ñ"] = "c", ["ì"] = "v",
	["è"] = "b", ["ò"] = "n", ["ü"] = "m", ["á"] = ",", ["þ"] = ".", ["É"] = "Q", ["Ö"] = "W", ["Ó"] = "E", ["Ê"] = "R", ["Å"] = "T", ["Í"] = "Y", ["Ã"] = "U", ["Ø"] = "I",
	["Ù"] = "O", ["Ç"] = "P", ["Õ"] = "{", ["Ú"] = "}", ["Ô"] = "A", ["Û"] = "S", ["Â"] = "D", ["À"] = "F", ["Ï"] = "G", ["Ð"] = "H", ["Î"] = "J", ["Ë"] = "K", ["Ä"] = "L",
	["Æ"] = ":", ["Ý"] = "\"", ["ß"] = "Z", ["×"] = "X", ["Ñ"] = "C", ["Ì"] = "V", ["È"] = "B", ["Ò"] = "N", ["Ü"] = "M", ["Á"] = "<", ["Þ"] = ">"
}
local checked_test1 = imgui.ImBool(cfg.settings.automute)
local checked_test2 = imgui.ImBool(cfg.settings.keysync)
local checked_test3 = imgui.ImBool(cfg.settings.autoonline)
local checked_test4 = imgui.ImBool(cfg.settings.slejkaform)
local checked_test5 = imgui.ImBool(cfg.settings.autosave)
local checked_test7 = imgui.ImBool(cfg.settings.ansreport)
local checked_test8 = imgui.ImBool(cfg.settings.acon)
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
local newcommand = imgui.ImBuffer(256)
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
local mycommand_window_state = imgui.ImBool(false)
local dopcustomreport_window_state = imgui.ImBool(false)
function main() -- îñíîâíîé ñöåíàðèé ñêðèïòà
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
	font_watermark = renderCreateFont("Javanese Text", 9, font.BOLD + font.BORDER + font.SHADOW)
	lua_thread.create(function()
		while true do 
			renderFontDrawText(font_watermark, tag .. '{A9A9A9}version['.. thisScript().version..']', 10, sh-20, 0xCCFFFFFF)
			wait(0)
		end	
	end)
	if cfg.settings.fastspawn then
		fastspawn = import(path_fastspawn) -- ïîäãðóçêà ñêðèïòà ôàñòñïàâí
	end
	if cfg.settings.trassera then
		trassera = import(path_trassera) -- ïîäãðóçêà òðàññåðîâ
	end
	local enable_autoupdate = true
	autoupdate_loaded = false
	local Update = nil
	if enable_autoupdate then
		local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Îáíàðóæåíî îáíîâëåíèå. Ïûòàþñü îáíîâèòüñÿ c '..thisScript().version..' íà '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Çàãðóæåíî %d èç %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Çàãðóçêà îáíîâëåíèÿ çàâåðøåíà.')sampAddChatMessage(b..'Îáíîâëåíèå çàâåðøåíî!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Îáíîâëåíèå ïðîøëî íåóäà÷íî. Çàïóñêàþ óñòàðåâøóþ âåðñèþ..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Îáíîâëåíèå íå òðåáóåòñÿ.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Íå ìîãó ïðîâåðèòü îáíîâëåíèå. Îáíîâëåíèé íå íàéäåíî, ó âàñ àêòóàëüíàÿ âåðñèÿ, åñëè ýòî íå òàê, ñâÿæèòåñü ñ '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, âûõîäèì èç îæèäàíèÿ ïðîâåðêè îáíîâëåíèÿ. Îáíîâëåíèÿ íå îáíàðóæåíû, ó âàñ àêòóàëüíàÿ âåðñèÿ. Åñëè ýòî íå òàê - ñâÿæèòåñü '..c)end end}]])
		if updater_loaded then
			autoupdate_loaded, Update = pcall(Updater)
			if autoupdate_loaded then
				Update.json_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.json" .. tostring(os.clock())
				Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
				Update.url = "https:vk.com/alexandrkob"
			end
		end
	end
	sampRegisterChatCommand('update', function()
		if autoupdate_loaded and enable_autoupdate and Update then
			pcall(Update.check, Update.json_url, Update.prefix, Update.url)
		end
	end)
	imgui.Process = false
	inputHelpText = renderCreateFont("Arial", 9, FCR_BORDER + FCR_BOLD) -- øðèôò èíïóò õåëïåðà
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
						sampSendChat('/ans ' .. cheater .. ' Óâàæàåìûé ' .. sampGetPlayerNickname(cheater) .. ', Âû íàðóøàëè ïðàâèëà ñåðâåðà.')
						sampSendChat('/ans ' .. cheater .. ' Åñëè Âû íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà https://forumrds.ru')
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
						sampSendChat('/ans ' .. cheater .. ' Óâàæàåìûé ' .. sampGetPlayerNickname(cheater) .. ', Âû íàðóøàëè ïðàâèëà ñåðâåðà.')
						sampSendChat('/ans ' .. cheater .. ' Åñëè Âû íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà https://forumrds.ru')
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
				sampAddChatMessage('{FF0000}AForm: {FAEBD7}ôîðìà îòêëîíåíà')
			end
		end
		if isKeyJustPressed(VK_F3) and not sampIsDialogActive() then  -- êíîïêà àêòèâàöèè îêíà
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
			sampSendInputChat('/wh')
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.agm)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not main_window_state.v then
			sampSendChat('/agm ')
		end
		if isKeyJustPressed(strToIdKeys(cfg.settings.rep)) and not isKeyJustPressed(VK_RBUTTON)  and not sampIsChatInputActive() and not sampIsDialogActive() and not main_window_state.v then
			sampSendChat('/a /ANS /ANS /ANS /ANS /ANS /ANS ANS /ANS /ANS')
		end
	end
end
function sampSendInputChat(text) -- îòïðàâêà â ÷àò ÷åðåç ô6
	sampSetChatInputText(text)
	sampSetChatInputEnabled(true)
	setVirtualKeyDown(13, true)
	setVirtualKeyDown(13, false)
end

function ao() -- àâòîîíëàéí
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

---------------===================== Îïðåäåëåíåíèå ID íàæàòîé êëàâèøè
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
---------------===================== Îïðåäåëåíåíèå ID íàæàòîé êëàâèøè
function color() -- ðàíäîì ïðåôèêñ
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
function imgui.CenterText(text) -- öåíòðèðîâàíèå òåêñòà
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 ) 			
    imgui.Text(text)
end
function imgui.Link(label, description) -- ãèïåðññûëêà
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
local w = { -- çàäàåì øèðèíó äëÿ ôëóäåðà
    second = 150,
}
local menu = {true, -- ðåêîí ìåíþ
    false,
}
local menu2 = {true, -- ðåêîí ìåíþ
    false,
	false,
	false,
	false,
	false,
	false,
}

function imgui.OnDrawFrame()
	if not main_window_state.v and not tree_window_state.v and not four_window_state.v and not fourtwo_window_state.v and not five_window_state.v and not ac_window_state.v and not ansreport_window_state.v and not ansreport_window_state.v and not dopcustomreport_window_state.v then
		imgui.Process = false
		sampSendInputChat('/keysync off')
		showCursor(false,false)
	end
	if main_window_state.v then -- ÊÍÎÏÊÈ ÈÍÒÅÐÔÅÉÑÀ F3
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), (sh / 2)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(315, 355), imgui.Cond.FirstUseEver)
		imgui.Begin('xX   ' .. " Admin Tools " .. '  Xx', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
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
			if imgui.IsWindowAppearing() then
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.SetCursorPosX(10)
			if imgui.Checkbox(u8'Âèðò.êëàâèøè', checked_test2) then
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
			if imgui.Checkbox(u8"input helper", checked_test13) then
				cfg.settings.inputhelper = not cfg.settings.inputhelper
				inicfg.save(cfg,directIni)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"WallHack", checked_test14) then
				if cfg.settings.wallhack == true then
					sampSendInputChat('/wh ')
				else
					sampSendInputChat('/wh ')
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
			if imgui.Checkbox(u8'Ñëåæêà çà ôîðìàìè', checked_test4) then
				cfg.settings.slejkaform  = not cfg.settings.slejkaform
				inicfg.save(cfg,directIni)
			end
			if imgui.Checkbox(u8'Àâòîìóò', checked_test1) then
				cfg.settings.automute  = not cfg.settings.automute
				inicfg.save(cfg,directIni)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(160)
			if imgui.Checkbox(u8"Óâåäîìë. èãðîêà", checked_test7) then
				cfg.settings.ansreport = not cfg.settings.ansreport
				inicfg.save(cfg,directIni)
			end
			if autoupdate_loaded then
				if imgui.Button(u8'Îáíîâèòü ñêðèïò', imgui.ImVec2(300, 24)) then
					sampSendInputChat('/update')
					sampAddChatMessage(tag .. 'Îáíîâëåíèå çàãðóæàåòñÿ, îæèäàéòå.', -1)
				end
			end
			if imgui.Button(u8'Îòêðûòü íàñòðîéêè ñïàâíà', imgui.ImVec2(300, 24)) then
				sampSendInputChat('/fs')
			end
			if imgui.Button(u8'Îòêðûòü íàñòðîéêè òðàññåðîâ', imgui.ImVec2(300, 24)) then
				sampSendInputChat('/trassera')
			end
			imgui.Separator()
			imgui.Text(u8'Ðàçðàáîò÷èê ñêðèïòà - N.E.O.N [RDS 01]\nÎáðàòíàÿ ñâÿçü óêàçàíà íèæå\n')
			if imgui.Link("https://vk.com/alexandrkob", u8"Íàæìè, ÷òîáû îòêðûòü ññûëêó â áðàóçåðå") then
				os.execute(('explorer.exe "%s"'):format("https://vk.com/alexandrkob"))
			end
		end
		if menu2[3] then
			imgui.SetCursorPosX(10)
			imgui.Text(u8'Ìë.Àäìèíèñòðàòîð')
			imgui.SameLine()
			imgui.SetCursorPosX(150)
			imgui.PushItemWidth(100)
			if imgui.InputText('   ', PrefixMa) then
				cfg.settings.prefixma = PrefixMa.v
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.SetCursorPosX(10)
			imgui.Text(u8'Àäìèíèñòðàòîð')
			imgui.SameLine()
			imgui.SetCursorPosX(150)
			imgui.PushItemWidth(100)
			if imgui.InputText(' ', PrefixA) then
				cfg.settings.prefixa = PrefixA.v
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.SetCursorPosX(10)
			imgui.Text(u8'Ñò.Àäìèíèñòðàòîð')
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
			imgui.CenterText(u8'Äîïîëíèòåëüíûé òåêñò êîìàíä')
			imgui.PushItemWidth(300)
			if imgui.InputText('', doptexts) then
				cfg.settings.mytextreport = u8:decode(doptexts.v)
				inicfg.save(cfg,directIni)	
			end
			imgui.PopItemWidth()
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'Ñîõðàíèòü ïîçèöèþ Recon Menu', imgui.ImVec2(300, 24)) then
				if four_window_state.v then
					four_window_state.v = not four_window_state.v
					fourtwo_window_state.v = not fourtwo_window_state.v
				else
					sampAddChatMessage(tag .. 'Çàéäèòå â ñëåæêó âî èçáåæàíèÿ ðàññèõðîíà', -1)
				end
			end
			imgui.SetCursorPosX(10)
			if cfg.settings.acon then
				if imgui.Button(u8'Ñîõðàíèòü ïîçèöèþ àäìèí-÷àòà', imgui.ImVec2(300, 24)) then
					ac_window_state.v = not ac_window_state.v
				end
			end
			imgui.SetCursorPosX(10)
			if cfg.settings.keysync then
				if imgui.Button(u8'Ñîõðàíèòü ïîçèöèþ âèðò.êëàâèø', imgui.ImVec2(300, 23)) then
					five_window_state.v = not five_window_state.v 
				end
			end
			imgui.SetCursorPosX(10)
			if imgui.Button(u8'Âûãðóçèòü ñêðèïò ' .. fa.ICON_POWER_OFF, imgui.ImVec2(300, 23)) then
				lua_thread.create(function()
					main_window_state.v = false
					if cfg.settings.wallhack then
						sampSendInputChat('/wh ')
					end
					wait(100)
					sampSendInputChat('/trasoff ')
					wait(100)
					sampSendInputChat('/fsoff ')
					imgui.Process = false
					imgui.showCursor(false,false)
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
			imgui.CenterText(u8'Îòêðûòèå ðåïîðòà:')
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.ans))
			if imgui.Button(u8"Ñoxðaíèòü.", imgui.ImVec2(300, 24)) then
				cfg.settings.ans = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8'Âêë/âûêë áûñòðîãî ðåïîðòà')
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.tr))
			if imgui.Button(u8"Ñîxðaíèòü.", imgui.ImVec2(300, 24)) then
				cfg.settings.tr = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8"Âêë/âûêë WallHack: ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.wh))
			if imgui.Button(u8"Cîxðaíèòü.", imgui.ImVec2(300, 24)) then
				cfg.settings.wh = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8"Âêë/âûêë áåññìåðòèÿ: ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.agm))
			if imgui.Button(u8"Coxðaíèòü.", imgui.ImVec2(300, 24)) then
				cfg.settings.agm = getDownKeysText()
				inicfg.save(cfg,directIni)
			end
			imgui.CenterText(u8"Íàïîìèíàíèå î ðåïîðòå: ")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.rep))
			if imgui.Button(u8"Ñîxpaíèòü.", imgui.ImVec2(300, 24)) then
				cfg.settings.rep = getDownKeysText()
				inicfg.save(cfg,directIni)
				sampShowDialog(1000, "Âíèìàíèå!", "Äàííàÿ ôóíêöèÿ ïðåäíàçíà÷åíà äëÿ òîãî, ÷òîáû îòïðàâëÿòü /a /ANS /ANS /ANS /ANS /ANS\nÍå íàäî áàëîâàòüñÿ äàííîé ôóíêöèåé.", "Ïîíÿë", _)
			end
			imgui.Separator()
			if imgui.Button(u8"Ñáðîñèòü âñå çíà÷åíèÿ.", imgui.ImVec2(300, 24)) then
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
				imgui.Text(u8'      Ôëóäû îá /gw')
				if imgui.Button(u8'Aztecas vs Ballas', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 Íà äàííûé ìîìåíò ïðîõîäèò âîîðóæåííîå ñðàæåíèå äâóõ âðàæäåáíûõ ãðóïïèðîâîê.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Ballas Gang ##')
					sampSendChat('/mess 14 Ïîìîãè áðàòüÿì îòñòîÿòü ñâîþ òåððèòîðèþ è çàùèòèòü ÷åñòü áàíäû, ââîäè /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Aztecas vs Grove', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 Íà äàííûé ìîìåíò ïðîõîäèò âîîðóæåííîå ñðàæåíèå äâóõ âðàæäåáíûõ ãðóïïèðîâîê.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Grove Street Gang ##')
					sampSendChat('/mess 14 Ïîìîãè áðàòüÿì îòñòîÿòü ñâîþ òåððèòîðèþ è çàùèòèòü ÷åñòü áàíäû, ââîäè /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Aztecas vs Vagos', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 Íà äàííûé ìîìåíò ïðîõîäèò âîîðóæåííîå ñðàæåíèå äâóõ âðàæäåáíûõ ãðóïïèðîâîê.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Vagos Gang ##')
					sampSendChat('/mess 14 Ïîìîãè áðàòüÿì îòñòîÿòü ñâîþ òåððèòîðèþ è çàùèòèòü ÷åñòü áàíäû, ââîäè /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Aztecas vs Rifa', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 Íà äàííûé ìîìåíò ïðîõîäèò âîîðóæåííîå ñðàæåíèå äâóõ âðàæäåáíûõ ãðóïïèðîâîê.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs The Rifa ##')
					sampSendChat('/mess 14 Ïîìîãè áðàòüÿì îòñòîÿòü ñâîþ òåððèòîðèþ è çàùèòèòü ÷åñòü áàíäû, ââîäè /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Ballas vs Grove', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 Íà äàííûé ìîìåíò ïðîõîäèò âîîðóæåííîå ñðàæåíèå äâóõ âðàæäåáíûõ ãðóïïèðîâîê.')
					sampSendChat('/mess 14 ## Ballas Gang vs Grove Street Gang ##')
					sampSendChat('/mess 14 Ïîìîãè áðàòüÿì îòñòîÿòü ñâîþ òåððèòîðèþ è çàùèòèòü ÷åñòü áàíäû, ââîäè /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Ballas vs Vagos', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 Íà äàííûé ìîìåíò ïðîõîäèò âîîðóæåííîå ñðàæåíèå äâóõ âðàæäåáíûõ ãðóïïèðîâîê.')
					sampSendChat('/mess 14 ## Ballas Gang vs Vagos Gang ##')
					sampSendChat('/mess 14 Ïîìîãè áðàòüÿì îòñòîÿòü ñâîþ òåððèòîðèþ è çàùèòèòü ÷åñòü áàíäû, ââîäè /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Ballas vs Rifa', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 Íà äàííûé ìîìåíò ïðîõîäèò âîîðóæåííîå ñðàæåíèå äâóõ âðàæäåáíûõ ãðóïïèðîâîê.')
					sampSendChat('/mess 14 ## Ballas Gang vs The Rifa ##')
					sampSendChat('/mess 14 Ïîìîãè áðàòüÿì îòñòîÿòü ñâîþ òåððèòîðèþ è çàùèòèòü ÷åñòü áàíäû, ââîäè /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Grove vs Vagos', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 Íà äàííûé ìîìåíò ïðîõîäèò âîîðóæåííîå ñðàæåíèå äâóõ âðàæäåáíûõ ãðóïïèðîâîê.')
					sampSendChat('/mess 14 ## Grove Street Gang vs Vagos Gang ##')
					sampSendChat('/mess 14 Ïîìîãè áðàòüÿì îòñòîÿòü ñâîþ òåððèòîðèþ è çàùèòèòü ÷åñòü áàíäû, ââîäè /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				if imgui.Button(u8'Vagos vs Rifa', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
					sampSendChat('/mess 14 Íà äàííûé ìîìåíò ïðîõîäèò âîîðóæåííîå ñðàæåíèå äâóõ âðàæäåáíûõ ãðóïïèðîâîê.')
					sampSendChat('/mess 14 ## Vagos Gang vs The Rifa ##')
					sampSendChat('/mess 14 Ïîìîãè áðàòüÿì îòñòîÿòü ñâîþ òåððèòîðèþ è çàùèòèòü ÷åñòü áàíäû, ââîäè /gw!')
					sampSendChat('/mess 11 --------=================== GangWar ================-----------')
				end
				imgui.Text(u8'Â ðàçðàáîòêå.')
				imgui.NextColumn()
				imgui.SetColumnWidth(-1, w.second)
				imgui.Text(u8'       Îáùèå ôëóäû')
				if imgui.Button(u8'Ñïàâí àâòî', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 10 --------=================== Spawn Auto ================-----------')
					sampSendChat('/mess 15 Ìíîãîóâàæàåìûå äðèôòåðû è äðèôòåðøè')
					sampSendChat('/mess 15 ×åðåç 15 ñåêóíä ïðîéä¸ò ðåñïàâí âñåãî òðàíñïîðòà íà ñåðâåðå.')
					sampSendChat('/mess 15 Çàéìèòå ñâîè ñóïåð êàðû âî èçáåæàíèÿ ïîòåðè :3')
					sampSendChat('/mess 10 --------=================== Spawn Auto ================-----------')
					sampSendChat('/delcarall')
					sampSendChat('/spawncars 15')
				end
				if imgui.Button(u8'/trade', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 3 -----========================= Ðûíîê =====================-------')
					sampSendChat('/mess 0 Ìå÷òàë ïðèîáðåñòè àêêñåññóàðû íà ñâîé ñêèí?')
					sampSendChat('/mess 0 Áåãàòü ñ ðó÷íûì ïîïóãàé÷èêîì íà ïëå÷å è ñâåòèòñÿ êàê áîæåíüêà?')
					sampSendChat('/mess 0 Ñêîðåé ââîäè /trade, áîëüøîé âûáîð àññîðòèìåíòà, êàê îò ñåðâåðà, òàê è îò èãðîêîâ!')
					sampSendChat('/mess 3 -----========================= Ðûíîê =====================-------')
				end
				if imgui.Button(u8'Àâòîìàñòåðñêàÿ', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 16 --------=================== Àâòîìàñòåðñêàÿ ================-----------')
					sampSendChat('/mess 17 Âñåãäà ìå÷òàë ïðèîáðåñòè êîâø íà ñâîé êèáåðòðàê? Íå ïðîáëåìà!')
					sampSendChat('/mess 17 Â àâòîìàñòåðñêèõ èç /tp - ðàçíîå - àâòîìàñòåðñêèå íàéäåòñÿ è íå òàêîå.')
					sampSendChat('/mess 17 Ñäåëàé àïãðåéä ñâîåãî ëþáèì÷èêà ïîä ñâîé âêóñ è öâåò')
					sampSendChat('/mess 16 --------=================== Àâòîìàñòåðñêàÿ ================-----------')
				end
				if imgui.Button(u8'Ãðóïïà/Ôîðóì', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 -------============= Ñòîðîííèå ïëîùàäêè ==========-----------------')
					sampSendChat('/mess 7 Ó íàøåãî ïðîåêòà èìååòñÿ ãðóïïà vk.ñom/teamadmrds ...')
					sampSendChat('/mess 7 ... è äàæå ôîðóì, íà êîòîðîì èãðîêè ìîãóò îñòàâèòü æàëîáó íà àäìèíèñòðàöèþ èëè èãðîêîâ.')
					sampSendChat('/mess 7 Ñëåäè çà íîâîñòÿìè è áóäü âêóðñå ñîáûòèé.')
					sampSendChat('/mess 11 -------============= Àâòîìîáèëü ==========-----------------')
				end
				if imgui.Button(u8'VIP', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 13 --------============ Ïðåèìóùåñòâà VIP ===========------------------')
					sampSendChat('/mess 7 Õî÷åøü èãðàòü ñ äðóçüÿìè áåç äèñêîìôîðòà?')
					sampSendChat('/mess 7 Õî÷åøü âñåãäà òåëåïîðòèðîâàòüñÿ ïî êàðòå è ê äðóçüÿì, ÷òîáû áûòü âñåãäà âìåñòå?')
					sampSendChat('/mess 7 Õî÷åøü ïîëó÷àòü êàæäûé PayDay ïëþøêè íà ñâîé àêêàóíò? Îáçàâåäèñü VIP-ñòàòóñîì!')
					sampSendChat('/mess 13 --------============ Ïðåèìóùåñòâà VIP ===========------------------')
				end
				if imgui.Button(u8'Àðåíå', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 12 -------============= PVP Arena ==========-----------------')
					sampSendChat('/mess 10 Íå çíàåøü ÷åì çàíÿòüñÿ? Õî÷åòñÿ ýêøåíà è áûñòðîé ðåàêöèè?')
					sampSendChat('/mess 10 Ââîäè /arena è ïîêàæè íà ÷òî òû ñïîñîáåí!')
					sampSendChat('/mess 10 Íàáåé ìàêñèìàëüíîå êîëè÷åñòâî êèëëîâ, äîáåéñÿ èäåàëà â ñâîåì +C')
					sampSendChat('/mess 12 -------============= PVP Arena ==========-----------------')
				end
				if imgui.Button(u8'Âèðòóàëüíûé ìèð', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------============ Òâîé âèðòóàëüíûé ìèð ===========------------------')
					sampSendChat('/mess 15 Ìåøàþò èãðàòü? Ïîñòîÿííî ïðåñëåäóþò òàíêè è ñàìîë¸òû?')
					sampSendChat('/mess 15 Îáû÷íûé ïàññèâ ðåæèì íå ñïàñàåò âî âðåìÿ äðèôòà?')
					sampSendChat('/mess 15 Âûõîä åñòü! Ââîäè /dt [0-999] è äðèôòè ñ êîìôîðòîì.')
					sampSendChat('/mess 8 --------============ Òâîé âèðòóàëüíûé ìèð ===========------------------')
				end
				if imgui.Button(u8'Ïîêóïêà àâòîìîáèëÿ', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 3 -------============= Àâòîìîáèëü ==========-----------------')
					sampSendChat('/mess 2 Ìå÷òàë ïðèîáðåñòè ñóïåðêàð? Ìå÷òàë ñäåëàòü øèêàðíûé òþíèíã ïîä ñåáÿ?')
					sampSendChat('/mess 2 Âñ¸ ýòî âîçìîæíî! Èñïîëüçóé /tp - ðàçíîå - àâòîñàëîíû è ïîêóïàé íóæíîå àâòî.')
					sampSendChat('/mess 2 Â àâòîñàëîíå íåò íóæíîãî àâòî? Äîãîâîðèñü ñ èãðîêîì, ëèáî òåëåïîðòèðóéñÿ íà /autoyartp')
					sampSendChat('/mess 3 -------============= Àâòîìîáèëü ==========-----------------')
				end
				if imgui.Button(u8'Î /report', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 17 --------========== Ñâÿçü ñ àäìèíèñòðàöèåé ==========----------')
					sampSendChat('/mess 13 Íàøåë ÷èòåðà, çëîñòíîãî íàðóøèòåëÿ, ÄÌåðà, èëè ïðîñòî ìåøàþò èãðàòü?')
					sampSendChat('/mess 13 Ïîÿâèëñÿ âîïðîñ î âîçìîæíîñòÿõ ñåðâåðà èëè åãî íüàíñàõ?')
					sampSendChat('/mess 13 Àäìèíèñòðàöèÿ ïîìîæåò! Ïèøè /report è ñâîþ æàëîáó/âîïðîñ')
					sampSendChat('/mess 17 --------========== Ñâÿçü ñ àäìèíèñòðàöèåé ==========----------')
				end
				imgui.Separator()
				imgui.Text(u8'Ìåðîïðèÿòèÿ /join')
				if imgui.Button(u8'Äåðáè', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå Äåðáè ================-----------')
					sampSendChat('/mess 0 Íà äàííûé ìîìåíò ïðîõîäèò ñáîð èãðîêîâ íà ìåðîïðèÿòèå Äåðáè')
					sampSendChat('/mess 0 ×òîáû ïðèíÿòü ó÷àñòèå ââîäè /join - 1')
					sampSendChat('/mess 0 Ïîòîðîïèñü! Êîëè÷åñòâî ìåñò îãðàíè÷åíî.')
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå Äåðáè ================-----------')
				end
				if imgui.Button(u8'Ïàðêóð', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå /parkour ================-----------')
					sampSendChat('/mess 0 Íà äàííûé ìîìåíò ïðîõîäèò ñáîð èãðîêîâ íà ìåðîïðèÿòèå Ïàðêóð')
					sampSendChat('/mess 0 ×òîáû ïðèíÿòü ó÷àñòèå ââîäè /parkour ëèáî /join - 2')
					sampSendChat('/mess 0 Ïîòîðîïèñü! Êîëè÷åñòâî ìåñò îãðàíè÷åíî.')
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå /parkour ================-----------')
				end
				if imgui.Button(u8'PUBG', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå /pubg ================-----------')
					sampSendChat('/mess 0 Íà äàííûé ìîìåíò ïðîõîäèò ñáîð èãðîêîâ íà ìåðîïðèÿòèå Pubg')
					sampSendChat('/mess 0 ×òîáû ïðèíÿòü ó÷àñòèå ââîäè /pubg ëèáî /join - 3')
					sampSendChat('/mess 0 Ïîòîðîïèñü! Êîëè÷åñòâî ìåñò îãðàíè÷åíî.')
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå /pubg ================-----------')
				end
				if imgui.Button(u8'DAMAGE DEATHMATCH', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå /damagegm ================-----------')
					sampSendChat('/mess 0 Íà äàííûé ìîìåíò ïðîõîäèò ñáîð èãðîêîâ íà ìåðîïðèÿòèå DAMAGE DEATHMATCH')
					sampSendChat('/mess 0 ×òîáû ïðèíÿòü ó÷àñòèå ââîäè /damagegm ëèáî /join - 4')
					sampSendChat('/mess 0 Ïîòîðîïèñü! Êîëè÷åñòâî ìåñò îãðàíè÷åíî.')
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå /damagegm ================-----------')
				end
				if imgui.Button(u8'KILL DEATHMATCH', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå KILL DEATHMATCH ================-----------')
					sampSendChat('/mess 0 Íà äàííûé ìîìåíò ïðîõîäèò ñáîð èãðîêîâ íà ìåðîïðèÿòèå DAMAGE DEATHMATCH')
					sampSendChat('/mess 0 ×òîáû ïðèíÿòü ó÷àñòèå ââîäè /join - 5')
					sampSendChat('/mess 0 Ïîòîðîïèñü! Êîëè÷åñòâî ìåñò îãðàíè÷åíî.')
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå KILL DEATHMATCH ================-----------')
				end
				if imgui.Button(u8'Paint Ball', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå Paint Ball ================-----------')
					sampSendChat('/mess 0 Íà äàííûé ìîìåíò ïðîõîäèò ñáîð èãðîêîâ íà ìåðîïðèÿòèå Paint Ball')
					sampSendChat('/mess 0 ×òîáû ïðèíÿòü ó÷àñòèå ââîäè /join - 7')
					sampSendChat('/mess 0 Ïîòîðîïèñü! Êîëè÷åñòâî ìåñò îãðàíè÷åíî.')
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå Paint Ball ================-----------')
				end
				if imgui.Button(u8'Çîìáè vs Ëþäåé', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== Çîìáè ïðîòèâ ëþäåé ================-----------')
					sampSendChat('/mess 0 Íà äàííûé ìîìåíò ïðîõîäèò ñáîð èãðîêîâ íà ìåðîïðèÿòèå Çîìáè ïðîòèâ ëþäåé')
					sampSendChat('/mess 0 ×òîáû ïðèíÿòü ó÷àñòèå ââîäè /join - 8')
					sampSendChat('/mess 0 Ïîòîðîïèñü! Êîëè÷åñòâî ìåñò îãðàíè÷åíî.')
					sampSendChat('/mess 8 --------=================== Çîìáè ïðîòèâ ëþäåé ================-----------')
				end
				if imgui.Button(u8'Ïðÿòêè', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå Ïðÿòêè ================-----------')
					sampSendChat('/mess 0 Íà äàííûé ìîìåíò ïðîõîäèò ñáîð èãðîêîâ íà ìåðîïðèÿòèå Ïðÿòêè')
					sampSendChat('/mess 0 ×òîáû ïðèíÿòü ó÷àñòèå ââîäè /join - 10')
					sampSendChat('/mess 0 Ïîòîðîïèñü! Êîëè÷åñòâî ìåñò îãðàíè÷åíî.')
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå Ïðÿòêè ================-----------')
				end
				if imgui.Button(u8'Äîãîíÿëêè', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå Äîãîíÿëêè ================-----------')
					sampSendChat('/mess 0 Íà äàííûé ìîìåíò ïðîõîäèò ñáîð èãðîêîâ íà ìåðîïðèÿòèå Äîãîíÿëêè')
					sampSendChat('/mess 0 ×òîáû ïðèíÿòü ó÷àñòèå ââîäè /join - 11')
					sampSendChat('/mess 0 Ïîòîðîïèñü! Êîëè÷åñòâî ìåñò îãðàíè÷åíî.')
					sampSendChat('/mess 8 --------=================== Ìåðîïðèÿòèå Äîãîíÿëêè ================-----------')
				end
		end
		imgui.PopFont()
		if menu2[2] then
			imgui.SetCursorPosX(10)
			imgui.PushItemWidth(300)
			if imgui.Button(u8'Äîáàâèòü ñâîé îòâåò', imgui.ImVec2(300, 24)) and #customotv.v~=0 then
				key = #cfg.customotvet + 1
				cfg.customotvet[key] = u8:decode(customotv.v)
				inicfg.save(cfg,directIni)
			end
			imgui.InputText('.', customotv)
			imgui.PopItemWidth()
			imgui.Separator()
			imgui.CenterText(u8'Ñîõðàíåííûå îòâåòû')
			for k,v in pairs(cfg.customotvet) do
				if imgui.Button(u8(v), imgui.ImVec2(300, 24)) then
					cfg.customotvet[k] = nil
					cfg.customotvet[v] = nil
					inicfg.save(cfg,directIni)
				end
			end
		end
		if menu2[6] then
			imgui.CenterText(u8'Ñêðèïò')
			imgui.Text(u8'/tool - îòêðûòü ìåíþ ñêðèïòà\n/wh - âêë/âûêë ôóíêöèþ WallHack\n/add_mat - äîáàâèòü ìàò\n/add_osk - äîáàâèòü îñêîðáëåíèå\n/del_mat - óäàëèòü ìàò\n/del_osk - óäàëèòü îñêîðáëåíèå\n/textform - ïîñòàâèòü ñâîé òåêñò ïîñëå îäîáðåíèÿ ôîðìû\n/stylecolor - ïîñòàâèòü ñâîé öâåò îïîâåù.\n/stylecolorform - ïîñòàâèòü ñâîé òåêñò ôîðìû.')
			imgui.Separator()
			imgui.CenterText(u8'Âñïîìîãàòåëüíûå êîìàíäû')
			imgui.Text(u8'/n - Íå âèæó íàðóøåíèé îò èãðîêà\n/nak - èãðîê íàêàçàí\n/afk - èãðîê íàõîäèòñÿ â àôê èëè áåçäåéñòâóåò\n/pv - Ïîìîãëè âàì\n/dpr - äîíàò ïðåèìóùåñòâà\n/rep - ñîîáùèòü èãðîêó î íàëè÷èè êîìàíäû /report\n/c - íà÷àë(à) ðàáîòó íàä âàøåé æàëîáîé\n/cl - äàííûé èãðîê ÷èñò\n/uj - ñíÿòü äæàéë\n/nv - Èãðîê íå â ñåòè\n/prfma - âûäàòü ïðåôèêñà Ìë.Àäìèíó\n/prfa - Âûäàòü ïðåôèêñ Àäìèíó\n/prfsa - âûäàòü ïðåôèêñ Ñò.Àäìèíó\n/prfpga - âûäàòü ïðåôèêñ ÏÃÀ\n/prfzga - âûäàòü ïðåôèêñ ÇÃÀ\n/prfga - âûäàòü ïðåôèêñ ÃÀ\n/prfcpec - Âûäàòü ïðåôèêñ Ñïåöó\n/stw - âûäàòü ìèíèãàí\n/uu - êðàòêàÿ êîìàíäà ñíÿòèÿ ìóòà\n/al - Íàïîìíèòü àäìèíèñòðàòîðó ïðî /alogin\n/as - çàñïàâíèòü èãðîêà\n/spp - çàñïàâíèòü âñåõ â ðàäèóñå\n/sbanip - áàí èãðîêà îôô ïî íèêó ñ IP (ÔÄ!)')
			imgui.Separator()
			imgui.CenterText(u8'Âûäàòü ìóò ÷àòà')
			imgui.Text(u8'/m - /m3 ìàò\n/ok - /ok3 îñêîðáëåíèå\n/fd - /fd3 ôëóä\n/or - îñê/óïîì ðîäíûõ\n/up - óïîìèíàíèå ïðîåêòà ñ î÷èñòêîé ÷àòà\n/oa - îñêîðáëåíèå àäìèíèñòðàöèè\n/kl - êëåâåòà íà àäìèíèñòðàöèþ\n/po - /po3 - ïîïðîøàéíè÷åñòâî\n/rekl - ðåêëàìà\n/zs - çëîóïîòðåáëåíèå ñèìâîëàìè\n/rz - ðîçæèã\n/ia - âûäà÷à ñåáÿ çà àäìèíèñòðàöèþ')
			imgui.Separator()
			imgui.CenterText(u8'Âûäàòü ìóò ðåïîðòà')
			imgui.Text(u8'/oft - /oft3 îôôòîï\n/cp - /cp3 êàïñ\n/roa - îñêîðáëåíèå àäìèíèñòðàöèè\n/ror - îñê/óïîì ðîä\n/rzs - çëîóïîòðåáëåíèå ñèìâîëàìè\n/rrz - ðîçæèã\n/rpo - ïîïðîøàéíè÷åñòâî\n/rm - ìàò\n/rok - îñêîðáëåíèå')
			imgui.Separator()
			imgui.CenterText(u8'Ïîñàäèòü â òþðüìó')
			imgui.Text(u8'/dz - ÄÌ/ÄÁ â çåëåíîé çîíå\n/zv - Çëîóïîòðåáëåíèå VIP ñòàòóñîì\n/sk - Ñïàâí-Êèëë\n/dmp - ñåðüåçíàÿ ïîìåõà íà ìåðîïðèÿòèè\n/td - Car in /trade\n/jm - íàðóøåíèå ïðàâèë ìï\n/jcb - âðåäèòåëüñêèå ÷èòû(âìåñòî áàíà)\n/jc - áåçâðåäíûå ÷èòû\n/baguse - áàãîþç\n/dk - ÄÁ Êîâø â çåëåíîé çîíå')
			imgui.Separator()
			imgui.CenterText(u8'Êèêíóòü èãðîêà')
			imgui.Text(u8'/cafk - Àôê íà àðåíå\n/kk1 - Ñìåíèòå íèê 1/3\n/kk2 - Ñìåíèòå íèê 2/3\n/kk3 - Ñìåíèòå íèê 3/3 (áàí)')
			imgui.Separator()
			imgui.CenterText(u8'Áëîêèðîâêà àêêàóíòà')
			imgui.Text(u8'/ch - ÷èòû\n/bosk - îñêîðáëåíèå ïðîåêòà\n/obm - Îáìàí/ðàçâîä\n/neadekv - Íåàäåêâàòíîå ïîâåäåíèå(3 äíÿ)\n/oskhelper - Íàðóøåíèå ïðàâèë õåëïåðà\n/reklama - ðåêëàìà')
			imgui.Separator()
			imgui.Text(u8'Âûäà÷à íàêàçàíèÿ â îôôëàéíå - /okf /mf /dzf')
		end
		if menu2[8] then
			imgui.PushFont(fontsize)
			imgui.CenterText(u8'Âûáåðèòå òåìó îôîðìëåíèÿ')
			imgui.PushItemWidth(300)
			if imgui.Combo(u8"", style_selected, style_list, style_selected) then
				style(style_selected.v) -- Ïðèìåíÿåì ñðàçó æå âûáðàííûé ñòèëü
				cfg.settings.style = style_selected.v 
				inicfg.save(cfg, directIni) 
			end
			imgui.PopItemWidth()
			imgui.PopFont()
		end
 		imgui.End()
	end
	if ac_window_state.v then -- ñîõðàíåíèå ïîçèöèè àäìèí ÷àòà
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Àäìèí-÷àò', ac_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'Ñîõðàíèòü ïîçèöèþ ' .. fa.ICON_ARROWS) then
			local pos = imgui.GetWindowPos()
			cfg.settings.chatposx = pos.x
			cfg.settings.chatposy = pos.y
			inicfg.save(cfg,directIni)
		end
		imgui.Text(u8'Ðàçìåð: ')
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
	if tree_window_state.v then -- áûñòðûé îòâåò íà ðåïîðò
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2) - 250, (sh / 2)-90), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Îòâåò íà ðåïîðò', tree_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8'Ðåïîðò îò èãðîêà ' .. autor .. '[' ..autorid.. ']')
		imgui.TextWrapped(u8('Æàëîáà: ') .. u8(textreport))
		if imgui.IsWindowAppearing() then
			imgui.SetKeyboardFocusHere(-1)
		end
		imgui.NewInputText('##SearchBar', text_buffer, 370, nil, 2)
		imgui.SameLine()
		imgui.SetCursorPosX(383)
		if imgui.Button(u8'Îòïðàâèòü ' .. fa.ICON_SHARE, imgui.ImVec2(120, 25)) then
			if cfg.settings.autosave then
				key = #cfg.customotvet + 1
				cfg.customotvet[key] = u8:decode(text_buffer.v)
				inicfg.save(cfg,directIni)
			end
			moiotvet = true
		end
		imgui.Separator()
		if imgui.Button(u8'Ðàáîòàþ', imgui.ImVec2(120, 25)) then
			rabotay = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Ñëåæó', imgui.ImVec2(120, 25)) then
			slejy = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Ñïèñîê ñâîèõ', imgui.ImVec2(120, 25)) then
			custom_otvet_state.v = not custom_otvet_state.v
		end
		imgui.SameLine()
		if imgui.Button(u8'Ïåðåäàòü', imgui.ImVec2(120, 25)) then
			peredamrep = true
		end
		if imgui.Button(u8'Íàêàçàòü', imgui.ImVec2(120, 25)) then
			if tonumber(autorid) then
				nakajy = true
			else
				sampAddChatMessage(tag .. 'Äàííûé èãðîê íå â ñåòè. Èñïîëüçóéòå /rmuteoff', -1)
			end
		end
		imgui.SameLine()
		if imgui.Button(u8'Óòî÷íèòå ID', imgui.ImVec2(120, 25)) then
			uto4id = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Ôîðóì', imgui.ImVec2(120, 25)) then
			uto4 = true
		end
		imgui.SameLine()
		if imgui.Button(u8'Îòêëîíèòü', imgui.ImVec2(120, 25)) then
			otklon = true
		end
		imgui.Separator()
		if imgui.Checkbox(u8'Äîáàâèòü âàø òåêñò ê îòâåòó ' .. fa.ICON_COMMENTING_O, checked_test15) then
			cfg.settings.doptext = not cfg.settings.doptext
			inicfg.save(cfg,directIni)
		end
		if imgui.Checkbox(u8'Ñîõðàíÿòü îòâåòû â áàçå äàííûõ ñêðèïòà ' .. fa.ICON_DATABASE, checked_test5) then
			cfg.settings.autosave = not cfg.settings.autosave
			inicfg.save(cfg,directIni)
		end
		imgui.PopFont()
		imgui.End()
	end
	if ban_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Âûäàòü áëîêèðîâêó àêêàóíòà", ban_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Âûáåðèòå ïðè÷èíó')
		if not sampIsDialogActive() then
			if imgui.Button(u8'×èòû', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/ch ' .. playerrecon)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Ìíîãî÷èñëåííûå íàðóøåíèÿ (3)', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/iban ' .. playerrecon .. ' 3 Íåàäåêâàòíîå ïîâåäåíèå')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Íàðóøåíèå ïðàâèë õåëïåðà', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/oskhelper ' .. playerrecon)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Îñêîðáëåíèå ïðîåêòà', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/bosk ' .. playerrecon)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Ðåêëàìà', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/reklama ' .. playerrecon)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Îáìàí', imgui.ImVec2(250, 25)) then
				sampSendChat('/siban ' .. playerrecon .. ' 30 Îáìàí/ðàçâîä')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Íàçâàíèå áàíäû', imgui.ImVec2(250, 25)) then
				sampSendChat('/ban ' .. playerrecon .. ' 7 Íàçâàíèå áàíäû')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
		else
			sampAddChatMessage(tag .. '{FFFFFF}Çàêðîéòå äèàëîã, ÷òîáû ïðîäîëæèòü.', -1)
		end
		imgui.End()
	end
	if jail_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Ïîñàäèòü èãðîêà â òþðüìó", jail_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Âûáåðèòå ïðè÷èíó')
		if not sampIsDialogActive() then
			if imgui.Button(u8'DM/DB in ZZ', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/dz ' .. playerrecon)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8"Çëîóïîòðåáëåíèå VIP'îì", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/zv ' .. playerrecon)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'Spawn Kill', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/sk ' .. playerrecon)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'Car in trade/ZZ', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/td ' .. playerrecon)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'×èò', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/jcb ' .. playerrecon)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'×èò áåçâðåäíûé', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/jc ' .. playerrecon)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'ÄÁ êîâø â çåëåíîé çîíå', imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. ' ÄÁ êîâø â çåëåíîé çîíå')
				showCursor(false,false)
				jail_window_state.v = false
			end
		else
			sampAddChatMessage(tag .. 'Çàêðîéòå äèàëîã, ÷òîáû ïðîäîëæèòü.', -1)
		end
		imgui.End()
	end
	if mute_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Çàáëîêèðîâàòü ÷àò èãðîêó", mute_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Âûáåðèòå ïðè÷èíó')
		if not sampIsDialogActive() then
			if imgui.Button(u8'Îñêîðáëåíèå/Óíèæåíèå', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/ok ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8"Ìàò", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/m ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8"Ôëóä", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/fd ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Ïîïðîøàéíè÷åñòâî', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/po ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/or ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Îñêîðáëåíèå àäìèíèñòðàöèè', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/oa ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Êëåâåòà íà àäìèíèñòðàöèþ', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/kl ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Çëîóïîòðåáëåíèå ñèìâîëàìè', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/zs ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Âûäà÷à ñåáÿ çà àäìèíèñòðàòîðà', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/ia ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Óïîìèíàíèå ñòîðîííèõ ïðîåêòîâ', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/up ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
		else
			sampAddChatMessage(tag .. 'Çàêðîéòå äèàëîã, ÷òîáû ïðîäîëæèòü.', -1)
		end
		imgui.End()
	end
	if kick_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Êèêíóòü èãðîêà ñ ñåðâåðà", kick_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Âûáåðèòå ïðè÷èíó')
		if not sampIsDialogActive() then
			if imgui.Button(u8'AFK /arena', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/cafk ' .. playerrecon)
				four_window_state.v = false
				kick_window_state.v = false
			end
			if imgui.Button(u8"Nick 1/3", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/kk1 ' .. playerrecon)
				four_window_state.v = false
				kick_window_state.v = false
			end
			if imgui.Button(u8"Nick 2/3", imgui.ImVec2(250, 25)) then
				sampSendInputChat('/kk2 ' .. playerrecon)
				four_window_state.v = false
				kick_window_state.v = false
			end
			if imgui.Button(u8'Nick 3/3', imgui.ImVec2(250, 25)) then
				sampSendInputChat('/kk3 ' .. playerrecon)
				four_window_state.v = false
				kick_window_state.v = false
			end
		else
			sampAddChatMessage(tag .. 'Çàêðîéòå äèàëîã, ÷òîáû ïðîäîëæèòü.', -1)
		end
		imgui.End()
	end
	if four_window_state.v then -- êàñòîì ðåêîí ìåíþ
		if cfg.settings.customposx then
			imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.customposx, cfg.settings.customposy))
		else
			imgui.SetNextWindowPos(imgui.ImVec2(sw-270, 0))
		end
		imgui.Begin(u8"Ðåêîí", four_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'Èãðîê ' ..fa.ICON_MALE, imgui.ImVec2(120, 25)) then uu() menu[1] = true end imgui.SameLine()
        if imgui.Button(u8'Â ðàäèóñå ' .. fa.ICON_USERS, imgui.ImVec2(120, 25)) then uu() menu[2] = true end 
		imgui.PopFont()
        imgui.Separator()
        imgui.NewLine()
        imgui.SameLine(3)
        if menu[1] then
			imgui.PushFont(fontsize)
			imgui.SetCursorPosX(10)
			if imgui.Button(fa.ICON_FILES_O) then
				setClipboardText(nickplayerrecon)
				sampAddChatMessage(tag .. 'Íèê ñêîïèðîâàí â áóôôåð îáìåíà.', -1)
			end
			if imgui.IsWindowAppearing() then
				imgui.SetKeyboardFocusHere(-1)
			end
			if ansreport_window_state.v then
				ansreport_window_state.v = false
				saveplayerrecon = false
			end
			imgui.SameLine()
			imgui.Text(u8('Èãðîê: ' .. nickplayerrecon) .. '[' .. playerrecon .. ']' )
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
				imgui.Text(u8'Çäîðîâüå àâòî: ' .. u8(hpcar))
			end
			if speed then
				imgui.Text(u8'Ñêîðîñòü: ' .. u8(speed))
			end
			if ping then
				imgui.Text(u8'Ïèíã: ' .. u8(ping))
			end
			if ploss then
				imgui.Text(u8'P.Loss: ' .. u8(ploss))
			end
			if gun then
				imgui.Text(u8'Îðóæèå: ' .. u8(gun))
				if aim then
					imgui.Text(u8'Òî÷íîñòü: ' .. u8(aim))
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
				imgui.Text(u8'Òóðáî ïàêåò: ' .. u8(turbo))
			end
			if collision then
				imgui.Text(u8'Êîëëèçèÿ: ' .. u8(collision))
			end
			if imgui.Button(u8'Ïîñìîòðåòü ñòàòèñòèêó', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					sampSendChat('/statpl ' .. playerrecon)
				else
					sampAddChatMessage(tag .. 'Ó âàñ îòêðûò äèàëîã, çàêðîéòå åãî.', -1)
				end
			end
			if imgui.Button(u8'Ïîñìîòðåòü /offstats ñòàòèñòèêó', imgui.ImVec2(250, 25)) then
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
					sampAddChatMessage(tag .. 'Ó âàñ îòêðûò äèàëîã, çàêðîéòå åãî.', -1)
				end
			end
			if imgui.Button(u8'Ïîñìîòðåòü âòîðóþ ñòàòèñòèêó', imgui.ImVec2(250, 25)) then
				if not sampIsDialogActive() then
					sampSendClickTextdraw(165)
				else
					sampAddChatMessage(tag .. 'Ó âàñ îòêðûò äèàëîã, çàêðîéòå åãî.', -1)
				end
			end
			if imgui.Button(u8'Çàáëîêèðîâàòü èãðîêà', imgui.ImVec2(250, 25)) then
				ban_window_state.v = true
			end
			if imgui.Button(u8'Ïîñàäèòü â äæàéë', imgui.ImVec2(250, 25)) then
				jail_window_state.v = true
			end
			if imgui.Button(u8'Âûäàòü ìóò', imgui.ImVec2(250, 25)) then
				mute_window_state.v = true
			end
			if imgui.Button(u8'Êèêíóòü èãðîêà', imgui.ImVec2(250, 25)) then
				kick_window_state.v = true
			end
			if imgui.Button(u8'Äîïîëíèòåëüíûå äåéñòâèÿ', imgui.ImVec2(250, 25)) then
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
						sampSendInputChat('/keysync ' .. playerrecon)
					end
				end)
			end
			if isKeyJustPressed(VK_Q) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendClickTextdraw(177)
				four_window_state.v = false
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
	if fourtwo_window_state.v then -- Ñîõðàíåíèÿ ðàñïîëîæåíèÿ êàñòîì ðåêîí ìåíþ
		imgui.SetNextWindowSize(imgui.ImVec2(250, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Íàñòðîéêè ðåêîíà", fourtwo_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'Ñîõðàíèòü ïîçèöèþ ' .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
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
	if five_window_state.v then -- Ñîõðàíåíèå ðàñïîëîæåíèÿ keylogger
		imgui.SetNextWindowSize(imgui.ImVec2(400, 100), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Íàñòðîéêè keylog", five_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8"Ñîõðàíèòü ðàñïîëîæåíèå " .. fa.ICON_ARROWS, imgui.ImVec2(250, 25)) then
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
	if dopcustomreport_window_state.v then -- äîï äåéñòâèÿ â êàñòîì ðåêîí ìåíþ
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Âçàèìîäåéñòâèå ñ èãðîêîì", dopcustomreport_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Âûáåðèòå äåéñòâèå')
		if imgui.Button(u8"Ñëàïíóòü", imgui.ImVec2(250, 25)) then
			sampSendChat('/slap ' .. playerrecon)
		end
		if imgui.Button(u8"Çàñïàâíèòü", imgui.ImVec2(250, 25)) then
			sampSendChat('/aspawn ' .. playerrecon)
		end
		if imgui.Button(u8"Çàìîðîçèòü", imgui.ImVec2(250, 25)) then
			sampSendChat('/freeze ' .. playerrecon)
		end
		if imgui.Button(u8"Óáèòü", imgui.ImVec2(250, 25)) then
			sampSendChat('/sethp ' .. playerrecon .. ' 0')
		end
		if imgui.Button(u8"Òåëåïîðòèðîâàòü ê ñåáå", imgui.ImVec2(250, 25)) then
			if not sampIsDialogActive() then
				lua_thread.create(function()
					sampSendChat('/reoff')
					dopcustomreport_window_state.v = false
					wait(3000)
					sampSendChat('/gethere ' .. playerrecon)
				end)
			else
				sampAddChatMessage(tag .. 'Çàêðîéòå äèàëîã.')
			end
		end
		if imgui.Button(u8"Òåëåïîðòèðîâàòü ê íåìó", imgui.ImVec2(250, 25)) then
			if not sampIsDialogActive() then
				lua_thread.create(function()
					sampSendChat('/reoff')
					dopcustomreport_window_state.v = false
					wait(3000)
					sampSendChat('/agt ' .. playerrecon)
				end)
			else
				sampAddChatMessage(tag .. 'Çàêðîéòå äèàëîã.')
			end
		end
		imgui.End()
	end
	if rmute_window_state.v then -- Íàêàçàòü â îêíå áûñòðîãî ðåïîðòà
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Âûäàòü áëîêèðîâêó ðåïîðòà", rmute_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.Button(u8'Îôôòîï', imgui.ImVec2(250, 25)) then
			oftop = true
		end
		if imgui.Button(u8'Êàïñ', imgui.ImVec2(250, 25)) then
			capsrep = true
		end
		if imgui.Button(u8'Îñêîðáëåíèå àäìèíèñòðàöèè', imgui.ImVec2(250, 25)) then
			oskadm = true
		end
		if imgui.Button(u8'Êëåâåòà íà àäìèíèñòðàöèþ', imgui.ImVec2(250, 25)) then
			kl = true
		end
		if imgui.Button(u8'Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ', imgui.ImVec2(250, 25)) then
			oskrod = true
		end
		if imgui.Button(u8'Ïîïðîøàéíè÷åñòâî', imgui.ImVec2(250, 25)) then
			poprep = true
		end
		if imgui.Button(u8'Îñêîðáëåíèå/Óíèæåíèå', imgui.ImVec2(250, 25)) then
			oskrep = true
		end
		if imgui.Button(u8'Íåöåíçóðíàÿ ëåêñèêà', imgui.ImVec2(250, 25)) then
			matrep = true
		end
		imgui.End()
	end
	if custom_otvet_state.v then -- ñâîé îòâåò â ðåïîðò
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), (sh / 2)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Ìîé îòâåò', custom_otvet_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
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
	if ansreport_window_state.v then -- ïîìîùü ïîñëå ñëåæêè â ðåêîíå
		imgui.SetNextWindowPos(imgui.ImVec2(sw-250, 0), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Ïîìîùü ïîñëå âûõîäà èç ðåêîíà", ansreport_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Âû çàêîí÷èëè ñëåæêó ïî ðåïîðòó')
		imgui.CenterText(u8'Äîëîæèòü èíôîðìàöèþ?')
		if imgui.Button(u8'Íàðóøåíèé íå íàáëþäàþ', imgui.ImVec2(250, 25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSendInputChat('/n ' .. saveplayerrecon)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage(tag .. 'Èãðîê íå â ñåòè.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'Äàííûé èãðîê ÷èñò', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSendInputChat('/cl ' .. saveplayerrecon)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage(tag .. 'Èãðîê íå â ñåòè.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'Èãðîê íàêàçàí.', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSendInputChat('/nak ' .. saveplayerrecon)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage(tag .. 'Èãðîê íå â ñåòè.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'Ïîìîãëè âàì.', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSendInputChat('/pv ' .. saveplayerrecon)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage(tag .. 'Èãðîê íå â ñåòè.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'Èãðîê AFK', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSendInputChat('/afk ' .. saveplayerrecon)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage(tag .. 'Èãðîê íå â ñåòè.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'Èãðîê íå â ñåòè', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSendInputChat('/nv ' .. saveplayerrecon)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage(tag .. 'Èãðîê íå â ñåòè.')
				saveplayerrecon = nil
				ansreport_window_state.v = false
			end
		end
		if imgui.Button(u8'Ýòî äîíàò-ïðåèìóùåñòâà', imgui.ImVec2(250,25)) then
			if sampIsPlayerConnected(saveplayerrecon) then
				sampSendInputChat('/dpr ' .. saveplayerrecon)
				saveplayerrecon = nil
				ansreport_window_state.v = false
			else
				sampAddChatMessage(tag .. 'Èãðîê íå â ñåòè.')
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
		imgui.CenterText(u8'Àêòèâàöèÿ/äåàêòèâàöèÿ êóðñîðà')
		imgui.CenterText(u8'ÏÊÌ')
		imgui.CenterText(u8'Ìåíþ àêòèâíî 5 ñåêóíä.')
		imgui.End()
	end
end
local russian_characters = { -- ðóññêèå áóêîâêè äëÿ ôóíêöèè íèæå
    [168] = '¨', [184] = '¸', [192] = 'À', [193] = 'Á', [194] = 'Â', [195] = 'Ã', [196] = 'Ä', [197] = 'Å', [198] = 'Æ', [199] = 'Ç', [200] = 'È', [201] = 'É', [202] = 'Ê', [203] = 'Ë', [204] = 'Ì', [205] = 'Í', [206] = 'Î', [207] = 'Ï', [208] = 'Ð', [209] = 'Ñ', [210] = 'Ò', [211] = 'Ó', [212] = 'Ô', [213] = 'Õ', [214] = 'Ö', [215] = '×', [216] = 'Ø', [217] = 'Ù', [218] = 'Ú', [219] = 'Û', [220] = 'Ü', [221] = 'Ý', [222] = 'Þ', [223] = 'ß', [224] = 'à', [225] = 'á', [226] = 'â', [227] = 'ã', [228] = 'ä', [229] = 'å', [230] = 'æ', [231] = 'ç', [232] = 'è', [233] = 'é', [234] = 'ê', [235] = 'ë', [236] = 'ì', [237] = 'í', [238] = 'î', [239] = 'ï', [240] = 'ð', [241] = 'ñ', [242] = 'ò', [243] = 'ó', [244] = 'ô', [245] = 'õ', [246] = 'ö', [247] = '÷', [248] = 'ø', [249] = 'ù', [250] = 'ú', [251] = 'û', [252] = 'ü', [253] = 'ý', [254] = 'þ', [255] = 'ÿ',
}
function string.rlower(s) -- ïåðåâîä ðóññêèõ áóêâ â ïðîïèñíûå
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- ¨
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function uu() -- äëÿ âêëàäîê
    for i = 0,2 do
        menu[i] = false
    end
end
function uu2() -- äëÿ âêëàäîê
    for i = 0,10 do
        menu2[i] = false
    end
end
function textSplit(str, delim, plain) -- ðàçáèåíèå òåêñòà ïî îïðåäåëåííûì òðèããåðàì
    local tokens, pos, plain = {}, 1, not (plain == false)
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end
function timerans()
	rabotay = nil
	slejy = nil
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
function timer() -- òàéìåð äëÿ àâòîôîðì
	while true do
		wait(0)
		if st.bool and st.timer ~= -1 and sett then
            timer = os.clock()-st.timer
			if probid and sampIsPlayerConnected(probid) then
           		renderFontDrawText(fonts, cfg.settings.stylecolor .. 'Íàæìè U ÷òîáû ïðèíÿòü èëè J ÷òîáû îòêëîíèòü\nÔîðìà: ' .. cfg.settings.stylecolorform .. forma .. cfg.settings.stylecolor .. ' íà èãðîêà '.. cfg.settings.stylecolorform .. nickid .. '[' .. probid .. ']'.. cfg.settings.stylecolor .. '\nÂðåìåíè íà ðàçäóìüÿ 8 ñåê, ïðîøëî: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
			else
				renderFontDrawText(fonts, cfg.settings.stylecolor .. 'Íàæìè U ÷òîáû ïðèíÿòü èëè J ÷òîáû îòêëîíèòü\nÔîðìà: ' .. cfg.settings.stylecolorform .. forma.. cfg.settings.stylecolor .. '\nÂðåìåíè íà ðàçäóìüÿ 8 ñåê, ïðîøëî: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
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
local count = 0 -- ñ÷åò÷èê êîë-âà ñîîáùåíèé â À×
----- Ïîòîê äëÿ ðåíäåðà àäìèí ÷àòà ---------------
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
function sampev.onServerMessage(color,text) -- ïîèñê ñîîáùåíèé èç ÷àòà
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
									sampAddChatMessage(tag..'ID íå îáíàðóæåí, ëèáî íàõîäèòñÿ âíå ñåòè.', -1)
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
		return false --
	end
	if cfg.settings.automute and not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
        if (text:match("(.*)%((%d+)%):%s(.+)(.+)") or text:match("(.*)%[(%d+)%]:%s(.+)")) and not text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)") and not text:match('%[(%d+)%] íàïèñàë %[(%d+)%]') and not text:match('%] îòâåòèë (.*)%[(%d+)%]: (.*)') and not text:match('Æàëîáà #') then
            if tonumber(text:match('%((%d+)%)')) then
                oskid = tonumber(text:match('%((%d+)%)'))
            else
                oskid = tonumber(text:match('%[(%d+)%]'))
            end
            text = text:lower()
            text = text:rlower()
            if (text:match('%s'..'mq') or text:match('}'..'mq')) or (text:match('%s' .. 'rnq' .. '%s') or text:match('}' .. 'rnq')) then
                sampAddChatMessage('{00FF00}[ÀÂÒÎÌÓÒ]{DCDCDC} ' .. text .. ' {00FF00}[ÀÂÒÎÌÓÒ]', -1)
                lua_thread.create(function()
                    while sampIsDialogActive() do
                        wait(20)
                    end
                end)
				if oskid and not isGamePaused() and not isPauseMenuActive() and not sampIsPlayerPaused(id) then
					sampSendChat('/mute ' .. oskid .. ' 5000 Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ')
					if notify then
						notify.addNotify('Àâòîìóò', 'Âûÿâëåí íàðóøèòåëü:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Óïîìèíàíèå ðîäíûõ.', 2,1,4)
					end
				end
                return false
            end
            for k,v in pairs(cfg.osk) do
                if (text:match('%s'..v) or text:match('}'..v)) and not text:match('ÿ ' .. v) then
                    sampAddChatMessage('{00FF00}[ÀÂÒÎÌÓÒ]{DCDCDC} ' .. text .. ' {00FF00}[ÀÂÒÎÌÓÒ]', -1)
                    lua_thread.create(function()
                        while sampIsDialogActive() do
                            wait(20)
                        end
                    end)
                    if oskid then
                        sampSendChat('/mute ' .. oskid .. ' 400 Îñêîðáëåíèå/Óíèæåíèå')
						if notify then
							notify.addNotify('Àâòîìóò', 'Âûÿâëåí íàðóøèòåëü:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Çàïðåùåííîå ñëîâî: ' .. v, 2,1,4)
						end
                    end
                    return false
                end
            end
            for k,v in pairs(cfg.mat) do
                if (text:match('%s'..v) or text:match('}'..v)) then
                    sampAddChatMessage('{00FF00}[ÀÂÒÎÌÓÒ]{DCDCDC} ' .. text .. ' {00FF00}[ÀÂÒÎÌÓÒ]', -1)
                    lua_thread.create(function()
                        while sampIsDialogActive() do
                            wait(20)
                        end
                    end)
					if oskid and not isGamePaused() and not isPauseMenuActive() and not sampIsPlayerPaused(id) then
                        sampSendChat('/mute ' .. oskid .. ' 300 Íåöåíçóðíàÿ ëåêñèêà')
						if notify then
							notify.addNotify('Àâòîìóò', 'Âûÿâëåí íàðóøèòåëü:\n ' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Çàïðåùåííîå ñëîâî: ' .. v, 2,1,4)
						end
                    end
                    return false
                end
            end
        end
    end
end
function sampev.onShowTextDraw(id, data) -- Ñ÷èòûâàåì ñåðâåðíûå òåêñòäðàâû
	lua_thread.create(function()
		if id == 2052 then
			wait(100)
			sampTextdrawSetPos(2052, 2000, 0)
			imgui.Process = true
			playerrecon = sampTextdrawGetString(2052)
			playerrecon = tonumber(playerrecon:match('%((%d+)%)')) -- id íàðóøèòåëÿ
			nickplayerrecon = sampGetPlayerNickname(playerrecon) -- íèê íàðóøèòåëÿ
			four_window_state.v = true
			if cfg.settings.keysync then
				sampSendInputChat('/keysync ' .. playerrecon)
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
				vip = 'Îòñóòñòâóåò'
			end
			if vip == '1' then
				vip = 'Îáûêíîâåííûé'
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
				passivemod = 'Âûêëþ÷åí'
			else
				passivemod = 'Àêòèâèðîâàí'
			end
			if turbo == '0' then
				turbo = 'Âûêëþ÷åí'
			else
				turbo = 'Àêòèâèðîâàí'
			end
			if collision == '1' then
				collision = 'Àêòèâèðîâàíà'
			else
				collision = 'Âûêëþ÷åíà'
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
function sampGetPlayerIdByNickname(nick) -- óçíàòü ID ïî íèêó
	nick = tostring(nick)
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if nick == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 1003 do
	  	if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
			return i
	  	end
	end
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text) -- Ðàáîòà ñ îòêðûòèìè ÄÈÀËÎÃÀÌÈ
	if dialogId == 16190 then -- îêíî /offstats ãäå âûáîð ìåæäó ñòàòèñòèêîé è àâòî èñïîëüçóåòñÿ äëÿ /sbanip
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
	if dialogId == 16191 then -- îêíî /offstats èñïîëüçóåòñÿ äëÿ /sbanip
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
	if dialogId == 2349 then -- îêíî ñ ñàìèì ðåïîðòîì.
		local lineIndex = -1
		for line in text:gmatch("[^\n]+") do
			lineIndex = lineIndex + 1
			if lineIndex == tonumber(1) - 1 then 
				don = string.sub(line, 1, 1)
				if don == '{' then
					autor = string.sub(line, 24) -- ñ÷èòûâàåì àâòîðà æàëîáû
					if sampGetPlayerIdByNickname(autor) then
						autorid = sampGetPlayerIdByNickname(autor) -- óçíàåì èä
					else
						autorid = (u8'ÍÅ Â ÑÅÒÈ')
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
					textreport = string.sub(line, 9) -- òåêñò ðåïîðòà
					if string.match(line, '%d[%d.,]*') then
						reportid = tonumber(string.match(textreport, '%d[%d.,]*'))
						if sampIsPlayerConnected(reportid) then
							nickreportid = sampGetPlayerNickname(reportid) -- íèê òîãî íà êîãî æàëóþòñÿ
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
			while rabotay ~= 2 and uto4 ~= 2  and nakajy ~= 2 and not customans and slejy ~= 2 and jb ~= 2 and ojid ~= 2 and moiotvet ~= 2 and uto4id ~= 2 and helpest~= 2 and nakazan ~= 2 and otklon ~= 2 and peredamrep ~= 2 do -- æäåì íàæàòèÿ êëàâèøè
				wait(50)
				doptext = ('{'..tostring(color())..'} ' .. cfg.settings.mytextreport)
				if rabotay then
					peremrep = ('Íà÷àë(à) ðàáîòó ïî âàøåé æàëîáå!')
					rabotay = 2
				end
				if ojid then
					peremrep = ('Îæèäàéòå, ñêîðî âñ¸ áóäåò.')
					ojid = 2
				end
				if nakazan then
					peremrep = ('Äàííûé èãðîê óæå áûë íàêàçàí.')
					nakazan = 2
				end
				if helpest then
					peremrep = ('Äàííàÿ èíôîðìàöèÿ èìååòñÿ â /help')
					helpest = 2
				end
				if otklon then
					otklon = 2
				end
				if peredamrep then
					peredamrep = 2
				end
				if uto4id then
					peremrep = ('Óòî÷íèòå ID íàðóøèòåëÿ â /report.')
					uto4id = 2
				end
				if nakajy then
					peremrep = ('Áóäåòå íàêàçàíû çà íàðóøåíèå ïðàâèë /report')
					rmute_window_state.v = true
					if oftop or oskadm or matrep or oskrep or poprep or oskrod or capsrep then
						nakajy = 2
						rmute_window_state.v = false
					end  
				end
				if jb then
					peremrep = ('Íàïèøèòå æàëîáó íà forumrds.ru')
					jb = 2
				end
				if moiotvet then
					if cfg.settings.doptext then
						peremrep = (u8:decode(text_buffer.v) .. doptext)
						if #peremrep >= 80 then
							peremrep = (u8:decode(text_buffer.v))
							if #peremrep >= 80 then
								text_buffer.v = u8'Ìîé îòâåò íå âìåùàåòñÿ â îêíî ðåïîðòà, ÿ îòïèøó âàì ëè÷íî'
								moiotvet = true
							end
						end
						moiotvet = 2
					else
						peremrep = (u8:decode(text_buffer.v))
						if #peremrep >= 80 then
							text_buffer.v = u8'Ìîé îòâåò íå âìåùàåòñÿ â îêíî ðåïîðòà, ÿ îòïèøó âàì ëè÷íî'
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
					peremrep = ('Îáðàòèòåñü ñ äàííîé ïðîáëåìîé íà ôîðóì https://forumrds.ru')
					uto4 = 2
				end
			end
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
			tree_window_state.v = not tree_window_state.v
			imgui.Process = tree_window_state
		end)
	end
	if dialogId == 2350 then -- îêíî ñ âîçìîæíîñòüþ ïðèíÿòü èëè îòêëîíèòü ðåïîðò
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
	if dialogId == 2351 then -- îêíî ñ îòâåòîì íà ðåïîðò
		lua_thread.create(function()
			if peredamrep == 2 then
				sampSendDialogResponse(dialogId, 1, _, 'Ïåðåäàì âàø ðåïîðò.')
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
						peremrep = ('Íà÷àë(à) ðàáîòó ïî âàøåé æàëîáå.')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						rabotay = nil
					end
					if reportid and reportid ~= myid then
						if not sampIsPlayerConnected(reportid) then
							peremrep = ('Óêàçàííûé âàìè èãðîê ïîä ' .. reportid .. ' ID íàõîäèòñÿ âíå ñåòè.')
							sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							rabotay = nil
						else
							peremrep = ('Íà÷àë(à) ðàáîòó ïî âàøåé æàëîáå.')
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
						peremrep = ('Íà÷àë(à) ðàáîòó ïî âàøåé æàëîáå.')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						rabotay = nil
					end
				else
					if not reportid then
						peremrep = ('Íà÷àë(à) ðàáîòó ïî âàøåé æàëîáå.')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						rabotay = nil
					end
					if reportid and reportid ~= myid then
						if not sampIsPlayerConnected(reportid) then
							peremrep = ('Óêàçàííûé âàìè èãðîê ïîä ' .. reportid .. ' ID íàõîäèòñÿ âíå ñåòè.')
							sampSendDialogResponse(dialogId, 1, _, peremrep)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							rabotay = nil
						else
							peremrep = ('Íà÷àë(à) ðàáîòó ïî âàøåé æàëîáå.')
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
						peremrep = ('Íà÷àë(à) ðàáîòó ïî âàøåé æàëîáå.')
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
						peremrep = ('Íà÷èíàþ ñëåæêó.')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						slejy = nil
					end
					if reportid and reportid ~= myid then
						if not sampIsPlayerConnected(reportid) then
							peremrep = ('Óêàçàííûé âàìè èãðîê ïîä ' .. reportid .. ' ID íàõîäèòñÿ âíå ñåòè.')
							sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							slejy = nil
						else
							peremrep = ('Îòïðàâëÿþñü â ñëåæêó çà èãðîêîì ' .. nickreportid .. '['..reportid..']')
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
						peremrep = ('Âû óêàçàëè ìîé ID :D')
						sampSendDialogResponse(dialogId, 1, _, peremrep .. doptext)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						slejy = nil
					end
				else
					if not reportid then
						peremrep = ('Íà÷èíàþ ñëåæêó.')
						sampSendDialogResponse(dialogId, 1, _, peremrep)
						setVirtualKeyDown(13, true)
						setVirtualKeyDown(13, false)
						slejy = nil
					end
					if reportid and reportid ~= myid then
						if not sampIsPlayerConnected(reportid) then
							peremrep = ('Óêàçàííûé âàìè èãðîê ïîä ' .. reportid .. ' ID íàõîäèòñÿ âíå ñåòè.')
							sampSendDialogResponse(dialogId, 1, _, peremrep)
							setVirtualKeyDown(13, true)
							setVirtualKeyDown(13, false)
							slejy = nil
						else
							peremrep = ('Îòïðàâëÿþñü â ñëåæêó çà èãðîêîì ' .. nickreportid .. '['..reportid..']')
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
						peremrep = ('Âû óêàçàëè ìîé ID :D')
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
					sampSendChat('/rmute ' .. autorid .. ' 120 îôôòîï â /report')
					oftop = false
				end
				if oskadm then
					sampSendChat('/rmute ' .. autorid .. ' 2500 Îñêîðáëåíèå àäìèíèñòðàöèè')
					oskadm = false
				end
				if oskrep then
					sampSendChat('/rmute ' .. autorid .. ' 400 Îñêîðáëåíèå/Óíèæåíèå')
					oskrep = false
				end
				if poprep then
					sampSendChat('/rmute ' .. autorid .. ' 120 Ïîïðîøàéíè÷åñòâî')
					poprep = false
				end
				if oskrod then
					sampSendChat('/rmute ' .. autorid .. ' 5000 Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ')
					oskrod = false
				end
				if capsrep then
					sampSendChat('/rmute ' .. autorid .. ' 120 Êàïñ â /report')
					capsrep = false
				end
				if matrep then
					sampSendChat('/rmute ' .. autorid .. ' 300 Íåöåíçóðíàÿ ëåêñèêà')
					matrep = false
				end
				if kl then
					sampSendChat('/rmute ' .. autorid .. ' 3000 Êëåâåòà íà àäìèíèñòðàöèþ')
					kl = false
				end
			end
			if customans then
				if cfg.settings.doptext then
					peremrep = (customans .. doptext)
					if #peremrep >= 80 then
						peremrep = customans
						if #peremrep >= 80 then
							peremrep = u8'Ìîé îòâåò íå âìåùàåòñÿ â îêíî ðåïîðòà, ÿ îòïèøó âàì ëè÷íî'
						end
					end
				else
					peremrep = customans
					if #peremrep >= 80 then
						peredamrep = u8'Ìîé îòâåò íå âìåùàåòñÿ â îêíî ðåïîðòà, ÿ îòïèøó âàì ëè÷íî'
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
function sampev.onDisplayGameText(style, time, text) -- ñêðûâàåò òåêñò íà ýêðàíå.
   -- if text:find("REPORT++") then
   --     return false
   -- end
	if text:find('RECON') then
		four_window_state.v = false
		if cfg.settings.keysync then
			sampSendInputChat('/keysync off')
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
				mimgui.Text(u8"Èãðîê íå çàôèêñèðîâàí. Îáíîâèòå ðåêîí íàæàâ êëàâèøó R")
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
function imgui.NewInputText(lable, val, width, hint, hintpos) -- Ïîëå ââîäà ñ ïîäñêàçêîé
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
function onWindowMessage(msg, wparam, lparam) -- áëîêèðîâêà ALT + Enter
	if msg == 261 and wparam == 13 then consumeWindowMessage(true, true) end
end
function playersToStreamZone() -- èãðîêè â ðàäèóñå
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
----======================= Èñêëþ÷èòåëüíî äëÿ ñêðèïòà ===============------------------
sampRegisterChatCommand('add_mat', function(param)
	key = #cfg.mat + 1
	param = param:lower()
	param = param:rlower()
    for k, v in pairs(cfg.mat) do
        if cfg.mat[k] == param then
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Ñëîâî{008000} ' .. param .. ' {F0E68C}óæå èìååòñÿ â ñïèñêå ìàòîâ.', -1)
            a = true
            break
        else    
            a = false
        end
    end
    if not a then
        cfg.mat[key] = param
        inicfg.save(cfg,directIni)
        sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Ñëîâî{008000} ' .. param .. ' {F0E68C}áûëî óñïåøíî äîáàâëåíî â ñïèñîê ìàòîâ.', -1)
        a = false
    end
end)
sampRegisterChatCommand('del_mat', function(param)
	key = #cfg.mat + 1
	param = param:lower()
	param = param:rlower()
    for k, v in pairs(cfg.mat) do
        if cfg.mat[k] == param then
            cfg.mat[k] = nil
            inicfg.save(cfg,directIni)
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Âûáðàííîå âàìè ñëîâî{008000} ' .. param .. ' {F0E68C}áûëî óñïåøíî óäàëåíî èç ñïèñêà ìàòîâ', -1)
            a = true
            break
        else    
            a = false
        end
    end
    if not a then
        sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Òàêîãî ñëîâà â ñïèñêå ìàòîâ íåò.', -1)
        a = nil
    end
end)
sampRegisterChatCommand('add_osk', function(param)
	key = #cfg.osk + 1
	param = param:lower()
	param = param:rlower()
    for k, v in pairs(cfg.osk) do
        if cfg.osk[k] == param then
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Ñëîâî{008000} ' .. param .. ' {F0E68C}óæå èìååòñÿ â ñïèñêå îñêîðáëåíèé.' , -1)
            a = true
            break
        else    
            a = false
        end
    end
    if not a then
        cfg.osk[key] = param
        inicfg.save(cfg,directIni)
        sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Ñëîâî{008000} ' .. param .. ' {F0E68C}áûëî óñïåøíî äîáàâëåíî â ñïèñîê îñêîðáëåíèé', -1)
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
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Âûáðàííîå âàìè ñëîâî{008000} ' .. param .. ' {F0E68C}áûëî óñïåøíî óäàëåíî èç ñïèñêà', -1)
            a = true
            break
        else    
            a = false
        end
    end
    if not a then
        sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Òàêîãî ñëîâà â ñïèñêå îñêîðáëåíèé íåò.', -1)
        a = nil
    end
end)
sampRegisterChatCommand('wh' , function()
	if not cfg.settings.wallhack then
		cfg.settings.wallhack = true
		checked_test14 = imgui.ImBool(true)
		sampAddChatMessage(tag .. 'WallHack âêëþ÷åí', -1)
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
		sampAddChatMessage(tag .. 'WallHack âûêëþ÷åí', -1)
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
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end)
sampRegisterChatCommand('textform', function(param) 
	cfg.settings.texts = param
	inicfg.save(cfg,directIni)
	sampAddChatMessage(tag .. 'Òåêñò ïðèíÿòèÿ ôîðìû îáíîâëåí', -1)
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

----======================= Èñêëþ÷èòåëüíî âñïîìîãàòåëüíûå ===============------------------
sampRegisterChatCommand('test', function()

end)
sampRegisterChatCommand('spp', function()
	local playerid_to_stream = playersToStreamZone()
	for _, v in pairs(playerid_to_stream) do
	sampSendChat('/aspawn ' .. v)
	end
end)
sampRegisterChatCommand('n', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Íå âèæó íàðóøåíèé ñî ñòîðîíû èãðîêà. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' Íå âèæó íàðóøåíèé ñî ñòîðîíû èãðîêà.')
		end
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('dpr', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Ó èãðîêà êóïëåíû ôóíêöèè çà /donate ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' Ó èãðîêà êóïëåíû ôóíêöèè çà /donate')
		end
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('c', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Íà÷àë(à) ðàáîòó íàä âàøåé æàëîáîé. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' Íà÷àë(à) ðàáîòó íàä âàøåé æàëîáîé.')
		end
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('cl', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Äàííûé èãðîê ÷èñò. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' Äàííûé èãðîê ÷èñò.')
		end
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('nak', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Èãðîê áûë íàêàçàí, ñïàñèáî çà îáðàùåíèå. ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' Èãðîê áûë íàêàçàí, ñïàñèáî çà îáðàùåíèå.')
		end
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('pv', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Ïîìîãëè âàì. Îáðàùàéòåñü åù¸ ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' Ïîìîãëè âàì. Îáðàùàéòåñü åù¸')
		end
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('afk', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Èãðîê áåçäåéñòâóåò èëè íàõîäèòñÿ â AFK ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' Èãðîê áåçäåéñòâóåò èëè íàõîäèòñÿ â AFK')
		end
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('nv', function(param) 
	if #param ~= 0 then
		if cfg.settings.doptext then
			sampSendChat('/ans ' .. param .. ' Èãðîê íå â ñåòè ' .. cfg.settings.mytextreport)
		else
			sampSendChat('/ans ' .. param .. ' Èãðîê íå â ñåòè')
		end
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('prfma', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Ìë.Àäìèíèñòðàòîð " .. cfg.settings.prefixma)
	end
end)
sampRegisterChatCommand('prfa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Àäìèíèñòðàòîð " .. cfg.settings.prefixa)
	end
end)
sampRegisterChatCommand('prfsa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Ñò.Àäìèíèñòðàòîð " .. cfg.settings.prefixsa)
	end
end)
sampRegisterChatCommand('prfpga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Ãëàâíûé-Àäìèíèñòðàòîð " .. color())
	end
end)
sampRegisterChatCommand('prfzga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Çàì.Ãëàâ.Àäìèíèñòðàòîðà " .. color())
	end
end)
sampRegisterChatCommand('prfga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Ãëàâíûé-Àäìèíèñòðàòîð " .. color())
	end
end)
sampRegisterChatCommand('prfcpec', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Ñïåö.Àäìèíèñòðàòîð " .. color())
	end
end)
sampRegisterChatCommand('stw', function(param) 
	if #param ~= 0 then
		sampSendChat("/setweap " .. param .. " 38 5000")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('uu', function(param) 
	if #param ~= 0 then
		sampSendChat('/unmute ' .. param) 
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('uj', function(param) 
	if #param ~= 0 then
		sampSendChat('/unjail ' .. param) 
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('al', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' Çäðàâñòâóéòå! Âû çàáûëè ââåñòè /alogin!') 
		sampSendChat('/ans ' .. param .. ' Ââåäèòå êîìàíäó /alogin è ñâîé ïàðîëü, ïîæàëóéñòà.')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rep', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' Çàäàòü âîïðîñ èëè ïîæàëîâàòüñÿ íà èãðîêà âû ìîæåòå â /report') 
		sampSendChat('/ans ' .. param .. ' Àäìèíèñòðàöèÿ ñðàçó ðåøèò âàø âîïðîñ.')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('as', function(param) 
	if #param ~= 0 then
		sampSendChat('/aspawn ' .. param)
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
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
        sampAddChatMessage(tag .. '/banip [íèê] [÷èñëî] [ïðè÷èíà]', -1)
    end
end)
----======================= Èñêëþ÷èòåëüíî äëÿ ÌÓÒÎÂ ×ÀÒÀ ===============------------------
sampRegisterChatCommand('m', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 300 Íåöåíçóðíàÿ ëåêñèêà')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('mf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 300 Íåöåíçóðíàÿ ëåêñèêà')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('m2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 600 Íåöåíçóðíàÿ ëåêñèêà x2')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('m3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 900 Íåöåíçóðíàÿ ëåêñèêà x3')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('ok', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 400 Îñêîðáëåíèå/Óíèæåíèå')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('okf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 400 Îñêîðáëåíèå/Óíèæåíèå')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('ok2', function(param) 
	if #param ~= 0 then
 		sampSendChat('/mute ' .. param .. ' 800 Îñêîðáëåíèå/Óíèæåíèå x2')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('ok3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1200 Îñêîðáëåíèå/Óíèæåíèå x3')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('fd', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 Ôëóä')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('fdf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 Ôëóä')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('fd2', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 240 Ôëóä x2')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('fd3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 Ôëóä x3')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('or', function(param) 
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 5000 Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('orf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('up', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 1000 Óïîìèíàíèå ñòîðîííèõ ïðîåêòîâ')
		sampSendChat('/cc')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('upf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 Óïîìèíàíèå ñòîðîííèõ ïðîåêòîâ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('oa', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 2500 Îñêîðáëåíèå àäìèíèñòðàöèè')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('oaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 Îñêîðáëåíèå àäìèíèñòðàöèè')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('kl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 3000 Êëåâåòà íà àäìèíèñòðàöèþ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('klf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 3000 Êëåâåòà íà àäìèíèñòðàöèþ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('po', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 120 Ïîïðîøàéíè÷åñòâî')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('pof', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 120 Ïîïðîøàéíè÷åñòâî')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('po2', function(param)
	if #param ~= 0 then 
		sampSendChat('/mute ' .. param .. ' 240 Ïîïðîøàéíè÷åñòâî x2')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('po3', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. ' 360 Ïîïðîøàéíè÷åñòâî x3')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('zs', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 600 Çëîóïîòðåáëåíèå ñèìâîëàìè")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('zsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 600 Çëîóïîòðåáëåíèå ñèìâîëàìè')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rekl', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 1000 Ðåêëàìà")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('reklf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 1000 Ðåêëàìà')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rz', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 5000 Ðîçæèã")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 5000 Ðîçæèã')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('ia', function(param) 
	if #param ~= 0 then
		sampSendChat('/mute ' .. param .. " 2500 Âûäà÷à ñåáÿ çà àäìèíèñòðàòîðà")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('iaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/muteoff ' .. param .. ' 2500 Âûäà÷à ñåáÿ çà àäìèíèñòðàòîðà')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
----======================= Èñêëþ÷èòåëüíî äëÿ ÌÓÒÎÂ ÐÅÏÎÐÒÀ ===============------------------
sampRegisterChatCommand('oft', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('oftf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Offtop in /report")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('oft2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Offtop in /report x2")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('oft3', function(param) 
	if param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Offtop in /report x3")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('cp', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('cpf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Caps in /report")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('cp2', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 240 Caps in /report x2")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('cp3', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 360 Caps in /report x3")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('roa', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 2500 Îñêîðáëåíèå àäìèíèñòðàöèè")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('roaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 2500 Îñêîðáëåíèå àäìèíèñòðàöèè")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('ror', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rorf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rzs', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 600 Çëîóïîòðåáëåíèå ñèìâîëàìè")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rzsf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 600 Çëîóïîòðåáëåíèå ñèìâîëàìè")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rrz', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 5000 Ðîçæèã")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rrzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 5000 Ðîçæèã")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rpo', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 120 Ïîïðîøàéíè÷åñòâî")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rpof', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 120 Ïîïðîøàéíè÷åñòâî")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rm', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 300 Ìàò â /report")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 300 Íåöåíçóðíàÿ ëåêñèêà")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rok', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmute ' .. param .. " 400 Îñêîðáëåíèå â /report")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('rokf', function(param) 
	if #param ~= 0 then
		sampSendChat('/rmuteoff ' .. param .. " 400 Îñêîðáëåíèå â /report")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
----======================= Èñêëþ÷èòåëüíî äëÿ ÄÆÀÉËÀ ===============------------------
sampRegisterChatCommand('dz', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 ÄÌ/ÄÁ â çåëåíîé çîíå')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('dzf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 ÄÌ/ÄÁ â çåëåíîé çîíå')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('zv', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. " 3000 Çëîóïîòðåáëåíèå VIP'îì")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('dmp', function(param)
	if #param ~= 0 then
		sampSendChat("/jail " .. param .. " 3000 Ñåðüåçíàÿ ïîìåõà íà ìåðîïðèÿòèè")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('zvf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 3000 Çëîóïîòðåáëåíèå VIP'oì")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('sk', function(param)
	if #param ~= 0 then 
		sampSendChat('/jail ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('skf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 Spawn Kill')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('dk', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 ÄÁ Êîâø â çåëåíîé çîíå')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('dkf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 ÄÁ Êîâø â çåëåíîé çîíå')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('td', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 car in /trade')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('tdf', function(param) 
	if #param ~= 0 then
		sampSendChat("/jailakk " .. param .. " 300 Car in /trade")
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('jcb', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 3000 ÷èòåðñêèé ñêðèïò/ÏÎ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('jcbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 3000 ÷èòåðñêèé ñêðèïò/ÏÎ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('jm', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 Íàðóøåíèå ïðàâèë ÌÏ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('jmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 Íàðóøåíèå ïðàâèë ÌÏ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('jc', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 900 ÷èòåðñêèé ñêðèïò/ÏÎ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('jcf', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 900 ÷èòåðñêèé ñêðèïò/ÏÎ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('baguse', function(param) 
	if #param ~= 0 then
		sampSendChat('/jail ' .. param .. ' 300 Áàãîþç')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('bagusef', function(param) 
	if #param ~= 0 then
		sampSendChat('/jailakk ' .. param .. ' 300 Áàãîþç')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
----======================= Èñêëþ÷èòåëüíî äëÿ ÁÀÍÀ ===============------------------
sampRegisterChatCommand('bosk', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 999 Îñêîðáëåíèå ïðîåêòà')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('boskf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 Îñêîðáëåíèå ïðîåêòà')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('reklama', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 999 Ðåêëàìà')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('reklamaf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 999 Ðåêëàìà')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('obm', function(param) 
	if #param ~= 0 then
		sampSendChat('/iban ' .. param .. ' 30 Îáìàí/Ðàçâîä')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('obmf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 30 Îáìàí/Ðàçâîä')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('nmb', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 Íåàäåêâàòíîå ïîâåäåíèå')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('nmbf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 3 Íåàäåêâàòíîå ïîâåäåíèå')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('ch', function(param) 
	if #param ~= 0 then
		sampSendChat('/ans ' .. param .. ' Óâàæàåìûé èãðîê, Âû íàêàçàíû çà íàðóøåíèå ïðàâèë ñåðâåðà.')
		sampSendChat('/ans ' .. param .. ' Åñëè Âû íå ñîãëàñíû ñ âûäàííûì íàêàçàíèåì, íàïèøèòå æàëîáó íà https://forumrds.ru')
		sampSendChat('/iban ' .. param .. ' 7 ÷èòåðñêèé ñêðèïò/ÏÎ')
		if tonumber(playerrecon) == tonumber(param) then
			four_window_state.v = false
			lua_thread.create(function()
				wait(500)
				sampSendInputChat('/keysync off')
			end)
		end
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('chf', function(param) 
	if #param ~= 0 then
		sampSendChat('/banoff ' .. param .. ' 7 ÷èòåðñêèé ñêðèïò/ÏÎ')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('oskhelper', function(param) 
	if #param ~= 0 then
		sampSendChat('/ban ' .. param .. ' 3 Íàðóøåíèå ïðàâèë /helper')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
----======================= Èñêëþ÷èòåëüíî äëÿ ÊÈÊÎÂ ===============------------------
sampRegisterChatCommand('cafk', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' AFK in /arena') 
		four_window_state.v = false
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('kk1', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' Ñìåíèòå íèê 1/3') 
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('kk2', function(param) 
	if #param ~= 0 then
		sampSendChat('/kick ' .. param .. ' Ñìåíèòå íèê 2/3')
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)
sampRegisterChatCommand('kk3', function(param)
	if #param ~= 0 then 
		sampSendChat('/ban ' .. param .. ' 7 Ñìåíèòå íèê 3/3') 
	else
		sampAddChatMessage(tag .. 'Âû íå óêàçàëè çíà÷åíèå.')
	end
end)


function style(id) -- ÒÅÌÛ
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    if id == 0 then -- Òåìíî-Ñèíÿÿ
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
    elseif id == 1 then -- Êðàñíàÿ
		colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 0.78)
		colors[clr.TextDisabled]         = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
		colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]              = ImVec4(0.53, 0.20, 0.16, 0.65)
		colors[clr.TitleBgActive]        = ImVec4(0.56, 0.14, 0.14, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
		colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.CheckMark]            = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.64, 0.14, 0.14, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(1.00, 0.37, 0.37, 1.00)
		colors[clr.Button]               = ImVec4(0.59, 0.13, 0.13, 1.00)
		colors[clr.ButtonHovered]        = ImVec4(0.69, 0.15, 0.15, 1.00)
		colors[clr.ButtonActive]         = ImVec4(0.67, 0.13, 0.07, 1.00)
		colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
		colors[clr.HeaderHovered]        = ImVec4(0.98, 0.38, 0.26, 0.80)
		colors[clr.HeaderActive]         = ImVec4(0.98, 0.26, 0.26, 1.00)
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
    elseif id == 2 then -- çåëåíàÿ òåìà
		colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 0.78)
		colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.25, 0.29, 0.20, 1.00)
		colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
		colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]              = ImVec4(0.09, 0.12, 0.14, 0.65)
		colors[clr.TitleBgActive]        = ImVec4(0.35, 0.58, 0.06, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
		colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.CheckMark]            = ImVec4(0.72, 1.00, 0.28, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.43, 0.57, 0.05, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(0.55, 0.67, 0.15, 1.00)
		colors[clr.Button]               = ImVec4(0.40, 0.57, 0.01, 1.00)
		colors[clr.ButtonHovered]        = ImVec4(0.45, 0.69, 0.07, 1.00)
		colors[clr.ButtonActive]         = ImVec4(0.27, 0.50, 0.00, 1.00)
		colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
		colors[clr.HeaderHovered]        = ImVec4(0.72, 0.98, 0.26, 0.80)
		colors[clr.HeaderActive]         = ImVec4(0.74, 0.98, 0.26, 1.00)
		colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
		colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
		colors[clr.ResizeGrip]           = ImVec4(0.68, 0.98, 0.26, 0.25)
		colors[clr.ResizeGripHovered]    = ImVec4(0.72, 0.98, 0.26, 0.67)
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
    elseif id == 3 then -- áèðþçîâàÿ
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
		colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.30)
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
	elseif id == 4 then -- Âèøíåâàÿ òåìà
		colors[clr.WindowBg]              = ImVec4(0, 0, 0, 1);
		colors[clr.ChildWindowBg]         = ImVec4(0, 0, 0, 1);
		colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
		colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
		colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
		colors[clr.FrameBg]               = ImVec4(0.12, 0.12, 0.12, 0.94);
		colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
		colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
		colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
		colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
		colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
		colors[clr.ScrollbarBg]           = ImVec4(0.04, 0.04, 0.04, 1.00);
		colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
		colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
		colors[clr.SliderGrab]            = ImVec4(0.28, 0.28, 0.28, 1.00);
		colors[clr.SliderGrabActive]      = ImVec4(0.35, 0.35, 0.35, 1.00);
		colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
		colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
		colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
		colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
		colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
		colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
		colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
		colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
		colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
		colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
		colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
		colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
		colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
		colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
    elseif id == 5 then -- ãîëóáàÿ òåìà
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
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
		colors[clr.Button]                 = ImVec4(0.41, 0.55, 0.78, 1.00)
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



--------- ÄËß ID Â ÊÈËË ×ÀÒÅ ----------- (ÍÈÆÅ ÁÎËÜØÅ ÍÈ×ÅÃÎ ÍÅÒ.)
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
