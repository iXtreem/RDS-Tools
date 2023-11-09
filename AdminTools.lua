require 'lib.moonloader'									-- Считываем библиотеки Moonloader
require 'lib.sampfuncs' 									-- Считываем библиотеки SampFuncs
script_name 'AdminTools [AT]'  								-- Название скрипта 
script_author 'Neon4ik' 									-- Псевдоним разработчика
script_properties("work-in-pause") 							-- Возможность обрабатывать информацию, находясь в AFK
local version = 4.3		 									-- Версия скрипта
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
------=================== Подгрузка библиотек ===================----------------------
local imgui 			= require 'imgui' 					-- Визуализация скрипта, окно программы
local sampev		 	= require 'lib.samp.events'			-- Считывание текста из чата
local imadd 			= require 'imgui_addons' 			-- Замена имгуи CheckBox'a
local mimgui 			= require "mimgui"					-- Мимгуи для работы keysyns
local inicfg 			= require 'inicfg'					-- Сохранение/загрузка конфигов
local encoding 			= require 'encoding'				-- Дешифровка на русский язык
local vkeys 			= require 'vkeys' 					-- Работа с нажатием клавиш
local ffi 				= require "ffi"						-- Работа с открытым чатом
local fa 				= require 'faicons'					-- Иконки в imgui
local mem 				= require "memory"					-- Работа с памятью игры
local font 				= require ("moonloader").font_flag	-- Шрифты визуальных текстов на экране
encoding.default 		= 'CP1251' 
local u8 				= encoding.UTF8 

------=================== Загрузка модулей ===================----------------------

local AT_MP 			= script.load("\\resource\\AT_MP.lua") 			-- подгрузка плагина для мероприятий
local AT_FastSpawn 		= script.load("\\resource\\AT_FastSpawn.lua")  	-- подгрузка быстрого спавна
local AT_Trassera 		= script.load("\\resource\\AT_Trassera.lua") 	-- подгрузка трассеров
local notify_report 	= import("\\resource\\lib_imgui_notf.lua") 				-- импорт уведомлений

local tag 				= '{2B6CC4}Admin Tools: {F0E68C}' 	-- Задаем название скрипта в самой игре
local sw, sh 			= getScreenResolution()           	-- Узнаем разрешение экрана пользователя

local cfg = inicfg.load({   ------------ Загружаем базовый конфиг, если он отсутствует
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
		mytextreport = ' // Приятной игры на RDS <3',
		position_recon_menu_x = sw - 270,
		position_recon_menu_y = 0,
		keysync = true,
		wallhack = true,
		answer_player_report = false,
		bloknotik = '',
		admin_chat = true,
		position_adminchat_x = -2,
		position_adminchat_y = sh*0.5-100,
		size_adminchat = 10,
		custom_answer_save = false,
		find_form = false,
		on_custom_recon_menu = true,
		on_custom_answer = true,
		strok_admin_chat = 6,
		position_ears_x = sw*0.5+200,
		position_ears_y = sh*0.2,
		size_ears = 10,
		strok_ears = 6,
		keysyncx = sh/2 + 100,
		keysyncy = sw/2 + 20,
		on_color_report = false,
		color_report = nil,
		fast_key_ans = 'None',
		fast_key_addText = 'None',
		fast_key_wallhack = 'None',
		prefixh = '',
		prefixma = '2E8B57',
		prefixa = '87CEEB',
		prefixsa = 'FF4500',
		autoprefix = true,
		forma_na_ban = false,
		forma_na_jail = false,
		forma_na_kick = false,
		forma_na_mute = false,
		add_mynick_in_form = false,
		control_system_mute = false,
		size_text_f6 = 12,
	},
	customotvet = {},
	myflood = {},
	my_command = {},
	binder_key = {},
	render_admins_exception = {},
	mute_players = {data = os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year},
}, 'AT//AT_main.ini')
inicfg.save(cfg, 'AT//AT_main.ini')

------=================== ImGui окна ===================----------------------
local windows = {
	menu_tools 			= imgui.ImBool(false),
	fast_report 		= imgui.ImBool(false),
	recon_menu 			= imgui.ImBool(false),
	menu_in_recon 		= imgui.ImBool(false),
	recon_ban_menu 		= imgui.ImBool(false),
	recon_mute_menu 	= imgui.ImBool(false),
	recon_jail_menu 	= imgui.ImBool(false),
	recon_kick_menu 	= imgui.ImBool(false),
	answer_player_report= imgui.ImBool(false),
	custom_ans 			= imgui.ImBool(false),
	render_admins		= imgui.ImBool(false),
	new_flood_mess 		= imgui.ImBool(false),
	pravila 			= imgui.ImBool(false),
	update_script 		= imgui.ImBool(false),
	menu_chatlogger 	= imgui.ImBool(false),
}

------=================== Выставление своих настроек, кнопки со значение True/False ===================----------------------
local checkbox = {
	check_automute 			= imgui.ImBool(cfg.settings.automute),
	check_keysync 			= imgui.ImBool(cfg.settings.keysync),
	check_autoonline 		= imgui.ImBool(cfg.settings.autoonline),
	check_find_form			= imgui.ImBool(cfg.settings.find_form),
	check_save_answer 		= imgui.ImBool(cfg.settings.custom_answer_save),
	check_render_admins 	= imgui.ImBool(cfg.settings.render_admins),
	check_admin_chat 		= imgui.ImBool(cfg.settings.admin_chat),
	check_form_ban 			= imgui.ImBool(cfg.settings.forma_na_ban),
	check_form_jail 		= imgui.ImBool(cfg.settings.forma_na_jail),
	check_form_mute 		= imgui.ImBool(cfg.settings.forma_na_mute),
	check_form_kick 		= imgui.ImBool(cfg.settings.forma_na_kick),
	check_add_mynick_form 	= imgui.ImBool(cfg.settings.add_mynick_in_form),
	check_WallHack			= imgui.ImBool(cfg.settings.wallhack),
	check_add_answer_report = imgui.ImBool(cfg.settings.add_answer_report),
	check_notify_report 	= imgui.ImBool(cfg.settings.notify_report),
	check_find_weapon_hack 	= imgui.ImBool(cfg.settings.find_warning_weapon_hack),
	check_smart_automute 	= imgui.ImBool(cfg.settings.smart_automute),
	check_on_custom_answer  = imgui.ImBool(cfg.settings.on_custom_answer),
	check_color_report 		= imgui.ImBool(cfg.settings.on_color_report),
	checked_radio_button 	= imgui.ImInt(1),
	custom_ans 				= imgui.ImInt(0),
	style_selected 			= imgui.ImInt(cfg.settings.style),
	selected_item 			= imgui.ImInt(cfg.settings.size_adminchat),
	option_find_log 		= imgui.ImInt(0),
	check_render_ears 		= imgui.ImBool(false),
	add_full_words 			= imgui.ImBool(true),
	control_system_mute  	= imgui.ImBool(cfg.settings.control_system_mute),
	check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report),
	check_on_custom_recon_menu = imgui.ImBool(cfg.settings.on_custom_recon_menu),
}

------=================== Ввод данных в ImGui окне ===================----------------------
local buffer = {
	text_ans 			= imgui.ImBuffer(256),
	custom_answer 		= imgui.ImBuffer(256),
	find_custom_answer 	= imgui.ImBuffer(256),
	newmat 				= imgui.ImBuffer(256),
	newosk 				= imgui.ImBuffer(256),
	add_new_text		= imgui.ImBuffer(u8(cfg.settings.mytextreport), 256),
	bloknotik 			= imgui.ImBuffer(u8(cfg.settings.bloknotik), 4096),
	new_flood_mess 		= imgui.ImBuffer(4096),
	title_flood_mess 	= imgui.ImBuffer(256),
	new_command_title 	= imgui.ImBuffer(256),
	new_command 		= imgui.ImBuffer(4096),
	find_rules 			= imgui.ImBuffer(256),
	new_binder_key 		= imgui.ImBuffer(2056),
	new_prfh 			= imgui.ImBuffer(cfg.settings.prefixh,256),
	new_prfma 			= imgui.ImBuffer(cfg.settings.prefixma,256),
	new_prfa 			= imgui.ImBuffer(cfg.settings.prefixa,256),
	new_prfsa 			= imgui.ImBuffer(cfg.settings.prefixsa, 256),
	find_log 			= imgui.ImBuffer(4096),
}
local chatlog_1 		= {} 											-- чат-лог1
local chatlog_2 		= {} 											-- чат-лог2
local chatlog_3 		= {} 											-- чат-лог3
local files_chatlogs 	= {}											-- список чат-логгов
local mat 				= {}											-- автомут на мат
local osk 				= {}											-- автомут на оск
local admins 			= {}											-- Рендер /admins
local chatlog 			= {}											-- Считывание чатлога из файла
local menu 				= {true, false} 								-- переключение окон в рекон меню [True = окно активно при запуке]
local menu2 			= {true, false, false, false, false, false, false}-- переключение окон основное меню [True = окно активно при запуске]
local textdraw 			= {} 											-- узнаем ид текстравов для взаимодействия с ними
local admin_form 		= {} 											-- Работа с админ-формами
local nakazatreport 	= {}											-- Возможность наказать прямо из репорта
local answer 			= {} 											-- Выбор ответа в репорте
local adminchat 		= {}											-- Все админ-сообщения хранятся тут
local ears 				= {}											-- Все /ears сообщения хранятся тут
local inforeport 		= {}											-- Вся информация о игроке в реконе хранится тут
local pravila 			= {}											-- Правила/команды хранятся тут (/ahelp)
local textdraw_delete = {  												-- Текстдравы из рекон меню, подлежащие удалению (заменить при обнове)
	144, 146, 141, 155, 153, 152, 154, 160, 179, 159, 157, 164, 180, 161,
	169, 181, 166, 168, 174, 182, 171, 173, 150, 183, 183, 147, 149, 142,
	143, 184, 176, 145, 158, 162, 163, 167, 172, 148
}
--================== русские буковки =====================
local russian_characters = {[168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я'}
--================== Название авто ID = [0],[1],[2],[3]...[n]  =====================
local name_car = {'Landstalker','Bravura','Buffalo','Linerunner','Perrenial','Sentinel','Dumper','Firetruck','Trashmaster','Stretch','Manana','Infernus','Voodoo','Pony','Mule','Cheetah','Ambulance','Leviathan','Moonbeam','Esperanto','Taxi','Washington','Bobcat','Mr Whoopee','BF Injection','Hunter','Premier','Enforcer','Securicar','Banshee','Predator','Bus','Rhino','Barracks','Hotknife','Trailer','Previon','Coach','Cabbie','Stallion','Rumpo','RC Bandit','Romero','Packer','Monster','Admiral','Squalo','Seasparrow','Pizzaboy','Tram','Trailer2','Turismo','Speeder','Reefer','Tropic','Flatbed','Yankee','Caddy','Solair','BerkleysRCVan','Skimmer','PCJ-600','Faggio','Freeway','RC Baron','RC Raider','Glendale','Oceanic','Sanchez','Sparrow','Patriot','Quad','Coastguard','Dinghy','Hermes','Sabre','Rustler','ZR-350','Walton','Regina','Comet','BMX','Burrito','Camper','Marquis','Baggage','Dozer','Maverick','News Chopper','Rancher','FBI Rancher','Virgo','Greenwood','Jetmax','Hotring','Sandking','Blista Compact','Police Maverick','Boxville','Benson','Mesa','RC Goblin','Hotring Racer A','Hotring Racer B','Bloodring Banger','Rancher','Super GT','Elegant','Journey','Bike','Mountain Bike','Beagle','Cropdust','Stunt','Tanker','Roadtrain','Nebula','Majestic','Buccaneer','Shamal','Hydra','FCR-900','NRG-500','HPV1000','Cement Truck','Tow Truck','Fortune','Cadrona','FBI Truck','Willard','Forklift','Tractor','Combine','Feltzer','Remington','Slamvan','Blade','Freight','Streak','Vortex','Vincent','Bullet','Clover','Sadler','Firetruck LA','Hustler','Intruder','Primo','Cargobob','Tampa',	'Sunrise','Merit','Utility','Nevada','Yosemite','Windsor','Monster A','Monster B','Uranus','Jester',	'Sultan',	'Stratum','Elegy','Raindance','RC Tiger',	'Flash',	'Tahoma','Savanna','Bandito','Freight Flat','Streak Carriage','Kart','Mower','Duneride','Sweeper','Broadway','Tornado','AT-400','DFT-30','Huntley','Stafford','BF-400','Newsvan','Tug','Trailer3','Emperor','Wayfarer','Euros','Hotdog','Club','Freight Carriage','Trailer4','Andromada','Dodo','RC Cam','Launch','Police Car (LSPD)','Police Car (SFPD)','Police Car (LVPD)','Police Ranger','Picador','S.W.A.T. Van','Alpha','Phoenix','Glendale','Sadler','Luggage Trailer A','Luggage Trailer B','Stair Trailer','Boxville','Farm Plow','Utility Trailer',}
---================= Задаем шрифт админ-чата =====================------------
local font_adminchat = renderCreateFont("Calibri", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW)
---================= Задаем шрифт ears-чата =====================------------
local font_earschat = renderCreateFont("Calibri", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)
---================= Задаем шрифт рендера игроков =====================------------

local spisokoskrod = {'mq', 'rnq'} -- автомут на оск род
local spisokrz = { 'слава укр', 'слава росс'} -- примерный розжиг
local spisokor = { -- список возможных вариаций оскорбления родни (мат + что-то из этого списка, или что-то из списка и оск)
	'сын',
	'мать',
	'мам',
	'выблядок',
	'mamy',
	'mama',
	'матушк',
}
local spisok_in_form = { -- список для автоформ
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
}
--------======================== Задаем шрифт и размер для имгуи текста ============--------------------
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local fa_glyph_ranges = imgui.ImGlyphRanges( {fa.min_range, fa.max_range} )
function imgui.BeforeDrawFrame()
    if not fontsize then  fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 17.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end -- 17 razmer
	if not fa_font then local font_config = imgui.ImFontConfig() font_config.MergeMode = true fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges) end 
end
ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
	int GetKeyboardLayoutNameA(char* pwszKLID);
]]
do
    local langIdBuffer = ffi.new("char[9]") --thanks by @RTD
    function getCurrentLanguageName()
        if ffi.C.GetKeyboardLayoutNameA(langIdBuffer) then
            return ffi.string(langIdBuffer) or "err"
        end
        return "err"
    end
