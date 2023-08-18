require 'lib.moonloader'
require 'lib.sampfuncs'
script_name 'RDS Tools' 
script_author 'Neon4ik'
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
local version = 0.5
local imgui = require 'imgui' 
local imadd = require 'imgui_addons'
local sampev = require 'lib.samp.events'
local mimgui = require "mimgui"
local se = require "samp.events"
local inicfg = require 'inicfg'
local directIni = 'RDSTools.ini'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local ev = require 'lib.samp.events'
local key = require 'vkeys'
local rkeys = require "rkeys"
local fa = require 'faIcons'
local ffi = require "ffi"
local mem = require "memory"
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local path_chatclear = getWorkingDirectory() .. "\\resource\\cleaner.lua" -- подгрузка скрипта для очистки чата (по желанию)
local path_fastspawn = getWorkingDirectory() .. "\\resource\\FastSpawn.lua" -- подгрузка скрипта для быстрого спавна (по желанию)
local path_trassera = getWorkingDirectory() .. "\\resource\\trassera.lua" -- подгрузка скрипта для трассеров (по желанию)
local notify = import '\\resource\\lib_imgui_notf.lua' -- подгрузка уведомлений для репорта

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
		check_weapon_hack = false,
		chatclear = true,
		FLD = false,
		prfrandom = false,
		form = true,
		trassera = true,
		autoal = false,
		wallhack = true,
		fastspawn = false,
		autoonline = false,
		inputhelper = true,
		automute = false,
		opreport = true,
		prefixma = '2E8B57',
		prefixa = '87CEEB',
		prefixsa = 'FF4500',
		texts = '+',
		prefixnick = 'Главный-Администратор',
		stylecolor = '{FFFFFF}',
		stylecolorform = '{FF0000}',
		doptext = true,
		mytextreport = ' // Приятной игры на RDS <3',
		customposx = false,
		customposy = false,
		item = 4,
		keysync = true
	},
	script = {
		version = 0.5
	},
	osk = {'додик','долбаеб','ебанат','хуеглот','долбаёб','далбаеб','далбаёб','утырок','урод','чмырь','урод','пидор','пидорас', 'еблоид', 'суки', 'додик', 'крыса', 'нищ', 'нищеброд', 'сыкло', 'ссыкло', 'сикло', 'ебанат', 'даун', 'дурак', 'дебил'},
	mat = {'пиздец', 'ебануться','ахуеть','вахуи', 'пизда', 'бля', 'blya', 'ебло', 'ебал', 'сука', 'syka', 'suka', 'cerf', 'пизда', 'пиздец', 'ахуеть', 'нахуй', 'ебать', 'ебаь', 'дохуя', 'хуево', 'хуйня', 'пиздой', 'хуевая', 'охуеть', 'ахуенно', 'ахуено', 'охуено'}
}, directIni)
inicfg.save(cfg,directIni)

info = 'Добавил автомут на Мат и Оск из слов добавленных в список, /add_mat - добавить, /del_mat - удалить, /add_osk - добавить /del_osk - удалить\nДобавлено кастом рекон меню, Q - выйти из рекона, R - обновить.\nПофикшена ошибка в оповещении репортов, когда их было более 3-ех, он писал "на сервере 0 репортов".'

local target = -1
local keys = {
	["onfoot"] = {},
	["vehicle"] = {}
}


local font = renderCreateFont('TimesNewRoman', 12, 5) -- таймер для форм
local st = {
    bool = false,
    timer = -1,
    id = -1,
}
spisok = {
	'ban',
	'jail',
	'kick',
	'mute',
	'spawncars',
	'setweap',
	'mess',
	'aspawn',
	'tweap',
	'delcarall',
	'vvig'
}

local fontsize = nil
function imgui.BeforeDrawFrame()
    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 17, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
end


local string_flood = ""
local string_number_max = 4 -- anti flood
local msgs = {chat = {}}
local string_time = 30

require 'lib.sampfuncs'
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

local checked_test = imgui.ImBool(cfg.settings.check_weapon_hack)
local checked_test2 = imgui.ImBool(cfg.settings.keysync)
local checked_test3 = imgui.ImBool(cfg.settings.autoonline)
local checked_test4 = imgui.ImBool(cfg.settings.prfrandom)
local checked_test5 = imgui.ImBool(cfg.settings.chatclear)
local checked_test6 = imgui.ImBool(cfg.settings.fastspawn)
local checked_test7 = imgui.ImBool(cfg.settings.FLD)
local checked_test8 = imgui.ImBool(cfg.settings.opreport)
local checked_test9 = imgui.ImBool(cfg.settings.automute)
local checked_test10 = imgui.ImBool(cfg.settings.autoal)
local checked_test11 = imgui.ImBool(cfg.settings.trassera)
local checked_test12 = imgui.ImBool(cfg.settings.form)
local checked_test13 = imgui.ImBool(cfg.settings.inputhelper)
local checked_test14 = imgui.ImBool(cfg.settings.wallhack)
local checked_test15 = imgui.ImBool(cfg.settings.doptext)
local sw, sh = getScreenResolution()
local text_buffer = imgui.ImBuffer(256)
local main_window_state = imgui.ImBool(false)
local secondary_window_state = imgui.ImBool(false)
local tree_window_state = imgui.ImBool(false)
local tree_window_state = imgui.ImBool(false)
local four_window_state = imgui.ImBool(false)
local fourtwo_window_state = imgui.ImBool(false)
local item = imgui.ImInt(cfg.settings.item)
local five_window_state = imgui.ImBool(false)
local ban_window_state = imgui.ImBool(false)
local mute_window_state = imgui.ImBool(false)
local jail_window_state = imgui.ImBool(false)
local kick_window_state = imgui.ImBool(false)

local act = false -- защита от работы в афк

