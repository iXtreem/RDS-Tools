-- [[ Редактируя код, я не ручаюсь за ваши ошибки, есть пожелание - предлагайте, возможно реализую. ]] --
require 'lib.moonloader'									-- Считываем библиотеки Moonloader
import("\\resource\\AT_FastSpawn.lua")  					-- подгрузка быстрого спавна
require 'my_lib'											-- Комбо функций необходимых для скрипта
script_name 'AdminTools [AT]'  								-- Название скрипта 
script_author 'Neon4ik' 									-- Псевдоним разработчика в игре N.E.O.N
script_properties("work-in-pause") 							-- Возможность обрабатывать информацию, находясь в AFK
local version = 9   			 							-- Версия скрипта


local DELETE_TEXTDRAW_RECON = {} -- вписать сюда через запятую какие текстравы удалять в РЕКОНЕ

for i = 186, 250 do -- генератор ID текстдравов попадающих под удаление из рекона, можно изменить вручную
	table.insert(DELETE_TEXTDRAW_RECON, i, #DELETE_TEXTDRAW_RECON+1)
end

local cfg = inicfg.load({  									-- Загружаем базовый конфиг, если он отсутствует
	settings = {
		style = 0,
		autoonline = false,
		inputhelper = true,
		add_answer_report = true,
		notify_report = false,
		automute = false,
		smart_automute = false,
		render_admins_positionX = sw-300,
		render_admins_positionY = sh-150,
		render_admins = true,
		mytextreport = '|| Приятной игры на RDS <3',
		position_recon_menu_x = sw - 260,
		position_recon_menu_y = 0,
		keysync = true,
		wallhack = true,
		answer_player_report = false,
		admin_chat = true,
		position_adminchat_x = 0,
		position_adminchat_y = sh*0.5-100,
		custom_answer_save = false,
		find_form = false,
		on_custom_recon_menu = true,
		on_custom_answer = true,
		position_ears_x = sw-400,
		position_ears_y = sh-200,
		size_adminchat = 10,
		size_ears = 10,
		strok_ears = 11,
		strok_admin_chat = 9,
		keysyncx = sw*0.5,
		keysyncy = sh-120,
		fast_key_ans = 'None',
		fast_key_addText = 'None',
		fast_key_wallhack = 'None',
		key_automute = 'None',
		prefixh = '',
		prefixma = '',
		prefixa = '',
		prefixsa = '',
		autoprefix = false,
		forma_na_ban = false,
		forma_na_jail = false,
		forma_na_kick = false,
		forma_na_mute = false,
		add_mynick_in_form = false,
		size_text_f6 = 11,
		enter_report = true,
		open_tool = 'F3',
		weapon_hack = false,
		autoaccept_form = false,
		bloknotik = '',
		chat_log = true,
		control_afk = false,
		vision_form = true,
		color_chat = '{0088ff}',
		active_chat = true,
		auto_cc     = false,
		option_automute = 0,
		key_automute = "Insert",
		sek_automute = 8,
		sokr_nick = "",
		nodialog = true,
		custom_addtext_report = "",
		addBeginText = true,
		atr = false,
		timetext = false,
		customtimetext = "",
		timetext_razmer = 14,
		timetext_pos_x = sw*0.5-100,
		timetext_pos_y = sh-20,
		save_radar = false,
		time_nakazanie = true,
		time_nakazanie_posx = sw-400,
		time_nakazanie_posy = 10,
		time_form = 8,
		render_players = false,
		render_players_x = sh*0.5,
		render_players_y = sw*0.5 - 150,
		render_players_size = 10,
		render_players_count = 10,
		sound_report = 80,
	},
	customotvet = {},
	myflood = {},
	my_command = {},
	binder_key = {},
	render_admins_exception = {},
	spisokoskrod = {
		'mq',
	},
	spisokproject = {
		'аризона',
	},
	spisokor = {
		'мать',
	},
	spisokrz = {
		'слава укр'
	},
	spisokoskadm = {
		'админ',
	},
	report_button = {},
	auto_ban = {},
	custom_hints = {},
}, 'AT//AT_main.ini')
inicfg.save(cfg, 'AT//AT_main.ini')
style(cfg.settings.style)
import("\\resource\\AT_Trassera.lua") 	  			-- подгрузка трассеров
------=================== ImGui окна ===================----------------------

local array = {
	windows = {
		menu_tools 			= imgui.ImBool(false),
		fast_report 		= imgui.ImBool(false),
		recon_menu 			= imgui.ImBool(false),
		answer_player_report= imgui.ImBool(false),
		custom_ans 			= imgui.ImBool(false),
		render_admins		= imgui.ImBool(false),
		pravila 			= imgui.ImBool(false),
		menu_chatlogger 	= imgui.ImBool(false),
	},
	------=================== Выставление своих настроек, кнопки со значение True/False ===================----------------------
	checkbox = {
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
		check_weapon_hack 		= imgui.ImBool(cfg.settings.weapon_hack),
		checked_radio_button 	= imgui.ImInt(1),
		custom_ans 				= imgui.ImInt(4),
		new_binder_key 			= imgui.ImInt(1),
		add_smart_automute 		= imgui.ImInt(0),
		style_selected 			= imgui.ImInt(cfg.settings.style),
		selected_adminchat		= imgui.ImInt(cfg.settings.size_adminchat),
		selected_adminchat2 	= imgui.ImInt(cfg.settings.strok_admin_chat),
		selected_ears 			= imgui.ImInt(cfg.settings.size_ears),
		selected_ears2			= imgui.ImInt(cfg.settings.strok_ears),
		option_find_log 		= imgui.ImInt(2),
		button_enter_in_report 	= imgui.ImBool(cfg.settings.enter_report),
		check_render_ears 		= imgui.ImBool(false),
		add_full_words 			= imgui.ImBool(true),
		autoaccept_form 		= imgui.ImBool(cfg.settings.autoaccept_form),
		inputhelper			  	= imgui.ImBool(cfg.settings.inputhelper),
		check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report),
		check_on_custom_recon_menu = imgui.ImBool(cfg.settings.on_custom_recon_menu),
		autoprefix				   = imgui.ImBool(cfg.settings.autoprefix),
		size_chat 				   = imgui.ImInt(cfg.settings.size_text_f6),
		active_chat 			   = imgui.ImBool(cfg.settings.active_chat),
		vision_form				   = imgui.ImBool(cfg.settings.vision_form),
		auto_cc					   = imgui.ImBool(cfg.settings.auto_cc),
	 	option_automute 		   = imgui.ImInt(cfg.settings.option_automute),
		sek_automute 			   = imgui.ImInt(cfg.settings.sek_automute),
		razmer_text				   = imgui.ImInt(cfg.settings.timetext_razmer),
		radar 					   = imgui.ImBool(cfg.settings.save_radar),
		time_nakazanie 			   = imgui.ImBool(cfg.settings.time_nakazanie),
		time_form				   = imgui.ImInt(cfg.settings.time_form),
		render_players			   = imgui.ImBool(cfg.settings.render_players),
		render_players_size 	   = imgui.ImInt(cfg.settings.render_players_size),
		render_players_count 	   = imgui.ImInt(cfg.settings.render_players_count),
		sound_report 			   = imgui.ImInt(cfg.settings.sound_report),
	},
	------=================== Ввод данных в ImGui окне ===================----------------------
	buffer = {
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
		add_smart_automute  = imgui.ImBuffer(4096),
		new_word 		 	= imgui.ImBuffer(4096),
		sokr_nick			= imgui.ImBuffer(cfg.settings.sokr_nick, 256),
		custom_addtext_report = imgui.ImBuffer(cfg.settings.custom_addtext_report, 256),
		customtimetext 		  = imgui.ImBuffer( u8(cfg.settings.customtimetext), 1024),
		newButtonReport 	  = imgui.ImBuffer(1024),
		newButtonReportName   = imgui.ImBuffer(1024),
	},
	chatlog_1 		= {}, 											-- чат-лог1
	chatlog_2 		= {}, 											-- чат-лог2
	chatlog_3 		= {}, 											-- чат-лог3
	files_chatlogs 	= {},											-- список чат-логгов
	admins 			= {},											-- Рендер /admins
	textdraw 		= {}, 											-- узнаем ид текстравов для взаимодействия с ними
	admin_form 		= {}, 											-- Работа с админ-формами
	nakazatreport 	= {},											-- Возможность наказать прямо из репорта
	answer 			= {}, 											-- Выбор ответа в репорте
	adminchat 		= {},											-- Все админ-сообщения хранятся тут
	adminchat_minimal = {},											-- Сокращенный AdminChat
	ears 			= {},											-- Все ears сообщения хранятся тут
	ears_minimal 	= {},											-- Сокращенный EARS
	render_players  = {},											-- Входы выходы игроков
	inforeport 		= {},											-- Вся информация о игроке в реконе хранится тут
	pravila 		= {},											-- Правила/команды хранятся тут /ahelp
	flood = { --[[сборник ID]]message = {},--[[Сообщение]]time = {},--[[время отправки]]count = {},--[[кол-во повторных сообщений]] nick = {} --[[ник-нейм запоминаем]]},
	name_car = {'Landstalker','Bravura','Buffalo','Linerunner','Perrenial','Sentinel','Dumper','Firetruck','Trashmaster','Stretch','Manana','Infernus','Voodoo','Pony','Mule','Cheetah','Ambulance','Leviathan','Moonbeam','Esperanto','Taxi','Washington','Bobcat','Mr Whoopee','BF Injection','Hunter','Premier','Enforcer','Securicar','Banshee','Predator','Bus','Rhino','Barracks','Hotknife','Trailer','Previon','Coach','Cabbie','Stallion','Rumpo','RC Bandit','Romero','Packer','Monster','Admiral','Squalo','Seasparrow','Pizzaboy','Tram','Trailer2','Turismo','Speeder','Reefer','Tropic','Flatbed','Yankee','Caddy','Solair','BerkleysRCVan','Skimmer','PCJ-600','Faggio','Freeway','RC Baron','RC Raider','Glendale','Oceanic','Sanchez','Sparrow','Patriot','Quad','Coastguard','Dinghy','Hermes','Sabre','Rustler','ZR-350','Walton','Regina','Comet','BMX','Burrito','Camper','Marquis','Baggage','Dozer','Maverick','News Chopper','Rancher','FBI Rancher','Virgo','Greenwood','Jetmax','Hotring','Sandking','Blista Compact','Police Maverick','Boxville','Benson','Mesa','RC Goblin','Hotring Racer A','Hotring Racer B','Bloodring Banger','Rancher','Super GT','Elegant','Journey','Bike','Mountain Bike','Beagle','Cropdust','Stunt','Tanker','Roadtrain','Nebula','Majestic','Buccaneer','Shamal','Hydra','FCR-900','NRG-500','HPV1000','Cement Truck','Tow Truck','Fortune','Cadrona','FBI Truck','Willard','Forklift','Tractor','Combine','Feltzer','Remington','Slamvan','Blade','Freight','Streak','Vortex','Vincent','Bullet','Clover','Sadler','Firetruck LA','Hustler','Intruder','Primo','Cargobob','Tampa',	'Sunrise','Merit','Utility','Nevada','Yosemite','Windsor','Monster A','Monster B','Uranus','Jester',	'Sultan',	'Stratum','Elegy','Raindance','RC Tiger',	'Flash',	'Tahoma','Savanna','Bandito','Freight Flat','Streak Carriage','Kart','Mower','Duneride','Sweeper','Broadway','Tornado','AT-400','DFT-30','Huntley','Stafford','BF-400','Newsvan','Tug','Trailer3','Emperor','Wayfarer','Euros','Hotdog','Club','Freight Carriage','Trailer4','Andromada','Dodo','RC Cam','Launch','Police Car (LSPD)','Police Car (SFPD)','Police Car (LVPD)','Police Ranger','Picador','S.W.A.T. Van','Alpha','Phoenix','Glendale','Sadler','Luggage Trailer A','Luggage Trailer B','Stair Trailer','Boxville','Farm Plow','Utility Trailer'},
	--AutoMute
	mat 				= {},										-- автомут на мат
	osk 				= {},										-- автомут на оск
	spisok_in_form = {											 	-- список для автоформ
		'ban',
		'jail',
		'kick',
		'mute',
	},
	chars = { 	-- инпут хелпер
		["й"] = "q", ["ц"] = "w", ["у"] = "e", ["к"] = "r", ["е"] = "t", ["н"] = "y", ["г"] = "u", ["ш"] = "i", ["щ"] = "o", ["з"] = "p", ["х"] = "[", ["ъ"] = "]", ["ф"] = "a",
		["ы"] = "s", ["в"] = "d", ["а"] = "f", ["п"] = "g", ["р"] = "h", ["о"] = "j", ["л"] = "k", ["д"] = "l", ["ж"] = ";", ["э"] = "'", ["я"] = "z", ["ч"] = "x", ["с"] = "c", ["м"] = "v",
		["и"] = "b", ["т"] = "n", ["ь"] = "m", ["б"] = ",", ["ю"] = ".", ["Й"] = "Q", ["Ц"] = "W", ["У"] = "E", ["К"] = "R", ["Е"] = "T", ["Н"] = "Y", ["Г"] = "U", ["Ш"] = "I",
		["Щ"] = "O", ["З"] = "P", ["Х"] = "{", ["Ъ"] = "}", ["Ф"] = "A", ["Ы"] = "S", ["В"] = "D", ["А"] = "F", ["П"] = "G", ["Р"] = "H", ["О"] = "J", ["Л"] = "K", ["Д"] = "L",
		["Ж"] = ":", ["Э"] = "\"", ["Я"] = "Z", ["Ч"] = "X", ["С"] = "C", ["М"] = "V", ["И"] = "B", ["Т"] = "N", ["Ь"] = "M", ["Б"] = "<", ["Ю"] = ">"
	},
	keys = { 	-- keysync
		["onfoot"] = {},
		["vehicle"] = {}
	},
}
local menu 				= 'Главное меню' 								-- Разные вкладки в F3
local menu_in_recon 	= 'Главное меню'								-- Разные вкладки в рекон
local tag 				= '{2B6CC4}Admin Tools: {F0E68C}' 				-- Задаем название скрипта в самой игре
local AFK 				= false											-- основной триггер скрипта, афк мы или нет
local target            = -1											-- Игрок в виртуальных клавишах
local tr 				= false
local control_player_recon = 0											-- Игрок в реконе
local font_adminchat = renderCreateFont("Arial", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW) -- шрифт админ чата
local font_earschat  = renderCreateFont("Arial", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)	   -- шрифт ears чата
local font_chat 	 = renderCreateFont("Arial", cfg.settings.size_text_f6, font.BOLD + font.BORDER + font.SHADOW) -- шрифт открытого чата
local font_timetext  = renderCreateFont("Arial", cfg.settings.timetext_razmer, font.BOLD + font.BORDER + font.SHADOW) -- время снизу
local font_players   = renderCreateFont("Arial", cfg.settings.render_players_size, font.BOLD + font.BORDER + font.SHADOW) -- время снизу

--======================================= РЕГИСТРАЦИЯ КОМАНД ====================================--
local basic_command = { -- базовые команды, 1 аргумент = символ '_'
	prochee = {
		["/update"]  	= 		'Обновить скрипт',
		["/fs"] 		=		'Открыть меню FastSpawn',
		["/trassera"] 	= 		'Открыть настройку трассеров пуль',
		["/ears"] 		=		'Включить/выключить рендер личных сообщений игроков',
		["/ahelp"] 		= 		'Все команды скрипта/сервера и правила',
		["/wh"] 		= 		'Включить/выключить WallHack',
		["/c"] 			=		'Быстрый ответ игроку в формате репорта',
		["/rst"] 		= 		'Принудительная перезагрузка всех Lua скриптов',
		["/tool"] 		= 		'Активировать меню АТ',
		["/sbanip"] 	= 		'Выдать блокировку аккаунта с IP адресом (ФД!)',
		["/opencl"]  	= 		'Открыть меню чат-логгера',
		["/spp"] 		= 		'Заспавнить игроков в радиусе',
		["/prfma"] 		= 		'Выдать префикс мл.админу',
		["/prfa"] 		= 		'Выдать префикс админу',
		["/prfsa"] 		= 		'Выдать префикс старшему админу',
		["/prfpga"] 	= 		'Выдать префикс ПГА',
		["/prfzga"] 	= 		'Выдать префикс ЗГА',
		["/prfga"] 		= 		'Выдать префикс ГА',
		["/color_report"]='Назначить цвет ответа на репорт',
		["/control_afk"] ='Автоматически закрывать игру, при AFK более указанного кол-ва минут',
		["/add_autoprefix"]='Добавить администратора в исключение автопрефикса',
		["/del_autoprefix"]='Удалить администратора из исключений автопрефикса',
		["/reset"] 		='Сбросить настройки по умолчанию',
		["/autoban"] 	='Автоматический бан за рекламу, ключевые слова',
		["/up"]	 		= "/mute _ 1000 Упом стор. проектов",
		["/q"] 			= "Выход из игры",
		["/pagesize"] 	= "Настройка количества строк в чате",
		["/fontsize"] 	= "Настройка размера чата",
		["/headmove"] 	= "Настройка вращения головы персонажа",
		["/timestamp"]	= "Время в чате",
		["/alogin"] 	= "Авторизация в админ-права",
		["/hints"]      = "Добавление своих подсказок в input helper",
	},
	help = {
		["/uu"]      =  	'/unmute _',
		["/uj"]      =  	'/unjail _',
		["/ur"]      =  	'/unrmute _',
		["/uuf"] 	 =		'/muteakk _ 5 Наказание снято.',
		["/ujf"] 	 =		'/jailakk _ 5 Наказание снято.',
		["/urf"] 	 = 		'/rmuteoff _ 5 Наказание снято.',
		["/as"]      =  	'/aspawn _',
		["/gv"] 	 =		'/giveaccess _',
		["/mk"] 	 =		'/makeadmin _',
		["/sa"]		 =		'/setadmin',
		["/sn"] 	 =		'/setnick _',
		["/stw"]     =  	'/setweap _ 38 5000',
		["/vig"] 	 =		"/vvig _ 1 Злоупотребление VIP'ом",
	},
	ans = { 														-- с вариативностью есть доп/текст или нет
		["/nv"]      =  	'/ot _ Игрок не в сети',
		["/cl"]      =  	'/ot _ Данный игрок чист.',
		["/pmv"]     =  	'/ot _ Помогли вам. Обращайтесь ещё',
		["/dpr"]     =  	'/ot _ У игрока куплены функции за /donate',
		["/afk"]     =  	'/ot _ Игрок бездействует или находится в AFK',
		["/nak"]     =  	'/ot _ Игрок был наказан! Благодарим за обращение.',
		["/n"]       =  	'/ot _ Нарушений со стороны игрока не наблюдается.',
		["/fo"]      =  	'/ot _ Обратитесь на форум по ссылке https://forumrds.ru',
		["/rep"]     =  	'/ot _ Нашли нарушителя? Появился вопрос? Напишите /report!',
		["/al"]      =		'/ot _ Введите /alogin и свой пароль, пожалуйста.',
	},
	mute = { -- ВНИМАНИЕ КОМАНДЫ ДЛЯ ВЫДАЧИ В ОФФЛАЙНЕ СОЗДАЮТСЯ САМИ С ОКОНЧАНИЕМ -f
		["/fd"]     =  		'/mute _ 120 Флуд/Спам',			--[[x10]]["/fd2"]='/mute _ 240 Флуд x2',["/fd3"]='/mute _ 360 Флуд x3',["/fd4"]='/mute _ 480 Флуд x4',["/fd5"]='/mute _ 600 Флуд x5',["/fd6"]='/mute _ 720 Флуд x6',["/fd7"]='/mute _ 840 Флуд x7',["/fd8"]='/mute _ 960 Флуд x8',["/fd9"]='/mute _ 1080 Флуд x9',["/fd10"]='/mute _ 1200 Флуд x10',
		["/po"] 	=  		'/mute _ 120 Попрошайничество',		--[[x10]]["/po2"]='/mute _ 240 Попрошайничество x2',["/po3"]='/mute _ 360 Попрошайничество x3',["/po4"] ='/mute _ 480 Попрошайничество x4',["/po5"] ='/mute _ 600 Попрошайничество x5',["/po6"] ='/mute _ 720 Попрошайничество x6',["/po7"] ='/mute _ 840 Попрошайничество x7',["/po8"] ='/mute _ 960 Попрошайничество x8',["/po9"] ='/mute _ 1080 Попрошайничество x9',["/po10"] ='/mute _ 1200 Попрошайничество x10',
		["/m"]      =  		'/mute _ 300 Нецензурная лексика',	--[[x10]]["/m2"]='/mute _ 600 Нецензурная лексика x2',["/m3"]='/mute _ 900 Нецензурная лексика x3',["/m4"]='/mute _ 1200 Нецензурная лексика x4',["/m5"]='/mute _ 1500 Нецензурная лексика x5',["/m6"]='/mute _ 1800 Нецензурная лексика x6',["/m7"]='/mute _ 2100 Нецензурная лексика x7',["/m8"]='/mute _ 2400 Нецензурная лексика x8',["/m9"]='/mute _ 2700 Нецензурная лексика x9',["/m10"]='/mute _ 3000 Нецензурная лексика x10',
		["/ok"]     =  		'/mute _ 400 Оскорбление/Унижение',	--[[x10]]["/ok2"]='/mute _ 800 Оскорбление/Унижение x2',["/ok3"]='/mute _ 1200 Оскорбление/Унижение x3',["/ok4"]='/mute _ 1600 Оскорбление/Унижение x4',["/ok5"]='/mute _ 2000 Оскорбление/Унижение x5',["/ok6"]='/mute _ 2400 Оскорбление/Унижение x6',["/ok7"]='/mute _ 2800 Оскорбление/Унижение x7',["/ok8"]='/mute _ 3200 Оскорбление/Унижение x8',["/ok9"]='/mute _ 3600 Оскорбление/Унижение x9',["/ok10"]='/mute _ 4000 Оскорбление/Унижение x10',
		["/oa"] 	=  		'/mute _ 2500 Оскорбление администрации',
		["/kl"] 	=  		'/mute _ 3000 Клевета на администрацию',
		["/zs"] 	=  		'/mute _ 600 Злоупотребление символами',
		["/nm"] 	=  		'/mute _ 600 Неадекватное поведение.',
		["/rekl"] 	=  		'/mute _ 1000 Реклама',
		["/rz"]		=  		'/mute _ 5000 Розжиг межнац. розни',
		["/or"]		= 		'/mute _ 5000 Оскорбление/Упоминание родни',
		["/ia"] 	=  		'/mute _ 2500 Выдача себя за администратора',
	},
	rmute = { -- ВНИМАНИЕ КОМАНДЫ ДЛЯ ВЫДАЧИ В ОФФЛАЙНЕ СОЗДАЮТСЯ САМИ С ОКОНЧАНИЕМ -f
		["/oft"] 	= 		'/rmute _ 120 оффтоп в репорт',		--[[x10]]["/oft2"]='/rmute _ 240 оффтоп в репорт x2',["/oft3"]='/rmute _ 360 оффтоп в репорт x3',["/oft4"]='/rmute _ 480 оффтоп в репорт х4',["/oft5"]='/rmute _ 600 оффтоп в репорт х5',["/oft6"]='/rmute _ 720 оффтоп в репорт x6',["/oft7"]='/rmute _ 840 оффтоп в репорт х7',["/oft8"]='/rmute _ 960 оффтоп в репорт х8',["/oft9"]='/rmute _ 1080 оффтоп в репорт х9',["/oft10"]='/rmute _ 1200 оффтоп в репорт х10',
		["/rpo"]	=		'/rmute _ 120 Попрошайка в /report',--[[x10]]["/rpo2"]='/rmute _ 240 Попрошайка в /report x2',["/rpo3"]='/rmute _ 360 Попрошайка в /report x3',["/rpo4"]='/rmute _ 480 Попрошайка в /report x4',["/rpo5"]='/rmute _ 600 Попрошайка в /report x5',["/rpo6"]='/rmute _ 720 Попрошайка в /report x6',["/rpo7"]='/rmute _ 840 Попрошайка в /report x7',["/rpo8"]='/rmute _ 960 Попрошайка в /report x8',["/rpo9"]='/rmute _ 1080 Попрошайка в /report x9',["/rpo10"]='/rmute _ 1200 Попрошайка в /report x10',
		["/rm"] 	= 		'/rmute _ 300 мат в /report',		--[[x10]]["/rm2"]='/rmute _ 600 мат в /report x2',["/rm3"]='/rmute _ 900 мат в /report x3',["/rm4"]='/rmute _ 600 мат в /report x4',["/rm5"]='/rmute _ 600 мат в /report x5',["/rm6"]='/rmute _ 600 мат в /report x6',["/rm7"]='/rmute _ 600 мат в /report x7',["/rm8"]='/rmute _ 600 мат в /report x8',["/rm9"]='/rmute _ 600 мат в /report x9',["/rm10"]='/rmute _ 600 мат в /report x10',
		["/rok"] 	= 		'/rmute _ 400 Оскорбление в /report',--[[x10]]["/rok2"]='/rmute _ 800 Оскорбление в /report x2',["/rok3"]='/rmute _ 1200 Оскорбление в /report x3',["/rok4"]='/rmute _ 1600 Оскорбление в /report x4',["/rok5"]='/rmute _ 2000 Оскорбление в /report x5',["/rok6"]='/rmute _ 2400 Оскорбление в /report x6',["/rok7"]='/rmute _ 2800 Оскорбление в /report x7',["/rok8"]='/rmute _ 3200 Оскорбление в /report x8',["/rok9"]='/rmute _ 3600 Оскорбление в /report x9',["/rok10"]='/rmute _ 4000 Оскорбление в /report x10',
		["/roa"] 	= 		'/rmute _ 2500 Оскорблeние администрации',
		["/ror"] 	= 		'/rmute _ 5000 Оскорблeние/Упоминание родных',
		["/rzs"] 	= 		'/rmute _ 600 Злоупотребление символaми',
		["/rrz"] 	= 		'/rmute _ 5000 Розжиг межнац. рoзни',
		["/rkl"] 	= 		'/rmute _ 3000 Клевeта на администрацию'
	},
	jail = { -- ВНИМАНИЕ КОМАНДЫ ДЛЯ ВЫДАЧИ В ОФФЛАЙНЕ СОЗДАЮТСЯ САМИ С ОКОНЧАНИЕМ -f
		["/bg"] 	= 		'/jail _ 300 Багоюз',
		["/td"] 	= 		'/jail _ 300 car in /trade',
		["/jm"] 	= 		'/jail _ 300 Нарушение правил МП',	--[[x10]]["/jm2"]='/jail _ 600 Нарушение правил МП x2',["/jm3"]='/jail _ 900 Нарушение правил МП x3',["/jm4"]='/jail _ 1200 Нарушение правил МП x4',["/jm5"]='/jail _ 1500 Нарушение правил МП x5',["/jm6"]='/jail _ 1800 Нарушение правил МП x6',["/jm7"]='/jail _ 2100 Нарушение правил МП x7',["/jm8"]='/jail _ 2400 Нарушение правил МП x8',["/jm9"]='/jail _ 2700 Нарушение правил МП x9',["/jm10"]='/jail _ 3000 Нарушение правил МП x10',
		["/dz"]		=		'/jail _ 300 ДМ/ДБ в зеленой зоне',	--[[x10]]["/dz2"]='/jail _ 600 ДМ/ДБ в зеленой зоне x2',["/dz3"]='/jail _ 900 ДМ/ДБ в зеленой зоне x3',["/dz4"]='/jail _ 1200 ДМ/ДБ в зеленой зоне x4',["/dz5"]='/jail _ 1500 ДМ/ДБ в зеленой зоне x5',["/dz6"]='/jail _ 1800 ДМ/ДБ в зеленой зоне x6',["/dz7"]='/jail _ 2100 ДМ/ДБ в зеленой зоне x7',["/dz8"]='/jail _ 2400 ДМ/ДБ в зеленой зоне x8',["/dz9"]='/jail _ 2700 ДМ/ДБ в зеленой зоне x9',["/dz10"]='/jail _ 3000 ДМ/ДБ в зеленой зоне x10',
		["/sk"] 	= 		'/jail _ 300 Spawn Kill',			--[[x10]]["/sk2"]='/jail _ 600 Spawn Kill x2',["/sk3"]='/jail _ 900 Spawn Kill x3',["/sk4"]='/jail _ 1200 Spawn Kill x4',["/sk5"]='/jail _ 1500 Spawn Kill x5',["/sk6"]='/jail _ 1800 Spawn Kill x6',["/sk7"]='/jail _ 2100 Spawn Kill x7',["/sk8"]='/jail _ 2400 Spawn Kill x8',["/sk9"]='/jail _ 2700 Spawn Kill x9',["/sk10"]='/jail _ 3000 Spawn Kill x10',
		["/dk"] 	= 		'/jail _ 900 ДБ Ковш в зеленой зоне',
		["/jc"] 	= 		'/jail _ 900 сторонний скрипт/ПО',
		["/sh"] 	= 		'/jail _ 900 SpeedHack/FlyCar',
		["/prk"] 	=		'/jail _ 900 Parkour mode',
		["/vs"] 	=		'/jail _ 900 Дрифт мод',
		["/jcb"] 	= 		'/jail _ 3000 читерский скрипт/ПО',
		["/zv"] 	= 		"/jail _ 3000 Злоупотребление VIP'ом",
		["/dmp"] 	= 		'/jail _ 3000 Серьезная помеха на МП',
	},
	ban = { -- ВНИМАНИЕ КОМАНДЫ ДЛЯ ВЫДАЧИ В ОФФЛАЙНЕ СОЗДАЮТСЯ САМИ С ОКОНЧАНИЕМ -f
		["/bh"] 	= 		'/ban _ 3 Нарушение правил /helper',
		["/nmb"] 	= 		'/ban _ 3 Неадекватное поведение',
		["/ch"]		= 		'/iban _ 7 читерский скрипт/ПО',
		["/obh"] 	= 		'/iban _ 7 Обход прошлого бана',
		["/bosk"]   =   	'/siban _ 999 Оскорбление проекта',
		["/rk"] 	= 		'/siban _ 999 Реклама',
		["/obm"] 	= 		'/siban _ 30 Обман/Развод',
	},
	kick = {
		["/nickban"] 	= 	'/ban _ 7 Смените никнейм.',
		["/nick"] 	= 		'/kick _ Смените никнейм.',
		["/cafk"] 	= 		'/kick _ AFK in /arena',
		["/dj"] 	= 		'/kick _ DM in jail',
	},
	server = {},
	custom = {},
}