end
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
--------=================== Подпись ID в килл-чате =============------------------------
function sampev.onPlayerDeathNotification(killerId, killedId, reason)
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
---=========================== ОСНОВНОЙ СЦЕНАРИЙ СКРИПТА ============-----------------
function main() 
	while not isSampAvailable() do wait(0) end
	while not sampIsLocalPlayerSpawned() do wait(1000) end
	local dlstatus = require('moonloader').download_status
    downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.ini", getWorkingDirectory() .. '//config//AT//AdminTools.ini', function(id, status) end)
	local AdminTools = inicfg.load(nil, getWorkingDirectory() .. '//config//AT//AdminTools.ini')
	if AdminTools then
		if AdminTools.script.info then update_info = AdminTools.script.info end
		if AdminTools.script.version > version then
			update_main = true
			if AdminTools.script.main then
				sampAddChatMessage(tag .. 'Обнаружено новое {808080}обязательное {F0E68C}обновление скрипта! Произвожу самообновление.', -1)
				update_main = true
				update_fs = true
				update_mp = true
				update()
			end
		end
		if cfg.settings.versionFS and cfg.settings.versionMP then
			if AdminTools.script.versionMP > cfg.settings.versionMP then
				update_mp = true
			end
			if AdminTools.script.versionFS > cfg.settings.versionFS then
				update_fs = true
			end
		else sampAddChatMessage(tag .. 'Дополнительные модули не подгружены! Сообщите об этом разработчику, или переустановите скрипт.', -1) end
	end
	local AdminTools = nil
	if sampGetCurrentServerAddress() == '46.174.52.246' or sampGetCurrentServerAddress() == '46.174.49.170' then sampAddChatMessage(tag .. 'Скрипт успешно загружен. Активация F3(/tool)', -1)
	else
		sampAddChatMessage(tag .. 'Я предназначен для RDS, там и буду работать.', -1)
		ScriptExport()
	end
	if update_main or update_fs or update_mp then windows.update_script.v = true imgui.Process = true end
	--------------------============ ПРАВИЛА И КОМАНДЫ =====================---------------------------------
	local rules = file_exists(getWorkingDirectory() .. "\\config\\AT\\rules.txt") if not rules then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", getWorkingDirectory() .. "\\config\\AT\\rules.txt", function(id, status) end) end
	local AutoMute_mat = file_exists(getWorkingDirectory() .. "\\config\\AT\\mat.txt") if not AutoMute_mat then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/mat.txt", getWorkingDirectory() .. "\\config\\AT\\mat.txt", function(id, status) end) end
	local AutoMute_osk = file_exists(getWorkingDirectory() .. "\\config\\AT\\osk.txt") if not AutoMute_osk then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/osk.txt", getWorkingDirectory() .. "\\config\\AT\\osk.txt", function(id, status) end) end
	
	local rules = io.open(getWorkingDirectory() .. "\\config\\AT\\rules.txt","r")
	if rules then for line in rules:lines() do pravila[#pravila + 1] = u8:decode(line);end rules:close() end
	
	--------------------============ АВТОМУТ =====================---------------------------------
	local AutoMute_mat = io.open(getWorkingDirectory() .. "\\config\\AT\\mat.txt", "r")
	if AutoMute_mat then for line in AutoMute_mat:lines() do line = u8:decode(line) if line and #(line) > 2 then table.insert(mat, line) end;end AutoMute_mat:close() end
	
	local AutoMute_osk = io.open(getWorkingDirectory() .. "\\config\\AT\\osk.txt", "r")
	if AutoMute_osk then for line in AutoMute_osk:lines() do line = u8:decode(line) if line and #(line) > 2 then table.insert(osk, line) end;end AutoMute_osk:close() end
	--------------------============ АВТОМУТ =====================---------------------------------
	local data_today = os.date("*t") -- узнаем дату сегодня
	if cfg.mute_players.data ~= data_today.day..'.'.. data_today.month..'.'..data_today.year then
		cfg.mute_players = {} -- сброс значений умного автомута если наступил следующий день
		cfg.mute_players.data = data_today.day..'.'.. data_today.month..'.'..data_today.year
		save()
	end
	--=========== ЧАТ ЛОГГ =======-----
	local log = (getWorkingDirectory()..'\\config\\chatlog\\chatlog '.. data_today.day..'.'..data_today.month..'.'..data_today.year..'.txt')
	if not directory_exists(getWorkingDirectory()..'\\config\\chatlog\\') then os.execute("mkdir moonloader\\config\\chatlog") print('Папка отсутствовала, создал новую.') end
	if not file_exists(log) then
		local file = io.open(log,"w")
		file:close()
		print('Создан новый chatlog.txt')
	end
	for k, v in ipairs(scanDirectory(getWorkingDirectory()..'\\config\\chatlog\\')) do
		local data1,data2,data3 = string.sub(string.gsub(string.gsub(v, 'chatlog ', ''), '%.',' '), 1,-5):match('(%d+) (%d+) (%d+)')
		if data3 and data2 and data3 then
			if tonumber(daysPassed(data3,data2,data1)) < 3 then
				file = io.open(getWorkingDirectory()..'\\config\\chatlog\\'..v,'r')
				for line in file:lines() do
					if k == 1 then chatlog_1[#chatlog_1 + 1] = string.gsub(encrypt(line, -3), '{%w%w%w%w%w%w}','')
					elseif k == 2 then chatlog_2[#chatlog_2 + 1] = string.gsub(encrypt(line, -3), '{%w%w%w%w%w%w}','')
					elseif k == 3 then chatlog_3[#chatlog_3 + 1] = string.gsub(encrypt(line, -3), '{%w%w%w%w%w%w}','') end
				end
				file:close()
			else os.remove(getWorkingDirectory()..'\\config\\chatlog\\' .. v) end -- если чатлогу больше 3 дней (вкл) то удаляем его
		else sampAddChatMessage(tag ..'Что-то пошло не так, чат-лог не обнаружен, или имеет неверное название', -1) end
	end
	--========== ЧАТ ЛОГГ ========----
	if cfg.settings.inputhelper then lua_thread.create(inputChat) end
	func = lua_thread.create_suspended(autoonline)
	funcadm = lua_thread.create_suspended(render_admins)
	func1 = lua_thread.create_suspended(render_text)
	func4 = lua_thread.create_suspended(binder_key)
	if cfg.settings.render_admins then funcadm:run() end
	if cfg.settings.wallhack then on_wallhack() end
	if cfg.settings.autoonline then func:run() end
	func1:run() 									--render_text
	func4:run() 									--binder_key
	lua_thread.create(function()
		local font_watermark = renderCreateFont("Javanese Text", 8, font.BOLD + font.BORDER + font.SHADOW)
		while true do 
			wait(1)
			renderFontDrawText(font_watermark, tag .. '{A9A9A9}version['.. version .. ']', 10, sh-20, 0xCCFFFFFF)
		end	
	end)
	while true do
        wait(1)
		if isPauseMenuActive() or isGamePaused() then AFK = true end
		if AFK and not (isPauseMenuActive() or isGamePaused()) then AFK = false end
		if isKeyJustPressed(VK_F3) and not sampIsDialogActive() then  -- кнопка активации окна
			windows.menu_tools.v = not windows.menu_tools.v
			imgui.Process = true
		end
		if cfg.settings.wallhack and not AFK then
			for i = 0, sampGetMaxPlayerId() do
				if sampIsPlayerConnected(i) then
					local result, cped = sampGetCharHandleBySampPlayerId(i)
					local color = sampGetPlayerColor(i)
					local aa, rr, gg, bb = explode_argb(color)
					local color = join_argb(255, rr, gg, bb)
					if result and doesCharExist(cped) and isCharOnScreen(cped) then
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
--======================================= РЕГИСТРАЦИЯ КОМАНД ====================================--
function color() mcolor = "" math.randomseed( os.time() ) for i = 1, 6 do local b = math.random(1, 16) if b == 1 then mcolor = mcolor .. "A" elseif b == 2 then mcolor = mcolor .. "B" elseif b == 3 then mcolor = mcolor .. "C" elseif b == 4 then mcolor = mcolor .. "D" elseif b == 5 then mcolor = mcolor .. "E" elseif b == 6 then mcolor = mcolor .. "F" elseif b == 7 then mcolor = mcolor .. "0" elseif b == 8 then mcolor = mcolor .. "1" elseif b == 9 then mcolor = mcolor .. "2" elseif b == 10 then mcolor = mcolor .. "3" elseif b == 11 then mcolor = mcolor .. "4" elseif b == 12 then mcolor = mcolor .. "5" elseif b == 13 then mcolor = mcolor .. "6" elseif b == 14 then mcolor = mcolor .. "7" elseif b == 15 then mcolor = mcolor .. "8" elseif b == 16 then mcolor = mcolor .. "9" end end return mcolor end
local basic_command = { -- базовые команды, 1 аргумент = символ '_'
	ans = { 														-- с вариативностью есть доп/текст или нет
		nv      =  		'/ot _ Игрок не в сети ',
		cl      =  		'/ot _ Данный игрок чист. ',
		pmv     =  		'/ot _ Помогли вам. Обращайтесь ещё ',
		c       =  		'/ot _ Начал(а) работу над вашей жалобой. ',
		dpr     =  		'/ot _ У игрока куплены функции за /donate ',
		afk     =  		'/ot _ Игрок бездействует или находится в AFK ',
		nak     =  		'/ot _ Игрок был наказан, спасибо за обращение. ',
		n       =  		'/ot _ Не наблюдаю нарушений со стороны игрока. ',
		fo      =  		'/ot _ Обратитесь с данной проблемой на форум https://forumrds.ru ',
		rep     =  		'/ot _ Нашли нарушителя? Появился вопрос? Напишите /report!',
	},
	mute = {
		fd      =  		'/mute _ 120 Флуд',--[[x10]]fd2='/mute _ 240 Флуд x2',fd3='/mute _ 360 Флуд x3',fd4='/mute _ 480 Флуд x4',fd5='/mute _ 600 Флуд x5',fd6='/mute _ 720 Флуд x6',fd7='/mute _ 840 Флуд x7',fd8='/mute _ 960 Флуд x8',fd9='/mute _ 1080 Флуд x9',fd10='/mute _ 1200 Флуд x10',
		po 		=  		'/mute _ 120 Попрошайничество',--[[x10]]po2='/mute _ 240 Попрошайничество x2',po3='/mute _ 360 Попрошайничество x3',po4 ='/mute _ 480 Попрошайничество x4',po5 ='/mute _ 600 Попрошайничество x5',po6 ='/mute _ 720 Попрошайничество x6',po7 ='/mute _ 840 Попрошайничество x7',po8 ='/mute _ 960 Попрошайничество x8',po9 ='/mute _ 1080 Попрошайничество x9',po10 ='/mute _ 1200 Попрошайничество x10',
		m       =  		'/mute _ 300 Нецензурная лексика',--[[x10]]m2='/mute _ 600 Нецензурная лексика x2',m3='/mute _ 900 Нецензурная лексика x3',m4='/mute _ 1200 Нецензурная лексика x4',m5='/mute _ 1500 Нецензурная лексика x5',m6='/mute _ 1800 Нецензурная лексика x6',m7='/mute _ 2100 Нецензурная лексика x7',m8='/mute _ 2400 Нецензурная лексика x8',m9='/mute _ 2700 Нецензурная лексика x9',m10='/mute _ 3000 Нецензурная лексика x10',
		ok      =  		'/mute _ 400 Оскорбление/Унижение',--[[x10]]ok2='/mute _ 800 Оскорбление/Унижение x2',ok3='/mute _ 1200 Оскорбление/Унижение x3',ok4='/mute _ 1600 Оскорбление/Унижение x4',ok5='/mute _ 2000 Оскорбление/Унижение x5',ok6='/mute _ 2400 Оскорбление/Унижение x6',ok7='/mute _ 2800 Оскорбление/Унижение x7',ok8='/mute _ 3200 Оскорбление/Унижение x8',ok9='/mute _ 3600 Оскорбление/Унижение x9',ok10='/mute _ 4000 Оскорбление/Унижение x10',
		up 		=  		'/mute _ 1000 Упом. сторонних проектов',
		oa 		=  		'/mute _ 2500 Оскорбление администрации',
		kl 		=  		'/mute _ 3000 Клевета на администрацию',
		zs 		=  		'/mute _ 600 Злоупотребление символами',
		nm 		=  		'/mute _ 600 Неадекватное поведение.',
		rekl 	=  		'/mute _ 1000 Реклама',
		rz		=  		'/mute _ 5000 Розжиг межнац. розни',
		ia 		=  		'/mute _ 2500 Выдача себя за администратора',
	},
	rmute = {
		oft 	= 		'/rmute _ 120 оффтоп в репорт',--[[x10]]oft2='/rmute _ 240 оффтоп в репорт x2',oft3='/rmute _ 360 оффтоп в репорт x3',oft4='/rmute _ 480 оффтоп в репорт х4',oft5='/rmute _ 600 оффтоп в репорт х5',oft6='/rmute _ 720 оффтоп в репорт x6',oft7='/rmute _ 840 оффтоп в репорт х7',oft8='/rmute _ 960 оффтоп в репорт х8',oft9='/rmute _ 1080 оффтоп в репорт х9',oft10='/rmute _ 1200 оффтоп в репорт х10',
		cp 		= 		'/rmute _ 120 Caps in /report',--[[x10]]cp2='/rmute _ 240 Caps in /report x2',cp3='/rmute _ 360 Caps in /report x3',cp4='/rmute _ 480 Caps in /report x4',cp5='/rmute _ 600 Caps in /report x5',cp6='/rmute _ 720 Caps in /report x6',cp7='/rmute _ 840 Caps in /report x7',cp8='/rmute _ 960 Caps in /report x8',cp9='/rmute _ 1080 Caps in /report x9',cp10='/rmute _ 1200 Caps in /report x10',
		rpo		=		'/rmute _ 120 Попрошайка в /report',--[[x10]]rpo2='/rmute _ 240 Попрошайка в /report x2',rpo3='/rmute _ 360 Попрошайка в /report x3',rpo4='/rmute _ 480 Попрошайка в /report x4',rpo5='/rmute _ 600 Попрошайка в /report x5',rpo6='/rmute _ 720 Попрошайка в /report x6',rpo7='/rmute _ 840 Попрошайка в /report x7',rpo8='/rmute _ 960 Попрошайка в /report x8',rpo9='/rmute _ 1080 Попрошайка в /report x9',rpo10='/rmute _ 1200 Попрошайка в /report x10',
		rm 		= 		'/rmute _ 300 мат в /report',--[[x10]]rm2='/rmute _ 600 мат в /report x2',rm3='/rmute _ 900 мат в /report x3',rm4='/rmute _ 600 мат в /report x4',rm5='/rmute _ 600 мат в /report x5',rm6='/rmute _ 600 мат в /report x6',rm7='/rmute _ 600 мат в /report x7',rm8='/rmute _ 600 мат в /report x8',rm9='/rmute _ 600 мат в /report x9',rm10='/rmute _ 600 мат в /report x10',
		rok 	= 		'/rmute _ 400 Оскорбление в /report',--[[x10]]rok2='/rmute _ 800 Оскорбление в /report x2',rok3='/rmute _ 1200 Оскорбление в /report x3',rok4='/rmute _ 1600 Оскорбление в /report x4',rok5='/rmute _ 2000 Оскорбление в /report x5',rok6='/rmute _ 2400 Оскорбление в /report x6',rok7='/rmute _ 2800 Оскорбление в /report x7',rok8='/rmute _ 3200 Оскорбление в /report x8',rok9='/rmute _ 3600 Оскорбление в /report x9',rok10='/rmute _ 4000 Оскорбление в /report x10',
		roa 	= 		'/rmute _ 2500 Оскорбление администрации',
		ror 	= 		'/rmute _ 5000 Оскорбление/Упоминание родных',
		rzs 	= 		'/rmute _ 600 Злоупотребление символами',
		rrz 	= 		'/rmute _ 5000 Розжиг межнац. розни',
	},
	jail = {
		bg 		= 		'/jail _ 300 Багоюз',
		sk 		= 		'/jail _ 300 Spawn Kill',
		td 		= 		'/jail _ 300 car in /trade',
		jm 		= 		'/jail _ 300 Нарушение правил МП',
		dz 		= 		'/jail _ 300 ДМ/ДБ в зеленой зоне',
		dk 		= 		'/jail _ 900 ДБ Ковш в зеленой зоне',
		jc 		= 		'/jail _ 900 сторонний скрипт/ПО',
		sh 		= 		'/jail _ 900 SpeedHack/FlyCar',
		prk 	=		'/jail _ 900 Parkour mode',
		vs 		=		'/jail _ 900 Дрифт мод',
		jcb 	= 		'/jail _ 3000 читерский скрипт/ПО',
		zv 		= 		"/jail _ 3000 Злоупотребление VIP'ом",
		dmp 	= 		'/jail _ 3000 Серьезная помеха на МП',
	},
	ban = {
		bh 		= 		'/ban _ 3 Нарушение правил /helper',
		nmb 	= 		'/iban _ 3 Неадекватное поведение',
		ch 		= 		'/iban _ 7 читерский скрипт/ПО',
		obh 	= 		'/iban _ 7 Обход прошлого бана',
		bosk 	= 		'/siban _ 999 Оскорбление проекта',
		rk 		= 		'/siban _ 999 Реклама',
		obm 	= 		'/siban _ 30 Обман/Развод',
	},
	kick = {
		cafk 	= 		'/kick _ AFK in /arena',
		jk 		= 		'/kick _ DM in jail',
		kk1 	= 		'/kick _ Смените ник 1/3',
		kk2 	= 		'/kick _ Смените ник 2/3',
		kk3 	= 		'/ban _ 7 Смените ник 3/3',
	},
	help = {
		uu      =  		'/unmute _',
		uj      =  		'/unjail _',
		ur      =  		'/unrmute _',
		as      =  		'/aspawn _',
		stw     =  		'/setweap _ 38 5000',
		prfma   =  		'/prefix _ Мл.Администратор ' .. cfg.settings.prefixma,
		prfa    =  		'/prefix _ Администратор ' .. cfg.settings.prefixa,
		prfsa   =  		'/prefix _ Ст.Администратор ' .. cfg.settings.prefixsa,
		prfpga  =  		'/prefix _ Помощник.Глав.Администратора ' .. color(),
		prfzga  =  		'/prefix _ Зам.Глав.Администратора ' .. color(),
		prfga   =  		'/prefix _ Главный-Администратор ' .. color(),
		prfcpec =  		'/prefix _ Спец.Администратор ' .. color(),
		al 		=		'/ans _ Здравствуйте! Вы забыли ввести /alogin! Авторизируйтесь, пожалуйста.',
	},
	prochee = {
		wh 		= 		'Включить WallHack',
		tool 	= 		'Активировать меню АТ',
		sbanip 	= 		'Выдать блокировку аккаунта с IP адресом (ФД!)',
		spp 	= 		'Заспавнить игроков в радиусе',
		prfma 	= 		'Выдать префикс мл.админу',
		prfa 	= 		'Выдать префикс админу',
		prfsa 	= 		'Выдать префикс старшему админу',
		prfpga 	= 		'Выдать префикс ПГА',
		prfzga 	= 		'Выдать префикс ЗГА',
		prfga 	= 		'Выдать префикс ГА',
		color_report   ='Назначить цвет ответа на репорт',
		inputhelper    ='Включить/Выключить InputHelper',
		size_chat	   ='Изменить размер рендера информации открытого чата',
		add_autoprefix ='Добавить администратора в исключение автопрефикса',
		del_autoprefix ='Удалить администратора из исключений автопрефикса',
	},
}
--------============= Инициализируем команды, указанные выше ===========================---------------------------
for k,v in pairs(basic_command.help) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.ans) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then if cfg.settings.add_answer_report then sampSendChat(string.gsub(v, '_', param) ..' '.. cfg.settings.mytextreport) else sampSendChat(string.gsub(v, '_', param)) end else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.mute) do  sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param) ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1)  end end) end
for k,v in pairs(basic_command.rmute) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.jail) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.kick) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.ban) do sampRegisterChatCommand(k, function(param)  if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
--============= Регистрация тех же команд из массива, но для выдачи в ОФФЛАЙНЕ (окончание f) ===============================--
for k,v in pairs(basic_command.mute) do sampRegisterChatCommand(k..'f', function(param) if #param ~= 0 then sampSendChat(string.gsub(string.gsub(v, '_', param), '/mute', '/muteoff') ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.rmute) do sampRegisterChatCommand(k..'f', function(param) if #param ~= 0 then sampSendChat(string.gsub(string.gsub(v, '_', param) , '/rmute', '/rmuteoff') ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.jail) do sampRegisterChatCommand(k..'f', function(param) if #param ~= 0 then sampSendChat(string.gsub(string.gsub(v, '_', param) , '/jail', '/jailakk') ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.ban) do sampRegisterChatCommand(k..'f', function(param) if #param ~= 0 then sampSendChat(string.gsub(string.gsub(string.gsub(v, '_', param) , '/siban', '/banoff') ,'/iban', '/banoff') ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
--------============= Инициализируем команды ниже (особые свойства) ===========================---------------------------
for k,v in pairs(cfg.my_command) do local v = string.gsub(v, '\\n','\n') sampRegisterChatCommand(k, function(param) lua_thread.create(function() for a,b in pairs(textSplit(string.gsub(v, '_', param), '\n')) do if b:match('wait(%(%d+)%)') then wait(tonumber(b:match('%d+') .. '000')) else sampSendChat(b) end end end) end) end

-- Команда or (оск/упом родни) содержит название переменной, потому создается отдельно
sampRegisterChatCommand('prfma', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' Младший-Администратор ' .. cfg.settings.prefixma) else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end end)
sampRegisterChatCommand('prfa', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' Администратор ' .. cfg.settings.prefixa) else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end end)
sampRegisterChatCommand('prfsa', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' Ст.Администратор ' .. cfg.settings.prefixsa) else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end end)
sampRegisterChatCommand('prfpga', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' Помощник Глав.Администратора ' .. color()) else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end end)
sampRegisterChatCommand('prfzga', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' Заместитель Глав.Администратора ' .. color()) else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end end)
sampRegisterChatCommand('prfga', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' Главный-Администратор ' .. color()) else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end end)
sampRegisterChatCommand('or', function(param) if #param ~= 0 then sampSendChat('/mute '..param..' 5000 Оскорбление/Упоминание родных') else sampAddChatMessage(tag ..'Вы не указали значение') end end)
sampRegisterChatCommand('orf', function(param) if #param ~= 0 then sampSendChat('/muteakk '..param..' 5000 Оскорбление/Упоминание родных') else sampAddChatMessage(tag ..'Вы не указали значение') end end)
sampRegisterChatCommand('wh' , function()
	if not cfg.settings.wallhack then
		cfg.settings.wallhack = true
		save()
		notify('{66CDAA}[AT-WallHack]', 'Опция успешно включена')
		checkbox.check_WallHack = imgui.ImBool(cfg.settings.wallhack),
		on_wallhack()
	else
		cfg.settings.wallhack = false
		save()
		notify('{66CDAA}[AT-WallHack]', 'Опция успешно выключена')
		checkbox.check_WallHack = imgui.ImBool(cfg.settings.wallhack),
		off_wallhack()
	end
end)
sampRegisterChatCommand('inputhelper', function()
	cfg.settings.inputhelper = not cfg.settings.inputhelper
	save()
	sampAddChatMessage(tag .. 'Инпут хелпер включен/выключен', -1)
end)
sampRegisterChatCommand('tool', function()
	windows.menu_tools.v = not windows.menu_tools.v
	imgui.Process = true
end)
sampRegisterChatCommand('add_autoprefix', function(param)
	if #param > 4 then
		for i = 1, #(cfg.render_admins_exception) do
			if param == cfg.render_admins_exception[i] then
				find_admin = true
				sampAddChatMessage(tag .. 'Администратор ' .. param .. ' уже имеется в списке.', -1)
				for i = 1, #(cfg.render_admins_exception) do if cfg.render_admins_exception[i] then sampAddChatMessage(cfg.render_admins_exception[i], -1) end end
				break
			end
		end
		if not find_admin then 
			cfg.render_admins_exception[#(cfg.render_admins_exception) + 1] = param
			save()
			sampAddChatMessage(tag .. 'Администратор ' .. param .. ' был успешно добавлен в список исключений авто-выдачи префикса.', -1) 
		end
	else  sampAddChatMessage(tag .. 'Введите ник администратора.', -1) end
	find_admin = nil
end)
sampRegisterChatCommand('del_autoprefix', function(param)
	if #param > 4 then
		for i = 1, #(cfg.render_admins_exception) do
			if param == cfg.render_admins_exception[i] then 
				cfg.render_admins_exception[i] = nil 
				save()
				sampAddChatMessage(tag .. 'Администратор ' .. param .. ' был успешно убран из списка исключений авто-выдачи префикса.', -1)
				find_admin = true
				break 
			end
		end
		if not find_admin then sampAddChatMessage(tag .. 'Администратор ' .. param .. ' не был найден в исключений авто-выдачи префикса.', -1) for i = 1, #(cfg.render_admins_exception) do if cfg.render_admins_exception[i] then sampAddChatMessage(cfg.render_admins_exception[i], -1) end end end
	else sampAddChatMessage(tag .. 'Введите ник администратора.', -1) end
	find_admin = nil
end)
sampRegisterChatCommand('color_report', function(param)
	if #param ~= 0 then
		if #param == 6 then
			cfg.settings.color_report = '{'..param..'}'
			save()
			sampAddChatMessage(tag ..cfg.settings.color_report.. 'Выбранный цвет', -1)
		else sampAddChatMessage(tag..'Цвет указан неверно. Введите HTML цвет состоящий из 6 символов', -1) sampAddChatMessage(tag ..'Пример: /color_report FF0000 (будет указан цвет ' .. '{FF0000}Красный' .. '{FFFFFF})', -1) end
	else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end
end)
sampRegisterChatCommand('autoprefix', function()
	if cfg.settings.autoprefix then sampAddChatMessage(tag .. 'Автоматическая выдача префикса успешно выключена.', -1)
	else sampAddChatMessage(tag .. 'Автоматическая выдача префикса успешно включена.', -1) end
	cfg.settings.autoprefix = not cfg.settings.autoprefix
	save()
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
				else sampAddChatMessage(tag .. 'Данные введены некорректно.',-1) end
			else sampAddChatMessage(tag .. 'Данные введены некорректно.',-1) end
		else sampAddChatMessage(tag .. 'Данные введены некорректно.',-1) end
	end)
end)
sampRegisterChatCommand('spp', function()
	lua_thread.create(function() for _, id in pairs(playersToStreamZone()) do wait(500) sampSendChat('/aspawn ' .. id) end end)
end)
sampRegisterChatCommand('size_chat', function(param)
	if param:match('(%d+)') then
		local param = param:match('(%d+)')
		if (tonumber(param) >= 8 and tonumber(param) <= 18) or tonumber(param) == 1 then
			cfg.settings.size_text_f6 = param
			save()
			thisScript():reload()
		else sampAddChatMessage(tag .. 'Команда принимает значения от 8 до 18 (1 = выключить)', -1) end
	else sampAddChatMessage(tag.. 'Команда принимает значения от 8 до 18 (1 = выключить)', -1) end
end)
--======================================= РЕГИСТРАЦИЯ КОМАНД ====================================--
function imgui.OnDrawFrame()
	if not windows.update_script.v and not windows.render_admins.v and not windows.menu_tools.v and not windows.pravila.v and not windows.fast_report.v and not windows.recon_menu.v and not windows.answer_player_report.v and not windows.menu_chatlogger.v then
		showCursor(false,false)
		imgui.Process = false
		if cfg.settings.render_admins then sampSendChat('/admins') end
	end
	if windows.menu_tools.v then -- КНОПКИ ИНТЕРФЕЙСА F3
		windows.render_admins.v = false
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
		imgui.Begin('xX     Admin Tools [AT]     Xx', windows.menu_tools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.SameLine()
		imgui.SetCursorPosX(120)
		if imgui.Button(fa.ICON_ADDRESS_BOOK, imgui.ImVec2(30, 30)) then uu2() menu2[1] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_COGS, imgui.ImVec2(30, 30)) then uu2() menu2[3] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_PENCIL_SQUARE, imgui.ImVec2(30, 30)) then uu2() menu2[4] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_CALENDAR_CHECK_O, imgui.ImVec2(30, 30)) then uu2() menu2[5] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_RSS, imgui.ImVec2(30, 30)) then uu2() menu2[7] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_BOOKMARK, imgui.ImVec2(30, 30)) then uu2() menu2[2] = true end imgui.SameLine()
		if imgui.Button(fa.ICON_CLOUD, imgui.ImVec2(30, 30)) then uu2() menu2[8] = true end
        imgui.Separator()
        imgui.NewLine()
        imgui.SameLine(2)
		if menu2[1] then
			imgui.SetCursorPosX(8)
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
			imgui.Text(u8'Авто-Выдача за онлайн')
			imgui.SameLine()
			imgui.SetCursorPosX(250)
			if imadd.ToggleButton("##system_mute", checkbox.control_system_mute) then
				cfg.settings.control_system_mute = not cfg.settings.control_system_mute
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Перевыдача мутов')
			if imadd.ToggleButton("##WallHack", checkbox.check_WallHack) then
				if cfg.settings.wallhack then off_wallhack() else on_wallhack() end
			end
			imgui.SameLine()
			imgui.Text('WallHack')
			imgui.SameLine()
			imgui.SetCursorPosX(250)
			if imadd.ToggleButton('##find_form', checkbox.check_find_form) then
				cfg.settings.find_form  = not cfg.settings.find_form
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Слежка за формами')
			if imadd.ToggleButton('##automute', checkbox.check_automute) then
				if cfg.settings.automute and cfg.settings.smart_automute then
					cfg.settings.smart_automute = false
					checkbox.check_smart_automute = imgui.ImBool(cfg.settings.smart_automute)
				end
				if cfg.settings.forma_na_mute then
					cfg.settings.automute = false
					checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
				else cfg.settings.automute  = not cfg.settings.automute end
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Автомут')
			imgui.SameLine()
			imgui.SetCursorPosX(250)
			if imadd.ToggleButton("##NotifyPlayer", checkbox.check_answer_player_report) then
				if not cfg.settings.on_custom_recon_menu then
					sampAddChatMessage(tag .. 'Данная функция работает только с кастом рекон меню', -1)
					cfg.settings.answer_player_report = false
					checkbox.check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report)
				else cfg.settings.answer_player_report = not cfg.settings.answer_player_report end
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Уведомление игрока')
			if imadd.ToggleButton("##SmartAutomute", checkbox.check_smart_automute) then
				if not cfg.settings.automute then
					cfg.settings.automute  = not cfg.settings.automute
					checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
				end
				cfg.settings.smart_automute = not cfg.settings.smart_automute
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Умный автомут')
			imgui.SameLine()
			imgui.SetCursorPosX(250)
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
			imgui.Text(u8'Реакция на чит-оружие')
			imgui.SameLine()
			imgui.SetCursorPosX(250)
			if imadd.ToggleButton("##FastReport", checkbox.check_on_custom_answer) then
				cfg.settings.on_custom_answer = not cfg.settings.on_custom_answer
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Кастом ответ на репорт')
			if imadd.ToggleButton("##virtualkey", checkbox.check_keysync) then
				cfg.settings.keysync = not cfg.settings.keysync
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Виртуал. клавиши')
			imgui.SameLine()
			imgui.SetCursorPosX(197)
			if imgui.Button(fa.ICON_ARROWS..'##1') then
				if windows.recon_menu.v then
					lua_thread.create(function()
						sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
						sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
						local old_pos_x, old_pos_y = cfg.settings.keysyncx, cfg.settings.keysyncy
						while true do
							cfg.settings.keysyncx, cfg.settings.keysyncy = getCursorPos()
							if isKeyJustPressed(VK_RETURN) then save() break end
							if isKeyJustPressed(VK_ESCAPE) then cfg.settings.keysyncx = old_pos_x cfg.settings.keysyncy = old_pos_y break end
							wait(1)
						end
					end)
				else sampAddChatMessage(tag .. 'Данная опция доступна только в реконе.', -1) end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(250)
			if imadd.ToggleButton("##renderEars", checkbox.check_render_ears) then
				if not sampIsDialogActive() then
					if checkbox.check_render_ears.v then ears = {} end
					sampSendChat('/ears')
				else sampAddChatMessage(tag .. 'У вас открыт диалог.',-1) end
			end
			imgui.SameLine()
			imgui.Text(u8'Рендер /ears')    
			imgui.SameLine()
			imgui.SetCursorPosX(408)
			if imgui.Button(fa.ICON_ARROWS..'##2') then imgui.OpenPopup('settings_ears') end
			if imgui.BeginPopup('settings_ears') then  
				imgui.Text(u8'Размер: ')
				imgui.SameLine()
				imgui.PushItemWidth(20)
				if imgui.Combo('##color2', checkbox.selected_item, {'1', '2', '3', '4', '5', '6', '7', '8', '9'}, 9) then
					if checkbox.selected_item.v == 0 then cfg.settings.size_ears = 9
					elseif checkbox.selected_item.v == 1 then cfg.settings.size_ears = 10
					elseif checkbox.selected_item.v == 2 then cfg.settings.size_ears = 11
					elseif checkbox.selected_item.v == 3 then cfg.settings.size_ears = 12
					elseif checkbox.selected_item.v == 4 then cfg.settings.size_ears = 13
					elseif checkbox.selected_item.v == 5 then cfg.settings.size_ears = 14
					elseif checkbox.selected_item.v == 6 then cfg.settings.size_ears = 15
					elseif checkbox.selected_item.v == 7 then cfg.settings.size_ears = 16
					elseif checkbox.selected_item.v == 8 then cfg.settings.size_ears = 17 end
					save()
					font_earschat = renderCreateFont("Calibri", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)
				end
				imgui.PopItemWidth()
				imgui.Text(u8'Кол-во строк: ')
				imgui.SameLine()
				imgui.PushItemWidth(20)
				if imgui.Combo('##stroki2', checkbox.selected_item, {'3', '6', '9', '12', '15','20'}, 6) then -- счет на -1 число, т.к счет идет с 0
					if checkbox.selected_item.v == 0 then cfg.settings.strok_ears = 2
					elseif checkbox.selected_item.v == 1 then cfg.settings.strok_ears = 5
					elseif checkbox.selected_item.v == 2 then cfg.settings.strok_ears = 8
					elseif checkbox.selected_item.v == 3 then cfg.settings.strok_ears = 11
					elseif checkbox.selected_item.v == 4 then cfg.settings.strok_ears = 14
					elseif checkbox.selected_item.v == 5 then cfg.settings.strok_ears = 19 end
					if #ears > cfg.settings.strok_ears then for i = #ears, cfg.settings.strok_ears do ears[i] = nil end end
					save()
				end
				if imgui.Button(u8'Изменить позицию') then
					if render_ears then
						lua_thread.create(function()
							if not ears[1] then ears[1] = 'Тестовое сообщение для видимости новой позиции.' end 
							sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
							sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
							local old_pos_x, old_pos_y = cfg.settings.position_ears_x, cfg.settings.position_ears_y
							while true do
								cfg.settings.position_ears_x, cfg.settings.position_ears_y = getCursorPos()
								if isKeyJustPressed(VK_RETURN) then save() break end
								if isKeyJustPressed(VK_ESCAPE) then cfg.settings.position_ears_x = old_pos_x cfg.settings.position_ears_y = old_pos_y break end
								wait(1)
							end
						end)
					else sampAddChatMessage(tag .. 'Функция выключена, включите её и сохраните позицию.', -1) end
				end
				imgui.PopItemWidth()
				imgui.EndPopup()
			end
			if imadd.ToggleButton("##AdminChat", checkbox.check_admin_chat) then
				if cfg.settings.admin_chat then adminchat = {} end
				cfg.settings.admin_chat = not cfg.settings.admin_chat
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Админ чат')
			imgui.SameLine()
			imgui.SetCursorPosX(197)
			if imgui.Button(fa.ICON_ARROWS..'##3') then imgui.OpenPopup('settings_adminchat') end
			if imgui.BeginPopup('settings_adminchat') then
				imgui.Text(u8'Размер: ')
				imgui.SameLine()
				imgui.PushItemWidth(20)
				if imgui.Combo('##color', checkbox.selected_item, {'1', '2', '3', '4', '5', '6', '7', '8', '9'}, 9) then
					if checkbox.selected_item.v == 0 then cfg.settings.size_adminchat = 9
					elseif checkbox.selected_item.v == 1 then cfg.settings.size_adminchat = 10
					elseif checkbox.selected_item.v == 2 then cfg.settings.size_adminchat = 11
					elseif checkbox.selected_item.v == 3 then cfg.settings.size_adminchat = 12
					elseif checkbox.selected_item.v == 4 then cfg.settings.size_adminchat = 13
					elseif checkbox.selected_item.v == 5 then cfg.settings.size_adminchat = 14
					elseif checkbox.selected_item.v == 6 then cfg.settings.size_adminchat = 15
					elseif checkbox.selected_item.v == 7 then cfg.settings.size_adminchat = 16
					elseif checkbox.selected_item.v == 8 then cfg.settings.size_adminchat = 17 end
					save()
					font_adminchat = renderCreateFont("Calibri", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW)
				end
				imgui.PopItemWidth()
				imgui.Text(u8'Кол-во строк: ')
				imgui.SameLine()
				imgui.PushItemWidth(20)
				if imgui.Combo('##stroki', checkbox.selected_item, {'3', '6', '9', '12'}, 4) then -- счет на -1 число, т.к счет идет с 0
					if checkbox.selected_item.v == 0 then cfg.settings.strok_admin_chat = 2
					elseif checkbox.selected_item.v == 1 then cfg.settings.strok_admin_chat = 5
					elseif checkbox.selected_item.v == 2 then cfg.settings.strok_admin_chat = 8
					elseif checkbox.selected_item.v == 3 then cfg.settings.strok_admin_chat = 11 end
					if #adminchat > cfg.settings.strok_admin_chat then for i = #adminchat, cfg.settings.strok_admin_chat do adminchat[i] = nil end end
					save()
				end
				imgui.PopItemWidth()
				if imgui.Button(u8'Изменить позицию') then
					lua_thread.create(function()
						if not adminchat[1] then adminchat[1] = 'Тестовое сообщение для видимости новой позиции.' end 
						sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
						sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
						local old_pos_x, old_pos_y = cfg.settings.position_adminchat_x, cfg.settings.position_adminchat_y
						while true do
							cfg.settings.position_adminchat_x, cfg.settings.position_adminchat_y = getCursorPos()
							if isKeyJustPressed(VK_RETURN) then save() break end
							if isKeyJustPressed(VK_ESCAPE) then cfg.settings.position_adminchat_x = old_pos_x cfg.settings.position_adminchat_y = old_pos_y break end
							wait(1)
						end
					end)
				end
				imgui.EndPopup()
			end
			imgui.SameLine()
			imgui.SetCursorPosX(250)
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
			imgui.Text(u8'Рендер /admins')
			imgui.SameLine()
			if imgui.Button(fa.ICON_ARROWS..'##4') then
				if cfg.settings.render_admins then
				lua_thread.create(function()
					windows.menu_tools.v = false
					windows.render_admins.v = true
					sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
					sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
					local old_pos_x, old_pos_y = cfg.settings.render_admins_positionX, cfg.settings.render_admins_positionY
					while true do
						showCursor(true,false)
						cfg.settings.render_admins_positionX, cfg.settings.render_admins_positionY = getCursorPos()
						if isKeyJustPressed(VK_RETURN) then save() break end
						if isKeyJustPressed(VK_ESCAPE) then cfg.settings.render_admins_positionX = old_pos_x cfg.settings.render_admins_positionY = old_pos_y break end
						wait(1)
					end
					showCursor(false,false)
				end)
				else sampAddChatMessage(tag .. 'Опция выключена, включите её и задайте позицию.',-1) end
			end
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
			if imgui.Button(fa.ICON_ARROWS..'##5') then
				if cfg.settings.on_custom_recon_menu then
					if windows.recon_menu.v then
						lua_thread.create(function()
							sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
							sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
							local old_pos_x, old_pos_y = cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y
							while true do
								cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y = getCursorPos()
								if isKeyJustPressed(VK_RETURN) then save() break end
								if isKeyJustPressed(VK_ESCAPE) then cfg.settings.position_recon_menu_x = old_pos_x cfg.settings.position_recon_menu_y = old_pos_y break end
								wait(1)
							end
						end)
					else sampAddChatMessage(tag .. 'Данная опция доступна только в реконе.', -1) end
				else sampAddChatMessage(tag ..'Функция выключена, включите её и задайте позицию', -1) end
			end
			if windows.recon_menu.v then
				imgui.Text(u8'На данный момент вы находитесь в реконе.\nАктивация курсора - клавиша F или правая кнопка мыши.')
			end
			imgui.SetCursorPosY(370)
			imgui.Separator()
			imgui.Text(u8'Разработчик скрипта - N.E.O.N [RDS 01].')
			imgui.Text(u8'Обратная связь:')
			imgui.SameLine()
			if imgui.Link("https://vk.com/alexandrkob", u8"Нажми, чтобы открыть ссылку в браузере") then
				os.execute(('explorer.exe "%s"'):format("https://vk.com/alexandrkob"))
			end
			imgui.Text(u8'Группа VK:')
			imgui.SameLine()
			if imgui.Link("https://vk.com/club222702914", u8"Нажми, чтобы открыть ссылку в браузере") then
				os.execute(('explorer.exe "%s"'):format("https://vk.com/club222702914"))
			end
			imgui.Text(u8'Есть предложения по улучшению проекта?')
			imgui.Text(u8'Произошёл баг или краш скрипта?')
			imgui.Text(u8'Отправляй скрин в VK (Ё ~) или файл moonloader/moonloader.log')
		end
		if menu2[3] then
			imgui.SetCursorPosX(8)
			imgui.CenterText(u8'Дополнительный текст команд')
			imgui.PushItemWidth(485)
			if imgui.InputText('##doptextcommand', buffer.add_new_text) then
				cfg.settings.mytextreport = u8:decode(buffer.add_new_text.v)
				save()	
			end
			imgui.PopItemWidth()
			imgui.Separator()
			imgui.Text(u8'Префикс Хелпера')
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			imgui.PushItemWidth(100)
			if imgui.InputText('##prfh', buffer.new_prfh) then
				cfg.settings.prefixh = buffer.new_prfh.v
				save()
			end
			imgui.PopItemWidth()
			imgui.Text(u8'Префикс Младшего Администратора')
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			imgui.PushItemWidth(100)
			if imgui.InputText('##prfma', buffer.new_prfma) then
				cfg.settings.prefixma = buffer.new_prfma.v
				save()
			end
			imgui.PopItemWidth()
			imgui.Text(u8'Префикс Администратора')
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			imgui.PushItemWidth(100)
			if imgui.InputText('##prfa', buffer.new_prfa) then
				cfg.settings.prefixa = buffer.new_prfa.v
				save()
			end
			imgui.PopItemWidth()
			imgui.Text(u8'Префикс Старшего Администратора')
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			imgui.PushItemWidth(100)
			if imgui.InputText('##prfsa', buffer.new_prfsa) then
				cfg.settings.prefixsa = buffer.new_prfsa.v
				save()
			end
			imgui.PopItemWidth()
			imgui.Separator()
			if imgui.Button(u8'Fast Spawn', imgui.ImVec2(250, 24)) then
				windows.menu_tools.v = false
				sampProcessChatInput('/fs')
			end
			imgui.SameLine()
			if imgui.Button(u8'Трассера', imgui.ImVec2(228, 24)) then
				windows.menu_tools.v = false
				sampProcessChatInput('/trassera')
			end
			if imgui.Button(u8'Статистика за день', imgui.ImVec2(250, 24)) then
				sampProcessChatInput('/state')
				windows.menu_tools.v = false
				showCursor(true,false)
			end
			imgui.SameLine()
			if imgui.Button(u8'Чат-логгер', imgui.ImVec2(228, 24)) then windows.menu_chatlogger.v = true windows.menu_tools.v = false end
			if imgui.Button(u8'Авто-отправка форм для младших администраторов', imgui.ImVec2(485, 24)) then imgui.OpenPopup('autoform') end
			if imgui.BeginPopup('autoform') then
				imgui.CenterText(u8'Каких доступов у вас нет?')
				if imgui.Checkbox('/ban', checkbox.check_form_ban) then
					cfg.settings.forma_na_ban = not cfg.settings.forma_na_ban
					save()
				end
				if imgui.Checkbox('/jail', checkbox.check_form_jail) then
					cfg.settings.forma_na_jail = not cfg.settings.forma_na_jail
					save()
				end
				if imgui.Checkbox('/mute', checkbox.check_form_mute) then
					if not cfg.settings.automute then
						cfg.settings.forma_na_mute = not cfg.settings.forma_na_mute
					else 
						cfg.settings.forma_na_mute = false
						checkbox.check_form_mute = imgui.ImBool(cfg.settings.forma_na_mute)
						sampAddChatMessage(tag .. 'У вас включен автомут, во избежания фарма данные опции совместно запрещены.', -1)
					end
					save()
				end
				if imgui.Checkbox('/kick', checkbox.check_form_kick) then
					cfg.settings.forma_na_kick = not cfg.settings.forma_na_kick
					save()
				end
				if imgui.Checkbox(u8'Добавлять // мой ник', checkbox.check_add_mynick_form) then
					cfg.settings.add_mynick_in_form = not cfg.settings.add_mynick_in_form
					save()
				end
				imgui.EndPopup()
			end
			imgui.SetCursorPosY(470)
			if imgui.Button(u8'Перезагрузить скрипт '..fa.ICON_RECYCLE, imgui.ImVec2(250,24)) then reloadScripts() end
			imgui.SameLine()
			if imgui.Button(u8'Выгрузить скрипт ' .. fa.ICON_POWER_OFF, imgui.ImVec2(228, 24)) then ScriptExport() end
		end
		if menu2[4] then
			buffer.bloknotik.v = string.gsub(buffer.bloknotik.v, "\\n", "\n")
			if imgui.InputTextMultiline("##1", buffer.bloknotik, imgui.ImVec2(495, 500)) then
				buffer.bloknotik.v = string.gsub(buffer.bloknotik.v, "\n", "\\n")
				cfg.settings.bloknotik = u8:decode(buffer.bloknotik.v)
				save()	
			end
		end
		if menu2[5] then
			imgui.SetCursorPosX(8)
			imgui.NewInputText('##SearchBar7', buffer.new_binder_key, 485, u8'Текст биндера', 2)
			if imgui.Button(u8'Добавить', imgui.ImVec2(250,24)) and #(u8:decode(buffer.new_binder_key.v)) ~= 0 then
				if getDownKeysText() then
					cfg.binder_key[getDownKeysText()] = u8:decode(buffer.new_binder_key.v)
					save()
				else sampAddChatMessage(tag .. 'Зажмите клавишу, на которую хотите сохранить биндер', -1) end
			end
			imgui.SameLine()
			if imgui.Button(u8'Удалить', imgui.ImVec2(228,24)) and #(u8:decode(buffer.new_binder_key.v)) ~= 0 then
				for k,v in pairs(cfg.binder_key) do
					if u8:decode(buffer.new_binder_key.v) == v then
						cfg.binder_key[k] = nil
						save()
						sampAddChatMessage(tag .. 'Биндер удален.', -1)
					end
				end 
			end
			imgui.Separator()
			imgui.CenterText(u8'Открытие репорта:')
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_ans))
			if imgui.Button(u8"Сoxрaнить.", imgui.ImVec2(250, 24)) then
				if getDownKeysText() and not getDownKeysText():find('+') then
					cfg.settings.fast_key_ans = getDownKeysText()
					save()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'Сброcить', imgui.ImVec2(228,24)) then
				cfg.settings.fast_key_ans = 'None'
				save()
			end
			imgui.CenterText(u8"Отправка в чат доп.текста")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_addText))
			if imgui.Button(u8"Coxрaнить.", imgui.ImVec2(250, 24)) then
				if getDownKeysText() and not getDownKeysText():find('+') then
					cfg.settings.fast_key_addText = getDownKeysText()
					save()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'Сбросить', imgui.ImVec2(228,24)) then
				cfg.settings.fast_key_addText = 'None'
				save()
			end
			imgui.CenterText(u8"Вкл/выкл WallHack")
			imgui.SameLine()
			imgui.Text(u8(cfg.settings.fast_key_wallhack))
			if imgui.Button(u8"Coxрaнить. ", imgui.ImVec2(250, 24)) then
				if getDownKeysText() and not getDownKeysText():find('+') then
					cfg.settings.fast_key_wallhack = getDownKeysText()
					save()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'Сбрoсить', imgui.ImVec2(228,24)) then
				cfg.settings.fast_key_wallhack = 'None'
				save()
			end
			imgui.Separator()
			imgui.CenterText(u8'[Мои быстрые клавиши]')
			for k, v in pairs(cfg.binder_key) do
				imgui.Text(u8('[Клавиша '..k..'] ='))
				imgui.SameLine()
				imgui.Text(u8(v))
			end
			imgui.SetCursorPosY(475)
			if getDownKeysText() then imgui.Text(u8'Зажата клавиша: ' .. getDownKeysText())
			else imgui.Text(u8'Нет зажатых клавиш') end
			imgui.SameLine()
			imgui.SetCursorPosX(253)
			if imgui.Button(u8"Сбросить значения моих клавиш") then
				for k,v in pairs(cfg.binder_key) do cfg.binder_key[k] = nil end
				save()
			end
		end
		if menu2[7] then
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'Мои флуды', imgui.ImVec2(410, 25)) then
				windows.new_flood_mess.v = not windows.new_flood_mess.v 
			end
			imgui.CenterText(u8'Флуды /gw')
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'Aztecas vs Ballas', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Varios Los Aztecas vs Ballas Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Aztecas vs Grove', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Varios Los Aztecas vs Grove Street Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Aztecas vs Vagos', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Varios Los Aztecas vs Vagos Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
			end
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'Aztecas vs Rifa', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Varios Los Aztecas vs The Rifa ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Ballas vs Grove', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Ballas Gang vs Grove Street Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Ballas vs Vagos', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Ballas Gang vs Vagos Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
			end
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'Ballas vs Rifa', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Ballas Gang vs The Rifa ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Grove vs Vagos', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Grove Street Gang vs Vagos Gang ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Vagos vs Rifa', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				sampSendChat('/mess 14 На данный момент проходит вооруженное сражение двух враждебных группировок.')
				sampSendChat('/mess 14 ## Vagos Gang vs The Rifa ##')
				sampSendChat('/mess 14 Помоги братьям отстоять свою территорию и защитить честь банды, вводи /gw!')
				sampSendChat('/mess 11 --------===================| GangWar |================-----------')
			end
			imgui.CenterText(u8'Общие флуды')
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'Спавн авто', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 10 --------===================| Spawn Auto |================-----------')
				sampSendChat('/mess 15 Многоуважаемые дрифтеры и дрифтерши')
				sampSendChat('/mess 15 Через 15 секунд пройдёт респавн всего транспорта на сервере.')
				sampSendChat('/mess 15 Займите свои супер кары во избежания потери :3')
				sampSendChat('/mess 10 --------===================| Spawn Auto |================-----------')
				sampSendChat('/delcarall')
				sampSendChat('/spawncars 15')
			end
			imgui.SameLine()
			if imgui.Button(u8'/trade', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 3 --------===================| Рынок |================-----------')
				sampSendChat('/mess 0 Мечтал приобрести акксессуары на свой скин?')
				sampSendChat('/mess 0 Бегать с ручным попугайчиком на плече и светится как боженька?')
				sampSendChat('/mess 0 Скорей вводи /trade, большой выбор ассортимента, как от сервера, так и от игроков!')
				sampSendChat('/mess 3 --------===================| Рынок |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Автомастерская', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 16 --------===================| Автомастерская |================-----------')
				sampSendChat('/mess 17 Всегда мечтал приобрести ковш на свой кибертрак? Не проблема!')
				sampSendChat('/mess 17 В автомастерских из /tp - разное - автомастерские найдется и не такое.')
				sampSendChat('/mess 17 Сделай апгрейд своего любимчика под свой вкус и цвет')
				sampSendChat('/mess 16 --------===================| Автомастерская |================-----------')
			end
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'Группа/Форум', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 11 --------===================| Сторонние площадки |================-----------')
				sampSendChat('/mess 7 У нашего проекта имеется группа vk.сom/teamadmrds ...')
				sampSendChat('/mess 7 ... и даже форум, на котором игроки могут оставить жалобу на администрацию или игроков.')
				sampSendChat('/mess 7 Следи за новостями и будь вкурсе событий.')
				sampSendChat('/mess 11 --------===================| Сторонние площадки |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'VIP', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 13 --------===================| Преимущества VIP |================-----------')
				sampSendChat('/mess 7 Хочешь играть с друзьями без дискомфорта?')
				sampSendChat('/mess 7 Хочешь всегда телепортироваться по карте и к друзьям, чтобы быть всегда вместе?')
				sampSendChat('/mess 7 Хочешь получать каждый PayDay плюшки на свой аккаунт? Обзаведись VIP-статусом!')
				sampSendChat('/mess 13 --------===================| Преимущества VIP |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Арене', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 12 --------===================| PVP Arena |================-----------')
				sampSendChat('/mess 10 Не знаешь чем заняться? Хочется экшена и быстрой реакции?')
				sampSendChat('/mess 10 Вводи /arena и покажи на что ты способен!')
				sampSendChat('/mess 10 Набей максимальное количество киллов, добейся идеала в своем +C')
				sampSendChat('/mess 12 --------===================| PVP Arena |================-----------')
			end
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'Виртуальный мир', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Твой виртуальный мир |================-----------')
				sampSendChat('/mess 15 Мешают играть? Постоянно преследуют танки и самолёты?')
				sampSendChat('/mess 15 Обычный пассив режим не спасает во время дрифта?')
				sampSendChat('/mess 15 Выход есть! Вводи /dt [0-999] и дрифти с комфортом.')
				sampSendChat('/mess 8 --------===================| Твой виртуальный мир |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Набор на админку', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 3 --------===================| Набор на пост администратора |================-----------')
				sampSendChat('/mess 2 Мечтал встать на пост администратора? Чистить сервер от читеров и нарушителей?')
				sampSendChat('/mess 2 Всё это возможно и совершенно бесплатно <3')
				sampSendChat('/mess 2 На нашем форуме https://forumrds.ru/ открыт набор, успей подать заявку, кол-во мест ограничено.')
				sampSendChat('/mess 3 --------===================| Набор на пост администратора |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'О /report', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 17 --------===================| Связь с администрацией |================-----------')
				sampSendChat('/mess 13 Нашел читера, злостного нарушителя, ДМера, или просто мешают играть?')
				sampSendChat('/mess 13 Появился вопрос о возможностях сервера или его особенностей?')
				sampSendChat('/mess 13 Администрация поможет! Пиши /report и свою жалобу/вопрос')
				sampSendChat('/mess 17 --------===================| Связь с администрацией |================-----------')
			end
			imgui.CenterText(u8'Мероприятия /join')
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'Дерби', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Мероприятие Дерби |================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Дерби')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 1')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------===================| Мероприятие Дерби |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Паркур', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Мероприятие /parkour |================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Паркур')
				sampSendChat('/mess 0 Чтобы принять участие вводи /parkour либо /join - 2')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------===================| Мероприятие /parkour |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'PUBG', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Мероприятие /pubg |================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Pubg')
				sampSendChat('/mess 0 Чтобы принять участие вводи /pubg либо /join - 3')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------===================| Мероприятие /pubg |================-----------')
			end
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'DAMAGE DEATHMATCH', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Мероприятие /damagegm |================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие DAMAGE DEATHMATCH')
				sampSendChat('/mess 0 Чтобы принять участие вводи /damagegm либо /join - 4')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------===================| Мероприятие /damagegm |================-----------')
	
			end
			imgui.SameLine()
			if imgui.Button(u8'KILL DEATHMATCH', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Мероприятие KILL DEATHMATCH |================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие DAMAGE DEATHMATCH')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 5')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------===================| Мероприятие KILL DEATHMATCH |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Paint Ball', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Мероприятие Paint Ball |================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Paint Ball')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 7')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------===================| Мероприятие Paint Ball |================-----------')
			end
			imgui.SetCursorPosX(50)
			if imgui.Button(u8'Зомби vs Людей', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Зомби против людей |================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Зомби против людей')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 8')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------===================| Зомби против людей |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Прятки', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Мероприятие Прятки |================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Прятки')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 10')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------===================| Мероприятие Прятки |================-----------')
			end
			imgui.SameLine()
			if imgui.Button(u8'Догонялки', imgui.ImVec2(130, 25)) then
				sampSendChat('/mess 8 --------===================| Мероприятие Догонялки |================-----------')
				sampSendChat('/mess 0 На данный момент проходит сбор игроков на мероприятие Догонялки')
				sampSendChat('/mess 0 Чтобы принять участие вводи /join - 11')
				sampSendChat('/mess 0 Поторопись! Количество мест ограничено.')
				sampSendChat('/mess 8 --------===================| Мероприятие Догонялки |================-----------')
			end
		end
		if menu2[2] then
			imgui.SetCursorPosX(125)
			if imgui.Button(u8'Добавить мой ответ', imgui.ImVec2(250, 24)) and #(buffer.custom_answer.v) > 1 then
				cfg.customotvet[#(cfg.customotvet) + 1] = u8:decode(buffer.custom_answer.v)
				save()
				buffer.custom_answer.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.NewInputText('##SearchBar2', buffer.custom_answer, 485, u8'Введите ваш ответ.', 2)
			imgui.Separator()
			imgui.CenterText(u8'Сохраненные ответы')
			for k,v in pairs(cfg.customotvet) do
				if imgui.Button(u8(v), imgui.ImVec2(485, 24)) then
					cfg.customotvet[k] = nil
					save()
				end
				imgui.Tooltip(u8'Нажми, чтобы удалить ответ.')
			end
		end
		if menu2[8] then
			imgui.SetCursorPosX(10)
			imgui.Checkbox('##celoeslovo', checkbox.add_full_words)
			imgui.Tooltip(u8'Добавить в автомут целое слово')
			imgui.SameLine()
			imgui.CenterText(u8'Добавить мат (Всего в словаре: ' .. #mat..')')
			imgui.PushItemWidth(430)
			imgui.InputText('##newmat', buffer.newmat)
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(440)
			if (imgui.Button(fa.ICON_CHECK, imgui.ImVec2(24,24)) and (string.len(u8:decode(buffer.newmat.v))>=2)) or (isKeyJustPressed(VK_RETURN) and (string.len(u8:decode(buffer.newmat.v))>=2)) then
				buffer.newmat.v = u8:decode(buffer.newmat.v)
				buffer.newmat.v = buffer.newmat.v:rlower()
				for k, v in pairs(mat) do
					if mat[k] == buffer.newmat.v then
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newmat.v .. ' {F0E68C}уже имеется в списке матов.', -1)
						find_words = true
						break
					end
				end
				if not find_words then
					table.insert(mat, buffer.newmat.v)
					local AutoMute_mat = io.open(getWorkingDirectory() .. "\\config\\AT\\mat.txt", "a")
					if checkbox.add_full_words.v then AutoMute_mat:write(u8(buffer.newmat.v..'%s') .. '\n')
					else AutoMute_mat:write(u8(buffer.newmat.v) .. '\n') end
					AutoMute_mat:close()
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newmat.v .. ' {F0E68C}было успешно добавлено в список матов.', -1)
				end
				find_words = nil
				buffer.newmat.v = u8(buffer.newmat.v)
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(465)
			if imgui.Button(fa.ICON_BAN, imgui.ImVec2(24,24)) and string.len(u8:decode(buffer.newmat.v)) >= 2 then
				buffer.newmat.v = u8:decode(buffer.newmat.v)
				buffer.newmat.v = buffer.newmat.v:rlower()
				for k, v in pairs(mat) do
					if mat[k] == buffer.newmat.v then
						table.remove(mat, k)
						local AutoMute_mat = io.open(getWorkingDirectory() .. "\\config\\AT\\mat.txt", "w") 
						AutoMute_mat:close()
						local AutoMute_mat = io.open(getWorkingDirectory() .. "\\config\\AT\\mat.txt", "a")
						for i = 1, #mat do if mat[i] and #(mat[i]) > 2 then AutoMute_mat:write(u8(mat[i]) .. "\n") end end
						AutoMute_mat:close()
						find_words = true
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Выбранное вами слово{008000} ' .. buffer.newmat.v .. ' {F0E68C}было успешно удалено из списка матов', -1)
						break
					end
				end
				if not find_words then sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Такого слова в списке матов нет.', -1) end
				find_words = nil
				buffer.newmat.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.CenterText(u8'Добавить оскорбление (Всего в словаре: ' .. #osk .. ')')
			imgui.PushItemWidth(430)
			imgui.InputText('##newosk', buffer.newosk)
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(440)
			if (imgui.Button(fa.ICON_CHECK .. '##', imgui.ImVec2(24,24)) and (string.len(u8:decode(buffer.newosk.v))>=2)) or (isKeyJustPressed(VK_RETURN) and (string.len(u8:decode(buffer.newosk.v))>=2)) then
				buffer.newosk.v = u8:decode(buffer.newosk.v)
				buffer.newosk.v = buffer.newosk.v:rlower()
				for k, v in pairs(osk) do
					if osk[k] == buffer.newosk.v then
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newosk.v .. ' {F0E68C}уже имеется в списке оскорблений.', -1)
						find_words = true
						break
					end
				end
				if not find_words then
					table.insert(osk, buffer.newosk.v)
					local AutoMute_osk = io.open(getWorkingDirectory() .. "\\config\\AT\\osk.txt", "a")
					if checkbox.add_full_words.v then AutoMute_osk:write(u8(buffer.newosk.v .. '%s') .. '\n')
					else AutoMute_osk:write(u8(buffer.newosk.v .. '%s') .. '\n') end
					AutoMute_osk:close()
					sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newosk.v .. ' {F0E68C}было успешно добавлено в список оскорблений.', -1)
				end
				find_words = nil
				buffer.newosk.v = u8(buffer.newosk.v)
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(465)
			if imgui.Button(fa.ICON_BAN .. '##', imgui.ImVec2(24,24)) and string.len(u8:decode(buffer.newosk.v)) >= 2 then
				buffer.newosk.v = u8:decode(buffer.newosk.v)
				buffer.newosk.v = buffer.newosk.v:lower()
				buffer.newosk.v = buffer.newosk.v:rlower()
				for k, v in pairs(osk) do
					if osk[k] == buffer.newosk.v then
						table.remove(osk, k)
						local AutoMute_osk = io.open(getWorkingDirectory() .. "\\config\\AT\\osk.txt", "w") 
						AutoMute_osk:close()
						local AutoMute_osk = io.open(getWorkingDirectory() .. "\\config\\AT\\osk.txt", "a")
						for i = 1, #osk do if osk[i] and #(osk[i]) > 2 then AutoMute_osk:write(u8(osk[i]) .. "\n") end end
						AutoMute_osk:close()
						find_words = true
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Выбранное вами слово{008000} ' .. buffer.newosk.v .. ' {F0E68C}было успешно удалено из списка оскорблений', -1)
						break
					end
				end
				if not find_words then sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Такого слова в списке оскорблений нет.', -1) end
				find_words = nil
				buffer.newosk.v = ''
				imgui.SetKeyboardFocusHere(-1)
			end
			imgui.CenterText(u8'Выберите тему оформления')
			imgui.PushItemWidth(480)
			if imgui.Combo("##selected", checkbox.style_selected, {u8"Темно-Синяя тема", u8"Красная тема", u8"Зеленая тема", u8"Бирюзовая тема", u8"Розовая тема", u8"Голубая тема"}, checkbox.style_selected) then
				cfg.settings.style = checkbox.style_selected.v 
				save()
				sampAddChatMessage(tag ..'Произвожу перезагрузку для сихронизации RGB цветов...', -1)
				reloadScripts()
			end
			imgui.PopItemWidth()
			imgui.CenterText(u8'Добавить быструю команду')
			imgui.SameLine()
			imgui.Text('(?)')
			imgui.Tooltip(u8'Символ "_" без кавычек принимает введенный аргумент\nКоманда wait добавляет задержку, пример: wait(5) (это 5 сек)\nПример: /mute _ 400 оскорбление')
			imgui.NewInputText('##titlecommand5', buffer.new_command_title, 480, u8'Команда (пример: /ok, /dz, /ch)', 2)
			imgui.InputTextMultiline("##newcommand", buffer.new_command, imgui.ImVec2(480, 200))
			if imgui.Button(u8'Сохрaнить', imgui.ImVec2(250, 24)) then
				if #(u8:decode(buffer.new_command_title.v)) ~= 0 and #(u8:decode(buffer.new_command.v)) > 2 then
					buffer.new_command_title.v = string.gsub(buffer.new_command_title.v, '%/', '')
					cfg.my_command[buffer.new_command_title.v] = string.gsub(u8:decode(buffer.new_command.v),'\n','\\n')
					save()
					buffer.new_command.v = string.gsub(buffer.new_command.v, '\\n','\n') 
					local v = string.gsub(cfg.my_command[buffer.new_command_title.v], '\\n','\n') 
					sampRegisterChatCommand(buffer.new_command_title.v, function(param) 
						lua_thread.create(function() 
							for a,b in pairs(textSplit(string.gsub(v, '_', param), '\n'))  do 
								if b:match('wait(%(%d+)%)') then 
									wait(tonumber(b:match('%d+') .. '000')) 
								else sampSendChat(b) end 
							end 
						end) 
					end) 
					sampAddChatMessage(tag .. 'Новая команда /' .. buffer.new_command_title.v .. ' успешно создана.',-1)
					buffer.new_command.v, buffer.new_command_title.v = '',''
				else sampAddChatMessage(tag .. 'Что вы собрались сохранять?', -1) end
			end
			imgui.SameLine()
			if imgui.Button(u8'Удалить', imgui.ImVec2(228, 24)) then
				if #(buffer.new_command_title.v) == 0 then sampAddChatMessage(tag ..'Вы не указали название команды, что вы собрались удалять?', -1)
				else
					buffer.new_command_title.v = string.gsub(u8:decode(buffer.new_command_title.v), '/', '')
					if cfg.my_command[buffer.new_command_title.v] then
						cfg.my_command[buffer.new_command_title.v] = nil
						sampAddChatMessage(tag .. 'Команда была успешно удалена. Перестанет действовать после перезагрузки игры.', -1)
					else sampAddChatMessage(tag .. 'Такой команды в базе данных нет.', -1) end
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
		imgui.Text(u8('Игрок: '..autor .. '[' ..autorid.. ']'))
		imgui.SameLine()
		if tonumber(autorid) then 				-- Если игрок в сети
			imgui.Text(fa.ICON_EYE) 			-- Иконка глаза
			if imgui.IsItemClicked(0) or (isKeyDown(VK_X) and not sampIsChatInputActive()) then
				answer.rabotay = true 			-- Отправляем что работает по жалобе
				answer.control_player = true 	-- Переходим в рекон
			end
			imgui.Tooltip('X')
			imgui.SameLine()
		end
		imgui.Text(fa.ICON_FILES_O)
		if imgui.IsItemClicked(0) then 
			setClipboardText(autor)
			sampAddChatMessage(tag .. 'Ник скопирован в буффер обмена.', -1)
		end
		imgui.TextWrapped(u8('Жалоба: ' .. textreport))
		if isKeyJustPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end 
		imgui.NewInputText('##SearchBar', buffer.text_ans, 375, u8'Введите ваш ответ.', 2)
		imgui.SameLine()
		imgui.SetCursorPosX(392)
		imgui.Tooltip('Space')
		if imgui.Button(u8'Отправить ' .. fa.ICON_SHARE, imgui.ImVec2(120, 25)) then
			if #(u8:decode(buffer.text_ans.v)) ~= 0 then answer.moiotvet = true
			else sampAddChatMessage(tag .. 'Ответ не менее 1 символа.', -1) end
		end
		imgui.Tooltip('Enter')
		imgui.Separator()
		if #(buffer.text_ans.v) > 2 then
			imgui.CenterText(u8'Сохраненные ответы')
			imgui.SameLine()
			imgui.Text('(?)')
			imgui.Tooltip(u8'Нажатие на ответ - отправляет ответ.\nНажатие на кнопку "Отправить" отправляет ваш ответ, вне зависимости от сохраненных.\nНажатие Enter отправляет 1-ый из предложенных сохраненных ответов при наличии.')
			for k,v in pairs(cfg.customotvet) do
				if string.rlower(v):find(string.rlower(u8:decode(buffer.text_ans.v))) or string.rlower(v):find(translateText(string.rlower(u8:decode(buffer.text_ans.v)))) then
					if imgui.Button(u8(v), imgui.ImVec2((sw * 0.5) - 295, 24)) then
						if not answer.customans then 
							answer.customans = v
						end
					end
				end
			end
		else
			if imgui.Button(u8'Работаю', imgui.ImVec2(120, 25)) or (isKeyDown(VK_Q) and not sampIsChatInputActive()) then
				answer.rabotay = true
			end
			imgui.Tooltip('Q')
			imgui.SameLine()
			if imgui.Button(u8'Слежу', imgui.ImVec2(120, 25)) or (isKeyDown(VK_E) and not sampIsChatInputActive()) then
				answer.slejy = true
			end
			imgui.Tooltip('E')
			imgui.SameLine()
			if imgui.Button('Skin/Color', imgui.ImVec2(120, 25)) or (isKeyJustPressed(VK_R) and not sampIsChatInputActive()) then
				start_my_answer()
			end
			imgui.Tooltip('R')
			imgui.SameLine()
			if imgui.Button(u8'Передать', imgui.ImVec2(120, 25)) or (isKeyDown(VK_V) and not sampIsChatInputActive()) then
				answer.peredamrep = true
			end
			imgui.Tooltip('V')
			if imgui.Button(u8'Наказать', imgui.ImVec2(120, 25)) or (isKeyJustPressed(VK_G) and not sampIsChatInputActive()) then
				if tonumber(autorid) then imgui.OpenPopup('option')
				else sampAddChatMessage(tag .. 'Данный игрок не в сети. Используйте /rmuteoff', -1) end
			end
			if imgui.BeginPopup('option') then
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
				imgui.EndPopup()
			end
			imgui.Tooltip('G')
			imgui.SameLine()
			if imgui.Button(u8'Уточните ID', imgui.ImVec2(120, 25)) or (isKeyDown(VK_B) and not sampIsChatInputActive()) then
				answer.uto4id = true
			end
			imgui.Tooltip('B')
			imgui.SameLine()
			if imgui.Button(u8'Форум', imgui.ImVec2(120, 25)) or (isKeyDown(VK_F) and not sampIsChatInputActive()) then
				answer.uto4 = true
			end
			imgui.Tooltip('F')
			imgui.SameLine()
			if imgui.Button(u8'Отклонить', imgui.ImVec2(120, 25)) or (isKeyDown(VK_Y) and not sampIsChatInputActive()) then
				answer.otklon = true
			end
			imgui.Tooltip('Y')
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
		imgui.Tooltip(u8'Добавляет ваш текст к ответу. Не сработает, если кол-во символов в ответе превысит максимум')
		imgui.SameLine()
		imgui.Text(u8'Сохранить данный ответ в базу данных скрипта')
		if imadd.ToggleButton('##newcolor', checkbox.check_color_report) then
			if cfg.settings.color_report then
				cfg.settings.on_color_report = not cfg.settings.on_color_report
				save()
			else
				checkbox.check_color_report = imgui.ImBool(cfg.settings.on_color_report)
				sampAddChatMessage(tag .. 'Цвет не указан. Сохраните выбранный вами HTML цвет через команду /color_report', -1)
				sampAddChatMessage(tag .. 'Рекомендуется сначала ответить на репорт.',-1)
			end
		end
		imgui.Tooltip(u8'Добавляет окраску к ответу. Не сработает, если кол-во символов в ответе превысит максимум')
		imgui.SameLine()
		imgui.Text(u8'Перекрасить мой ответ в другой цвет')
		imgui.PopFont()
		imgui.End()
	end
	if windows.recon_ban_menu.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.4), sh * 0.4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(265, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Выдать блокировку аккаунта", windows.recon_ban_menu, imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Выберите причину')
		for k,v in pairs(basic_command.ban) do
			local name = string.gsub(string.gsub(string.gsub(v, '/ban _ (%d+) ', ''), '/siban _ (%d+) ', ''), '/iban _ (%d+) ', '')
			if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
				sampSendChat(string.gsub(v, '_', control_player_recon))
				windows.recon_ban_menu.v = false
			end
		end
		imgui.End()
	end
	if windows.recon_jail_menu.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.4), sh * 0.4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(265, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Посадить игрока в тюрьму", windows.recon_jail_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Выберите причину')
		for k,v in pairs(basic_command.jail) do
			local name = string.gsub(v, '/jail _ (%d+) ', '')
			if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
				sampSendChat(string.gsub(v, '_', control_player_recon))
				windows.recon_jail_menu.v = false
			end
		end
		imgui.End()
	end
	if windows.recon_mute_menu.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.4), sh * 0.4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(265, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Заблокировать чат игроку", windows.recon_mute_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Выберите причину')
		for k,v in pairs(basic_command.mute) do
			local name = string.gsub(v, '/mute _ (%d+) ', '')
			if not name:find('x(%d+)') and not name:find('х(%d+)') then
				if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
					if control_player then sampSendChat(string.gsub(v, '_', control_player))
					else sampSendChat(string.gsub(v, '_', control_player_recon)) end
					windows.recon_mute_menu.v = false
					showCursor(false,false)
				end
			end
		end
		imgui.End()
	end
	if windows.recon_kick_menu.v then 
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.4), sh * 0.4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(265, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Кикнуть игрока с сервера", windows.recon_kick_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Выберите причину')
		for k,v in pairs(basic_command.kick) do
			local name = string.gsub(v, '/kick _ ', '')
			if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
				sampSendChat(string.gsub(v, '_', control_player_recon))
				windows.recon_kick_menu.v = false
			end
		end
		imgui.End()
	end
	if windows.recon_menu.v then
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y))
		imgui.Begin("##recon", windows.recon_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.ShowCursor = false
		imgui.PushFont(fontsize)
		if imgui.Button(u8'Игрок ' ..fa.ICON_MALE, imgui.ImVec2(120, 25)) then uu() menu[1] = true end imgui.SameLine()
        if imgui.Button(u8'В радиусе ' .. fa.ICON_USERS, imgui.ImVec2(120, 25)) then uu() menu[2] = true end
        if menu[1] then
			imgui.SetCursorPosX(10)
			if imgui.Button(fa.ICON_FILES_O) then
				setClipboardText(sampGetPlayerNickname(control_player_recon))
				sampAddChatMessage(tag .. 'Ник скопирован в буффер обмена. (ctrl + v)', -1)
			end
			imgui.SameLine()
			if sampIsPlayerConnected(control_player_recon) then 
				imgui.Text(sampGetPlayerNickname(control_player_recon) .. '[' .. control_player_recon .. ']')
			end
			imgui.SameLine()
			imgui.SetCursorPosX(230)
			if mobile_player then imgui.Text(fa.ICON_MOBILE)
			else imgui.Text(fa.ICON_DESKTOP) end
			imgui.Separator()
			if inforeport[14] then
				imgui.Text(u8'Здоровье авто: ' .. inforeport[3])
				imgui.Text(u8'Скорость: ' .. inforeport[4])
				imgui.Text(u8'Оружие: ' .. inforeport[6])
				imgui.Text(u8'Точность: ' .. inforeport[7])
				imgui.Text('Ping: ' .. inforeport[5])
				imgui.Text('AFK: ' .. inforeport[9])
				imgui.Text('VIP: ' .. inforeport[11])
				imgui.Text('Passive mode: ' .. inforeport[12])
				imgui.Text(u8'Турбо пакет: ' .. inforeport[13])
				imgui.Text(u8'Коллизия: ' .. inforeport[14])
			end
			if imgui.Button(u8'Посмотреть первую статистику', imgui.ImVec2(250, 25)) or (isKeyJustPressed(VK_Z) and not (sampIsChatInputActive() or sampIsDialogActive())) then
				sampSendChat('/statpl ' .. sampGetPlayerNickname(control_player_recon))
			end
			if imgui.Button(u8'Посмотреть вторую статистику', imgui.ImVec2(250, 25)) or (isKeyJustPressed(VK_X) and not (sampIsChatInputActive() or sampIsDialogActive())) then
				sampSendClickTextdraw(textdraw.stats)
			end
			if imgui.Button(u8'Посмотреть /offstats статистику', imgui.ImVec2(250, 25)) or (isKeyJustPressed(VK_C) and not (sampIsChatInputActive() or sampIsDialogActive())) then
				sampSendChat('/offstats ' .. sampGetPlayerNickname(control_player_recon))
				sampSendDialogResponse(16196, 1, 0)
			end
        end
        if menu[2] then
			for _,v in pairs(playersToStreamZone()) do
				if v ~= control_player_recon then
					imgui.SetCursorPosX(10)
					if imgui.Button(sampGetPlayerNickname(v) .. '[' .. v .. ']', imgui.ImVec2(250, 25)) then sampSendChat('/re ' .. v) end
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
		if imgui.Button(u8'<- Предыдущий') then
			lua_thread.create(function()
				if control_player_recon < sampGetMaxPlayerId() then
					control_player_recon = control_player_recon - 1
					sampSendChat('/re ' .. control_player_recon)
					while not sampIsPlayerConnected(control_player_recon) do wait(0) end
				end
			end)
		end
		imgui.Tooltip('NumPad 4')
		imgui.SameLine()
		if imgui.Button(u8'Забанить игрока') then
			windows.recon_ban_menu.v = not windows.recon_ban_menu.v
		end
		imgui.SameLine()
		if imgui.Button(u8'Посадить в тюрьму') then
			windows.recon_jail_menu.v = not windows.recon_jail_menu.v
		end
		imgui.SameLine()
		if imgui.Button(u8'Выдать мут') then
			windows.recon_mute_menu.v = not windows.recon_mute_menu.v
		end
		imgui.SameLine()
		if imgui.Button(u8'Кикнуть игрока') then
			windows.recon_kick_menu.v = not windows.recon_kick_menu.v
		end
		imgui.SameLine()
		if imgui.Button(u8'Следующий ->') then
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
		imgui.Tooltip('NumPad 6')
		imgui.SetCursorPosX(40)
		if imgui.Button(u8'Выйти') or (isKeyJustPressed(VK_Q) and not (sampIsChatInputActive() or sampIsDialogActive())) then
			sampSendClickTextdraw(textdraw.close)
		end
		imgui.Tooltip(u8'Q')
		imgui.SameLine()
		if imgui.Button(u8'Слапнуть') then
			sampSendChat('/slap ' .. control_player_recon)
		end
		imgui.SameLine()
		if imgui.Button(u8'Заспавнить')  then
			sampSendChat('/aspawn ' .. control_player_recon)
		end
		imgui.SameLine()
		if imgui.Button(u8'Телепортировать') then
			lua_thread.create(function()
				sampSendChat('/reoff')
				wait(3000)
				sampSendChat('/gethere ' .. control_player_recon)
			end)
		end
		imgui.SameLine()
		if imgui.Button(u8'Телепортироваться')then
			lua_thread.create(function()
				sampSendChat('/reoff')
				wait(3000)
				sampSendChat('/agt ' .. control_player_recon)
			end)
		end
		imgui.SameLine()
		if imgui.Button(u8'Обновить') or (isKeyJustPressed(VK_R) and not (sampIsChatInputActive() or sampIsDialogActive())) then
			sampSendClickTextdraw(textdraw.refresh)
			printStyledString('update...', 200, 4)
			if cfg.settings.keysync then
				lua_thread.create(function()
					wait(1000)
					keysync(control_player_recon)
				end)
			end
		end
		imgui.Tooltip('R')
		if isKeyJustPressed(VK_RBUTTON) and not (sampIsChatInputActive() or sampIsDialogActive()) then
			lua_thread.create(function()
				setVirtualKeyDown(70, true)
				wait(150)
				setVirtualKeyDown(70, false)
			end)
		end
		imgui.End()
	end
	if windows.custom_ans.v then -- свой ответ в репорт
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2((sw*0.5)+15, sh*0.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Мой ответ', windows.custom_ans, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.IsWindowAppearing() then imgui.SetKeyboardFocusHere(-1) end
		if isKeyJustPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end
		if not windows.fast_report.v then windows.custom_ans.v = false end
		imgui.PushFont(fontsize)
		if imgui.RadioButton(u8"ID скинов", checkbox.custom_ans, 0) then
			if not skin then
				skin = {}
				for i = 0, 311 do
					skin[#skin+1] = imgui.CreateTextureFromFile(getWorkingDirectory()..'\\resource\\skin\\skin_'..i..'.png')
				end
			end
		end
		imgui.SameLine()
		if imgui.RadioButton(u8"ID цветов", checkbox.custom_ans, 1) then
			if not html_color then
				html_color = {}
				local file_color = io.open(getWorkingDirectory() .. "\\resource\\skin\\color.txt","r")
				if file_color then for line in file_color:lines() do html_color[#html_color + 1] = u8:decode(line);end file_color:close() end
			end
		end 
		imgui.SameLine()
		if imgui.RadioButton(u8"Названия авто", checkbox.custom_ans, 2) then
			if not auto then
				auto = {}
				for i = 400, 611 do
					auto[#auto+1] = imgui.CreateTextureFromFile(getWorkingDirectory()..'\\resource\\auto\\vehicle_'..i..'.png')
				end
			end
		end
		imgui.Separator()
		if checkbox.custom_ans.v == 0 then
			imgui.CenterText(u8'Выбранный скин будет дополнен к вашему ответу.')
			for i = 1, 312 do
				imgui.Image(skin[i], imgui.ImVec2(75, 150))
				if imgui.IsItemClicked(0) then buffer.text_ans.v = buffer.text_ans.v .. ('ID: '..i-1) end
				if i%9~=0 then imgui.SameLine() end
			end
		elseif checkbox.custom_ans.v == 1 then
			imgui.CenterText(u8'Выбранный цвет будет дополнен к вашему ответу.')
			for i = 1, 256 do 
				imgui.TextColoredRGB(u8(html_color[i]))
				if imgui.IsItemClicked(0) then buffer.text_ans.v = buffer.text_ans.v .. string.sub(string.sub(html_color[i], 1, 7), 2) end 
				if i%7~=0 then imgui.SameLine() end 
			end
		elseif checkbox.custom_ans.v == 2 then
			imgui.CenterText(u8'Выбранный транспорт будет дополнен к вашему ответу.')
			imgui.NewInputText('##SearchBar3', buffer.find_custom_answer, sw*0.5, u8'Фильтр транспорта', 2)			
			for i = 1, 212 do
				if string.lower(name_car[i]):find(string.lower(buffer.find_custom_answer.v)) then
					imgui.Image(auto[i], imgui.ImVec2(120, 100))
					if imgui.IsItemClicked(0) then buffer.text_ans.v =  buffer.text_ans.v .. name_car[i] end
					imgui.SameLine()
					imgui.Text(name_car[i])
					if i%3>0 then imgui.SameLine() end
				end
			end
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.answer_player_report.v then -- помощь после слежки в реконе
		imgui.SetNextWindowPos(imgui.ImVec2(sw-250, 0), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Помощь после выхода из рекона", windows.answer_player_report.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Вы закончили слежку по репорту')
		imgui.CenterText(u8'Доложить информацию?')
		if imgui.Button(u8'Нарушений не наблюдаю (1)', imgui.ImVec2(250, 25)) or (isKeyDown(VK_1) and not (sampIsChatInputActive() or sampIsDialogActive())) then
			sampProcessChatInput('/n ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Данный игрок чист (2)', imgui.ImVec2(250,25)) or (isKeyDown(VK_2) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/cl ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Игрок наказан. (3)', imgui.ImVec2(250,25)) or (isKeyDown(VK_3) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/nak ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Помогли вам. (4)', imgui.ImVec2(250,25)) or (isKeyDown(VK_4) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/pmv ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Игрок AFK (5)', imgui.ImVec2(250,25)) or (isKeyDown(VK_5) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/afk ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Игрок не в сети (6)', imgui.ImVec2(250,25)) or (isKeyDown(VK_6) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/nv ' .. copies_player_recon)
			copies_player_recon = nil
			windows.answer_player_report.v = false
		end
		if imgui.Button(u8'Это донат-преимущества (7)', imgui.ImVec2(250,25)) or (isKeyDown(VK_7) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/dpr ' .. copies_player_recon)
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
		imgui.CenterText(u8'Нажми нужную клавишу, либо курсором')
		imgui.CenterText(u8'Активация курсора: ПКМ или F')
		imgui.CenterText(u8'Меню активно 5 секунд.')
		if isKeyJustPressed(VK_ESCAPE) then windows.answer_player_report.v = false end
		imgui.End()
	end
	if windows.render_admins.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.render_admins_positionX, cfg.settings.render_admins_positionY))
		imgui.Begin('##render_admins', windows.render_admins, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		for i = 1, #admins - 1 do imgui.TextColoredRGB(admins[i]) end
        imgui.End()
	end
	if windows.new_flood_mess.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(265,340), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Новый флуд', windows.new_flood_mess, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Button(u8'Скрипт сам допишет /mess\nВам лишь надо указать цвет.', imgui.ImVec2(250,32)) then sampSendChat('/mcolors') end
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
					save()
					buffer.title_flood_mess.v = ''
					buffer.new_flood_mess.v = ''
				else sampAddChatMessage(tag .. 'Вы не указали номер цвета', -1)
				end
			else sampAddChatMessage(tag .. 'Что вы собрались сохранять?', -1)
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
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5,0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw*0.5,sh*0.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Помощь', windows.pravila, imgui.WindowFlags.NoResize +imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.NewInputText('##SearchBar6', buffer.find_rules, sw*0.5, u8'Поиск по всем спискам', 2)
		imgui.Tooltip('Space')
		imgui.PushFont(fontsize)
		imgui.RadioButton(u8"Правила", checkbox.checked_radio_button, 1)
		imgui.SameLine()
		imgui.RadioButton(u8"Быстрые команды", checkbox.checked_radio_button, 2)
		imgui.SameLine()
		imgui.RadioButton(u8"Серверные команды", checkbox.checked_radio_button, 3)
		if isKeyJustPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end
		if checkbox.checked_radio_button.v == 1 then
			for i = 1, #pravila do
				if string.rlower(pravila[i]):find(string.rlower(u8:decode('%s'..buffer.find_rules.v))) then
					if not u8(pravila[i]):find('%[(%d+) lvl%]') and not u8(pravila[i]):find('SCRIPT')  then
						imgui.TextWrapped(u8(pravila[i]))
					end
				end
			end
		elseif checkbox.checked_radio_button.v == 2 then
			if #(cfg.my_command) ~= 0 then imgui.CenterText(u8'Мои команды') end
			for k,v in pairs(cfg.my_command) do
				imgui.TextWrapped(u8('/' .. k))
			end
			imgui.CenterText(u8'Команды скрипта')
			for k,v in pairs(basic_command.prochee) do
				imgui.TextWrapped(u8('/'..k..' = '..v))
			end
			imgui.CenterText(u8'Вспомогательные команды')
			for k,v in pairs(basic_command.help) do
				imgui.TextWrapped(u8('/'..k..' = '..v))
			end
			imgui.CenterText(u8'Ответ игроку')
			for k,v in pairs(basic_command.ans) do
				imgui.TextWrapped(u8('/'..k ..' = '..v))
			end
			imgui.CenterText(u8'Выдать мут игроку')
			for k,v in pairs(basic_command.mute) do
				if not v:find('x') then imgui.TextWrapped(u8('/'..k..' = '..v)) end
			end
			imgui.CenterText(u8'Выдать рмут игроку')
			for k,v in pairs(basic_command.rmute) do
				if not v:find('x') then imgui.TextWrapped(u8('/'..k..' = '..v)) end
			end
			imgui.CenterText(u8'Выдать джайл игроку')
			for k,v in pairs(basic_command.jail) do
				imgui.TextWrapped(u8('/'..k..' = '..v))
			end
			imgui.CenterText(u8'Выдать бан игроку')
			for k,v in pairs(basic_command.ban) do
				imgui.TextWrapped(u8('/'..k..' = '..v))
			end
			imgui.CenterText(u8'Выдать кик игроку')
			for k,v in pairs(basic_command.kick) do
				imgui.TextWrapped(u8('/'..k..' = '..v))
			end
		elseif checkbox.checked_radio_button.v == 3 then
			for i = 1, #pravila do
				if string.rlower(pravila[i]):find(string.rlower(u8:decode('%s'..buffer.find_rules.v))) then
					if pravila[i]:find('%[%d+ lvl%] ') then imgui.TextWrapped(u8(pravila[i])) end
				end
			end
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.menu_chatlogger.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw*0.7, sh*0.8), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Логирование чата', windows.menu_chatlogger, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.IsWindowAppearing() then chat = {1, 500, 1} end -- 1 параметр начало массива, 2 параметр - конец массива, 3 - страница.
		imgui.PushFont(fontsize)
		imgui.CenterText(u8'Выберите файл для просмотра')
		imgui.Text(u8'Примечание: Нажатие по тексту - копирует его в буффер обмена.\nСкриншот данного окна можно использовать ввиде доказазательств.\nВ целях уменьшения нагрузки на ваш компьютер, данное окно обновляется каждый перезаход в игру.')
		imgui.PushItemWidth(sw*0.7 - 30)
		if imgui.Combo('##chatlog', checkbox.option_find_log, files_chatlogs, checkbox.option_find_log) then chat = {1, 500, 1} end
		imgui.NewInputText('##searchlog', buffer.find_log, (sw*0.7)-30, u8'Сортировка текста', 2)
		imgui.PopItemWidth()
		if checkbox.option_find_log.v == 0 then 	--= ОСТОРОЖНО, ПРИ ИЗМЕНЕНИЯХ, ЗАВИСИМОСТЬ ОТ ЦИФР'
			if #chatlog_1 > 500 then
				if chat[3] > 1 then
					if imgui.Button(u8'<- Предыдущая страница'..' ('..(chat[3] - 1)..')') then
						if chat[1] ~= 1 then
							if chat[1] == 500 then chat[1] = 1 chat[2] = chat[2] - 500
							elseif #chatlog_1 == chat[2] then
								chat[2] = chat[1]
								if chat[1] - 500 < 500 then chat[1] = 1 
								else chat[1] = chat[1] - 500 end
							else
								chat[1] = chat[1] - 500
								chat[2] = chat[2] - 500
							end
							chat[3] = chat[3] - 1
						end
					end
					imgui.SameLine()
				end
				if imgui.Button(u8'Следующая страница ' .. '('..chat[3].. ') ->') then
					if #chatlog_1~=chat[2] then
						if #chatlog_1 < chat[2] + 500 then chat[1] = chat[2] chat[2] = #chatlog_1
						else chat[1] = chat[2] chat[2] = chat[2] + 500 end
						chat[3] = chat[3] + 1
					end
				end
			else chat[2] = #chatlog_1 end
			for i = chat[1], chat[2] do
				if string.rlower(chatlog_1[i]):find(string.rlower(u8:decode(buffer.find_log.v))) then
					imgui.Text(u8(chatlog_1[i]))
					if imgui.IsItemClicked(0) then setClipboardText(chatlog_1[i]) sampAddChatMessage(tag..'Строка скопирована в буффера обмена',-1) end
				end
			end
		end
		if checkbox.option_find_log.v == 1 then
			if #chatlog_2 > 500 then
				if chat[3] > 1 then
					if imgui.Button(u8'<- Предыдущая страница'..' ('..(chat[3] - 1)..')') then
						if chat[1] ~= 1 then
							if chat[1] == 500 then chat[1] = 1 chat[2] = chat[2] - 500
							elseif #chatlog_2 == chat[2] then
								chat[2] = chat[1]
								if chat[1] - 500 < 500 then chat[1] = 1 
								else chat[1] = chat[1] - 500 end
							else
								chat[1] = chat[1] - 500
								chat[2] = chat[2] - 500
							end
							chat[3] = chat[3] - 1
						end
					end
					imgui.SameLine()
				end
				if imgui.Button(u8'Следующая страница ' .. '('..chat[3].. ') ->') then
					if #chatlog_2~=chat[2] then
						if #chatlog_2 < chat[2] + 500 then chat[1] = chat[2] chat[2] = #chatlog_2
						else chat[1] = chat[2] chat[2] = chat[2] + 500 end
						chat[3] = chat[3] + 1
					end
				end
			else chat[2] = #chatlog_2 end
			for i = chat[1], chat[2] do
				if string.rlower(chatlog_2[i]):find(string.rlower(u8:decode(buffer.find_log.v))) then
					imgui.Text(u8(chatlog_2[i]))
					if imgui.IsItemClicked(0) then setClipboardText(chatlog_2[i]) sampAddChatMessage(tag..'Строка скопирована в буффера обмена',-1) end
				end
			end
		end
		if checkbox.option_find_log.v == 2 then
			if #chatlog_3 > 500 then
				if chat[3] > 1 then
					if imgui.Button(u8'<- Предыдущая страница'..' ('..(chat[3] - 1)..')') then
						if chat[1] ~= 1 then
							if chat[1] == 500 then chat[1] = 1 chat[2] = chat[2] - 500
							elseif #chatlog_3 == chat[2] then
								chat[2] = chat[1]
								if chat[1] - 500 < 500 then chat[1] = 1 
								else chat[1] = chat[1] - 500 end
							else
								chat[1] = chat[1] - 500
								chat[2] = chat[2] - 500
							end
							chat[3] = chat[3] - 1
						end
					end
					imgui.SameLine()
				end
				if imgui.Button(u8'Следующая страница ' .. '('..chat[3].. ') ->') then
					if #chatlog_3~=chat[2] then
						if #chatlog_3 < chat[2] + 500 then chat[1] = chat[2] chat[2] = #chatlog_3
						else chat[1] = chat[2] chat[2] = chat[2] + 500 end
						chat[3] = chat[3] + 1
					end
				end
			else chat[2] = #chatlog_3 end
			for i = chat[1], chat[2] do
				if string.rlower(chatlog_3[i]):find(string.rlower(u8:decode(buffer.find_log.v))) then
					imgui.Text(u8(chatlog_3[i]))
					if imgui.IsItemClicked(0) then setClipboardText(chatlog_3[i]) sampAddChatMessage(tag..'Строка скопирована в буффера обмена',-1) end
				end
			end
		end
		imgui.PopFont()
		imgui.End()
	end
	if windows.update_script.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 150, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Найдена новая версия скрипта', windows.update_script, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		if update_info then
			imgui.Text(u8'Примечание к обновлению:')
			imgui.PopFont()
			imgui.Text('\n')
			imgui.TextWrapped(update_info)
			imgui.Text('\n')
			imgui.PushFont(fontsize)
		end
		if update_main then
			if imgui.Button(u8'Обновить основной скрипт', imgui.ImVec2(400, 24)) then
				sampAddChatMessage(tag .. 'Правильный выбор!', -1)
				sampAddChatMessage(tag .. 'Ожидайте, начинаю процесс обновления.', -1)
				update()
			end
		end
		if update_fs then
			if imgui.Button(u8'Обновить плагин быстрого спавна', imgui.ImVec2(400, 24)) then
				sampAddChatMessage(tag .. 'Верно мыслите!', -1)
				sampAddChatMessage(tag .. 'Ожидайте, начинаю процесс обновления.', -1)
				update()
			end
		end
		if update_mp then
			if imgui.Button(u8'Обновить плагин мероприятий/админ-статистики', imgui.ImVec2(400, 24)) then
				sampAddChatMessage(tag .. 'Дальше только лучше!', -1)
				sampAddChatMessage(tag .. 'Ожидайте, начинаю процесс обновления.', -1)
				update()
			end
		end
		imgui.PopFont()
		imgui.CenterText(u8'Клавиша ESC закрывает окно обновления')
		if isKeyDown(VK_ESCAPE) then windows.update_script.v = false end
		imgui.End()
	end
end

function sampev.onSendCommand(command) -- Регистрация отправленных пакет-сообщений
	if command:match('mute (.+) (.+) .+') and string.sub(command, 2) =='/' and not string.sub(command, 3) =='/a' then
		if cfg.settings.forma_na_mute then
			if sampIsPlayerConnected(command:match('(%d+)')) then
				printStyledString('send forms ...', 1000, 4)
				if cfg.settings.add_mynick_in_form then
					local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
				else SendChat('/a ' .. command) end
				return false
			end
		end
		if cfg.settings.smart_automute then
			local id, second, reason = string.match(command,'(%d+) (%d+) (.+)') -- Узнаем ник наказуемого
			if sampIsPlayerConnected(id) and not string.gsub(reason, 'x(%d)', '') then -- если игрок в сети
				local nick = string.gsub(sampGetPlayerNickname(id), '%p','') -- присваиваем переменной значение ника и удаляем символы пунктуации
				for a,b in pairs(cfg.mute_players) do
					if a:find(nick) and string.gsub(a, nick, ''):find(string.gsub(reason, '%p', '')) then -- Если ник найден в массиве уже наказанных
						local second = second * b -- Умножаем наказание
						if second > 5000 then second = 5000 end
						sampAddChatMessage(tag .. 'Данный игрок уже был наказан ранее, потому я увеличиваю наказание.', -1)
						SendChat('/mute ' .. id ..' '..  second .. ' ' .. reason ..' x'..b)
						return false
					end
				end
			end
		end
	end
	if cfg.settings.forma_na_ban and command:match('ban (%d+) (%d+) .+') and string.sub(command, 2) =='/' and not string.sub(command, 3) =='/a' then
		if sampIsPlayerConnected(command:match('(%d+)')) then
			printStyledString('send forms ...', 1000, 4)
			if cfg.settings.add_mynick_in_form then
				local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
			else SendChat('/a ' .. command) end
			return false
		end
	end
	if cfg.settings.forma_na_jail and command:match('/jail (%d+) (%d+) .+') and string.sub(command, 2) =='/' and not string.sub(command, 3) =='/a' then
		if sampIsPlayerConnected(command:match('(%d+)')) then
			printStyledString('send forms ...', 1000, 4)
			if cfg.settings.add_mynick_in_form then
				local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
			else SendChat('/a ' .. command) end
			return false
		end
	end
	if cfg.settings.forma_na_kick and command:match('/kick (%d+) .+') and string.sub(command, 2) =='/' and not string.sub(command, 3) =='/a' then
		if sampIsPlayerConnected(command:match('(%d+)')) then
			printStyledString('send forms ...', 1000, 4)
			if cfg.settings.add_mynick_in_form then
				local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
			else SendChat('/a ' .. command) end
			return false
		end
	end
	return
end
function SendChat(text)
    local bs = raknetNewBitStream()
    local rn = require 'samp.raknet'
    raknetBitStreamWriteInt32(bs, #text)
    raknetBitStreamWriteString(bs, text)
    raknetSendRpc(rn.RPC.SERVERCOMMAND, bs)
    raknetDeleteBitStream(bs)
end
function sampev.onServerMessage(color,text) -- Поиск сообщений из чата
	if #text > 4 then
		if text:match('%[Информация%] {FFFFFF}Теперь вы не видите сообщения игроков') then
			checkbox.check_render_ears = imgui.ImBool(true)
			ears = {}
			notify('{66CDAA}[AT] Сканирование ЛС', 'Сканирование личных сообщений\nБыло успешно приостановлено')
			return false
		end
		if text:match('%[Информация%] {FFFFFF}Теперь вы видите сообщения игроков') then
			checkbox.check_render_ears = imgui.ImBool(false)
			notify('{66CDAA}[AT] Сканирование ЛС', 'Сканирование личных сообщений\nБыло успешно инициализировано')
			return false
		end
		if cfg.settings.render_admins then
			if text:match('Время администратирования за сегодня:') or text:match('Ваша репутация:') or text:match('Всего администрации в сети:') then
				return false
			end
		end
		if not AFK then log(text) end
		if text:match("(.+)%((%d+)%) пытался написать в чат: ") and not AFK and cfg.settings.control_system_mute then
			lua_thread.create(function()
				local fonts = renderCreateFont('TimesNewRoman', 12, 5) -- текст для автоформ
				local nick, id = text:match('(.+)%((%d+)%)')
				local text = string.gsub(text, '(.+)%((%d+)%) пытался написать в чат: ', '')
				local count = 800
				while count ~= 0 do
					wait(1)
					count = count - 1
					renderFontDrawText(fonts, 'Игрок '..nick .. '['.. id..'] попытался отправить в чат:{EE82EE}'..text..'\n{FFFFFF}Снять наказание? U - Да, J - Нет, M - выдать альтернативное.\nДействие доступно в течение 8 секунд.' , sw*0.2, sh*0.5, 0xFFFFFFFF)
					if isKeyJustPressed(VK_U) and not sampIsChatInputActive() then sampSendChat('/unmute ' .. id) break end
					if isKeyJustPressed(VK_J) and not sampIsChatInputActive() then break end
					if isKeyJustPressed(VK_M) and not sampIsChatInputActive() then
						if sampIsDialogActive() then sampAddChatMessage(tag .. 'Как вы собрались выдавать наказание с открытым диалогом?', -1)
						else
							control_player = id
							imgui.Process = true
							windows.recon_mute_menu.v = true
							wait(100)
							showCursor(true,false)
							while windows.recon_mute_menu.v do wait(200) end
							showCursor(false,false)
							control_player = nil
						end
						break
					end
				end
			end)
		end
		if text:match("Администратор (.+) заткнул%(.+%) игрока (.+) на (.+) секунд. Причина:") then
			local _, myid = sampGetPlayerIdByCharHandle(playerPed) -- узнаем мой ник
			if text:match(sampGetPlayerNickname(myid)) then -- Узнаем я ли выдал это наказание
				local nick = string.match(text, 'игрока (.+) на') -- Ищем игрока
				local reason = string.sub(string.match(text, 'Причина: .+'), 10) --- ищем причину
				---========= Если в причине есть множитель - удаляем ============-----------------
				local reason = string.gsub(string.gsub(reason, ' x(%d)', ''), ' х(%d)', '')
				--========== Если такой ник найден в скрипте, то добавляем множитель + 1 =======--- 
				if cfg.mute_players[string.gsub(nick..reason, '%p','')] then cfg.mute_players[string.gsub(nick..reason, '%p','')] = tonumber(string.sub(cfg.mute_players[string.gsub(nick..reason, '%p','')],1,-1)) + 1
				--========== Если такой ник не найден в скрипте, то приписываем множитель 2 =======--- 
				else cfg.mute_players[string.gsub(nick..reason, '%p','')] = 2	end
				save()
			end
		end
		if text:match("Администратор (.+) закрыл%(.+%) доступ к репорту игроку (.+) на (.+) секунд. Причина:") then
			local _, myid = sampGetPlayerIdByCharHandle(playerPed) -- узнаем мой ник
			if text:match(sampGetPlayerNickname(myid)) then -- Узнаем я ли выдал это наказание
				local nick = string.match(text, 'игроку (.+) на') -- Ищем игрока
				local reason = string.sub(string.match(text, 'Причина: .+'), 10) --- ищем причину
				---========= Если в причине есть множитель - удаляем ============-----------------
				local reason = string.gsub(string.gsub(reason, ' x(%d)', ''), ' х(%d)', '')
				--========== Если такой ник найден в скрипте, то добавляем множитель + 1 =======--- 
				if cfg.mute_players[string.gsub(nick..reason, '%p','')] then cfg.mute_players[string.gsub(nick..reason, '%p','')] = tonumber(string.sub(cfg.mute_players[string.gsub(nick..reason, '%p','')],1,-1)) + 1
				--========== Если такой ник не найден в скрипте, то приписываем множитель 2 =======--- 
				else cfg.mute_players[string.gsub(nick..reason, '%p','')] = 2 end
				save()
			end
		end
		if cfg.settings.find_warning_weapon_hack and not AFK then
			if text:match('Weapon hack .code. 015.') then
				lua_thread.create(function()
					while (sampIsDialogActive() or sampIsChatInputActive()) do wait(0) end
					sampSendChat("/iwep " .. string.match(text, "%[(%d+)%]"))
				end)
				return false
			end 
		end
		if cfg.settings.find_form and not AFK then
			if text:match("%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: ") then
				for i = 1, #spisok_in_form do
					if text:find(spisok_in_form[i]) then
						while true do -- пока цикл не будет прерван
							admin_form = {}
							local find_admin_form = string.gsub(text, '%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: {%w%w%w%w%w%w}', '')
							if string.sub(find_admin_form, 1, 1) == '/' then
								admin_form.idadmin = tonumber(text:match('%[(%d+)%]'))
								admin_form.forma = find_admin_form
								if find_admin_form:find('unban (.+)') then
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
									if (find_admin_form.sub(find_admin_form, 2)):find('//') then admin_form.styleform = true end
									admin_form.sett = true
									wait_accept_form()
									break
								end
								admin_form.probid = string.match(admin_form.forma, '%d[%d.,]*')
								if admin_form.probid and sampIsPlayerConnected(admin_form.probid) then
									admin_form.bool = true
									admin_form.timer = os.clock()
									admin_form.nickid = sampGetPlayerNickname(admin_form.probid)
									if (find_admin_form.sub(find_admin_form, 2)):find('//') then admin_form.styleform = true end
									admin_form.sett = true
									wait_accept_form()
									break
								else
									admin_form = {}
									sampAddChatMessage(tag .. 'ID не обнаружен, либо находится вне сети.', -1)
									break
								end
							else break end
						end
					end
				end
			end
		end
		if text:match('%[A%] NEARBY CHAT: .+') or text:match('%[A%] SMS: .+') then
			render_ears = true
			checkbox.check_render_ears = imgui.ImBool(render_ears) 
			local text = string.gsub(text, 'NEARBY CHAT:', '{87CEEB}AT-NEAR:{FFFFFF}')
			local text = string.gsub(text, 'SMS:', '{4682B4}AT-SMS:{FFFFFF}')
			local text = string.gsub(text, ' отправил ', '')
			local text = string.gsub(text, ' игроку ', '->')
			local text = string.sub(text, 5) -- удаляем [A]
			if #ears == cfg.settings.strok_ears then
				for i = 0, #ears do
					if i ~= #ears then ears[i] = ears[i + 1]
					else ears[#ears] = text end
				end
			else ears[#ears + 1] = text end
			return false
		end
		if cfg.settings.admin_chat and text:match("%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]:") then
			local admlvl, prefix, nickadm, idadm, admtext  = text:match('%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)')
			local messange = string.sub(prefix, 2) .. ' ' .. admlvl .. ' ' ..  nickadm .. '(' .. idadm .. '): '.. admtext
			if #messange >= 160 then messange = string.sub(messange, 1, 160) .. '...' end
			if #adminchat == cfg.settings.strok_admin_chat then
				for i = 0, #adminchat do
					if i ~= #adminchat then adminchat[i] = adminchat[i+1]
					else adminchat[#adminchat] = messange end
				end
			else adminchat[#adminchat + 1] = messange end
			local admlvl, prefix, nickadm, idadm, admtext = nil
			return false
		end
		if cfg.settings.automute and not AFK then 
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
							notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Упоминание родных.')
							return false
						end
					end
					for i = 0, #spisokrz do
						if text:match('}'..tostring(spisokrz[i])) or text:match('%s'..tostring(spisokrz[i])) then
							sampAddChatMessage('=======================================================', 0x00FF00)
							sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' .. text .. ' {00FF00}[АТ]', -1)
							sampAddChatMessage('=======================================================', 0x00FF00)
							sampSendChat('/rmute ' .. oskid .. ' 5000 Розжиг межнац.розни')
							notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Розжиг межнац.розни')
							return false
						end
					end
				end
			end
			if (text:match("(.*)%((%d+)%):%s(.+)") or text:match("(.*)%[(%d+)%]:%s(.+)")) and not text:match("%[a%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)") and not text:match('написал %[(%d+)%]:') and not text:match('ответил (.*)%[(%d+)%]: (.*)') and not text:match('жалоба') then
				if text:match('%((%d+)%)') then oskid = text:match('%((%d+)%)') text = string.gsub(text, "(.*)%((%d+)%):",'')
				else oskid = text:match('%[(%d+)%]') text = string.gsub(text, "(.*)%[(%d+)%]:", '') end
				local text = string.gsub(text, '{%w%w%w%w%w%w}', '')
				if cfg.settings.smart_automute then
					for i = 0, #spisokoskrod do
						if text:match('%s'.. tostring(spisokoskrod[i])) then
							sampAddChatMessage('=======================================================', 0x00FF00)
							sampAddChatMessage('{00FF00}[АT]{DCDCDC} '..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
							sampAddChatMessage('=======================================================', 0x00FF00)
							sampSendChat('/mute ' .. oskid .. ' 5000 Оскорбление/Упоминание родных')
							notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Упоминание родных.')
							return false
						end
					end
					for i = 0, #spisokrz do
						if text:match('%s'..tostring(spisokrz[i])) then
							sampAddChatMessage('=======================================================', 0x00FF00)
							sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
							sampAddChatMessage('=======================================================', 0x00FF00)
							sampSendChat('/mute ' .. oskid .. ' 5000 Розжиг межнац.розни')
							notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Розжиг межнац.розни')
							return false
						end
					end
					for i = 0, #spisokproject do
						if text:match('%s' .. tostring(spisokproject[i])) then
							sampAddChatMessage('=======================================================', 0x00FF00)
							sampAddChatMessage('{00FF00}[АT]{DCDCDC} '..sampGetPlayerNickname(oskid) .. '['..oskid..']: ' .. text .. ' {00FF00}[АТ]', -1)
							sampAddChatMessage('=======================================================', 0x00FF00)
							sampProcessChatInput('/up ' .. oskid)
							notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(spisokproject[i]), 2,1,10)
							return false
						end
					end
				end
				for i = 0, #osk do
					if not text:match(' я ') and text:match('%s'..tostring(osk[i])) then
						if cfg.settings.smart_automute then
							for d = 0, #spisokor do
								if text:match('%s'.. tostring(spisokor[d])) then
									sampAddChatMessage('=======================================================', 0x00FF00)
									sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
									sampAddChatMessage('=======================================================', 0x00FF00)
									sampSendChat('/mute ' .. oskid .. ' 5000 Оскорбление/упоминание родных')
									notify('{66CDAA}[AT-AutoMute]', '' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(osk[i]) .. ' и ' .. tostring(spisokor[d]))
									return false
								end
							end
						end
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/mute ' .. oskid .. ' 400 Оскорбление/Унижение')
						notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(osk[i]))
						return false
					end
				end
				for i = 0, #mat do
					if text:match('%s'.. tostring(mat[i])) then
						if cfg.settings.smart_automute then
							for d = 0, #spisokor do
								if text:match('%s'.. tostring(spisokor[d])) then
									sampAddChatMessage('=======================================================', 0x00FF00)
									sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
									sampAddChatMessage('=======================================================', 0x00FF00)
									sampSendChat('/mute ' .. oskid .. ' 5000 Оскорбление/упоминание родных')
									notify('{66CDAA}[AT-AutoMute]', '' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(mat[i]) .. ' и ' .. tostring(spisokor[d]))
									return false
								end
							end
						end
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('=======================================================', 0x00FF00)
						sampSendChat('/mute ' .. oskid .. ' 300 Нецензурная лексика')
						notify('{66CDAA}[AT-AutoMute]', '' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. tostring(mat[i]))				
						return false
					end
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
			elseif v:match('~n~') then
				if not v:match('~g~') then 
					textdraw.inforeport = id  -- инфо панель в реконе
					lua_thread.create(function()
						while not windows.recon_menu.v do wait(0) end
						while windows.recon_menu.v do
							inforeport = textSplit(sampTextdrawGetString(textdraw.inforeport), "~n~") -- информация о игроке, считывание с текстрдрава
							if inforeport[3] ==   '-1'   then inforeport[3] = '-' end  --========= ХП АВТО
							if inforeport[6] == '0 : 0 ' then inforeport[6] = '-' end  --====== Оружие
							--=========== Название ВИП =======--------
							if     inforeport[11] == '0' then inforeport[11] = '-'
							elseif inforeport[11] == '1' then inforeport[11] = 'Standart'
							elseif inforeport[11] == '2' then inforeport[11] = 'Premium'
							elseif inforeport[11] == '3' then inforeport[11] = 'Diamond'
							elseif inforeport[11] == '4' then inforeport[11] = 'Platinum'
							elseif inforeport[11] == '5' then inforeport[11] = 'Personal' end
							--=========== Название ВИП =======--------
							wait(1000)
						end
					end)
				else return false end
			elseif v:match('(.+)%((%d+)%)') then
				textdraw.name_report = id
				control_player_recon = tonumber(string.match(v, '%((%d+)%)')) -- ник игрока в реконе
				lua_thread.create(function()
					wait(1000)
					while (sampIsDialogActive() or sampIsChatInputActive()) do wait(0) end
					mobile_player = false
					sampSendChat('/tonline ' .. control_player_recon)
				end)
			elseif v == 'STATS' then 
				textdraw.stats = id
				lua_thread.create(function()
					while not (sampTextdrawIsExists(textdraw.close) and sampTextdrawIsExists(textdraw.name_report)) do wait(100) end
					wait(1)
					windows.recon_menu.v = true
					windows.menu_in_recon.v = true
					imgui.Process = true
					if cfg.settings.keysync then keysync(control_player_recon) end
					sampTextdrawSetPos(textdraw.stats, 2000, 0) -- кнопка статистики
					sampTextdrawSetPos(textdraw.refresh,2000,0) -- кнопка Refresh в реконе
					sampTextdrawSetPos(textdraw.name_report, 2000, 0) -- информация о никнейме игрока
					wait(300)
					sampTextdrawSetPos(textdraw.inforeport, 2000, 0) -- информация
					sampTextdrawSetPos(textdraw.close, 2000, 0) -- кнопка закрытия рекона
				end)
			elseif v == 'CLOSE' then textdraw.close = id
			elseif v == 'BAN' then return false
			elseif v == 'MUTE' then return false
			elseif v == 'KICK' then return false
			elseif v == 'JAIL' then return false end
		end
		------=========== Удаляем лишние текстдравы, сравнивая их с массивом =======---------------
		for i = 0, #textdraw_delete do if id == textdraw_delete[i] then return false end end
	end
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text) -- Работа с открытими ДИАЛОГАМИ
	if text:match('Weapon') then
		lua_thread.create(function()
			local text = textSplit(text, '\n')
			for i = 1, #text - 1 do
				local _,weapon, patron = text[i]:match('(%d+)	Weapon: (%d+)     Ammo: (.+)')
				if (text[i]:find('-')) or (weapon == '0' and patron ~= '0') then
					sampAddChatMessage(tag .. 'Оружие (ID): ' .. weapon..'. Патроны: '..patron, -1)
					notify('{66CDAA}[AT] Анти-чит', 'Оружие (ID): ' .. weapon..'\nПатроны: '..patron)
					wait(1500)
					setVirtualKeyDown(119, true) -- screenshot F8
					setVirtualKeyDown(119, false)
					player_cheater = true
					break
				end
			end
			wait(0)
			sampCloseCurrentDialogWithButton(0)
			if player_cheater then
				while sampIsDialogActive() do wait(300) end
				player_cheater = nil
				sampSendChat('/iban '..sampGetPlayerIdByNickname(title)..' 7 Чит на оружие')
				notify('{66CDAA}[AT] Анти-чит', 'Скриншот /iwep можно найти в\nДокументах игры - скриншоты')
			else sampAddChatMessage(tag .. 'Пробил игрока ' .. title .. '[' .. sampGetPlayerIdByNickname(title) .. ']. По результатам проверки читов не обнаружено.', -1) end
		end)
	end
	if title == 'Mobile' then -- проверка в сети ли игрок
		lua_thread.create(function()
			local text = textSplit(text, '\n')
			for i = 6, #text - 1 do if text[i] == (sampGetPlayerNickname(control_player_recon)..'('..control_player_recon..')') then mobile_player = true break end end
			wait(0)
			sampCloseCurrentDialogWithButton(0)
		end)
	end
	if dialogId == 3247 then -- /ahelp
		lua_thread.create(function() windows.pravila.v = not windows.pravila.v imgui.Process = true wait(0) sampCloseCurrentDialogWithButton(0) end)
	end
	if cfg.settings.render_admins and title:find('Администрация проекта') then
		admins = textSplit(text, '\n')
		local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		for i = 1, #admins - 1 do -- {FFFFFF}N.E.O.N(0) ({2E8B57}Мл.Администратор{FFFFFF}) | Уровень: {ff8587}6{FFFFFF} | Выговоры: {ff8587}0 из 3{FFFFFF} | Репутация: {ff8587}
			local rang = string.sub(string.gsub(string.match(admins[i], '(%(.+)%)'), '(%(%d+)%)', ''), 3) --{FFFFFF}N.E.O.N(0) | Уровень: {ff8587}18{FFFFFF} | Выговоры: {ff8587}0 из 3{FFFFFF} | Репутация: {ff8587}60
			admins[i] = string.gsub(admins[i], '{%w%w%w%w%w%w}', "")
			local afk = string.match(admins[i], 'AFK: (.+)')
			local name, id, _, lvl, _, _ = string.match(admins[i], '(.+)%((%d+)%) (%(.+)%) | Уровень: (%d+) | Выговоры: 0 из (%d+) | Репутация: (.+)')
			local name, id, lvl = tostring(name), tostring(id), tostring(lvl)
			admins[i] = string.gsub(admins[i], '| Выговоры: %d из %d |', "")
			admins[i] = string.gsub(admins[i], 'Репутация: (.+)', "")
			if #rang > 2 then
				if afk then admins[i] = name .. '(' .. id .. ') ' .. rang .. ' ' .. lvl .. ' AFK: ' .. afk
				else admins[i] = name .. '(' .. id .. ') ' .. rang .. ' '.. lvl end
			else
				_, id, lvl = string.match(admins[i], '(.+)%((%d+)%) | Уровень: (%d+)')
				rang = 'Отсутствует'
			end
			if cfg.settings.autoprefix then
				local lvl, rang, id = tonumber(lvl), string.gsub(rang, '{%w%w%w%w%w%w}', ''), tonumber(id)
				if not management_team then if id == myid and lvl == 18 and rang ~= 'Ст.Администратор' then management_team = true end
				elseif id ~= myid then
					for i = 1, #(cfg.render_admins_exception) do if cfg.render_admins_exception[i] == sampGetPlayerNickname(id) then  exception_admin = true end end
					if not exception_admin then
						lua_thread.create(function() -- во избежание задержек закрытия окна
							if lvl <= 9 and lvl > 0 and rang ~= 'Мл.Администратор' then
								while sampIsDialogActive() do wait(0) end
								sampAddChatMessage(tag .. 'У администратора ' .. sampGetPlayerNickname(id) .. ' обнаружен неверный префикс.', -1)
								sampAddChatMessage(tag .. 'Произвожу замену: ' .. rang .. ' -> {' .. cfg.settings.prefixma .. '}Мл.Администратор', -1)
								wait(800) -- серверная задержка на команды
								sampSendChat('/prefix ' .. id .. ' Мл.Администратор ' .. cfg.settings.prefixma)
								wait(800) -- серверная задержка на команды
								sampSendChat('/admins')
								notify('{FF6347}[AT] Автоматическая выдача префикса', 'Администратор '..sampGetPlayerNickname(id)..'['..id ..']\nБыл установлен новый префикс.\n' .. rang .. '-> Мл.Администратор.')
							elseif lvl < 15 and lvl >= 10 and rang ~= 'Администратор' then
								while sampIsDialogActive() do wait(0) end
								sampAddChatMessage(tag .. 'У администратора ' .. sampGetPlayerNickname(id) .. ' обнаружен неверный префикс.', -1)
								sampAddChatMessage(tag .. 'Произвожу замену: ' .. rang .. ' -> {' ..cfg.settings.prefixa..'}Администратор', -1)
								wait(800) -- серверная задержка на команды
								sampSendChat('/prefix ' .. id .. ' Администратор ' .. cfg.settings.prefixa)
								wait(800) -- серверная задержка на команды
								notify('{FF6347}[AT] Автоматическая выдача префикса', 'Администратор '..sampGetPlayerNickname(id)..'['..id ..']\nБыл установлен новый префикс.\n' .. rang .. '-> Администратор.')
								sampSendChat('/admins')
							elseif lvl < 18 and lvl >= 15 and rang ~= 'Ст.Администратор' then
								while sampIsDialogActive() do wait(0) end
								sampAddChatMessage(tag .. 'У администратора ' .. sampGetPlayerNickname(id) .. ' обнаружен неверный префикс.', -1)
								sampAddChatMessage(tag .. 'Произвожу замену: ' .. rang .. ' -> {' .. cfg.settings.prefixsa..'}Ст.Администратор', -1)
								wait(800) -- серверная задержка на команды
								sampSendChat('/prefix ' .. id .. ' Ст.Администратор ' .. cfg.settings.prefixsa)
								wait(800) -- серверная задержка на команды
								sampSendChat('/admins')
								notify('{FF6347}[AT] Автоматическая выдача префикса', 'Администратор '..sampGetPlayerNickname(id)..'['..id ..']\nБыл установлен новый префикс.\n' .. rang .. '-> Ст.Администратор.')
							end
						end)
					end
					exception_admin = nil
				end
			end
			local name, id, rang, lvl, afk, rang, myid = nil
		end
		imgui.Process, windows.render_admins.v = true, true
		sampSendDialogResponse(dialogId, 1, 0)
		return false
	end
	if dialogId == 1098 then -- автоонлайн
		sampSendDialogResponse(dialogId, 1, math.floor(sampGetPlayerCount(false) / 10) - 1)
		sampCloseCurrentDialogWithButton(0)
		return false
	end
	if dialogId == 16196 then -- окно /offstats где выбор между статистикой и авто используется для /sbanip
		if find_ip_player then sampSendDialogResponse(dialogId, 1, 0) return false end
		if regip then lua_thread.create(function() wait(0) sampCloseCurrentDialogWithButton(0) end) end
	end
	if dialogId == 16197 and find_ip_player then -- окно /offstats используется для /sbanip
		for k,v in pairs(textSplit(text, '\n')) do if k == 12 then regip = string.sub(v, 17) elseif k == 13 then lastip = string.sub(v, 18) end end
		sampSendDialogResponse(dialogId,1,0)
		find_ip_player = nil
		return false
	end
	if dialogId == 2348 and windows.fast_report.v then windows.fast_report.v = false end
	if dialogId == 2349 then -- окно с самим репортом.
		answer, windows.answer_player_report.v, peremrep = {}, false, nil
		local text = textSplit(text, '\n')
		text[1] = string.gsub(string.gsub(text[1], '{%w%w%w%w%w%w}', ''), 'Игрок: ', '')
		text[4] = string.gsub(string.gsub(text[4], '{%w%w%w%w%w%w}', ''), 'Жалоба: ', '')
		autor = text[1]																			--1
		if sampGetPlayerIdByNickname(autor) then autorid = sampGetPlayerIdByNickname(autor)		--1
		else autorid = 'Не в сети' end     														--1
		textreport = text[4]																	--4
		reportid = tonumber(string.match(textreport, '%d[%d.,]*'))								--4
		if not sampIsPlayerConnected(reportid) then 											--4
			_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED) 									--4
		end																						--4
		if cfg.settings.on_custom_answer then windows.fast_report.v,imgui.Process=true,true end
		lua_thread.create(function()
			while windows.fast_report.v and not (answer.rabotay or answer.uto4 or answer.nakajy or answer.customans or answer.slejy or answer.jb or answer.ojid or answer.moiotvet or answer.uto4id or answer.nakazan or answer.otklon or answer.peredamrep) do wait(100) end
			sampSendDialogResponse(dialogId,1,0)
		end)
	end
	if dialogId == 2350 then -- окно с возможностью принять или отклонить репорт
		if not peremrep then
			if answer.rabotay then peremrep = ('Начал(а) работу по вашей жалобе!')
			elseif answer.slejy then
				if not reportid then peremrep = ('Начинаю слежку.') answer.slejy = nil
				elseif reportid and reportid ~= myid then
					if not sampIsPlayerConnected(reportid) then peremrep = ('Указанный вами игрок под ' .. reportid .. ' ID находится вне сети.') answer.slejy = nil
					else peremrep = ('Отправляюсь в слежку за игроком ' .. sampGetPlayerNickname(reportid) .. '['..reportid..']') end
				elseif myid then if reportid == myid then peremrep = ('Вы указали мой ID :D') answer.slejy = nil end end
			elseif answer.nakazan then peremrep = ('Данный игрок уже был наказан.')
			elseif answer.uto4id then peremrep = ('Уточните ID нарушителя в /report.')
			elseif answer.nakajy then peremrep = ('Будете наказаны за нарушение правил /report')  
			elseif answer.jb then peremrep = ('Напишите жалобу на forumrds.ru')
			elseif answer.peredamrep then peremrep = ('Передам ваш репорт.')
			elseif answer.rabotay then peremrep = ('Начал(а) работу по вашей жалобе.')
			elseif answer.customans then peremrep = answer.customans
			elseif answer.uto4 then peremrep = ('Обратитесь с данной проблемой на форум https://forumrds.ru')
			elseif #(buffer.text_ans.v) > 2 and #answer == 0 then
				if not answer.moiotvet then
					for k,v in pairs(cfg.customotvet) do
						if string.rlower(v):find(string.rlower(u8:decode(buffer.text_ans.v))) or string.rlower(v):find(translateText(string.rlower(u8:decode(buffer.text_ans.v)))) then
							peremrep = v 
							break
						end
					end
				end
				if not peremrep then peremrep = (u8:decode(buffer.text_ans.v)) end
			elseif answer.otklon then 
				sampSendDialogResponse(dialogId, 1, 2) 
				sampCloseCurrentDialogWithButton(0)  
				return false 
			end
		end
		if peremrep then
			if #peremrep > 80 then sampAddChatMessage(tag .. 'Ваш ответ оказался слишком длинный, попробуйте сократить текст.',-1) peremrep = nil end
			if peremrep then
				if cfg.settings.add_answer_report and (#peremrep + #(cfg.settings.mytextreport)) < 80 then peremrep = peremrep .. ('{'..tostring(color())..'} ' .. cfg.settings.mytextreport) end
				if cfg.settings.on_color_report and (#peremrep + #(cfg.settings.color_report)) < 80 then peremrep = cfg.settings.color_report .. peremrep end
				if #peremrep < 3 then peremrep = peremrep .. '    ' end
				if cfg.settings.custom_answer_save and answer.moiotvet then cfg.customotvet[ #cfg.customotvet + 1 ] = u8:decode(buffer.text_ans.v) save() end	
				sampSendDialogResponse(dialogId, 1, 0)
				return false
			end
		end
		windows.fast_report.v = false
	end
	if dialogId == 2351 and peremrep then -- окно с ответом на репорт
		windows.fast_report.v = false
		sampSendDialogResponse(dialogId, 1, _, peremrep)
		sampCloseCurrentDialogWithButton(0)
		buffer.text_ans.v = ''
		lua_thread.create(function()
			while sampIsDialogActive() do wait(100) end
			if answer.control_player then sampSendChat('/re ' .. autorid)
			elseif answer.slejy then sampSendChat('/re ' .. reportid)
			elseif answer.peredamrep then sampSendChat('/a ' .. autor .. '[' .. autorid .. '] | ' .. textreport)
			elseif answer.nakajy then
				if nakazatreport.oftop then sampSendChat('/rmute ' .. autorid .. ' 120 Оффтоп в /report')
				elseif nakazatreport.oskadm then sampSendChat('/rmute ' .. autorid .. ' 2500 Оскорбление администрации')
				elseif nakazatreport.oskrep then sampSendChat('/rmute ' .. autorid .. ' 400 Оскорбление/Унижение')
				elseif nakazatreport.poprep then sampSendChat('/rmute ' .. autorid .. ' 120 Попрошайничество')
				elseif nakazatreport.oskrod then sampSendChat('/rmute ' .. autorid .. ' 5000 Оскорбление/Упоминание родни')
				elseif nakazatreport.capsrep then sampSendChat('/rmute ' .. autorid .. ' 120 Капс в /report')
				elseif nakazatreport.matrep then sampSendChat('/rmute ' .. autorid .. ' 300 Нецензурная лексика')
				elseif nakazatreport.kl then sampSendChat('/rmute ' .. autorid .. ' 3000 Клевета на администрацию') end
				nakazatreport = {}
			end
			if answer.slejy and not copies_player_recon and tonumber(autorid) and cfg.settings.answer_player_report then
				local copies_report_id = reportid
				copies_player_recon = autorid
				while not windows.recon_menu.v do wait(0) end
				while windows.recon_menu.v do wait(2000) end
				if copies_player_recon and copies_report_id == control_player_recon then
					if sampIsPlayerConnected(copies_player_recon) then
						imgui.Process, windows.answer_player_report.v = true, true
						for i = 0, 11 do wait(500) if windows.recon_menu.v then break end end
						if windows.answer_player_report.v then windows.answer_player_report.v = false copies_player_recon = nil end
					else sampAddChatMessage(tag .. 'Игрок, написавший репорт, находится вне сети.', -1) end
				end
			else copies_player_recon = nil end
		end)
		return false
	end
end
function sampev.onDisplayGameText(style, time, text) -- скрывает текст на экране.
	if text:find('RECON') then windows.recon_menu.v = false windows.menu_in_recon.v = false return false end
	if text:find('REPORT') then
		if cfg.settings.notify_report and not AFK then printStyledString('REPORT ++', 2000, 4) end
		return false
	end
end
function imgui.Tooltip(text) -- подсказка при наведении на кнопку
    if imgui.IsItemHovered() then
       imgui.BeginTooltip() 
       imgui.Text(text)
       imgui.EndTooltip()
    end
end
function log(text) -- записываем лог
	local data_today = os.date("*t") -- узнаем дату сегодня
	local log = (getWorkingDirectory()..'\\config\\chatlog\\chatlog '.. data_today.day..'.'..data_today.month..'.'..data_today.year..'.txt')
	local file = io.open(log,"a")
	if file then file:write('['..data_today.hour..':'..data_today.min ..':'..data_today.sec..'] ' .. encrypt(text, 3)..'\n') end
	file:close()
end
function daysPassed(year1, month1, day1) -- узнаем разницу в днях
    local currentDate = os.date("*t")
    currentDate.year = year1
    currentDate.month = month1
    currentDate.day = day1
    local currentTimestamp = os.time(currentDate)
    local secondsPassed = os.difftime(os.time(), currentTimestamp)
    local daysPassed = math.floor(secondsPassed / (24 * 60 * 60))
    return daysPassed
end
function scanDirectory(path) -- Проверяем все файлы в папке
    files_chatlogs = {}
	local lfs = require("lfs")
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local fullPath = path .. "/" .. file
            local attributes = lfs.attributes(fullPath)
            if attributes.mode == "directory" then
                local nestedFiles = scanDirectory(fullPath)
                for _, nestedFile in ipairs(nestedFiles) do table.insert(files_chatlogs, nestedFile) end
            else table.insert(files_chatlogs, file) end
        end
    end
    return files_chatlogs
end

function directory_exists(directory) return os.rename(directory,directory) end -- Проверка наличия папки

function string.rlower(s) -- перевод русских букв в прописные
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then output = output .. russian_characters[ch + 32]
        elseif ch == 168 then output = output .. russian_characters[184] -- буква ё
		else output = output .. string.char(ch) end
    end
    return output
end
function uu() -- для вкладок
    for i = 0,2 do menu[i] = false end
end
function uu2() -- для вкладок
    for i = 0,10 do menu2[i] = false end
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
	for i = 0, 301 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then return i end end
end
function render_admins()
	while true do
		wait(30000)
		while sampIsDialogActive() do wait(500) end
		if not AFK then sampSendChat('/admins') end
	end
end

function autoonline() 
	while true do
		wait(61000) 
		while sampIsDialogActive() do wait(500) end 
		if not AFK then sampSendChat("/online") end 
	end 
end
------------- Input Helper -------------
function translite(text)
	for k, v in pairs(chars) do text = string.gsub(text, k, v) end return text
end
function inputChat()
	local font = renderCreateFont("Calibri", cfg.settings.size_text_f6, font.BOLD + font.BORDER + font.SHADOW)
	while true do
		wait(5)
		if sampIsChatInputActive() then
			local getInput = sampGetChatInputText()
			if(oldText ~= getInput and #getInput > 0)then
				local firstChar = string.sub(getInput, 1, 1)
				if (firstChar == "." or firstChar == "/") and cfg.settings.inputhelper then
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
			local in1 = sampGetInputInfoPtr()
			local in1 = getStructElement(in1, 0x8, 4)
			local in2 = getStructElement(--[[int]] in1, --[[int]] 0x8, --[[int]] 4)
			local in3 = getStructElement(--[[int]] in1, --[[int]] 0xC, --[[int]] 4)
			local _, pID = sampGetPlayerIdByCharHandle(playerPed) -- myid
			local name = sampGetPlayerNickname(--[[int]] pID) -- mynick
			local ping = sampGetPlayerPing(--[[int]] pID) -- ping
			local caps = (ffi.load("user32")).GetKeyState(0x14) -- Код клавиши CapsLock

			if caps == 1 or caps == 3 then caps = 'ON'
			else caps = 'OFF' end

			if getCurrentLanguageName() == '00000419' then raskl = 'RU'
			else raskl = 'EN' end

			local text = string.format("Ваш ник: {0088ff}%s{ffffff}, Ваш ID: {0088ff}%s{ffffff}, Ваш пинг: {0088ff}%s{ffffff}, Раскладка: {0088ff}%s{ffffff}, Capslock: {0088ff}%s{ffffff}", name, pID, ping, raskl, caps)
			renderFontDrawText(--[[int]] font, --[[string]] text, --[[int]] in2 + 5, --[[int]] in3 + 40, --[[int]] -1)
		end
	end
end
------------- Input Helper -------------

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
	local peds, streaming_player = getAllChars(), {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(control_recon_playerid) then streaming_player[key] = id end
	end
	return streaming_player
end
function ScriptExport()
	lua_thread.create(function()
		imgui.Process = false
		if cfg.settings.wallhack then sampProcessChatInput('/wh ') end
		wait(500)
		sampProcessChatInput('/fsoff')
		wait(500)
		sampProcessChatInput('/mpoff')
		showCursor(false,false)
		thisScript():unload()
	end)
end

function save()
	inicfg.save(cfg,'AT//AT_main.ini')
end
function wait_accept_form()
	lua_thread.create(function()
		local fonts = renderCreateFont('TimesNewRoman', 12, 5) -- текст для автоформ
		while true do
			wait(1)
			if admin_form.bool and admin_form.timer and admin_form.sett then
				timer = os.clock() - admin_form.timer 
				if admin_form.probid then
					if sampIsPlayerConnected(admin_form.probid) then renderFontDrawText(fonts, '{FFFFFF}Нажми U чтобы принять или J чтобы отклонить\nФорма: {F0E68C}' .. admin_form.forma .. '{FFFFFF}' .. ' на игрока '.. '{F0E68C}' .. admin_form.nickid .. '[' .. admin_form.probid .. ']'.. '{FFFFFF}' .. '\nВремени на раздумья 8 сек, прошло: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
					else renderFontDrawText(fonts, '{FFFFFF}Нажми U чтобы принять или J чтобы отклонить\nФорма: {F0E68C}' .. admin_form.forma.. '{FFFFFF}' .. '\nВремени на раздумья 8 сек, прошло: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF) end
				else renderFontDrawText(fonts, '{FFFFFF}Нажми U чтобы принять или J чтобы отклонить\nФорма: {F0E68C}' .. admin_form.forma.. '{FFFFFF}' .. '\nВремени на раздумья 8 сек, прошло: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF) end
				if timer>8 then break end
			end
			if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() then
				if sampIsPlayerConnected(admin_form.idadmin) then
					if not admin_form.styleform then wait(500) sampSendChat(admin_form.forma .. ' // ' .. sampGetPlayerNickname(admin_form.idadmin))
					else wait(500) sampSendChat(admin_form.forma) end
					wait(800)
					sampSendChat('/a AT - Принято.')
				else sampAddChatMessage(tag .. 'Администратор не в сети.', -1) end
				break
			end
			if isKeyDown(VK_J) and not sampIsChatInputActive() and not sampIsDialogActive() then
				sampAddChatMessage(tag .. 'форма отклонена', -1)
				break
			end
		end
		admin_form = {}
	end)
end
function binder_key()
	while true do
		if not (sampIsChatInputActive() or sampIsDialogActive() or windows.menu_tools.v or windows.answer_player_report.v or windows.fast_report.v) then
			if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_ans)) then sampSendChat("/ans") sampSendDialogResponse(2348, 1, 0) end
			if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_addText)) then sampSetChatInputText(string.sub(sampGetChatInputText(), 1, -2) .. ' '.. cfg.settings.mytextreport) sampSetChatInputEnabled(true) end
			if isKeyJustPressed(strToIdKeys(cfg.settings.fast_key_wallhack)) then sampProcessChatInput("/wh") end
			for k,v in pairs(cfg.binder_key) do if isKeyJustPressed(strToIdKeys(k)) then sampSendChat(v) end end
		end
		wait(1)
	end
end
--============= Wallhack + RGB color ==============--
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
function on_wallhack() -- Включение WallHack (свойства)
	local pStSet = sampGetServerSettingsPtr();
	NTdist = mem.getfloat(pStSet + 39)
	NTwalls = mem.getint8(pStSet + 47)
	NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 500.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
	nameTag = true
end
function off_wallhack() -- Выключение WallHack (свойства)
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, 30)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
	nameTag = false
end
--============= Wall hack + RGB color ==============--

function imgui.CenterText(text) -- центрирование текста
    imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(text).x / 2 ) 			
    imgui.Text(text)
end
function imgui.Link(label, description) -- гиперссылка
    local size = imgui.CalcTextSize(label)
	local p = imgui.GetCursorScreenPos()
	local p2 = imgui.GetCursorPos()
	local result = imgui.InvisibleButton(label, size)
    imgui.SetCursorPos(p2)
    if imgui.IsItemHovered() then
        if description then imgui.BeginTooltip() imgui.PushTextWrapPos(600) imgui.TextUnformatted(description) imgui.PopTextWrapPos() imgui.EndTooltip() end
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.CheckMark]))
	else imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label) end
    return result
end
-------================= Определяем нажатую клавишу, инициализируем её свойства ============------------------------
function getDownKeys()
    local curkeys, bool = "", false
    for k, v in pairs(vkeys) do if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then curkeys = v end end end
    for k, v in pairs(vkeys) do if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then if tostring(curkeys):len() == 0 then curkeys = v else curkeys = curkeys .. " " .. v end bool = true end end return curkeys, bool
end

function getDownKeysText()
	tKeys = textSplit(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then str = vkeys.id_to_name(tonumber(tKeys[i]))
			else str = str .. "+" .. vkeys.id_to_name(tonumber(tKeys[i])) end
		end
		return str
	else return "None" end
end

function strToIdKeys(str)
	tKeys = textSplit(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then str = vkeys.name_to_id(tKeys[i], false)
			else str = str .. " " .. vkeys.name_to_id(tKeys[i], false) end
		end
		return tostring(str)
	else return "((" end
end

function isKeysDown(keylist, pressed)
    local tKeys = textSplit(keylist, " ")
    if pressed == nil then pressed = false end
    if tKeys[1] == nil then return false end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then bool = true
            elseif isKeyDown(key) and pressed then bool = true end
        end
    else if isKeyDown(modified) and not wasKeyReleased(modified) then if wasKeyPressed(key) and not pressed then bool = true elseif isKeyDown(key) and pressed then bool = true end end end
    if nextLockKey == keylist then if pressed and not wasKeyReleased(key) then bool = false else bool = false nextLockKey = "" end end
    return bool
end
-------================= Определяем нажатую клавишу, инициализируем её свойства ============------------------------
function update() -- Обновление скрипта
	imgui.Process = false
	local dlstatus = require('moonloader').download_status
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", getWorkingDirectory() .. "//config//AT//rules.txt", function(id, status)  end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_Trassera.lua", getWorkingDirectory() .. "//resource//AT_Trassera.lua", function(id, status) end)
	if update_mp then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_MP.lua", getWorkingDirectory() .. "//resource//AT_MP.lua", function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. 'Скрипт получил актуальную версию модуля мероприятий',-1)
				if not (update_fs or update_main) then reloadScripts() end
			end 
		end) 
	end
	if update_fs then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_FastSpawn.lua", getWorkingDirectory() .. "//resource//AT_FastSpawn.lua", function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. 'Скрипт получил актуальную версию быстрого спавна',-1)
				if not (update_mp or update_main) then reloadScripts() end
			end  
		end) 
	end
	if update_main then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.lua", thisScript().path, function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. 'Скрипт получил актуальную версию АТ',-1)
				reloadScripts()
			end 
		end) 
	end
end

function notify(title, text)
	if notify_report then notify_report.addNotify(title, text, 2,1,12) end
end

function render_text()
	while true do
		wait(1)
		if not isPauseMenuActive() then
			for i = 1, #adminchat do
				renderFontDrawText(font_adminchat, adminchat[i], cfg.settings.position_adminchat_x, cfg.settings.position_adminchat_y + (i*15), 0xCCFFFFFF)
			end
			for i = 1, #ears do 
				renderFontDrawText(font_earschat, ears[i], cfg.settings.position_ears_x, cfg.settings.position_ears_y + (i*15), 0xCCFFFFFF)
			end
		end
	end
end

function start_my_answer()
	if start_download then sampAddChatMessage('Процесс загрузки уже идёт.', -1)
	else
		if not file_exists(getWorkingDirectory()..'\\resource\\skin\\skin_311.png') or not file_exists(getWorkingDirectory()..'\\resource\\auto\\vehicle_611.png') then
			start_download = true
			sampAddChatMessage(tag .. 'Файлы кастомных ответов ещё не загружены. Сразу как вы ответите на репорт я начну загрузку.', -1)
			lua_thread.create(function()
				while windows.fast_report.v do wait(1000) end
				sampAddChatMessage(tag..'Информация о скинах не загружена! Через 5 секунд создам папки, игра будет свернута.', -1)
				wait(5000)
				if not directory_exists(getWorkingDirectory() .. "\\resource\\skin") then os.execute("mkdir moonloader\\resource\\skin") end
				if not directory_exists(getWorkingDirectory().. "\\resource\\auto") then os.execute("mkdir moonloader\\resource\\auto") end
				wait(3000)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				sampAddChatMessage(tag..'Папка была создана, начинаю загрузку файлов. Следить за прогрессом можно нажав Ё (~)', -1)
				sampAddChatMessage(tag..'Примерное время ожидания ~= 5 минут.', -1)
				sampAddChatMessage(tag..'В случае, если вы выйдите из игры досрочно - установка будет начата с начала.', -1)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				local dlstatus = require('moonloader').download_status
				for i = 0, 311 do
					downloadUrlToFile("https://assets.open.mp/assets/images/skins/"..i..".png", getWorkingDirectory() .. '\\resource\\skin\\skin_'..i..'.png', function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							print('Загружаю информацию о скинах: ' .. i .. '/311')
							if i == 311 then
								print('Скачаю ещё и информацию о авто, ожидайте.') 
							end
						end 
					end)
				end
				for i = 400,611 do
					downloadUrlToFile("https://gta-serv.ru/images/stories/vehicle/vehicle_".. i ..".jpg", getWorkingDirectory() .. '\\resource\\auto\\vehicle_'..i..'.png', function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							print('Загружаю информацию о авто: ' .. i-400 .. '/211')
						end
						if i==611 then print('Осталось совсем чуть-чуть...') print('Загружаю HTML-цвета ...') end
					end)
				end
				downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/color.txt", getWorkingDirectory() .. '\\resource\\skin\\color.txt', function(id, status)
					if status == dlstatus.STATUS_ENDDOWNLOADDATA then
						print('Установка завершена, можете пользоваться быстрыми ответами в прежнем режиме.')
						start_download = false
					end
				end)
			end)
		else windows.custom_ans.v = not windows.custom_ans.v end
	end
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
function file_exists(name) -- проверяем существование файла
	local f = io.open(name, "r")
	return f ~= nil and io.close(f)
 end
---========================== /KEYSYNC =============================----
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
					keysync('off')
				end
			else
				mimgui.Text(u8"Игрок потерян, обновляю рекон...")
				auto_update_recon()
				if not windows.recon_menu.v then windows.menu_in_recon.v = false keysync('off') end
			end
		mimgui.End()
    end
)
function auto_update_recon()
	if not start_update_recon then
		start_update_recon = true
		lua_thread.create(function()
			wait(1000)
			while not doesCharExist(target) and windows.recon_menu.v do
				sampSendClickTextdraw(textdraw.refresh)
				printStyledString('auto - update...', 500, 4)
				wait(1000)
				keysync(control_player_recon)
			end
			start_update_recon = false
		end)
	end
end 
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
function keysync(playerId)
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
end
local transliterationTable = {
    ['й'] = 'q', ['ц'] = 'w', ['у'] = 'e', ['к'] = 'r', ['е'] = 't', ['н'] = 'y', ['г'] = 'u', ['ш'] = 'i', ['щ'] = 'o',
    ['з'] = 'p', ['х'] = '[', ['ъ'] = ']', ['ф'] = 'a', ['ы'] = 's', ['в'] = 'd', ['а'] = 'f', ['п'] = 'g', ['р'] = 'h',
    ['о'] = 'j', ['л'] = 'k', ['д'] = 'l', ['ж'] = ';', ['э'] = "'", ['я'] = 'z', ['ч'] = 'x', ['с'] = 'c', ['м'] = 'v',
    ['и'] = 'b', ['т'] = 'n', ['ь'] = 'm', ['б'] = ',', ['ю'] = '.', ['ё'] = '`',
    
    ['q'] = 'й', ['w'] = 'ц', ['e'] = 'у', ['r'] = 'к', ['t'] = 'е', ['y'] = 'н', ['u'] = 'г', ['i'] = 'ш', ['o'] = 'щ',
    ['p'] = 'з', ['['] = 'х', [']'] = 'ъ', ['a'] = 'ф', ['s'] = 'ы', ['d'] = 'в', ['f'] = 'а', ['g'] = 'п', ['h'] = 'р',
    ['j'] = 'о', ['k'] = 'л', ['l'] = 'д', [';'] = 'ж', ["'"] = 'э', ['z'] = 'я', ['x'] = 'ч', ['c'] = 'с', ['v'] = 'м',
    ['b'] = 'и', ['n'] = 'т', ['m'] = 'ь', [','] = 'б', ['.'] = '/', ['`'] = 'ё', ['/'] = '.',
}

function translateText(input)
    local output = ''
    for i = 1, string.len(input) do
		local translatedChar = nil
        local char = string.sub(input, i, i)
		for k,v in pairs(transliterationTable) do
        	if k == char then
				translatedChar = v
				break
			elseif v == chat then
				translatedChar = k
				break
			end
		end
        if translatedChar then output = output .. translatedChar
		else output = output .. char end
    end
    return output
end
function encrypt(text, shift)
	local encrypted = ""
	for i = 1, #text do
	  local char = text:sub(i, i)
	  if char >= "a" and char <= "z" then
		local ascii = string.byte(char)
		ascii = (ascii - 97 + shift) % 26 + 97
		char = string.char(ascii)
	  elseif char >= "A" and char <= "Z" then
		local ascii = string.byte(char)
		ascii = (ascii - 65 + shift) % 26 + 65
		char = string.char(ascii)
	  elseif char >= "а" and char <= "я" then
		local ascii = string.byte(char)
		ascii = (ascii - 224 + shift) % 32 + 224
		char = string.char(ascii)
	  elseif char >= "А" and char <= "Я" then
		local ascii = string.byte(char)
		ascii = (ascii - 192 + shift) % 32 + 192
		char = string.char(ascii)
	  end
	  encrypted = encrypted .. char
	end
	return encrypted
end
----------------- ДЛЯ ID В КИЛЛ ЧАТЕ ----------- ТЕМЫ -------------------(НИЖЕ БОЛЬШЕ НИЧЕГО НЕТ.)
function style(id) -- ТЕМЫ
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
style(checkbox.style_selected.v)

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


