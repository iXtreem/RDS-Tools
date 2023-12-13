require 'lib.moonloader'									-- Считываем библиотеки Moonloader
require 'lib.sampfuncs' 									-- Считываем библиотеки SampFuncs
require 'my_lib'											-- Комбо функций необходимых для скрипта
script_name 'AdminTools [AT]'  								-- Название скрипта 
script_author 'Neon4ik' 									-- Псевдоним разработчика
script_properties("work-in-pause") 							-- Возможность обрабатывать информацию, находясь в AFK
local version = 5.1 			 							-- Версия скрипта

------=================== Загрузка модулей ===================----------------------
local imgui 			= require 'imgui' 					-- Визуализация скрипта, окно программы
local sampev		 	= require 'lib.samp.events'					-- Считывание текста из чата
local imadd 			= require 'imgui_addons' 			-- Замена имгуи CheckBox'a
local mimgui 			= require 'mimgui'					-- Мимгуи для работы keysyns
local inicfg 			= require 'inicfg'					-- Сохранение/загрузка конфигов
local encoding 			= require 'encoding'				-- Дешифровка на русский язык
local vkeys 			= require 'vkeys' 					-- Работа с нажатием клавиш
local ffi 				= require "ffi"						-- Работа с открытым чатом
local fa 				= require 'faicons'					-- Иконки в imgui
local mem 				= require 'memory'					-- Работа с памятью игры
local font 				= require ('moonloader').font_flag	-- Шрифты визуальных текстов на экране
encoding.default 		= 'CP1251' 
local u8 				= encoding.UTF8


local AT_MP 			= import("\\resource\\AT_MP.lua") 			-- подгрузка плагина для мероприятий
local AT_FastSpawn 		= import("\\resource\\AT_FastSpawn.lua")  	-- подгрузка быстрого спавна
local AT_Trassera 		= import("\\resource\\AT_Trassera.lua") 	-- подгрузка трассеров
local plagin_notify		= import('\\lib\\lib_imgui_notf.lua')
local tag 				= '{2B6CC4}Admin Tools: {F0E68C}' 	-- Задаем название скрипта в самой игре
local sw, sh 			= getScreenResolution()           	-- Узнаем разрешение экрана пользователя
local AFK 				= false								-- основной триггер скрипта, афк мы или нет