function main()
	while not isSampAvailable() do wait(0) end
	if item.v == 0 then
		function theme()
			imgui.SwitchContext()
			local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col
			local ImVec4 = imgui.ImVec4
			
			style.WindowRounding = 3
			style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
			style.ChildWindowRounding = 3
			style.FrameRounding = 3
			style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
			style.ScrollbarSize = 13.0
			style.ScrollbarRounding = 1
			style.GrabMinSize = 8.0
			style.GrabRounding = 3
			style.WindowPadding = imgui.ImVec2(4.0, 4.0)
			style.FramePadding = imgui.ImVec2(2.5, 3.5)
			style.ButtonTextAlign = imgui.ImVec2(0.02, 0.4)   
			
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
		end
		theme()
	end
	if item.v == 1 then
		function black_grey()
			imgui.SwitchContext()
			local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col
			local ImVec4 = imgui.ImVec4
			local ImVec2 = imgui.ImVec2
		  
			style.FramePadding = ImVec2(4.0, 2.0)
			style.ItemSpacing = ImVec2(8.0, 2.0)
			style.WindowRounding = 1.0
			style.FrameRounding = 1.0
			style.ScrollbarRounding = 1.0
			style.GrabRounding = 1.0
		  
			colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 0.95)
			colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
			colors[clr.WindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
			colors[clr.ChildWindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
			colors[clr.PopupBg] = ImVec4(0.05, 0.05, 0.05, 0.94)
			colors[clr.Border] = ImVec4(0.53, 0.53, 0.53, 0.46)
			colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg] = ImVec4(0.00, 0.00, 0.00, 0.85)
			colors[clr.FrameBgHovered] = ImVec4(0.22, 0.22, 0.22, 0.40)
			colors[clr.FrameBgActive] = ImVec4(0.16, 0.16, 0.16, 0.53)
			colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.00, 1.00)
			colors[clr.TitleBgActive] = ImVec4(0.00, 0.00, 0.00, 1.00)
			colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
			colors[clr.MenuBarBg] = ImVec4(0.12, 0.12, 0.12, 1.00)
			colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
			colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
			colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
			colors[clr.ScrollbarGrabActive] = ImVec4(0.48, 0.48, 0.48, 1.00)
			colors[clr.ComboBg] = ImVec4(0.24, 0.24, 0.24, 0.99)
			colors[clr.CheckMark] = ImVec4(0.79, 0.79, 0.79, 1.00)
			colors[clr.SliderGrab] = ImVec4(0.48, 0.47, 0.47, 0.91)
			colors[clr.SliderGrabActive] = ImVec4(0.56, 0.55, 0.55, 0.62)
			colors[clr.Button] = ImVec4(0.50, 0.50, 0.50, 0.63)
			colors[clr.ButtonHovered] = ImVec4(0.67, 0.67, 0.68, 0.63)
			colors[clr.ButtonActive] = ImVec4(0.26, 0.26, 0.26, 0.63)
			colors[clr.Header] = ImVec4(0.54, 0.54, 0.54, 0.58)
			colors[clr.HeaderHovered] = ImVec4(0.64, 0.65, 0.65, 0.80)
			colors[clr.HeaderActive] = ImVec4(0.25, 0.25, 0.25, 0.80)
			colors[clr.Separator] = ImVec4(0.58, 0.58, 0.58, 0.50)
			colors[clr.SeparatorHovered] = ImVec4(0.81, 0.81, 0.81, 0.64)
			colors[clr.SeparatorActive] = ImVec4(0.81, 0.81, 0.81, 0.64)
			colors[clr.ResizeGrip] = ImVec4(0.87, 0.87, 0.87, 0.53)
			colors[clr.ResizeGripHovered] = ImVec4(0.87, 0.87, 0.87, 0.74)
			colors[clr.ResizeGripActive] = ImVec4(0.87, 0.87, 0.87, 0.74)
			colors[clr.CloseButton] = ImVec4(0.45, 0.45, 0.45, 0.50)
			colors[clr.CloseButtonHovered] = ImVec4(0.70, 0.70, 0.90, 0.60)
			colors[clr.CloseButtonActive] = ImVec4(0.70, 0.70, 0.70, 1.00)
			colors[clr.PlotLines] = ImVec4(0.68, 0.68, 0.68, 1.00)
			colors[clr.PlotLinesHovered] = ImVec4(0.68, 0.68, 0.68, 1.00)
			colors[clr.PlotHistogram] = ImVec4(0.90, 0.77, 0.33, 1.00)
			colors[clr.PlotHistogramHovered] = ImVec4(0.87, 0.55, 0.08, 1.00)
			colors[clr.TextSelectedBg] = ImVec4(0.47, 0.60, 0.76, 0.47)
			colors[clr.ModalWindowDarkening] = ImVec4(0.88, 0.88, 0.88, 0.35)
		end
		black_grey()
	end
	if item.v == 2 then
		function theme()
			imgui.SwitchContext()
			local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col
			local ImVec4 = imgui.ImVec4
			local ImVec2 = imgui.ImVec2
		
			style.WindowPadding = imgui.ImVec2(8, 8)
			style.WindowRounding = 6
			style.ChildWindowRounding = 5
			style.FramePadding = imgui.ImVec2(5, 3)
			style.FrameRounding = 3.0
			style.ItemSpacing = imgui.ImVec2(5, 4)
			style.ItemInnerSpacing = imgui.ImVec2(4, 4)
			style.IndentSpacing = 21
			style.ScrollbarSize = 10.0
			style.ScrollbarRounding = 13
			style.GrabMinSize = 8
			style.GrabRounding = 1
			style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
			style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		
			colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
			colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
			colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
			colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
			colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
			colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
			colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
			colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
			colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
			colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
			colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
			colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
			colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
			colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
			colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
			colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
			colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
			colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
			colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
			colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
			colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
			colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
			colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
			colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
			colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
			colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
			colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
			colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
			colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
			colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
			colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
			colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
			colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
			colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
		end
		theme()
	end
	if item.v == 3 then
		function style() -- стиль имгуи
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
	end
	if item.v == 4 then
		function apply_custom_style()
			imgui.SwitchContext()
			local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col
			local ImVec4 = imgui.ImVec4
			local ImVec2 = imgui.ImVec2
		 
			 style.WindowPadding = ImVec2(15, 15)
			 style.WindowRounding = 15.0
			 style.FramePadding = ImVec2(5, 5)
			 style.ItemSpacing = ImVec2(12, 8)
			 style.ItemInnerSpacing = ImVec2(8, 6)
			 style.IndentSpacing = 25.0
			 style.ScrollbarSize = 15.0
			 style.ScrollbarRounding = 15.0
			 style.GrabMinSize = 15.0
			 style.GrabRounding = 7.0
			 style.ChildWindowRounding = 8.0
			 style.FrameRounding = 6.0
		   
		 
			   colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
			   colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
			   colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
			   colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
			   colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
			   colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
			   colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
			   colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
			   colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
			   colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
			   colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
			   colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
			   colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
			   colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
			   colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
			   colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
			   colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
			   colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
			   colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
			   colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
			   colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
			   colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
			   colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
			   colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
			   colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
			   colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
			   colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
			   colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
			   colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
			   colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
			   colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
			   colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
			   colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
			   colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
			   colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
			   colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
			   colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
			   colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
			   colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
			   colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
		 end
		 apply_custom_style()
	end
	if item.v == 5 then
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		local ImVec2 = imgui.ImVec2

		style.WindowPadding = ImVec2(15, 15)
		style.WindowRounding = 6.0
		style.FramePadding = ImVec2(5, 5)
		style.FrameRounding = 4.0
		style.ItemSpacing = ImVec2(12, 8)
		style.ItemInnerSpacing = ImVec2(8, 6)
		style.IndentSpacing = 25.0
		style.ScrollbarSize = 15.0
		style.ScrollbarRounding = 9.0
		style.GrabMinSize = 5.0
		style.GrabRounding = 3.0

		colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
		colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
		colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
		colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
		colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
		colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
		colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
		colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
		colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
	end
	func = lua_thread.create_suspended(ao)
	func:run()
	func = lua_thread.create_suspended(timer)
	func:run()
	update_state = false
	local dlstatus = require('moonloader').download_status
	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.ini" -- Ссылка на конфиг
	local update_path = getWorkingDirectory() .. "/RDSTools.ini" -- и тут ту же самую ссылку
	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.lua" -- Ссылка на сам файл
	local script_path = thisScript().path
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            RDSTools = inicfg.load(nil, update_path)
            if tonumber(RDSTools.script.version) > version then
                update_state = true
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Найдено обновление, проверить что добавлено командой /check_update, загружаю ... ', -1)
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Найдено обновление, проверить что добавлено командой /check_update, загружаю ... ', -1)
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Найдено обновление, проверить что добавлено командой /check_update, загружаю ... ', -1)
			else
				sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}был успешно загружен, активация: {808080}F3', -1)
			end
            os.remove(update_path)
        end
    end)
	imgui.Process = false
	inputHelpText = renderCreateFont("Arial", 9, FCR_BORDER + FCR_BOLD) -- шрифт инпут хелпера
	lua_thread.create(inputChat)

	if cfg.settings.chatclear then
		local chatclear = import(path_chatclear) -- подгрузка чистильщика чата
	end
	if cfg.settings.fastspawn and not update_state then
		local fastspawn = import(path_fastspawn) -- подгрузка скрипта фастспавн
	end
	if cfg.settings.trassera then
		local trassera = import(path_trassera) -- подгрузка трассеров
	end
	if cfg.settings.wallhack then
		for i = 0, sampGetMaxPlayerId() do
			if sampIsPlayerConnected(i) then
				local result, cped = sampGetCharHandleBySampPlayerId(i)
				local color = sampGetPlayerColor(i)
				local aa, rr, gg, bb = explode_argb(color)
				local color = join_argb(255, rr, gg, bb)
				local pStSet = sampGetServerSettingsPtr();
				NTdist = mem.getfloat(pStSet + 39)
				NTwalls = mem.getint8(pStSet + 47)
				NTshow = mem.getint8(pStSet + 56)
				mem.setfloat(pStSet + 39, 1488.0)
				mem.setint8(pStSet + 47, 0)
				mem.setint8(pStSet + 56, 1)
				nameTag = true
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
	if defaultState and not nameTag then nameTagOn() end
	while true do
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					wait(10000)
                    sampShowDialog(1000, "xX RDS Tools Xx", '{FFFFFF}Была найдена новая версия - ' .. RDSTools.script.version .. '\n{FFFFFF}В ней добавлено ' .. RDSTools.script.info, "Спасибо", "", 0)
					showCursor(false,false)
                    thisScript():reload()
                end
            end)
            break
        end
		if isKeyJustPressed(VK_F3) and not sampIsDialogActive() then  -- кнопка активации окна RDS Tools
			main_window_state.v = not main_window_state.v
			imgui.Process = true
			showCursor(true,false)
		end
		if isKeyJustPressed(VK_F2) then
			if act then
				cfg.settings.check_weapon_hack = checkweap
				cfg.settings.FLD = fld
				cfg.settings.forms = forms
				cfg.settings.autoal = pleaseal
				cfg.settings.automute = checkmat
				cfg.settings.opreport = opreport
				act = false
				sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}Все значения возвращены в прежние позиции.', -1)
			else
				checkweap = cfg.settings.check_weapon_hack
				fld = cfg.settings.FLD
				forms = cfg.settings.forms
				pleaseal = cfg.settings.autoal
				checkmat = cfg.settings.automute
				opreport = cfg.settings.opreport
				cfg.settings.check_weapon_hack = false
				cfg.settings.FLD = false
				cfg.settings.forms = false
				cfg.settings.autoal = false
				cfg.settings.automute = false
				cfg.settings.opreport = false
				act = true
				sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}Блокирую работу скриптов, можете отходить в AFK', -1)
			end
		end
		while sett do
			wait(0)
			if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampSendChat('/a ' .. cfg.settings.texts)
				if not styleform then
					sampSendChat(forma .. ' // ' .. nicknameform, -1)
					sett = false
					styleform = false
				else
					sampSendChat(forma, -1)
					sett = false
				end
			end
			if isKeyDown(VK_J) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sett = false
				styleform = false
				sampAddChatMessage('{C0C0C0}AForm: {FAEBD7}форма отклонена', -1)
			end	
		end
	end
end

function color()
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


function ao() -- автоонлайн
	if cfg.settings.autoonline then
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
end