---=========================== ОСНОВНОЙ СЦЕНАРИЙ СКРИПТА ============-----------------
function main()
	while not isSampAvailable() do wait(3000) end
	local scanDirectory = function(path) -- Проверяем все файлы в папке
		array.files_chatlogs = {}
		local lfs = require("lfs")
		for file in lfs.dir(path) do
			if file ~= nil and file ~= "." and file ~= ".." then
				local fullPath = path .. "/" .. file
				local attributes = lfs.attributes(fullPath)
				if attributes.mode == "directory" then
					local nestedFiles = scanDirectory(fullPath)
					for _, nestedFile in ipairs(nestedFiles) do table.insert(array.files_chatlogs, nestedFile) end
				else table.insert(array.files_chatlogs, file ) end
			end
		end
		return array.files_chatlogs
	end

	local data_today = os.date("*t") -- узнаем дату сегодня
	local log = ('moonloader\\config\\chatlog\\chatlog '.. data_today.day..'.'..data_today.month..'.'..data_today.year..'.txt')

	if not directory_exists('moonloader\\config\\chatlog\\') then os.execute("mkdir moonloader\\config\\chatlog") print('Папка отсутствовала, создал новую.') end
	if not file_exists(log) then
		local file = io.open(log,"w")
		file:close()
		print('Создан новый chatlog '.. data_today.day..'.'..data_today.month..'.'..data_today.year..'.txt')
	end
	sampRegisterChatCommand('opencl', function()
		for k, v in ipairs(scanDirectory('moonloader\\config\\chatlog\\')) do
			local data1,data2,data3 = string.sub(string.gsub(string.gsub(v, 'chatlog ', ''), '%.',' '), 1,-5):match('(%d+) (%d+) (%d+)')
			if tonumber(data3) and tonumber(data2) and tonumber(data3) then
				if tonumber(daysPassed(data3,data2,data1)) < 3 then
					local log = "moonloader\\config\\chatlog\\"..v
					if file_exists(log) then
						local file = io.open(log,'r')
						for line in file:lines() do
							local line = encrypt(line, -3)
							if not (line:match('Время администратирования за сегодня:') or line:match('Ваша репутация:') or line:match('Всего администрации в сети:')) then
								if k == 1 then array.chatlog_1[#array.chatlog_1 + 1] = line
									array.checkbox.option_find_log.v = 0
								elseif k == 2 then array.chatlog_2[#array.chatlog_2 + 1] = line
									array.checkbox.option_find_log.v = 1
								elseif k == 3 then array.chatlog_3[#array.chatlog_3 + 1] = line
									array.checkbox.option_find_log.v = 2
								end
							end
						end
						file:close()
					end
				else os.remove('moonloader\\config\\chatlog\\' .. v) end -- если чатлогу больше 3 дней (вкл) то удаляем его
			else os.remove("moonloader\\config\\chatlog\\" ..v) end
		end
		for i = 1, 512 do  -- [[[ FIX BUG INPUT TEXT IMGUI  ]]]
			imgui:GetIO().KeysDown[i] = false
		end
		for i = 1, 5 do
			imgui:GetIO().MouseDown[i] = false
		end
		imgui:GetIO().KeyCtrl = false
		imgui:GetIO().KeyShift = false
		imgui:GetIO().KeyAlt = false
		imgui:GetIO().KeySuper = false  
		array.windows.menu_chatlogger.v = not array.windows.menu_chatlogger.v
		imgui.Process = array.windows.menu_chatlogger.v
	end)
	local direct = "moonloader/resource/report.mp3"
	if not file_exists(direct) then
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/report.mp3", direct, function(id, status) end)
	end
	while not sampIsLocalPlayerSpawned() do wait(1000) end
	func_inputhelper = lua_thread.create_suspended(input_helper)
	func_timetext    = lua_thread.create_suspended(time_text)
	if cfg.settings.inputhelper then func_inputhelper:run() end
	if cfg.settings.timetext then func_timetext:run() end
	local wait_alogin = true
	for i = 1, 200 do
		for id = 500, 515 do -- [[ ID TEXDRAW FROM ALOGIN TABLE ID CHEATERS ]] --
			if sampTextdrawIsExists(id) then
				wait_alogin = nil
				break
			end
		end
		wait(1000)
		if not wait_alogin then break end
	end
	if wait_alogin then ffi.C.ExitProcess(0) end
	local dlstatus = require('moonloader').download_status
    downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.ini", 'moonloader//config//AT//AdminTools.ini', function(id, status) end)
	local AdminTools = inicfg.load(nil, 'moonloader\\config\\AT\\AdminTools.ini')
	if AdminTools then
		if AdminTools.script.info then update_info = AdminTools.script.info end
		if AdminTools.script.version > version then
			if AdminTools.script.main then
				sampAddChatMessage(tag .. 'Обнаружено новое {FF0000}обязательное {F0E68C}обновление скрипта! Произвожу само-обновление!', -1)
				wait(5000)
				download_update()
			else
				sampAddChatMessage(tag .. 'Обнаружено новое обновление скрипта version['..AdminTools.script.version..']! Команда /update обновляет скрипт.', -1)
			end
		end
		if cfg.settings.versionFS and cfg.settings.versionMP then
			if AdminTools.script.versionMP > cfg.settings.versionMP then sampAddChatMessage(tag .. 'Обнаружено новое обновление скрипта version['..AdminTools.script.version..']! Команда /update обновляет скрипт.', -1) end
			if AdminTools.script.versionFS > cfg.settings.versionFS then sampAddChatMessage(tag .. 'Обнаружено новое обновление скрипта version['..AdminTools.script.version..']! Команда /update обновляет скрипт.', -1) end
		else sampAddChatMessage(tag .. 'Дополнительные модули не подгружены! Сообщите об этом разработчику, или переустановите скрипт.', -1) end
		if sampGetCurrentServerAddress() ~= '46.174.52.246' --[[ 01 SERVER ]] and sampGetCurrentServerAddress() ~= '46.174.49.170' --[[ 02 SERVER ]] then
			sampAddChatMessage(tag .. 'Я предназначен для RDS, там и буду работать.', -1)
			ScriptExport()
	 	else sampAddChatMessage("",-1) sampAddChatMessage(tag.. 'Скрипт успешно загружен. Активация: клавиша ' .. cfg.settings.open_tool .. ' или /tool', -1) sampAddChatMessage("",-1)  end
	end
	local AdminTools = nil 
	local dlstatus = nil


	local check_pass = inicfg.load(nil, 'AT//AT_FS.ini')
	if check_pass.settings.parolalogin == nil or #check_pass.settings.parolalogin < 2 then sampAddChatMessage(tag .. 'До сих пор вводите /alogin вручную?)) Автоматизируйте рутину, вводите /fs', -1) end
	local check_pass = nil

	local rules = file_exists('moonloader\\config\\AT\\rules.txt') if not rules then
		sampProcessChatInput('/reset')
	end

	local rules = io.open('moonloader\\config\\AT\\rules.txt',"r")
	if rules then for line in rules:lines() do array.pravila[ #(array.pravila) + 1] = line;end rules:close() end
	for k,v in pairs(array.pravila) do
		if v:match('%[(.+) lvl%]') then
			local v = string.gsub(v, '%[(.+) lvl%] ', "")
			local command = textSplit(u8:decode(v), " - ")[1]
			basic_command.server[command] = string.gsub( u8:decode(v), command..' %- ', "")
		end
	end
	--------------------============ АВТОМУТ =====================---------------------------------
	local AutoMute_mat = io.open('moonloader\\config\\AT\\mat.txt', "r")
	if AutoMute_mat then for line in AutoMute_mat:lines() do line = u8:decode(line) if line and #(line) > 2 then array.mat[#array.mat + 1] = line end;end AutoMute_mat:close() end
	
	local AutoMute_osk = io.open('moonloader\\config\\AT\\osk.txt', "r")
	if AutoMute_osk then for line in AutoMute_osk:lines() do line = u8:decode(line) if line and #(line) > 2 then array.osk[#array.osk + 1] = line end;end AutoMute_osk:close() end
	import("\\resource\\AT_MP.lua") 					-- подгрузка плагина для мероприятий

	func = lua_thread.create_suspended(autoonline) -- function autoonline
	func1 = lua_thread.create_suspended(wallhack) -- function wallhack
	funcadm = lua_thread.create_suspended(render_admins) -- function render admins
	local func4 = lua_thread.create_suspended(binder_key) -- binder key
	func4:run()
	if cfg.settings.wallhack then on_wallhack() func1:run() end
	if cfg.settings.autoonline then func:run() end
	if cfg.settings.render_admins then
		lua_thread.create(function()
			while not array.admins do wait(0) end
			while #(array.admins) == 0 do wait(3000) end
			array.windows.render_admins.v = true
			imgui.Process = true
		end)
		funcadm:run() 
	end

	if cfg.settings.render_players then
		lua_thread.create(function()
			sampev.onPlayerJoin = function(id, color, npc, nick)
				if not AFK and npc == false then
					lua_thread.create(function()
						wait(100)
						if sampIsPlayerConnected(id) then
							local text = '{DCDCDC}'..sampGetPlayerNickname(id)..'['..id..'] ({228B22}Подключился{DCDCDC})'
							if #array.render_players == cfg.settings.render_players_count then
								for i = 0, #array.render_players do
									if i ~= #array.render_players then array.render_players[i] = array.render_players[i + 1]
									else array.render_players[#array.render_players] = text end
								end
							else array.render_players[#array.render_players + 1] = text end
						end
					end)
				end
			end
			sampev.onPlayerQuit = function(id, reason)
				if not AFK and sampIsPlayerConnected(id) then
					local text = '{DCDCDC}'..sampGetPlayerNickname(id)..' ({FF0000}Отключился{DCDCDC})'
					if #array.render_players == cfg.settings.render_players_count then
						for i = 0, #array.render_players do
							if i ~= #array.render_players then array.render_players[i] = array.render_players[i + 1]
							else array.render_players[#array.render_players] = text end
						end
					else array.render_players[#array.render_players + 1] = text end
				end
			end 
			while true do wait(1)
				if not AFK then
					for i = 1, #array.render_players do
						renderFontDrawText(font_players, array.render_players[i], cfg.settings.render_players_x, cfg.settings.render_players_y + (i*16), 0xCCFFFFFF)
					end
				end
			end
		end)
	end


	if cfg.settings.save_radar then mem.write(sampGetBase() + 643864, 37008, 2, true) end

	mem.write(0x747FB6, 0x1, 1, true) -- [[ AntiAFK Script in GameOver ]]
	mem.write(0x74805A, 0x1, 1, true)
	mem.fill(0x74542B, 0x90, 8, true)
	mem.fill(0x53EA88, 0x90, 6, true)

	local font_watermark = renderCreateFont("Arial", 9, font.BOLD + font.BORDER + font.SHADOW) -- шрифт текста о АТ снизуу
	while true do

		if not AFK then
			-- рендер чатов 
			local mouseX, mouseY = getCursorPos() 
			for i = 1, #array.adminchat do
				local coordinateX, coordinateY = cfg.settings.position_adminchat_x, cfg.settings.position_adminchat_y + (i*15)
				if (sampIsCursorActive() and (mouseX > coordinateX and not (mouseX > coordinateX+400)) and (math.abs(mouseY - coordinateY) < 20)) or (isKeyDown(strToIdKeys(cfg.settings.key_automute)) and not (sampIsChatInputActive() or sampIsDialogActive())) then
					renderFontDrawText(font_adminchat, array.adminchat[i], coordinateX, coordinateY, 0xCCFFFFFF)
				else
					renderFontDrawText(font_adminchat, array.adminchat_minimal[i], coordinateX, coordinateY, 0xCCFFFFFF)
				end
			end
			for i = 1, #array.ears do
				local coordinateX, coordinateY = cfg.settings.position_ears_x, cfg.settings.position_ears_y + (i*15)
				if (sampIsCursorActive() and (mouseX > coordinateX and not (mouseX > coordinateX+200)) and (math.abs(mouseY - coordinateY) < 20)) or (isKeyDown(strToIdKeys(cfg.settings.key_automute)) and not (sampIsChatInputActive() or sampIsDialogActive())) then
					renderFontDrawText(font_earschat, array.ears[i], coordinateX, coordinateY, 0xCCFFFFFF)
				else
					renderFontDrawText(font_earschat, array.ears_minimal[i], coordinateX, coordinateY, 0xCCFFFFFF)
				end
			end
		end
		renderFontDrawText(font_watermark, tag..'{808080}version['..version..']', 10, sh-20, 0xCCFFFFFF)
		wait(1) -- задержка
	end
end
--------============= Инициализируем команды, указанные выше ===========================---------------------------
for k,v in pairs(basic_command.ans) do   sampRegisterChatCommand(string.sub(k,2), function(param) if #param ~= 0 then for k,v in pairs(textSplit(v, '\n')) do sampSendChat(string.gsub(v, '_', param)) end else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end

for k,v in pairs(basic_command.mute) do 
	sampRegisterChatCommand(string.sub(k.."f",2), function(param) if #param ~= 0 then sampSendChat(string.gsub(	string.gsub(v, '/mute', '/muteoff'), '_', param) ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1)  end end)
	sampRegisterChatCommand(string.sub(k,2), function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param) ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1)  end end) end

for k,v in pairs(basic_command.jail) do 
	sampRegisterChatCommand(string.sub(k.."f",2), function(param) if #param ~= 0 then sampSendChat(string.gsub(	string.gsub(v, '/jail', '/jailakk'), '_', param) ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1)  end end)
	sampRegisterChatCommand(string.sub(k,2), function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param) ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1)  end end) end

for k,v in pairs(basic_command.rmute) do 
	sampRegisterChatCommand(string.sub(k.."f",2), function(param) if #param ~= 0 then sampSendChat(string.gsub(	string.gsub(v, '/rmute', '/rmuteoff'), '_', param) ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1)  end end)
	sampRegisterChatCommand(string.sub(k,2), function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end

for k,v in pairs(basic_command.kick) do sampRegisterChatCommand(string.sub(k,2), function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end

for k,v in pairs(basic_command.ban) do
	sampRegisterChatCommand(string.sub(k.."f",2), function(param) if #param ~= 0 then sampSendChat(string.gsub(	string.gsub (string.gsub(v , '/siban', '/banoff') ,'/iban', '/banoff'), '_', param) ) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1)  end end)
	sampRegisterChatCommand(string.sub(k,2), function(param)  if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end

for k,v in pairs(basic_command.help) do sampRegisterChatCommand(string.sub(k,2), function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. 'Вы не указали значение.', -1) end end) end

for k,v in pairs(cfg.my_command) do
	local v = string.gsub(v, '\\n','\n')
	basic_command.prochee['/'..k] = v
	sampRegisterChatCommand(k, function(param) 
		lua_thread.create(function() 
			for a,b in pairs(textSplit(string.gsub(v, '_', param), '\n')) do
				if #b ~= 0 then
					if b:match('wait(%(%d+)%)') then 
						wait(tonumber(b:match('%d+') .. '000'))
					elseif b:match('nick%((.+)%)') then
						local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						local parametr = tonumber(b:match('nick%((.+)%)'))
						if parametr and sampIsPlayerConnected(parametr) then
							sampSendChat(string.gsub(b, 'nick%((.+)%)', sampGetPlayerNickname(parametr)))
						else
							sampAddChatMessage(tag .. 'ID игрока указан неверно.', -1)
							break
						end
					else sampSendChat(b) end
				end
			end 
		end) 
	end) 
end

for k,v in pairs(cfg.custom_hints) do basic_command.custom[k] = v end -- custom hints

sampRegisterChatCommand('prfma', function(param) if #param ~= 0 then  sampSendChat('/prefix ' .. param .. ' Мл.Администратор ' .. cfg.settings.prefixma) else sampAddChatMessage(tag ..'Вы не указали значение.', -1) end end)
sampRegisterChatCommand('prfa', function(param) if #param ~= 0 then   sampSendChat('/prefix '  .. param .. ' Администратор ' .. cfg.settings.prefixa) else sampAddChatMessage(tag ..'Вы не указали значение.', -1) end end)
sampRegisterChatCommand('prfsa', function(param) if #param ~= 0 then  sampSendChat('/prefix ' .. param .. ' Ст.Администратор ' .. cfg.settings.prefixsa) else sampAddChatMessage(tag ..'Вы не указали значение.', -1) end end)

sampRegisterChatCommand('prfpga', function(param) if #param ~= 0 then sampSendChat('/prefix '.. param .. ' Помощник.Глав.Администратора ' .. color()) else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end end)
sampRegisterChatCommand('prfzga', function(param) if #param ~= 0 then sampSendChat('/prefix ' ..param .. ' Зам.Глав.Администратора ' .. color()) else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end end)
sampRegisterChatCommand('prfga', function(param) if #param ~= 0 then  sampSendChat('/prefix ' .. param .. ' Главный-Администратор ' .. color()) else sampAddChatMessage(tag .. 'Вы не указали значение', -1) end end)

sampRegisterChatCommand('spawncars', function(param)
	if not ((#param == 1 or #param == 2) and tonumber(param)) then
		sampAddChatMessage(tag .. 'Вы не указали время, потому оно было выбрано по умолчанию - 15 секунд.', -1)
		param = 15
	end
	local random = math.random(2,17)
	local random_2 = math.random(9,15)
	sampSendChat('/mess '..random..' --------===================| Spawn Auto |================-----------')
	sampSendChat('/mess '..random_2..' Многоуважаемые дрифтеры и дрифтерши')
	sampSendChat('/mess '..random_2..' Через '..param..' секунд пройдёт респавн всего транспорта на сервере.')
	sampSendChat('/mess '..random_2..' Займите свои супер кары во избежания потери :3')
	sampSendChat('/mess '..random..' --------===================| Spawn Auto |================-----------')
	sampSendChat('/delcarall')
	sampSendChat('/spawncars '..param)
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
sampRegisterChatCommand('hints', function(param)
	if not param:match("(.+) (.+)") then sampAddChatMessage(tag .. 'Форма: [Наименнование команды] [действие]', -1) return end
	local param1 = textSplit(param, " ")
	if not param1[1]:match('/') then sampAddChatMessage(tag .. 'Первая идет команда, пример /az', -1) return end;
	if param1[2] == '-' then
		if cfg.custom_hints[param1[1]] then
			cfg.custom_hints[param1[1]] = nil 
			save()
			sampAddChatMessage(tag .. 'Подсказка на команду ' .. param1[1] .. ' успешно удалена', -1)
			basic_command.custom[param1[1]] = nil;
		else sampAddChatMessage(tag .. 'Команда не обнаружена, попробуйте еще раз.', -1) end
		return;
	end;
	local param2 = string.gsub(param, param1[1].." ", "")
	cfg.custom_hints[param1[1]] = param2
	sampAddChatMessage(param1[1] .. ' -> ' .. param2,-1)
	sampAddChatMessage(tag .. 'Если желаете удалить эту, или другую команду, введите [Команда] -, пример: /az -',-1)
	basic_command.custom[param1[1]] = param2
	save()
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
sampRegisterChatCommand('c', function(param)
	if param:find('(%d+) (.+)') then
		sampSendChat('/ans ' .. param)
		return false
	end
	if (not sampIsPlayerConnected(tonumber(param))) or (not array.flood.message[param]) then sampAddChatMessage(tag .. 'ID игрока указан неверно, возможно игрок просто не писал ничего в чат, или у вас выключен автомут.', -1) return false end
	sampev.onShowDialog(2349, DIALOG_STYLE_INPUT, 'tipa title', 'button1', 'button2', 'Игрок: '..sampGetPlayerNickname(param)..'\n\n\nЖалоба:' .. array.flood.message[param])
	lua_thread.create(function()
		showCursor(true,false)
		while not array.windows.fast_report.v do wait(300) end
		while array.windows.fast_report.v and not (array.answer.rabotay or array.answer.uto4 or array.answer.nakajy or array.answer.customans or array.answer.slejy or array.answer.jb or array.answer.ojid or array.answer.moiotvet or array.answer.uto4id or array.answer.nakazan or array.answer.otklon or array.answer.peredamrep) do wait(200) end
		showCursor(false,false)
		if not sampev.onShowDialog(2350, DIALOG_STYLE_INPUT, 'aboba', 'Действие', 'Назад', 'aboba') and peremrep then
			if array.answer.control_player then sampSendChat('/re ' .. autorid)
			elseif array.answer.slejy then sampSendChat('/re ' .. reportid)
			elseif array.answer.peredamrep then sampSendChat('/a ' .. autor .. '[' .. autorid .. '] | ' .. textreport) 
			elseif array.answer.moiotvet then sampSendChat('/ans ' .. param .. ' ' .. peremrep)
			elseif array.answer.customans then sampSendChat('/ans ' .. param .. ' ' .. array.answer.customans) end
			if array.answer.slejy and not copies_player_recon and tonumber(autorid) and cfg.settings.answer_player_report then
				local copies_report_id = reportid
				copies_player_recon = autorid
				while not array.windows.recon_menu.v do wait(100) end
				while array.windows.recon_menu.v do wait(2000) end
				if copies_player_recon and copies_report_id == control_player_recon then
					if sampIsPlayerConnected(copies_player_recon) then
						imgui.Process, array.windows.answer_player_report.v = true, true
						for i = 0, 11 do wait(500) if not copies_player_recon or (copies_report_id ~= control_player_recon) then break end end
						if array.windows.answer_player_report.v then array.windows.answer_player_report.v = false copies_player_recon = nil end
					else sampAddChatMessage(tag .. 'Игрок, написавший репорт, находится вне сети.', -1) end
				end
			else copies_player_recon = nil end
		else array.windows.fast_report.v = false end
	end)
end)
sampRegisterChatCommand('sbanip', function(param)
	if not param:match('(.+) (.+) (.+)') then sampAddChatMessage(tag .. '/sbanip [Игрок] [Дни] [Причина]', -1) return false end
	lua_thread.create(function()
		local text = textSplit(param, ' ')
		local reason = string.gsub(param, text[1] .. ' ' .. text[2] .. ' ', '')
		find_ip_player = true
		sampSendChat('/offstats ' .. text[1])
		while not regip do wait(200) end
		wait(1000)
		sampSendChat('/banoff ' .. text[1] .. ' ' .. text[2] .. ' ' .. reason)
		wait(1000)
		sampSendChat('/banip ' .. regip .. ' ' .. text[2] .. ' ' .. reason)
		wait(1000)
		if lastip then -- на случай если этого пункта не будет в диалоге
			sampSendChat('/banip ' .. lastip .. ' ' .. text[2] .. ' ' .. reason)
		end
		find_ip_player, regip, lastip = false, nil, nil
	end)
end)
sampRegisterChatCommand('control_afk', function(param)
	if not tonumber(param) then sampAddChatMessage(tag .. 'Значение указано неверно. Введите кол-во минут. 0 = выкл.', -1) return false end
	local param = tonumber(param)
	if param and param >= 0 then
		if param == 0 then 
			cfg.settings.control_afk = false
			sampAddChatMessage(tag .. 'Автоматический выход из игры деактивирован.', -1)
		else 
			cfg.settings.control_afk = param
			sampAddChatMessage(tag .. 'АТ автоматически закроет игру, если вы будете находиться в AFK ' .. param .. '+ минут.', -1)
		end
		save()
	else sampAddChatMessage(tag .. 'Значение указано неверно. Введите кол-во минут. 0 = выкл.', -1) end
end)
sampRegisterChatCommand('up', function(param)
	if sampIsDialogActive() then return false end
	if #param == 0 then sampAddChatMessage(tag .. '/up [id] [0/1 без очистки/с очисткой]', -1) return false end
	local param = textSplit(param,' ')
	if not tonumber(param[2]) then param[2] = 0 end
	if not cfg.settings.auto_cc then
		sampSendChat('/mute ' .. param[1] .. ' 1000 Упом. сторонних проектов')
	else
		lua_thread.create(function()
			sampSendChat('/mute ' .. param[1] .. ' 1000 Упом. сторонних проектов')
			wait(3000)
			sampSendChat('/cc')
			sampAddChatMessage(tag .. 'Чат очищен.',-1)
		end)
	end
end)
sampRegisterChatCommand('autoban', function(param)
	local param1 = textSplit(param, ' ')
	if not param1[1] then param1[1] = "4" end
	local param1 = param1[1]
	local param2 = string.gsub(param, param1..' ', '')
	if param1 == "0" then
		local text = false
		for k,v in pairs(cfg.auto_ban) do
			if tostring(v) == param2 then
				text = k
			end
		end
		if text then
			sampAddChatMessage(tag ..'Текст ' ..param2..' было удалено из списка', -1)
			table.remove( cfg.auto_ban,k )
		else
			sampAddChatMessage(tag ..'Данный текст не найден в списке', -1)
		end
	elseif param1 == "1" then
		sampAddChatMessage(tag ..'Текст ' ..param2..' было добавлено для поиска в чате и автоматической блокировки за рекламу', -1)
		table.insert( cfg.auto_ban, tostring(param2) )
	elseif param1 == '2' then
		sampAddChatMessage(tag ..'Словарь: ', -1)
		for k,v in pairs(cfg.auto_ban) do
			sampAddChatMessage(v,-1)
		end
	else
		sampAddChatMessage(tag ..'/autoban [0-2] text',-1)
		sampAddChatMessage(tag ..'0 - удалить слово, 1 - добавить, 2 - список', -1)
	end
	save()
end)
sampRegisterChatCommand('wh' , function()
	if not cfg.settings.wallhack then
		cfg.settings.wallhack = true
		save()
		array.checkbox.check_WallHack = imgui.ImBool(cfg.settings.wallhack),
		on_wallhack()
		sampAddChatMessage(tag ..'Функция WallHack успешно активирована', -1)
	else
		cfg.settings.wallhack = false
		save()
		array.checkbox.check_WallHack = imgui.ImBool(cfg.settings.wallhack),
		off_wallhack()
		sampAddChatMessage(tag ..'Функция WallHack была деактивирована', -1)
	end
end)
sampRegisterChatCommand('tool', function()
	for i = 1, 512 do  -- [[[ FIX BUG INPUT TEXT IMGUI  ]]]
		imgui:GetIO().KeysDown[i] = false
	end
	for i = 1, 5 do
		imgui:GetIO().MouseDown[i] = false
	end
	imgui:GetIO().KeyCtrl = false
	imgui:GetIO().KeyShift = false
	imgui:GetIO().KeyAlt = false
	imgui:GetIO().KeySuper = false  
	imgui.Process = true
	array.windows.menu_tools.v = not array.windows.menu_tools.v
	if array.windows.recon_menu.v then 	-- активация курсора если рекон меню активно
		lua_thread.create(function()
			setVirtualKeyDown(70, true)
			wait(150)
			setVirtualKeyDown(70, false)
		end)
	end
end)
sampRegisterChatCommand('spp', function()
	lua_thread.create(function() 
		for _, id in pairs(playersToStreamZone()) do 
			wait(500) 
			sampSendChat('/aspawn ' .. id) 
		end 
	end)
end)
sampRegisterChatCommand('ahelp', function()
	array.windows.pravila.v = not array.windows.pravila.v
	imgui.Process = array.windows.pravila.v
end)
sampRegisterChatCommand('update', function() download_update() end)
sampRegisterChatCommand('reset', function()
	lua_thread.create(function()
		while sampIsDialogActive() do wait(0) end
		sampSendChat('/access') 		-- проверка доступов
		while not sampIsDialogActive(8991) do wait(0) end
		sampCloseCurrentDialogWithButton(0)
	end)
	local dlstatus = require('moonloader').download_status
	imgui.Process = false
	showCursor(false,false)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", 'moonloader//config//AT//rules.txt', function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
			sampAddChatMessage(tag..'Правила загружены.', -1) 
		end 
	end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/mat.txt", 'moonloader//config//AT//mat.txt', function(id, status) 
		if  status == dlstatus.STATUS_ENDDOWNLOADDATA then  
			sampAddChatMessage(tag..'Автомут на маты загружены.', -1) 
		end 
	end)  
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/osk.txt", 'moonloader//config//AT//osk.txt', function(id, status) 
		if  status == dlstatus.STATUS_ENDDOWNLOADDATA then 
			sampAddChatMessage(tag..'Автомут на оскорбления загружен.', -1) 
		end 
	end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_main.ini", 'moonloader//config//AT//AT_main.ini', function(id, status) 
		if  status == dlstatus.STATUS_ENDDOWNLOADDATA then 
			sampAddChatMessage(tag..'Настройки АТ подгружены.', -1) 
		end 
	end)
	lua_thread.create(function()
		wait(5000)
		sampAddChatMessage(tag ..'Выполняется перезагрузка..', -1)
		reloadScripts()
	end)
end)
sampRegisterChatCommand('tr', function()
	if cfg.settings.atr then
		if not tr then sampAddChatMessage('{37aa0d}[Информация] {FFFFFF}Вы{32CD32} включили режим TakeReport by AT.', 0x32CD32)
		else sampAddChatMessage('{37aa0d}[Информация] {FFFFFF}Вы {FF0000}выключили режим TakeReport.', 0x32CD32) end
		tr = not tr
	else sampSendChat('/tr') end
end)
sampRegisterChatCommand('ears', function()
	if sampIsDialogActive() then return false end
	sampSendChat('/ears')
	if array.checkbox.check_render_ears.v then
		array.ears = {}
		array.ears_minimal = {}
		array.checkbox.check_render_ears.v = false
		print('Сканирование ЛС успешно активировано.', -1)
	else
		array.checkbox.check_render_ears.v = true
		print('Сканирование ЛС успешно активировано.', -1)
	end
end)
--======================================= РЕГИСТРАЦИЯ КОМАНД ====================================--
function imgui.OnDrawFrame()
	if not array.windows.render_admins.v and not array.windows.menu_tools.v and not array.windows.pravila.v and not array.windows.fast_report.v and not array.windows.recon_menu.v and not array.windows.answer_player_report.v and not array.windows.menu_chatlogger.v then
		showCursor(false,false)
		if cfg.settings.render_admins then 	array.windows.render_admins.v = true
		else imgui.Process = false end
	end
	if array.windows.menu_tools.v then -- КНОПКИ ИНТЕРФЕЙСА F3
		array.windows.render_admins.v = false
		imgui.ShowCursor = true
		if wasKeyPressed(VK_ESCAPE) then array.windows.menu_tools.v = false end
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
		imgui.Begin('xX     Admin Tools [AT]     Xx', array.windows.menu_tools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.SameLine()
		imgui.SetCursorPosX(80)
		imgui.BeginGroup()
			if imgui.Button(fa.ICON_ADDRESS_BOOK, imgui.ImVec2(30, 30)) then 		menu = 'Главное меню' end imgui.SameLine()
			if imgui.Button(fa.ICON_COGS, imgui.ImVec2(30, 30)) then 				menu = 'Дополнительные функции' end imgui.SameLine()
			if imgui.Button(fa.ICON_CALENDAR_CHECK_O, imgui.ImVec2(30, 30)) then 	menu = 'Быстрые клавиши' end imgui.SameLine()
			if imgui.Button(fa.ICON_PENCIL_SQUARE, imgui.ImVec2(30, 30)) then 		menu = 'Блокнот' end imgui.SameLine()
			if imgui.Button(fa.ICON_RSS, imgui.ImVec2(30, 30)) then 				menu = 'Флуды' end imgui.SameLine()
			if imgui.Button(fa.ICON_BOOKMARK, imgui.ImVec2(30, 30)) then 			menu = 'Быстрые ответы' end imgui.SameLine()
			if imgui.Button(fa.ICON_CLOUD, imgui.ImVec2(30, 30)) then 				menu = 'Автомут' end imgui.SameLine()
			if imgui.Button(fa.ICON_SERVER, imgui.ImVec2(30,30)) then				menu = 'smartautomute' end imgui.SameLine()
			if imgui.Button(fa.ICON_INFO_CIRCLE, imgui.ImVec2(30, 30)) then array.windows.menu_tools.v = false sampProcessChatInput('/ahelp') end
		imgui.EndGroup()
		imgui.SetCursorPosY(65)
        imgui.Separator()
		imgui.BeginGroup()
			if menu == 'Главное меню' then
				imgui.SetCursorPosX(8)
				if imadd.ToggleButton("##autoonline", array.checkbox.check_autoonline) then
					cfg.settings.autoonline = not cfg.settings.autoonline
					save()
					if not cfg.settings.autoonline then
						func:terminate()
					else func:run() end
				end
				imgui.SameLine()
				imgui.Text(u8'Авто-Выдача за онлайн')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##inputhelper", array.checkbox.inputhelper) then
					if cfg.settings.input_helper then func_inputhelper:terminate() else func_inputhelper:run() end
					cfg.settings.inputhelper = not cfg.settings.inputhelperc
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Перевод команд')
				if imadd.ToggleButton("##WallHack", array.checkbox.check_WallHack) then
					if cfg.settings.wallhack then off_wallhack() func1:terminate() else on_wallhack() func1:run() end
					cfg.settings.wallhack = not cfg.settings.wallhack
					save()
				end
				imgui.SameLine()
				imgui.Text('WallHack')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton('##find_form', array.checkbox.check_find_form) then
					cfg.settings.find_form  = not cfg.settings.find_form
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Слежка за формами')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_COG.."##aaa", imgui.ImVec2(21,21)) then
					imgui.OpenPopup('slejform')
				end
				if imgui.BeginPopup('slejform') then
					if imgui.SliderInt('##Sliderы', array.checkbox.time_form, 6, 20) then
						cfg.settings.time_form = array.checkbox.time_form.v
						save()
					end
					if array.checkbox.check_find_form.v then
						imgui.Text(u8'Автоматическое принятие форм ')
						imgui.SameLine()
						if imgui.Checkbox('##autoaccept', array.checkbox.autoaccept_form) then
							cfg.settings.autoaccept_form = not cfg.settings.autoaccept_form
							save()
						end
						imgui.Tooltip(u8'Предупреждение: ответственность несете Вы')
					end
					imgui.EndPopup()
				end
				if imgui.Button(fa.ICON_COG, imgui.ImVec2(30,20)) then imgui.OpenPopup('check_AM') end
				imgui.SameLine()
				imgui.Text(u8'Автовыдача мута')
				if imgui.BeginPopup('check_AM') then
					if imadd.ToggleButton('##automute', array.checkbox.check_automute) then
						if cfg.settings.automute and cfg.settings.smart_automute then
							cfg.settings.smart_automute = false
							array.checkbox.check_smart_automute.v = false
						end
						if cfg.settings.forma_na_mute then
							cfg.settings.automute = false
							array.checkbox.check_automute.v = false
							sampAddChatMessage(tag .. 'У вас включены автоформы на мут. Во избежания флуда совмещать эти функции запрещено.', -1)
						else 
							cfg.settings.automute  = not cfg.settings.automute 
						end
						save()
					end
					imgui.SameLine()
					imgui.Text(u8'Вкл/Выкл')
					if cfg.settings.automute then
						if imgui.RadioButton(u8"Обычный режим", array.checkbox.option_automute, 0) then cfg.settings.option_automute=0 save() end
						if imgui.RadioButton(u8'AutoMute Premium', array.checkbox.option_automute, 1) then
							local cfg_mp = inicfg.load({}, 'AT//AT_MP.ini')
							if cfg_mp.AT_MP.access_automute then cfg.settings.option_automute = 1
							else 
								sampAddChatMessage(tag .. 'Данная функция доступна только внимательным администраторам.', -1)
								sampAddChatMessage(tag .. 'Как доказать, что ты достоен этой опции?',-1)
								sampAddChatMessage(tag .. 'Выдай 150 мутов за 1 день, тогда опция станет доступна',-1)
								cfg.settings.option_automute = 0
								array.checkbox.option_automute.v=0
								array.windows.menu_tools.v = false
							end
							cfg_mp = nil
							save()
						end
					end
					imgui.EndPopup()
				end
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##NotifyPlayer", array.checkbox.check_answer_player_report) then
					if not cfg.settings.on_custom_recon_menu then
						sampAddChatMessage(tag .. 'Данная функция работает только с кастом рекон меню', -1)
						cfg.settings.answer_player_report = false
						array.checkbox.check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report)
					else cfg.settings.answer_player_report = not cfg.settings.answer_player_report end
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Уведомление игрока')
				if imadd.ToggleButton("##SmartAutomute", array.checkbox.check_smart_automute) then
					if not cfg.settings.automute then
						if cfg.settings.forma_na_mute then
							cfg.settings.automute = false
							cfg.settings.smart_automute = false
							array.checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
							array.checkbox.check_smart_automute = imgui.ImBool(cfg.settings.smart_automute)
							sampAddChatMessage(tag .. 'У вас включены автоформы на мут. Во избежания флуда совмещать эти функции запрещено.', -1)
						else
							cfg.settings.automute  = not cfg.settings.automute
							array.checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
						end
					end
					cfg.settings.smart_automute = not cfg.settings.smart_automute
					save()
				end
				imgui.Tooltip(u8'Оскорбление родных, упоминание сторонних проектов, флуд детектор.')
				imgui.SameLine()
				imgui.Text(u8'Умный автомут')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##NotifyReport", array.checkbox.check_notify_report) then
					if not cfg.settings.notify_report then imgui.OpenPopup('1') end
					cfg.settings.notify_report = not cfg.settings.notify_report
					save()
				end
				if imgui.BeginPopup('1') then
					imgui.Text(u8'Громкость оповещения')
					if imgui.SliderInt('##sound', array.checkbox.sound_report, 0, 100) then
						cfg.settings.sound_report = array.checkbox.sound_report.v
						save()
					end
					imgui.EndPopup()
				end
				imgui.SameLine()
				imgui.Text(u8'Уведомление о репорте')
				if imadd.ToggleButton("##FastReport", array.checkbox.check_on_custom_answer) then
					cfg.settings.on_custom_answer = not cfg.settings.on_custom_answer
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Ответ на репорт')
				imgui.SameLine()
				imgui.SetCursorPosX(190)
				if imgui.Button(fa.ICON_COG.."##aa", imgui.ImVec2(21,21)) then
					 imgui.OpenPopup('option_ans')
				end
				if imgui.BeginPopup('option_ans') then
					if imgui.Button(u8'Назначить цвет репорта', imgui.ImVec2(300,24)) then
						if not html_color then
							html_color = {}
							local file_color = io.open('moonloader\\' .. "\\resource\\skin\\color.txt","r")
							if file_color then for line in file_color:lines() do html_color[#html_color + 1] = u8:decode(line);end file_color:close() end
						end
						imgui.OpenPopup('color')
						sampAddChatMessage(tag .. 'Подсказка, /color_report *', -1)
						sampAddChatMessage(tag .. 'Делает цвет ответа разноцветным.', -1)
					end
					if imgui.BeginPopup('color') then
						for i = 1, 256 do 
							imgui.TextColoredRGB(u8(html_color[i]))
							if imgui.IsItemClicked(0) then
								local color = '{'..string.sub(string.sub(html_color[i], 1, 7), 2)..'}'
								cfg.settings.color_report = color
								save()
								sampAddChatMessage(tag .. color ..'Новый цвет', -1)
							end
							if i%8~=0 then imgui.SameLine() end 
						end
						imgui.EndPopup()
					end
					if cfg.settings.color_report and imgui.Button(u8'Удалить цвет репорта', imgui.ImVec2(300,24)) then
						cfg.settings.color_report = nil
						save()
					end
					imgui.EndPopup()
				end
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##weaponhack", array.checkbox.check_weapon_hack) then
					cfg.settings.weapon_hack = not cfg.settings.weapon_hack
					save()
				end
				imgui.Tooltip(u8'Автоматически пробивает /iwep новых варнингов на чит-оружие\nМожет вызывать проблемы с открытием диалога\nПри наличии чита - автоматически банит\nПомните, что впервую очередь за все блокировки ответственность несете вы.\nСкриншот сохраняет в:\nC:\\Users\\User\\Документы\\GTA San Andreas User Files\\screens')
				imgui.SameLine()
				imgui.Text(u8'Реакция на чит-оружие')
				if imadd.ToggleButton("##autoupdate", array.checkbox.active_chat) then
					cfg.settings.active_chat = not cfg.settings.active_chat
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Чат-подсказки')
				imgui.SameLine()
				imgui.SetCursorPosX(190)
				if imgui.Button(fa.ICON_ARROWS..'##8') then
					imgui.OpenPopup('size_chat')
				end
				if imgui.BeginPopup('size_chat') then
					if imgui.SliderInt('##Slider8', array.checkbox.size_chat, 8, 18) then
						cfg.settings.size_text_f6 = array.checkbox.size_chat.v
						save()
						sampSetChatInputEnabled(true)
						font_chat = renderCreateFont("Arial", cfg.settings.size_text_f6, font.BOLD + font.BORDER + font.SHADOW) 
					end
					if imgui.Button(u8'Назначить цвет', imgui.ImVec2(272,24)) then
						if not html_color then
							html_color = {}
							local file_color = io.open('moonloader\\' .. "\\resource\\skin\\color.txt","r")
							if file_color then for line in file_color:lines() do html_color[#html_color + 1] = u8:decode(line);end file_color:close() end
						end
						imgui.OpenPopup('color')
					end
					if imgui.BeginPopup('color') then
						for i = 1, 256 do 
							imgui.TextColoredRGB(u8(html_color[i]))
							if imgui.IsItemClicked(0) then
								local color = '{'..string.sub(string.sub(html_color[i], 1, 7), 2)..'}'
								cfg.settings.color_chat = color
								save()
								sampAddChatMessage(tag .. color ..'Новый цвет', -1)
							end
							if i%8~=0 then imgui.SameLine() end 
						end
						imgui.EndPopup()
					end
					imgui.EndPopup()
				end
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##AdminChat", array.checkbox.check_admin_chat) then
					if cfg.settings.admin_chat then array.adminchat, array.adminchat_minimal = {}, {} end
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
					if imgui.SliderInt('##Slider3', array.checkbox.selected_adminchat, 8, 15) then
						cfg.settings.size_adminchat = array.checkbox.selected_adminchat.v
						save()
						font_adminchat = renderCreateFont("Calibri", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW)
					end
					imgui.CenterText(u8'Кол-во строк: ')
					if imgui.SliderInt('##Slider4', array.checkbox.selected_adminchat2, 3, 20) then
						cfg.settings.strok_admin_chat = array.checkbox.selected_adminchat2.v
						save()
						if #array.adminchat > cfg.settings.strok_admin_chat then for i = cfg.settings.strok_admin_chat, #array.adminchat do array.adminchat_minimal[i] = nil array.adminchat[i] = nil end end
					end
					if imgui.Button(u8'Изменить позицию',imgui.ImVec2(140,24)) then
						lua_thread.create(function()
							if #array.adminchat < 1 then array.adminchat[1], array.adminchat_minimal[1] = 'Тестовое сообщение для видимости новой позиции.', 'Тестовое сообщение для видимости новой позиции.' end 
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
					if imgui.Button(u8'Сбросить чат',imgui.ImVec2(125, 24)) then array.adminchat, array.adminchat_minimal= {}, {} end
					imgui.EndPopup()
				end
				if imadd.ToggleButton("##render/admins", array.checkbox.check_render_admins) then
					if cfg.settings.render_admins then
						array.admins = {}
						array.windows.render_admins.v = false
						funcadm:terminate()
					else
						funcadm:run()
					end
					cfg.settings.render_admins = not cfg.settings.render_admins
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Рендер /admins')
				imgui.SameLine()
				imgui.SetCursorPosX(190)
				if imgui.Button(fa.ICON_ARROWS..'##4') then
					if cfg.settings.render_admins then
					lua_thread.create(function()
						array.windows.menu_tools.v = false
						array.windows.render_admins.v = true
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
				if imadd.ToggleButton("##CustomReconMenu", array.checkbox.check_on_custom_recon_menu) then
					if cfg.settings.on_custom_recon_menu and cfg.settings.answer_player_report then
						cfg.settings.answer_player_report = false
						save()
						array.checkbox.check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report)
					end
					cfg.settings.on_custom_recon_menu = not cfg.settings.on_custom_recon_menu
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Кастом рекон меню')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_COG..'##5') then imgui.OpenPopup('settings_recon') end
				if imgui.BeginPopup('settings_recon') then
					imgui.Text(u8'Сохранять радар в реконе') 
					imgui.SameLine()
					if imadd.ToggleButton("##radar", array.checkbox.radar) then
						cfg.settings.save_radar = not cfg.settings.save_radar
						save()
					end
					imgui.Tooltip(u8'Внесенные изменения требуют перегрузку игры')
					if imgui.Button(u8'Настроить позицию') then
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
					end
					imgui.EndPopup()
				end
				if imadd.ToggleButton("##virtualkey", array.checkbox.check_keysync) then
					cfg.settings.keysync = not cfg.settings.keysync
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Виртуал. клавиши')
				imgui.SameLine()
				imgui.SetCursorPosX(190)
				if imgui.Button(fa.ICON_ARROWS..'##1') then
					if array.windows.recon_menu.v then
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
				if imadd.ToggleButton("##renderEars", array.checkbox.check_render_ears) then
					if array.checkbox.check_render_ears.v then array.ears = {} array.ears_minimal = {} end
					array.checkbox.check_render_ears.v = not array.checkbox.check_render_ears.v
					sampProcessChatInput('/ears')
				end
				imgui.SameLine()
				imgui.Text(u8'Рендер /ears')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_ARROWS..'##2') then imgui.OpenPopup('settings_ears') end
				if imgui.BeginPopup('settings_ears') then  
					imgui.CenterText(u8'Размер: ')
					if imgui.SliderInt('##Slider1', array.checkbox.selected_ears, 8, 15) then
						cfg.settings.size_ears = array.checkbox.selected_ears.v
						save()
						font_earschat = renderCreateFont("Calibri", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)
					end
					imgui.CenterText(u8'Кол-во строк: ')
					if imgui.SliderInt('##Slider2', array.checkbox.selected_ears2, 3, 20) then
						cfg.settings.strok_ears = array.checkbox.selected_ears2.v
						save()
						if #array.ears > cfg.settings.strok_ears then
							array.ears = {}
							array.ears_minimal = {}
						end
					end
					if imgui.Button(u8'Изменить позицию',imgui.ImVec2(140,24)) then
						if array.checkbox.check_render_ears.v then
							lua_thread.create(function()
								if #array.ears < 1 then array.ears[#array.ears] = 'Тестовое сообщение для видимости новой позиции.' array.ears_minimal[#array.ears_minimal] = 'Тестовое сообщение для видимости новой позиции.' end 
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
					if imgui.Button(u8'Сбросить чат',imgui.ImVec2(125, 24)) then array.ears = "" end
					imgui.EndPopup()
				end
				if imadd.ToggleButton("##timetext", imgui.ImBool(cfg.settings.timetext)) then
					if cfg.settings.timetext then func_timetext:terminate() else func_timetext:run() end
					cfg.settings.timetext = not cfg.settings.timetext
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Нижний текст') 
				imgui.SameLine()
				imgui.SetCursorPosX(190)
				if imgui.Button(fa.ICON_COG..'##5s', imgui.ImVec2(21,21)) and cfg.settings.timetext then imgui.OpenPopup('text') end
				if imgui.BeginPopup('text') then
					imgui.Text(u8'Текст вместо времени по умолчанию:')
					if imgui.InputText("##text", array.buffer.customtimetext) then
						array.buffer.customtimetext.v = string.gsub(string.gsub( array.buffer.customtimetext.v, '%[', ''), '%]', '')
						cfg.settings.customtimetext = u8:decode(array.buffer.customtimetext.v)
						save()
						func_timetext:terminate()
						func_timetext:run()
					end
					if imgui.SliderInt('##Slider5', array.checkbox.razmer_text, 8, 18) then
						cfg.settings.timetext_razmer = array.checkbox.razmer_text.v
						save()
						font_timetext = renderCreateFont("Arial", cfg.settings.timetext_razmer, font.BOLD + font.BORDER + font.SHADOW) -- время снизу
					end
					if imgui.Button(u8'Изменить месторасположение', imgui.ImVec2(272,24)) then
						lua_thread.create(function()
							sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
							sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
							local old_pos_x, old_pos_y = cfg.settings.timetext_pos_x, cfg.settings.timetext_pos_y
							while true do
								showCursor(true,true)
								cfg.settings.timetext_pos_x, cfg.settings.timetext_pos_y = getCursorPos()
								if wasKeyPressed(VK_RETURN) then save() break end
								if wasKeyPressed(VK_ESCAPE) then cfg.settings.timetext_pos_x = old_pos_x cfg.settings.timetext_pos_y = old_pos_y break end
								wait(1)
							end
							showCursor(false,false)
						end)
						array.windows.menu_tools.v = false
					end
					if imgui.Button(u8'Добавить цвет', imgui.ImVec2(272,24)) then
						if not html_color then
							html_color = {}
							local file_color = io.open('moonloader\\' .. "\\resource\\skin\\color.txt","r")
							if file_color then for line in file_color:lines() do html_color[#html_color + 1] = u8:decode(line);end file_color:close() end
						end
						imgui.OpenPopup('color_text')
					end
					if imgui.BeginPopup('color_text') then
						for i = 1, 256 do 
							imgui.TextColoredRGB(u8(html_color[i]))
							if imgui.IsItemClicked(0) then
								local color = '{'..string.sub(string.sub(html_color[i], 1, 7), 2)..'}'
								cfg.settings.customtimetext = cfg.settings.customtimetext .. color
								array.buffer.customtimetext.v = u8(cfg.settings.customtimetext)
								save()				
								sampAddChatMessage(tag .. color ..'Добавлен цвет', -1)
							end
							if i%8~=0 then imgui.SameLine() end 
						end
						imgui.EndPopup()
					end
					imgui.EndPopup()
				end
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton('##timenakaz', array.checkbox.time_nakazanie) then
					cfg.settings.time_nakazanie = not cfg.settings.time_nakazanie
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'Время наказаний')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_ARROWS..'##2235') then
					lua_thread.create(function()
						sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
						sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
						local old_pos_x, old_pos_y = cfg.settings.time_nakazanie_posx, cfg.settings.time_nakazanie_posy
						while true do
							showCursor(true,true)
							cfg.settings.time_nakazanie_posx, cfg.settings.time_nakazanie_posy = getCursorPos()
							if wasKeyPressed(VK_RETURN) then save() break end
							if wasKeyPressed(VK_ESCAPE) then cfg.settings.time_nakazanie_posx, cfg.settings.time_nakazanie_posy = old_pos_x, old_pos_y break end
							wait(1)
							renderFontDrawText(font_adminchat, 'До выдачи следующего наказания: 0/6 сек.', cfg.settings.time_nakazanie_posx, cfg.settings.time_nakazanie_posy, 0xCCFFFFFF)
						end
						showCursor(false,false)
					end)
					array.windows.menu_tools.v = false
				end
				if imadd.ToggleButton('##renderplayers', array.checkbox.render_players) then
					cfg.settings.render_players = not cfg.settings.render_players
					save()
					imgui.Process = false
					sampAddChatMessage(tag .. 'Выполняю инициализацию функции...', -1)
					lua_thread.create(function()
						wait(1500)
						thisScript():reload()
					end)
				end
				imgui.Tooltip(u8'Требуется перезагрузка.\nВо имя оптимизации.')
				imgui.SameLine()
				imgui.Text(u8'Входы/Выходы')
				imgui.SameLine()
				imgui.SetCursorPosX(190)
				if imgui.Button(fa.ICON_ARROWS..'##22w35') then imgui.OpenPopup('in/out') end
				if imgui.BeginPopup('in/out') then
					imgui.CenterText(u8'Размер текста')
					if imgui.SliderInt('##adwad2aw', array.checkbox.render_players_size, 6,14) then
						cfg.settings.render_players_size = array.checkbox.render_players_size.v
						save()
						font_players = renderCreateFont("Arial", cfg.settings.render_players_size, font.BOLD + font.BORDER + font.SHADOW) -- время снизу
					end
					imgui.CenterText(u8'Максимальное кол-во сообщений')
					if imgui.SliderInt('##adwadaw', array.checkbox.render_players_count, 3, 20) then
						cfg.settings.render_players_count = array.checkbox.render_players_count.v
						save()
						if #array.render_players > array.checkbox.render_players_count.v then
							for i = cfg.settings.render_players_count, #array.render_players do table.remove( array.render_players, i)  end
						end
					end
					if imgui.Button(u8'Сменить позицию') then
						lua_thread.create(function()
							sampAddChatMessage(tag .. 'Сохранить новую позицию окна: Enter', -1)
							sampAddChatMessage(tag .. 'Оставить прежнюю позицию: Esc',-1)
							local old_pos_x, old_pos_y = cfg.settings.render_players_x, cfg.settings.render_players_y
							while true do
								showCursor(true,true)
								cfg.settings.render_players_x, cfg.settings.render_players_y = getCursorPos()
								if wasKeyPressed(VK_RETURN) then save() break end
								if wasKeyPressed(VK_ESCAPE) then cfg.settings.render_players_x, cfg.settings.render_players_y = old_pos_x, old_pos_y break end
								wait(1)
								renderFontDrawText(font_adminchat, 'Предполагаемое место рендера', cfg.settings.render_players_x, cfg.settings.render_players_y, 0xCCFFFFFF)
							end
							showCursor(false,false)
						end)
						array.windows.menu_tools.v = false
					end
					imgui.EndPopup()
				end
				if array.checkbox.vision_form.v then
					if imgui.Button(u8'Авто-отправка форм для младших администраторов', imgui.ImVec2(419, 24)) then imgui.OpenPopup('autoform') end
					imgui.SameLine()
					if imgui.Checkbox('##vision', array.checkbox.vision_form) then
						cfg.settings.vision_form = false
						save()
					end
					imgui.Tooltip(u8'Нажми, если у тебя есть все доступы\nКнопка будет отображена на второй странице')
					vision_form()
				end
				imgui.SetCursorPosY(440)
				imgui.Separator()
				imgui.Text(u8'Разработчик N.E.O.N -') imgui.SameLine() imgui.Link("https://vk.com/alexandrkob",u8'Нажми, чтобы открыть ссылку в браузере')
				imgui.Text(u8'Группа разработчика -') imgui.SameLine() imgui.Link("https://vk.com/club222702914",u8'Нажми, чтобы открыть ссылку в браузере')
				--imgui.CenterText(u8'Конечный продукт для Администрации RDS '..fa.ICON_SPACE_SHUTTLE)
			elseif menu == 'Дополнительные функции' then -- мульти выбор
				imgui.SetCursorPosX(8)
				if imgui.NewInputText('##doptextcomыmand', array.buffer.custom_addtext_report, 485, u8'Дополнительный текст в начале ответа', 2) then
					cfg.settings.custom_addtext_report = u8:decode(array.buffer.custom_addtext_report.v)
					save()	
				end
				if imgui.NewInputText('##doptextcomыmanыd', array.buffer.add_new_text, 485, u8'Дополнительный текст в конце ответа', 2) then
					cfg.settings.mytextreport = u8:decode(array.buffer.add_new_text.v)
					save()	
				end
				imgui.Separator()
				imgui.Text(u8'Префикс Хелпера')
				imgui.SameLine()
				imgui.SetCursorPosX(275)
				imgui.PushItemWidth(100)
				if imgui.InputText('##prfh', array.buffer.new_prfh) then
					cfg.settings.prefixh = array.buffer.new_prfh.v
					save()
				end
				imgui.PopItemWidth()
				imgui.Text(u8'Префикс Младшего Администратора')
				imgui.SameLine()
				imgui.SetCursorPosX(275)
				imgui.PushItemWidth(100)
				if imgui.InputText('##prfma', array.buffer.new_prfma) then
					cfg.settings.prefixma = array.buffer.new_prfma.v
					save()
				end
				imgui.PopItemWidth()
				imgui.Text(u8'Префикс Администратора')
				imgui.SameLine()
				imgui.SetCursorPosX(275)
				imgui.PushItemWidth(100)
				if imgui.InputText('##prfa', array.buffer.new_prfa) then
					cfg.settings.prefixa = array.buffer.new_prfa.v
					save()
				end
				imgui.PopItemWidth()
				imgui.Text(u8'Префикс Старшего Администратора')
				imgui.SameLine()
				imgui.SetCursorPosX(275)
				imgui.PushItemWidth(100)
				if imgui.InputText('##prfsa', array.buffer.new_prfsa) then
					cfg.settings.prefixsa = array.buffer.new_prfsa.v
					save()
				end
				imgui.PopItemWidth()
				imgui.Separator()
				if imgui.Button(u8'Fast Spawn', imgui.ImVec2(250, 24)) then
					array.windows.menu_tools.v = false
					sampProcessChatInput('/fs')
				end
				imgui.SameLine()
				if imgui.Button(u8'Трассера', imgui.ImVec2(228, 24)) then
					array.windows.menu_tools.v = false
					sampProcessChatInput('/trassera')
				end
				if imgui.Button(u8'Статистика за день', imgui.ImVec2(250, 24)) then
					sampProcessChatInput('/state')
					array.windows.menu_tools.v = false
					showCursor(true,false)
				end
				imgui.SameLine()
				if imgui.Button(u8'Чат-логгер', imgui.ImVec2(228, 24)) then sampProcessChatInput('/opencl') end
				if not array.checkbox.vision_form.v then
					if imgui.Button(u8'Автоматическая отправка форм', imgui.ImVec2(485, 24)) then imgui.OpenPopup('autoform') end
					vision_form()
				end
				if imgui.Button(u8'Автозакрытие игры в AFK', imgui.ImVec2(485, 24)) then
					if not cfg.settings.control_afk then
						sampAddChatMessage(tag .. 'Укажите кол-во минут в AFK, после которого игра автоматически закроется.', -1)
						sampSetChatInputText('/control_afk ') 
						sampSetChatInputEnabled(true)
					else cfg.settings.control_afk = false sampAddChatMessage(tag .. 'Выключено.', -1) end
				end
				if imgui.Button(u8'Автовыдача префикса (для руководящего состава)', imgui.ImVec2(485, 24)) then imgui.OpenPopup('autoprefix') end
				if imgui.BeginPopup('autoprefix') then
					if array.checkbox.autoprefix.v then imgui.Text(u8'Статус: Активно')
					else imgui.Text(u8'Статус: Деактивировано') end
					imgui.SameLine()
					imgui.SetCursorPosX(200)
					if imadd.ToggleButton('##autoprefix', array.checkbox.autoprefix) then
						cfg.settings.autoprefix = not cfg.settings.autoprefix
						save()
					end
					if imgui.Button(u8'Добавить исключение') then
						sampSetChatInputText('/add_autoprefix ')  
						sampSetChatInputEnabled(true)
					end
					imgui.SameLine()
					if imgui.Button(u8'Убрать исключение') then
						sampSetChatInputText('/del_autoprefix ')  
						sampSetChatInputEnabled(true)
					end
					imgui.EndPopup()
				end
				imgui.PushItemWidth(485)
				if imgui.Combo("##selected", array.checkbox.style_selected, {u8"Классическая тема", u8"Красная тема", u8"Синяя тема", u8"Фиолетовая тема", u8"Розовая тема", u8"Голубая тема"}, array.checkbox.style_selected) then
					cfg.settings.style = array.checkbox.style_selected.v 
					save()
					style(cfg.settings.style)
				end
				imgui.PopItemWidth()
				if imgui.Checkbox(u8'Скрытие закрытых диалогов для автоонлайна/рендера /admins', imgui.ImBool(cfg.settings.nodialog)) then
					cfg.settings.nodialog = not cfg.settings.nodialog
					save()
				end
				imgui.Tooltip(u8'Выключить если есть проблемы с открытыми диалогами')
				imgui.SetCursorPosY(470)
				if imgui.Button(u8'Перезагрузить скрипты '..fa.ICON_RECYCLE, imgui.ImVec2(250,24)) then reloadScripts() end
				imgui.SameLine()
				if imgui.Button(u8'Выгрузить скрипт ' .. fa.ICON_POWER_OFF, imgui.ImVec2(228, 24)) then
					sampAddChatMessage(tag .. 'Скрипты АТ выгружены. Если желаете загрузить их вновь, введите команду /rst',-1)
					ScriptExport() 
				end
			elseif menu == 'Быстрые клавиши' then -- быстрые клавиши
				imgui.SetCursorPosX(8)
				imgui.NewInputText('##SearchBar7', array.buffer.new_binder_key, 485, u8'Текст биндера', 2)
				imgui.PushItemWidth(485)
				imgui.Combo("##Метод отправки", array.checkbox.new_binder_key, {u8"Отправить серверу", u8"Отправить клиенту", u8"Добавить в поле ввода"}, 3)
				imgui.PopItemWidth()
				if imgui.Button(u8'Добавить', imgui.ImVec2(250,24)) and #(u8:decode(array.buffer.new_binder_key.v)) ~= 0 then
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.binder_key[getDownKeysText()] = array.checkbox.new_binder_key.v ..'\\n'.. u8:decode(array.buffer.new_binder_key.v)
						save()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'Удалить', imgui.ImVec2(228,24)) and #(u8:decode(array.buffer.new_binder_key.v)) ~= 0 then
					for k,v in pairs(cfg.binder_key) do
						if (u8:decode(array.buffer.new_binder_key.v) == string.sub(v, 4)) then
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
				imgui.CenterText(u8'Подтверждение действия: ')
				imgui.SameLine()
				imgui.Text(u8(cfg.settings.key_automute))
				if imgui.Button(u8"Coxpaнить.", imgui.ImVec2(250, 24)) then
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.settings.key_automute = getDownKeysText()
						save()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'Сбpocить', imgui.ImVec2(228,24)) then
					cfg.settings.key_automute = 'None'
					save()
				end
				imgui.Separator()
				imgui.CenterText(u8'[Мои быстрые клавиши]')
				for k, v in pairs(cfg.binder_key) do
					imgui.Text(u8('[Клавиша '..k..'] = '))
					imgui.SameLine()
					imgui.Text(u8(string.sub(v, 4)))
					imgui.SameLine()
					imgui.SetCursorPosX(420)
					imgui.Text(u8'[Удалить]')
					if imgui.IsItemClicked(0) then
						cfg.binder_key[k] = nil
						save()
					end
				end
				imgui.SetCursorPosY(475)
				if getDownKeysText() and not getDownKeysText():find('+') then imgui.Text(u8'Зажата клавиша: ' .. getDownKeysText())
				else imgui.Text(u8'Нет зажатой клавиши') end
				imgui.SameLine()
				imgui.SetCursorPosX(253)
				if imgui.Button(u8"Сбросить значения всех клавиш") then
					for k,v in pairs(cfg.binder_key) do cfg.binder_key[k] = nil end
					save()
				end
			elseif menu == 'Блокнот' then
				array.buffer.bloknotik.v = string.gsub(array.buffer.bloknotik.v, "\\n", "\n")
				if imgui.InputTextMultiline("##1", array.buffer.bloknotik, imgui.ImVec2(490, 500)) then
					array.buffer.bloknotik.v = string.gsub(array.buffer.bloknotik.v, "\n", "\\n")
					cfg.settings.bloknotik = u8:decode(array.buffer.bloknotik.v)
					save()	
				end
			elseif menu == 'Флуды' then -- флуды
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'Мои флуды', imgui.ImVec2(410, 25)) then
					imgui.OpenPopup('myflood')
				end
				if imgui.BeginPopup('myflood') then
					if imgui.Button(u8'Скрипт сам допишет /mess\nВам лишь надо указать цвет.', imgui.ImVec2(250,32)) then sampAddChatMessage(tag .. 'Открыт диалог с цветами',-1) sampSendChat('/mcolors') end
					imgui.Text(u8'Название: ')
					imgui.PushItemWidth(250)
					imgui.InputText('##title_flood_mess', array.buffer.title_flood_mess)
					imgui.PopItemWidth()
					imgui.Text(u8'Текст: ')
					imgui.InputTextMultiline("##5", array.buffer.new_flood_mess, imgui.ImVec2(250, 100))
					if imgui.Button(u8'Сохранить', imgui.ImVec2(250, 24)) then
						if #(u8:decode(array.buffer.new_flood_mess.v)) > 3 and #(u8:decode(array.buffer.title_flood_mess.v)) ~= 0 then
							if array.buffer.new_flood_mess.v ~= 0 then
								if tonumber(string.sub(array.buffer.new_flood_mess.v, 1, 1)) then
									cfg.myflood[u8:decode(array.buffer.title_flood_mess.v)] = string.gsub(u8:decode(array.buffer.new_flood_mess.v), '\n', '\\n')
									save()
									array.buffer.title_flood_mess.v = ''
									array.buffer.new_flood_mess.v = ''
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
								array.buffer.title_flood_mess.v = u8(k)
								array.buffer.new_flood_mess.v = (string.gsub(u8(v), '\\n', '\n'))
							end
							if imgui.Button(fa.ICON_BAN) then
								cfg.myflood[k] = nil
								save()
							end
							imgui.EndPopup()
						end
						imgui.PopFont()
					end
					imgui.EndPopup()
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
					sampSendChat('/mess 7 У нашего проекта имеется группа vk сom/dmdriftgta ...')
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
				if imgui.Button(u8'Арена', imgui.ImVec2(130, 25)) then
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
					sampSendChat('/mess 13 Нашел читера, злостного нарушителя, ДМера, или кто-то просто мешают играть?')
					sampSendChat('/mess 13 Появился вопрос о возможностях сервера или его особенностях?')
					sampSendChat('/mess 13 Администрация всегда поможет! Пиши /report и свою жалобу/вопрос')
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
				if imgui.Button(u8'Добавить мой ответ', imgui.ImVec2(250, 24)) and #(array.buffer.custom_answer.v) > 1 then
					if #(u8:decode(array.buffer.custom_answer.v)) < 80 then
						cfg.customotvet[#(cfg.customotvet) + 1] = u8:decode(array.buffer.custom_answer.v)
						save()
						array.buffer.custom_answer.v = ''
						imgui.SetKeyboardFocusHere(-1)
					else sampAddChatMessage(tag .. 'Слишком много символов, сократите ответ', -1) end
				end
				imgui.NewInputText('##SearchBar2', array.buffer.custom_answer, 485, u8'Введите ваш ответ.', 2)
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
				imgui.Checkbox('##celoeslovo', array.checkbox.add_full_words)
				imgui.Tooltip(u8'Вкл = добавление исключительно целого слова, а не ключевых')
				imgui.SameLine()
				imgui.CenterText(u8'Добавить мат (Всего в словаре: ' .. #array.mat..')')
				imgui.SameLine()
				imgui.Text(fa.ICON_EYE)
				imgui.Tooltip(u8'Нажми, чтобы открыть предпросмотр словаря')
				if imgui.IsItemClicked(0) then -- если кликнул на иконку глаза
					imgui.OpenPopup('check_mat')
				end
				if imgui.BeginPopup('check_mat') then
					for i = 1, #array.mat do
						imgui.Text(u8(array.mat[i]))
						if imgui.IsItemClicked(0) then
							array.buffer.newmat.v = u8(array.mat[i])
						end
						if i % 8 ~= 0 then imgui.SameLine() end
					end
					imgui.EndPopup()
				end
				imgui.PushItemWidth(430)
				imgui.InputText('##newmat', array.buffer.newmat)
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX(440)
				if (imgui.Button(fa.ICON_CHECK, imgui.ImVec2(24,24)) and (string.len(u8:decode(array.buffer.newmat.v))>=2)) or (wasKeyPressed(VK_RETURN) and (string.len(u8:decode(array.buffer.newmat.v))>=2)) then
					array.buffer.newmat.v = u8:decode(array.buffer.newmat.v)
					array.buffer.newmat.v = array.buffer.newmat.v:rlower()
					for k, v in pairs(array.mat) do
						if (array.mat[k] == array.buffer.newmat.v) or (array.mat[k] == array.buffer.newmat.v..'%s') then
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. array.buffer.newmat.v .. ' {F0E68C}уже имеется в списке матов.', -1)
							find_words = true
							break
						end
					end
					if not find_words then
						local AutoMute_mat = io.open('moonloader\\' .. "\\config\\AT\\mat.txt", "a")
						if array.checkbox.add_full_words.v then 
							AutoMute_mat:write(u8(array.buffer.newmat.v)..'%s' .. '\n')
							table.insert(array.mat, array.buffer.newmat.v..'%s')
						else
							AutoMute_mat:write(u8(array.buffer.newmat.v) .. '\n')
							table.insert(array.mat, array.buffer.newmat.v)
						end
						AutoMute_mat:close()
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. array.buffer.newmat.v .. ' {F0E68C}было успешно добавлено в список матов.', -1)
					end
					find_words = nil
					array.buffer.newmat.v = u8(array.buffer.newmat.v)
					imgui.SetKeyboardFocusHere(-1)
				end
				imgui.SameLine()
				imgui.SetCursorPosX(465)
				if imgui.Button(fa.ICON_BAN, imgui.ImVec2(24,24)) and string.len(u8:decode(array.buffer.newmat.v)) >= 2 then
					array.buffer.newmat.v = u8:decode(array.buffer.newmat.v)
					array.buffer.newmat.v = array.buffer.newmat.v:rlower()
					for k, v in pairs(array.mat) do
						if (array.mat[k] == array.buffer.newmat.v) or (array.mat[k] == array.buffer.newmat.v..'%s') then
							table.remove(array.mat, k)
	
							local AutoMute_mat = io.open('moonloader\\' .. "\\config\\AT\\mat.txt", "w") 
							AutoMute_mat:close()
	
							local AutoMute_mat = io.open('moonloader\\' .. "\\config\\AT\\mat.txt", "a")
							for i = 1, #array.mat do if array.mat[i] and #(array.mat[i]) > 2 then AutoMute_mat:write(u8(array.mat[i]) .. "\n") end end
							AutoMute_mat:close()
	
							find_words = true
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Выбранное вами слово{008000} ' .. array.buffer.newmat.v .. ' {F0E68C}было успешно удалено из списка матов', -1)
							break
						end
					end
					if not find_words then sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Такого слова в списке матов нет.', -1) end
					find_words = nil
					array.buffer.newmat.v = ''
					imgui.SetKeyboardFocusHere(-1)
				end
				imgui.CenterText(u8'Добавить оскорбление (Всего в словаре: ' .. #array.osk .. ')')
				imgui.SameLine()
				imgui.Text(fa.ICON_EYE)
				imgui.Tooltip(u8'Нажми, чтобы открыть предпросмотр словаря')
				if imgui.IsItemClicked(0) then -- если кликнул на иконку глаза
					imgui.OpenPopup('check_osk')
				end
				if imgui.BeginPopup('check_osk') then
					for i = 1, #array.osk do
						imgui.Text(u8(array.osk[i]))
						if imgui.IsItemClicked(0) then
							array.buffer.newosk.v = u8(array.osk[i])
						end
						if i % 8 ~= 0 then imgui.SameLine() end
					end
					imgui.EndPopup()
				end
				imgui.PushItemWidth(430)
				imgui.InputText('##newosk', array.buffer.newosk)
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX(440)
				if (imgui.Button(fa.ICON_CHECK .. '##', imgui.ImVec2(24,24)) and (string.len(u8:decode(array.buffer.newosk.v))>=2)) or (wasKeyPressed(VK_RETURN) and (string.len(u8:decode(array.buffer.newosk.v))>=2)) then
					array.buffer.newosk.v = u8:decode(array.buffer.newosk.v)
					array.buffer.newosk.v = array.buffer.newosk.v:rlower()
					for k, v in pairs(array.osk) do
						if (array.osk[k] == array.buffer.newosk.v) or (array.osk[k] == array.buffer.newosk.v..'%s') then
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. array.buffer.newosk.v .. ' {F0E68C}уже имеется в списке оскорблений.', -1)
							find_words = true
							break
						end
					end
					if not find_words then
						local AutoMute_osk = io.open('moonloader\\' .. "\\config\\AT\\osk.txt", "a")
						if array.checkbox.add_full_words.v then 
							AutoMute_osk:write(u8(array.buffer.newosk.v) .. '%s' .. '\n')
							table.insert(array.osk, array.buffer.newosk.v..'%s')
						else 
							AutoMute_osk:write(u8(array.buffer.newosk.v) .. '\n')
							table.insert(array.osk, array.buffer.newosk.v) 
						end
						AutoMute_osk:close()
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Слово{008000} ' .. array.buffer.newosk.v .. ' {F0E68C}было успешно добавлено в список оскорблений.', -1)
					end
					find_words = nil
					array.buffer.newosk.v = u8(array.buffer.newosk.v)
					imgui.SetKeyboardFocusHere(-1)
				end
				imgui.SameLine()
				imgui.SetCursorPosX(465)
				if imgui.Button(fa.ICON_BAN .. '##', imgui.ImVec2(24,24)) and string.len(u8:decode(array.buffer.newosk.v)) >= 2 then
					array.buffer.newosk.v = u8:decode(array.buffer.newosk.v)
					array.buffer.newosk.v = array.buffer.newosk.v:rlower()
					for k, v in pairs(array.osk) do
						if (array.osk[k] == array.buffer.newosk.v) or (array.osk[k] == array.buffer.newosk.v..'%s') then
							local AutoMute_osk = io.open('moonloader\\' .. "\\config\\AT\\osk.txt", "w") 
							AutoMute_osk:close()
	
							table.remove(array.osk, k)
							local AutoMute_osk = io.open('moonloader\\' .. "\\config\\AT\\osk.txt", "a")
							for i = 1, #array.osk do if array.osk[i] and #(array.osk[i]) > 2 then AutoMute_osk:write(u8(array.osk[i]) .. "\n") end end
							AutoMute_osk:close()
	
							find_words = true
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Выбранное вами слово{008000} ' .. array.buffer.newosk.v .. ' {F0E68C}было успешно удалено из списка оскорблений', -1)
							break
						end
					end
					if not find_words then sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} Такого слова в списке оскорблений нет.', -1) end
					find_words = nil
					array.buffer.newosk.v = ''
					imgui.SetKeyboardFocusHere(-1)
				end
				imgui.CenterText(u8'Добавить быструю команду')
				imgui.SameLine()
				if imgui.Link(u8"[ИНСТРУКЦИЯ]", u8"Нажми, чтобы открыть ссылку в браузере") then
					os.execute(('explorer.exe "%s"'):format("https://youtu.be/gCtzMFcTtis"))
				end
				imgui.NewInputText('##titlecommand5', array.buffer.new_command_title, 480, u8'Название команды (пример: /ok, /dz, /ch)', 2)
				imgui.InputTextMultiline("##newcommand", array.buffer.new_command, imgui.ImVec2(480, 210))
				if imgui.Button(u8'Добавить аргументы', imgui.ImVec2(480, 24)) then
					imgui.OpenPopup('settings_command')
				end
				if imgui.BeginPopup('settings_command') then
					if imgui.Button(u8'Задержка, время ожидания') then
						array.buffer.new_command.v = array.buffer.new_command.v .. u8'\nwait(Кол-во секунд)'
						sampAddChatMessage(tag .. 'Введите количество секунд задержки', -1)
					end
					if imgui.Button(u8'Аргумент для ввода') then
						array.buffer.new_command.v = array.buffer.new_command.v .. '_'
					end
					if imgui.Button(u8'Ник игрока по его ID') then
						array.buffer.new_command.v = array.buffer.new_command.v .. 'nick(_)'
					end
					imgui.EndPopup()
				end
				if imgui.Button(u8'Сохрaнить', imgui.ImVec2(250, 24)) then
					if #(u8:decode(array.buffer.new_command_title.v)) ~= 0 and #(u8:decode(array.buffer.new_command.v)) > 2 then
						array.buffer.new_command_title.v = string.gsub(array.buffer.new_command_title.v, '%/', '')
						cfg.my_command[array.buffer.new_command_title.v] = string.gsub(u8:decode(array.buffer.new_command.v),'\n','\\n')
						save()
						array.buffer.new_command.v = string.gsub(array.buffer.new_command.v, '\\n','\n') 
						local v = string.gsub(cfg.my_command[array.buffer.new_command_title.v], '\\n','\n') 
						sampRegisterChatCommand(array.buffer.new_command_title.v, function(param) 
							lua_thread.create(function() 
								for a,b in pairs(textSplit(string.gsub(v, '_', param), '\n'))  do 
									if #b ~= 0 then
										if b:match('wait(%(%d+)%)') then 
											wait(tonumber(b:match('%d+') .. '000'))
										elseif b:match('nick%((.+)%)') then
											local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
											local parametr = tonumber(b:match('nick%((.+)%)'))
											if parametr and sampIsPlayerConnected(parametr) then
												sampSendChat(string.gsub(b, 'nick%((.+)%)', sampGetPlayerNickname(parametr)))
											else
												sampAddChatMessage(tag .. 'ID игрока указан неверно.', -1)
												break
											end
										else sampSendChat(b) end
									end
								end 
							end) 
						end) 
						sampAddChatMessage(tag .. 'Новая команда /' .. array.buffer.new_command_title.v .. ' успешно создана.',-1)
						array.buffer.new_command.v, array.buffer.new_command_title.v = '',''
					else sampAddChatMessage(tag .. 'Что вы собрались сохранять?', -1) end
				end
				imgui.SameLine()
				if imgui.Button(u8'Удалить', imgui.ImVec2(222, 24)) then
					if #(array.buffer.new_command_title.v) == 0 then sampAddChatMessage(tag ..'Вы не указали название команды, что вы собрались удалять?', -1)
					else
						array.buffer.new_command_title.v = string.gsub(u8:decode(array.buffer.new_command_title.v), '/', '')
						if cfg.my_command[array.buffer.new_command_title.v] then
							cfg.my_command[array.buffer.new_command_title.v] = nil
							save()
							array.buffer.new_command_title.v = ''
							sampAddChatMessage(tag .. 'Команда была успешно удалена. Перестанет действовать после перезагрузки игры.', -1)
						else sampAddChatMessage(tag .. 'Такой команды в базе данных нет.', -1) end
					end
				end
			elseif menu == 'smartautomute' then
				imgui.CenterText(u8'Настройки умного автомута')
				imgui.SameLine()
				imgui.Text(fa.ICON_EYE)
				if imgui.IsItemClicked(0) then
					imgui.OpenPopup('watch')
				end
				if array.checkbox.add_smart_automute.v == 0 then 
					arr = cfg.spisokproject
					imgui.Text(u8'Авто-Мут за упоминание стороннего проекта')
					if imgui.Checkbox(u8'Авто-очистка чата', array.checkbox.auto_cc) then
						cfg.settings.auto_cc = not cfg.settings.auto_cc
						save()
					end
				elseif array.checkbox.add_smart_automute.v == 1 then 
					arr = cfg.spisokoskrod
					imgui.Text(u8'Авто-Мут за прямое оскорбление или упоминание родни')
				elseif array.checkbox.add_smart_automute.v == 2 then 
					arr = cfg.spisokor
					imgui.Text(u8'Авто-Мут за примерный оск род, пример:\nСын шалавы (шалавы - оск) + (сын - упом род)')
				elseif array.checkbox.add_smart_automute.v == 3 then
					arr = cfg.spisokrz
				elseif array.checkbox.add_smart_automute.v == 4 then
					arr = cfg.spisokoskadm
					imgui.Text(u8'Авто-Мут за примерный оск адм, пример:\nдебил админ (дебил - оск) + (админ - ключевое слово)')
				end
				if imgui.BeginPopup('watch') then
					for i = 1, #arr do
						imgui.Text(u8(arr[i]))
						if imgui.IsItemClicked(0) then
							array.buffer.add_smart_automute.v = u8(arr[i])
						end
						if i % 6 ~= 0 then imgui.SameLine() end
					end
					imgui.EndPopup()
				end
				imgui.RadioButton(u8"Список проектов", array.checkbox.add_smart_automute, 0)
				imgui.RadioButton(u8"Оскорбление родни", array.checkbox.add_smart_automute, 1)
				imgui.RadioButton(u8"Оскорбление + упоминание родни", array.checkbox.add_smart_automute, 2)
				imgui.RadioButton(u8"Розжиг межнац.розни", array.checkbox.add_smart_automute, 3)
				imgui.RadioButton(u8"Оскорбление администрации", array.checkbox.add_smart_automute, 4)
				if array.checkbox.add_full_words.v then
					imgui.Checkbox(u8'Добавить целое слово', array.checkbox.add_full_words)
				else
					imgui.Checkbox(u8'Добавить ключевое слово', array.checkbox.add_full_words)
				end
				imgui.PushItemWidth(480)
				imgui.InputText('##add', array.buffer.add_smart_automute)
				imgui.PopItemWidth()
				if imgui.Button(u8'Добавить', imgui.ImVec2(250, 24)) and #(array.buffer.add_smart_automute.v) > 2 then
					array.buffer.add_smart_automute.v = (u8:decode(array.buffer.add_smart_automute.v)):rlower()
					for i = 0, #arr do
						if (arr[i] == array.buffer.add_smart_automute.v) or (arr[i] == array.buffer.add_smart_automute.v..'%s') then
							find_words = i
							break
						end
					end
					if find_words then
						sampAddChatMessage(tag..'Данное слово уже имеется в словаре.', -1)
						find_words = nil
					else
						if array.checkbox.add_full_words.v then
							table.insert(arr, array.buffer.add_smart_automute.v .. '%s')
						else
							table.insert(arr, array.buffer.add_smart_automute.v)
						end
						save()
						sampAddChatMessage(tag .. 'Слово ' .. array.buffer.add_smart_automute.v .. ' успешно добавлено в выбранный словарь.', -1)
					end
					array.buffer.add_smart_automute.v = u8('')
				end
				imgui.SameLine()
				if imgui.Button(u8'Удалить', imgui.ImVec2(222,24)) and #(array.buffer.add_smart_automute.v) > 2 then
					array.buffer.add_smart_automute.v = (u8:decode(array.buffer.add_smart_automute.v)):rlower()
					for i = 0, #arr do
						if (arr[i] == array.buffer.add_smart_automute.v) or (arr[i] == array.buffer.add_smart_automute.v..'%s') then
							find_words = i
							break
						end
					end
					if find_words then
						table.remove(arr, find_words)
						save()
						sampAddChatMessage(tag..'Слово ' .. array.buffer.add_smart_automute.v .. ' успешно удалено из выбранного словаря.', -1)
						find_words = nil
					else sampAddChatMessage(tag..'Данного слова в выбранном словаре нет.', -1) end
					array.buffer.add_smart_automute.v = u8('')
				end
				imgui.SetCursorPosY(470)
				if imgui.Button(u8'Сбросить настройки АТ') then
					imgui.OpenPopup('reset')
				end
				if imgui.BeginPopup('reset') then
					imgui.Text(u8'Вы уверены, что хотите сбросить настройки?')
					if imgui.Button(u8'Да', imgui.ImVec2(150,25)) then
						sampProcessChatInput('/reset')
					end
					imgui.Text(u8'Сброс настроек скачает рекомендуемые настройки АТ и автомута')
					imgui.EndPopup()
				end
			end
		imgui.EndGroup()
		imgui.PopFont()
 		imgui.End()
	end
	if array.windows.fast_report.v then -- быстрый ответ на репорт
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5) - 250, (sh * 0.5)-90), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Ответ на репорт', array.windows.fast_report, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8('Игрок: '..autor .. '[' ..autorid.. ']'))
 		imgui.SameLine()
		imgui.Text(fa.ICON_FILES_O)
		if imgui.IsItemClicked(0) then 
			setClipboardText(autor)
			sampAddChatMessage(tag .. 'Ник скопирован в буфер обмена.', -1)
		end
		imgui.SameLine()
		imgui.SetCursorPosX(495)
		imgui.Text(fa.ICON_PLUS_CIRCLE)
		if imgui.IsItemClicked(0) then
			imgui.OpenPopup('new')
			array.buffer.newButtonReport.v = array.buffer.text_ans.v
			array.buffer.newButtonReportName.v = ""
		end
		imgui.Tooltip(u8'Добавить кнопку')
		imgui.TextWrapped(u8('Репорт: ' .. textreport))
		if reportid and sampIsPlayerConnected(reportid) then
			imgui.SameLine()
			imgui.TextColoredRGB(u8('{D3D3D3}>> '..sampGetPlayerNickname(reportid)))
		end
		if imgui.BeginPopup('new') then
			imgui.NewInputText('##', array.buffer.newButtonReportName, 200, u8'Название кнопки', 2)
			imgui.NewInputText('##2', array.buffer.newButtonReport, 200, u8'Ответ игроку', 2)
			if imgui.Button(u8'Сохранить', imgui.ImVec2(200,24)) then
				if #array.buffer.newButtonReportName.v < 3 or #array.buffer.newButtonReportName.v > 23 then sampAddChatMessage(tag .. "Название кнопки не подходит под критерии 3 < n < 23", -1) 
				elseif #array.buffer.newButtonReport.v < 3 or #array.buffer.newButtonReport.v > 80 then sampAddChatMessage(tag .. 'Ответ не подходит под критерии 3 < n < 80',-1)
				else
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.report_button[string.gsub(string.gsub(u8:decode(u8(array.buffer.newButtonReportName.v)), '%[', ''), '%]', '')] = getDownKeysText() .. "_" .. string.gsub(string.gsub(u8:decode(array.buffer.newButtonReport.v), '%[', ''), '%]', '')
						save()
						sampAddChatMessage(tag .. 'Новый ответ успешно сохранен.', -1)
					elseif getDownKeysText() == nil or not getDownKeysText():find('+') then
						cfg.report_button[string.gsub(string.gsub(u8:decode(u8(array.buffer.newButtonReportName.v)), '%[', ''), '%]', '')] = "None_" .. string.gsub(string.gsub(u8:decode(array.buffer.newButtonReport.v), '%[', ''), '%]', '')
						save()
						sampAddChatMessage(tag .. 'Клавиша сохранена, но без быстрой клавиши.', -1)
					end
					array.buffer.newButtonReport.v = ""
					array.buffer.newButtonReportName.v = ""
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'Del') then
				if (#array.buffer.newButtonReportName.v == 0) then 
					sampAddChatMessage(tag .. 'Название кнопки не заполнено.', -1)
				else
					cfg.report_button[u8:decode(u8(array.buffer.newButtonReportName.v))]=nil
					save()
					sampAddChatMessage(tag .. 'Удаление происходит по названию кнопки, если оно указано неверно - кнопка не будет удалена.', -1)
					array.buffer.newButtonReportName.v = ""
				end
			end
			if (getDownKeysText()) then
				imgui.Text(u8'Зажата клавиша: ' .. getDownKeysText())
			else
				imgui.Text(u8'Нет зажатых клавиш')
			end
			imgui.EndPopup()
		else
			if wasKeyPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end 
			imgui.NewInputText('##SearchBar', array.buffer.text_ans, 375, u8'Введите ваш ответ.', 2)
			imgui.SameLine()
			imgui.SetCursorPosX(392)
			imgui.Tooltip('Space')
			if imgui.Button(u8'Отправить ' .. fa.ICON_SHARE, imgui.ImVec2(120, 25)) or (not cfg.settings.enter_report and wasKeyPressed(VK_RETURN) and not sampIsChatInputActive()) then
				if #(array.buffer.text_ans.v) ~= 0 then array.answer.moiotvet = true
				else sampAddChatMessage(tag .. 'Ответ не менее 1 символа.', -1) end
			end
			imgui.Tooltip('Enter')
			imgui.Separator()
			if #(array.buffer.text_ans.v) > 4 then
				if imgui.Checkbox(u8"При нажатии на Enter отправить сохраненный ответ", array.checkbox.button_enter_in_report) then
					cfg.settings.enter_report = not cfg.settings.enter_report
					save()
				end
				for k,v in pairs(cfg.customotvet) do
					if string.rlower(string.gsub(v, '%p', '')):find(string.rlower(string.gsub(u8:decode(array.buffer.text_ans.v), '%p', ''))) or string.rlower(string.gsub(v, '%p', '')):find(translateText(string.rlower(string.gsub(u8:decode(array.buffer.text_ans.v), '%p', '')))) then
						if imgui.Button(u8(v), imgui.ImVec2(imgui.GetWindowWidth()-18, 24)) or (wasKeyPressed(VK_RETURN) and not sampIsChatInputActive()) then
							if not array.answer.customans then 
								array.answer.customans = v
							end
						end
					end
				end
			else
				if imgui.Button(u8'Работаю', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_Q) and not sampIsChatInputActive()) then
					array.answer.rabotay = true 		-- Отправляем что работает по жалобе
					array.answer.control_player = true 	-- Переходим в рекон
				end
				imgui.Tooltip('Q')
				imgui.SameLine()
				if imgui.Button(u8'Слежу', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_E) and not sampIsChatInputActive()) then
					array.answer.slejy = true
				end
				imgui.Tooltip('E')
				imgui.SameLine()
				if imgui.Button('Skin/Color', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_R) and not sampIsChatInputActive()) then
					array.windows.custom_ans.v = true
				end
				imgui.Tooltip('R')
				imgui.SameLine()
				if imgui.Button(u8'Передать', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_V) and not sampIsChatInputActive()) then
					array.answer.peredamrep = true
				end
				imgui.Tooltip('V')
				if imgui.Button(u8'Наказать', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_G) and not sampIsChatInputActive()) then
					imgui.OpenPopup('option')
				end
				if imgui.BeginPopup('option') then
					if imgui.Button(u8'Оффтоп (1)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_1) then
						array.nakazatreport.oftop = true
						array.answer.nakajy = true
					end
					if imgui.Button(u8'Оскорбление администрации (2)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_2) then
						array.nakazatreport.oskadm = true
						array.answer.nakajy = true
					end
					if imgui.Button(u8'Клевета на администрацию (3)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_3) then
						array.nakazatreport.kl = true
						array.answer.nakajy = true
					end
					if imgui.Button(u8'Оск/Упом родных (4)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_4) then
						array.nakazatreport.oskrod = true
						array.answer.nakajy = true
					end
					if imgui.Button(u8'Попрошайничество (5)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_5) then
						array.nakazatreport.poprep = true
						array.answer.nakajy = true
					end
					if imgui.Button(u8'Оскорбление/Унижение (6)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_6) then
						array.nakazatreport.oskrep = true
						array.answer.nakajy = true
					end
					if imgui.Button(u8'Нецензурная лексика (7)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_7) then
						array.nakazatreport.matrep = true
						array.answer.nakajy = true
					end
					if imgui.Button(u8'Розжиг (8)', imgui.ImVec2(250,25)) or wasKeyPressed(VK_8) then
						array.nakazatreport.rozjig = true
					end
					imgui.EndPopup()
				end
				imgui.Tooltip('G')
				imgui.SameLine()
				if imgui.Button(u8'Уточните ID', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_B) and not sampIsChatInputActive()) then
					array.answer.uto4id = true
				end
				imgui.Tooltip('B')
				imgui.SameLine()
				if imgui.Button(u8'Форум', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_F) and not sampIsChatInputActive()) then
					array.answer.uto4 = true
				end
				imgui.Tooltip('F')
				imgui.SameLine()
				if imgui.Button(u8'Отклонить', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_Y) and not sampIsChatInputActive()) then
					array.answer.otklon = true
				end
				local cnt = 0
				for k,v in pairs(cfg.report_button) do
					local v = textSplit(v, "_")
					cnt = cnt + 1
					if cnt % 4 ~= 1 then imgui.SameLine() end 
					if imgui.Button(k, imgui.ImVec2(120, 25)) or (wasKeyPressed(strToIdKeys(v[1]))) then
						array.answer.customans = v[2]
					end
					if (v[1] ~= "None") then
						imgui.Tooltip(u8(v[1]))
					end
				end
			end
			imgui.Separator()
			if imadd.ToggleButton("#####", imgui.ImBool(cfg.settings.addBeginText)) then
				cfg.settings.addBeginText = not cfg.settings.addBeginText
				save()
			end
			imgui.SameLine()
			imgui.Text(u8'Добавить текст в начале ответа '.. fa.ICON_COMMENTING_O)
			if imadd.ToggleButton('##doptextans', array.checkbox.check_add_answer_report) then
				cfg.settings.add_answer_report = not cfg.settings.add_answer_report
				save()
			end
			imgui.Tooltip(u8'Добавляет текст к началу вашего ответа\nНе сработает, если кол-во символов в ответе превысит максимум\nЕсли функция включена и текст не указан - берет из словаря.')
			imgui.SameLine()
			imgui.Text(u8'Добавить текст в конце ответа  ' .. fa.ICON_COMMENTING_O)
			if imadd.ToggleButton('##saveans', array.checkbox.check_save_answer) then
				cfg.settings.custom_answer_save = not cfg.settings.custom_answer_save
				save()
			end
			imgui.Tooltip(u8'Добавляет текст к концу вашего ответу\nНе сработает, если кол-во символов в ответе превысит максимум\nТекст на данный момент:\n' .. u8(cfg.settings.mytextreport))
			imgui.SameLine()
			imgui.Text(u8'Сохранить данный ответ в базу данных скрипта ' .. fa.ICON_DATABASE)
		end
		imgui.PopFont()
		imgui.End()
	end
	if array.windows.recon_menu.v then -- recon menu
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y))
		imgui.Begin("##recon", array.windows.recon_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
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
					imgui.TextColoredRGB(sampGetPlayerNickname(control_player_recon) .. '[' .. control_player_recon .. ']')
				else imgui.Text(u8'Игрок не в сети.') end
				imgui.Separator()
				if array.inforeport[14] then
					if array.inforeport[3] then
						imgui.Text(u8'Здоровье авто: ' .. array.inforeport[3])
					end
					imgui.Text(u8'Скорость: ' .. array.inforeport[4])
					imgui.Text(u8'Оружие: ' .. array.inforeport[6])
					imgui.Text(u8'Точность: ' .. array.inforeport[7])
					imgui.Text('PING: ' .. array.inforeport[5])
					imgui.Text('AFK: ' .. array.inforeport[9])
					imgui.TextColoredRGB('VIP: ' .. array.inforeport[11])
					imgui.Text('Turbo: ' .. array.inforeport[13]) 
					imgui.Text('Passive: ' .. array.inforeport[12])
					imgui.Text(u8'Коллизия: ' .. array.inforeport[14])
				else
					imgui.Text(u8'Информация о игроке недоступна.')
				end
				if imgui.Button(u8'Посмотреть первую статистику', imgui.ImVec2(250, 25)) then
					sampSendChat('/statpl ' .. sampGetPlayerNickname(control_player_recon))
				end
				if imgui.Button(u8'Посмотреть вторую статистику', imgui.ImVec2(250, 25)) then
					sampSendClickTextdraw(array.textdraw.stats)
				end
				if imgui.Button(u8'Посмотреть /offstats статистику', imgui.ImVec2(250, 25)) then
					sampSendChat('/offstats ' .. sampGetPlayerNickname(control_player_recon))
					sampSendDialogResponse(16200, 1, 0)
				end
				if imgui.Button(u8'Посмотреть устройство игрока', imgui.ImVec2(250, 25)) then
					sampSendChat('/tonline')
				end
			elseif menu_in_recon == 'Дополнительные функции' then
				for _,v in pairs(playersToStreamZone()) do
					if v ~= control_player_recon then
						imgui.SetCursorPosX(10)
						if imgui.Button(sampGetPlayerNickname(v) .. '[' .. v .. ']', imgui.ImVec2(250, 25)) then sampSendChat('/re ' .. v) end
					end
				end
			end
		imgui.EndGroup()
		imgui.BeginGroup()
			imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.keysyncx, cfg.settings.keysyncy), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
			imgui.Begin('##keysync', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
			if doesCharExist(target) then
				local plState = (isCharOnFoot(target) and "onfoot" or "vehicle")
				imgui.SetCursorPosX(8)  						
					
				KeyCap("TAB", (array.keys[plState]["TAB"] ~= nil), imgui.ImVec2(45, 30)); imgui.SameLine()
				KeyCap("Q", (array.keys[plState]["Q"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
				KeyCap("W", (array.keys[plState]["W"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
				KeyCap("E", (array.keys[plState]["E"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
				KeyCap("R", (array.keys[plState]["R"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
	
	
				KeyCap("RM", (array.keys[plState]["RKM"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
				KeyCap("LM", (array.keys[plState]["LKM"] ~= nil), imgui.ImVec2(33, 30))					
	
	
				KeyCap("Shift", (array.keys[plState]["Shift"] ~= nil), imgui.ImVec2(45, 30)); imgui.SameLine()
				KeyCap("A", (array.keys[plState]["A"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
				KeyCap("S", (array.keys[plState]["S"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
				KeyCap("D", (array.keys[plState]["D"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
				KeyCap("C", (array.keys[plState]["C"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
				
				KeyCap("Enter", (array.keys[plState]["Enter"] ~= nil), imgui.ImVec2(77, 30))
	
				KeyCap("Ctrl", (array.keys[plState]["Ctrl"] ~= nil), imgui.ImVec2(45, 30)); imgui.SameLine()
				KeyCap("Alt", (array.keys[plState]["Alt"] ~= nil), imgui.ImVec2(35, 30)); imgui.SameLine()
				KeyCap("Space", (array.keys[plState]["Space"] ~= nil), imgui.ImVec2(205, 30))
			else
				imgui.Text(u8"Игрок потерян из поля видимости\nЕсли игрок так и не появился в поле видимости:\nQ - покинуть рекон, R - обновить в ручную.\nНачинаю процесс автоматического обновления рекона...")
				auto_update_recon()
			end
			imgui.End()
		imgui.EndGroup()
		imgui.BeginGroup()
			imgui.SetNextWindowPos(imgui.ImVec2((sw*0.5)-300, sh-65))
			imgui.Begin("##recon+", nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
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
				imgui.OpenPopup('ban')
			end
			imgui.SameLine()
			if imgui.Button(u8'Посадить в тюрьму') then
				imgui.OpenPopup('jail')
			end
			imgui.SameLine()
			if imgui.Button(u8'Выдать мут') then
				imgui.OpenPopup('mute')
			end
			imgui.SameLine()
			if imgui.Button(u8'Кикнуть игрока') then
				imgui.OpenPopup('kick')
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
				sampSendChat('/reoff')
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
				printStyledString('~n~~w~update...', 200, 4)
				sampSendClickTextdraw(array.textdraw.refresh)
				keysync(control_player_recon)
			end
			imgui.Tooltip('R')
			if wasKeyPressed(VK_RBUTTON) and not (sampIsChatInputActive() or sampIsDialogActive()) then
				lua_thread.create(function()
					setVirtualKeyDown(70, true)
					wait(150)
					setVirtualKeyDown(70, false)
				end)
			end
			if imgui.BeginPopup('mute') then
				imgui.CenterText(u8'Выберите причину')
				for k,v in pairs(basic_command.mute) do
					local name = string.gsub(v, '/mute _ (%d+) ', '')
					if not string.sub(v, -3):find('x(%d+)')  then
						if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
							sampSendChat(string.gsub(v, '_', control_player_recon))
						end
					end
				end
				imgui.EndPopup()
			elseif imgui.BeginPopup('jail') then
				imgui.CenterText(u8'Выберите причину')
				for k,v in pairs(basic_command.jail) do
					if not string.sub(v, -3):find('x(%d+)')  then
						local name = string.gsub(v, '/jail _ (%d+) ', '')
						if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
							sampSendChat(string.gsub(v, '_', control_player_recon))
						end
					end
				end
				imgui.EndPopup()
			elseif imgui.BeginPopup('ban') then
				imgui.CenterText(u8'Выберите причину')
				for k,v in pairs(basic_command.ban) do
					local name = string.gsub(string.gsub(string.gsub(v, '/ban _ (%d+) ', ''), '/siban _ (%d+) ', ''), '/iban _ (%d+) ', '')
					if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
						sampSendChat(string.gsub(v, '_', control_player_recon))
					end
				end
				imgui.EndPopup()
			elseif imgui.BeginPopup('kick') then
				imgui.CenterText(u8'Выберите причину')
				for k,v in pairs(basic_command.kick) do
					local name = string.gsub(v, '/kick _ ', '')
					if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
						sampSendChat(string.gsub(v, '_', control_player_recon))
					end
				end
				imgui.EndPopup()
			end
			imgui.End()
		imgui.EndGroup()
		imgui.PopFont()
		imgui.End()
	end
	if array.windows.custom_ans.v then -- свой ответ в репорт
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2((sw*0.5)+15, sh*0.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Мой ответ', array.windows.custom_ans, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if wasKeyPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end
		if not array.windows.fast_report.v then array.windows.custom_ans.v = false end
		imgui.PushFont(fontsize)
		if imgui.RadioButton(u8"ID скинов", array.checkbox.custom_ans, 0) then
			if not skin then
				skin = {}
				for i = 0, 311 do
					skin[#skin+1] = imgui.CreateTextureFromFile('moonloader\\'..'\\resource\\skin\\skin_'..i..'.png')
				end
			end
		end
		imgui.SameLine()
		if imgui.RadioButton(u8"ID цветов", array.checkbox.custom_ans, 1) then
			if not html_color then
				html_color = {}
				local file_color = io.open('moonloader\\' .. "\\resource\\skin\\color.txt","r")
				if file_color then for line in file_color:lines() do html_color[#html_color + 1] = u8:decode(line);end file_color:close() end
			end
		end 
		imgui.SameLine()
		if imgui.RadioButton(u8"Названия авто", array.checkbox.custom_ans, 2) then
			if not array.auto then
				array.auto = {}
				for i = 400, 611 do
					array.auto[#array.auto+1] = imgui.CreateTextureFromFile('moonloader\\'..'\\resource\\auto\\vehicle_'..i..'.png')
				end
			end
		end
		imgui.Separator()
		if array.checkbox.custom_ans.v == 0 then
			imgui.CenterText(u8'Выбранный скин будет дополнен к вашему ответу.')
			for i = 1, 312 do
				imgui.Image(skin[i], imgui.ImVec2(75, 150))
				if imgui.IsItemClicked(0) then array.buffer.text_ans.v = array.buffer.text_ans.v .. ('ID: '..i-1) ..' ' end
				if i%9~=0 then imgui.SameLine() end
			end
		elseif array.checkbox.custom_ans.v == 1 then
			imgui.CenterText(u8'Выбранный цвет будет дополнен к вашему ответу.')
			for i = 1, 256 do 
				imgui.TextColoredRGB(u8(html_color[i]))
				if imgui.IsItemClicked(0) then array.buffer.text_ans.v = array.buffer.text_ans.v .. string.sub(string.sub(html_color[i], 1, 7), 2) .. ' ' end 
				if i%7~=0 then imgui.SameLine() end 
			end
		elseif array.checkbox.custom_ans.v == 2 then
			imgui.CenterText(u8'Выбранный транспорт будет дополнен к вашему ответу.')
			imgui.NewInputText('##SearchBar3', array.buffer.find_custom_answer, sw*0.5, u8'Фильтр транспорта', 2)			
			for i = 1, 212 do
				if string.lower(array.name_car[i]):find(string.lower(array.buffer.find_custom_answer.v)) then
					imgui.Image(array.auto[i], imgui.ImVec2(120, 100))
					if imgui.IsItemClicked(0) then array.buffer.text_ans.v =  array.buffer.text_ans.v .. array.name_car[i]..' ' end
					imgui.SameLine()
					imgui.Text(array.name_car[i])
					if i%3>0 then imgui.SameLine() end
				end
			end
		end
		imgui.PopFont()
		imgui.End()
	end
	if array.windows.answer_player_report.v then -- помощь после слежки в реконе
		imgui.SetNextWindowPos(imgui.ImVec2(sw-250, 0), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Помощь после выхода из рекона", array.windows.answer_player_report.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'Вы закончили слежку по репорту')
		imgui.CenterText(u8'Доложить информацию?')
		if imgui.Button(u8'Нарушений не наблюдаю (1)', imgui.ImVec2(250, 25)) or (wasKeyPressed(VK_1) and not (sampIsChatInputActive() or sampIsDialogActive())) then
			sampProcessChatInput('/n ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		imgui.Tooltip('/n ' .. copies_player_recon)
		if imgui.Button(u8'Данный игрок чист (2)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_2) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/cl ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		imgui.Tooltip('/cl ' .. copies_player_recon)
		if imgui.Button(u8'Игрок наказан. (3)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_3) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/nak ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		imgui.Tooltip('/nak ' .. copies_player_recon)
		if imgui.Button(u8'Помогли вам. (4)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_4) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/pmv ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		imgui.Tooltip('/pmv ' .. copies_player_recon)
		if imgui.Button(u8'Игрок AFK (5)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_5) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/afk ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		imgui.Tooltip('/afk ' .. copies_player_recon)
		if imgui.Button(u8'Игрок не в сети (6)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_6) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/nv ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		imgui.Tooltip('/nv ' .. copies_player_recon)
		if imgui.Button(u8'Это донат-преимущества (7)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_7) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/dpr ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		imgui.Tooltip('/dpr ' .. copies_player_recon)
		if (wasKeyPressed(VK_RBUTTON) or wasKeyPressed(VK_F)) and not (sampIsChatInputActive() or sampIsDialogActive()) then
			if sampIsCursorActive() then showCursor(false,false)
			else showCursor(true,false) end
		end
		imgui.CenterText(u8'Нажми нужную клавишу, либо курсором')
		imgui.CenterText(u8'Активация курсора: ПКМ или F')
		imgui.CenterText(u8'Меню активно 5 секунд.')
		if wasKeyPressed(VK_ESCAPE) then copies_player_recon = nil  array.windows.answer_player_report.v = false end
		imgui.End()
	end
	if array.windows.render_admins.v then -- рендер админов
		imgui.ShowCursor = false
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.render_admins_positionX, cfg.settings.render_admins_positionY))
		imgui.Begin('##render_admins.', array.windows.render_admins, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
		for i = 1, #array.admins do imgui.TextColoredRGB(array.admins[i]) end
        imgui.End()
	end
	if array.windows.pravila.v then -- ahelp
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5,0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw*0.5,sh*0.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Помощь', array.windows.pravila, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.RadioButton(u8"Правила", array.checkbox.checked_radio_button, 1)
		imgui.SameLine()
		imgui.RadioButton(u8"Быстрые команды", array.checkbox.checked_radio_button, 2)
		imgui.SameLine()
		imgui.RadioButton(u8"Серверные команды", array.checkbox.checked_radio_button, 3)
		if wasKeyPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end
		if array.checkbox.checked_radio_button.v == 1 then
			imgui.NewInputText('##SearchBar6', array.buffer.find_rules, sw*0.5, u8'Поиск по правилам', 2)
			for i = 1, #array.pravila do
				if string.rlower(u8:decode(array.pravila[i])):find(string.rlower(u8:decode(array.buffer.find_rules.v))) then
					if not (array.pravila[i]:find('%[%d+ lvl%]')) then
						imgui.TextWrapped(array.pravila[i])
					end
				end
			end
		elseif array.checkbox.checked_radio_button.v == 2 then
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
				server = "amogus babous",
				custom = "Мои команды",
			}
			for name, _ in pairs(basic_command) do
				if name ~= "server" and imgui.CollapsingHeader( u8(command[name]) ) then
					for k,v in pairs(basic_command[name]) do
						if not tonumber( string.sub(k, -1) ) then 
							local v = string.gsub( v, '_', '[ID]')
							imgui.TextWrapped(u8(k ..' = '.. string.gsub(v, '\n', '\n		') ))
						end
					end
				end
			end
		elseif array.checkbox.checked_radio_button.v == 3 then
			for i = 1, 18 do
				if imgui.CollapsingHeader(u8('Уровень доступа - ' .. i)) then
					for b = 1, #array.pravila do
						if array.pravila[b]:find('%['..i..' lvl%]') then
							imgui.Text(string.gsub(array.pravila[b], '%[%d+ lvl%]', ''))
						end
					end
				end
			end
		end
		imgui.PopFont()
		imgui.End()
	end
	if array.windows.menu_chatlogger.v then -- chatlogger
		if wasKeyPressed(VK_ESCAPE) then array.windows.menu_chatlogger.v = false end
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw*0.7, sh*0.8), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Логирование чата', array.windows.menu_chatlogger, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.IsWindowAppearing() then chat = {1, 500, 1} end -- 1 параметр начало массива, 2 параметр - конец массива, 3 - страница.
		imgui.PushFont(fontsize)
		imgui.CenterText(u8'Выберите файл для просмотра')
		imgui.Text(u8'Примечание: Нажатие по тексту - копирует его в буфер обмена\nСкриншот данного окна можно использовать ввиде доказазательств.\nВ целях уменьшения нагрузки на ваш компьютер, данное окно обновляется каждый перезаход в игру.')
		imgui.PushItemWidth(sw*0.7 - 30)
		if imgui.Combo('##chatlog', array.checkbox.option_find_log, array.files_chatlogs, array.checkbox.option_find_log) then chat = {1, 500, 1} end
		imgui.NewInputText('##searchlog', array.buffer.find_log, (sw*0.7)-30, u8'Сортировка текста', 2)
		imgui.PopItemWidth()
		if array.checkbox.option_find_log.v == 0 then 	--= ОСТОРОЖНО, ПРИ ИЗМЕНЕНИЯХ, ЗАВИСИМОСТЬ ОТ ЦИФР'
			if #array.chatlog_1 > 500 then
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
							elseif #array.chatlog_1 == chat[2] then
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
					if #array.chatlog_1~=chat[2] then
						if #array.chatlog_1 < chat[2] + 500 then chat[1] = chat[2] chat[2] = #array.chatlog_1
						else chat[1] = chat[2] chat[2] = chat[2] + 500 end
						chat[3] = chat[3] + 1
					end
				end
				if chat[2] ~= #array.chatlog_1 then
					imgui.SameLine()
					if imgui.Button('-->>') then
						chat[2] = #array.chatlog_1
						if chat[2] > 499 then
							chat[1] = chat[2] - 500
						end
						chat[3] = (chat[2] / 500)
						chat[3] = chat[3] - chat[3] % 1
					end
				end
			else chat[2] = #array.chatlog_1 end
			check_chat = array.chatlog_1
		end
		if array.checkbox.option_find_log.v == 1 then
			if #array.chatlog_2 > 500 then
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
							elseif #array.chatlog_2 == chat[2] then
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
					if #array.chatlog_2~=chat[2] then
						if #array.chatlog_2 < chat[2] + 500 then chat[1] = chat[2] chat[2] = #array.chatlog_2
						else chat[1] = chat[2] chat[2] = chat[2] + 500 end
						chat[3] = chat[3] + 1
					end
				end
				if chat[2] ~= #array.chatlog_2 then
					imgui.SameLine()
					if imgui.Button('-->>') then
						chat[2] = #array.chatlog_2
						if chat[2] > 499 then
							chat[1] = chat[2] - 500
						end
						chat[3] = (chat[2] / 500)
						chat[3] = chat[3] - chat[3] % 1
					end
				end
			else chat[2] = #array.chatlog_2 end
			check_chat = array.chatlog_2
		end
		if array.checkbox.option_find_log.v == 2 then
			if #array.chatlog_3 > 500 then
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
							elseif #array.chatlog_3 == chat[2] then
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
					if #array.chatlog_3~=chat[2] then
						if #array.chatlog_3 < chat[2] + 500 then chat[1] = chat[2] chat[2] = #array.chatlog_3
						else chat[1] = chat[2] chat[2] = chat[2] + 500 end
						chat[3] = chat[3] + 1
					end
				end
				if chat[2] ~= #array.chatlog_3 then
					imgui.SameLine()
					if imgui.Button('-->>') then
						chat[2] = #array.chatlog_3
						if chat[2] > 499 then
							chat[1] = chat[2] - 500
						end
						chat[3] = (chat[2] / 500)
						chat[3] = chat[3] - chat[3] % 1
					end
				end
			else chat[2] = #array.chatlog_3 end
			check_chat = array.chatlog_3
		end
		if imgui.BeginPopup('raskl') then
			imgui.Text(u8'Смените вашу раскладку клавиатуры на английский язык для копирования данной строки.')
			imgui.EndPopup()
		end
		if imgui.BeginPopup('scop') then
			imgui.Text(u8'Скопировано.')
			imgui.EndPopup()
		end
		for i = chat[1], chat[2] do
			local txt = u8:decode(array.buffer.find_log.v)
			if string.rlower(  string.gsub(check_chat[i], "%p","")     )    :find      (   string.rlower(    string.gsub(txt, '%p', '')  )     )      then

				imgui.BeginGroup() -- для того чтобы при нажатии на текст срабатывало действие
					imgui.TextColoredRGB(check_chat[i])
				imgui.EndGroup()

				if imgui.IsItemClicked(0) then
					if getCurrentLanguageName() ~= '00000419' then 
						imgui.OpenPopup('raskl')
					else
						imgui.OpenPopup('scop')
						setClipboardText(string.sub(string.gsub( string.gsub (check_chat[i], '{%w%w%w%w%w%w}', ''), '%[(%d+):(%d+):(%d+)%]', '' ), 2)) -- удаляем время, удаляем html color - copy
					end
				end
			end
		end
 		imgui.PopFont()
		imgui.End()
	end
end
function sampev.onSendCommand(command) -- Регистрация отправленных пакет-сообщений
	if string.sub(command, 1, 1) =='/' and string.sub(command, 1, 2) ~='/a' and not sampIsDialogActive() then
		if ( command:match('mute (.+) (.+) (.+)') or command:match('muteakk (.+) (.+) (.+)') or command:match('muteoff (.+) (.+) (.+)')) then
			back_punishment(6)
			if cfg.settings.forma_na_mute then
				printStyledString('send forms ...', 1000, 4)
				if cfg.settings.add_mynick_in_form then
					if #array.buffer.sokr_nick.v > 0 then SendChat('/a ' .. command .. ' // ' .. array.buffer.sokr_nick.v)
					else
						local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
					end
				else SendChat('/a ' .. command) end
				return false
			end
		elseif command:match('ban (%d+) (%d+) .+') or command:match('banoff (%d+) (%d+) .+') or command:match('banakk (%d+) (%d+) .+') then
			back_punishment(15)
			if cfg.settings.forma_na_ban then
				printStyledString('send forms ...', 1000, 4)
				if cfg.settings.add_mynick_in_form then
					if #array.buffer.sokr_nick.v > 0 then SendChat('/a ' .. command .. ' // ' .. array.buffer.sokr_nick.v)
					else
						local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
					end
				else SendChat('/a ' .. command) end
				return false
			end
		elseif (command:match('/jail (%d+) (%d+) .+') or command:match('/jailakk (%d+) (%d+) .+') or command:match('/jailoff (%d+) (%d+) .+')) then
			back_punishment(6)
			if cfg.settings.forma_na_jail then
				printStyledString('send forms ...', 1000, 4)
				if cfg.settings.add_mynick_in_form then
					if #array.buffer.sokr_nick.v > 0 then SendChat('/a ' .. command .. ' // ' .. array.buffer.sokr_nick.v)
					else
						local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
					end
				else SendChat('/a ' .. command) end
				return false
			end
		elseif command:match('/kick (%d+) (.+)') and cfg.settings.forma_na_kick then
			if sampIsPlayerConnected(command:match('(%d+)')) then
				printStyledString('send forms ...', 1000, 4)
				if cfg.settings.add_mynick_in_form then
					if #array.buffer.sokr_nick.v > 0 then SendChat('/a ' .. command .. ' // ' .. array.buffer.sokr_nick.v)
					else
						local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						SendChat('/a ' .. command .. ' // ' .. sampGetPlayerNickname(myid))
					end
				else SendChat('/a ' .. command) end
				return false
			end
		end
	end
end

function sampev.onServerMessage(color,text) -- Получение сообщений из чата
	log( '{'..('%x'):format(color):sub(9, 14)..'}'..text)
	if cfg.settings.render_admins and (text:match('Время администратирования за сегодня:') or text:match('Ваша репутация:') or text:match('Всего администрации в сети:')) then
		return false
	elseif text:match("(.+)%((%d+)%) пытался написать в чат: .+") then
		sampAddChatMessage('',-1)
		sampAddChatMessage(text, 0xff6347) -- чтобы не пропускали такие сообщения
		sampAddChatMessage('',-1)
		return false
	elseif text:match('%[A%] NEARBY CHAT: .+') or text:match('%[A%] SMS: .+') then
		array.checkbox.check_render_ears.v = true
		local sokr_text = string.gsub( string.sub( string.gsub (string.gsub(string.gsub(string.gsub(text, 'NEARBY CHAT: ', '{87CEEB}'), 'SMS: ','{D8BFD8}'), ' отправил ', ''), ' игрока ', ''), 5), ' |(.+)%((%d+)%)', '')
		if #sokr_text > 40 then sokr_text = string.sub(sokr_text, 1, 40).."..." end
		local sokr_text = "{696969}PM: " .. sokr_text
		if #array.ears == cfg.settings.strok_ears then
			for i = 0, #array.ears_minimal do
				if i ~= #array.ears_minimal then array.ears_minimal[i] = array.ears_minimal[i + 1]
				else array.ears_minimal[#array.ears_minimal] = sokr_text end
			end
		else array.ears_minimal[#array.ears_minimal + 1] = sokr_text end
		local text = string.gsub(text, 'NEARBY CHAT:', os.date("[%H:%M:%S] ")..'{87CEEB}AT-NEAR:{FFFFFF}')
		local text = string.gsub(text, 'SMS:', os.date("[%H:%M:%S] ")..'{D8BFD8}AT-SMS:{FFFFFF}')
		local text = string.gsub(text, ' отправил ', '')
		local text = string.gsub(text, ' игроку ', '->')
		local text = string.sub(text, 5) -- удаляем [A]
		if #array.ears == cfg.settings.strok_ears then
			for i = 0, #array.ears do
				if i ~= #array.ears then array.ears[i] = array.ears[i + 1]
				else array.ears[#array.ears] = text end
			end
		else array.ears[#array.ears + 1] = text end
		return false
	elseif text:match("%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]:") then
		if cfg.settings.find_form then
			for i = 1, #array.spisok_in_form do
				if text:find(array.spisok_in_form[i]) and not AFK then
					while true do -- пока цикл не будет прерван
						array.admin_form = {}
						local find_admin_form = string.gsub(text, '%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: {%w%w%w%w%w%w}', '')
						if string.sub(find_admin_form, 1, 1) == '/' then
							array.admin_form.idadmin = tonumber(text:match('%[(%d+)%]'))
							array.admin_form.forma = find_admin_form
							if find_admin_form:find('unban (.+)') then
								array.admin_form.bool = true
								array.admin_form.timer = os.clock()
								array.admin_form.sett = true
								array.admin_form.styleform = true
								wait_accept_form()
								break
							end
							if find_admin_form:find('off (.+)') or find_admin_form:find('akk (.+)') then
								array.admin_form.bool = true
								array.admin_form.timer = os.clock()
								if (find_admin_form.sub(find_admin_form, 2)):find('//') then array.admin_form.styleform = true end
								array.admin_form.sett = true
								wait_accept_form()
								break
							end
							array.admin_form.probid = string.match(array.admin_form.forma, '%d[%d.,]*')
							if array.admin_form.probid and sampIsPlayerConnected(array.admin_form.probid) then
								array.admin_form.bool = true
								array.admin_form.timer = os.clock()
								array.admin_form.nickid = sampGetPlayerNickname(array.admin_form.probid)
								if (find_admin_form.sub(find_admin_form, 2)):find('//') then array.admin_form.styleform = true end
								array.admin_form.sett = true
								wait_accept_form()
								text = text .. " {A9A9A9}(" ..array.admin_form.nickid..")"
								break
							else
								array.admin_form = {}
								text = text .. " {A9A9A9}(Не в сети)"
								break
							end
						else break end
					end
				end
			end
		end
		if cfg.settings.admin_chat then
			local admlvl, prefix, nickadm, idadm, admtext  = text:match('%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.+)')
			local messange = os.date("[%H:%M:%S] ")..'{C0C0C0}[A-'..admlvl..'] '..(string.sub(prefix, 2) .. ' ' ..  nickadm .. '(' .. idadm .. '): '.. admtext)
			if #admtext > 60 then admtext = string.sub(admtext, 1, 60).."..." end
			local messange_min = '{C0C0C0}[A-'..admlvl..'] '..(string.match(string.sub(prefix,2), '{%w%w%w%w%w%w}').. nickadm..'['..idadm..']: '.. admtext)
			if #array.adminchat == cfg.settings.strok_admin_chat then
				for i = 0, #array.adminchat_minimal do
					if i ~= #array.adminchat_minimal then array.adminchat_minimal[i] = array.adminchat_minimal[i+1]
					else array.adminchat_minimal[#array.adminchat_minimal] = messange_min end
				end
			else array.adminchat_minimal[#array.adminchat_minimal + 1] = messange_min end

			if #array.adminchat == cfg.settings.strok_admin_chat then
				for i = 0, #array.adminchat do
					if i ~= #array.adminchat then array.adminchat[i] = array.adminchat[i+1]
					else array.adminchat[#array.adminchat] = messange end
				end
			else array.adminchat[#array.adminchat + 1] = messange end
			return false
		end
	elseif not AFK then
		local text = string.gsub(text, '|', '%|')
		if cfg.settings.automute and (text:match("%((%d+)%): (.+)") or text:match("%[(%d+)%]: (.+)")) 			and not (text:match("%[a%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]:") or text:match('написал %[(%d+)%]:') or text:match('ответил (.+)%[(%d+)%]: ')) then
			local report = false
			if text:match('Жалоба (.+) %| {AFAFAF}(.+)%[(%d+)%]: {ffffff}.+') then 
				report = true
				oskid = text:match('%[(%d+)%]')
				text = string.gsub(text,'Жалоба (.+) %| ', '')
			else 
				if text:match('%((%d+)%)') then oskid = text:match('%((%d+)%)') text = string.gsub(text, ".+%((%d+)%):",'')
				else oskid = text:match('%[(%d+)%]') text = string.gsub(text, ".+%[(%d+)%]:", '') end
			end
			local text = text:rlower() .. ' '
			local text = string.gsub(text, '{%w%w%w%w%w%w}', '')
			if cfg.settings.smart_automute then
				for i = 1, #cfg.spisokoskrod do -- МАССИВ НАЧИНАЕТСЯ С 1
					if text:match(' '.. cfg.spisokoskrod[i]) then
						automute(cfg.spisokoskrod[i], oskid, text, '5000 Оскорбление родни', report)
						return false
					end
				end
				for i = 1, #cfg.spisokrz do -- МАССИВ НАЧИНАЕТСЯ С 1
					if text:match(' '..cfg.spisokrz[i]) then
						automute(cfg.spisokrz[i], oskid, text, '5000 Розжиг Межнац.Розни',report)
						return false
					end
				end
				for i = 1, #cfg.spisokproject do -- МАССИВ НАЧИНАЕТСЯ С 1
					if text:match(' ' .. cfg.spisokproject[i]) then
						automute(cfg.spisokproject[i], oskid, text, '1000 Упом.стор.проектов',report)
						lua_thread.create(function()
							if cfg.settings.auto_cc then
								wait(3000)
								sampSendChat('/cc')
								wait(2000)
								sampAddChatMessage(tag..'Чат очищен. Нарушитель - ' .. sampGetPlayerNickname(oskid)..'('..oskid..'), слово - ' .. cfg.spisokproject[i], -1)
							else sampAddChatMessage(tag .. 'Рекомендуется произвести очистку чата /cc', -1) end
						end)
						return false
					end
				end
			end
			for i = 1, #array.osk do	-- МАССИВ НАЧИНАЕТСЯ С 1
				if not text:match(' я ') and text:match('%s'.. array.osk[i]) then
					for a = 1, #cfg.spisokor do
						if text:match(cfg.spisokor[a]) then
							automute(cfg.spisokor[a], oskid, text, '5000 Оскорбление родни',report)
							return false
						end
					end
					for a = 1, #cfg.spisokoskadm do
						if text:match(cfg.spisokoskadm[a]) then
							automute(cfg.spisokoskadm[a], oskid, text, '2500 Оскорбление администрации',report)
							return false
						end
					end
					automute(array.osk[i], oskid, text, '400 Оскорбление/Унижение',report)
					return false
				end
			end
			for i = 1, #array.mat do -- МАССИВ НАЧИНАЕТСЯ С 1
				if text:match(' '.. array.mat[i]) then
					for a = 1, #cfg.spisokor do
						if text:match(cfg.spisokor[a]) then
							automute(cfg.spisokor[a], oskid, text, '5000 Оскорбление родни',report)
							return false
						end
					end
					for a = 1, #cfg.spisokoskadm do
						if text:match(cfg.spisokoskadm[a]) then
							automute(cfg.spisokoskadm[a], oskid, text, '2500 Оскорбление администрации',report)
							return false
						end
					end
					automute(array.mat[i], oskid, text, '300 Нецензурная лексика',report)
					return false
				end
			end
			if array.flood.message[oskid] then
				if ( array.flood.message[oskid] ~= text ) or  ( (os.clock() - array.flood.time[oskid]) > 30 ) then 
					array.flood.message[oskid] = text
					array.flood.time[oskid] = os.clock()
					array.flood.count[oskid] = 1
					array.flood.nick[oskid] = sampGetPlayerNickname(oskid)
				else
					if array.flood.count[oskid] == 3 and cfg.settings.smart_automute then -- если 4 сообщения то мут, счетчик от 0
						array.flood.message[oskid] = nil
						lua_thread.create(function()
							while sampIsDialogActive() do wait(0) end
							sampAddChatMessage(tag .. 'Обнаружен флуд в чате! Нарушитель ' .. sampGetPlayerNickname(oskid)..'['..oskid..']', -1)
							sampAddChatMessage(tag .. 'Отправил 4 сообщения за ' .. math.ceil(os.clock() - array.flood.time[oskid]) .. '/30 сек.', 0xA9A9A9)
							sampAddChatMessage('{CD853F}Flood {ffffff}- '..sampGetPlayerNickname(oskid)..'['..oskid..']: '..text, -1)
							sampSendChat('/mute ' .. oskid .. ' 120 Флуд/Cпам')
						end)
					else array.flood.count[oskid] = array.flood.count[oskid] + 1 end
				end
			else
				array.flood.message[oskid] = text
				array.flood.time[oskid] = os.clock()
				array.flood.count[oskid] = 1
				array.flood.nick[oskid] = sampGetPlayerNickname(oskid)
			end
			for k,v in pairs(cfg.auto_ban) do
				if text:match(v) then
					lua_thread.create(function()
						while sampIsDialogActive() do wait(0) end
						sampAddChatMessage(tag .. 'Запретное слово: ' .. v,-1)
						sampProcessChatInput('/rk ' ..oskid)
					end)
					return text
				end
			end
		elseif text:match('%<AC%-WARNING%> {ffffff}(.+)%[(%d+)%]{82b76b} подозревается в использовании чит%-программ: {ffffff}Weapon hack %[code: 015%]%.') and cfg.settings.weapon_hack then
			if not sampIsDialogActive() then 
				lua_thread.create(function()
					while sampIsChatInputActive() do wait(1) end
					sampSendChat('/iwep '.. string.match(text, "%[(%d+)%]"))
				end)
			end
			return false
		end
	end
end
function automute(array, oskid, text, nakaz, report)
	local colorc = '{00BFFF}'
	if report then 
		command = '/rmute ' 
		rcommand = 'REPORT'
	else 
		command = '/mute ' 
		rcommand = 'CHAT' 
	end
	if string.sub(array,-1 ) == 's' then array = string.sub(array,1,-3) end
	local text = string.gsub(text, array, '{F08080}'..array.."{ffffff}")
	if cfg.settings.option_automute == 1 then
		sampAddChatMessage(colorc..'===================={'..color()..'} AutoMute AT '..colorc..'====================', -1)
		sampAddChatMessage(colorc..'['..rcommand..']{D3D3D3} '..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. colorc..' ['..rcommand..']', -1)
		sampAddChatMessage(colorc..'===================={'..color()..'} AutoMute AT '..colorc..'====================', -1)
		if not sampIsDialogActive() then sampSendChat(command..oskid..' '..nakaz) end
	else
		lua_thread.create(function()
			local nakaz_name = string.gsub(nakaz, textSplit(nakaz, ' ')[1]..' ', '')
			sampAddChatMessage(colorc..'===================={'..color()..'} AutoMute AT '..colorc..'====================', -1)
			sampAddChatMessage('{E6E6FA}Выдать мут по причине: "{90EE90}' ..nakaz_name ..'{E6E6FA}"? Клавиша {A9A9A9}'..cfg.settings.key_automute ..'{E6E6FA} для подтверждения',-1)
			sampAddChatMessage('{00BFFF}['..rcommand..'] {FFF0F5}'..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text..' {00BFFF}['..rcommand..']', -1)
			sampAddChatMessage(colorc..'===================={'..color()..'} AutoMute AT '..colorc..'====================', -1)
			local count = cfg.settings.sek_automute * 100
			local time = cfg.settings.sek_automute
			while count ~= 0 do
				wait(1)
				if wasKeyPressed(strToIdKeys(cfg.settings.key_automute)) and not sampIsDialogActive() and not sampIsChatInputActive() then
					if sampIsPlayerConnected(oskid) then sampSendChat(command..oskid..' '..nakaz)
					else sampAddChatMessage(tag .. 'Игрок не в сети.', -1) end
					break
				end
				renderFontDrawText(font_adminchat, 'Время на действие: ' .. time ..' сек.', sw-400, 10, 0xCCFFFFFF)
				count = count - 1
				if count%100==0 then time = time-1 end
			end
		end)
	end
end

function sampev.onShowTextDraw(id, data) -- Считываем серверные текстдравы
	if cfg.settings.on_custom_recon_menu then
		for k,v in pairs(data) do
			local v = tostring(v)
			if v == 'REFRESH' then 
				lua_thread.create(function()
					wait(0) -- даем время появится текстдраву
					array.textdraw.refresh = id  -- записываем ид кнопки обновить в реконе
					sampTextdrawSetStyle(array.textdraw.refresh, -1)
				end)
			elseif v:match('~n~') then
				if not v:match('~g~') then
					array.textdraw.inforeport = id  -- инфо панель в реконе
					lua_thread.create(function()
						wait(1) -- даем время появится текстдраву
						sampTextdrawSetStyle(array.textdraw.inforeport, -1) -- превращаем в невидимый стиль
						while not array.windows.recon_menu.v do wait(100) end
						while array.windows.recon_menu.v do
							array.inforeport = textSplit(sampTextdrawGetString(array.textdraw.inforeport), "~n~") -- информация о игроке, считывание с текстрдрава
							if array.inforeport[3] ==   '-1'   then array.inforeport[3] = false end  --========= ХП АВТО
							--=========== Название ВИП =======--------
							if array.inforeport[11] == '1' then array.inforeport[11] = 'Standart'
							elseif array.inforeport[11] == '2' then array.inforeport[11] = 'Premium'
							elseif array.inforeport[11] == '3' then array.inforeport[11] = '{87CEEB}Diamond'
							elseif array.inforeport[11] == '4' then array.inforeport[11] = '{FF00FF}Platinum'
							elseif array.inforeport[11] == '5' then array.inforeport[11] = '{DAA520}Personal' end
							--=========== Название ВИП =======--------
							wait(1000)
						end
					end)
				else return false end
			elseif v:match('(.+)%((%d+)%)') then
				array.textdraw.name_report = id
				control_player_recon = tonumber(string.match(v, '%((%d+)%)')) -- ник игрока в реконе
				if control_player_recon ~= nil then
					array.windows.recon_menu.v = true
					imgui.Process = true
					return false
				end
			elseif v == 'STATS' then 
				array.textdraw.stats = id
				lua_thread.create(function()
					wait(2) -- даем время появится текстдраву 
					sampTextdrawSetStyle(array.textdraw.stats, -1)
					if cfg.settings.keysync then keysync(control_player_recon) end
				end)
			elseif v == 'CLOSE' then return false
			elseif v == 'BAN' then return false
			elseif v == 'MUTE' then return false
			elseif v == 'KICK' then return false
			elseif v == 'JAIL' then return false end
		end
		------=========== Удаляем лишние текстдравы, сравнивая их с массивом =======---------------
		if DELETE_TEXTDRAW_RECON[id] then return false end
	end
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text) -- Работа с открытими ДИАЛОГАМИ
	local closeDialog = function(id)
		if cfg.settings.nodialog then 
			return true
		else
			lua_thread.create(function()
				wait(0)
				sampSendDialogResponse(id, 0)
				sampCloseCurrentDialogWithButton(1)
			end)
			return false
		end
	end
	if title == '{ff8587}Администрация проекта (онлайн)' and cfg.settings.render_admins then
		sampSendDialogResponse(dialogId, 1, 0)
		lua_thread.create(function()
			array.admins = textSplit(text, '\n')
			local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			array.admins[#array.admins] = nil -- последний пункт диалога пустой
			for i = 1, #array.admins do
				local rang = string.sub(string.gsub(string.match(array.admins[i], '(%(.+)%)'), '(%(%d+)%)', ''), 3) --{FFFFFF}N.E.O.N(0) | Уровень: {ff8587}18{FFFFFF} | Выговоры: {ff8587}0 из 3{FFFFFF} | Репутация: {ff8587}60
				array.admins[i] = string.gsub(array.admins[i], '{%w%w%w%w%w%w}', "")
				local afk = string.match(array.admins[i], 'AFK: (.+)')
				local name, id, _, lvl, _, _ = string.match(array.admins[i], '(.+)%((%d+)%) %((.+)%) | Уровень: (%d+) | Выговоры: (%d+) из 3 | Репутация: (.+)')
				array.admins[i] = string.gsub(array.admins[i], 'Репутация: (.+)', "")
				if #rang > 2 then
					if afk then array.admins[i] = name .. '(' .. id .. ') ' .. rang .. ' ' .. lvl .. ' AFK: ' .. afk
					else array.admins[i] = name .. '(' .. id .. ') ' .. rang .. ' '.. lvl end
				else
					_, id, lvl = string.match(array.admins[i], '(.+)%((%d+)%) | Уровень: (%d+)')
					rang = 'Отсутствует'
				end
				if cfg.settings.autoprefix then
					local color1, name,color2 = string.match(rang, '{%w%w%w%w%w%w}(.+){%w%w%w%w%w%w}')
					if name then
						rang = '{'..color1..'}' .. name
					end
					local lvl, id = tonumber(lvl), tonumber(id)
					if id ~= myid and autoprefix_access and lvl then
						if (lvl > 0 and lvl < 10) and rang ~= '{'..cfg.settings.prefixma..'}Мл.Администратор' then
							sampAddChatMessage(tag .. 'У администратора ' .. sampGetPlayerNickname(id) .. ' обнаружен неверный префикс.', -1)
							sampAddChatMessage(tag .. 'Произвожу замену: ' .. rang .. ' -> {' .. cfg.settings.prefixma .. '}Мл.Администратор', -1)
							sampSendChat('/prefix ' .. id .. ' Мл.Администратор ' .. cfg.settings.prefixma)
							wait(10000)
							sampSendChat('/admins')
							sampAddChatMessage('Администратор '..sampGetPlayerNickname(id)..'['..id ..']\nБыл установлен новый префикс.\n' .. rang .. '-> Мл.Администратор.',-1)
						elseif (lvl > 11 and lvl < 15) and rang ~= '{'..cfg.settings.prefixa..'}Администратор' then
							wait(5000)
							sampAddChatMessage(tag .. 'У администратора ' .. sampGetPlayerNickname(id) .. ' обнаружен неверный префикс.', -1)
							sampAddChatMessage(tag .. 'Произвожу замену: ' .. rang .. ' -> {' ..cfg.settings.prefixa..'}Администратор', -1)
							sampSendChat('/prefix ' .. id .. ' Администратор ' .. cfg.settings.prefixa)
							wait(3000)
							sampSendChat('/admins')
							sampAddChatMessage('Администратор '..sampGetPlayerNickname(id)..'['..id ..']\nБыл установлен новый префикс.\n' .. rang .. '-> Администратор.',-1)
						elseif (lvl > 16 and lvl < 18) and rang ~= '{'..cfg.settings.prefixsa..'}Ст.Администратор' then
							wait(5000)
							sampAddChatMessage(tag .. 'У администратора ' .. sampGetPlayerNickname(id) .. ' обнаружен неверный префикс.', -1)
							sampAddChatMessage(tag .. 'Произвожу замену: ' .. rang .. ' -> {' .. cfg.settings.prefixsa..'}Ст.Администратор', -1)
							sampSendChat('/prefix ' .. id .. ' Ст.Администратор ' .. cfg.settings.prefixsa)
							wait(3000)
							sampSendChat('/admins')
							sampAddChatMessage('Администратор '..sampGetPlayerNickname(id)..'['..id ..']\nБыл установлен новый префикс.\n' .. rang .. '-> Ст.Администратор.',-1)
						end
					elseif lvl == 18 and rang ~= 'Ст.Администратор' and not autoprefix_access then
						autoprefix_access = true
						print('Вы из руководящего состава!')
						print('Автовыдача префикса была успешно инициализирована.')
					end
				end
			end
		end)
		if closeDialog(dialogID) then return false end
	elseif dialogId == 1098 then -- автоонлайн
		sampSendDialogResponse(1098, 1, math.floor(sampGetPlayerCount(false) / 10) - 1)
		if closeDialog(dialogID) then return false end
	elseif cfg.settings.weapon_hack and button1 == 'Готово' and button2 ~= 'Закрыть' then
		lua_thread.create(function()
			local text = textSplit(text, '\n')
			for i = 1, #text - 1 do
				local _,weapon, patron = text[i]:match('(%d+)	Weapon: (%d+)     Ammo: (.+)')
				if (text[i]:find('-')) or (weapon == '0' and patron ~= '0') then
					sampAddChatMessage(tag .. 'Пробиваемый игрок - ' .. title..'['..sampGetPlayerIdByNickname(title)..']',-1)
					sampAddChatMessage(tag .. 'Оружие (ID): ' .. weapon..'. Патроны: '..patron, -1)
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
				player_cheater = nil
				while sampIsDialogActive() do wait(0) end
				if sampGetPlayerIdByNickname(title) and sampIsPlayerConnected(tonumber(sampGetPlayerIdByNickname(title))) then
					sampSendChat('/iban '..sampGetPlayerIdByNickname(title)..' 7 Чит на оружие')
				else 
					sampSendChat('/banoff '..title..' 7 Чит на оружие')
				end
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
			else sampAddChatMessage(tag .. 'Устройство данного юзера - персональный компьютер', -1) end
			wait(0)
			sampCloseCurrentDialogWithButton(0)
		end)
	elseif title == 'Get Offline Stats' then -- окно /offstats где выбор между статистикой и авто используется для /sbanip
		if find_ip_player then sampSendDialogResponse(dialogId, 1, 0) if closeDialog(dialogID) then return false end end
		if regip then lua_thread.create(function() wait(0) sampCloseCurrentDialogWithButton(0) end) end
	elseif button1 == 'Закрыть' and find_ip_player then -- окно /offstats используется для /sbanip
		sampSendDialogResponse(dialogId,1,0)
		for k,v in pairs(textSplit(text, '\n')) do
			if k == 12 then 
				regip = string.sub(v, 17) 
			elseif k == 13 then 
				lastip = string.sub(v, 18) 
			end 
		end
		find_ip_player = false
		if closeDialog(dialogID) then return false end
	elseif dialogId == 2348 and array.windows.fast_report.v then array.windows.fast_report.v = false
	elseif dialogId == 2349 then -- окно с самим репортом.
		collectgarbage()
		array.answer, array.windows.answer_player_report.v, peremrep, myid, reportid = {}, false, nil, nil, nil
		local text = textSplit(text, '\n')
		text[1] = string.gsub(string.gsub(text[1], '{%w%w%w%w%w%w}', ''), 'Игрок: ', '')
		text[4] = string.gsub(string.gsub(text[4], '{%w%w%w%w%w%w}', ''), 'Жалоба: ', '')
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

				for i = 1, 512 do  -- [[[ FIX BUG INPUT TEXT IMGUI  ]]]
					imgui:GetIO().KeysDown[i] = false
				end
				for i = 1, 5 do
					imgui:GetIO().MouseDown[i] = false
				end
				imgui:GetIO().KeyCtrl = false
				imgui:GetIO().KeyShift = false
				imgui:GetIO().KeyAlt = false
				imgui:GetIO().KeySuper = false  

				array.windows.fast_report.v,imgui.Process=true,true
				wait(500)
				array.answer = {}
				while array.windows.fast_report.v and not (array.answer.rabotay or array.answer.uto4 or array.answer.nakajy or array.answer.customans or array.answer.slejy or array.answer.jb or array.answer.ojid or array.answer.moiotvet or array.answer.uto4id or array.answer.nakazan or array.answer.otklon or array.answer.peredamrep) do wait(100) end
				sampSendDialogResponse(dialogId,1,0)
			end
		end)
	elseif dialogId == 2350 then -- окно с возможностью принять или отклонить репорт
		array.windows.fast_report.v = false
		if not peremrep then
			if array.answer.rabotay then peremrep = ('Начал(а) работу по вашей жалобе!')
			elseif array.answer.slejy then
				if not reportid then peremrep = ('Отправляюсь в слежку') array.answer.slejy = nil
				elseif reportid and reportid ~= myid then
					if not sampIsPlayerConnected(reportid) then
						if reportid < 300 then
							peremrep = ('Указанный вами игрок под ' .. reportid .. ' ID находится вне сети.') 
							array.answer.slejy = nil
						else peremrep = ('Отправляюсь в слежку...') array.answer.control_player = true array.answer.slejy = false  end
					else peremrep = ('Отправляюсь в слежку за игроком ' .. sampGetPlayerNickname(reportid) .. '['..reportid..']') end
				elseif myid then if reportid == myid then peremrep = ('Вы указали мой ID (^_^)') array.answer.slejy = nil end end
			elseif array.answer.nakazan then peremrep = ('Данный игрок уже был наказан.')
			elseif array.answer.uto4id then peremrep = ('Уточните ID нарушителя в /report.')
			elseif array.answer.nakajy then peremrep = ('Будете наказаны за нарушение правил /report')  
			elseif array.answer.jb then peremrep = ('Напишите жалобу на forumrds.ru')
			elseif array.answer.peredamrep then peremrep = ('Передам ваш репорт.')
			elseif array.answer.rabotay then peremrep = ('Начал(а) работу по вашей жалобе.')
			elseif array.answer.customans then peremrep = array.answer.customans
			elseif array.answer.uto4 then peremrep = ('Обратитесь на форум по ссылке https://forumrds.ru')
			elseif #(array.buffer.text_ans.v) ~= 0 and #array.answer == 0 then
				if array.checkbox.button_enter_in_report.v and (not array.answer.moiotvet) and (#(array.buffer.text_ans.v) > 5) then
					for k,v in pairs(cfg.customotvet) do
						if string.rlower(v):find(string.rlower(u8:decode(array.buffer.text_ans.v))) or string.rlower(v):find(translateText(u8:decode(array.buffer.text_ans.v))) then
							peremrep = v 
							break
						end
					end
				end
				if not peremrep then 
					peremrep = u8:decode(array.buffer.text_ans.v)
					array.answer.moiotvet = true 
				end
			elseif array.answer.otklon then 
				sampSendDialogResponse(dialogId, 1, 2) 
				sampCloseCurrentDialogWithButton(0)
				if closeDialog(dialogID) then return false end
			end
		end
		if peremrep then
			if #(peremrep) > 80 then
				sampAddChatMessage(tag .. '{FFFFFF}Ваш ответ оказался слишком длинный {ff0000}' .. #peremrep..'{FFFFFF}/80 символов, попробуйте сократить текст.',-1)
				peremrep = nil
				lua_thread.create(function()
					wait(0)
					sampCloseCurrentDialogWithButton(0)
				end)
			else
				if cfg.settings.add_answer_report and (#peremrep + #(cfg.settings.mytextreport)) < 80 then peremrep = (peremrep ..('{'..color()..'} '..cfg.settings.mytextreport)) end
				if cfg.settings.addBeginText and (#peremrep + #(array.buffer.custom_addtext_report.v)) < 80 then peremrep = addBeginText().. peremrep end
				if cfg.settings.color_report and (#peremrep + 8) < 80 then
					if cfg.settings.color_report == '*' then peremrep = ('{'..color()..'}' .. peremrep)
					else peremrep = (cfg.settings.color_report .. peremrep) end
				end
				if #peremrep < 4 then peremrep = peremrep .. '       ' end			
				if cfg.settings.custom_answer_save and array.answer.moiotvet then cfg.customotvet[ #cfg.customotvet + 1 ] = u8:decode(array.buffer.text_ans.v) save() end	
				sampSendDialogResponse(dialogId, 1, 0)
				sampCloseCurrentDialogWithButton(0)
				array.buffer.text_ans.v = ''
				if closeDialog(dialogID) then return false end
			end
		end
	elseif dialogId == 2351 and peremrep then -- окно с ответом на репорт
		sampSendDialogResponse(dialogId, 1, 1, peremrep)
		lua_thread.create(function()
			while sampIsDialogActive() do wait(1) end
			if array.answer.control_player then sampSendChat('/re ' .. autorid)
			elseif array.answer.slejy then sampSendChat('/re ' .. reportid)
			elseif array.answer.peredamrep then sampSendChat('/a ' .. autor .. '[' .. autorid .. '] | ' .. textreport)
			elseif array.answer.nakajy then
				if not tonumber(autorid) or not sampIsPlayerConnected(autorid) then autorid = autor command = '/rmuteoff '
				else command = '/rmute ' end
				if array.nakazatreport.oftop then       sampSendChat(command  .. autorid .. ' 120 Оффтоп в /report')
				elseif array.nakazatreport.oskadm then  sampSendChat(command  .. autorid .. ' 2500 Оскорбление администрации')
				elseif array.nakazatreport.oskrep then  sampSendChat(command  .. autorid .. ' 400 Оскорбление/Унижение')
				elseif array.nakazatreport.poprep then  sampSendChat(command  .. autorid .. ' 120 Попрошайничество')
				elseif array.nakazatreport.oskrod then  sampSendChat(command  .. autorid .. ' 5000 Оскорбление/Упоминание родни')
				elseif array.nakazatreport.matrep then  sampSendChat(command  .. autorid .. ' 300 Нецензурная лексика')
				elseif array.nakazatreport.rozjig then  sampSendChat(command  .. autorid .. ' 5000 Розжиг')
				elseif array.nakazatreport.kl then      sampSendChat(command  .. autorid .. ' 3000 Клевета') end
				array.nakazatreport = {}
			end
			if array.answer.slejy then
				if not copies_player_recon and tonumber(autorid) and cfg.settings.answer_player_report then
					local copies_report_id = reportid
					copies_player_recon = autorid
					while not array.windows.recon_menu.v do wait(0) end
					while array.windows.recon_menu.v do wait(2000) end
					if copies_player_recon and copies_report_id == control_player_recon then
						if sampIsPlayerConnected(copies_player_recon) then
							imgui.Process, array.windows.answer_player_report.v = true, true
							for i = 0, 11 do wait(500) if not copies_player_recon or (copies_report_id ~= control_player_recon) then break end end
							if array.windows.answer_player_report.v then array.windows.answer_player_report.v = false copies_player_recon = nil end
						else sampAddChatMessage(tag .. 'Игрок, написавший репорт, находится вне сети.', -1) end
					end
				else copies_player_recon = nil end
			end
		end)
		if closeDialog(dialogID) then return false end
	elseif dialogId == 8991 then
		local text = textSplit(text, '{808080}')
		for i = 2, #text do
			if not text[i]:match("{03C03C}Имеется{FFFFFF}") then
				if text[i]:match("Доступ на 'Все виды банов'") then
					cfg.settings.forma_na_ban = true
					sampAddChatMessage(tag .. 'У вас отсутствует доступ на команды /ban, активированы автоформы.', -1)
				elseif text[i]:match("Доступ к '/tr'") then
					cfg.settings.atr = true
					sampAddChatMessage(tag .. 'У вас отсутствует команда /tr, активирована альтернатива, команда работает от имени АТ.', -1)
				elseif text[i]:match("Доступ на 'Выдачу тюрьмы'") then
					cfg.settings.forma_na_jail = true
					sampAddChatMessage(tag .. 'У вас отсутствует доступ на команды /jail, активированы автоформы.', -1)
				elseif text[i] then
					cfg.settings.forma_na_mute = true
					sampAddChatMessage(tag .. 'У вас отсутствует доступ на команды /mute, активированы автоформы.', -1)
				end
			end
		end
		save()
	end
end

function sampev.onDisplayGameText(style, time, text) -- скрывает текст на экране.
	if text == ('~w~RECON ~r~OFF') or text == ('~w~RECON ~r~OFF~n~~r~PLAYER DISCONNECT') then 
		array.windows.recon_menu.v = false 
		return false
	elseif text == ('~y~REPORT++') then
		if not AFK then
			if tr and not sampIsDialogActive() then sampSendChat("/ans") sampSendDialogResponse(2348, 1, 0) end
			if cfg.settings.notify_report then 
				printStyledString('~n~~p~REPORT ++', 1500, 4)
				local audio = loadAudioStream("moonloader/resource/report.mp3")
				setAudioStreamState(audio, 1)
				setAudioStreamVolume(audio, cfg.settings.sound_report) -- проигрывание и громкость звука
			end
		end
		return false
	end
end

function log(text, color) -- записываем лог
	if not AFK and #text > 8 then
		local data_today = os.date("*t") -- узнаем дату сегодня
		local log = ('moonloader\\config\\chatlog\\chatlog '.. data_today.day..'.'..data_today.month..'.'..data_today.year..'.txt')
		local file = io.open(log,"a")
		file:write('['..data_today.hour..':'..data_today.min ..':'..data_today.sec..'] ' .. encrypt(string.gsub(text, '{}', ''), 3)..'\n') 
		file:close()
	end
end

function render_admins()
	wait(5000)
	while true do
		while sampIsDialogActive() do wait(500) end
		if not AFK then sampSendChat('/admins') end
		wait(30000)
	end
end

function autoonline() 
	while true do
		wait(63000) 
		while sampIsDialogActive() do wait(300) end
		if not AFK then sampSendChat("/online") end 
	end 
end

function onWindowMessage(msg, wparam, lparam) -- блокировка ALT + Enter
	if msg == 261 and wparam == 13 then consumeWindowMessage(true, true) end
end
function save() inicfg.save(cfg,'AT//AT_main.ini') end
function wait_accept_form()
	lua_thread.create(function()
		local fonts = renderCreateFont('TimesNewRoman', 12, 5) -- текст для автоформ
		while true do
			wait(2)
			if array.admin_form.bool and array.admin_form.timer and array.admin_form.sett then
				local timer = os.clock() - array.admin_form.timer
				renderFontDrawText(fonts, '{FFFFFF}Обнаружена форма от администратора.\nНажми U, чтобы принять или J - чтобы отклонить\nВремени на раздумья '..cfg.settings.time_form..' сек, прошло: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
				if timer> cfg.settings.time_form then break end
			end
			if not (sampIsChatInputActive() or sampIsDialogActive()) then
				if wasKeyPressed(VK_U) or cfg.settings.autoaccept_form then
					if sampIsPlayerConnected(array.admin_form.idadmin) and array.admin_form.forma~=nil then
						if not (array.admin_form.forma):match('kick') and not (array.admin_form.forma):match('off') and not (array.admin_form.forma):match('akk') and not (array.admin_form.forma):match('unban') then
							local _, id, sec, prichina = (array.admin_form.forma):match('(.+) (.+) (.+) (.+)')
							if not (tonumber(id) or tonumber(sec) or prichina) then
								sampSendChat('/a АТ - Отказано.')
								break
							end
						end
						if array.admin_form.probid and not sampIsPlayerConnected(array.admin_form.probid) then
							sampAddChatMessage(tag .. 'Указанный игрок не в сети', -1)
							break
						end
						if (array.admin_form.forma) then
							if not array.admin_form.styleform then sampSendChat(array.admin_form.forma .. ' // ' .. sampGetPlayerNickname(array.admin_form.idadmin))
							else sampSendChat(array.admin_form.forma) end
							wait(1000)
							sampSendChat('/a AT - Принято.')
						else sampAddChatMessage(tag .. 'Ошибка, форма потеряна... Попробуйте ещё раз.', -1) end
 					else sampAddChatMessage(tag .. 'Администратор не в сети.', -1) end
					break
				end
				if wasKeyPressed(VK_J) then
					sampAddChatMessage(tag .. 'форма отклонена', -1)
					break
				end
			end
		end
		array.admin_form = {}
	end)
end
function binder_key()
	while true do
		if not (sampIsChatInputActive() or sampIsDialogActive() or array.windows.fast_report.v or array.windows.answer_player_report.v or AFK) then
			if wasKeyPressed(strToIdKeys(cfg.settings.open_tool)) then  -- кнопка активации окна
				for i = 1, 512 do  -- [[[ FIX BUG INPUT TEXT IMGUI  ]]]
					imgui:GetIO().KeysDown[i] = false
				end
				for i = 1, 5 do
					imgui:GetIO().MouseDown[i] = false
				end
				imgui:GetIO().KeyCtrl = false
				imgui:GetIO().KeyShift = false
				imgui:GetIO().KeyAlt = false
				imgui:GetIO().KeySuper = false  
				imgui.Process = true
				array.windows.menu_tools.v = not array.windows.menu_tools.v
				if array.windows.recon_menu.v then 	-- активация курсора если рекон меню активно
					lua_thread.create(function()
						setVirtualKeyDown(70, true)
						wait(150)
						setVirtualKeyDown(70, false)
					end)
				end
			elseif wasKeyPressed(strToIdKeys(cfg.settings.fast_key_ans)) and not array.windows.menu_tools.v then sampSendChat("/ans") sampSendDialogResponse(2348, 1, 0)
			elseif wasKeyPressed(strToIdKeys(cfg.settings.fast_key_addText)) and not array.windows.menu_tools.v then sampSetChatInputText(string.sub(sampGetChatInputText(), 1, -2) .. ' '.. cfg.settings.mytextreport) sampSetChatInputEnabled(true) end
			for k,v in pairs(cfg.binder_key) do 
				if wasKeyPressed(strToIdKeys(k)) and not array.windows.menu_tools.v then
					local check_v, v = string.match(v, '(%d)\\n(.+)')
					if check_v == '0' then sampSendChat(v)
					elseif check_v == '1' then sampProcessChatInput(v)
					elseif check_v == '2' then sampSetChatInputText(string.sub(sampGetChatInputText(), 1, -2) .. v .. ' ') sampSetChatInputEnabled(true) end
				end 
			end
		end
		wait(30)
		if isGamePaused() then 
			if not AFK and tonumber(cfg.settings.control_afk) then
				lua_thread.create(function()
					for i = 0, (cfg.settings.control_afk*10) do
						wait(6000)
						if not AFK then
							break
						elseif i == (cfg.settings.control_afk*10) then ffi.C.ExitProcess(0)--[[game over]] end
					end
				end)
			end
			AFK = true
		else AFK = false end
	end
end
function back_punishment(count)
	if not cfg.settings.time_nakazanie then return end
	lua_thread.create(function()
		newCount = true
		wait(3)
		newCount = false
		local maxBack_count = count
		local cnt = os.clock() 
		local count = count + 1
		while true do wait(1)
			if (os.clock()-cnt > count) or newCount then break
			else
				local back_count = math.floor( os.clock()-cnt )
				if back_count == count then break end
				if not AFK then renderFontDrawText(font_adminchat, 'До выдачи следующего наказания: ' .. back_count .. '/'..maxBack_count..' сек.', cfg.settings.time_nakazanie_posx, cfg.settings.time_nakazanie_posy, 0xCCFFFFFF) end
			end
		end
	end)
end
function input_helper()
	local _, pID = sampGetPlayerIdByCharHandle(playerPed) -- myid
	local name = sampGetPlayerNickname(pID) -- mynick
	local convertToHexColor = function(htmlText)
		local hexColorPattern = "#([0-9a-fA-F]+)"
		local hexColor = htmlText:match(hexColorPattern)
		if hexColor then
			local r = tonumber(hexColor:sub(1, 2), 16)
			local g = tonumber(hexColor:sub(3, 4), 16)
			local b = tonumber(hexColor:sub(5, 6), 16)
			return string.format("0x88%02X%02X%02X", r, g, b)
		else return "" end
	end
	local translite = function(text) -- транслейт текста для замены . /
		for k, v in pairs(array.chars) do text = string.gsub(text, k, v) end return text
	end
	local user32 = ffi.load("user32") -- caps chat\
	local names_command = {["mute"]=true, ["rmute"]=true, ["ban"]=true, ["jail"]=true,}
	while true do wait(1)
		if sampIsChatInputActive() then
			local in1 = sampGetInputInfoPtr() -- координаты под чатом
			local in1 = getStructElement(in1, 0x8, 4)
			local in2 = getStructElement(in1, 0x8, 4)
			local in3 = getStructElement(in1, 0xC, 4)
			local getInput = sampGetChatInputText()
			if (oldText ~= getInput and #getInput > 0)then
				local firstChar = string.sub(getInput, 1, 1)
				if (firstChar == "." or firstChar == "/") then
					local cmd, text = string.match(getInput, "^([^ ]+)(.*)")
					local nText = "/" .. translite(string.sub(cmd, 2)) .. text
					local chatInfoPtr = sampGetInputInfoPtr()
					local chatBoxInfo = getStructElement(chatInfoPtr, 0x8, 4)
					local lastPos = mem.getint8(chatBoxInfo + 0x11E)
					sampSetChatInputText(nText)
					mem.setint8(chatBoxInfo + 0x11E, lastPos)
					mem.setint8(chatBoxInfo + 0x119, lastPos)
					oldText = nText
					while string.sub(sampGetChatInputText(), 1, 5) == '/mess' do wait(0)
						local s = ""
						local color = {
							'{FFFFFF}Белый',
							'{000000}Черный',
							'{008000}Темно-зеленый',
							'{80FF00}Светло-зеленый',
							'{FF0000}Красный',
							'{0000FF}Темно-синий',
							'{FDFF00}Желтый',
							'{FF9000}Золотой',
							'{B313E7}Фиолетовый',
							'{49E789}Бирюзовый',
							'{139BEC}Синий',
							'{2C9197}Сине-зеленый',
							'{DDB201}Желтый',
							'{B8B6B6}Серый',
							'{FFEE8A}Бежевый',
							'{FF9DB6}Розовый',
							'{BE8A01}Коричневый',
							'{E6284E}Светлокрасный',
						}
						for k,v in pairs(color) do
							s = s ..k-1 .. ' - ' .. v .. "\n{FFFFFF}"
						end 

						renderFontDrawText(font_chat, s, in2 + 5, in3 + 50, -1)
					end
				end
			end
			-- подсказки под чатом

			local ping = sampGetPlayerPing(pID) -- ping
			local caps = (user32).GetKeyState(0x14) -- Код клавиши CapsLock

			if caps == 1 or caps == 3 then caps = 'ON'
			else caps = 'OFF' end

			if getCurrentLanguageName() == '00000419' then raskl = 'RU'
			else raskl = 'EN' end

			local text = ("Ваш ник: "..cfg.settings.color_chat..name.."["..pID.."]{ffffff}, Ваш пинг: "..cfg.settings.color_chat..ping.."{ffffff}, Раскладка: "..cfg.settings.color_chat..raskl.."{ffffff}, CapsLock: "..cfg.settings.color_chat..caps)
			local count = 0
			if cfg.settings.active_chat then
				local mouseX, mouseY = getCursorPos()
				if #getInput > 1 then
					local getInput = "/"..string.rlower(string.gsub(getInput,"%p", ""))
					for name_razdel, razdel in pairs(basic_command) do
						for name, command in pairs(razdel) do
							if (getInput:match(name) or name:match(getInput) or (string.gsub(command, "_", "(%d+)"):match( getInput ) )) and not tonumber(string.sub(command, -1)) then
								if getInput:match(name.." ") then
									renderDrawBox(in2 + 5, in3 + 55 + (count*6), 700, 30, convertToHexColor("#"..cfg.settings.color_chat:sub(2):sub(1,-2)))
								elseif (sampIsCursorActive() and mouseX < in2+705  and mouseY > in3 + 55 + (count*6) and mouseY<(in3 + 90 + (count*6))) then
									if wasKeyPressed(VK_LBUTTON) then
										sampSetChatInputText(name..' ') 
										lua_thread.create(function() 
											for i = 1, 100 do wait(1) 
												sampSetChatInputEnabled(true)
											end
										end)
									end
								else renderDrawBox(in2 + 5, in3 + 55 + (count*6), 700, 30, 0x88000000) end
								if names_command[name_razdel] then
									renderFontDrawText(font_chat, "{A9A9A9}-f", 720, in3 + 60 + (count*6) , -1)
								end
								local id = string.gsub(getInput, name, '')
								if tonumber(id) and sampIsPlayerConnected(id) then
									local clr = '{'..string.format("%x", sampGetPlayerColor(id)) ..'}'
									if #clr~=10 or clr == "{ffffffff}" then clr = cfg.settings.color_chat end
									renderFontDrawText(font_chat,  name .. " > " .. string.gsub(command, "_", clr..sampGetPlayerNickname(id) .. '{FFFFFF}'), in2 + 10, in3 + 60 + (count*6) , -1)
								else
									renderFontDrawText(font_chat,  name .. " > " .. string.gsub(command, "_", "ID"), in2 + 10, in3 + 60 + (count*6) , -1)
								end
								count = count + 5
								if count > 11 then break end -- не более 3-ех подсказок
							end 
						end
						if count > 11 then break end -- не более 3-ех подсказок
					end
					if count == 0 then renderFontDrawText(font_chat, text, in2 + 5, in3 + 50, -1) end
				else renderFontDrawText(font_chat, text, in2 + 5, in3 + 50, -1) end
			end
		end
	end
end
function time_text()
	if #(cfg.settings.customtimetext) ~= 0 then
		while true do wait(1) if not AFK then
			renderFontDrawText(font_timetext, cfg.settings.customtimetext, cfg.settings.timetext_pos_x, cfg.settings.timetext_pos_y, 0xCCFFFFFF)
		end end
	else
		while true do wait(1) if not AFK then
			renderFontDrawText(font_timetext, os.date("%H:%M %d/%m/%y"), cfg.settings.timetext_pos_x, cfg.settings.timetext_pos_y, 0xCCFFFFFF)
		end end
	end
end
--============= Wallhack ==============--

function wallhack()
	while true do
		wait(1)
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

function on_wallhack() -- Включение WallHack (свойства)
	local pStSet = sampGetServerSettingsPtr();
	local NTdist = mem.getfloat(pStSet + 39)
	local NTwalls = mem.getint8(pStSet + 47)
	local NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 900.0) -- дальность прорисовки 900 метров
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
end
function off_wallhack() -- Выключение WallHack (свойства)
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, 30)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
end

function download_update()
	if update_info then sampShowDialog(9999, "Информация об обновлении",string.gsub(u8:decode(update_info), '\\n', '\n'), "Спасибо", nil, 0) end
	local dlstatus = require('moonloader').download_status
	imgui.Process = false
	showCursor(false,false)
	sampAddChatMessage(tag .. 'Ожидайте, начинаю процесс обновления.', -1)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/my_lib.lua", 'moonloader//lib//my_lib.lua', function(id, status) end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", 'moonloader//config//AT//rules.txt', function(id, status)  end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_Trassera.lua", 'moonloader//resource//AT_Trassera.lua', function(id, status) end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/control_work_AT.lua", 'moonloader//control_work_AT.lua', function(id, status) end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_MP.lua", 'moonloader//resource//AT_MP.lua', function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(tag .. 'Скрипт получил актуальную версию модуля мероприятий',-1)
		end 
	end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_FastSpawn.lua", 'moonloader//resource//AT_FastSpawn.lua', function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(tag .. 'Скрипт получил актуальную версию быстрого спавна',-1)
		end  
	end)
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.lua", thisScript().path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(tag .. 'Скрипт получил актуальную версию АТ',-1)
		end 
	end)
	lua_thread.create(function()
		wait(8000)
		sampAddChatMessage(tag .. 'Выполняю установку загруженных скриптов...', -1)
		reloadScripts()
	end)
end
---========================== /KEYSYNC =============================----
function sampev.onPlayerSync(playerId, data)
	local result, id = sampGetPlayerIdByCharHandle(target)
	if result and id == playerId then
		array.keys["onfoot"] = {}
		array.keys["onfoot"]["W"] = (data.upDownKeys == 65408) or nil
		array.keys["onfoot"]["A"] = (data.leftRightKeys == 65408) or nil
		array.keys["onfoot"]["S"] = (data.upDownKeys == 00128) or nil
		array.keys["onfoot"]["D"] = (data.leftRightKeys == 00128) or nil

		array.keys["onfoot"]["R"] = (bit.band(data.keysData, 82) == 82) or nil

		array.keys["onfoot"]["Alt"] = (bit.band(data.keysData, 1024) == 1024) or nil
		array.keys["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
		array.keys["onfoot"]["TAB"] = (data.otherKeys == 9) or nil
		array.keys["onfoot"]["Space"] = (bit.band(data.keysData, 32) == 32) or nil
		array.keys["onfoot"]["Ctrl"] = (data.otherKeys == 65507) or nil

		array.keys["onfoot"]["C"] = (bit.band(data.keysData, 2) == 2) or nil

		array.keys["onfoot"]["RKM"] = (bit.band(data.keysData, 4) == 4) or nil
		array.keys["onfoot"]["LKM"] = (bit.band(data.keysData, 128) == 128) or nil
		array.keys["onfoot"]["Enter"] = (bit.band(data.keysData, 16) == 16) or nil
	end
end
function sampev.onVehicleSync(playerId, vehicleId, data)
	local result, id = sampGetPlayerIdByCharHandle(target)
	if result and id == playerId then
		array.keys["vehicle"] = {}

		array.keys["vehicle"]["W"] = (bit.band(data.keysData, 8) == 8) or nil
		array.keys["vehicle"]["A"] = (data.leftRightKeys == 65408) or nil
		array.keys["vehicle"]["S"] = (bit.band(data.keysData, 32) == 32) or nil
		array.keys["vehicle"]["D"] = (data.leftRightKeys == 00128) or nil

		array.keys["vehicle"]["Q"] = (bit.band(data.keysData, 256) == 256) or nil
		array.keys["vehicle"]["E"] = (bit.band(data.keysData, 64) == 64) or nil

        array.keys["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
		array.keys["vehicle"]["Space"] = (bit.band(data.keysData, 128) == 128) or nil

		array.keys["vehicle"]["Alt"] = (bit.band(data.keysData, 4) == 4) or nil
		array.keys["vehicle"]["Enter"] = (bit.band(data.keysData, 16) == 16) or nil

		array.keys["vehicle"]["Up"] = (data.upDownKeys == 65408) or nil
		array.keys["vehicle"]["Down"] = (data.upDownKeys == 00128) or nil
	end
end

function auto_update_recon()
	if not start_update_recon then
		start_update_recon = true
		lua_thread.create(function()
			while not doesCharExist(target) and array.windows.recon_menu.v do
				wait(1500)
				sampSendClickTextdraw(array.textdraw.refresh)
				printStyledString('~n~~b~~h~auto - update...', 200, 4)
				keysync(control_player_recon)
			end
			start_update_recon = false
		end)
	end
end 
function KeyCap(keyName, isPressed, size)
	local u32 = imgui.ColorConvertFloat4ToU32
	local DL = imgui.GetWindowDrawList()
	local p = imgui.GetCursorScreenPos()
	local colors = {
		[true] = imgui.ImVec4(0.60, 0.60, 1.00, 1.00),
		[false] = imgui.ImVec4(0.60, 0.60, 1.00, 0.10)
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
	local A = imgui.ImVec2(p.x, p.y)
	local B = imgui.ImVec2(p.x + size.x, p.y + size.y)
	if K.timer ~= nil then
		K.color = bringVec4To(colors[not isPressed], colors[isPressed], K.timer, 0.1)
	end
	local ts = imgui.CalcTextSize(keyName)
	local text_pos = imgui.ImVec2(p.x + (size.x / 2) - (ts.x / 2), p.y + (size.y / 2) - (ts.y / 2))
	imgui.Dummy(size)
	DL:AddRectFilled(A, B, u32(K.color), rounding)
	DL:AddRect(A, B, u32(colors[true]), rounding, _, 1)
	DL:AddText(text_pos, 0xFFFFFFFF, keyName)
end
function bringVec4To(from, dest, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
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

function vision_form()
	if imgui.BeginPopup('autoform') then
		imgui.CenterText(u8'Каких доступов у вас нет?')
		if imgui.Checkbox('/ban', array.checkbox.check_form_ban) then
			cfg.settings.forma_na_ban = not cfg.settings.forma_na_ban
			save()
		end
		if imgui.Checkbox('/jail', array.checkbox.check_form_jail) then
			cfg.settings.forma_na_jail = not cfg.settings.forma_na_jail
			save()
		end
		if imgui.Checkbox('/mute', array.checkbox.check_form_mute) then
			if not cfg.settings.automute then
				cfg.settings.forma_na_mute = not cfg.settings.forma_na_mute
			else 
				cfg.settings.forma_na_mute = false
				array.checkbox.check_form_mute.v = false
				sampAddChatMessage(tag .. 'У вас включен автомут, во избежания фарма данные опции совместно запрещены.', -1)
			end
			save()
		end
		if imgui.Checkbox('/kick', array.checkbox.check_form_kick) then
			cfg.settings.forma_na_kick = not cfg.settings.forma_na_kick
			save()
		end
		if imgui.Checkbox(u8'Добавлять // мой ник', array.checkbox.check_add_mynick_form) then
			cfg.settings.add_mynick_in_form = not cfg.settings.add_mynick_in_form
			save()
		end
		imgui.Text(u8'Сокращенный ник(при желании): ')
		imgui.PushItemWidth(250)
		if imgui.InputText("######", array.buffer.sokr_nick) then
			cfg.settings.sokr_nick = array.buffer.sokr_nick
			save()
		end
		imgui.PopItemWidth()
		imgui.Text('')
		if imgui.Checkbox(u8'У меня нет доступ к /tr', imgui.ImBool(cfg.settings.atr)) then
			if tr then
				tr = false
				sampAddChatMessage('{37aa0d}[Информация] {FFFFFF}Вы {FF0000}выключили режим TakeReport.', 0x32CD32)
			end
			cfg.settings.atr = not cfg.settings.atr
			save()
		end
		if cfg.settings.atr then
			imgui.Text(u8'Активация TakeReport - /tr')
		end
		imgui.Text(u8'Скрипт сам будет\nотправлять формы старшим,\nне важно отправите вы\nэто полноценной командой,\nили быстрой.')
		imgui.Text(u8'Подсказка: /ahelp содержит\nвсе серверные правила и команды')
		imgui.EndPopup()
	end
end

function ScriptExport()
	local get_name_of_path = function(path) return path:match('^.+[\\/](.-)$') end
	local get_files = function(path, mask)
		if type(mask) ~= 'table' then mask = { mask } end
		local t = {}
		for i = 1, #mask do
			local handle, name = findFirstFile(path .. '\\' .. mask[i])
			if handle then
				while name do
					t[#t + 1] = name
					name = findNextFile(handle)
				end
				findClose(handle)
			end
		end
		return t
	end
	local get_loaded_scripts = function()
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
	local loaded, _ = get_loaded_scripts()
	for k,v in pairs(loaded) do
		if v.name == 'AT_MP' or v.name == 'AT_FastSpawn' or v.name == 'AT_Trassera' or v.name == 'AdminToolsPlus' then
			v:unload()
		end
	end
	if cfg.settings.wallhack then off_wallhack() end
	showCursor(false,false)
	thisScript():unload()
end
function addBeginText()
	if #array.buffer.custom_addtext_report.v > 1 then return u8:decode(array.buffer.custom_addtext_report.v)
	else
		local text = {
			"Доброго времени суток!",
			"Приветствую!",
			"Уважаемый игрок!",
			"Здравствуйте!",
		}
		return ( text[math.random(1,#text)] .. " " )
	end
end
--------=================== Подпись ID в килл-чате =============------------------------
ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
	int GetKeyboardLayoutNameA(char* pwszKLID);
	void ExitProcess(unsigned int uExitCode); //  -- /q

	// kill chat
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
	// kill chat
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
function sampev.onPlayerDeathNotification(killerId, killedId, reason)
	local kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)
	killer,killed,reasonkill = killerId,killedId,reason
	local n_killer = ( sampIsPlayerConnected(killerId) or killerId == myid ) and sampGetPlayerNickname(killerId) or nil
	local n_killed = ( sampIsPlayerConnected(killedId) or killedId == myid ) and sampGetPlayerNickname(killedId) or nil
	lua_thread.create(function()
		wait(1)
		if n_killer then kill.killEntry[4].szKiller = ffi.new('char[25]', ( n_killer .. '[' .. killerId .. ']' ):sub(1, 24) ) end
		if n_killed then kill.killEntry[4].szVictim = ffi.new('char[25]', ( n_killed .. '[' .. killedId .. ']' ):sub(1, 24) ) end
	end)
end