local cfg = inicfg.load({   ------------ Загружаем базовый конфиг, если он отсутствует
	settings = {
		style = 0,
		autoonline = false,
		inputhelper = true,
		add_answer_report = true,
		notify_report = false,
		automute = false,
		smart_automute = false,
		render_admins_positionX = sw - 300,
		render_admins_positionY = sh - 300,
		render_admins = false,
		mytextreport = '|| Приятной игры на RDS <3',
		position_recon_menu_x = sw - 270,
		position_recon_menu_y = 0,
		keysync = true,
		wallhack = true,
		answer_player_report = false,
		admin_chat = true,
		position_adminchat_x = -2,
		position_adminchat_y = sh*0.5-100,
		custom_answer_save = false,
		find_form = false,
		on_custom_recon_menu = true,
		on_custom_answer = true,
		position_ears_x = sw*0.5+200,
		position_ears_y = sh*0.2,
		size_adminchat = 10,
		size_ears = 10,
		strok_ears = 6,
		strok_admin_chat = 6,
		keysyncx = sh/2 + 100,
		keysyncy = sw/2 + 20,
		on_color_report = false,
		color_report = '*',
		fast_key_ans = 'None',
		fast_key_addText = 'None',
		fast_key_wallhack = 'None',
		key_start_fraps = 'None',
		prefixh = '',
		prefixma = '',
		prefixa = '',
		prefixsa = '',
		autoprefix = true,
		forma_na_ban = false,
		forma_na_jail = false,
		forma_na_kick = false,
		forma_na_mute = false,
		add_mynick_in_form = false,
		size_text_f6 = 12,
		enter_report = true,
		open_tool = 'F3',
		weapon_hack = false,
		color_report = '*',
		autoaccept_form = false,
		bloknotik = '',
		start_fraps = false,
	},
	customotvet = {},
	myflood = {},
	my_command = {},
	binder_key = {},
	render_admins_exception = {},
	mute_players = {data = os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year},
}, 'AT//AT_main.ini')
inicfg.save(cfg, 'AT//AT_main.ini')
style(cfg.settings.style)

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
	check_smart_automute 	= imgui.ImBool(cfg.settings.smart_automute),
	check_on_custom_answer  = imgui.ImBool(cfg.settings.on_custom_answer),
	check_color_report 		= imgui.ImBool(cfg.settings.on_color_report),
	check_weapon_hack 		= imgui.ImBool(cfg.settings.weapon_hack),
	checked_radio_button 	= imgui.ImInt(1),
	custom_ans 				= imgui.ImInt(4),
	new_binder_key 			= imgui.ImInt(1),
	style_selected 			= imgui.ImInt(cfg.settings.style),
	selected_adminchat		= imgui.ImInt(cfg.settings.size_adminchat),
	selected_adminchat2 	= imgui.ImInt(cfg.settings.strok_admin_chat),
	selected_ears 			= imgui.ImInt(cfg.settings.size_ears),
	selected_ears2			= imgui.ImInt(cfg.settings.strok_ears),
	option_find_log 		= imgui.ImInt(2),
	button_enter_in_report 	= imgui.ImBool(cfg.settings.enter_report),
	check_render_ears 		= imgui.ImBool(false),
	add_full_words 			= imgui.ImBool(true),
	check_start_fraps 		= imgui.ImBool(cfg.settings.start_fraps),
	inputhelper			  	= imgui.ImBool(cfg.settings.inputhelper),
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
	new_prfh 			= imgui.ImBuffer(cfg.settings.prefixh, 256),
	new_prfma 			= imgui.ImBuffer(cfg.settings.prefixma, 56),
	new_prfa 			= imgui.ImBuffer(cfg.settings.prefixa, 256),
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
local textdraw 			= {} 											-- узнаем ид текстравов для взаимодействия с ними
local admin_form 		= {} 											-- Работа с админ-формами
local nakazatreport 	= {}											-- Возможность наказать прямо из репорта
local answer 			= {} 											-- Выбор ответа в репорте
local adminchat 		= {}											-- Все админ-сообщения хранятся тут
local ears 				= {}											-- Все /ears сообщения хранятся тут
local inforeport 		= {}											-- Вся информация о игроке в реконе хранится тут
local pravila 			= {}											-- Правила/команды хранятся тут (/ahelp)
local menu 				= 'Главное меню' 								-- Разные вкладки в F3
local menu_in_recon 	= 'Главное меню'								-- Разные вкладки в реконе
local atr 				= false											-- альтернатива /tr
local check_weapon		= false											-- проверка игрока на читы, защита от бага с диалогом
local start_fraps		= false											-- переменная автоматического запуска фрапса
local flood = { -- сборник ID
	message = {}, -- Сообщение
	time = {}, -- время отправки
	count = {} -- кол-во повторных сообщений
}
local textdraw_delete = {  												-- Текстдравы из рекон меню, подлежащие удалению (заменить при обнове)
	144, 146, 141, 155, 153, 152, 154, 160, 179, 159, 157, 164, 180, 161,
	169, 181, 166, 168, 174, 182, 171, 173, 150, 183, 183, 147, 149, 142,
	143, 184, 176, 145, 158, 162, 163, 167, 172, 148
}
--================== Название авто ID = [0],[1],[2],[3]...[n]  =====================
local name_car = {'Landstalker','Bravura','Buffalo','Linerunner','Perrenial','Sentinel','Dumper','Firetruck','Trashmaster','Stretch','Manana','Infernus','Voodoo','Pony','Mule','Cheetah','Ambulance','Leviathan','Moonbeam','Esperanto','Taxi','Washington','Bobcat','Mr Whoopee','BF Injection','Hunter','Premier','Enforcer','Securicar','Banshee','Predator','Bus','Rhino','Barracks','Hotknife','Trailer','Previon','Coach','Cabbie','Stallion','Rumpo','RC Bandit','Romero','Packer','Monster','Admiral','Squalo','Seasparrow','Pizzaboy','Tram','Trailer2','Turismo','Speeder','Reefer','Tropic','Flatbed','Yankee','Caddy','Solair','BerkleysRCVan','Skimmer','PCJ-600','Faggio','Freeway','RC Baron','RC Raider','Glendale','Oceanic','Sanchez','Sparrow','Patriot','Quad','Coastguard','Dinghy','Hermes','Sabre','Rustler','ZR-350','Walton','Regina','Comet','BMX','Burrito','Camper','Marquis','Baggage','Dozer','Maverick','News Chopper','Rancher','FBI Rancher','Virgo','Greenwood','Jetmax','Hotring','Sandking','Blista Compact','Police Maverick','Boxville','Benson','Mesa','RC Goblin','Hotring Racer A','Hotring Racer B','Bloodring Banger','Rancher','Super GT','Elegant','Journey','Bike','Mountain Bike','Beagle','Cropdust','Stunt','Tanker','Roadtrain','Nebula','Majestic','Buccaneer','Shamal','Hydra','FCR-900','NRG-500','HPV1000','Cement Truck','Tow Truck','Fortune','Cadrona','FBI Truck','Willard','Forklift','Tractor','Combine','Feltzer','Remington','Slamvan','Blade','Freight','Streak','Vortex','Vincent','Bullet','Clover','Sadler','Firetruck LA','Hustler','Intruder','Primo','Cargobob','Tampa',	'Sunrise','Merit','Utility','Nevada','Yosemite','Windsor','Monster A','Monster B','Uranus','Jester',	'Sultan',	'Stratum','Elegy','Raindance','RC Tiger',	'Flash',	'Tahoma','Savanna','Bandito','Freight Flat','Streak Carriage','Kart','Mower','Duneride','Sweeper','Broadway','Tornado','AT-400','DFT-30','Huntley','Stafford','BF-400','Newsvan','Tug','Trailer3','Emperor','Wayfarer','Euros','Hotdog','Club','Freight Carriage','Trailer4','Andromada','Dodo','RC Cam','Launch','Police Car (LSPD)','Police Car (SFPD)','Police Car (LVPD)','Police Ranger','Picador','S.W.A.T. Van','Alpha','Phoenix','Glendale','Sadler','Luggage Trailer A','Luggage Trailer B','Stair Trailer','Boxville','Farm Plow','Utility Trailer',}
---================= Задаем шрифт админ-чата =====================------------
local font_adminchat = renderCreateFont("Calibri", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW)
---================= Задаем шрифт ears-чата =====================------------
local font_earschat = renderCreateFont("Calibri", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)
---================= Задаем шрифт рендера игроков =====================------------
local spisokoskrod = { -- автомут на оск род
	'mq', 
	'rnq'
} 
local spisokrz = {  -- примерный розжиг
	'слава укр', 
	'слава росс'
}
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
	'amazing',
	'амазинг',
}
--------======================== Задаем шрифт и размер для имгуи текста ============--------------------
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
	while not isSampAvailable() do wait(1000) end
	while not sampIsLocalPlayerSpawned() do wait(1000) end
	local dlstatus = require('moonloader').download_status
    downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.ini", 'moonloader\\' .. '//config//AT//AdminTools.ini', function(id, status) end)
	local AdminTools = inicfg.load(nil, 'moonloader\\' .. '//config//AT//AdminTools.ini')
	if AdminTools then
		if AdminTools.script.info then update_info = AdminTools.script.info end
		if AdminTools.script.version > version then
			if AdminTools.script.main then
				sampAddChatMessage(tag .. 'Обнаружено новое {808080}обязательное {F0E68C}обновление скрипта! Произвожу самообновление.', -1)
				update('all')
			end
			update_main = true
		end
		if cfg.settings.versionFS and cfg.settings.versionMP then
			if AdminTools.script.versionMP > cfg.settings.versionMP then update_mp = true end
			if AdminTools.script.versionFS > cfg.settings.versionFS then update_fs = true end
		else sampAddChatMessage(tag .. 'Дополнительные модули не подгружены! Сообщите об этом разработчику, или переустановите скрипт.', -1) end
		if sampGetCurrentServerAddress() ~= '46.174.52.246' and sampGetCurrentServerAddress() ~= '46.174.49.170' then
			sampAddChatMessage(tag .. 'Я предназначен для RDS, там и буду работать.', -1)
			ScriptExport()
		end
		if update_main or update_fs or update_mp then
			sampAddChatMessage       ('==================================================================================', '0x'..(color()))
			sampAddChatMessage(tag .. 'Обнаружено новое {FF0000}обновление {F0E68C}, вводи /update, чтобы обновить скрипт', '0x'..(color()))
			sampAddChatMessage       ('==================================================================================', '0x'..(color()))
		else sampAddChatMessage(tag .. 'Скрипт успешно загружен. Активация F3(/tool)', -1) end
	end
	local AdminTools = nil

	--------------------============ ПРАВИЛА И КОМАНДЫ =====================---------------------------------
	local rules = file_exists('moonloader\\' .. "\\config\\AT\\rules.txt") if not rules then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", 'moonloader\\' .. "\\config\\AT\\rules.txt", function(id, status) end) end
	local AutoMute_mat = file_exists('moonloader\\' .. "\\config\\AT\\mat.txt") if not AutoMute_mat then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/mat.txt", 'moonloader\\' .. "\\config\\AT\\mat.txt", function(id, status) end) end
	local AutoMute_osk = file_exists('moonloader\\' .. "\\config\\AT\\osk.txt") if not AutoMute_osk then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/osk.txt", 'moonloader\\' .. "\\config\\AT\\osk.txt", function(id, status) end) end	
	local rules = io.open('moonloader\\' .. "\\config\\AT\\rules.txt","r")
	if rules then for line in rules:lines() do pravila[#pravila + 1] = line;end rules:close() end
	
	--------------------============ АВТОМУТ =====================---------------------------------
	local AutoMute_mat = io.open('moonloader\\' .. "\\config\\AT\\mat.txt", "r")
	if AutoMute_mat then for line in AutoMute_mat:lines() do line = u8:decode(line) if line and #(line) > 2 then mat[#mat + 1] = line end;end AutoMute_mat:close() end
	
	local AutoMute_osk = io.open('moonloader\\' .. "\\config\\AT\\osk.txt", "r")
	if AutoMute_osk then for line in AutoMute_osk:lines() do line = u8:decode(line) if line and #(line) > 2 then osk[#osk + 1] = line end;end AutoMute_osk:close() end
	--------------------============ АВТОМУТ =====================---------------------------------
	local data_today = os.date("*t") -- узнаем дату сегодня
	if cfg.mute_players.data ~= data_today.day..'.'.. data_today.month..'.'..data_today.year then
		cfg.mute_players = {} -- сброс значений умного автомута если наступил следующий день
		cfg.mute_players.data = data_today.day..'.'.. data_today.month..'.'..data_today.year
		save()
	end
	--=========== ЧАТ ЛОГГ =======-----
	local log = ('moonloader\\'..'\\config\\chatlog\\chatlog '.. data_today.day..'.'..data_today.month..'.'..data_today.year..'.txt')
	if not directory_exists('moonloader\\'..'\\config\\chatlog\\') then os.execute("mkdir moonloader\\config\\chatlog") print('Папка отсутствовала, создал новую.') end
	if not file_exists(log) then
		local file = io.open(log,"w")
		file:close()
		print('Создан новый chatlog.txt')
	end
	for k, v in ipairs(scanDirectory('moonloader\\'..'\\config\\chatlog\\')) do
		local data1,data2,data3 = string.sub(string.gsub(string.gsub(v, 'chatlog ', ''), '%.',' '), 1,-5):match('(%d+) (%d+) (%d+)')
		if data3 and data2 and data3 then
			if tonumber(daysPassed(data3,data2,data1)) < 3 then
				file = io.open('moonloader\\'..'\\config\\chatlog\\'..v,'r')
				for line in file:lines() do
					if k == 1 then chatlog_1[#chatlog_1 + 1] = string.gsub(encrypt(line, -3), '{%w%w%w%w%w%w}','')
					elseif k == 2 then chatlog_2[#chatlog_2 + 1] = string.gsub(encrypt(line, -3), '{%w%w%w%w%w%w}','')
					elseif k == 3 then chatlog_3[#chatlog_3 + 1] = string.gsub(encrypt(line, -3), '{%w%w%w%w%w%w}','') end
				end
				file:close()
			else os.remove('moonloader\\'..'\\config\\chatlog\\' .. v) end -- если чатлогу больше 3 дней (вкл) то удаляем его
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
	local font_watermark = renderCreateFont("Javanese Text", 8, font.BOLD + font.BORDER + font.SHADOW)
	while true do
        wait(1)
		renderFontDrawText(font_watermark, tag..'{808080}version['..version..']', 10, sh-20, 0xCCFFFFFF) 
		if isPauseMenuActive() or isGamePaused() then AFK = true end
		if AFK and not (isPauseMenuActive() or isGamePaused()) then AFK = false end
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
local basic_command = { -- базовые команды, 1 аргумент = символ '_'
	prochee = {
		update  = 		'Обновить скрипт',
		ears 	=		'Включить рендер личных сообщений игроков',
		ahelp 	= 		'Все команды скрипта/сервера и правила',
		wh 		= 		'Включить WallHack',
		c 		=		'Быстрый ответ игроку в формате репорта',
		tool 	= 		'Активировать меню АТ',
		sbanip 	= 		'Выдать блокировку аккаунта с IP адресом (ФД!)',
		opencl  = 		'Открыть меню чат-логгера',
		atr 	=		'бесплатная альтернатива /tr, автоматически берет новые репорты',
		spp 	= 		'Заспавнить игроков в радиусе',
		prfma 	= 		'Выдать префикс мл.админу',
		prfa 	= 		'Выдать префикс админу',
		prfsa 	= 		'Выдать префикс старшему админу',
		prfpga 	= 		'Выдать префикс ПГА',
		prfzga 	= 		'Выдать префикс ЗГА',
		prfga 	= 		'Выдать префикс ГА',
		color_report   ='Назначить цвет ответа на репорт',
		autoaccept_form='Автопринятие админ-форм',
		size_chat	   ='Изменить размер рендера информации открытого чата',
		add_autoprefix ='Добавить администратора в исключение автопрефикса',
		del_autoprefix ='Удалить администратора из исключений автопрефикса',
	},
	help = {
		uu      =  		'/unmute _',
		uj      =  		'/unjail _',
		ur      =  		'/unrmute _',
		uuf 	=		'/muteakk _ 5 Наказание снято.',
		ujf 	=		'/jailakk _ 5 Наказание снято.',
		urf 	= 		'/rmuteoff _ 5 Наказание снято.',
		as      =  		'/aspawn _',
		gv 		=		'/giveaccess _',
		mk 		=		'/makeadmin _',
		sa		=		'/setadmin',
		sn 		=		'/setnick _',
		stw     =  		'/setweap _ 38 5000',
		vig 	=		"/vvig _ 1 Злоупотребление VIP'ом",
		prfma   =  		'/prefix _ Мл.Администратор ' .. cfg.settings.prefixma,
		prfa    =  		'/prefix _ Администратор ' .. cfg.settings.prefixa,
		prfsa   =  		'/prefix _ Ст.Администратор ' .. cfg.settings.prefixsa,
		prfpga  =  		'/prefix _ Помощник.Глав.Администратора ' .. color(),
		prfzga  =  		'/prefix _ Зам.Глав.Администратора ' .. color(),
		prfga   =  		'/prefix _ Главный-Администратор ' .. color(),
		prfcpec =  		'/prefix _ Спец.Администратор ' .. color(),
	},
	ans = { 														-- с вариативностью есть доп/текст или нет
		nv      =  		'/ot _ Игрок не в сети',
		cl      =  		'/ot _ Данный игрок чист.',
		pmv     =  		'/ot _ Помогли вам. Обращайтесь ещё',
		dpr     =  		'/ot _ У игрока куплены функции за /donate',
		afk     =  		'/ot _ Игрок бездействует или находится в AFK',
		nak     =  		'/ot _ Игрок был наказан! Благодарим за обращение.',
		n       =  		'/ot _ Нарушений со стороны игрока не наблюдается.',
		fo      =  		'/ot _ Обратитесь с данной проблемой на форум https://forumrds.ru',
		rep     =  		'/ot _ Нашли нарушителя? Появился вопрос? Напишите /report!',
		sl  	=		'/ot _ Слежу за данным игроком!',
		al 		=		'/ans _ Здравствуйте! Вы забыли ввести /alogin !\n'..
						'/ans _ Введите /alogin и свой пароль, пожалуйста.',
	},
	mute = { -- ВНИМАНИЕ КОМАНДЫ ДЛЯ ВЫДАЧИ В ОФФЛАЙНЕ СОЗДАЮТСЯ САМИ С ОКОНЧАНИЕМ -f
		fd      =  		'/mute _ 120 Флуд',					--[[x10]]fd2='/mute _ 240 Флуд x2',fd3='/mute _ 360 Флуд x3',fd4='/mute _ 480 Флуд x4',fd5='/mute _ 600 Флуд x5',fd6='/mute _ 720 Флуд x6',fd7='/mute _ 840 Флуд x7',fd8='/mute _ 960 Флуд x8',fd9='/mute _ 1080 Флуд x9',fd10='/mute _ 1200 Флуд x10',
		po 		=  		'/mute _ 120 Попрошайничество',		--[[x10]]po2='/mute _ 240 Попрошайничество x2',po3='/mute _ 360 Попрошайничество x3',po4 ='/mute _ 480 Попрошайничество x4',po5 ='/mute _ 600 Попрошайничество x5',po6 ='/mute _ 720 Попрошайничество x6',po7 ='/mute _ 840 Попрошайничество x7',po8 ='/mute _ 960 Попрошайничество x8',po9 ='/mute _ 1080 Попрошайничество x9',po10 ='/mute _ 1200 Попрошайничество x10',
		m       =  		'/mute _ 300 Нецензурная лексика',	--[[x10]]m2='/mute _ 600 Нецензурная лексика x2',m3='/mute _ 900 Нецензурная лексика x3',m4='/mute _ 1200 Нецензурная лексика x4',m5='/mute _ 1500 Нецензурная лексика x5',m6='/mute _ 1800 Нецензурная лексика x6',m7='/mute _ 2100 Нецензурная лексика x7',m8='/mute _ 2400 Нецензурная лексика x8',m9='/mute _ 2700 Нецензурная лексика x9',m10='/mute _ 3000 Нецензурная лексика x10',
		ok      =  		'/mute _ 400 Оскорбление/Унижение',	--[[x10]]ok2='/mute _ 800 Оскорбление/Унижение x2',ok3='/mute _ 1200 Оскорбление/Унижение x3',ok4='/mute _ 1600 Оскорбление/Унижение x4',ok5='/mute _ 2000 Оскорбление/Унижение x5',ok6='/mute _ 2400 Оскорбление/Унижение x6',ok7='/mute _ 2800 Оскорбление/Унижение x7',ok8='/mute _ 3200 Оскорбление/Унижение x8',ok9='/mute _ 3600 Оскорбление/Унижение x9',ok10='/mute _ 4000 Оскорбление/Унижение x10',
		up 		=  		'/mute _ 1000 Упом. сторонних проектов',
		oa 		=  		'/mute _ 2500 Оскорбление администрации',
		kl 		=  		'/mute _ 3000 Клевета на администрацию',
		zs 		=  		'/mute _ 600 Злоупотребление символами',
		nm 		=  		'/mute _ 600 Неадекватное поведение.',
		rekl 	=  		'/mute _ 1000 Реклама',
		rz		=  		'/mute _ 5000 Розжиг межнац. розни',
		ia 		=  		'/mute _ 2500 Выдача себя за администратора',
	},
	rmute = { -- ВНИМАНИЕ КОМАНДЫ ДЛЯ ВЫДАЧИ В ОФФЛАЙНЕ СОЗДАЮТСЯ САМИ С ОКОНЧАНИЕМ -f
		oft 	= 		'/rmute _ 120 оффтоп в репорт',		--[[x10]]oft2='/rmute _ 240 оффтоп в репорт x2',oft3='/rmute _ 360 оффтоп в репорт x3',oft4='/rmute _ 480 оффтоп в репорт х4',oft5='/rmute _ 600 оффтоп в репорт х5',oft6='/rmute _ 720 оффтоп в репорт x6',oft7='/rmute _ 840 оффтоп в репорт х7',oft8='/rmute _ 960 оффтоп в репорт х8',oft9='/rmute _ 1080 оффтоп в репорт х9',oft10='/rmute _ 1200 оффтоп в репорт х10',
		cp 		= 		'/rmute _ 120 caps in /report',		--[[x10]]cp2='/rmute _ 240 Caps in /report x2',cp3='/rmute _ 360 Caps in /report x3',cp4='/rmute _ 480 Caps in /report x4',cp5='/rmute _ 600 Caps in /report x5',cp6='/rmute _ 720 Caps in /report x6',cp7='/rmute _ 840 Caps in /report x7',cp8='/rmute _ 960 Caps in /report x8',cp9='/rmute _ 1080 Caps in /report x9',cp10='/rmute _ 1200 Caps in /report x10',
		rpo		=		'/rmute _ 120 Попрошайка в /report',--[[x10]]rpo2='/rmute _ 240 Попрошайка в /report x2',rpo3='/rmute _ 360 Попрошайка в /report x3',rpo4='/rmute _ 480 Попрошайка в /report x4',rpo5='/rmute _ 600 Попрошайка в /report x5',rpo6='/rmute _ 720 Попрошайка в /report x6',rpo7='/rmute _ 840 Попрошайка в /report x7',rpo8='/rmute _ 960 Попрошайка в /report x8',rpo9='/rmute _ 1080 Попрошайка в /report x9',rpo10='/rmute _ 1200 Попрошайка в /report x10',
		rm 		= 		'/rmute _ 300 мат в /report',		--[[x10]]rm2='/rmute _ 600 мат в /report x2',rm3='/rmute _ 900 мат в /report x3',rm4='/rmute _ 600 мат в /report x4',rm5='/rmute _ 600 мат в /report x5',rm6='/rmute _ 600 мат в /report x6',rm7='/rmute _ 600 мат в /report x7',rm8='/rmute _ 600 мат в /report x8',rm9='/rmute _ 600 мат в /report x9',rm10='/rmute _ 600 мат в /report x10',
		rok 	= 		'/rmute _ 400 Оскорбление в /report',--[[x10]]rok2='/rmute _ 800 Оскорбление в /report x2',rok3='/rmute _ 1200 Оскорбление в /report x3',rok4='/rmute _ 1600 Оскорбление в /report x4',rok5='/rmute _ 2000 Оскорбление в /report x5',rok6='/rmute _ 2400 Оскорбление в /report x6',rok7='/rmute _ 2800 Оскорбление в /report x7',rok8='/rmute _ 3200 Оскорбление в /report x8',rok9='/rmute _ 3600 Оскорбление в /report x9',rok10='/rmute _ 4000 Оскорбление в /report x10',
		roa 	= 		'/rmute _ 2500 Оскорблeние администрации',
		ror 	= 		'/rmute _ 5000 Оскорблeние/Упоминание родных',
		rzs 	= 		'/rmute _ 600 Злоупотребление символaми',
		rrz 	= 		'/rmute _ 5000 Розжиг межнац. рoзни',
		rkl 	= 		'/rmute _ 3000 Клевeта на администрацию'
	},
	jail = { -- ВНИМАНИЕ КОМАНДЫ ДЛЯ ВЫДАЧИ В ОФФЛАЙНЕ СОЗДАЮТСЯ САМИ С ОКОНЧАНИЕМ -f
		bg 		= 		'/jail _ 300 Багоюз',
		td 		= 		'/jail _ 300 car in /trade',
		jm 		= 		'/jail _ 300 Нарушение правил МП',	--[[x10]]jm2='/jail _ 600 Нарушение правил МП x2',jm3='/jail _ 900 Нарушение правил МП x3',jm4='/jail _ 1200 Нарушение правил МП x4',jm5='/jail _ 1500 Нарушение правил МП x5',jm6='/jail _ 1800 Нарушение правил МП x6',jm7='/jail _ 2100 Нарушение правил МП x7',jm8='/jail _ 2400 Нарушение правил МП x8',jm9='/jail _ 2700 Нарушение правил МП x9',jm10='/jail _ 3000 Нарушение правил МП x10',
		dz		=		'/jail _ 300 ДМ/ДБ в зеленой зоне',	--[[x10]]dz2='/jail _ 600 ДМ/ДБ в зеленой зоне x2',dz3='/jail _ 900 ДМ/ДБ в зеленой зоне x3',dz4='/jail _ 1200 ДМ/ДБ в зеленой зоне x4',dz5='/jail _ 1500 ДМ/ДБ в зеленой зоне x5',dz6='/jail _ 1800 ДМ/ДБ в зеленой зоне x6',dz7='/jail _ 2100 ДМ/ДБ в зеленой зоне x7',dz8='/jail _ 2400 ДМ/ДБ в зеленой зоне x8',dz9='/jail _ 2700 ДМ/ДБ в зеленой зоне x9',dz10='/jail _ 3000 ДМ/ДБ в зеленой зоне x10',
		sk 		= 		'/jail _ 300 Spawn Kill',			--[[x10]]sk2='/jail _ 600 Spawn Kill x2',sk3='/jail _ 900 Spawn Kill x3',sk4='/jail _ 1200 Spawn Kill x4',sk5='/jail _ 1500 Spawn Kill x5',sk6='/jail _ 1800 Spawn Kill x6',sk7='/jail _ 2100 Spawn Kill x7',sk8='/jail _ 2400 Spawn Kill x8',sk9='/jail _ 2700 Spawn Kill x9',sk10='/jail _ 3000 Spawn Kill x10',
		dk 		= 		'/jail _ 900 ДБ Ковш в зеленой зоне',
		jc 		= 		'/jail _ 900 сторонний скрипт/ПО',
		sh 		= 		'/jail _ 900 SpeedHack/FlyCar',
		prk 	=		'/jail _ 900 Parkour mode',
		vs 		=		'/jail _ 900 Дрифт мод',
		jcb 	= 		'/jail _ 3000 читерский скрипт/ПО',
		zv 		= 		"/jail _ 3000 Злоупотребление VIP'ом",
		dmp 	= 		'/jail _ 3000 Серьезная помеха на МП',
	},
	ban = { -- ВНИМАНИЕ КОМАНДЫ ДЛЯ ВЫДАЧИ В ОФФЛАЙНЕ СОЗДАЮТСЯ САМИ С ОКОНЧАНИЕМ -f
		bh 		= 		'/ban _ 3 Нарушение правил /helper',
		nmb 	= 		'/iban _ 3 Неадекватное поведение',
		ch 		= 		'/iban _ 7 читерский скрипт/ПО',
		obh 	= 		'/iban _ 7 Обход прошлого бана',
		bosk 	= 		'/siban _ 999 Оскорбление проекта',
		rk 		= 		'/siban _ 999 Реклама',
		obm 	= 		'/siban _ 30 Обман/Развод',
		pl 		= 		'/ban _ 7 Плагиат ника администратора',
	},
	kick = {
		kk3 	= 		'/ban _ Смените ник 3/3',
		kk2 	= 		'/kick _ Смените ник 2/3',
		kk1 	= 		'/kick _ Смените ник 1/3',
		cafk 	= 		'/kick _ AFK in /arena',
		jk 		= 		'/kick _ DM in jail',
	},
}
--------============= Инициализируем команды, указанные выше ===========================---------------------------
for k,v in pairs(basic_command.ans) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then for k,v in pairs(textSplit(v, '\n')) do sampSendChat(string.gsub(v, '_', param)) end else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.mute) do  sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param) ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1)  end end) end
for k,v in pairs(basic_command.rmute) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.jail) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.kick) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.ban) do sampRegisterChatCommand(k, function(param)  if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
for k,v in pairs(basic_command.help) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end
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
	if #param == 6 then
		cfg.settings.color_report = '{'..param..'}'
		save()
		sampAddChatMessage(tag ..cfg.settings.color_report.. 'Выбранный цвет', -1)
	elseif param == '*' then
		cfg.settings.color_report = '*'
		save()
		sampAddChatMessage(tag .. '{C0C0C0}Теперь {FF0000}у вас {9370DB}будут {8FBC8F}разные {7CFC00}цвета {FFA500}при ответе {AFEEEE}на репорт!', '0x'..color())
	else 
		sampAddChatMessage(tag..'Цвет указан неверно. Введите HTML цвет состоящий из 6 символов', -1) 
		sampAddChatMessage(tag ..'Пример: /color_report FF0000 (будет указан цвет ' .. '{FF0000}Красный' .. '{FFFFFF})', -1)
		sampAddChatMessage(tag ..'Если вы хотите сделать разные цвета при каждом ответе репорта, введите звездочку *', -1)
	end
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
	lua_thread.create(function() 
		for _, id in pairs(playersToStreamZone()) do 
			wait(500) 
			sampSendChat('/aspawn ' .. id) 
		end 
	end)
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
sampRegisterChatCommand('opencl', function(param)
	windows.menu_chatlogger.v = not windows.menu_chatlogger.v
	imgui.Process = true
end)
sampRegisterChatCommand('ahelp', function()
	windows.pravila.v = not windows.pravila.v 
	imgui.Process = true
end)
sampRegisterChatCommand('update', function()
	if sampIsDialogActive() then return false end
	lua_thread.create(function()
		if (update_main or update_fs or update_mp) then
			sampShowDialog(1111, "Обнаружена новая версия AT!", "Примечания к выпуску:\n"..string.gsub(u8:decode(update_info),'\\n','\n')..'\nЖелаете обновиться?', "Да", "Нет", DIALOG_STYLE_MSGBOX) -- сам диалог
			while sampIsDialogActive(1111) do wait(400) end -- ждёт пока вы ответите на диалог
			local _, button, _, _ = sampHasDialogRespond(1111)
			if button == 1 then
				local text = {[0] = '-\n', [1] = '-\n', [2] = '-'}
				if update_main then text[0] = 'AdminTools\n' end
				if update_fs then text[1] = 'FastSpawn\n' end
				if update_mp then text[2] = 'Мероприятия' end
				sampShowDialog(1111, "Выберите, что хотите обновить", (text[0]..text[1]..text[2]), "Выбрать", nil, DIALOG_STYLE_LIST);
				while sampIsDialogActive(1111) do wait(400) end -- ждёт пока вы ответите на диалог
				local _, _, button, _ = sampHasDialogRespond(1111)
				if button == 0 then
					if text[0] ~= '-\n' then update('main') end
				elseif button == 1 then update('fs')
					if text[1] ~= '-\n' then update('fs') end
				elseif button == 2 then update('mp')
					if text[2] ~= '-' then update('mp') end
				end
			end
		else 
			sampShowDialog(1111, "", "Обновлений не обнаружено, у вас актуальная версия.\nЖелаете переустановить пакет AT?", "Да", "Нет", DIALOG_STYLE_MSGBOX) -- сам диалог
			while sampIsDialogActive(1111) do wait(400) end -- ждёт пока вы ответите на диалог
			local _, button, _, _ = sampHasDialogRespond(1111)
			if button == 1 then update('all') end
		end
	end)
end)
sampRegisterChatCommand('atr', function()
	if not atr then sampAddChatMessage('{37aa0d}[Информация] {FFFFFF}Вы{32CD32} включили режим TakeReport.', 0x32CD32)
	else sampAddChatMessage('{37aa0d}[Информация] {FFFFFF}Вы {FF0000}выключили режим TakeReport.', 0x32CD32) end
	atr = not atr
end)
sampRegisterChatCommand('c', function(param)
	if (not sampIsPlayerConnected(tonumber(param))) or (not flood.message[param]) then sampAddChatMessage(tag .. 'ID игрока указан неверно, или игрок не писал ничего в чат.', -1) return false end
	sampev.onShowDialog(2349, DIALOG_STYLE_INPUT, 'tipa title', 'button1', 'button2', 'Игрок: '..sampGetPlayerNickname(param)..'\n\n\nЖалоба:' .. flood.message[param])
	lua_thread.create(function()
		showCursor(true,false)
		while not windows.fast_report.v do wait(300) end
		while windows.fast_report.v and not (answer.rabotay or answer.uto4 or answer.nakajy or answer.customans or answer.slejy or answer.jb or answer.ojid or answer.moiotvet or answer.uto4id or answer.nakazan or answer.otklon or answer.peredamrep) do wait(200) end
		showCursor(false,false)
		if not sampev.onShowDialog(2350, DIALOG_STYLE_INPUT, 'aboba', 'Действие', 'Назад', 'aboba') and peremrep then
			if answer.control_player then sampSendChat('/re ' .. autorid)
			elseif answer.slejy then sampSendChat('/re ' .. reportid)
			elseif answer.peredamrep then sampSendChat('/a ' .. autor .. '[' .. autorid .. '] | ' .. textreport) end
			sampSendChat('/ans ' .. param .. ' ' .. peremrep)
			if answer.slejy and not copies_player_recon and tonumber(autorid) and cfg.settings.answer_player_report then
				local copies_report_id = reportid
				copies_player_recon = autorid
				while not windows.recon_menu.v do wait(100) end
				while windows.recon_menu.v do wait(2000) end
				if copies_player_recon and copies_report_id == control_player_recon then
					if sampIsPlayerConnected(copies_player_recon) then
						imgui.Process, windows.answer_player_report.v = true, true
						for i = 0, 11 do wait(500) if not copies_player_recon or (copies_report_id ~= control_player_recon) then break end end
						if windows.answer_player_report.v then windows.answer_player_report.v = false copies_player_recon = nil end
					else sampAddChatMessage(tag .. 'Игрок, написавший репорт, находится вне сети.', -1) end
				end
			else copies_player_recon = nil end
		else windows.fast_report.v = false end
	end)
end)
sampRegisterChatCommand('autoaccept_form', function(param)
	cfg.settings.autoaccept_form = not cfg.settings.autoaccept_form
	save()
	if cfg.settings.autoaccept_form then
		sampAddChatMessage(tag .. "Авто-принятие форм успешно инициализировано.", -1)
		sampAddChatMessage(tag .. "Помните, что вы несете ответственность за каждое выданное наказание, даже если это форма!", -1)
	else sampAddChatMessage(tag .. "Теперь выбор стоит за вами.", -1) end
end)
sampRegisterChatCommand('ears', function()
	if sampIsDialogActive() then return false end
	sampSendChat('/ears')
	checkbox.check_render_ears.v = not checkbox.check_render_ears.v
	if not checkbox.check_render_ears.v then
		ears = {}
		notify('{66CDAA}[AT] Сканирование ЛС', 'Сканирование личных сообщений\nБыло успешно приостановлено')
	else
		checkbox.check_render_ears.v = true
		notify('{66CDAA}[AT] Сканирование ЛС', 'Сканирование личных сообщений\nБыло успешно инициализировано')
	end
end)
--======================================= РЕГИСТРАЦИЯ КОМАНД ====================================--
function imgui.OnDrawFrame()
	if not windows.render_admins.v and not windows.menu_tools.v and not windows.pravila.v and not windows.fast_report.v and not windows.recon_menu.v and not windows.answer_player_report.v and not windows.menu_chatlogger.v then
		showCursor(false,false)
		if cfg.settings.render_admins then windows.render_admins.v = true
		else imgui.Process = false end
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
		imgui.SetCursorPosX(140)
		imgui.BeginGroup()
			if imgui.Button(fa.ICON_ADDRESS_BOOK, imgui.ImVec2(30, 30)) then 		menu = 'Главное меню' end imgui.SameLine()
			if imgui.Button(fa.ICON_COGS, imgui.ImVec2(30, 30)) then 				menu = 'Дополнительные функции' end imgui.SameLine()
			if imgui.Button(fa.ICON_CALENDAR_CHECK_O, imgui.ImVec2(30, 30)) then 	menu = 'Быстрые клавиши' end imgui.SameLine()
			if imgui.Button(fa.ICON_PENCIL_SQUARE, imgui.ImVec2(30, 30)) then 		menu = 'Блокнот' end imgui.SameLine()
			if imgui.Button(fa.ICON_RSS, imgui.ImVec2(30, 30)) then 				menu = 'Флуды' end imgui.SameLine()
			if imgui.Button(fa.ICON_BOOKMARK, imgui.ImVec2(30, 30)) then 			menu = 'Быстрые ответы' end imgui.SameLine()
			if imgui.Button(fa.ICON_CLOUD, imgui.ImVec2(30, 30)) then 				menu = 'Автомут' end
		imgui.EndGroup()
		imgui.SetCursorPosY(65)
        imgui.Separator()
		imgui.BeginGroup()
			if menu == 'Главное меню' then
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
				if imadd.ToggleButton("##inputhelper", checkbox.inputhelper) then
					cfg.settings.inputhelper = not cfg.settings.inputhelper
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Перевод команд')
				if imadd.ToggleButton("##WallHack", checkbox.check_WallHack) then
					if cfg.settings.wallhack then off_wallhack() else on_wallhack() end
					cfg.settings.wallhack = not cfg.settings.wallhack
					save()
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
						if cfg.settings.forma_na_mute then
							cfg.settings.automute = false
							cfg.settings.smart_automute = false
							checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
							checkbox.check_smart_automute = imgui.ImBool(cfg.settings.smart_automute)
						else
							cfg.settings.automute  = not cfg.settings.automute
							checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
						end
					end
					cfg.settings.smart_automute = not cfg.settings.smart_automute
					save()
				end
				imgui.Tooltip(u8'Оскорбление родных, упоминание сторонних проектов\nАвтомут за "0", флуд детектор.')
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
				if imadd.ToggleButton("##FastReport", checkbox.check_on_custom_answer) then
					cfg.settings.on_custom_answer = not cfg.settings.on_custom_answer
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Кастом ответ на репорт')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##weaponhack", checkbox.check_weapon_hack) then
					cfg.settings.weapon_hack = not cfg.settings.weapon_hack
					save()
				end
				imgui.Tooltip(u8'Автоматически пробивает /iwep новых варнингов на чит-оружие\nМожет вызывать проблемы с открытием диалога\nПри наличии чита - автоматически банит\nПомните, что впервую очередь за все блокировки ответственность несете вы.\nСкриншот сохраняет в:\nC:\\Users\\User\\Документы\\GTA San Andreas User Files\\screens')
				imgui.SameLine()
				imgui.Text(u8'Реакция на чит-оружие')
				if imadd.ToggleButton("##rendervideo", checkbox.check_start_fraps) then
					if cfg.settings.key_start_fraps ~= 'None' then
						cfg.settings.start_fraps = not cfg.settings.start_fraps
						save()
					else 
						sampAddChatMessage(tag .. 'Стоило бы сначала обозначить на какую клавишу будем запускать видео', -1)
						checkbox.check_start_fraps.v = false
					end
				end
				imgui.Tooltip(u8'Автоматически нажимает клавишу, указанную в 3-ем меню\nТуда заносите свою клавишу в программе для записи игр\nПримеры программ: Bandicam, OBS, DXTORY, Fraps ...\nПри входе в рекон видео автоматически запускается с информированием\nПри выходе аналогично - выключается.') 
				imgui.SameLine()
				imgui.Text(u8'Авто-видеофиксация')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##AdminChat", checkbox.check_admin_chat) then
					if cfg.settings.admin_chat then adminchat = {} end
					cfg.settings.admin_chat = not cfg.settings.admin_chat
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Админ чат')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_ARROWS..'##3') then imgui.OpenPopup('settings_adminchat') end
				if imgui.BeginPopup('settings_adminchat') then
					imgui.CenterText(u8'Размер: ')
					if imgui.SliderInt('##Slider3', checkbox.selected_adminchat, 8, 15) then
						cfg.settings.size_adminchat = checkbox.selected_adminchat.v
						save()
						font_adminchat = renderCreateFont("Calibri", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW)
					end
					imgui.CenterText(u8'Кол-во строк: ')
					if imgui.SliderInt('##Slider4', checkbox.selected_adminchat2, 3, 20) then
						cfg.settings.strok_admin_chat = checkbox.selected_adminchat2.v
						save()
						if #adminchat > cfg.settings.strok_admin_chat then for i = cfg.settings.strok_admin_chat, #adminchat do adminchat[i] = nil end end
					end
					if imgui.Button(u8'Изменить позицию',imgui.ImVec2(140,24)) then
						lua_thread.create(function()
							if not adminchat[1] then adminchat[1] = 'Тестовое сообщение для видимости новой позиции.' end 
							sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
							sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
							local old_pos_x, old_pos_y = cfg.settings.position_adminchat_x, cfg.settings.position_adminchat_y
							while true do
								cfg.settings.position_adminchat_x, cfg.settings.position_adminchat_y = getCursorPos()
								if wasKeyPressed(VK_RETURN) then save() break end
								if wasKeyPressed(VK_ESCAPE) then cfg.settings.position_adminchat_x = old_pos_x cfg.settings.position_adminchat_y = old_pos_y break end
								wait(1)
							end
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'Сбросить чат',imgui.ImVec2(125, 24)) then adminchat = {} end
					imgui.EndPopup()
				end
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
				imgui.SetCursorPosX(190)
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
							if wasKeyPressed(VK_RETURN) then save() break end
							if wasKeyPressed(VK_ESCAPE) then cfg.settings.render_admins_positionX = old_pos_x cfg.settings.render_admins_positionY = old_pos_y break end
							wait(1)
						end
						showCursor(false,false)
					end)
					else sampAddChatMessage(tag .. 'Опция выключена, включите её и задайте позицию.',-1) end
				end
				imgui.SameLine()
				imgui.SetCursorPosX(250)
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
				imgui.Text(u8'Рендер /ears')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_ARROWS..'##2') then imgui.OpenPopup('settings_ears') end
				if imgui.BeginPopup('settings_ears') then  
					imgui.CenterText(u8'Размер: ')
					if imgui.SliderInt('##Slider1', checkbox.selected_ears, 8, 15) then
						cfg.settings.size_ears = checkbox.selected_ears.v
						save()
						font_earschat = renderCreateFont("Calibri", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)
					end
					imgui.CenterText(u8'Кол-во строк: ')
					if imgui.SliderInt('##Slider2', checkbox.selected_ears2, 3, 20) then
						cfg.settings.strok_ears = checkbox.selected_ears2.v
						save()
						if #ears > cfg.settings.strok_ears then for i = cfg.settings.strok_ears, #ears do ears[i] = nil end end
					end
					if imgui.Button(u8'Изменить позицию',imgui.ImVec2(140,24)) then
						if checkbox.check_render_ears.v then
							lua_thread.create(function()
								if not ears[1] then ears[1] = 'Тестовое сообщение для видимости новой позиции.' end 
								sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
								sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
								local old_pos_x, old_pos_y = cfg.settings.position_ears_x, cfg.settings.position_ears_y
								while true do
									cfg.settings.position_ears_x, cfg.settings.position_ears_y = getCursorPos()
									if wasKeyPressed(VK_RETURN) then save() break end
									if wasKeyPressed(VK_ESCAPE) then cfg.settings.position_ears_x = old_pos_x cfg.settings.position_ears_y = old_pos_y break end
									wait(1)
								end
							end)
						else sampAddChatMessage(tag .. 'Функция выключена, включите её и сохраните позицию.', -1) end
					end
					imgui.SameLine()
					if imgui.Button(u8'Сбросить чат',imgui.ImVec2(125, 24)) then ears = {} end
					imgui.EndPopup()
				end 
				if imadd.ToggleButton("##virtualkey", checkbox.check_keysync) then
					cfg.settings.keysync = not cfg.settings.keysync
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Виртуал. клавиши')
				imgui.SameLine()
				imgui.SetCursorPosX(190)
				if imgui.Button(fa.ICON_ARROWS..'##1') then
					if windows.recon_menu.v then
						lua_thread.create(function()
							sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
							sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
							local old_pos_x, old_pos_y = cfg.settings.keysyncx, cfg.settings.keysyncy
							while true do
								cfg.settings.keysyncx, cfg.settings.keysyncy = getCursorPos()
								if wasKeyPressed(VK_RETURN) then save() break end
								if wasKeyPressed(VK_ESCAPE) then cfg.settings.keysyncx = old_pos_x cfg.settings.keysyncy = old_pos_y break end
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
				imgui.Text(u8'Кастом рекон меню')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_ARROWS..'##5') then
					if cfg.settings.on_custom_recon_menu then
						if windows.recon_menu.v then
							lua_thread.create(function()
								sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
								sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
								local old_pos_x, old_pos_y = cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y
								while true do
									cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y = getCursorPos()
									if wasKeyPressed(VK_RETURN) then save() break end
									if wasKeyPressed(VK_ESCAPE) then cfg.settings.position_recon_menu_x = old_pos_x cfg.settings.position_recon_menu_y = old_pos_y break end
									wait(1)
								end
							end)
						else sampAddChatMessage(tag .. 'Данная опция доступна только в реконе.', -1) end
					else sampAddChatMessage(tag ..'Функция выключена, включите её и задайте позицию', -1) end
				end
				imgui.SetCursorPosY(400)
				imgui.Separator()
				imgui.Text(u8'Разработчик скрипта - N.E.O.N')
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
			elseif menu == 'Дополнительные функции' then -- мульти выбор
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
				if imgui.Button(u8'Провести серверное мероприятие', imgui.ImVec2(485, 24)) then sampSendChat('/mp') windows.menu_tools.v = false end
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
			elseif menu == 'Быстрые клавиши' then -- быстрые клавиши
				imgui.SetCursorPosX(8)
				imgui.NewInputText('##SearchBar7', buffer.new_binder_key, 485, u8'Текст биндера', 2)
				imgui.PushItemWidth(485)
				imgui.Combo("##Метод отправки", checkbox.new_binder_key, {u8"Отправить серверу", u8"Отправить клиенту", u8"Добавить в поле ввода"}, 3)
				imgui.PopItemWidth()
				if imgui.Button(u8'Добавить', imgui.ImVec2(250,24)) and #(u8:decode(buffer.new_binder_key.v)) ~= 0 then
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.binder_key[getDownKeysText()] = checkbox.new_binder_key.v ..'\\n'.. u8:decode(buffer.new_binder_key.v)
						save()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'Удалить', imgui.ImVec2(228,24)) and #(u8:decode(buffer.new_binder_key.v)) ~= 0 then
					for k,v in pairs(cfg.binder_key) do
						if (u8:decode(buffer.new_binder_key.v) == string.sub(v, 4)) then
							cfg.binder_key[k] = nil
							save()
							sampAddChatMessage(tag .. 'Биндер удален.', -1)
						end
					end 
				end
				imgui.Separator()
				imgui.CenterText(u8'Открытие меню AT:')
				imgui.SameLine()
				imgui.Text(u8(cfg.settings.open_tool))
				if imgui.Button(u8"Сoxpaнить.", imgui.ImVec2(250, 24)) then
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.settings.open_tool = getDownKeysText()
						save()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'Сброcить', imgui.ImVec2(228,24)) then
					cfg.settings.open_tool = 'None'
					save()
				end
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
				if imgui.Button(u8'Сбрocить', imgui.ImVec2(228,24)) then
					cfg.settings.fast_key_ans = 'None'
					save()
				end
				imgui.CenterText(u8"Отправка в чат моего текста:")
				imgui.SameLine()
				imgui.Text(cfg.settings.fast_key_addText)
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
				imgui.CenterText(u8'Клавиша запуска видеофиксации: ')
				imgui.SameLine()
				imgui.Text(cfg.settings.key_start_fraps)
				if imgui.Button(u8'Соxpaнить.', imgui.ImVec2(250, 24)) then
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.settings.key_start_fraps = getDownKeysText()
						save()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'Сбpocить', imgui.ImVec2(228, 24)) then
					cfg.settings.key_start_fraps = 'None'
					save()
					cfg.settings.start_fraps = false
					checkbox.check_start_fraps.v = false
				end
				imgui.Separator()
				imgui.CenterText(u8'[Мои быстрые клавиши]')
				for k, v in pairs(cfg.binder_key) do
					imgui.Text(u8('[Клавиша '..k..'] = '))
					imgui.Tooltip(u8'Нажми, чтобы удалить')
					if imgui.IsItemClicked(0) then
						cfg.binder_key[k] = nil
						save()
					end
					imgui.SameLine()
					imgui.Text(u8(string.sub(v, 4)))
				end
				imgui.SetCursorPosY(475)
				if getDownKeysText() and not getDownKeysText():find('+') then imgui.Text(u8'Зажата клавиша: ' .. getDownKeysText())
				else imgui.Text(u8'Нет зажатой клавиши') end
				imgui.SameLine()
				imgui.SetCursorPosX(253)
				if imgui.Button(u8"Сбросить значения моих клавиш") then
					for k,v in pairs(cfg.binder_key) do cfg.binder_key[k] = nil end
					save()
				end
			elseif menu == 'Блокнот' then
				buffer.bloknotik.v = string.gsub(buffer.bloknotik.v, "\\n", "\n")
				if imgui.InputTextMultiline("##1", buffer.bloknotik, imgui.ImVec2(495, 500)) then
					buffer.bloknotik.v = string.gsub(buffer.bloknotik.v, "\n", "\\n")
					cfg.settings.bloknotik = u8:decode(buffer.bloknotik.v)
					save()	
				end
			elseif menu == 'Флуды' then -- флуды
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
			elseif menu == 'Быстрые ответы' then -- быстрые ответы
				imgui.SetCursorPosX(125)
				if imgui.Button(u8'Добавить мой ответ', imgui.ImVec2(250, 24)) and #(buffer.custom_answer.v) > 1 then
					if #(buffer.custom_answer.v) < 80 then
						cfg.customotvet[#(cfg.customotvet) + 1] = u8:decode(buffer.custom_answer.v)
						save()
						buffer.custom_answer.v = ''
						imgui.SetKeyboardFocusHere(-1)
					else sampAddChatMessage(tag .. 'Слишком много символов, сократите ответ', -1) end
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

			elseif menu == 'Автомут' then -- автомут, быстрые команды, стиль имгуи
				imgui.SetCursorPosX(10)
				imgui.Checkbox('##celoeslovo', checkbox.add_full_words)
				imgui.Tooltip(u8'Вкл = добавление исключительно целого слова, а не ключевых')
				imgui.SameLine()
				imgui.CenterText(u8'Добавить мат (Всего в словаре: ' .. #mat..')')
				imgui.SameLine()
				imgui.Text(fa.ICON_EYE)
				imgui.Tooltip(u8'Нажми, чтобы открыть предпросмотр словаря')
				if imgui.IsItemClicked(0) then -- если кликнул на иконку глаза
					imgui.OpenPopup('check_mat')
				end
				if imgui.BeginPopup('check_mat') then
					for i = 1, #mat do
						imgui.Text(u8(mat[i]))
						if imgui.IsItemClicked(0) then
							buffer.newmat.v = u8(mat[i])
						end
						if i % 8 ~= 0 then imgui.SameLine() end
					end
					imgui.EndPopup()
				end
				imgui.PushItemWidth(430)
				imgui.InputText('##newmat', buffer.newmat)
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX(440)
				if (imgui.Button(fa.ICON_CHECK, imgui.ImVec2(24,24)) and (string.len(u8:decode(buffer.newmat.v))>=2)) or (wasKeyPressed(VK_RETURN) and (string.len(u8:decode(buffer.newmat.v))>=2)) then
					buffer.newmat.v = u8:decode(buffer.newmat.v)
					buffer.newmat.v = buffer.newmat.v:rlower()
					for k, v in pairs(mat) do
						if (mat[k] == buffer.newmat.v) or (mat[k] == buffer.newmat.v..'%s') then
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newmat.v .. ' {F0E68C}уже имеется в списке матов.', -1)
							find_words = true
							break
						end
					end
					if not find_words then
						local AutoMute_mat = io.open('moonloader\\' .. "\\config\\AT\\mat.txt", "a")
						if checkbox.add_full_words.v then 
							AutoMute_mat:write(u8(buffer.newmat.v)..'%s' .. '\n')
							table.insert(mat, buffer.newmat.v..'%s')
						else
							AutoMute_mat:write(u8(buffer.newmat.v) .. '\n')
							table.insert(mat, buffer.newmat.v)
						end
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
						if (mat[k] == buffer.newmat.v) or (mat[k] == buffer.newmat.v..'%s') then
							table.remove(mat, k)
	
							local AutoMute_mat = io.open('moonloader\\' .. "\\config\\AT\\mat.txt", "w") 
							AutoMute_mat:close()
	
							local AutoMute_mat = io.open('moonloader\\' .. "\\config\\AT\\mat.txt", "a")
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
				imgui.SameLine()
				imgui.Text(fa.ICON_EYE)
				imgui.Tooltip(u8'Нажми, чтобы открыть предпросмотр словаря')
				if imgui.IsItemClicked(0) then -- если кликнул на иконку глаза
					imgui.OpenPopup('check_osk')
				end
				if imgui.BeginPopup('check_osk') then
					for i = 1, #osk do
						imgui.Text(u8(osk[i]))
						if imgui.IsItemClicked(0) then
							buffer.newosk.v = u8(osk[i])
						end
						if i % 8 ~= 0 then imgui.SameLine() end
					end
					imgui.EndPopup()
				end
				imgui.PushItemWidth(430)
				imgui.InputText('##newosk', buffer.newosk)
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX(440)
				if (imgui.Button(fa.ICON_CHECK .. '##', imgui.ImVec2(24,24)) and (string.len(u8:decode(buffer.newosk.v))>=2)) or (wasKeyPressed(VK_RETURN) and (string.len(u8:decode(buffer.newosk.v))>=2)) then
					buffer.newosk.v = u8:decode(buffer.newosk.v)
					buffer.newosk.v = buffer.newosk.v:rlower()
					for k, v in pairs(osk) do
						if (osk[k] == buffer.newosk.v) or (osk[k] == buffer.newosk.v..'%s') then
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. buffer.newosk.v .. ' {F0E68C}уже имеется в списке оскорблений.', -1)
							find_words = true
							break
						end
					end
					if not find_words then
						local AutoMute_osk = io.open('moonloader\\' .. "\\config\\AT\\osk.txt", "a")
						if checkbox.add_full_words.v then 
							AutoMute_osk:write(u8(buffer.newosk.v) .. '%s' .. '\n')
							table.insert(osk, buffer.newosk.v..'%s')
						else 
							AutoMute_osk:write(u8(buffer.newosk.v) .. '\n')
							table.insert(osk, buffer.newosk.v) 
						end
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
					buffer.newosk.v = buffer.newosk.v:rlower()
					for k, v in pairs(osk) do
						if (osk[k] == buffer.newosk.v) or (osk[k] == buffer.newosk.v..'%s') then
							local AutoMute_osk = io.open('moonloader\\' .. "\\config\\AT\\osk.txt", "w") 
							AutoMute_osk:close()
	
							table.remove(osk, k)
							local AutoMute_osk = io.open('moonloader\\' .. "\\config\\AT\\osk.txt", "a")
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
				if imgui.Combo("##selected", checkbox.style_selected, {u8"Классическая тема", u8"Красная тема", u8"Синяя тема", u8"Фиолетовая тема", u8"Розовая тема", u8"Голубая тема"}, checkbox.style_selected) then
					cfg.settings.style = checkbox.style_selected.v 
					save()
					style(cfg.settings.style)
				end
				imgui.PopItemWidth()
				imgui.CenterText(u8'Добавить быструю команду')
				imgui.SameLine()
				imgui.Text('(?)')
				imgui.Tooltip(u8'Символ "_" без кавычек принимает введенный аргумент\nКоманда wait добавляет задержку, пример: wait(5) (это 5 сек)\nПример команды для выдачи своего бана:\nНазвание команды: /cht\nОписание команды:\n/ans _ Здравствуйте, вы наказаны за нарушение правил сервера.\n/iban _ 7 cheat')
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
							save()
							buffer.new_command_title.v = ''
							sampAddChatMessage(tag .. 'Команда была успешно удалена. Перестанет действовать после перезагрузки игры.', -1)
						else sampAddChatMessage(tag .. 'Такой команды в базе данных нет.', -1) end
					end
				end
			end
		imgui.EndGroup()
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
 		imgui.SameLine()
		imgui.Text(fa.ICON_FILES_O)
		if imgui.IsItemClicked(0) then 
			setClipboardText(autor)
			sampAddChatMessage(tag .. 'Ник скопирован в буфер обмена.', -1)
		end
		imgui.TextWrapped(u8('Жалоба: ' .. textreport))
		if wasKeyPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end 
		imgui.NewInputText('##SearchBar', buffer.text_ans, 375, u8'Введите ваш ответ.', 2)
		imgui.SameLine()
		imgui.SetCursorPosX(392)
		imgui.Tooltip('Space')
		if imgui.Button(u8'Отправить ' .. fa.ICON_SHARE, imgui.ImVec2(120, 25)) or (not cfg.settings.enter_report and wasKeyPressed(VK_RETURN) and not sampIsChatInputActive()) then
			if #(u8:decode(buffer.text_ans.v)) ~= 0 then answer.moiotvet = true
			else sampAddChatMessage(tag .. 'Ответ не менее 1 символа.', -1) end
		end
		imgui.Tooltip('Enter')
		imgui.Separator()
		if #(buffer.text_ans.v) > 5 then
			if imgui.Checkbox(u8"При нажатии на Enter отправить сохраненный ответ", checkbox.button_enter_in_report) then
				cfg.settings.enter_report = not cfg.settings.enter_report
				save()
			end
			for k,v in pairs(cfg.customotvet) do
				if string.rlower(v):find(string.rlower(u8:decode(buffer.text_ans.v))) or string.rlower(v):find(translateText(string.rlower(u8:decode(buffer.text_ans.v)))) then
					if imgui.Button(u8(v), imgui.ImVec2((sw * 0.5) - 295, 24)) or (wasKeyPressed(VK_RETURN) and not sampIsChatInputActive()) then
						if not answer.customans then 
							answer.customans = v
						end
					end
				end
			end
		else
			if imgui.Button(u8'Работаю', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_Q) and not sampIsChatInputActive()) then
				answer.rabotay = true
			end
			imgui.Tooltip('Q')
			imgui.SameLine()
			if imgui.Button(u8'Слежу', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_E) and not sampIsChatInputActive()) then
				answer.slejy = true
			end
			imgui.Tooltip('E')
			imgui.SameLine()
			if imgui.Button('Skin/Color', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_R) and not sampIsChatInputActive()) then
				start_my_answer()
			end
			imgui.Tooltip('R')
			imgui.SameLine()
			if imgui.Button(u8'Передать', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_V) and not sampIsChatInputActive()) then
				imgui.OpenPopup('peredat')
			end
			imgui.Tooltip('V')
			if imgui.Button(u8'Наказать', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_G) and not sampIsChatInputActive()) then
				imgui.OpenPopup('option')
			end
			if imgui.BeginPopup('option') then
				if imgui.Button(u8'Оффтоп (1)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_1) then
					nakazatreport.oftop = true
					answer.nakajy = true
				end
				if imgui.Button(u8'Капс (2)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_2) then
					nakazatreport.capsrep = true
					answer.nakajy = true
				end
				if imgui.Button(u8'Оскорбление администрации (3)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_3) then
					nakazatreport.oskadm = true
					answer.nakajy = true
				end
				if imgui.Button(u8'Клевета на администрацию (4)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_4) then
					nakazatreport.kl = true
					answer.nakajy = true
				end
				if imgui.Button(u8'Оск/Упом родных (5)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_5) then
					nakazatreport.oskrod = true
					answer.nakajy = true
				end
				if imgui.Button(u8'Попрошайничество (6)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_6) then
					nakazatreport.poprep = true
					answer.nakajy = true
				end
				if imgui.Button(u8'Оскорбление/Унижение (7)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_7) then
					nakazatreport.oskrep = true
					answer.nakajy = true
				end
				if imgui.Button(u8'Нецензурная лексика (8)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_8) then
					nakazatreport.matrep = true
					answer.nakajy = true
				end
				if imgui.Button(u8'Розжиг (9)', imgui.ImVec2(250,25)) or wasKeyPressed(VK_9) then
					nakazatreport.rozjig = true
				end
				imgui.EndPopup()
			end
			imgui.Tooltip('G')
			imgui.SameLine()
			if imgui.Button(u8'Уточните ID', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_B) and not sampIsChatInputActive()) then
				answer.uto4id = true
			end
			imgui.Tooltip('B')
			imgui.SameLine()
			if imgui.Button(u8'Форум', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_F) and not sampIsChatInputActive()) then
				answer.uto4 = true
			end
			imgui.Tooltip('F')
			imgui.SameLine()
			if imgui.Button(u8'Отклонить', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_Y) and not sampIsChatInputActive()) then
				answer.otklon = true
			end
			imgui.Tooltip('Y')
			if imgui.BeginPopup('peredat') then
				if imgui.Button(u8'Оставить репорт другому администратору (1)', imgui.ImVec2(350, 25)) or isKeyDown(VK_1) then
					sampCloseCurrentDialogWithButton(0)
					windows.fast_report.v = false
				end
				if imgui.Button(u8'Передать репорт (2)', imgui.ImVec2(350, 25)) or isKeyDown(VK_2) then
					answer.peredamrep = true
				end
				imgui.EndPopup()
			end
		end
		imgui.Separator()
		if imadd.ToggleButton('##doptextans', checkbox.check_add_answer_report) then
			cfg.settings.add_answer_report = not cfg.settings.add_answer_report
			save()
		end
		imgui.SameLine()
		imgui.Text(u8'Добавить дополнительный текст к ответу ' .. fa.ICON_COMMENTING_O)
		if imadd.ToggleButton('##saveans', checkbox.check_save_answer) then
			cfg.settings.custom_answer_save = not cfg.settings.custom_answer_save
			save()
		end
		imgui.Tooltip(u8'Добавляет ваш текст к ответу. Не сработает, если кол-во символов в ответе превысит максимум')
		imgui.SameLine()
		imgui.Text(u8'Сохранить данный ответ в базу данных скрипта ' .. fa.ICON_DATABASE)
		if imadd.ToggleButton('##newcolor', checkbox.check_color_report) then
			if not cfg.settings.on_color_report then
				sampAddChatMessage(tag .. 'Если вы желаете изменить цвет - введите HTML цвет в данную команду', -1)
				sampSetChatInputText('/color_report ')
				sampSetChatInputEnabled(true)
			end
			cfg.settings.on_color_report = not cfg.settings.on_color_report
			save()
		end
		imgui.Tooltip(u8'Добавляет окраску к ответу. Не сработает, если кол-во символов в ответе превысит максимум\nПотому рекомендуется использовать без доп.текста')
		imgui.SameLine()
		imgui.Text(u8'Перекрасить мой ответ в другой цвет ' .. fa.ICON_TACHOMETER)
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
			if not string.sub(v, -3):find('x(%d+)')  then
				local name = string.gsub(v, '/jail _ (%d+) ', '')
				if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
					sampSendChat(string.gsub(v, '_', control_player_recon))
					windows.recon_jail_menu.v = false
				end
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
			if not string.sub(v, -3):find('x(%d+)')  then
				if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
					sampSendChat(string.gsub(v, '_', control_player_recon))
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
		imgui.BeginGroup()
			if imgui.Button(u8'Игрок ' ..fa.ICON_MALE, imgui.ImVec2(120, 25)) then menu_in_recon = 'Главное меню' end imgui.SameLine()
			if imgui.Button(u8'В радиусе ' .. fa.ICON_USERS, imgui.ImVec2(120, 25)) then menu_in_recon = 'Дополнительные функции' end
		imgui.EndGroup()
		imgui.BeginGroup()
			if menu_in_recon == 'Главное меню' then
				imgui.SetCursorPosX(10)
				if imgui.Button(fa.ICON_FILES_O) then
					setClipboardText(sampGetPlayerNickname(control_player_recon))
					sampAddChatMessage(tag .. 'Ник скопирован в буфер обмена. (ctrl + v)', -1)
				end
				imgui.SameLine()
				if sampIsPlayerConnected(control_player_recon) then
					imgui.Text(sampGetPlayerNickname(control_player_recon) .. '[' .. control_player_recon .. ']')
				end
				if start_fraps then
					imgui.SameLine()
					imgui.SetCursorPosX(240)
					imgui.Text(fa.ICON_VIDEO_CAMERA)
				end
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
				if imgui.Button(u8'Посмотреть первую статистику', imgui.ImVec2(250, 25)) or (wasKeyPressed(VK_Z) and not (sampIsChatInputActive() or sampIsDialogActive())) then
					sampSendChat('/statpl ' .. sampGetPlayerNickname(control_player_recon))
				end
				imgui.Tooltip('Z')
				if imgui.Button(u8'Посмотреть вторую статистику', imgui.ImVec2(250, 25)) or (wasKeyPressed(VK_X) and not (sampIsChatInputActive() or sampIsDialogActive())) then
					sampSendClickTextdraw(textdraw.stats)
				end
				imgui.Tooltip('X')
				if imgui.Button(u8'Посмотреть /offstats статистику', imgui.ImVec2(250, 25)) or (wasKeyPressed(VK_C) and not (sampIsChatInputActive() or sampIsDialogActive())) then
					sampSendChat('/offstats ' .. sampGetPlayerNickname(control_player_recon))
					sampSendDialogResponse(16196, 1, 0)
				end
				imgui.Tooltip('C')
				if imgui.Button(u8'Посмотреть устройство игрока', imgui.ImVec2(250, 25)) or (wasKeyPressed(VK_V) and not (sampIsChatInputActive() or sampIsDialogActive())) then
					sampSendChat('/tonline')
				end
				imgui.Tooltip('V')
			elseif menu_in_recon == 'Дополнительные функции' then
				for _,v in pairs(playersToStreamZone()) do
					if v ~= control_player_recon then
						imgui.SetCursorPosX(10)
						if imgui.Button(sampGetPlayerNickname(v) .. '[' .. v .. ']', imgui.ImVec2(250, 25)) then sampSendChat('/re ' .. v) end
					end
				end
			end
		imgui.EndGroup()
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
		if imgui.Button(u8'Выйти') or (wasKeyPressed(VK_Q) and not (sampIsChatInputActive() or sampIsDialogActive())) then
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
		if (imgui.Button(u8'Обновить') or (wasKeyPressed(VK_R)) and not (sampIsChatInputActive() or sampIsDialogActive())) then
			sampSendChat('/re '..control_player_recon)
			printStyledString('~n~~w~update...', 200, 4)
			if cfg.settings.keysync then
				lua_thread.create(function()
					wait(1000)
					keysync(control_player_recon)
				end)
			end
		end
		imgui.Tooltip('R')
		if wasKeyPressed(VK_RBUTTON) and not (sampIsChatInputActive() or sampIsDialogActive()) then
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
		if wasKeyPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end
		if not windows.fast_report.v then windows.custom_ans.v = false end
		imgui.PushFont(fontsize)
		if imgui.RadioButton(u8"ID скинов", checkbox.custom_ans, 0) then
			if not skin then
				skin = {}
				for i = 0, 311 do
					skin[#skin+1] = imgui.CreateTextureFromFile('moonloader\\'..'\\resource\\skin\\skin_'..i..'.png')
				end
			end
		end
		imgui.SameLine()
		if imgui.RadioButton(u8"ID цветов", checkbox.custom_ans, 1) then
			if not html_color then
				html_color = {}
				local file_color = io.open('moonloader\\' .. "\\resource\\skin\\color.txt","r")
				if file_color then for line in file_color:lines() do html_color[#html_color + 1] = u8:decode(line);end file_color:close() end
			end
		end 
		imgui.SameLine()
		if imgui.RadioButton(u8"Названия авто", checkbox.custom_ans, 2) then
			if not auto then
				auto = {}
				for i = 400, 611 do
					auto[#auto+1] = imgui.CreateTextureFromFile('moonloader\\'..'\\resource\\auto\\vehicle_'..i..'.png')
				end
			end
		end
		imgui.Separator()
		if checkbox.custom_ans.v == 0 then
			imgui.CenterText(u8'Выбранный скин будет дополнен к вашему ответу.')
			for i = 1, 312 do
				imgui.Image(skin[i], imgui.ImVec2(75, 150))
				if imgui.IsItemClicked(0) then buffer.text_ans.v = buffer.text_ans.v .. ('ID: '..i-1) ..' ' end
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
					if imgui.IsItemClicked(0) then buffer.text_ans.v =  buffer.text_ans.v .. name_car[i]..' ' end
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
		if (wasKeyPressed(VK_RBUTTON) or wasKeyPressed(VK_F)) and not sampIsChatInputActive() then
			if isCursorActive() then
				showCursor(false,false)
			else
				showCursor(true,false)
			end
		end
		imgui.CenterText(u8'Нажми нужную клавишу, либо курсором')
		imgui.CenterText(u8'Активация курсора: ПКМ или F')
		imgui.CenterText(u8'Меню активно 5 секунд.')
		if wasKeyPressed(VK_ESCAPE) then windows.answer_player_report.v = false end
		imgui.End()
	end
	if windows.render_admins.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.render_admins_positionX, cfg.settings.render_admins_positionY))
		imgui.Begin('##render_admins', windows.render_admins, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
		for i = 1, #admins - 1 do imgui.TextColoredRGB(admins[i]) end
        imgui.End()
	end
	if windows.new_flood_mess.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(265,340), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Новый флуд', windows.new_flood_mess, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Button(u8'Скрипт сам допишет /mess\nВам лишь надо указать цвет.', imgui.ImVec2(250,32)) then sampAddChatMessage(tag .. 'Открыт диалог с цветами',-1) sampSendChat('/mcolors') end
		imgui.Text(u8'Название: ')
		imgui.PushItemWidth(250)
		imgui.InputText('##title_flood_mess', buffer.title_flood_mess)
		imgui.PopItemWidth()
		imgui.Text(u8'Текст: ')
		imgui.InputTextMultiline("##5", buffer.new_flood_mess, imgui.ImVec2(250, 100))
		if imgui.Button(u8'Сохранить', imgui.ImVec2(250, 24)) then
			if #(u8:decode(buffer.new_flood_mess.v)) > 3 and #(u8:decode(buffer.title_flood_mess.v)) ~= 0 then
				if buffer.new_flood_mess.v ~= 0 then
					if tonumber(string.sub(buffer.new_flood_mess.v, 1, 1)) then
						cfg.myflood[u8:decode(buffer.title_flood_mess.v)] = string.gsub(u8:decode(buffer.new_flood_mess.v), '\n', '\\n')
						save()
						buffer.title_flood_mess.v = ''
						buffer.new_flood_mess.v = ''
					else sampAddChatMessage(tag .. 'Цвет не указан', -1) end
				else sampAddChatMessage(tag .. 'Вы не указали номер цвета', -1) end
			else sampAddChatMessage(tag .. 'Что вы собрались сохранять?', -1) end
		end
		for k,v in pairs(cfg.myflood) do
			if imgui.Button(u8(k), imgui.ImVec2(225, 24)) then
				local v = textSplit(v, '\\n')
				for _,v in pairs(v) do
					sampSendChat('/mess ' .. v)
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(235)
			imgui.PushFont(fontsize)
			if imgui.Button(fa.ICON_COG ..'##'..k, imgui.ImVec2(24,24)) then
				imgui.OpenPopup("settings")
			end
			if imgui.BeginPopup('settings') then
				if imgui.Button(fa.ICON_PENCIL) then
					buffer.title_flood_mess.v = u8(k)
					buffer.new_flood_mess.v = (string.gsub(u8(v), '\\n', '\n'))
				end
				if imgui.Button(fa.ICON_BAN) then
					cfg.myflood[k] = nil
					save()
				end
				imgui.EndPopup()
			end
			imgui.PopFont()
		end
		imgui.End()
	end
	if windows.pravila.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5,0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw*0.5,sh*0.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Помощь', windows.pravila, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.RadioButton(u8"Правила", checkbox.checked_radio_button, 1)
		imgui.SameLine()
		imgui.RadioButton(u8"Быстрые команды", checkbox.checked_radio_button, 2)
		imgui.SameLine()
		imgui.RadioButton(u8"Серверные команды", checkbox.checked_radio_button, 3)
		if wasKeyPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end
		if checkbox.checked_radio_button.v == 1 then
			imgui.NewInputText('##SearchBar6', buffer.find_rules, sw*0.5, u8'Поиск по правилам', 2)
			for i = 1, #pravila do
				if string.rlower(u8:decode(pravila[i])):find(string.rlower(u8:decode(buffer.find_rules.v))) then
					if not (pravila[i]:find('%[%d+ lvl%]')) then
						imgui.TextWrapped(pravila[i])
					end
				end
			end
		elseif checkbox.checked_radio_button.v == 2 then
			local command = 
			{
				prochee = 'Команды для работы со скриптом',
				help = 'Вспомогательные команды',
				ans = 'Ответы игрокам',
				mute = 'Выдача блокировки чата',
				rmute = 'Выдача блокировки репорта',
				jail = 'Выдача деморгана',
				ban = 'Блокировка аккаунта',
				kick = 'Кикнуть игрока',
			}
			if imgui.CollapsingHeader( u8('Мои команды') ) then
				for k,v in pairs(cfg.my_command) do
					imgui.CenterText( u8('/'..k) )
					imgui.TextWrapped( u8(v) )
				end
			end
			for name, _ in pairs(basic_command) do
				if imgui.CollapsingHeader( u8(command[name]) ) then
					for k,v in pairs(basic_command[name]) do
						if not string.sub(v, -3):find('x(%d+)') then 
							imgui.TextWrapped(u8('/'..k ..' = '.. string.gsub(v, '\n', '\n		') ))
						end
					end
				end
			end
		elseif checkbox.checked_radio_button.v == 3 then
			for i = 1, 18 do
				if imgui.CollapsingHeader(u8('Уровень доступа - ' .. i)) then
					for b = 1, #pravila do
						if pravila[b]:find('%['..i..' lvl%]') then
							imgui.Text(string.gsub(pravila[b], '%[%d+ lvl%]', ''))
						end
					end
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
		imgui.Text(u8'Примечание: Нажатие по тексту - копирует его в буфер обмена.\nСкриншот данного окна можно использовать ввиде доказазательств.\nВ целях уменьшения нагрузки на ваш компьютер, данное окно обновляется каждый перезаход в игру.')
		imgui.PushItemWidth(sw*0.7 - 30)
		if imgui.Combo('##chatlog', checkbox.option_find_log, files_chatlogs, checkbox.option_find_log) then chat = {1, 500, 1} end
		imgui.NewInputText('##searchlog', buffer.find_log, (sw*0.7)-30, u8'Сортировка текста', 2)
		imgui.PopItemWidth()
		if checkbox.option_find_log.v == 0 then 	--= ОСТОРОЖНО, ПРИ ИЗМЕНЕНИЯХ, ЗАВИСИМОСТЬ ОТ ЦИФР'
			if #chatlog_1 > 500 then
				if chat[3] > 1 then
					if chat[3] ~= 1 then
						if imgui.Button('<<--') then
							chat[1] = 1
							chat[2] = 500
							chat[3] = 1
						end
					end
					imgui.SameLine()
					if imgui.Button(u8'<- Предыдущая страница'..' ('..(chat[3] - 1)..')') then
						if chat[1] ~= 1 then
							if chat[1] == 500 then 
								chat[1] = 1 
								chat[2] = chat[2] - 500
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
				if chat[2] ~= #chatlog_1 then
					imgui.SameLine()
					if imgui.Button('-->>') then
						chat[2] = #chatlog_1
						if chat[2] > 499 then
							chat[1] = chat[2] - 500
						end
						chat[3] = (chat[2] / 500)
						chat[3] = chat[3] - chat[3] % 1
					end
				end
			else chat[2] = #chatlog_1 end
			for i = chat[1], chat[2] do
				if string.rlower(chatlog_1[i]):find(string.rlower(u8:decode(buffer.find_log.v))) then
					imgui.Text(u8(chatlog_1[i]))
					if imgui.IsItemClicked(0) then setClipboardText(chatlog_1[i]) sampAddChatMessage(tag..'Строка скопирована в буфера обмена',-1) end
				end
			end
		end
		if checkbox.option_find_log.v == 1 then
			if #chatlog_2 > 500 then
				if chat[3] > 1 then
					if chat[3] ~= 1 then
						if imgui.Button('<<--') then
							chat[1] = 1
							chat[2] = 500
							chat[3] = 1
						end
					end
					imgui.SameLine()
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
				if chat[2] ~= #chatlog_2 then
					imgui.SameLine()
					if imgui.Button('-->>') then
						chat[2] = #chatlog_2
						if chat[2] > 499 then
							chat[1] = chat[2] - 500
						end
						chat[3] = (chat[2] / 500)
						chat[3] = chat[3] - chat[3] % 1
					end
				end
			else chat[2] = #chatlog_2 end
			for i = chat[1], chat[2] do
				if string.rlower(chatlog_2[i]):find(string.rlower(u8:decode(buffer.find_log.v))) then
					imgui.Text(u8(chatlog_2[i]))
					if imgui.IsItemClicked(0) then setClipboardText(chatlog_2[i]) sampAddChatMessage(tag..'Строка скопирована в буфера обмена',-1) end
				end
			end
		end
		if checkbox.option_find_log.v == 2 then
			if #chatlog_3 > 500 then
				if chat[3] > 1 then
					if chat[3] ~= 1 then
						if imgui.Button('<<--') then
							chat[1] = 1
							chat[2] = 500
							chat[3] = 1
						end
					end
					imgui.SameLine()
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
				if chat[2] ~= #chatlog_3 then
					imgui.SameLine()
					if imgui.Button('-->>') then
						chat[2] = #chatlog_3
						if chat[2] > 499 then
							chat[1] = chat[2] - 500
						end
						chat[3] = (chat[2] / 500)
						chat[3] = chat[3] - chat[3] % 1
					end
				end
			else chat[2] = #chatlog_3 end
			for i = chat[1], chat[2] do
				if string.rlower(chatlog_3[i]):find(string.rlower(u8:decode(buffer.find_log.v))) then
					imgui.Text(u8(chatlog_3[i]))
					if imgui.IsItemClicked(0) then setClipboardText(chatlog_3[i]) sampAddChatMessage(tag..'Строка скопирована в буфера обмена',-1) end
				end
			end
		end
		imgui.PopFont()
		imgui.End()
	end
end
function sampev.onSendCommand(command) -- Регистрация отправленных пакет-сообщений
	if command:match('mute (.+) (.+) (.+)') and string.sub(command, 1, 1) =='/' and string.sub(command, 1, 2) ~='/a' then
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
			local _, id, second, reason = string.match(command,'(.+) (.+) (%d+) (.+)') -- Узнаем ник наказуемого
			if tonumber(id) and sampIsPlayerConnected(id) and not reason:find('x(%d)') then -- если игрок в сети
				local nick = string.gsub(sampGetPlayerNickname(id), '%p','') -- присваиваем переменной значение ника и удаляем символы пунктуации
				for a,b in pairs(cfg.mute_players) do
					if string.sub(a, 1, #nick) == nick and reason == string.sub(a, #nick+1) then -- Если ник найден в массиве уже наказанных, и причина совпадает
						second = second * b
						if second > 5000 then second = 5000 end
						sampAddChatMessage(tag .. 'Данный игрок уже был наказан ранее, потому я увеличиваю наказание.', -1)
						if string.sub(command, 1, 6) == '/rmute' then
							local accept = false
							for k,v in pairs(basic_command.rmute) do
								if v == reason then
									SendChat('/rmute ' .. id .. ' ' .. second .. ' ' .. reason .. ' x' .. b)
									accept = true
									break
								end
							end
							if accept then accept = nil
							else return end
						else SendChat('/mute ' .. id ..' '..  second .. ' ' .. reason ..' x' .. b) end
						return false
					end
				end
			end
		end
	elseif command:match('ban (%d+) (%d+) .+') and string.sub(command, 1, 1) =='/' and string.sub(command, 1, 2) ~= '/a' and cfg.settings.forma_na_ban then
		if sampIsPlayerConnected(command:match('(%d+)')) then
			printStyledString('send forms ...', 1000, 4)
			if cfg.settings.add_mynick_in_form then
				local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
			else SendChat('/a ' .. command) end
			return false
		end
	elseif command:match('/jail (%d+) (%d+) .+') and string.sub(command, 1, 1) =='/' and string.sub(command, 1, 2) ~= '/a' and cfg.settings.forma_na_jail then
		if sampIsPlayerConnected(command:match('(%d+)')) then
			printStyledString('send forms ...', 1000, 4)
			if cfg.settings.add_mynick_in_form then
				local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
			else SendChat('/a ' .. command) end
			return false
		end
	elseif command:match('/kick (%d+) .+') and string.sub(command, 1, 1) =='/' and string.sub(command, 1, 2) ~= '/a' then
		if cfg.settings.forma_na_kick then
			if sampIsPlayerConnected(command:match('(%d+)')) then
				printStyledString('send forms ...', 1000, 4)
				if cfg.settings.add_mynick_in_form then
					local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
				else SendChat('/a ' .. command) end
				return false
			end
		end
	end
	return
end
function sampev.onServerMessage(color,text) -- Поиск сообщений из чата
	if #text > 4 then
		if not AFK then log(text) end
		if text:match("%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]:") then
			if cfg.settings.find_form and not AFK then
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
								if find_admin_form:find('off (.+)') or find_admin_form:find('akk (.+)') then
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
			if cfg.settings.admin_chat then
				local admlvl, prefix, nickadm, idadm, admtext  = text:match('%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.*)')
				local messange = (string.sub(prefix, 2) .. ' ' .. admlvl .. ' ' ..  nickadm .. '(' .. idadm .. '): '.. admtext)
				if #adminchat == cfg.settings.strok_admin_chat then
					for i = 0, #adminchat do
						if i ~= #adminchat then adminchat[i] = adminchat[i+1]
						else adminchat[#adminchat] = messange end
					end
				else adminchat[#adminchat + 1] = messange end
				return false
			end
		elseif (text:match(".+%((%d+)%): (.+)") or text:match(".+%[(%d+)%]: (.+)")) and not (text:match("%[a%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]:") or text:match('написал %[(%d+)%]:') or text:match('ответил .+%[(%d+)%]: ') or AFK) and cfg.settings.automute then 
			local command = '/mute '
			if text:match('Жалоба') then
				command = '/rmute '
			end
			local text = text:rlower() .. ' '
			if text:match('%((%d+)%)') then oskid = text:match('%((%d+)%)') text = string.gsub(text, ".+%((%d+)%):",'')
			else oskid = text:match('%[(%d+)%]') text = string.gsub(text, ".+%[(%d+)%]:", '') end
			local text = string.gsub(text, '{%w%w%w%w%w%w}', '')
			if cfg.settings.smart_automute then
				for i = 1, #spisokoskrod do
					if text:match(' '.. spisokoskrod[i]) then
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} '..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampSendChat(command .. oskid .. ' 5000 Оскорбление/Упоминание родных')
						notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Упоминание родных.')
						return false
					end
				end
				for i = 1, #spisokrz do
					if text:match(' '..spisokrz[i]) then
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampSendChat(command .. oskid .. ' 5000 Розжиг межнац.розни')
						notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Розжиг межнац.розни')
						return false
					end
				end
				for i = 1, #spisokproject do
					if text:match(' ' .. spisokproject[i]) then
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} '..sampGetPlayerNickname(oskid) .. '['..oskid..']: ' .. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage(tag .. 'Рекомендуется произвести очистку чата /cc', -1)
						sampSendChat(command ..oskid.. ' 1000 Упоминание стор.проектов')
						notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. spisokproject[i])
						return false
					end
				end
			end
			for i = 1, #osk do	-- МАССИВ НАЧИНАЕТСЯ С 1
				if not text:match(' я ') and text:match('%s'.. osk[i]) then
					for a = 1, #spisokor do
						if text:match(spisokor[a]) then
							sampAddChatMessage('==========================================================================', 0x00FF00)
							sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
							sampAddChatMessage('==========================================================================', 0x00FF00)
							sampSendChat(command .. oskid .. ' 5000 Оскорбление/Упоминание родни')
							notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевые слово: ' .. osk[i] .. ' - ' .. spisokor[a])
							return false
						end
					end
					sampAddChatMessage('==========================================================================', 0x00FF00)
					sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
					sampAddChatMessage('==========================================================================', 0x00FF00)
					sampSendChat(command .. oskid .. ' 400 Оскорбление/Унижение')
					notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. osk[i])
					return false
				end
			end
			for i = 1, #mat do -- МАССИВ НАЧИНАЕТСЯ С 1
				if text:match(' '.. mat[i]) then
					for a = 1, #spisokor do
						if text:match(spisokor[a]) then
							sampAddChatMessage('==========================================================================', 0x00FF00)
							sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
							sampAddChatMessage('==========================================================================', 0x00FF00)
							sampSendChat(command .. oskid .. ' 5000 Оскорбление/Упоминание родни')
							notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевые слово: ' .. mat[i] .. ' - ' .. spisokor[a])
							return false
						end
					end
					sampAddChatMessage('==========================================================================', 0x00FF00)
					sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
					sampAddChatMessage('==========================================================================', 0x00FF00)
					sampSendChat(command .. oskid .. ' 300 Нецензурная лексика')
					notify('{66CDAA}[AT-AutoMute]', '' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. mat[i])				
					return false
				end
			end
			if flood.message[oskid] then
				if ( (os.clock() - flood.time[oskid]) > 40 ) or ( flood.message[oskid] ~= text ) then 
					flood.message[oskid] = text
					flood.time[oskid] = os.clock()
					flood.count[oskid] = 1
				else
					if flood.count[oskid] == 3 and cfg.settings.smart_automute then -- если 4 сообщения то мут
						flood.message[oskid] = nil
						lua_thread.create(function()
							while sampIsDialogActive() do wait(1000) end
							sampAddChatMessage(tag .. 'Обнаружен флуд в чате! Нарушитель ' .. sampGetPlayerNickname(oskid)..'['..oskid..']', -1)
							sampAddChatMessage(tag .. 'Отправил 4 сообщения за ' .. math.ceil(os.clock() - flood.time[oskid]) .. '/40 сек.', 0xA9A9A9)
							sampAddChatMessage('{00FF00}=== {A9A9A9}' .. sampGetPlayerNickname(oskid)..'['..oskid..']: '..text .. ' {00FF00}===', -1)
							sampSendChat('/mute ' .. oskid .. ' 120 Флуд/Cпам')
						end)
					else flood.count[oskid] = flood.count[oskid] + 1 end
				end
			else
				flood.message[oskid] = text
				flood.time[oskid] = os.clock()
				flood.count[oskid] = 1
			end
		elseif text:match('Время администратирования за сегодня:') or text:match('Ваша репутация:') or text:match('Всего администрации в сети:') then
			if cfg.settings.render_admins then return false end
		elseif text:match("(.+)%((%d+)%) пытался написать в чат: ") then
			sampAddChatMessage('',-1)
			sampAddChatMessage(text, 0xff6347) -- чтобы не пропускали такие сообщения
			sampAddChatMessage('',-1)
			return false
		elseif text:match("Администратор (.+) заткнул%(.+%) игрока (.+) на (.+) секунд. Причина:") then
			local _, myid = sampGetPlayerIdByCharHandle(playerPed) -- узнаем мой ник
			if text:match(sampGetPlayerNickname(myid)) then -- Узнаем я ли выдал это наказание
				local nick = string.match(text, 'игрока (.+) на') -- Ищем игрока
				local reason = string.sub(string.match(text, 'Причина: .+'), 10) --- ищем причину
				---========= Если в причине есть множитель - удаляем ============-----------------
				local reason = string.gsub(string.gsub(reason, ' x(%d)', ''), ' х(%d)', '')
				--========== Если такой ник найден в скрипте, то добавляем множитель + 1 =======--- 
				if cfg.mute_players[string.gsub(nick..reason, '%p','')] then 
					local b = tonumber(string.sub(cfg.mute_players[string.gsub(nick..reason, '%p','')],1,-1))
					if b ~= 0 then
						cfg.mute_players[string.gsub(nick..reason, '%p','')] = b + 1
					end
				--========== Если такой ник не найден в скрипте, то приписываем множитель 2 =======--- 
				else cfg.mute_players[string.gsub(nick..reason, '%p','')] = 2 end
				save()
			end
		elseif text:match("Администратор (.+) закрыл%(.+%) доступ к репорту игроку (.+) на (.+) секунд. Причина:") then
			local _, myid = sampGetPlayerIdByCharHandle(playerPed) -- узнаем мой ник
			if text:match(sampGetPlayerNickname(myid)) then -- Узнаем я ли выдал это наказание
				local nick = string.match(text, 'игроку (.+) на') -- Ищем игрока
				local reason = string.sub(string.match(text, 'Причина: .+'), 10) --- ищем причину
				---========= Если в причине есть множитель - удаляем ============-----------------
				local reason = string.gsub(string.gsub(reason, ' x(%d)', ''), ' х(%d)', '')
				--========== Если такой ник найден в скрипте, то добавляем множитель + 1 =======--- 
				if cfg.mute_players[string.gsub(nick..reason, '%p','')] then
					local b = tonumber(string.sub(cfg.mute_players[string.gsub(nick..reason, '%p','')],1,-1))
					if b ~= 0 then
						cfg.mute_players[string.gsub(nick..reason, '%p','')] = b + 1
					end
				--========== Если такой ник не найден в скрипте, то приписываем множитель 2 =======--- 
				else cfg.mute_players[string.gsub(nick..reason, '%p','')] = 2 end
				save()
			end
		elseif text:match('%[A%] NEARBY CHAT: .+') or text:match('%[A%] SMS: .+') then
			checkbox.check_render_ears.v = true
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
			if cfg.settings.smart_automute then
				local oskid = text:match('%[(%d+)%]')
				for i = 1, #spisokoskrod do
					if text:match(' '.. spisokoskrod[i]) then
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} '..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampSendChat('/mute ' .. oskid .. ' 5000 Оскорбление/Упоминание родных')
						notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Упоминание родных.')
						return 
					end
				end
				for i = 1, #spisokrz do
					if text:match(' '..spisokrz[i]) then
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampSendChat('/mute ' .. oskid .. ' 5000 Розжиг межнац.розни')
						notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Розжиг межнац.розни')
						return 
					end
				end
				for i = 1, #spisokproject do
					if text:match(' ' .. spisokproject[i]) then
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[АT]{DCDCDC} '..sampGetPlayerNickname(oskid) .. '['..oskid..']: ' .. text .. ' {00FF00}[АТ]', -1)
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampSendChat('/mute ' ..oskid.. ' 1000 Упоминание стор.проектов')
						notify('{66CDAA}[AT-AutoMute]', 'Выявлен нарушитель:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. 'Ключевое слово: ' .. spisokproject[i])
						return
					end
				end
			end
			return false
		elseif text:match('%<AC%-WARNING%> {ffffff}(.+)%[(%d+)%]{82b76b} подозревается в использовании чит%-программ%: {ffffff}Weapon hack %[code%: 015%]%.') and cfg.settings.weapon_hack and not AFK then
			if not check_weapon then
				lua_thread.create(function()
					check_weapon = true
					while sampIsDialogActive() do wait(1000) end
					sampSendChat('/iwep '.. string.match(text, "%[(%d+)%]"))
					check_weapon = false
				end)
			end
			return false
		end
	end
end
function sampev.onShowTextDraw(id, data) -- Считываем серверные текстдравы
	if cfg.settings.on_custom_recon_menu then
		for k,v in pairs(data) do
			local v = tostring(v)
			if v == 'REFRESH' then textdraw.refresh = id  -- записываем ид кнопки обновить в реконе
			elseif v:match('~n~') then
				if not v:match('~g~') then 
					textdraw.inforeport = id  -- инфо панель в реконе
					lua_thread.create(function()
						if not start_fraps and cfg.settings.start_fraps then ---- автозапуск фрапса -----
							setVirtualKeyDown(strToIdKeys(cfg.settings.key_start_fraps), true)
							wait(500)
							setVirtualKeyDown(strToIdKeys(cfg.settings.key_start_fraps), false)
						end
						while not windows.recon_menu.v do wait(500) end
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
						if start_fraps and cfg.settings.start_fraps then ---- автозавершение фрапса -----
							setVirtualKeyDown(strToIdKeys(cfg.settings.key_start_fraps), true)
							wait(500)
							setVirtualKeyDown(strToIdKeys(cfg.settings.key_start_fraps), false)
							start_fraps = false
						end
					end)
				else return false end
			elseif v:match('(.+)%((%d+)%)') then
				textdraw.name_report = id
				control_player_recon = tonumber(string.match(v, '%((%d+)%)')) -- ник игрока в реконе
			elseif v == 'STATS' then 
				textdraw.stats = id
				lua_thread.create(function()
					while not (sampTextdrawIsExists(textdraw.close) or sampTextdrawIsExists(textdraw.name_report)) do wait(100) end
					wait(50)
					windows.recon_menu.v = true
					windows.menu_in_recon.v = true
					imgui.Process = true
					if cfg.settings.keysync then keysync(control_player_recon) end
					sampTextdrawSetPos(textdraw.stats, 2000, 0) -- кнопка статистики
					sampTextdrawSetPos(textdraw.refresh,2000,0) -- кнопка Refresh в реконе
					wait(300)
					sampTextdrawSetPos(textdraw.name_report, 2000, 0) -- информация о никнейме игрока
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
	if title == '{ff8587}Администрация проекта (онлайн)' and cfg.settings.render_admins then
		sampSendDialogResponse(dialogId, 1, 0)
		lua_thread.create(function()
			admins = textSplit(text, '\n')
			local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			for i = 1, #admins - 1 do -- {FFFFFF}N.E.O.N(0) ({2E8B57}Мл.Администратор{FFFFFF}) | Уровень: {ff8587}6{FFFFFF} | Выговоры: {ff8587}0 из 3{FFFFFF} | Репутация: {ff8587}
				local rang = string.sub(string.gsub(string.match(admins[i], '(%(.+)%)'), '(%(%d+)%)', ''), 3) --{FFFFFF}N.E.O.N(0) | Уровень: {ff8587}18{FFFFFF} | Выговоры: {ff8587}0 из 3{FFFFFF} | Репутация: {ff8587}60
				admins[i] = string.gsub(admins[i], '{%w%w%w%w%w%w}', "")
				local afk = string.match(admins[i], 'AFK: (.+)')
				local name, id, _, lvl, _, _ = string.match(admins[i], '(.+)%((%d+)%) %((.+)%) | Уровень: (%d+) | Выговоры: (%d+) из 3 | Репутация: (.+)')
				local name, id, lvl = tostring(name), tostring(id), tostring(lvl)
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
					if not management_team then if id == myid and lvl == 18 and rang ~= 'Ст.Администратор' then print('Вы - руководящий состав') management_team = true end
					elseif id ~= myid then
						for i = 1, #(cfg.render_admins_exception) do if cfg.render_admins_exception[i] == sampGetPlayerNickname(id) then  exception_admin = true end end
						if not exception_admin then
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
						end
					end
				end
				local name, id, rang, lvl, afk, rang, myid = nil
			end
			imgui.Process, windows.render_admins.v = true, true
		end)
		return false
	elseif dialogId == 1098 then -- автоонлайн
		sampSendDialogResponse(dialogId, 1, math.floor(sampGetPlayerCount(false) / 10) - 1)
		return false
	elseif button1 == 'Готово' and button2 ~= 'Закрыть' then
		lua_thread.create(function()
			local text = textSplit(text, '\n')
			for i = 1, #text - 1 do
				local _,weapon, patron = text[i]:match('(%d+)	Weapon: (%d+)     Ammo: (.+)')
				if (text[i]:find('-')) or (weapon == '0' and patron ~= '0') then
					sampAddChatMessage(tag .. 'Оружие (ID): ' .. weapon..'. Патроны: '..patron, -1)
					notify('{66CDAA}[AT] Анти-чит', 'Оружие (ID): ' .. weapon..'\nПатроны: '..patron)
					imgui.Process = false
					wait(2000)
					ffi.cast("void (*__stdcall)()", sampGetBase() + 0x70FC0)()
					player_cheater = true
					imgui.Process = true
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
	elseif title == 'Mobile' and control_player_recon then -- проверка в сети ли игрок
		lua_thread.create(function()
			local text = textSplit(text, '\n')
			local player = sampGetPlayerNickname(control_player_recon)..'('..control_player_recon..')'
			local isTrigger = false
			for i = 6, #text - 1 do
				if text[i] == player then 
					isTrigger = true
					break 
				end 
			end
			sampAddChatMessage(tag .. 'Проверяемый пользователь - ' .. player, -1)
			if isTrigger then sampAddChatMessage(tag .. 'Устройство данного юзера - мобильное устройство.', -1)
			else sampAddChatMessage(tag .. 'Устройство данного юзера - персональный компьютер.', -1) end
			wait(0)
			sampCloseCurrentDialogWithButton(0)
		end)
	elseif dialogId == 16196 then -- окно /offstats где выбор между статистикой и авто используется для /sbanip
		if find_ip_player then sampSendDialogResponse(dialogId, 1, 0) return false end
		if regip then lua_thread.create(function() wait(0) sampCloseCurrentDialogWithButton(0) end) end
	elseif dialogId == 16197 and find_ip_player then -- окно /offstats используется для /sbanip
		sampSendDialogResponse(dialogId,1,0)
		for k,v in pairs(textSplit(text, '\n')) do if k == 12 then regip = string.sub(v, 17) elseif k == 13 then lastip = string.sub(v, 18) end end
		find_ip_player = nil
		return false
	elseif dialogId == 2348 and windows.fast_report.v then windows.fast_report.v = false
	elseif dialogId == 2349 then -- окно с самим репортом.
		answer, windows.answer_player_report.v, peremrep, myid = {}, false, nil, nil
		local text = textSplit(text, '\n')
		text[1] = string.gsub(string.gsub(text[1], '{.+}', ''), 'Игрок: ', '')
		text[4] = string.gsub(string.gsub(text[4], '{.+}', ''), 'Жалоба: ', '')
		autor = text[1]																			--1
		if sampGetPlayerIdByNickname(autor) then autorid = sampGetPlayerIdByNickname(autor)		--1
		else autorid = 'Не в сети' end 
		textreport = text[4]																	--4
		reportid = tonumber(string.match(string.gsub(textreport, '%,',' ')--[[фикс запятой, из-за нее не видит ID]], '%d[%d.,]*')) --4
		if not sampIsPlayerConnected(reportid) then 											--4
			_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED) 									--4
		end																			--4
		lua_thread.create(function()
			if cfg.settings.on_custom_answer then 
				windows.fast_report.v,imgui.Process=true,true
				wait(500)
				answer = {}
				while windows.fast_report.v and not (answer.rabotay or answer.uto4 or answer.nakajy or answer.customans or answer.slejy or answer.jb or answer.ojid or answer.moiotvet or answer.uto4id or answer.nakazan or answer.otklon or answer.peredamrep) do wait(100) end
				sampSendDialogResponse(dialogId,1,0)
			end
		end)
	elseif dialogId == 2350 then -- окно с возможностью принять или отклонить репорт
		windows.fast_report.v = false
		if not peremrep then
			if answer.rabotay then peremrep = ('Начал(а) работу по вашей жалобе!')
			elseif answer.slejy then
				if not reportid then peremrep = ('Отправляюсь в слежку') answer.slejy = nil
				elseif reportid and reportid ~= myid then
					if not sampIsPlayerConnected(reportid) then
						if reportid < 300 then
							peremrep = ('Указанный вами игрок под ' .. reportid .. ' ID находится вне сети.') 
							answer.slejy = nil
						else peremrep = ('Отправляюсь в слежку') end
					else peremrep = ('Отправляюсь в слежку за игроком ' .. sampGetPlayerNickname(reportid) .. '['..reportid..']') end
				elseif myid then if reportid == myid then peremrep = ('Вы указали мой ID (^_^)') answer.slejy = nil end end
			elseif answer.nakazan then peremrep = ('Данный игрок уже был наказан.')
			elseif answer.uto4id then peremrep = ('Уточните ID нарушителя в /report.')
			elseif answer.nakajy then peremrep = ('Будете наказаны за нарушение правил /report')  
			elseif answer.jb then peremrep = ('Напишите жалобу на forumrds.ru')
			elseif answer.peredamrep then peremrep = ('Передам ваш репорт.')
			elseif answer.rabotay then peremrep = ('Начал(а) работу по вашей жалобе.')
			elseif answer.customans then peremrep = answer.customans
			elseif answer.uto4 then peremrep = ('Обратитесь с данной проблемой на форум https://forumrds.ru')
			elseif #(buffer.text_ans.v) ~= 0 and #answer == 0 then
				if checkbox.button_enter_in_report.v and (not answer.moiotvet) and (#(buffer.text_ans.v) > 5) then
					for k,v in pairs(cfg.customotvet) do
						if string.rlower(v):find(string.rlower(u8:decode(buffer.text_ans.v))) or string.rlower(v):find(translateText(string.rlower(u8:decode(buffer.text_ans.v)))) then
							peremrep = v 
							break
						end
					end
				end
				if not peremrep then 
					peremrep = u8:decode(buffer.text_ans.v)
					answer.moiotvet = true 
				end
			elseif answer.otklon then 
				sampSendDialogResponse(dialogId, 1, 2) 
				sampCloseCurrentDialogWithButton(0)
				return false
			end
		end
		if peremrep then
			if #(peremrep) > 80 then
				sampAddChatMessage(tag .. 'Ваш ответ оказался слишком длинный, попробуйте сократить текст.',-1) 
				peremrep = nil
				lua_thread.create(function()
					wait(0)
					sampCloseCurrentDialogWithButton(0)
				end)
			else
				if cfg.settings.on_color_report and (#peremrep + 6) < 80 then
					if cfg.settings.color_report == '*' then peremrep = ('{'..color()..'}' .. peremrep)
					else peremrep = (cfg.settings.color_report .. peremrep) end
					if cfg.settings.add_answer_report and (#peremrep + #(cfg.settings.mytextreport)) < 80 then peremrep = (peremrep ..('{'..color()..'} '..cfg.settings.mytextreport)) end
				end
				if #(peremrep) < 4 then peremrep = peremrep .. '    ' end
				if cfg.settings.custom_answer_save and answer.moiotvet then cfg.customotvet[ #cfg.customotvet + 1 ] = u8:decode(buffer.text_ans.v) save() end	
				sampSendDialogResponse(dialogId, 1, 0)
				sampCloseCurrentDialogWithButton(0)
				buffer.text_ans.v = ''
				return false
			end
		end
	elseif dialogId == 2351 and peremrep then -- окно с ответом на репорт
		sampSendDialogResponse(dialogId, 1, _, peremrep)
		lua_thread.create(function()
			while sampIsDialogActive() do wait(200) end
			if answer.control_player then sampSendChat('/re ' .. autorid)
			elseif answer.slejy then sampSendChat('/re ' .. reportid)
			elseif answer.peredamrep then sampSendChat('/a ' .. autor .. '[' .. autorid .. '] | ' .. textreport)
			elseif answer.nakajy then
				if not autorid then autorid = autor command = '/rmuteoff '
				else command = '/rmute ' end
				if nakazatreport.oftop then sampSendChat(command .. autorid .. ' 120 Оффтоп в /report')
				elseif nakazatreport.oskadm then sampSendChat(command .. autorid .. ' 2500 Оскорбление администрации')
				elseif nakazatreport.oskrep then sampSendChat(command .. autorid .. ' 400 Оскорбление/Унижение')
				elseif nakazatreport.poprep then sampSendChat(command .. autorid .. ' 120 Попрошайничество')
				elseif nakazatreport.oskrod then sampSendChat(command .. autorid .. ' 5000 Оскорбление/Упоминание родни')
				elseif nakazatreport.capsrep then sampSendChat(command .. autorid .. ' 120 Капс в /report')
				elseif nakazatreport.matrep then sampSendChat(command .. autorid .. ' 300 Нецензурная лексика')
				elseif nakazatreport.rozjig then sampSendChat(command .. autorid .. ' 5000 Розжиг')
				elseif nakazatreport.kl then sampSendChat(command .. autorid .. ' 3000 Клевета') end
				command = nil
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
						for i = 0, 11 do wait(500) if not copies_player_recon or (copies_report_id ~= control_player_recon) then break end end
						if windows.answer_player_report.v then windows.answer_player_report.v = false copies_player_recon = nil end
					else sampAddChatMessage(tag .. 'Игрок, написавший репорт, находится вне сети.', -1) end
				end
			else copies_player_recon = nil end
		end)
		return false
	end
end

function sampev.onDisplayGameText(style, time, text) -- скрывает текст на экране.
	if text == ('~w~RECON ~r~OFF') or text == ('~w~RECON ~r~OFF~n~~r~PLAYER DISCONNECT') then 
		windows.recon_menu.v = false 
		windows.menu_in_recon.v = false
		return false
	elseif text == ('~y~REPORT++') then
		if not AFK then
			if atr then sampSendChat("/ans") sampSendDialogResponse(2348, 1, 0) end
			if cfg.settings.notify_report then printStyledString('~n~~p~REPORT ++', 700, 4) end
		end
		return false
	end
end

function log(text) -- записываем лог
	local data_today = os.date("*t") -- узнаем дату сегодня
	local log = ('moonloader\\config\\chatlog\\chatlog '.. data_today.day..'.'..data_today.month..'.'..data_today.year..'.txt')
	local file = io.open(log,"a")
	if file then file:write('['..data_today.hour..':'..data_today.min ..':'..data_today.sec..'] ' .. encrypt(text, 3)..'\n') file:close() end
end

function render_admins()
	wait(5000)
	while true do
		while sampIsDialogActive() do wait(1000) end
		wait(1000)
		if not AFK then sampSendChat('/admins') end
		wait(30000)
	end
end

function autoonline() 
	while true do
		wait(63000) 
		while sampIsDialogActive() do wait(500) end
		wait(500) -- подстраховочка 
		if not AFK then sampSendChat("/online") end 
	end 
end

function update(param)
	local dlstatus = require('moonloader').download_status
	if param == 'fs' or param == 'all' then
		sampAddChatMessage(tag .. 'Ожидайте, начинаю процесс обновления.', -1)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_FastSpawn.lua", 'moonloader\\' .. "//resource//AT_FastSpawn.lua", function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. 'Скрипт получил актуальную версию быстрого спавна',-1)
			end  
		end)
	end 
	if param == 'mp' or param == 'all' then
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_MP.lua", 'moonloader\\' .. "//resource//AT_MP.lua", function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. 'Скрипт получил актуальную версию модуля мероприятий',-1)
			end 
		end)
	end
	if param == 'main' or param == 'all' then
		sampAddChatMessage(tag .. 'Ожидайте, начинаю процесс обновления.', -1)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/my_lib.lua", 'moonloader\\' .. "//lib//my_lib.lua", function(id, status) end)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", 'moonloader\\' .. "//config//AT//rules.txt", function(id, status)  end)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_Trassera.lua", 'moonloader\\' .. "//resource//AT_Trassera.lua", function(id, status) end)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.lua", thisScript().path, function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. 'Скрипт получил актуальную версию АТ',-1)
				reloadScripts()
			end 
		end)
	end
	lua_thread.create(function()
		wait(8000)
		reloadScripts()
	end)
end

local chars = {
	["й"] = "q", ["ц"] = "w", ["у"] = "e", ["к"] = "r", ["е"] = "t", ["н"] = "y", ["г"] = "u", ["ш"] = "i", ["щ"] = "o", ["з"] = "p", ["х"] = "[", ["ъ"] = "]", ["ф"] = "a",
	["ы"] = "s", ["в"] = "d", ["а"] = "f", ["п"] = "g", ["р"] = "h", ["о"] = "j", ["л"] = "k", ["д"] = "l", ["ж"] = ";", ["э"] = "'", ["я"] = "z", ["ч"] = "x", ["с"] = "c", ["м"] = "v",
	["и"] = "b", ["т"] = "n", ["ь"] = "m", ["б"] = ",", ["ю"] = ".", ["Й"] = "Q", ["Ц"] = "W", ["У"] = "E", ["К"] = "R", ["Е"] = "T", ["Н"] = "Y", ["Г"] = "U", ["Ш"] = "I",
	["Щ"] = "O", ["З"] = "P", ["Х"] = "{", ["Ъ"] = "}", ["Ф"] = "A", ["Ы"] = "S", ["В"] = "D", ["А"] = "F", ["П"] = "G", ["Р"] = "H", ["О"] = "J", ["Л"] = "K", ["Д"] = "L",
	["Ж"] = ":", ["Э"] = "\"", ["Я"] = "Z", ["Ч"] = "X", ["С"] = "C", ["М"] = "V", ["И"] = "B", ["Т"] = "N", ["Ь"] = "M", ["Б"] = "<", ["Ю"] = ">"
}
------------- Input Helper -------------
function translite(text)
	for k, v in pairs(chars) do text = string.gsub(text, k, v) end return text
end
function inputChat()
	local font = renderCreateFont("Calibri", cfg.settings.size_text_f6, font.BOLD + font.BORDER + font.SHADOW)
	local _, pID = sampGetPlayerIdByCharHandle(playerPed) -- myid
	local name = sampGetPlayerNickname(pID) -- mynick
	while true do
		wait(8)
		if sampIsChatInputActive() and not AFK then
			local getInput = sampGetChatInputText()
			if (oldText ~= getInput and #getInput > 0)then
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
			local in2 = getStructElement(in1, 0x8, 4)
			local in3 = getStructElement(in1, 0xC, 4)

			local ping = sampGetPlayerPing(pID) -- ping
			local caps = (ffi.load("user32")).GetKeyState(0x14) -- Код клавиши CapsLock

			if caps == 1 or caps == 3 then caps = 'ON'
			else caps = 'OFF' end

			if getCurrentLanguageName() == '00000419' then raskl = 'RU'
			else raskl = 'EN' end

			local text = string.format("Ваш ник: {0088ff}%s[%s]{ffffff}, Ваш пинг: {0088ff}%s{ffffff}, Раскладка: {0088ff}%s{ffffff}, Capslock: {0088ff}%s{ffffff}", name, pID, ping, raskl, caps)
			renderFontDrawText(font, text, in2 + 5, in3 + 40, -1)
		end
	end
end
------------- Input Helper -------------

function onWindowMessage(msg, wparam, lparam) -- блокировка ALT + Enter
	if msg == 261 and wparam == 13 then consumeWindowMessage(true, true) end
end
function ScriptExport()
	if cfg.settings.wallhack then off_wallhack() end
	showCursor(false,false)
	thisScript():unload()
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
				renderFontDrawText(fonts, '{FFFFFF}Обнаружена форма от администратора.\nНажми U, чтобы принять или J - чтобы отклонить\nВремени на раздумья 5 сек, прошло: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
				if timer>5 then break end
			end
			if not (sampIsChatInputActive() or sampIsDialogActive()) then
				if wasKeyPressed(VK_U) or cfg.settings.autoaccept_form then
					if sampIsPlayerConnected(admin_form.idadmin) then
						if string.match(admin_form.forma, '(%d+)') then
							if not sampIsPlayerConnected(string.match(admin_form.forma, '(%d+)')) then
								sampAddChatMessage(tag .. 'Указанный игрок не в сети', -1)
								break
							end
						end
						if not admin_form.styleform then sampSendChat(admin_form.forma .. ' // ' .. sampGetPlayerNickname(admin_form.idadmin))
						else sampSendChat(admin_form.forma) end
						wait(1000)
						sampSendChat('/a AT - Принято.')
					else sampAddChatMessage(tag .. 'Администратор не в сети.', -1) end
					break
				end
				if wasKeyPressed(VK_J) then
					sampAddChatMessage(tag .. 'форма отклонена', -1)
					break
				end
			end
		end
		admin_form = {}
	end)
end
function binder_key()
	while true do
		if not (sampIsChatInputActive() or sampIsDialogActive() or windows.fast_report.v or windows.answer_player_report.v or AFK) then
			if wasKeyPressed(strToIdKeys(cfg.settings.open_tool)) then  -- кнопка активации окна
				windows.menu_tools.v = not windows.menu_tools.v
				imgui.Process = true
				if windows.recon_menu.v then 	-- активация курсора если рекон меню активно
					lua_thread.create(function()
						setVirtualKeyDown(70, true)
						wait(150)
						setVirtualKeyDown(70, false)
					end)
				end
			elseif wasKeyPressed(strToIdKeys(cfg.settings.fast_key_ans)) and not windows.menu_tools.v then sampSendChat("/ans") sampSendDialogResponse(2348, 1, 0)
			elseif wasKeyPressed(strToIdKeys(cfg.settings.fast_key_addText)) and not windows.menu_tools.v then sampSetChatInputText(string.sub(sampGetChatInputText(), 1, -2) .. ' '.. cfg.settings.mytextreport) sampSetChatInputEnabled(true)
			elseif wasKeyPressed(strToIdKeys(cfg.settings.key_start_fraps)) and not windows.menu_tools.v then start_fraps = not start_fraps end
			for k,v in pairs(cfg.binder_key) do 
				if wasKeyPressed(strToIdKeys(k)) and not windows.menu_tools.v then
					local check_v, v = string.match(v, '(%d)\\n(.+)')
					if check_v == '0' then sampSendChat(v)
					elseif check_v == '1' then sampProcessChatInput(v)
					elseif check_v == '2' then sampSetChatInputText(string.sub(sampGetChatInputText(), 1, -2) .. v .. ' ') sampSetChatInputEnabled(true) end
				end 
			end
		end
		wait(30)
	end
end
--============= Wallhack ==============--
function on_wallhack() -- Включение WallHack (свойства)
	local pStSet = sampGetServerSettingsPtr();
	NTdist = mem.getfloat(pStSet + 39)
	NTwalls = mem.getint8(pStSet + 47)
	NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 500.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
end
function off_wallhack() -- Выключение WallHack (свойства)
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, 30)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
end

---============ render admin chat and ears chat ================--
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

---============ подзагрузка важных файлов ================-----
function start_my_answer()
	if start_download then sampAddChatMessage('Процесс загрузки уже идёт.', -1)
	else
		if not file_exists('moonloader\\'..'\\resource\\skin\\skin_311.png') or not file_exists('moonloader\\'..'\\resource\\auto\\vehicle_611.png') then
			start_download = true
			sampAddChatMessage(tag .. 'Файлы кастомных ответов ещё не загружены. Сразу как вы ответите на репорт я начну загрузку.', -1)
			lua_thread.create(function()
				while windows.fast_report.v do wait(1000) end
				sampAddChatMessage(tag..'Информация о скинах не загружена! Через 5 секунд создам папки, игра будет свернута.', -1)
				wait(5000)
				if not directory_exists('moonloader\\' .. "\\resource\\skin") then os.execute("mkdir moonloader\\resource\\skin") end
				if not directory_exists('moonloader\\'.. "\\resource\\auto") then os.execute("mkdir moonloader\\resource\\auto") end
				wait(3000)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				sampAddChatMessage(tag..'Папка была создана, начинаю загрузку файлов. Следить за прогрессом можно нажав Ё (~)', -1)
				sampAddChatMessage(tag..'Примерное время ожидания ~ 5 минут.', -1)
				sampAddChatMessage(tag..'В случае, если вы выйдите из игры досрочно - установка будет начата с начала.', -1)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				local dlstatus 			= require('moonloader').download_status
				for i = 0, 311 do
					downloadUrlToFile("https://assets.open.mp/assets/images/skins/"..i..".png", 'moonloader\\' .. '\\resource\\skin\\skin_'..i..'.png', function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							print('Загружаю информацию о скинах: ' .. i .. '/311')
							if i == 311 then
								print('Скачаю ещё и информацию о авто, ожидайте.') 
							end
						end 
					end)
				end
				for i = 400,611 do
					downloadUrlToFile("https://gta-serv.ru/images/stories/vehicle/vehicle_".. i ..".jpg", 'moonloader\\' .. '\\resource\\auto\\vehicle_'..i..'.png', function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							print('Загружаю информацию о авто: ' .. i-400 .. '/211')
						end
						if i==611 then print('Осталось совсем чуть-чуть...') print('Загружаю HTML-цвета ...') end
					end)
				end
				downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/color.txt", 'moonloader\\' .. '\\resource\\skin\\color.txt', function(id, status)
					if status == dlstatus.STATUS_ENDDOWNLOADDATA then
						print('Установка завершена, можете пользоваться быстрыми ответами в прежнем режиме.')
						start_download = false
					end
				end)
			end)
		else windows.custom_ans.v = not windows.custom_ans.v end
	end
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

		keys["onfoot"]["R"] = (bit.band(data.keysData, 82) == 82) or nil

		keys["onfoot"]["Alt"] = (bit.band(data.keysData, 1024) == 1024) or nil
		keys["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["onfoot"]["TAB"] = (data.otherKeys == 9) or nil
		keys["onfoot"]["Space"] = (bit.band(data.keysData, 32) == 32) or nil
		keys["onfoot"]["Ctrl"] = (data.otherKeys == 65507) or nil

		keys["onfoot"]["C"] = (bit.band(data.keysData, 2) == 2) or nil

		keys["onfoot"]["RKM"] = (bit.band(data.keysData, 4) == 4) or nil
		keys["onfoot"]["LKM"] = (bit.band(data.keysData, 128) == 128) or nil
		keys["onfoot"]["Enter"] = (bit.band(data.keysData, 16) == 16) or nil
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

		keys["vehicle"]["Q"] = (bit.band(data.keysData, 256) == 256) or nil
		keys["vehicle"]["E"] = (bit.band(data.keysData, 64) == 64) or nil

        keys["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["vehicle"]["Space"] = (bit.band(data.keysData, 128) == 128) or nil

		keys["vehicle"]["Alt"] = (bit.band(data.keysData, 4) == 4) or nil
		keys["vehicle"]["Enter"] = (bit.band(data.keysData, 16) == 16) or nil

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
					mimgui.SetCursorPosX(10 - 5 + 5)  						
					
					KeyCap("TAB", (keys[plState]["TAB"] ~= nil), mimgui.ImVec2(40, 30)); mimgui.SameLine()
					KeyCap("Q", (keys[plState]["Q"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("W", (keys[plState]["W"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("E", (keys[plState]["E"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("R", (keys[plState]["R"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()


					KeyCap("RM", (keys[plState]["RKM"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("LM", (keys[plState]["LKM"] ~= nil), mimgui.ImVec2(30, 30))					


					KeyCap("Shift", (keys[plState]["Shift"] ~= nil), mimgui.ImVec2(40, 30)); mimgui.SameLine()
					KeyCap("A", (keys[plState]["A"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("S", (keys[plState]["S"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("D", (keys[plState]["D"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("C", (keys[plState]["C"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					
					KeyCap("Enter", (keys[plState]["Enter"] ~= nil), mimgui.ImVec2(65, 30))

					KeyCap("Ctrl", (keys[plState]["Ctrl"] ~= nil), mimgui.ImVec2(40, 30)); mimgui.SameLine()
					KeyCap("Alt", (keys[plState]["Alt"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("Space", (keys[plState]["Space"] ~= nil), mimgui.ImVec2(170, 30))

				mimgui.EndGroup()

				if not windows.recon_menu.v then
					windows.menu_in_recon.v = false
					keysync('off')
				end
			else
				mimgui.Text(u8"Игрок потерян из поля видимости\nЕсли игрок так и не появился в поле видимости:\nQ - покинуть рекон, R - обновить в ручную.\nНачинаю процесс автоматического обновления рекона...")
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
			wait(500)
			while not doesCharExist(target) and windows.recon_menu.v do
				wait(1500)
				sampSendClickTextdraw(textdraw.refresh)
				printStyledString('~n~~b~~h~auto - update...', 200, 4)
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
	else
		playerId = tonumber(playerId)
		if playerId ~= nil then
			local pedExist, ped = sampGetCharHandleBySampPlayerId(playerId)
			if pedExist then
				target = ped
			end
		end
	end
	return
end
function notify(title, text)
	if plagin_notify then plagin_notify.addNotify(title, text, 2,1,12) end
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
----------------- ДЛЯ ID В КИЛЛ ЧАТЕ ----------- ТЕМЫ -------------------(НИЖЕ БОЛЬШЕ НИЧЕГО НЕТ.)

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
local colours = {
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