function cyrillic(text)
	local convtbl = {[230]=155,[231]=159,[247]=164,[234]=107,[250]=144,[251]=168,[254]=171,[253]=170,[255]=172,[224]=97,[240]=112,[241]=99,[226]=162,[228]=154,[225]=151,[227]=153,[248]=165,[243]=121,[184]=101,[235]=158,[238]=111,[245]=120,[233]=157,[242]=166,[239]=163,[244]=63,[237]=174,[229]=101,[246]=36,[236]=175,[232]=156,[249]=161,[252]=169,[215]=141,[202]=75,[204]=77,[220]=146,[221]=147,[222]=148,[192]=65,[193]=128,[209]=67,[194]=139,[195]=130,[197]=69,[206]=79,[213]=88,[168]=69,[223]=149,[207]=140,[203]=135,[201]=133,[199]=136,[196]=131,[208]=80,[200]=133,[198]=132,[210]=143,[211]=89,[216]=142,[212]=129,[214]=137,[205]=72,[217]=138,[218]=167,[219]=145}
	local result = {}
	for i = 1, #text do
		local c = text:byte(i)
		result[i] = string.char(convtbl[c] or c)
	end
	return table.concat(result)
end
local sw, sh = getScreenResolution() -- узнаем разрешение экрана
function timer() -- таймер для автоформ
	while true do
		wait(0)
		if st.bool and st.timer ~= -1 and sett then
            timer = os.clock()-st.timer
            renderFontDrawText(font, cfg.settings.stylecolor .. 'Нажми U чтобы принять или J чтобы отклонить\nФорма: ' .. cfg.settings.stylecolorform .. forma .. cfg.settings.stylecolor .. '\nВремени на раздумья 8 сек, прошло: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
            if timer>8 then
                sett = false
				styleform = false
                st.bool = false
                st.timer = -1
            end
        end
	end
end
function sampev.onServerMessage(color, text)
	if cfg.settings.form then
		if text:match('[A-%d%d]') and text:match('.Администратор.') then
			d = string.len(text)
			for k,v in pairs(spisok) do
				if text:find(v) then
					local id = text:match('%[(%d+)%]')
					if id then
						lua_thread.create(function()
						wait(200)
						name = sampGetPlayerNickname(tostring(id))
						nicknameform = name
						end)
						while d ~= 0 do
							text = string.sub(text, 2)
							rev = string.reverse(text)
							don = string.sub(rev, -1)
							d = d - 1
							if don == '/' then
								forma = text
								d = 0
								sett = true
								st.bool = true
								st.timer = os.clock()
								sampAddChatMessage('{C0C0C0}AForm: {FAEBD7}(U - Да), (J - Пропустить)')
								if (text.sub(text, 2)):find('/') and not text:find('iunban') then
									styleform = true
								end
							end
						end
					end
				end
			end
		end
	end
	if cfg.settings.prfrandom then
		_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		nick = sampGetPlayerNickname(id)
		if text:find("Администратор " .. nick) and text:find("авторизовался в админ") then
			local ip = sampGetCurrentServerAddress()
			local _, id = sampGetPlayerIdByCharHandle(playerPed)
			local mcolor = ""
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
			sampSendChat("/prefix " .. id .. ' ' .. cfg.settings.prefixnick .. ' ' .. tostring(mcolor))
		end
	end
	if cfg.settings.check_weapon_hack then
		local str = {}
		str = string.split(text, " ")
		if str[1] == "<AC-WARNING>" then  
			str[7] = str[7]:gsub("{......}", "")
			str[8] = str[8]:gsub("{......}", "")
			if string.find(str[7], "Weapon") and string.find(str[8], "hack") then 
				str[2] = str[2]:gsub("{......}", "")
				local nick, id = string.match(str[2], "(.+)%[(.+)%]")
				sampSendChat("/iwep " .. id)
				sampAddChatMessage("Пробиваю: " .. nick .. " [" .. id .. "]", 0xADFF2F)
			end
		end 
	end
	if cfg.settings.autoal then
		if text:match("не авторизовался как администратор уже") then
			poiskid = text:match('(%d+)')
			--[A] Lawrence_Herson(29) не авторизовался как администратор уже 1 минут(ы)
			if poiskid then
				lua_thread.create(function()
				wait(200)
				nameadm = sampGetPlayerNickname(tostring(poiskid))
				sampSendChat('/ans ' .. poiskid .. ' Здравствуйте, ' .. nameadm .. ', вы забыли ввести /alogin, осуществите это немедленно.')
				end)
			end
		end
	end
	if cfg.settings.FLD then
		local _, check_flood_id, _, check_flood = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")
		local _, check_floodv_id, check_floodv = string.match(text, "[VIP чат] (.+)%[(%d+)%]: (.+)")
		if check_floodv ~= nil and check_floodv_id ~= nil and not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then  
			string_flood = check_floodv
			local playername,playerid, msg = text:match("[VIP чат] (.+)%[(%d+)%]: (.+)")
			if msgs.chat[playername] and msgs.chat[playername][1] then
				if (#msgs.chat[playername]+1 >= string_number_max) then
					while (#msgs.chat[playername] > string_number_max) do
						table.remove(msgs.chat[playername],1)
					end
					if msgs.chat[playername][#msgs.chat[playername]].id == playerid and msgs.chat[playername][#msgs.chat[playername]].msg == msg then
						msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
						if msgs.chat[playername][#msgs.chat[playername]].time and math.ceil(msgs.chat[playername][#msgs.chat[playername]].time - msgs.chat[playername][1].time) < string_time then
							if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
								detectedFlood(playername,playerid,msg,math.ceil(msgs.chat[playername][#msgs.chat[playername]].time - msgs.chat[playername][1].time),#msgs.chat[playername],n)
							end
							for i = 1,string_number_max,1 do
								table.remove(msgs.chat[playername],1)
							end
						end
					else
						for i = 1,string_number_max,1 do
							table.remove(msgs.chat[playername],1)
						end
					end
				else
					if msgs.chat[playername][#msgs.chat[playername]].id == playerid and msgs.chat[playername][#msgs.chat[playername]].msg == msg then
						msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
					else
						for i = 1,string_number_max,1 do
							table.remove(msgs.chat[playername],1)
						end
					end
				end
			else
				msgs.chat[playername] = {}
				msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
				if string_number_max <= 1 then
					for i = 1,cfg[n].maxmsg,1 do
						table.remove(msgs.chat[playername],1)
					end
				end
			end
		end
		if check_flood ~= nil and check_flood_id ~= nil and not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then  
			string_flood = check_flood
			local playername,playerid, _, msg = text:match("(.+)%((.+)%): {(.+)}(.+)")
			if msgs.chat[playername] and msgs.chat[playername][1] then
				if (#msgs.chat[playername]+1 >= string_number_max) then
					while (#msgs.chat[playername] > string_number_max) do
						table.remove(msgs.chat[playername],1)
					end
					if msgs.chat[playername][#msgs.chat[playername]].id == playerid and msgs.chat[playername][#msgs.chat[playername]].msg == msg then
						msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
						if msgs.chat[playername][#msgs.chat[playername]].time and math.ceil(msgs.chat[playername][#msgs.chat[playername]].time - msgs.chat[playername][1].time) < string_time then
							if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
								sampAddChatMessage("[FLD] " .. text, -1)
								detectedFlood(playername,playerid,msg,math.ceil(msgs.chat[playername][#msgs.chat[playername]].time - msgs.chat[playername][1].time),#msgs.chat[playername],n)
							end
							for i = 1,string_number_max,1 do
								table.remove(msgs.chat[playername],1)
							end
						end
					else
						for i = 1,string_number_max,1 do
							table.remove(msgs.chat[playername],1)
						end
					end
				else
					if msgs.chat[playername][#msgs.chat[playername]].id == playerid and msgs.chat[playername][#msgs.chat[playername]].msg == msg then
						msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
					else
						for i = 1,string_number_max,1 do
							table.remove(msgs.chat[playername],1)
						end
					end
				end
			else
				msgs.chat[playername] = {}
				msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
				if string_number_max <= 1 then
					for i = 1,cfg[n].maxmsg,1 do
						table.remove(msgs.chat[playername],1)
					end
				end
			end
		end
	end
	if cfg.settings.automute then
		for k,v in ipairs(cfg.osk) do
			if text:match(v) and not text:match('%A%A' .. v) and not text:match('[A-%d]') then
				local oskid = tonumber(text:match('%((%d+)%)'))
				sampAddChatMessage('{00FF00}[АВТОМУТ]{DCDCDC} ' .. text .. ' {00FF00}[АВТОМУТ]', -1)
				lua_thread.create(function()
					while sampIsDialogActive() do
						wait(20)
					end
				end)
				if oskid then
					sampSendChat('/mute ' .. oskid .. ' 400 Оскорбление')
				end
				return false
			end
		end
		for k,v in pairs(cfg.mat) do
			if text:match(v) and not text:match('%A%A' .. v) and not text:match('[A-%d]')  then
				local matid = tonumber(text:match('%((%d+)%)'))
				sampAddChatMessage('{00FF00}[АВТОМУТ]{DCDCDC} ' .. text .. ' {00FF00}[АВТОМУТ]', -1)
				lua_thread.create(function()
					while sampIsDialogActive() do
						wait(20)
					end
				end)
				sampSendChat('/mute ' .. matid .. ' 300 Нецензурная лексика')
				return false
			end
		end
	end
	if cfg.settings.opreport then
		if text:match('Жалоба #%d | {AFAFAF}') then
			notify.addNotify('Оповещение', "Пришёл новый репорт\nЗаймитесь делом.", 2, 1, 4)
		end
		if text:match('Жалоба #3 | {AFAFAF}') or text:match('Жалоба #4 | {AFAFAF}') or text:match('Жалоба #5 | {AFAFAF}') then
			notify.addNotify('Оповещение', 'НА СЕРВЕРЕ БОЛЬШОЕ КОЛИЧЕСТВО НЕОТВЕЧЕННЫХ РЕПОРТОВ\nСРОЧНО РАЗБЕРИТЕСЬ!', 2, 1, 8)
		end
	end
end

function detectedFlood(name,id,msg,time,count,number)
	lua_thread.create(function()
		if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
			sampAddChatMessage("{E9967A}Флуд в чате. Отправлено "..count.." текста, за "..time.." секунд из ".. string_time .. " разрешенных!", -1)
			sampAddChatMessage("{FA8072}Текст: "..msg.." | Флудил Игрок: "..sampGetPlayerNickname(tonumber(id)).."["..id.."]", -1)
			wait(100)
			sampSendChat("/mute " .. id .. " 120 Флуд "..count.." сообщения за "..time.."/".. string_time .. "сек.", -1)
		end	
	end)
end	

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
  
function imgui.Link(label, description)
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


function explode_argb(argb)
	local a = bit.band(bit.rshift(argb, 24), 0xFF)
	local r = bit.band(bit.rshift(argb, 16), 0xFF)
	local g = bit.band(bit.rshift(argb, 8), 0xFF)
	local b = bit.band(argb, 0xFF)
	return a, r, g, b
end

function imgui.OnDrawFrame()
	if not main_window_state.v and not secondary_window_state.v and not tree_window_state.v and not four_window_state.v and not fourtwo_window_state.v and not five_window_state.v  then
		imgui.Process = false
		showCursor(false,false)
	end
	if main_window_state.v then -- КНОПКИ ИНТЕРФЕЙСА F3
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('xX   ' .. " RDS Tools " .. '  Xx', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
	-- END В КОНЦЕЕЕЕЕ
		imgui.PushFont(fontsize)
		imgui.Text(u8'Кнопка F2 переводит работу скриптов в афк режим')
		imgui.Separator()
		if imgui.Checkbox(u8"Weapon Hack +", checked_test) then
			cfg.settings.check_weapon_hack = not cfg.settings.check_weapon_hack
			inicfg.save(cfg,directIni)
		end
		imgui.SameLine()
		imgui.SetCursorPosX(175)
		if imgui.Checkbox(u8'Вирт.клавиши игрока', checked_test2) then
			cfg.settings.keysync = not cfg.settings.keysync
			inicfg.save(cfg,directIni)
		end
		if imgui.Checkbox(u8"Рандом префикс", checked_test4) then
			cfg.settings.prfrandom = not cfg.settings.prfrandom
			inicfg.save(cfg,directIni)
		end
			imgui.SameLine()
			imgui.SetCursorPosX(175)
		if imgui.Checkbox(u8"autoonline", checked_test3) then
			cfg.settings.autoonline = not cfg.settings.autoonline
			inicfg.save(cfg, directIni)
			showCursor(false,false)
			thisScript():reload()
		end
		if imgui.Checkbox(u8"Chat Cleaner", checked_test5) then
			cfg.settings.chatclear = not cfg.settings.chatclear
			inicfg.save(cfg, directIni)
			sampShowDialog(1000, "Информация", "Chat Cleaner для выключения требует перезагрузку игры. Активация: /cleaner", "Понял", _)
			showCursor(false,false)
			thisScript():reload()
		end
		imgui.SameLine()
		imgui.SetCursorPosX(175)
		if imgui.Checkbox(u8"Fast Spawn", checked_test6) then
			cfg.settings.fastspawn = not cfg.settings.fastspawn
			inicfg.save(cfg, directIni)
			sampShowDialog(1000, "Информация", "Fast spawn для выключения требует перезагрузку игры. Активация: /fs", "Понял", _)
			showCursor(false,false)
			thisScript():reload()
		end
		if imgui.Checkbox(u8"Flood Detector", checked_test7) then
			cfg.settings.FLD = not cfg.settings.FLD
			inicfg.save(cfg, directIni)
		end
		imgui.SameLine()
		imgui.SetCursorPosX(175)
		if imgui.Checkbox(u8"Слежка за репортами", checked_test8) then
			cfg.settings.opreport = not cfg.settings.opreport
			inicfg.save(cfg, directIni)
		end
		if imgui.Checkbox(u8"Автомут", checked_test9) then
			cfg.settings.automute = not cfg.settings.automute
			inicfg.save(cfg, directIni)
		end
		imgui.SameLine()
		imgui.SetCursorPosX(175)
		if imgui.Checkbox(u8"Просьба войти в /alogin", checked_test10) then
			cfg.settings.autoal = not cfg.settings.autoal
			inicfg.save(cfg,directIni)
		end
		if imgui.Checkbox(u8"Трассера", checked_test11) then
			cfg.settings.trassera = not cfg.settings.trassera
			inicfg.save(cfg,directIni)
			sampShowDialog(1000, "Информация", "Трассерам для выключения требуется перезагрузка игры. Активация: /trassera", "Понял", _)
			showCursor(false,false)
			thisScript():reload()
		end
		imgui.SameLine()
		imgui.SetCursorPosX(175)
		if imgui.Checkbox(u8"Слежка за формами +", checked_test12) then
			cfg.settings.form = not cfg.settings.form
			inicfg.save(cfg,directIni)
			sampAddChatMessage('Помощь в работе с данной функцией - /infoform', 0xCCCC33)
		end
		if imgui.Checkbox(u8"input helper", checked_test13) then
			cfg.settings.inputhelper = not cfg.settings.inputhelper
			inicfg.save(cfg,directIni)
		end
		imgui.SameLine()
		imgui.SetCursorPosX(175)
		if imgui.Checkbox(u8"WallHack", checked_test14) then
			if cfg.settings.wallhack == true then
				cfg.settings.wallhack = not cfg.settings.wallhack
				inicfg.save(cfg,directIni)
				local pStSet = sampGetServerSettingsPtr();
				mem.setfloat(pStSet + 39, 50)
				mem.setint8(pStSet + 47, 0)
				mem.setint8(pStSet + 56, 1)
			else
				cfg.settings.wallhack = not cfg.settings.wallhack
				inicfg.save(cfg,directIni)
				for i = 0, sampGetMaxPlayerId() do
					if sampIsPlayerConnected(i) then
						local result, cped = sampGetCharHandleBySampPlayerId(i)
						local color = sampGetPlayerColor(i)
						local aa, rr, gg, bb = explode_argb(color)
						local color = join_argb(255, rr, gg, bb)
						local pStSet = sampGetServerSettingsPtr();
						NTdist = mem.getfloat(pStSet + 39)
						NTwalls = mem.getint8(pStSet + 47)
						NTshow = mem.getint8(pStSet + 56)
						mem.setfloat(pStSet + 39, 1488.0)
						mem.setint8(pStSet + 47, 0)
						mem.setint8(pStSet + 56, 1)
						nameTag = true
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
		imgui.Separator()
		imgui.SameLine()
		imgui.SetCursorPosX(2)
		if imgui.Button(u8'Быстрые команды', imgui.ImVec2(390, 24)) then
			secondary_window_state.v = true
		end
		imgui.SetCursorPosX(2)
		if imgui.Button(u8'Сохранить новую позицию Custom Recon Menu', imgui.ImVec2(390, 24)) then
			four_window_state.v = false
			fourtwo_window_state.v = true
		end
		imgui.SetCursorPosX(2)
		if imgui.Button(u8'Сохранить новую позицию вирт.клавиш', imgui.ImVec2(390, 24)) then
			five_window_state.v = true
		end
		imgui.PushItemWidth(375) -- ширина
		if imgui.Combo('', item, {u8'Черно-фиолетовая тема', u8'Светло-черная тема', u8'Темно-красная', u8'Синяя тема', u8'Классический черный.', u8'Оранжевая тема'}, 6) then
			if item.v == 0 then
				cfg.settings.item = item.v
				inicfg.save(cfg, directIni)
				function theme()
					imgui.SwitchContext()
					local style = imgui.GetStyle()
					local colors = style.Colors
					local clr = imgui.Col
					local ImVec4 = imgui.ImVec4
					
					style.WindowRounding = 3
					style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
					style.ChildWindowRounding = 3
					style.FrameRounding = 3
					style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
					style.ScrollbarSize = 13.0
					style.ScrollbarRounding = 1
					style.GrabMinSize = 8.0
					style.GrabRounding = 3
					style.WindowPadding = imgui.ImVec2(4.0, 4.0)
					style.FramePadding = imgui.ImVec2(2.5, 3.5)
					style.ButtonTextAlign = imgui.ImVec2(0.02, 0.4)   
					
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
				end
				theme()
			end
			if item.v == 1 then
				cfg.settings.item = item.v
				inicfg.save(cfg, directIni)
				function black_grey()
					imgui.SwitchContext()
					local style = imgui.GetStyle()
					local colors = style.Colors
					local clr = imgui.Col
					local ImVec4 = imgui.ImVec4
					local ImVec2 = imgui.ImVec2
				  
					style.FramePadding = ImVec2(4.0, 2.0)
					style.ItemSpacing = ImVec2(8.0, 2.0)
					style.WindowRounding = 1.0
					style.FrameRounding = 1.0
					style.ScrollbarRounding = 1.0
					style.GrabRounding = 1.0
				  
					colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 0.95)
					colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
					colors[clr.WindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
					colors[clr.ChildWindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
					colors[clr.PopupBg] = ImVec4(0.05, 0.05, 0.05, 0.94)
					colors[clr.Border] = ImVec4(0.53, 0.53, 0.53, 0.46)
					colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
					colors[clr.FrameBg] = ImVec4(0.00, 0.00, 0.00, 0.85)
					colors[clr.FrameBgHovered] = ImVec4(0.22, 0.22, 0.22, 0.40)
					colors[clr.FrameBgActive] = ImVec4(0.16, 0.16, 0.16, 0.53)
					colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.00, 1.00)
					colors[clr.TitleBgActive] = ImVec4(0.00, 0.00, 0.00, 1.00)
					colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
					colors[clr.MenuBarBg] = ImVec4(0.12, 0.12, 0.12, 1.00)
					colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
					colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
					colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
					colors[clr.ScrollbarGrabActive] = ImVec4(0.48, 0.48, 0.48, 1.00)
					colors[clr.ComboBg] = ImVec4(0.24, 0.24, 0.24, 0.99)
					colors[clr.CheckMark] = ImVec4(0.79, 0.79, 0.79, 1.00)
					colors[clr.SliderGrab] = ImVec4(0.48, 0.47, 0.47, 0.91)
					colors[clr.SliderGrabActive] = ImVec4(0.56, 0.55, 0.55, 0.62)
					colors[clr.Button] = ImVec4(0.50, 0.50, 0.50, 0.63)
					colors[clr.ButtonHovered] = ImVec4(0.67, 0.67, 0.68, 0.63)
					colors[clr.ButtonActive] = ImVec4(0.26, 0.26, 0.26, 0.63)
					colors[clr.Header] = ImVec4(0.54, 0.54, 0.54, 0.58)
					colors[clr.HeaderHovered] = ImVec4(0.64, 0.65, 0.65, 0.80)
					colors[clr.HeaderActive] = ImVec4(0.25, 0.25, 0.25, 0.80)
					colors[clr.Separator] = ImVec4(0.58, 0.58, 0.58, 0.50)
					colors[clr.SeparatorHovered] = ImVec4(0.81, 0.81, 0.81, 0.64)
					colors[clr.SeparatorActive] = ImVec4(0.81, 0.81, 0.81, 0.64)
					colors[clr.ResizeGrip] = ImVec4(0.87, 0.87, 0.87, 0.53)
					colors[clr.ResizeGripHovered] = ImVec4(0.87, 0.87, 0.87, 0.74)
					colors[clr.ResizeGripActive] = ImVec4(0.87, 0.87, 0.87, 0.74)
					colors[clr.CloseButton] = ImVec4(0.45, 0.45, 0.45, 0.50)
					colors[clr.CloseButtonHovered] = ImVec4(0.70, 0.70, 0.90, 0.60)
					colors[clr.CloseButtonActive] = ImVec4(0.70, 0.70, 0.70, 1.00)
					colors[clr.PlotLines] = ImVec4(0.68, 0.68, 0.68, 1.00)
					colors[clr.PlotLinesHovered] = ImVec4(0.68, 0.68, 0.68, 1.00)
					colors[clr.PlotHistogram] = ImVec4(0.90, 0.77, 0.33, 1.00)
					colors[clr.PlotHistogramHovered] = ImVec4(0.87, 0.55, 0.08, 1.00)
					colors[clr.TextSelectedBg] = ImVec4(0.47, 0.60, 0.76, 0.47)
					colors[clr.ModalWindowDarkening] = ImVec4(0.88, 0.88, 0.88, 0.35)
				  end
				  black_grey()
			end
			if item.v == 2 then
				cfg.settings.item = item.v
				inicfg.save(cfg, directIni)
				function theme()
					imgui.SwitchContext()
					local style = imgui.GetStyle()
					local colors = style.Colors
					local clr = imgui.Col
					local ImVec4 = imgui.ImVec4
					local ImVec2 = imgui.ImVec2
				
					style.WindowPadding = imgui.ImVec2(8, 8)
					style.WindowRounding = 6
					style.ChildWindowRounding = 5
					style.FramePadding = imgui.ImVec2(5, 3)
					style.FrameRounding = 3.0
					style.ItemSpacing = imgui.ImVec2(5, 4)
					style.ItemInnerSpacing = imgui.ImVec2(4, 4)
					style.IndentSpacing = 21
					style.ScrollbarSize = 10.0
					style.ScrollbarRounding = 13
					style.GrabMinSize = 8
					style.GrabRounding = 1
					style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
					style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
				
					colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
					colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
					colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
					colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
					colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
					colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
					colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
					colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
					colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
					colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
					colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
					colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
					colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
					colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
					colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
					colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
					colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
					colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
					colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
					colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
					colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
					colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
					colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
					colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
					colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
					colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
					colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
					colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
					colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
					colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
					colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
					colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
					colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
					colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
				end
				theme()
			end
			if item.v == 3 then
				cfg.settings.item = item.v
				inicfg.save(cfg, directIni)
				function style() -- стиль имгуи
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
			end
			if item.v == 4 then
				cfg.settings.item = item.v
				inicfg.save(cfg, directIni)
				function apply_custom_style()
					imgui.SwitchContext()
					local style = imgui.GetStyle()
					local colors = style.Colors
					local clr = imgui.Col
					local ImVec4 = imgui.ImVec4
					local ImVec2 = imgui.ImVec2
				 
					 style.WindowPadding = ImVec2(15, 15)
					 style.WindowRounding = 15.0
					 style.FramePadding = ImVec2(5, 5)
					 style.ItemSpacing = ImVec2(12, 8)
					 style.ItemInnerSpacing = ImVec2(8, 6)
					 style.IndentSpacing = 25.0
					 style.ScrollbarSize = 15.0
					 style.ScrollbarRounding = 15.0
					 style.GrabMinSize = 15.0
					 style.GrabRounding = 7.0
					 style.ChildWindowRounding = 8.0
					 style.FrameRounding = 6.0
				   
				 
					   colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
					   colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
					   colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
					   colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
					   colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
					   colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
					   colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
					   colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
					   colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
					   colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
					   colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
					   colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
					   colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
					   colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
					   colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
					   colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
					   colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
					   colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
					   colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
					   colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
					   colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
					   colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
					   colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
					   colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
					   colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
					   colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
					   colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
					   colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
					   colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
					   colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
					   colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
					   colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
					   colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
					   colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
					   colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
					   colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
					   colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
					   colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
					   colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
					   colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
				 end
				 apply_custom_style()
			end
			if item.v == 5 then
				cfg.settings.item = item.v
				inicfg.save(cfg, directIni)
				imgui.SwitchContext()
				local style = imgui.GetStyle()
				local colors = style.Colors
				local clr = imgui.Col
				local ImVec4 = imgui.ImVec4
				local ImVec2 = imgui.ImVec2

				style.WindowPadding = ImVec2(15, 15)
				style.WindowRounding = 6.0
				style.FramePadding = ImVec2(5, 5)
				style.FrameRounding = 4.0
				style.ItemSpacing = ImVec2(12, 8)
				style.ItemInnerSpacing = ImVec2(8, 6)
				style.IndentSpacing = 25.0
				style.ScrollbarSize = 15.0
				style.ScrollbarRounding = 9.0
				style.GrabMinSize = 5.0
				style.GrabRounding = 3.0

				colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
				colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
				colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
				colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
				colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
				colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
				colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
				colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
				colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
				colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
				colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
				colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
				colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
				colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
				colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
				colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
				colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
				colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
				colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
				colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
				colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
				colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
				colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
				colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
				colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
				colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
				colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
				colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
				colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
				colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
				colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
				colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
				colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
				colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
				colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
				colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
				colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
				colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
				colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
				colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
			end
		end
		imgui.PopItemWidth()
		imgui.PopFont()
		imgui.End()
	end
	if secondary_window_state.v then -- второе окно сокращенных команд
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(550, 350), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Быстрые команды", secondary_window_state, _)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8"/m - m3 мут за мат\n/ok - /ok3 мут за оскорбление\n/fd - /fd3 мут за флуд\n/po - /po3 мут за попрошайничество\n/zs - мут за злоуп.симв\n/or - мут за оскорбление родных\n/oa - мут за оскорбление администрации\n/kl - клевета на администрацию\
/oft - /oft3 мут репорта за оффтоп\n/rpo - мут репорта за попрошайничество\n/ia - мут за выдачу себя за администратора\n/up - упоминание сторонних проектов\n/cp - /cp3 мут репорта за капс\n/roa - мут репорта за оскорбление администрации\n/ror - мут репорта за оскорбление родни\n/rrz - мут репорта за злоуп.симв\n/rz - мут за розжиг\n/rm - мут за мат в репорт\n/rok - мут за оск в репорт\
/dz - джайл за DM/DB в зз\n/zv - джайл за злоупотребление VIP\n/sk - джайл за Спавн-Килл\n/jcb - Джайл за вредительские читы\n/td - джайл за кар трейд\n/jc - джайл за безвредные читы\n/baguse - джайл за багоюз\
/bosk - бан за оскорбление проекта\n/rekl - бан за рекламу\n/ch - бан за читы\n/oskhelper - бан за оскорбление в хелпере\n/cafk - кик за афк на арене\
/kk1 - /kk3 кик за ник\n/prefixma - выдача префикса Младшему Администратору\n/prefixa - выдача префикса Администратору\n/prefixsa - выдача префикса Старшему Администратору\n/prefixzga - выдача рандомного префикса ЗГА\n/prefixpga - выдача рандомного префикса ПГА\n/prefixGA - выдача рандомного префикса ГА\
/n - не вижу нарушений\n/cl - данный игрок чист\n/c - начал работать над вашей жалобой\n/newprfma - изменить цвет префикса МА\n/newprfa - изменить цвет префикса А\n/newprfsa - изменить цвет префикса СА\n/newprfnick - изменить должность (для рандом префикса)\n/stw - выдать миниган\n/uu - снять мут\n/mytextreport - изменить дополнительный текст при ответе в репорт\
/wh - вкл/выкл функцию WallHack\n/textform - изменить текст отправленный в /a после одобрения формы\n/stylecolor - изменить цвет текста оповещения автоформ\n/stylecolorform - изменить цвет текста форм внутри оповещения.")
		imgui.Text(u8"/nv - Игрок не в сети\n/add_mat - добавить мат в Автомут\n/add_osk - добавить оскорбление в автомут\n/del_osk - удалить оскорбление из списка автомута\n/del_mat - удалить мат из списка автомута\n")
		imgui.PopFont()
		imgui.End()
	end
	if tree_window_state.v then --
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		--imgui.SetNextWindowSize(imgui.ImVec2(400, 170), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Ответ на репорт", tree_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8'Репорт от игрока: ' .. autor)
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
		if imgui.Button(u8'Вас накажут.', imgui.ImVec2(120, 25)) then
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
	if ban_window_state.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Выдать блокировку аккаунта", ban_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.Text(u8'Выберите причину:')
		if not sampIsDialogActive() then
			if imgui.Button(u8'Читы', imgui.ImVec2(250, 25)) then
				sampSendChat('/banc ' .. playerrecon)
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Многочисленные нарушения (3)', imgui.ImVec2(250, 25)) then
				sampSendChat('/ban ' .. playerrecon .. ' 3 Неадекват')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Нарушение правил хелпера', imgui.ImVec2(250, 25)) then
				sampSendChat('/iban ' .. playerrecon .. ' 3 Нарушение правил /helper')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Оскорбление проекта', imgui.ImVec2(250, 25)) then
				sampSendChat('/iban ' .. playerrecon .. ' 7 Оскорбление проекта')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Реклама', imgui.ImVec2(250, 25)) then
				sampSendChat('/iban ' .. playerrecon .. ' 7 Реклама')
				showCursor(false,false)
				four_window_state.v = false
				ban_window_state.v = false
			end
			if imgui.Button(u8'Обман', imgui.ImVec2(250, 25)) then
				sampSendChat('/iban ' .. playerrecon .. ' 7 Обман/развод')
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
			if imgui.Button(u8'Музыка бумбокса', imgui.ImVec2(250, 25)) then
				sampSendChat('/iban ' .. playerrecon .. ' 7 Музыка бумбокса')
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
				sampSendChat('/banc ' .. playerrecon)
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8"Злоупотребление VIP'ом", imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. " 3000 Злоупотребление VIP'oм")
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'Spawn Kill', imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. ' 3 Spawn Kill')
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'Car in /trade', imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. ' 300 car in /trade')
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'Чит', imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. ' 3000 чит')
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'Чит безвредный', imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. ' 900 чит')
				showCursor(false,false)
				jail_window_state.v = false
			end
			if imgui.Button(u8'ДБ ковш в зеленой зоне', imgui.ImVec2(250, 25)) then
				sampSendChat('/jail ' .. playerrecon .. ' 900 дб ковш в зеленой зоне')
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
				sampSendChat('/osk ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8"Мат", imgui.ImVec2(250, 25)) then
				sampSendChat('/mat ' .. playerrecon)
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8"Флуд", imgui.ImVec2(250, 25)) then
				sampSendChat('/mute ' .. playerrecon .. " 120 Флуд")
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Попрошайничество', imgui.ImVec2(250, 25)) then
				sampSendChat('/mute ' .. playerrecon .. ' 120 Попрошайничество')
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Оскорбление родных', imgui.ImVec2(250, 25)) then
				sampSendChat('/mute ' .. playerrecon .. ' 5000 Оскорбление/упоминание родни')
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Оскорбление администрации', imgui.ImVec2(250, 25)) then
				sampSendChat('/mute ' .. playerrecon .. ' 2500 Оскорбление администрации')
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Клевета на администрацию', imgui.ImVec2(250, 25)) then
				sampSendChat('/mute ' .. playerrecon .. ' 3000 Клевета на администрацию')
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Злоупотребление символами', imgui.ImVec2(250, 25)) then
				sampSendChat('/mute ' .. playerrecon .. ' 600 Злоупотребление символами')
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Выдача себя за администратора', imgui.ImVec2(250, 25)) then
				sampSendChat('/mute ' .. playerrecon .. ' 2500 Выдача себя за администратора')
				showCursor(false,false)
				mute_window_state.v = false
			end
			if imgui.Button(u8'Упоминание сторонних проектов', imgui.ImVec2(250, 25)) then
				sampSendChat('/mute ' .. playerrecon .. ' 1000 Упоминание сторонних проектов')
				sampSendChat('/cc')
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
				sampSendChat('/kick ' .. playerrecon .. ' AFK in /arena')
				four_window_state.v = false
				kick_window_state.v = false
			end
			if imgui.Button(u8"Nick 1/3", imgui.ImVec2(250, 25)) then
				sampSendChat('/kick ' .. playerrecon .. ' Смените ник 1/3')
				four_window_state.v = false
				kick_window_state.v = false
			end
			if imgui.Button(u8"Nick 2/3", imgui.ImVec2(250, 25)) then
				sampSendChat('/kick ' .. playerrecon .. " Смените ник 2/3")
				four_window_state.v = false
				kick_window_state.v = false
			end
			if imgui.Button(u8'Nick 3/3', imgui.ImVec2(250, 25)) then
				sampSendChat('/ban ' .. playerrecon .. ' 7 Смените ник 3/3')
				four_window_state.v = false
				kick_window_state.v = false
			end
		else
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}Закройте диалог, чтобы продолжить.', -1)
		end
		imgui.End()
	end
	if four_window_state.v and playerrecon then
		if cfg.settings.customposx then
			imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.customposx, cfg.settings.customposy))
		else
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		end
		imgui.Begin(u8"Рекон", four_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if imgui.Button(u8'+', imgui.ImVec2(20, 20)) then
			setClipboardText(nickplayerrecon)
			sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}Ник скопирован в буффер обмена.', -1)
		end
		imgui.SameLine()
		imgui.Text(u8('Игрок: ' .. nickplayerrecon) .. '[' .. playerrecon .. ']' )
		imgui.SameLine()
		playerreconstar = playerrecon
		if imgui.Button('->') then
			if not sampIsDialogActive() then
				sampSendChat('/re ' .. playerrecon + 1)
			end
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
		if isKeyJustPressed(VK_R) and not sampIsChatInputActive() then
			sampSendClickTextdraw(156)
			if cfg.settings.keysync then
				sampSetChatInputText('/keysync ' .. playerrecon)
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
			end
		end
		if isKeyJustPressed(VK_Q) and not sampIsChatInputActive() then
			sampSendClickTextdraw(177)
			four_window_state.v = false
			if cfg.settings.keysync then
				sampSetChatInputText('/keysync off')
				sampSetChatInputEnabled(true)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
			end
		end
		if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() then
			lua_thread.create(function()
				setVirtualKeyDown(70, true)
				wait(70)
				setVirtualKeyDown(70, false)
			end)
		end
		imgui.PopFont()
		imgui.ShowCursor = false
		imgui.End()
	end
	if fourtwo_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(250, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Настройки рекона", fourtwo_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.Button(u8'Сохранить выбранную позицию.', imgui.ImVec2(250, 25)) then
			local pos = imgui.GetWindowPos()
			cfg.settings.customposx = pos.x
			cfg.settings.customposy = pos.y
			inicfg.save(cfg,directIni)
			fourtwo_window_state.v = false
			four_window_state.v = true
		end
		imgui.End()
	end
	if five_window_state.v then
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
end
function textSplit(str, delim, plain)
    local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end

function sampev.onShowTextDraw(id, data)
	lua_thread.create(function()
		if id == 2052 then
			wait(100)
			sampTextdrawSetPos(2052, 2000, 0)
			four_window_state.v = true
			imgui.Process = true
			playerrecon = sampTextdrawGetString(2052)
			--playerrecon =  string.match(playerrecon, '%d[%d.,]*')
			playerrecon = tonumber(playerrecon:match('%((%d+)%)'))
			nickplayerrecon = sampGetPlayerNickname(playerrecon)
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
		end
	end)
end


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

-- 2349 взятие репорта
-- 2350 выбор ответить или отклонить
-- 2351 ввод текста

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if dialogId == 2349 then
		local lineIndex = -1
		for line in text:gmatch("[^\n]+") do
			lineIndex = lineIndex + 1
			if lineIndex == tonumber(1) - 1 then -- считываем автора жалобы
				autor = line
				rev = string.reverse(autor)
				don = string.sub(rev, -1)
				if don == '{' then
					autor = string.sub(autor, 24)
				end
			end
		end
		local lineIndex = -1
		for line in text:gmatch("[^\n]+") do
			lineIndex = lineIndex + 1
			if lineIndex == tonumber(3) - 1 then -- считываем жалобу
				textreport = line
				rev = string.reverse(textreport)
				don = string.sub(rev, -1)
				if don == '{' then
					textreport = string.sub(textreport, 9)
					reportid =  string.match(textreport, '%d[%d.,]*')
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
					if cfg.settings.doptext then
						peremrep = ('Начал работу по вашей жалобе!' .. doptext)
						rabotay = 2
					else
						peremrep = ('Начал работу по вашей жалобе!')
						rabotay = 2
					end
				end
				if ojid then
					if cfg.settings.doptext then
						peremrep = ('Ожидайте, скоро всё будет.' .. doptext)
						ojid = 2
					else
						peremrep = ('Ожидайте, скоро всё будет.')
						ojid = 2
					end
				end
				if nakazan then
					if cfg.settings.doptext then
						peremrep = ('Данный игрок уже был наказан.' .. doptext)
						nakazan = 2
					else
						peremrep = ('Данный игрок уже был наказан.')
						nakazan = 2
					end
				end
				if helpest then
					if cfg.settings.doptext then
						peremrep = ('Данная информация имеется в /help' .. doptext)
						helpest = 2
					else
						peremrep = ('Данная информация имеется в /help')
						helpest = 2
					end
				end
				if otklon then
					otklon = 2
				end
				if peredamrep then
					peredamrep = 2
				end
				if uto4id then
					if cfg.settings.doptext then
						peremrep = ('Уточните ID нарушителя в /report.' .. doptext)
						uto4id = 2
					else
						peremrep = ('Уточните ID нарушителя в /report.')
						uto4id = 2
					end
				end
				if nakajy then
					if cfg.settings.doptext then
						peremrep = ('Будете наказаны!' .. doptext)
						nakajy = 2
					else
						peremrep = ('Будете наказаны!')
						nakajy = 2
					end
				end
				if jb then
					if cfg.settings.doptext then
						peremrep = ('Напишите жалобу на forumrds.ru' .. doptext)
						jb = 2
					else
						peremrep = ('Напишите жалобу на forumrds.ru')
						jb = 2
					end
				end
				if internet then
					if cfg.settings.doptext then
						peremrep = ('С данной информацией вы можете ознакомиться в интернете.' .. doptext)
						internet = 2
					else
						peremrep = ('С данной информацией вы можете ознакомиться в интернете.')
						internet = 2
					end
				end
				if moiotvet then
					if cfg.settings.doptext then
						peremrep = (u8:decode(text_buffer.v) .. doptext)
						if #peremrep >= 80 then
							peremrep = (u8:decode(text_buffer.v))
							if #peremrep >= 80 then
								text_buffer.v = 'Слишком много символов'
							end
						end
						moiotvet = 2
					else
						peremrep = (u8:decode(text_buffer.v))
						if #peremrep >= 80 then
							text_buffer.v = 'Слишком много символов'
						end
						if #peremrep <= 3 then
							peremrep = (u8:decode(text_buffer.v) .. '    ')
						end
						moiotvet = 2
					end
				end
				if slejy then
					if cfg.settings.doptext then
						peremrep = ('Слежу за данным игроком!' .. doptext)
						slejy = 2
					else
						peremrep = ('Слежу за данным игроком!')
						slejy = 2
					end
				end
				if uto4 then
					if cfg.settings.doptext then
						peremrep = ('Уточните вашу жалобу/вопрос.' .. doptext)
						uto4 = 2
					else
						peremrep = ('Уточните вашу жалобу/вопрос.')
						uto4 = 2
					end
				end
			end
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
			tree_window_state.v = not tree_window_state.v
			imgui.Process = tree_window_state
		end)
	end
	if dialogId == 2350 then
		tree_window_state.v = false
		if otklon == 2 then
			lua_thread.create(function()
				sampSendDialogResponse(dialogId, 1, 2, _)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				otklon = nil
			end)
		end
		if peredamrep or slejy or rabotay or ojid or internet or uro4 or utorid or helpest or nakajy or jb or moiotvet or nakazan then
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
		end
	end
	if dialogId == 2351 then
		lua_thread.create(function()
			if peredamrep == 2 then
				sampSendDialogResponse(dialogId, 1, _, 'Передам ваш репорт.')
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				wait(300)
				sampSendChat('/a Репорт от игрока ' .. autor .. ': ' .. textreport)
				peredamrep = nil
			end
			if rabotay == 2 then
				sampSendDialogResponse(dialogId, 1, _, peremrep)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				if reportid then
					while sampIsDialogActive() do
						wait(0)
					end
					sampSendChat('/re ' .. reportid)
					reportid = nil
				end
				rabotay = nil
			end
			if slejy == 2 then
				sampSendDialogResponse(dialogId, 1, _, peremrep)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				if reportid then
					while sampIsDialogActive() do
						wait(0)
					end
					sampSendChat('/re ' .. reportid)
					reportid = nil
				end
				slejy = nil
			end
			if ojid or internet or uro4 or utorid or helpest or nakajy or jb or moiotvet or nakazan then
				sampSendDialogResponse(dialogId, 1, _, peremrep)
				setVirtualKeyDown(13, true)
				setVirtualKeyDown(13, false)
				text_buffer.v = ''
			end
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
function ev.onDisplayGameText(style, time, text)
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

function onWindowMessage(msg, wparam, lparam)
	if msg == 261 and wparam == 13 then consumeWindowMessage(true, true) end
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
				mimgui.Text(u8"Игрок не зафиксирован. Попробуйте обновить рекон нажав кнопку R")
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





function imgui.NewInputText(lable, val, width, hint, hintpos)
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

sampRegisterChatCommand('check_update', function() 
	sampShowDialog(1000, "В этом обновлении", info, "Понял", _)
end)


sampRegisterChatCommand('wh', function() 
	if cfg.settings.wallhack == true then
		sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}скрипт WallHack выключен', -1)
		cfg.settings.wallhack = not cfg.settings.wallhack
		inicfg.save(cfg,directIni)
		local pStSet = sampGetServerSettingsPtr();
		mem.setfloat(pStSet + 39, 50)
		mem.setint8(pStSet + 47, 0)
		mem.setint8(pStSet + 56, 1)
	else
		sampAddChatMessage('{FF0000}RDS Tools{d5d1eb}[' .. version .. ']: {FFFFFF}скрипт WallHack включен', -1)
		cfg.settings.wallhack = not cfg.settings.wallhack
		inicfg.save(cfg,directIni)
		for i = 0, sampGetMaxPlayerId() do
			if sampIsPlayerConnected(i) then
				local result, cped = sampGetCharHandleBySampPlayerId(i)
				local color = sampGetPlayerColor(i)
				local aa, rr, gg, bb = explode_argb(color)
				local color = join_argb(255, rr, gg, bb)
				local pStSet = sampGetServerSettingsPtr();
				NTdist = mem.getfloat(pStSet + 39)
				NTwalls = mem.getint8(pStSet + 47)
				NTshow = mem.getint8(pStSet + 56)
				mem.setfloat(pStSet + 39, 1488.0)
				mem.setint8(pStSet + 47, 0)
				mem.setint8(pStSet + 56, 1)
				nameTag = true
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
end)


sampRegisterChatCommand('add_mat', function(param)
	key = #cfg.osk + 1
    for k, v in pairs(cfg.mat) do
        if cfg.mat[k] == param:lower() then
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. param .. ' {F0E68C}уже имеется в списке матов.' , -1)
            a = true
            break
        else    
            a = false
        end
    end
    if not a then
        cfg.mat[key] = param:lower()
        inicfg.save(cfg,directIni)
        sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. param .. ' {F0E68C}успешно добавлено в список матов', -1)
        a = nil
    end
end)

sampRegisterChatCommand('del_mat', function(param)
	key = #cfg.osk + 1
    for k, v in pairs(cfg.mat) do
        if cfg.mat[k] == param:lower() then
            cfg.mat[k] = nil
            inicfg.save(cfg,directIni)
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Выбранное вами слово{008000} ' .. param .. ' {F0E68C}было успешно удалено из списка матов', -1)
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
end)


sampRegisterChatCommand('add_osk', function(param)
	key = #cfg.osk + 1
    for k, v in pairs(cfg.osk) do
        if cfg.osk[k] == param:lower() then
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. param .. ' {F0E68C}уже имеется в списке оскорблений.' , -1)
            a = true
            break
        else    
            a = false
        end
    end
    if not a then
        key = #cfg.osk + 1
        cfg.osk[key] = param:lower()
        inicfg.save(cfg,directIni)
        sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. param .. ' {F0E68C}было успешно добавлено в список оскорблений', -1)
        a = nil
    end
end)

sampRegisterChatCommand('del_osk', function(param)
	key = #cfg.osk + 1
    for k, v in pairs(cfg.osk) do
        if cfg.osk[k] == param:lower() then
            cfg.osk[k] = nil
            inicfg.save(cfg,directIni)
            sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Выбранное вами слово{008000} ' .. param .. ' {F0E68C}было успешно удалено из списка', -1)
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
end)


sampRegisterChatCommand('mytextreport', function(param) 
	cfg.settings.mytextreport = param
	inicfg.save(cfg, directIni)
	sampAddChatMessage('Новый дополнительный текст после ответа в репорт - ' .. param, -1)
end)
sampRegisterChatCommand('newprfma', function(param) 
	cfg.settings.prefixma = param
	sampAddChatMessage('Новый цвет префикса для младших администраторов: ' .. param, 0xCCCC33)
end)
sampRegisterChatCommand('newprfa', function(param) 
	cfg.settings.prefixa = param
	sampAddChatMessage('Новый цвет префикса для администраторов: ' .. param, 0xCCCC33)
end)
sampRegisterChatCommand('newprfsa', function(param) 
	cfg.settings.prefixsa = param
	sampAddChatMessage('Новый цвет префикса для старших администраторов: ' .. param, 0xCCCC33)
end)
sampRegisterChatCommand('newprfnick', function(param) 
	cfg.settings.prefixnick = param
	sampAddChatMessage('Ваша должность изменена на ' .. param, 0xCCCC33)
end)
sampRegisterChatCommand('infoform', function() 
	sampAddChatMessage('{C0C0C0}AForm: {FAEBD7}текст принятия формы - ' .. cfg.settings.texts, -1)
	sampAddChatMessage('{C0C0C0}AForm: {FAEBD7}настройки текста формы - /textform', -1)
	sampAddChatMessage('{C0C0C0}AForm: {FAEBD7}поменять стиль оповещения - /stylecolor, поменять стиль формы внутри оповещения - /stylecolorform', -1)
end)
sampRegisterChatCommand('textform', function(param) 
	cfg.settings.texts = param
	inicfg.save(cfg,directIni)
	sampAddChatMessage('{C0C0C0}AForm: {FAEBD7}текст принятия формы обновлен', -1)
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
sampRegisterChatCommand('n', function(param) 
	sampSendChat('/ans ' .. param .. ' Не вижу нарушений со стороны игрока.')
end)
sampRegisterChatCommand('c', function(param) 
	sampSendChat('/ans ' .. param .. ' Начал(а) работу над вашей жалобой.')
end)
sampRegisterChatCommand('cl', function(param) 
	sampSendChat('/ans ' .. param .. ' Данный игрок чист.')
end)
sampRegisterChatCommand('nv', function(param) 
	sampSendChat('/ans ' .. param .. ' Игрок не в сети')
end)
sampRegisterChatCommand('prefixma', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Мл.Администратор " .. cfg.settings.prefixma)
	end
end)
sampRegisterChatCommand('prefixa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Администратор " .. cfg.settings.prefixa)
	end
end)
sampRegisterChatCommand('prefixsa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Ст.Администратор " .. cfg.settings.prefixsa)
	end
end)
sampRegisterChatCommand('prefixpga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Главный-Администратор " .. color())
	end
end)
sampRegisterChatCommand('prefixzga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Зам.Глав.Администратора " .. color())
	end
end)
sampRegisterChatCommand('prefixga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Главный-Администратор " .. color())
	end
end)
sampRegisterChatCommand('stw', function(param) 
	sampSendChat("/setweap " .. param .. " 38 5000")
end)
--- Префиксы ---
sampRegisterChatCommand('m', function(param) 
	sampSendChat('/mute ' .. param .. ' 300 нецензурная лексика')
end)
sampRegisterChatCommand('m2', function(param) 
	sampSendChat('/mute ' .. param .. ' 600 нецензурная лексика x2')
end)
sampRegisterChatCommand('m3', function(param) 
	sampSendChat('/mute ' .. param .. ' 900 нецензурная лексика x3')
end)
sampRegisterChatCommand('ok', function(param) 
	sampSendChat('/mute ' .. param .. ' 400 Оскорбление')
end)
sampRegisterChatCommand('ok2', function(param) 
	sampSendChat('/mute ' .. param .. ' 800 Оскорбление x2')
end)
sampRegisterChatCommand('ok3', function(param) 
	sampSendChat('/mute ' .. param .. ' 1200 Оскорбление x3')
end)
sampRegisterChatCommand('fd', function(param) 
	sampSendChat('/mute ' .. param .. ' 120 Флуд')
end)
sampRegisterChatCommand('fd2', function(param) 
	sampSendChat('/mute ' .. param .. ' 240 Флуд x2')
end)
sampRegisterChatCommand('fd3', function(param) 
	sampSendChat('/mute ' .. param .. ' 360 Флуд x3')
end)
sampRegisterChatCommand('or', function(param) 
	sampSendChat('/mute ' .. param .. ' 5000 Оскорбление/Упоминание родни')
end)
sampRegisterChatCommand('up', function(param) 
	sampSendChat('/mute ' .. param .. ' 1000 Упоминание сторонних проектов')
	sampSendChat('/cc')
end)
sampRegisterChatCommand('oa', function(param) 
	sampSendChat('/mute ' .. param .. ' 2500 Оскорбление Администрации')
end)
sampRegisterChatCommand('kl', function(param) 
	sampSendChat('/mute ' .. param .. ' 3000 Клевета на Администрацию')
end)
sampRegisterChatCommand('po', function(param) 
	sampSendChat('/mute ' .. param .. ' 120 попрошайничество')
end)
sampRegisterChatCommand('po2', function(param) 
	sampSendChat('/mute ' .. param .. ' 240 попрошайничество x2')
end)
sampRegisterChatCommand('po3', function(param) 
	sampSendChat('/mute ' .. param .. ' 360 попрошайничество x3')
end)
sampRegisterChatCommand('zs', function(param) 
	sampSendChat('/mute ' .. param .. " 600 Злоупотребление символами")
end)
sampRegisterChatCommand('rz', function(param) 
	sampSendChat('/mute ' .. param .. " 5000 Розжиг")
end)
sampRegisterChatCommand('ia', function(param) 
	sampSendChat('/mute ' .. param .. " 2500 Выдача себя за администратора")
end)
sampRegisterChatCommand('oft', function(param) 
	sampSendChat('/rmute ' .. param .. " 120 Offtop in /report")
end)
sampRegisterChatCommand('oft2', function(param) 
	sampSendChat('/rmute ' .. param .. " 240 Offtop in /report x2")
end)
sampRegisterChatCommand('oft3', function(param) 
	sampSendChat('/rmute ' .. param .. " 360 Offtop in /report x3")
end)
sampRegisterChatCommand('cp', function(param) 
	sampSendChat('/rmute ' .. param .. " 120 Caps in /report")
end)
sampRegisterChatCommand('cp2', function(param) 
	sampSendChat('/rmute ' .. param .. " 240 Caps in /report x2")
end)
sampRegisterChatCommand('cp3', function(param) 
	sampSendChat('/rmute ' .. param .. " 360 Caps in /report x3")
end)
sampRegisterChatCommand('roa', function(param) 
	sampSendChat('/rmute ' .. param .. " 2500 Оскорбление Администрации")
end)
sampRegisterChatCommand('ror', function(param) 
	sampSendChat('/rmute ' .. param .. " 5000 Оскорбление/Упоминание Родни")
end)
sampRegisterChatCommand('rrz', function(param) 
	sampSendChat('/rmute ' .. param .. " 600 Злоупотребление символами")
end)
sampRegisterChatCommand('rpo', function(param) 
	sampSendChat('/rmute ' .. param .. " 120 Попрошайничество")
end)
sampRegisterChatCommand('rm', function(param) 
	sampSendChat('/rmute ' .. param .. " 300 мат в /report")
end)
sampRegisterChatCommand('rok', function(param) 
	sampSendChat('/rmute ' .. param .. " 400 оскорбление в /report")
end)
sampRegisterChatCommand('dz', function(param) 
	sampSendChat('/jail ' .. param .. ' 300 DM/DB in ZZ')
end)
sampRegisterChatCommand('zv', function(param) 
	sampSendChat('/jail ' .. param .. " 3000 Злоупотребление VIP'ом")
end)
sampRegisterChatCommand('sk', function(param) 
	sampSendChat('/jail ' .. param .. ' 300 Spawn Kill')
end)
sampRegisterChatCommand('td', function(param) 
	sampSendChat('/jail ' .. param .. ' 300 car in /trade')
end)
sampRegisterChatCommand('jcb', function(param) 
	sampSendChat('/jail ' .. param .. ' 3000 чит')
end)
sampRegisterChatCommand('jc', function(param) 
	sampSendChat('/jail ' .. param .. ' 900 чит')
end)
sampRegisterChatCommand('baguse', function(param) 
	sampSendChat('/jail ' .. param .. ' 300 Багоюз')
end)
sampRegisterChatCommand('bosk', function(param) 
	sampSendChat('/iban ' .. param .. ' 7 Оскорбление проекта')
end)
sampRegisterChatCommand('rekl', function(param) 
	sampSendChat('/iban ' .. param .. ' 7 реклама')
end)
sampRegisterChatCommand('ch', function(param) 
	sampSendChat('/iban ' .. param .. ' 7 чит.')
end)
sampRegisterChatCommand('oskhelper', function(param) 
	sampSendChat('/ban ' .. param .. ' 3 Нарушение правил /helper')
end)
sampRegisterChatCommand('cafk', function(param) 
	sampSendChat('/kick ' .. param .. ' Афк /arena') 
end)
sampRegisterChatCommand('kk1', function(param) 
	sampSendChat('/kick ' .. param .. ' Смените ник 1/3') 
end)
sampRegisterChatCommand('kk2', function(param) 
	sampSendChat('/kick ' .. param .. ' Смените ник 2/3') 
end)
sampRegisterChatCommand('kk3', function(param) 
	sampSendChat('/ban ' .. param .. ' Смените ник 3/3') 
end)
sampRegisterChatCommand('uu', function(param) 
	sampSendChat('/unmute ' .. param) 
end)



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