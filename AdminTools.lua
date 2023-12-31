require 'lib.moonloader'									-- ��������� ���������� Moonloader
require 'lib.sampfuncs' 									-- ��������� ���������� SampFuncs
require 'my_lib'											-- ����� ������� ����������� ��� �������
script_name 'AdminTools [AT]'  								-- �������� ������� 
script_author 'Neon4ik' 									-- ��������� ������������
script_properties("work-in-pause") 							-- ����������� ������������ ����������, �������� � AFK
import("\\resource\\AT_MP.lua") 							-- ��������� ������� ��� �����������
import("\\resource\\AT_FastSpawn.lua")  					-- ��������� �������� ������
import("\\resource\\AT_Trassera.lua") 	  					-- ��������� ���������
local version = 6				 							-- ������ �������

------=================== �������� ������� ===================----------------------
local imgui 			= require 'imgui' 					-- ������������ �������, ���� ���������
local sampev		 	= require 'lib.samp.events'			-- ���������� ������ �� ����
local imadd 			= require 'imgui_addons' 			-- ������ ����� CheckBox'a
local mimgui 			= require 'mimgui'					-- ������ ��� ������ keysyns
local inicfg 			= require 'inicfg'					-- ����������/�������� ��������
local encoding 			= require 'encoding'				-- ���������� �� ������� ����
local vkeys 			= require 'vkeys' 					-- ������ � �������� ������
local ffi 				= require "ffi"						-- ������ � �������� �����
local fa 				= require 'faicons'					-- ������ � imgui
local mem 				= require 'memory'					-- ������ � ������� ����
local font 				= require ('moonloader').font_flag	-- ������ ���������� ������� �� ������
encoding.default 		= 'CP1251' 
local u8 				= encoding.UTF8


local plagin_notify		= import('\\lib\\lib_imgui_notf.lua')
local sw, sh 			= getScreenResolution()           	-- ������ ���������� ������ ������������


local cfg = inicfg.load({  									-- ��������� ������� ������, ���� �� �����������
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
		mytextreport = '|| �������� ���� �� RDS <3',
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
		color_report = '*',
		autoaccept_form = false,
		bloknotik = '',
		autoupdate = true,
		chat_log = true,
		control_afk = false,
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

------=================== ImGui ���� ===================----------------------


local array = {
	windows = {
		menu_tools 			= imgui.ImBool(false),
		fast_report 		= imgui.ImBool(false),
		recon_menu 			= imgui.ImBool(false),
		menu_in_recon 		= imgui.ImBool(false),
		answer_player_report= imgui.ImBool(false),
		custom_ans 			= imgui.ImBool(false),
		render_admins		= imgui.ImBool(false),
		new_flood_mess 		= imgui.ImBool(false),
		pravila 			= imgui.ImBool(false),
		menu_chatlogger 	= imgui.ImBool(false),
	},
	------=================== ����������� ����� ��������, ������ �� �������� True/False ===================----------------------
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
		check_autoupdate		= imgui.ImBool(cfg.settings.autoupdate),
		inputhelper			  	= imgui.ImBool(cfg.settings.inputhelper),
		check_on_chatlog		= imgui.ImBool(cfg.settings.chat_log),
		check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report),
		check_on_custom_recon_menu = imgui.ImBool(cfg.settings.on_custom_recon_menu),
		autoprefix				   = imgui.ImBool(cfg.settings.autoprefix),
	},
	------=================== ���� ������ � ImGui ���� ===================----------------------
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
	},
	chatlog_1 		= {}, 											-- ���-���1
	chatlog_2 		= {}, 											-- ���-���2
	chatlog_3 		= {}, 											-- ���-���3
	files_chatlogs 	= {},											-- ������ ���-������
	admins 			= {},											-- ������ /admins
	textdraw 		= {}, 											-- ������ �� ���������� ��� �������������� � ����
	admin_form 		= {}, 											-- ������ � �����-�������
	nakazatreport 	= {},											-- ����������� �������� ����� �� �������
	answer 			= {}, 											-- ����� ������ � �������
	adminchat 		= {},											-- ��� �����-��������� �������� ���
	ears 			= {},											-- ��� ears ��������� �������� ���
	inforeport 		= {},											-- ��� ���������� � ������ � ������ �������� ���
	pravila 		= {},											-- �������/������� �������� ��� /ahelp
	flood = { --[[������� ID]]message = {},--[[���������]]time = {},--[[����� ��������]]count = {}--[[���-�� ��������� ���������]]},
	textdraw_delete = {  											-- ���������� �� ����� ����, ���������� �������� (�������� ��� ������)
		144, 146, 141, 155, 153, 152, 154, 160, 179, 159, 157, 164, 180, 161,
		169, 181, 166, 168, 174, 182, 171, 173, 150, 183, 183, 147, 149, 142,
		143, 184, 176, 145, 158, 162, 163, 167, 172, 148
	},
	name_car = {'Landstalker','Bravura','Buffalo','Linerunner','Perrenial','Sentinel','Dumper','Firetruck','Trashmaster','Stretch','Manana','Infernus','Voodoo','Pony','Mule','Cheetah','Ambulance','Leviathan','Moonbeam','Esperanto','Taxi','Washington','Bobcat','Mr Whoopee','BF Injection','Hunter','Premier','Enforcer','Securicar','Banshee','Predator','Bus','Rhino','Barracks','Hotknife','Trailer','Previon','Coach','Cabbie','Stallion','Rumpo','RC Bandit','Romero','Packer','Monster','Admiral','Squalo','Seasparrow','Pizzaboy','Tram','Trailer2','Turismo','Speeder','Reefer','Tropic','Flatbed','Yankee','Caddy','Solair','BerkleysRCVan','Skimmer','PCJ-600','Faggio','Freeway','RC Baron','RC Raider','Glendale','Oceanic','Sanchez','Sparrow','Patriot','Quad','Coastguard','Dinghy','Hermes','Sabre','Rustler','ZR-350','Walton','Regina','Comet','BMX','Burrito','Camper','Marquis','Baggage','Dozer','Maverick','News Chopper','Rancher','FBI Rancher','Virgo','Greenwood','Jetmax','Hotring','Sandking','Blista Compact','Police Maverick','Boxville','Benson','Mesa','RC Goblin','Hotring Racer A','Hotring Racer B','Bloodring Banger','Rancher','Super GT','Elegant','Journey','Bike','Mountain Bike','Beagle','Cropdust','Stunt','Tanker','Roadtrain','Nebula','Majestic','Buccaneer','Shamal','Hydra','FCR-900','NRG-500','HPV1000','Cement Truck','Tow Truck','Fortune','Cadrona','FBI Truck','Willard','Forklift','Tractor','Combine','Feltzer','Remington','Slamvan','Blade','Freight','Streak','Vortex','Vincent','Bullet','Clover','Sadler','Firetruck LA','Hustler','Intruder','Primo','Cargobob','Tampa',	'Sunrise','Merit','Utility','Nevada','Yosemite','Windsor','Monster A','Monster B','Uranus','Jester',	'Sultan',	'Stratum','Elegy','Raindance','RC Tiger',	'Flash',	'Tahoma','Savanna','Bandito','Freight Flat','Streak Carriage','Kart','Mower','Duneride','Sweeper','Broadway','Tornado','AT-400','DFT-30','Huntley','Stafford','BF-400','Newsvan','Tug','Trailer3','Emperor','Wayfarer','Euros','Hotdog','Club','Freight Carriage','Trailer4','Andromada','Dodo','RC Cam','Launch','Police Car (LSPD)','Police Car (SFPD)','Police Car (LVPD)','Police Ranger','Picador','S.W.A.T. Van','Alpha','Phoenix','Glendale','Sadler','Luggage Trailer A','Luggage Trailer B','Stair Trailer','Boxville','Farm Plow','Utility Trailer'},

	--AutoMute
	mat 				= {},										-- ������� �� ���
	osk 				= {},										-- ������� �� ���
	spisokoskrod = { 												-- ������� �� ��� ���
		'mq', 
		'rnq'
	},
	spisokrz = {  													-- ��������� ������
		'����� ���', 
		'����� ����'
	},
	spisokor = { 													-- ������ ��������� �������� ����������� ����� (��� + ���-�� �� ����� ������, ��� ���-�� �� ������ � ���)
		'���',
		'����',
		'���',
		'��������',
		'mamy',
		'mama',
		'������',
	},
	spisok_in_form = {											 	-- ������ ��� ��������
		'ban',
		'jail',
		'kick',
		'mute',
	},
	spisokproject = { 												-- ������ �������� �� ������� ���� �������
		'������',
		'���� ����',
		'���� ����',
		'������',
		'������',
		'������',
		'���',
		'arz',
		'amazing',
		'�������',
	},
	chars = { 	-- ����� ������
		["�"] = "q", ["�"] = "w", ["�"] = "e", ["�"] = "r", ["�"] = "t", ["�"] = "y", ["�"] = "u", ["�"] = "i", ["�"] = "o", ["�"] = "p", ["�"] = "[", ["�"] = "]", ["�"] = "a",
		["�"] = "s", ["�"] = "d", ["�"] = "f", ["�"] = "g", ["�"] = "h", ["�"] = "j", ["�"] = "k", ["�"] = "l", ["�"] = ";", ["�"] = "'", ["�"] = "z", ["�"] = "x", ["�"] = "c", ["�"] = "v",
		["�"] = "b", ["�"] = "n", ["�"] = "m", ["�"] = ",", ["�"] = ".", ["�"] = "Q", ["�"] = "W", ["�"] = "E", ["�"] = "R", ["�"] = "T", ["�"] = "Y", ["�"] = "U", ["�"] = "I",
		["�"] = "O", ["�"] = "P", ["�"] = "{", ["�"] = "}", ["�"] = "A", ["�"] = "S", ["�"] = "D", ["�"] = "F", ["�"] = "G", ["�"] = "H", ["�"] = "J", ["�"] = "K", ["�"] = "L",
		["�"] = ":", ["�"] = "\"", ["�"] = "Z", ["�"] = "X", ["�"] = "C", ["�"] = "V", ["�"] = "B", ["�"] = "N", ["�"] = "M", ["�"] = "<", ["�"] = ">"
	},
	keys = {
		["onfoot"] = {},
		["vehicle"] = {}
	}
}
local menu 				= '������� ����' 								-- ������ ������� � F3
local menu_in_recon 	= '������� ����'								-- ������ ������� � �����
local tag 				= '{2B6CC4}Admin Tools: {F0E68C}' 				-- ������ �������� ������� � ����� ����
local AFK 				= false											-- �������� ������� �������, ��� �� ��� ���
local atr 				= false											-- ������������ /tr
local find_ip_player 	= false											-- ����� IP � /offstats
local regip				= nil											-- ������ ����������� �� � /offstats
local lastip			= nil											-- ������ ��������� �� � /offstats
local autoprefix_access = false											-- ������ ����� �� ������ ���� ������ ��������
local target = -1														-- ����� � ����������� ��������
local font_adminchat = renderCreateFont("Arial", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW) -- ����� ����� ����
local font_earschat  = renderCreateFont("Arial", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)	   -- ����� ears ����

---=========================== �������� �������� ������� ============-----------------
function main()
	while not sampIsLocalPlayerSpawned() do wait(2000) end
	local dlstatus = require('moonloader').download_status
    downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.ini", 'moonloader//config//AT//AdminTools.ini', function(id, status) end)
	local AdminTools = inicfg.load(nil, 'moonloader\\config\\AT\\AdminTools.ini')
	if AdminTools then
		if AdminTools.script.info then update_info = AdminTools.script.info end
		if AdminTools.script.version > version then
			if AdminTools.script.main or cfg.settings.autoupdate then
				sampAddChatMessage(tag .. '���������� ����� {808080}������������ {F0E68C}���������� �������! ��������� ��������������.', -1)
				update('all')
			end
			update_main = true
		end
		if cfg.settings.versionFS and cfg.settings.versionMP then
			if AdminTools.script.versionMP > cfg.settings.versionMP then update_mp = true end
			if AdminTools.script.versionFS > cfg.settings.versionFS then update_fs = true end
		else sampAddChatMessage(tag .. '�������������� ������ �� ����������! �������� �� ���� ������������, ��� �������������� ������.', -1) end
		if sampGetCurrentServerAddress() ~= '46.174.52.246' and sampGetCurrentServerAddress() ~= '46.174.49.170' then
			sampAddChatMessage(tag .. '� ������������ ��� RDS, ��� � ���� ��������.', -1)
			ScriptExport()
		end
		if update_main or update_fs or update_mp then
			sampAddChatMessage       ('==================================================================================', '0x'..(color()))
			sampAddChatMessage(tag .. '���������� ����� {FF0000}���������� {F0E68C}, ����� /update, ����� �������� ������', '0x'..(color()))
			sampAddChatMessage       ('==================================================================================', '0x'..(color()))
		else sampAddChatMessage(tag.. '������ ������� ��������. ��������� F3(/tool)', -1) end
	end
	local AdminTools = nil
	--------------------============ ������� � ������� =====================---------------------------------
	local rules = file_exists('moonloader\\config\\AT\\rules.txt') if not rules then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", 'moonloader\\' .. "\\config\\AT\\rules.txt", function(id, status) end) end
	local AutoMute_mat = file_exists('moonloader\\config\\AT\\mat.txt') if not AutoMute_mat then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/mat.txt", 'moonloader\\' .. "\\config\\AT\\mat.txt", function(id, status) end) end
	local AutoMute_osk = file_exists('moonloader\\config\\AT\\osk.txt') if not AutoMute_osk then downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/osk.txt", 'moonloader\\' .. "\\config\\AT\\osk.txt", function(id, status) end) end	
	local rules = io.open('moonloader\\config\\AT\\rules.txt',"r")
	if rules then for line in rules:lines() do array.pravila[ #(array.pravila) + 1] = line;end rules:close() end
	
	--------------------============ ������� =====================---------------------------------
	local AutoMute_mat = io.open('moonloader\\config\\AT\\mat.txt', "r")
	if AutoMute_mat then for line in AutoMute_mat:lines() do line = u8:decode(line) if line and #(line) > 2 then array.mat[#array.mat + 1] = line end;end AutoMute_mat:close() end
	
	local AutoMute_osk = io.open('moonloader\\config\\AT\\osk.txt', "r")
	if AutoMute_osk then for line in AutoMute_osk:lines() do line = u8:decode(line) if line and #(line) > 2 then array.osk[#array.osk + 1] = line end;end AutoMute_osk:close() end
	--------------------============ ������� =====================---------------------------------
	local data_today = os.date("*t") -- ������ ���� �������
	if cfg.mute_players.data ~= data_today.day..'.'.. data_today.month..'.'..data_today.year then
		cfg.mute_players = {} -- ����� �������� ������ �������� ���� �������� ��������� ����
		cfg.mute_players.data = data_today.day..'.'.. data_today.month..'.'..data_today.year
		save()
	end
	--=========== ��� ���� =======-----
	local log = ('moonloader\\config\\chatlog\\chatlog '.. data_today.day..'.'..data_today.month..'.'..data_today.year..'.txt')
	if not directory_exists('moonloader\\config\\chatlog\\') then os.execute("mkdir moonloader\\config\\chatlog") print('����� �������������, ������ �����.') end
	if not file_exists(log) then
		local file = io.open(log,"w")
		file:close()
		print('������ ����� chatlog.txt')
	end
	for k, v in ipairs(scanDirectory('moonloader\\config\\chatlog\\')) do
		local data1,data2,data3 = string.sub(string.gsub(string.gsub(v, 'chatlog ', ''), '%.',' '), 1,-5):match('(%d+) (%d+) (%d+)')
		if data3 and data2 and data3 then
			if tonumber(daysPassed(data3,data2,data1)) < 3 then
				file = io.open('moonloader\\config\\chatlog\\'..v,'r')
				for line in file:lines() do
					if k == 1 then array.chatlog_1[#array.chatlog_1 + 1] = string.gsub(encrypt(line, -3), '{%w%w%w%w%w%w}','')
					elseif k == 2 then array.chatlog_2[#array.chatlog_2 + 1] = string.gsub(encrypt(line, -3), '{%w%w%w%w%w%w}','')
					elseif k == 3 then array.chatlog_3[#array.chatlog_3 + 1] = string.gsub(encrypt(line, -3), '{%w%w%w%w%w%w}','') end
				end
				file:close()
			else os.remove('moonloader\\config\\chatlog\\' .. v) end -- ���� ������� ������ 3 ���� (���) �� ������� ���
		else sampAddChatMessage(tag ..'���-�� ����� �� ���, ���-��� �� ���������, ��� ����� �������� ��������', -1) end
	end
	--========== ��� ���� ========----
	func = lua_thread.create_suspended(autoonline)
	funcadm = lua_thread.create_suspended(render_admins)
	func1 = lua_thread.create_suspended(wallhack)
	func4 = lua_thread.create_suspended(binder_key)
	func4:run() 									--binder_key
	if cfg.settings.render_admins then
		lua_thread.create(function()
			while #(array.admins) == 0 do wait(1000) end
			array.windows.render_admins.v = true
			imgui.Process = true
		end)
		funcadm:run() 
	end
	if cfg.settings.wallhack then on_wallhack() func1:run() end
	if cfg.settings.autoonline then func:run() end

	local font_watermark = renderCreateFont("Arial", 8, font.BOLD + font.BORDER + font.SHADOW) -- ����� ������ � �� ������
	local font 			 = renderCreateFont("Arial", cfg.settings.size_text_f6, font.BOLD + font.BORDER + font.SHADOW) -- ����� ��������� ����

	local _, pID = sampGetPlayerIdByCharHandle(playerPed) -- myid
	local name = sampGetPlayerNickname(pID) -- mynick

	local translite = function(text) -- ��������� ������ ��� ������ . /
		for k, v in pairs(array.chars) do text = string.gsub(text, k, v) end return text
	end


	while true do

		if not AFK then
			
			-- ������ �����
			for i = 1, #array.adminchat do
				renderFontDrawText(font_adminchat, array.adminchat[i], cfg.settings.position_adminchat_x, cfg.settings.position_adminchat_y + (i*14), 0xCCFFFFFF)
			end
			for i = 1, #array.ears do 
				renderFontDrawText(font_earschat, array.ears[i], cfg.settings.position_ears_x, cfg.settings.position_ears_y + (i*14), 0xCCFFFFFF)
			end

			--�������� ����� � ���� ������
			renderFontDrawText(font_watermark, tag..'{808080}version['..version..']', 10, sh-20, 0xCCFFFFFF)


			-- ���������� . /
			if sampIsChatInputActive() then
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

				-- ��������� ��� �����
				local in1 = sampGetInputInfoPtr()
				local in1 = getStructElement(in1, 0x8, 4)
				local in2 = getStructElement(in1, 0x8, 4)
				local in3 = getStructElement(in1, 0xC, 4)
	
				local ping = sampGetPlayerPing(pID) -- ping
				local caps = (ffi.load("user32")).GetKeyState(0x14) -- ��� ������� CapsLock
	
				if caps == 1 or caps == 3 then caps = 'ON'
				else caps = 'OFF' end
	
				if getCurrentLanguageName() == '00000419' then raskl = 'RU'
				else raskl = 'EN' end
	
				local text = ("��� ���: {0088ff}"..name.."["..pID.."]{ffffff}, ��� ����: {0088ff}"..ping.."{ffffff}, ���������: {0088ff}"..raskl.."{ffffff}, Capslock: {0088ff}"..caps)
				renderFontDrawText(font, text, in2 + 5, in3 + 40, -1)
			end
		end

		wait(3) -- ��������
	end
end
--======================================= ����������� ������ ====================================--
local basic_command = { -- ������� �������, 1 �������� = ������ '_'
	prochee = {
		update  = 		'�������� ������',
		fs 		=		'������� ���� FastSpawn',
		trassera= 		'������� ��������� ��������� ����',
		ears 	=		'��������/��������� ������ ������ ��������� �������',
		ahelp 	= 		'��� ������� �������/������� � �������',
		wh 		= 		'��������/��������� WallHack',
		c 		=		'������� ����� ������ � ������� �������',
		tool 	= 		'������������ ���� ��',
		sbanip 	= 		'������ ���������� �������� � IP ������� (��!)',
		opencl  = 		'������� ���� ���-�������',
		atr 	=		'���������� ������������ /tr, ������������� ����� ����� �������',
		spp 	= 		'���������� ������� � �������',
		prfma 	= 		'������ ������� ��.������',
		prfa 	= 		'������ ������� ������',
		prfsa 	= 		'������ ������� �������� ������',
		prfpga 	= 		'������ ������� ���',
		prfzga 	= 		'������ ������� ���',
		prfga 	= 		'������ ������� ��',
		color_report   ='��������� ���� ������ �� ������',
		autoaccept_form='������������ �����-����',
		control_afk    ='������������� ��������� ����, ���� ������ � AFK ����� ���������� ���-�� �����',
		size_chat	   ='�������� ������ ������� ���������� ��������� ����',
		add_autoprefix ='�������� �������������� � ���������� ������������',
		del_autoprefix ='������� �������������� �� ���������� ������������',
	},
	help = {
		uu      =  		'/unmute _',
		uj      =  		'/unjail _',
		ur      =  		'/unrmute _',
		uuf 	=		'/muteakk _ 5 ��������� �����.',
		ujf 	=		'/jailakk _ 5 ��������� �����.',
		urf 	= 		'/rmuteoff _ 5 ��������� �����.',
		as      =  		'/aspawn _',
		gv 		=		'/giveaccess _',
		mk 		=		'/makeadmin _',
		sa		=		'/setadmin',
		sn 		=		'/setnick _',
		stw     =  		'/setweap _ 38 5000',
		vig 	=		"/vvig _ 1 ��������������� VIP'��",
	},
	ans = { 														-- � �������������� ���� ���/����� ��� ���
		nv      =  		'/ot _ ����� �� � ����',
		cl      =  		'/ot _ ������ ����� ����.',
		pmv     =  		'/ot _ ������� ���. ����������� ���',
		dpr     =  		'/ot _ � ������ ������� ������� �� /donate',
		afk     =  		'/ot _ ����� ������������ ��� ��������� � AFK',
		nak     =  		'/ot _ ����� ��� �������! ���������� �� ���������.',
		n       =  		'/ot _ ��������� �� ������� ������ �� �����������.',
		fo      =  		'/ot _ ���������� � ������ ��������� �� ����� https://forumrds.ru',
		rep     =  		'/ot _ ����� ����������? �������� ������? �������� /report!',
		al 		=		'/ans _ ������������! �� ������ ������ /alogin !\n'..
						'/ans _ ������� /alogin � ���� ������, ����������.',
	},
	mute = { -- �������� ������� ��� ������ � �������� ��������� ���� � ���������� -f
		fd      =  		'/mute _ 120 ����/����',			--[[x10]]fd2='/mute _ 240 ���� x2',fd3='/mute _ 360 ���� x3',fd4='/mute _ 480 ���� x4',fd5='/mute _ 600 ���� x5',fd6='/mute _ 720 ���� x6',fd7='/mute _ 840 ���� x7',fd8='/mute _ 960 ���� x8',fd9='/mute _ 1080 ���� x9',fd10='/mute _ 1200 ���� x10',
		po 		=  		'/mute _ 120 ����������������',		--[[x10]]po2='/mute _ 240 ���������������� x2',po3='/mute _ 360 ���������������� x3',po4 ='/mute _ 480 ���������������� x4',po5 ='/mute _ 600 ���������������� x5',po6 ='/mute _ 720 ���������������� x6',po7 ='/mute _ 840 ���������������� x7',po8 ='/mute _ 960 ���������������� x8',po9 ='/mute _ 1080 ���������������� x9',po10 ='/mute _ 1200 ���������������� x10',
		m       =  		'/mute _ 300 ����������� �������',	--[[x10]]m2='/mute _ 600 ����������� ������� x2',m3='/mute _ 900 ����������� ������� x3',m4='/mute _ 1200 ����������� ������� x4',m5='/mute _ 1500 ����������� ������� x5',m6='/mute _ 1800 ����������� ������� x6',m7='/mute _ 2100 ����������� ������� x7',m8='/mute _ 2400 ����������� ������� x8',m9='/mute _ 2700 ����������� ������� x9',m10='/mute _ 3000 ����������� ������� x10',
		ok      =  		'/mute _ 400 �����������/��������',	--[[x10]]ok2='/mute _ 800 �����������/�������� x2',ok3='/mute _ 1200 �����������/�������� x3',ok4='/mute _ 1600 �����������/�������� x4',ok5='/mute _ 2000 �����������/�������� x5',ok6='/mute _ 2400 �����������/�������� x6',ok7='/mute _ 2800 �����������/�������� x7',ok8='/mute _ 3200 �����������/�������� x8',ok9='/mute _ 3600 �����������/�������� x9',ok10='/mute _ 4000 �����������/�������� x10',
		up 		=  		'/mute _ 1000 ����. ��������� ��������',
		oa 		=  		'/mute _ 2500 ����������� �������������',
		kl 		=  		'/mute _ 3000 ������� �� �������������',
		zs 		=  		'/mute _ 600 ��������������� ���������',
		nm 		=  		'/mute _ 600 ������������ ���������.',
		rekl 	=  		'/mute _ 1000 �������',
		rz		=  		'/mute _ 5000 ������ ������. �����',
		ia 		=  		'/mute _ 2500 ������ ���� �� ��������������',
	},
	rmute = { -- �������� ������� ��� ������ � �������� ��������� ���� � ���������� -f
		oft 	= 		'/rmute _ 120 ������ � ������',		--[[x10]]oft2='/rmute _ 240 ������ � ������ x2',oft3='/rmute _ 360 ������ � ������ x3',oft4='/rmute _ 480 ������ � ������ �4',oft5='/rmute _ 600 ������ � ������ �5',oft6='/rmute _ 720 ������ � ������ x6',oft7='/rmute _ 840 ������ � ������ �7',oft8='/rmute _ 960 ������ � ������ �8',oft9='/rmute _ 1080 ������ � ������ �9',oft10='/rmute _ 1200 ������ � ������ �10',
		cp 		= 		'/rmute _ 120 caps in /report',		--[[x10]]cp2='/rmute _ 240 Caps in /report x2',cp3='/rmute _ 360 Caps in /report x3',cp4='/rmute _ 480 Caps in /report x4',cp5='/rmute _ 600 Caps in /report x5',cp6='/rmute _ 720 Caps in /report x6',cp7='/rmute _ 840 Caps in /report x7',cp8='/rmute _ 960 Caps in /report x8',cp9='/rmute _ 1080 Caps in /report x9',cp10='/rmute _ 1200 Caps in /report x10',
		rpo		=		'/rmute _ 120 ���������� � /report',--[[x10]]rpo2='/rmute _ 240 ���������� � /report x2',rpo3='/rmute _ 360 ���������� � /report x3',rpo4='/rmute _ 480 ���������� � /report x4',rpo5='/rmute _ 600 ���������� � /report x5',rpo6='/rmute _ 720 ���������� � /report x6',rpo7='/rmute _ 840 ���������� � /report x7',rpo8='/rmute _ 960 ���������� � /report x8',rpo9='/rmute _ 1080 ���������� � /report x9',rpo10='/rmute _ 1200 ���������� � /report x10',
		rm 		= 		'/rmute _ 300 ��� � /report',		--[[x10]]rm2='/rmute _ 600 ��� � /report x2',rm3='/rmute _ 900 ��� � /report x3',rm4='/rmute _ 600 ��� � /report x4',rm5='/rmute _ 600 ��� � /report x5',rm6='/rmute _ 600 ��� � /report x6',rm7='/rmute _ 600 ��� � /report x7',rm8='/rmute _ 600 ��� � /report x8',rm9='/rmute _ 600 ��� � /report x9',rm10='/rmute _ 600 ��� � /report x10',
		rok 	= 		'/rmute _ 400 ����������� � /report',--[[x10]]rok2='/rmute _ 800 ����������� � /report x2',rok3='/rmute _ 1200 ����������� � /report x3',rok4='/rmute _ 1600 ����������� � /report x4',rok5='/rmute _ 2000 ����������� � /report x5',rok6='/rmute _ 2400 ����������� � /report x6',rok7='/rmute _ 2800 ����������� � /report x7',rok8='/rmute _ 3200 ����������� � /report x8',rok9='/rmute _ 3600 ����������� � /report x9',rok10='/rmute _ 4000 ����������� � /report x10',
		roa 	= 		'/rmute _ 2500 �������e��� �������������',
		ror 	= 		'/rmute _ 5000 �������e���/���������� ������',
		rzs 	= 		'/rmute _ 600 ��������������� ������a��',
		rrz 	= 		'/rmute _ 5000 ������ ������. �o���',
		rkl 	= 		'/rmute _ 3000 ����e�� �� �������������'
	},
	jail = { -- �������� ������� ��� ������ � �������� ��������� ���� � ���������� -f
		bg 		= 		'/jail _ 300 ������',
		td 		= 		'/jail _ 300 car in /trade',
		jm 		= 		'/jail _ 300 ��������� ������ ��',	--[[x10]]jm2='/jail _ 600 ��������� ������ �� x2',jm3='/jail _ 900 ��������� ������ �� x3',jm4='/jail _ 1200 ��������� ������ �� x4',jm5='/jail _ 1500 ��������� ������ �� x5',jm6='/jail _ 1800 ��������� ������ �� x6',jm7='/jail _ 2100 ��������� ������ �� x7',jm8='/jail _ 2400 ��������� ������ �� x8',jm9='/jail _ 2700 ��������� ������ �� x9',jm10='/jail _ 3000 ��������� ������ �� x10',
		dz		=		'/jail _ 300 ��/�� � ������� ����',	--[[x10]]dz2='/jail _ 600 ��/�� � ������� ���� x2',dz3='/jail _ 900 ��/�� � ������� ���� x3',dz4='/jail _ 1200 ��/�� � ������� ���� x4',dz5='/jail _ 1500 ��/�� � ������� ���� x5',dz6='/jail _ 1800 ��/�� � ������� ���� x6',dz7='/jail _ 2100 ��/�� � ������� ���� x7',dz8='/jail _ 2400 ��/�� � ������� ���� x8',dz9='/jail _ 2700 ��/�� � ������� ���� x9',dz10='/jail _ 3000 ��/�� � ������� ���� x10',
		sk 		= 		'/jail _ 300 Spawn Kill',			--[[x10]]sk2='/jail _ 600 Spawn Kill x2',sk3='/jail _ 900 Spawn Kill x3',sk4='/jail _ 1200 Spawn Kill x4',sk5='/jail _ 1500 Spawn Kill x5',sk6='/jail _ 1800 Spawn Kill x6',sk7='/jail _ 2100 Spawn Kill x7',sk8='/jail _ 2400 Spawn Kill x8',sk9='/jail _ 2700 Spawn Kill x9',sk10='/jail _ 3000 Spawn Kill x10',
		dk 		= 		'/jail _ 900 �� ���� � ������� ����',
		jc 		= 		'/jail _ 900 ��������� ������/��',
		sh 		= 		'/jail _ 900 SpeedHack/FlyCar',
		prk 	=		'/jail _ 900 Parkour mode',
		vs 		=		'/jail _ 900 ����� ���',
		jcb 	= 		'/jail _ 3000 ��������� ������/��',
		zv 		= 		"/jail _ 3000 ��������������� VIP'��",
		dmp 	= 		'/jail _ 3000 ��������� ������ �� ��',
	},
	ban = { -- �������� ������� ��� ������ � �������� ��������� ���� � ���������� -f
		bh 		= 		'/ban _ 3 ��������� ������ /helper',
		nmb 	= 		'/ban _ 3 ������������ ���������',
		ch 		= 		'/iban _ 7 ��������� ������/��',
		obh 	= 		'/iban _ 7 ����� �������� ����',
		bosk 	= 		'/siban _ 999 ����������� �������',
		rk 		= 		'/siban _ 999 �������',
		obm 	= 		'/siban _ 30 �����/������',
	},
	kick = {
		kk3 	= 		'/ban _ 7 ������� ��� 3/3',
		kk2 	= 		'/kick _ ������� ��� 2/3',
		kk1 	= 		'/kick _ ������� ��� 1/3',
		cafk 	= 		'/kick _ AFK in /arena',
		dj 		= 		'/kick _ DM in jail',
	},
}
--------============= �������������� �������, ��������� ���� ===========================---------------------------
for k,v in pairs(basic_command.ans) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then for k,v in pairs(textSplit(v, '\n')) do sampSendChat(string.gsub(v, '_', param)) end else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
for k,v in pairs(basic_command.mute) do  sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param) ) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1)  end end) end
for k,v in pairs(basic_command.rmute) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
for k,v in pairs(basic_command.jail) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
for k,v in pairs(basic_command.kick) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
for k,v in pairs(basic_command.ban) do sampRegisterChatCommand(k, function(param)  if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
for k,v in pairs(basic_command.help) do sampRegisterChatCommand(k, function(param) if #param ~= 0 then sampSendChat(string.gsub(v, '_', param)) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
--============= ����������� ��� �� ������ �� �������, �� ��� ������ � �������� (��������� f) ===============================--
for k,v in pairs(basic_command.mute) do sampRegisterChatCommand(k..'f', function(param) if #param ~= 0 then sampSendChat(string.gsub(string.gsub(v, '_', param), '/mute', '/muteoff') ) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
for k,v in pairs(basic_command.rmute) do sampRegisterChatCommand(k..'f', function(param) if #param ~= 0 then sampSendChat(string.gsub(string.gsub(v, '_', param) , '/rmute', '/rmuteoff') ) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
for k,v in pairs(basic_command.jail) do sampRegisterChatCommand(k..'f', function(param) if #param ~= 0 then sampSendChat(string.gsub(string.gsub(v, '_', param) , '/jail', '/jailakk') ) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
for k,v in pairs(basic_command.ban) do sampRegisterChatCommand(k..'f', function(param) if #param ~= 0 then sampSendChat(string.gsub(string.gsub(string.gsub(v, '_', param) , '/siban', '/banoff') ,'/iban', '/banoff') ) else sampAddChatMessage(tag .. '�� �� ������� ��������.', -1) end end) end
--------============= �������������� ������� ���� (������ ��������) ===========================---------------------------
for k,v in pairs(cfg.my_command) do 
	local v = string.gsub(v, '\\n','\n')
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
							sampAddChatMessage(tag .. 'ID ������ ������ �������.', -1)
							break
						end
					else sampSendChat(b) end
				end
			end 
		end) 
	end) 
end

-- ������� or (���/���� �����) �������� �������� ����������, ������ ��������� ��������
sampRegisterChatCommand('prfma', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' ��.������������� ' .. cfg.settings.prefixma) else sampAddChatMessage(tag ..'�� �� ������� ��������.', -1) end end)
sampRegisterChatCommand('prfa', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' ������������� ' .. cfg.settings.prefixa) else sampAddChatMessage(tag ..'�� �� ������� ��������.', -1) end end)
sampRegisterChatCommand('prfsa', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' ��.������������� ' .. cfg.settings.prefixsa) else sampAddChatMessage(tag ..'�� �� ������� ��������.', -1) end end)

sampRegisterChatCommand('prfpga', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' ��������.����.�������������� ' .. color()) else sampAddChatMessage(tag .. '�� �� ������� ��������', -1) end end)
sampRegisterChatCommand('prfzga', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' ���.����.�������������� ' .. color()) else sampAddChatMessage(tag .. '�� �� ������� ��������', -1) end end)
sampRegisterChatCommand('prfga', function(param) if #param ~= 0 then sampSendChat('/prefix ' .. param .. ' �������-������������� ' .. color()) else sampAddChatMessage(tag .. '�� �� ������� ��������', -1) end end)
sampRegisterChatCommand('or', function(param) if #param ~= 0 then sampSendChat('/mute '..param..' 5000 �����������/���������� ������') else sampAddChatMessage(tag ..'�� �� ������� ��������') end end)
sampRegisterChatCommand('orf', function(param) if #param ~= 0 then sampSendChat('/muteakk '..param..' 5000 �����������/���������� ������') else sampAddChatMessage(tag ..'�� �� ������� ��������') end end)

sampRegisterChatCommand('add_autoprefix', function(param)
	if #param > 4 then
		for i = 1, #(cfg.render_admins_exception) do
			if param == cfg.render_admins_exception[i] then
				find_admin = true
				sampAddChatMessage(tag .. '������������� ' .. param .. ' ��� ������� � ������.', -1)
				for i = 1, #(cfg.render_admins_exception) do if cfg.render_admins_exception[i] then sampAddChatMessage(cfg.render_admins_exception[i], -1) end end
				break
			end
		end
		if not find_admin then 
			cfg.render_admins_exception[#(cfg.render_admins_exception) + 1] = param
			save()
			sampAddChatMessage(tag .. '������������� ' .. param .. ' ��� ������� �������� � ������ ���������� ����-������ ��������.', -1) 
		end
	else  sampAddChatMessage(tag .. '������� ��� ��������������.', -1) end
	find_admin = nil
end)
sampRegisterChatCommand('del_autoprefix', function(param)
	if #param > 4 then
		for i = 1, #(cfg.render_admins_exception) do
			if param == cfg.render_admins_exception[i] then 
				cfg.render_admins_exception[i] = nil 
				save()
				sampAddChatMessage(tag .. '������������� ' .. param .. ' ��� ������� ����� �� ������ ���������� ����-������ ��������.', -1)
				find_admin = true
				break 
			end
		end
		if not find_admin then sampAddChatMessage(tag .. '������������� ' .. param .. ' �� ��� ������ � ���������� ����-������ ��������.', -1) for i = 1, #(cfg.render_admins_exception) do if cfg.render_admins_exception[i] then sampAddChatMessage(cfg.render_admins_exception[i], -1) end end end
	else sampAddChatMessage(tag .. '������� ��� ��������������.', -1) end
	find_admin = nil
end)
sampRegisterChatCommand('color_report', function(param)
	if #param == 6 then
		cfg.settings.color_report = '{'..param..'}'
		save()
		sampAddChatMessage(tag ..cfg.settings.color_report.. '��������� ����', -1)
	elseif param == '*' then
		cfg.settings.color_report = '*'
		save()
		sampAddChatMessage(tag .. '{C0C0C0}������ {FF0000}� ��� {9370DB}����� {8FBC8F}������ {7CFC00}����� {FFA500}��� ������ {AFEEEE}�� ������!', '0x'..color())
	else 
		sampAddChatMessage(tag..'���� ������ �������. ������� HTML ���� ��������� �� 6 ��������', -1) 
		sampAddChatMessage(tag ..'������: /color_report FF0000 (����� ������ ���� ' .. '{FF0000}�������' .. '{FFFFFF})', -1)
		sampAddChatMessage(tag ..'���� �� ������ ������� ������ ����� ��� ������ ������ �������, ������� ��������� *', -1)
	end
end)
sampRegisterChatCommand('size_chat', function(param)
	if param:match('(%d+)') then
		local param = param:match('(%d+)')
		if (tonumber(param) >= 8 and tonumber(param) <= 18) or tonumber(param) == 1 then
			cfg.settings.size_text_f6 = param
			save()
			thisScript():reload()
		else sampAddChatMessage(tag .. '������� ��������� �������� �� 8 �� 18 (1 = ���������)', -1) end
	else sampAddChatMessage(tag.. '������� ��������� �������� �� 8 �� 18 (1 = ���������)', -1) end
end)
sampRegisterChatCommand('c', function(param)
	if param:find('(%d+) (.+)') then
		sampSendChat('/ans ' .. param)
		return false
	end
	if (not sampIsPlayerConnected(tonumber(param))) or (not array.flood.message[param]) then sampAddChatMessage(tag .. 'ID ������ ������ �������, �������� ����� ������ �� ����� ������ � ���, ��� � ��� �������� �������.', -1) return false end
	sampev.onShowDialog(2349, DIALOG_STYLE_INPUT, 'tipa title', 'button1', 'button2', '�����: '..sampGetPlayerNickname(param)..'\n\n\n������:' .. array.flood.message[param])
	lua_thread.create(function()
		showCursor(true,false)
		while not array.windows.fast_report.v do wait(300) end
		while array.windows.fast_report.v and not (array.answer.rabotay or array.answer.uto4 or array.answer.nakajy or array.answer.customans or array.answer.slejy or array.answer.jb or array.answer.ojid or array.answer.moiotvet or array.answer.uto4id or array.answer.nakazan or array.answer.otklon or array.answer.peredamrep) do wait(200) end
		showCursor(false,false)
		if not sampev.onShowDialog(2350, DIALOG_STYLE_INPUT, 'aboba', '��������', '�����', 'aboba') and peremrep then
			if array.answer.control_player then sampSendChat('/re ' .. autorid)
			elseif array.answer.slejy then sampSendChat('/re ' .. reportid)
			elseif array.answer.peredamrep then sampSendChat('/a ' .. autor .. '[' .. autorid .. '] | ' .. textreport) end
			sampSendChat('/ans ' .. param .. ' ' .. peremrep)
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
					else sampAddChatMessage(tag .. '�����, ���������� ������, ��������� ��� ����.', -1) end
				end
			else copies_player_recon = nil end
		else array.windows.fast_report.v = false end
	end)
end)
sampRegisterChatCommand('sbanip', function(param)
	if not param:match('(.+) (.+) (.+)') then sampAddChatMessage(tag .. '/sbanip [�����] [���] [�������]', -1) return false end
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
		if lastip then -- �� ������ ���� ������� ������� �������
			sampSendChat('/banip ' .. lastip .. ' ' .. text[2] .. ' ' .. reason)
		end
		find_ip_player, regip, lastip = false, nil, nil
	end)
end)
sampRegisterChatCommand('control_afk', function(param)
	if not tonumber(param) then sampAddChatMessage(tag .. '�������� ������� �������. ������� ���-�� �����. 0 = ����.', -1) return false end
	local param = tonumber(param)
	if param >= 0 then
		if param == 0 then 
			cfg.settings.control_afk = false
			sampAddChatMessage(tag .. '�������������� ����� �� ���� �������������.', -1)
		else 
			cfg.settings.control_afk = param
			sampAddChatMessage(tag .. '�� ������������� ������� ����, ���� �� ������ ���������� � AFK ' .. param .. '+ �����.', -1)
		end
		save()
	else sampAddChatMessage(tag .. '�������� ������� �������. ������� ���-�� �����. 0 = ����.', -1) end
end)
sampRegisterChatCommand('wh' , function()
	if not cfg.settings.wallhack then
		cfg.settings.wallhack = true
		save()
		notify('{66CDAA}[AT-WallHack]', '����� ������� ��������')
		array.checkbox.check_WallHack = imgui.ImBool(cfg.settings.wallhack),
		on_wallhack()
	else
		cfg.settings.wallhack = false
		save()
		notify('{66CDAA}[AT-WallHack]', '����� ������� ���������')
		array.checkbox.check_WallHack = imgui.ImBool(cfg.settings.wallhack),
		off_wallhack()
	end
end)
sampRegisterChatCommand('tool', function()
	array.windows.menu_tools.v = not array.windows.menu_tools.v
	imgui.Process = true
end)
sampRegisterChatCommand('opencl', function()
	array.windows.menu_chatlogger.v = not array.windows.menu_chatlogger.v
	imgui.Process = true
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
	imgui.Process = true
end)
sampRegisterChatCommand('update', function()
	if sampIsDialogActive() then return false end
	lua_thread.create(function()
		if (update_main or update_fs or update_mp) then
			sampShowDialog(1111, "���������� ����� ������ AT!", "���������� � �������:\n"..string.gsub(u8:decode(update_info),'\\n','\n')..'\n������� ����������?', "��", "���", DIALOG_STYLE_MSGBOX) -- ��� ������
			while sampIsDialogActive(1111) do wait(400) end -- ��� ���� �� �������� �� ������
			local _, button, _, _ = sampHasDialogRespond(1111)
			if button == 1 then
				local text = {[0] = '-\n', [1] = '-\n', [2] = '-'}
				if update_main then text[0] = 'AdminTools\n' end
				if update_fs then text[1] = 'FastSpawn\n' end
				if update_mp then text[2] = '�����������' end
				sampShowDialog(1111, "��������, ��� ������ ��������", (text[0]..text[1]..text[2]), "�������", nil, DIALOG_STYLE_LIST);
				while sampIsDialogActive(1111) do wait(400) end -- ��� ���� �� �������� �� ������
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
			sampShowDialog(1111, "", "���������� �� ����������, � ��� ���������� ������.\n������� �������������� ����� AT?", "��", "���", DIALOG_STYLE_MSGBOX) -- ��� ������
			while sampIsDialogActive(1111) do wait(400) end -- ��� ���� �� �������� �� ������
			local _, button, _, _ = sampHasDialogRespond(1111)
			if button == 1 then update('all') end
		end
	end)
end)
sampRegisterChatCommand('atr', function()
	if not atr then sampAddChatMessage('{37aa0d}[����������] {FFFFFF}��{32CD32} �������� ����� TakeReport.', 0x32CD32)
	else sampAddChatMessage('{37aa0d}[����������] {FFFFFF}�� {FF0000}��������� ����� TakeReport.', 0x32CD32) end
	atr = not atr
end)
sampRegisterChatCommand('autoaccept_form', function()
	cfg.settings.autoaccept_form = not cfg.settings.autoaccept_form
	save()
	if cfg.settings.autoaccept_form then
		sampAddChatMessage(tag .. "����-�������� ���� ������� ����������������.", -1)
		sampAddChatMessage(tag .. "�������, ��� �� ������ ��������������� �� ������ �������� ���������, ���� ���� ��� �����!", -1)
	else sampAddChatMessage(tag .. "������ ����� ����� �� ����.", -1) end
end)
sampRegisterChatCommand('ears', function()
	if sampIsDialogActive() then return false end
	sampSendChat('/ears')
	if array.checkbox.check_render_ears.v then
		array.ears = {}
		array.checkbox.check_render_ears.v = false
		notify('{66CDAA}[AT] ������������ ��', '������������ ������ ���������\n���� ������� ��������������')
	else
		array.checkbox.check_render_ears.v = true
		notify('{66CDAA}[AT] ������������ ��', '������������ ������ ���������\n���� ������� ����������������')
	end
end)

--======================================= ����������� ������ ====================================--
function imgui.OnDrawFrame()
	if not array.windows.render_admins.v and not array.windows.menu_tools.v and not array.windows.pravila.v and not array.windows.fast_report.v and not array.windows.recon_menu.v and not array.windows.answer_player_report.v and not array.windows.menu_chatlogger.v then
		showCursor(false,false)
		if cfg.settings.render_admins then array.windows.render_admins.v = true
		else imgui.Process = false end
	end
	if array.windows.menu_tools.v then -- ������ ���������� F3
		array.windows.render_admins.v = false
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
		imgui.Begin('xX     Admin Tools [AT]     Xx', array.windows.menu_tools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.SameLine()
		imgui.SetCursorPosX(110)
		imgui.BeginGroup()
			if imgui.Button(fa.ICON_ADDRESS_BOOK, imgui.ImVec2(30, 30)) then 		menu = '������� ����' end imgui.SameLine()
			if imgui.Button(fa.ICON_COGS, imgui.ImVec2(30, 30)) then 				menu = '�������������� �������' end imgui.SameLine()
			if imgui.Button(fa.ICON_CALENDAR_CHECK_O, imgui.ImVec2(30, 30)) then 	menu = '������� �������' end imgui.SameLine()
			if imgui.Button(fa.ICON_PENCIL_SQUARE, imgui.ImVec2(30, 30)) then 		menu = '�������' end imgui.SameLine()
			if imgui.Button(fa.ICON_RSS, imgui.ImVec2(30, 30)) then 				menu = '�����' end imgui.SameLine()
			if imgui.Button(fa.ICON_BOOKMARK, imgui.ImVec2(30, 30)) then 			menu = '������� ������' end imgui.SameLine()
			if imgui.Button(fa.ICON_CLOUD, imgui.ImVec2(30, 30)) then 				menu = '�������' end imgui.SameLine()
			if imgui.Button(fa.ICON_INFO_CIRCLE, imgui.ImVec2(30, 30)) then array.windows.menu_tools.v = false sampProcessChatInput('/ahelp') end
		imgui.EndGroup()
		imgui.SetCursorPosY(65)
        imgui.Separator()
		imgui.BeginGroup()
			if menu == '������� ����' then
				imgui.SetCursorPosX(8)
				if imadd.ToggleButton("##autoonline", array.checkbox.check_autoonline) then
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
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##inputhelper", array.checkbox.inputhelper) then
					cfg.settings.inputhelper = not cfg.settings.inputhelper
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'������� ������')
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
				imgui.Text(u8'������ �� �������')
				if imadd.ToggleButton('##automute', array.checkbox.check_automute) then
					if cfg.settings.automute and cfg.settings.smart_automute then
						cfg.settings.smart_automute = false
						array.checkbox.check_smart_automute = imgui.ImBool(cfg.settings.smart_automute)
					end
					if cfg.settings.forma_na_mute then
						cfg.settings.automute = false
						array.checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
					else cfg.settings.automute  = not cfg.settings.automute end
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'�������')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##NotifyPlayer", array.checkbox.check_answer_player_report) then
					if not cfg.settings.on_custom_recon_menu then
						sampAddChatMessage(tag .. '������ ������� �������� ������ � ������ ����� ����', -1)
						cfg.settings.answer_player_report = false
						array.checkbox.check_answer_player_report = imgui.ImBool(cfg.settings.answer_player_report)
					else cfg.settings.answer_player_report = not cfg.settings.answer_player_report end
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'����������� ������')
				if imadd.ToggleButton("##SmartAutomute", array.checkbox.check_smart_automute) then
					if not cfg.settings.automute then
						if cfg.settings.forma_na_mute then
							cfg.settings.automute = false
							cfg.settings.smart_automute = false
							array.checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
							array.checkbox.check_smart_automute = imgui.ImBool(cfg.settings.smart_automute)
						else
							cfg.settings.automute  = not cfg.settings.automute
							array.checkbox.check_automute = imgui.ImBool(cfg.settings.automute)
						end
					end
					cfg.settings.smart_automute = not cfg.settings.smart_automute
					save()
				end
				imgui.Tooltip(u8'����������� ������, ���������� ��������� ��������, ���� ��������.')
				imgui.SameLine()
				imgui.Text(u8'����� �������')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##NotifyReport", array.checkbox.check_notify_report) then
					cfg.settings.notify_report = not cfg.settings.notify_report
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'����������� � �������')
				if imadd.ToggleButton("##FastReport", array.checkbox.check_on_custom_answer) then
					cfg.settings.on_custom_answer = not cfg.settings.on_custom_answer
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'������ ����� �� ������')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##weaponhack", array.checkbox.check_weapon_hack) then
					cfg.settings.weapon_hack = not cfg.settings.weapon_hack
					save()
				end
				imgui.Tooltip(u8'������������� ��������� /iwep ����� ��������� �� ���-������\n����� �������� �������� � ��������� �������\n��� ������� ���� - ������������� �����\n�������, ��� ������� ������� �� ��� ���������� ��������������� ������ ��.\n�������� ��������� �:\nC:\\Users\\User\\���������\\GTA San Andreas User Files\\screens')
				imgui.SameLine()
				imgui.Text(u8'������� �� ���-������')
				if imadd.ToggleButton("##autoupdate", array.checkbox.check_autoupdate) then
					cfg.settings.autoupdate = not cfg.settings.autoupdate
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'����-���������� ��')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##AdminChat", array.checkbox.check_admin_chat) then
					if cfg.settings.admin_chat then array.adminchat = {} end
					cfg.settings.admin_chat = not cfg.settings.admin_chat
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'����� ���')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_ARROWS..'##3') then imgui.OpenPopup('settings_adminchat') end
				if imgui.BeginPopup('settings_adminchat') then
					imgui.CenterText(u8'������: ')
					if imgui.SliderInt('##Slider3', array.checkbox.selected_adminchat, 8, 15) then
						cfg.settings.size_adminchat = array.checkbox.selected_adminchat.v
						save()
						font_adminchat = renderCreateFont("Calibri", cfg.settings.size_adminchat, font.BOLD + font.BORDER + font.SHADOW)
					end
					imgui.CenterText(u8'���-�� �����: ')
					if imgui.SliderInt('##Slider4', array.checkbox.selected_adminchat2, 3, 20) then
						cfg.settings.strok_admin_chat = array.checkbox.selected_adminchat2.v
						save()
						if #array.adminchat > cfg.settings.strok_admin_chat then for i = cfg.settings.strok_admin_chat, #array.adminchat do array.adminchat[i] = nil end end
					end
					if imgui.Button(u8'�������� �������',imgui.ImVec2(140,24)) then
						lua_thread.create(function()
							if not array.adminchat[1] then array.adminchat[1] = '�������� ��������� ��� ��������� ����� �������.' end 
							sampAddChatMessage(tag .. '��������� ����� ������� ����: Enter', -1)
							sampAddChatMessage(tag .. '�������� ������� �������: Esc',-1)
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
					if imgui.Button(u8'�������� ���',imgui.ImVec2(125, 24)) then array.adminchat = {} end
					imgui.EndPopup()
				end
				if imadd.ToggleButton("##render/admins", array.checkbox.check_render_admins) then
					if cfg.settings.render_admins then
						cfg.settings.render_admins = not cfg.settings.render_admins
						array.admins = {}
						array.windows.render_admins.v = false
						funcadm:terminate()
					else
						cfg.settings.render_admins = not cfg.settings.render_admins
						funcadm:run()
					end
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'������ /admins')
				imgui.SameLine()
				imgui.SetCursorPosX(190)
				if imgui.Button(fa.ICON_ARROWS..'##4') then
					if cfg.settings.render_admins then
					lua_thread.create(function()
						array.windows.menu_tools.v = false
						array.windows.render_admins.v = true
						sampAddChatMessage(tag .. '��������� ����� ������� ����: Enter', -1)
						sampAddChatMessage(tag .. '�������� ������� �������: Esc',-1)
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
					else sampAddChatMessage(tag .. '����� ���������, �������� � � ������� �������.',-1) end
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
				imgui.Text(u8'������ ����� ����')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_ARROWS..'##5') then
					if cfg.settings.on_custom_recon_menu then
						if array.windows.recon_menu.v then
							lua_thread.create(function()
								sampAddChatMessage(tag .. '��������� ����� ������� ����: Enter', -1)
								sampAddChatMessage(tag .. '�������� ������� �������: Esc',-1)
								local old_pos_x, old_pos_y = cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y
								while true do
									cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y = getCursorPos()
									if wasKeyPressed(VK_RETURN) then save() break end
									if wasKeyPressed(VK_ESCAPE) then cfg.settings.position_recon_menu_x = old_pos_x cfg.settings.position_recon_menu_y = old_pos_y break end
									wait(1)
								end
							end)
						else sampAddChatMessage(tag .. '������ ����� �������� ������ � ������.', -1) end
					else sampAddChatMessage(tag ..'������� ���������, �������� � � ������� �������', -1) end
				end
				if imadd.ToggleButton("##virtualkey", array.checkbox.check_keysync) then
					cfg.settings.keysync = not cfg.settings.keysync
					save()
				end
				imgui.SameLine()
				imgui.Text(u8'�������. �������')
				imgui.SameLine()
				imgui.SetCursorPosX(190)
				if imgui.Button(fa.ICON_ARROWS..'##1') then
					if array.windows.recon_menu.v then
						lua_thread.create(function()
							sampAddChatMessage(tag .. '��������� ����� ������� ����: Enter', -1)
							sampAddChatMessage(tag .. '�������� ������� �������: Esc',-1)
							local old_pos_x, old_pos_y = cfg.settings.keysyncx, cfg.settings.keysyncy
							while true do
								cfg.settings.keysyncx, cfg.settings.keysyncy = getCursorPos()
								if wasKeyPressed(VK_RETURN) then save() break end
								if wasKeyPressed(VK_ESCAPE) then cfg.settings.keysyncx = old_pos_x cfg.settings.keysyncy = old_pos_y break end
								wait(1)
							end
						end)
					else sampAddChatMessage(tag .. '������ ����� �������� ������ � ������.', -1) end
				end
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imadd.ToggleButton("##renderEars", array.checkbox.check_render_ears) then
					if array.checkbox.check_render_ears.v then array.ears = {} end
					array.checkbox.check_render_ears.v = not array.checkbox.check_render_ears.v
					sampProcessChatInput('/ears')
				end
				imgui.SameLine()
				imgui.Text(u8'������ /ears')
				imgui.SameLine()
				imgui.SetCursorPosX(435)
				if imgui.Button(fa.ICON_ARROWS..'##2') then imgui.OpenPopup('settings_ears') end
				if imgui.BeginPopup('settings_ears') then  
					imgui.CenterText(u8'������: ')
					if imgui.SliderInt('##Slider1', array.checkbox.selected_ears, 8, 15) then
						cfg.settings.size_ears = array.checkbox.selected_ears.v
						save()
						font_earschat = renderCreateFont("Calibri", cfg.settings.size_ears, font.BOLD + font.BORDER + font.SHADOW)
					end
					imgui.CenterText(u8'���-�� �����: ')
					if imgui.SliderInt('##Slider2', array.checkbox.selected_ears2, 3, 20) then
						cfg.settings.strok_ears = array.checkbox.selected_ears2.v
						save()
						if #array.ears > cfg.settings.strok_ears then for i = cfg.settings.strok_ears, #array.ears do array.ears[i] = nil end end
					end
					if imgui.Button(u8'�������� �������',imgui.ImVec2(140,24)) then
						if array.checkbox.check_render_ears.v then
							lua_thread.create(function()
								if not array.ears[1] then array.ears[1] = '�������� ��������� ��� ��������� ����� �������.' end 
								sampAddChatMessage(tag .. '��������� ����� ������� ����: Enter', -1)
								sampAddChatMessage(tag .. '�������� ������� �������: Esc',-1)
								local old_pos_x, old_pos_y = cfg.settings.position_ears_x, cfg.settings.position_ears_y
								while true do
									cfg.settings.position_ears_x, cfg.settings.position_ears_y = getCursorPos()
									if wasKeyPressed(VK_RETURN) then save() break end
									if wasKeyPressed(VK_ESCAPE) then cfg.settings.position_ears_x = old_pos_x cfg.settings.position_ears_y = old_pos_y break end
									wait(1)
								end
							end)
						else sampAddChatMessage(tag .. '������� ���������, �������� � � ��������� �������.', -1) end
					end
					imgui.SameLine()
					if imgui.Button(u8'�������� ���',imgui.ImVec2(125, 24)) then array.ears = {} end
					imgui.EndPopup()
				end
				imgui.SetCursorPosY(420)
				imgui.Separator()
				imgui.Text(u8'����������� ������� - N.E.O.N')
				imgui.Text(u8'�������� �����:')
				imgui.SameLine()
				if imgui.Link("https://vk.com/alexandrkob", u8"�����, ����� ������� ������ � ��������") then
					os.execute(('explorer.exe "%s"'):format("https://vk.com/alexandrkob"))
				end
				imgui.Text(u8'������ VK:')
				imgui.SameLine()
				if imgui.Link("https://vk.com/club222702914", u8"�����, ����� ������� ������ � ��������") then
					os.execute(('explorer.exe "%s"'):format("https://vk.com/club222702914"))
				end
			elseif menu == '�������������� �������' then -- ������ �����
				imgui.SetCursorPosX(8)
				imgui.CenterText(u8'�������������� ����� ������')
				imgui.PushItemWidth(485)
				if imgui.InputText('##doptextcommand', array.buffer.add_new_text) then
					cfg.settings.mytextreport = u8:decode(array.buffer.add_new_text.v)
					save()	
				end
				imgui.PopItemWidth()
				imgui.Separator()
				imgui.Text(u8'������� �������')
				imgui.SameLine()
				imgui.SetCursorPosX(275)
				imgui.PushItemWidth(100)
				if imgui.InputText('##prfh', array.buffer.new_prfh) then
					cfg.settings.prefixh = array.buffer.new_prfh.v
					save()
				end
				imgui.PopItemWidth()
				imgui.Text(u8'������� �������� ��������������')
				imgui.SameLine()
				imgui.SetCursorPosX(275)
				imgui.PushItemWidth(100)
				if imgui.InputText('##prfma', array.buffer.new_prfma) then
					cfg.settings.prefixma = array.buffer.new_prfma.v
					save()
				end
				imgui.PopItemWidth()
				imgui.Text(u8'������� ��������������')
				imgui.SameLine()
				imgui.SetCursorPosX(275)
				imgui.PushItemWidth(100)
				if imgui.InputText('##prfa', array.buffer.new_prfa) then
					cfg.settings.prefixa = array.buffer.new_prfa.v
					save()
				end
				imgui.PopItemWidth()
				imgui.Text(u8'������� �������� ��������������')
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
				if imgui.Button(u8'��������', imgui.ImVec2(228, 24)) then
					array.windows.menu_tools.v = false
					sampProcessChatInput('/trassera')
				end
				if imgui.Button(u8'���������� �� ����', imgui.ImVec2(250, 24)) then
					sampProcessChatInput('/state')
					array.windows.menu_tools.v = false
					showCursor(true,false)
				end
				imgui.SameLine()
				if imgui.Button(u8'���-������', imgui.ImVec2(228, 24)) then array.windows.menu_chatlogger.v = true array.windows.menu_tools.v = false end
				if imgui.Button(u8'�������� ��������� �����������', imgui.ImVec2(485, 24)) then sampSendChat('/mp') array.windows.menu_tools.v = false end
				if imgui.Button(u8'����-�������� ���� ��� ������� ���������������', imgui.ImVec2(485, 24)) then imgui.OpenPopup('autoform') end
				if imgui.Button(u8'������������ ���� � AFK', imgui.ImVec2(485, 24)) then
					if not cfg.settings.control_afk then
						sampAddChatMessage(tag .. '������� ���-�� ����� � AFK, ����� �������� ���� ������������� ���������.', -1)
						sampSetChatInputText('/control_afk ') 
						sampSetChatInputEnabled(true)
					else cfg.settings.control_afk = false sampAddChatMessage(tag .. '���������.', -1) end
				end
				if imgui.Button(u8'���������� �������� (��� ������������ �������)', imgui.ImVec2(485, 24)) then imgui.OpenPopup('autoprefix') end
				if imgui.BeginPopup('autoform') then
					imgui.CenterText(u8'����� �������� � ��� ���?')
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
							array.checkbox.check_form_mute = imgui.ImBool(cfg.settings.forma_na_mute)
							sampAddChatMessage(tag .. '� ��� ������� �������, �� ��������� ����� ������ ����� ��������� ���������.', -1)
						end
						save()
					end
					if imgui.Checkbox('/kick', array.checkbox.check_form_kick) then
						cfg.settings.forma_na_kick = not cfg.settings.forma_na_kick
						save()
					end
					if imgui.Checkbox(u8'��������� // ��� ���', array.checkbox.check_add_mynick_form) then
						cfg.settings.add_mynick_in_form = not cfg.settings.add_mynick_in_form
						save()
					end
					imgui.EndPopup()
				end
				if imgui.BeginPopup('autoprefix') then
					if array.checkbox.autoprefix.v then imgui.Text(u8'������: �������')
					else imgui.Text(u8'������: ��������������') end
					imgui.SameLine()
					imgui.SetCursorPosX(200)
					if imadd.ToggleButton('##autoprefix', array.checkbox.autoprefix) then
						cfg.settings.autoprefix = not cfg.settings.autoprefix
						save()
					end
					if imgui.Button(u8'�������� ����������') then
						sampSetChatInputText('/add_autoprefix ')  
						sampSetChatInputEnabled(true)
					end
					imgui.SameLine()
					if imgui.Button(u8'������ ����������') then
						sampSetChatInputText('/del_autoprefix ')  
						sampSetChatInputEnabled(true)
					end
					imgui.EndPopup()
				end
				imgui.SetCursorPosY(470)
				if imgui.Button(u8'������������� ������� '..fa.ICON_RECYCLE, imgui.ImVec2(250,24)) then reloadScripts() end
				imgui.SameLine()
				if imgui.Button(u8'��������� ������ ' .. fa.ICON_POWER_OFF, imgui.ImVec2(228, 24)) then ScriptExport() end
			elseif menu == '������� �������' then -- ������� �������
				imgui.SetCursorPosX(8)
				imgui.NewInputText('##SearchBar7', array.buffer.new_binder_key, 485, u8'����� �������', 2)
				imgui.PushItemWidth(485)
				imgui.Combo("##����� ��������", array.checkbox.new_binder_key, {u8"��������� �������", u8"��������� �������", u8"�������� � ���� �����"}, 3)
				imgui.PopItemWidth()
				if imgui.Button(u8'��������', imgui.ImVec2(250,24)) and #(u8:decode(array.buffer.new_binder_key.v)) ~= 0 then
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.binder_key[getDownKeysText()] = array.checkbox.new_binder_key.v ..'\\n'.. u8:decode(array.buffer.new_binder_key.v)
						save()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'�������', imgui.ImVec2(228,24)) and #(u8:decode(array.buffer.new_binder_key.v)) ~= 0 then
					for k,v in pairs(cfg.binder_key) do
						if (u8:decode(array.buffer.new_binder_key.v) == string.sub(v, 4)) then
							cfg.binder_key[k] = nil
							save()
							sampAddChatMessage(tag .. '������ ������.', -1)
						end
					end 
				end
				imgui.Separator()
				imgui.CenterText(u8'�������� ���� AT:')
				imgui.SameLine()
				imgui.Text(u8(cfg.settings.open_tool))
				if imgui.Button(u8"�oxpa����.", imgui.ImVec2(250, 24)) then
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.settings.open_tool = getDownKeysText()
						save()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'����c���', imgui.ImVec2(228,24)) then
					cfg.settings.open_tool = 'None'
					save()
				end
				imgui.CenterText(u8'�������� �������:')
				imgui.SameLine()
				imgui.Text(u8(cfg.settings.fast_key_ans))
				if imgui.Button(u8"�ox�a����.", imgui.ImVec2(250, 24)) then
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.settings.fast_key_ans = getDownKeysText()
						save()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'���oc���', imgui.ImVec2(228,24)) then
					cfg.settings.fast_key_ans = 'None'
					save()
				end
				imgui.CenterText(u8"�������� � ��� ����� ������:")
				imgui.SameLine()
				imgui.Text(cfg.settings.fast_key_addText)
				if imgui.Button(u8"Cox�a����.", imgui.ImVec2(250, 24)) then
					if getDownKeysText() and not getDownKeysText():find('+') then
						cfg.settings.fast_key_addText = getDownKeysText()
						save()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'��������', imgui.ImVec2(228,24)) then
					cfg.settings.fast_key_addText = 'None'
					save()
				end
				imgui.Separator()
				imgui.CenterText(u8'[��� ������� �������]')
				for k, v in pairs(cfg.binder_key) do
					imgui.Text(u8('[������� '..k..'] = '))
					imgui.Tooltip(u8'�����, ����� �������')
					if imgui.IsItemClicked(0) then
						cfg.binder_key[k] = nil
						save()
					end
					imgui.SameLine()
					imgui.Text(u8(string.sub(v, 4)))
				end
				imgui.SetCursorPosY(475)
				if getDownKeysText() and not getDownKeysText():find('+') then imgui.Text(u8'������ �������: ' .. getDownKeysText())
				else imgui.Text(u8'��� ������� �������') end
				imgui.SameLine()
				imgui.SetCursorPosX(253)
				if imgui.Button(u8"�������� �������� ���� ������") then
					for k,v in pairs(cfg.binder_key) do cfg.binder_key[k] = nil end
					save()
				end
			elseif menu == '�������' then
				array.buffer.bloknotik.v = string.gsub(array.buffer.bloknotik.v, "\\n", "\n")
				if imgui.InputTextMultiline("##1", array.buffer.bloknotik, imgui.ImVec2(490, 500)) then
					array.buffer.bloknotik.v = string.gsub(array.buffer.bloknotik.v, "\n", "\\n")
					cfg.settings.bloknotik = u8:decode(array.buffer.bloknotik.v)
					save()	
				end
			elseif menu == '�����' then -- �����
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'��� �����', imgui.ImVec2(410, 25)) then
					array.windows.new_flood_mess.v = not array.windows.new_flood_mess.v 
				end
				imgui.CenterText(u8'����� /gw')
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'Aztecas vs Ballas', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Ballas Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'Aztecas vs Grove', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Grove Street Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'Aztecas vs Vagos', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs Vagos Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'Aztecas vs Rifa', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Varios Los Aztecas vs The Rifa ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'Ballas vs Grove', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Ballas Gang vs Grove Street Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'Ballas vs Vagos', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Ballas Gang vs Vagos Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'Ballas vs Rifa', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Ballas Gang vs The Rifa ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'Grove vs Vagos', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Grove Street Gang vs Vagos Gang ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'Vagos vs Rifa', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
					sampSendChat('/mess 14 �� ������ ������ �������� ����������� �������� ���� ���������� �����������.')
					sampSendChat('/mess 14 ## Vagos Gang vs The Rifa ##')
					sampSendChat('/mess 14 ������ ������� �������� ���� ���������� � �������� ����� �����, ����� /gw!')
					sampSendChat('/mess 11 --------===================| GangWar |================-----------')
				end
				imgui.CenterText(u8'����� �����')
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'����� ����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 10 --------===================| Spawn Auto |================-----------')
					sampSendChat('/mess 15 �������������� �������� � ���������')
					sampSendChat('/mess 15 ����� 15 ������ ������ ������� ����� ���������� �� �������.')
					sampSendChat('/mess 15 ������� ���� ����� ���� �� ��������� ������ :3')
					sampSendChat('/mess 10 --------===================| Spawn Auto |================-----------')
					sampSendChat('/delcarall')
					sampSendChat('/spawncars 15')
				end
				imgui.SameLine()
				if imgui.Button(u8'/trade', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 3 --------===================| ����� |================-----------')
					sampSendChat('/mess 0 ������ ���������� ����������� �� ���� ����?')
					sampSendChat('/mess 0 ������ � ������ ������������ �� ����� � �������� ��� ��������?')
					sampSendChat('/mess 0 ������ ����� /trade, ������� ����� ������������, ��� �� �������, ��� � �� �������!')
					sampSendChat('/mess 3 --------===================| ����� |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'��������������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 16 --------===================| �������������� |================-----------')
					sampSendChat('/mess 17 ������ ������ ���������� ���� �� ���� ���������? �� ��������!')
					sampSendChat('/mess 17 � �������������� �� /tp - ������ - �������������� �������� � �� �����.')
					sampSendChat('/mess 17 ������ ������� ������ ��������� ��� ���� ���� � ����')
					sampSendChat('/mess 16 --------===================| �������������� |================-----------')
				end
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'������/�����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 11 --------===================| ��������� �������� |================-----------')
					sampSendChat('/mess 7 � ������ ������� ������� ������ vk.�om/teamadmrds ...')
					sampSendChat('/mess 7 ... � ���� �����, �� ������� ������ ����� �������� ������ �� ������������� ��� �������.')
					sampSendChat('/mess 7 ����� �� ��������� � ���� ������ �������.')
					sampSendChat('/mess 11 --------===================| ��������� �������� |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'VIP', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 13 --------===================| ������������ VIP |================-----------')
					sampSendChat('/mess 7 ������ ������ � �������� ��� �����������?')
					sampSendChat('/mess 7 ������ ������ ����������������� �� ����� � � �������, ����� ���� ������ ������?')
					sampSendChat('/mess 7 ������ �������� ������ PayDay ������ �� ���� �������? ���������� VIP-��������!')
					sampSendChat('/mess 13 --------===================| ������������ VIP |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'�����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 12 --------===================| PVP Arena |================-----------')
					sampSendChat('/mess 10 �� ������ ��� ��������? ������� ������ � ������� �������?')
					sampSendChat('/mess 10 ����� /arena � ������ �� ��� �� ��������!')
					sampSendChat('/mess 10 ����� ������������ ���������� ������, ������� ������ � ����� +C')
					sampSendChat('/mess 12 --------===================| PVP Arena |================-----------')
				end
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'����������� ���', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ���� ����������� ��� |================-----------')
					sampSendChat('/mess 15 ������ ������? ��������� ���������� ����� � �������?')
					sampSendChat('/mess 15 ������� ������ ����� �� ������� �� ����� ������?')
					sampSendChat('/mess 15 ����� ����! ����� /dt [0-999] � ������ � ���������.')
					sampSendChat('/mess 8 --------===================| ���� ����������� ��� |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'����� �� �������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 3 --------===================| ����� �� ���� �������������� |================-----------')
					sampSendChat('/mess 2 ������ ������ �� ���� ��������������? ������� ������ �� ������� � �����������?')
					sampSendChat('/mess 2 �� ��� �������� � ���������� ��������� <3')
					sampSendChat('/mess 2 �� ����� ������ https://forumrds.ru/ ������ �����, ����� ������ ������, ���-�� ���� ����������.')
					sampSendChat('/mess 3 --------===================| ����� �� ���� �������������� |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'� /report', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 17 --------===================| ����� � �������������� |================-----------')
					sampSendChat('/mess 13 ����� ������, ��������� ����������, �����, ��� ������ ������ ������?')
					sampSendChat('/mess 13 �������� ������ � ������������ ������� ��� ��� ������������?')
					sampSendChat('/mess 13 ������������� �������! ���� /report � ���� ������/������')
					sampSendChat('/mess 17 --------===================| ����� � �������������� |================-----------')
				end
				imgui.CenterText(u8'����������� /join')
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'�����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ����������� ����� |================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� �����')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 1')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------===================| ����������� ����� |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ����������� /parkour |================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ������')
					sampSendChat('/mess 0 ����� ������� ������� ����� /parkour ���� /join - 2')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------===================| ����������� /parkour |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'PUBG', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ����������� /pubg |================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� Pubg')
					sampSendChat('/mess 0 ����� ������� ������� ����� /pubg ���� /join - 3')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------===================| ����������� /pubg |================-----------')
				end
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'DAMAGE DEATHMATCH', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ����������� /damagegm |================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� DAMAGE DEATHMATCH')
					sampSendChat('/mess 0 ����� ������� ������� ����� /damagegm ���� /join - 4')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------===================| ����������� /damagegm |================-----------')
		
				end
				imgui.SameLine()
				if imgui.Button(u8'KILL DEATHMATCH', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ����������� KILL DEATHMATCH |================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� DAMAGE DEATHMATCH')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 5')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------===================| ����������� KILL DEATHMATCH |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'Paint Ball', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ����������� Paint Ball |================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� Paint Ball')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 7')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------===================| ����������� Paint Ball |================-----------')
				end
				imgui.SetCursorPosX(50)
				if imgui.Button(u8'����� vs �����', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ����� ������ ����� |================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ����� ������ �����')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 8')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------===================| ����� ������ ����� |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ����������� ������ |================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ������')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 10')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------===================| ����������� ������ |================-----------')
				end
				imgui.SameLine()
				if imgui.Button(u8'���������', imgui.ImVec2(130, 25)) then
					sampSendChat('/mess 8 --------===================| ����������� ��������� |================-----------')
					sampSendChat('/mess 0 �� ������ ������ �������� ���� ������� �� ����������� ���������')
					sampSendChat('/mess 0 ����� ������� ������� ����� /join - 11')
					sampSendChat('/mess 0 ����������! ���������� ���� ����������.')
					sampSendChat('/mess 8 --------===================| ����������� ��������� |================-----------')
				end
			elseif menu == '������� ������' then -- ������� ������
				imgui.SetCursorPosX(125)
				if imgui.Button(u8'�������� ��� �����', imgui.ImVec2(250, 24)) and #(array.buffer.custom_answer.v) > 1 then
					if #(u8:decode(array.buffer.custom_answer.v)) < 80 then
						cfg.customotvet[#(cfg.customotvet) + 1] = u8:decode(array.buffer.custom_answer.v)
						save()
						array.buffer.custom_answer.v = ''
						imgui.SetKeyboardFocusHere(-1)
					else sampAddChatMessage(tag .. '������� ����� ��������, ��������� �����', -1) end
				end
				imgui.NewInputText('##SearchBar2', array.buffer.custom_answer, 485, u8'������� ��� �����.', 2)
				imgui.Separator()
				imgui.CenterText(u8'����������� ������')
				for k,v in pairs(cfg.customotvet) do
					if imgui.Button(u8(v), imgui.ImVec2(485, 24)) then
						cfg.customotvet[k] = nil
						save()
					end
					imgui.Tooltip(u8'�����, ����� ������� �����.')
				end

			elseif menu == '�������' then -- �������, ������� �������, ����� �����
				imgui.SetCursorPosX(10)
				imgui.Checkbox('##celoeslovo', array.checkbox.add_full_words)
				imgui.Tooltip(u8'��� = ���������� ������������� ������ �����, � �� ��������')
				imgui.SameLine()
				imgui.CenterText(u8'�������� ��� (����� � �������: ' .. #array.mat..')')
				imgui.SameLine()
				imgui.Text(fa.ICON_EYE)
				imgui.Tooltip(u8'�����, ����� ������� ������������ �������')
				if imgui.IsItemClicked(0) then -- ���� ������� �� ������ �����
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
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. array.buffer.newmat.v .. ' {F0E68C}��� ������� � ������ �����.', -1)
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
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. array.buffer.newmat.v .. ' {F0E68C}���� ������� ��������� � ������ �����.', -1)
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
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ��������� ���� �����{008000} ' .. array.buffer.newmat.v .. ' {F0E68C}���� ������� ������� �� ������ �����', -1)
							break
						end
					end
					if not find_words then sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ������ ����� � ������ ����� ���.', -1) end
					find_words = nil
					array.buffer.newmat.v = ''
					imgui.SetKeyboardFocusHere(-1)
				end
				imgui.CenterText(u8'�������� ����������� (����� � �������: ' .. #array.osk .. ')')
				imgui.SameLine()
				imgui.Text(fa.ICON_EYE)
				imgui.Tooltip(u8'�����, ����� ������� ������������ �������')
				if imgui.IsItemClicked(0) then -- ���� ������� �� ������ �����
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
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. array.buffer.newosk.v .. ' {F0E68C}��� ������� � ������ �����������.', -1)
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
						sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} �����{008000} ' .. array.buffer.newosk.v .. ' {F0E68C}���� ������� ��������� � ������ �����������.', -1)
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
							sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ��������� ���� �����{008000} ' .. array.buffer.newosk.v .. ' {F0E68C}���� ������� ������� �� ������ �����������', -1)
							break
						end
					end
					if not find_words then sampAddChatMessage('{DDA0DD}[AutoMute]:{F0E68C} ������ ����� � ������ ����������� ���.', -1) end
					find_words = nil
					array.buffer.newosk.v = ''
					imgui.SetKeyboardFocusHere(-1)
				end
				imgui.CenterText(u8'�������� ���� ����������')
				imgui.PushItemWidth(480)
				if imgui.Combo("##selected", array.checkbox.style_selected, {u8"������������ ����", u8"������� ����", u8"����� ����", u8"���������� ����", u8"������� ����", u8"������� ����"}, array.checkbox.style_selected) then
					cfg.settings.style = array.checkbox.style_selected.v 
					save()
					style(cfg.settings.style)
				end
				imgui.PopItemWidth()
				imgui.CenterText(u8'�������� ������� �������')
				imgui.NewInputText('##titlecommand5', array.buffer.new_command_title, 480, u8'�������� ������� (������: /ok, /dz, /ch)', 2)
				imgui.InputTextMultiline("##newcommand", array.buffer.new_command, imgui.ImVec2(480, 170))
				if imgui.Button(u8'�������� ���������', imgui.ImVec2(480, 24)) then
					imgui.OpenPopup('settings_command')
				end
				if imgui.BeginPopup('settings_command') then
					if imgui.Button(u8'��������, ����� ��������') then
						array.buffer.new_command.v = array.buffer.new_command.v .. u8'\nwait(���-�� ������)'
						sampAddChatMessage(tag .. '������� ���������� ������ ��������', -1)
					end
					if imgui.Button(u8'�������� ��� �����') then
						array.buffer.new_command.v = array.buffer.new_command.v .. '_'
					end
					imgui.SameLine()
					imgui.Text(u8'(?)')
					imgui.Tooltip(u8'�������� ������� �� ������� � �������\n�������� /mk 525 - � ���� ������� ���������� �������� ����� 525\n������ ����� ����� �������������� ��� ���� ����������')
					if imgui.Button(u8'��� ������ �� ��� ID') then
						array.buffer.new_command.v = array.buffer.new_command.v .. 'nick(_)'
					end
					imgui.SameLine()
					imgui.Text(u8'(?)')
					imgui.Tooltip(u8'������ ����� _ �� ������ ������� ���� ������������� ��������\n�� ��������� �� ����� ��������� ���� ��������.')
					imgui.EndPopup()
				end
				if imgui.Button(u8'����a����', imgui.ImVec2(250, 24)) then
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
												sampAddChatMessage(tag .. 'ID ������ ������ �������.', -1)
												break
											end
										else sampSendChat(b) end
									end
								end 
							end) 
						end) 
						sampAddChatMessage(tag .. '����� ������� /' .. array.buffer.new_command_title.v .. ' ������� �������.',-1)
						array.buffer.new_command.v, array.buffer.new_command_title.v = '',''
					else sampAddChatMessage(tag .. '��� �� ��������� ���������?', -1) end
				end
				imgui.SameLine()
				if imgui.Button(u8'�������', imgui.ImVec2(222, 24)) then
					if #(array.buffer.new_command_title.v) == 0 then sampAddChatMessage(tag ..'�� �� ������� �������� �������, ��� �� ��������� �������?', -1)
					else
						array.buffer.new_command_title.v = string.gsub(u8:decode(array.buffer.new_command_title.v), '/', '')
						if cfg.my_command[array.buffer.new_command_title.v] then
							cfg.my_command[array.buffer.new_command_title.v] = nil
							save()
							array.buffer.new_command_title.v = ''
							sampAddChatMessage(tag .. '������� ���� ������� �������. ���������� ����������� ����� ������������ ����.', -1)
						else sampAddChatMessage(tag .. '����� ������� � ���� ������ ���.', -1) end
					end
				end
			end
		imgui.EndGroup()
		imgui.PopFont()
 		imgui.End()
	end
	if array.windows.fast_report.v then -- ������� ����� �� ������
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5) - 250, (sh * 0.5)-90), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'����� �� ������', array.windows.fast_report, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8('�����: '..autor .. '[' ..autorid.. ']'))
		imgui.SameLine()
		if tonumber(autorid) then 				-- ���� ����� � ����
			imgui.Text(fa.ICON_EYE) 			-- ������ �����
			if imgui.IsItemClicked(0) or (isKeyDown(VK_X) and not sampIsChatInputActive()) then
				array.answer.rabotay = true 			-- ���������� ��� �������� �� ������
				array.answer.control_player = true 	-- ��������� � �����
			end
			imgui.Tooltip('X')
			imgui.SameLine()
		end
 		imgui.SameLine()
		imgui.Text(fa.ICON_FILES_O)
		if imgui.IsItemClicked(0) then 
			setClipboardText(autor)
			sampAddChatMessage(tag .. '��� ���������� � ����� ������.', -1)
		end
		imgui.TextWrapped(u8('������: ' .. textreport))
		if reportid and sampIsPlayerConnected(reportid) then
			imgui.SameLine()
			imgui.TextColoredRGB(u8('{D3D3D3}>> '..sampGetPlayerNickname(reportid)))
		end
		if wasKeyPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end 
		imgui.NewInputText('##SearchBar', array.buffer.text_ans, 375, u8'������� ��� �����.', 2)
		imgui.SameLine()
		imgui.SetCursorPosX(392)
		imgui.Tooltip('Space')
		if imgui.Button(u8'��������� ' .. fa.ICON_SHARE, imgui.ImVec2(120, 25)) or (not cfg.settings.enter_report and wasKeyPressed(VK_RETURN) and not sampIsChatInputActive()) then
			if #(u8:decode(array.buffer.text_ans.v)) ~= 0 then array.answer.moiotvet = true
			else sampAddChatMessage(tag .. '����� �� ����� 1 �������.', -1) end
		end
		imgui.Tooltip('Enter')
		imgui.Separator()
		if #(array.buffer.text_ans.v) > 5 then
			if imgui.Checkbox(u8"��� ������� �� Enter ��������� ����������� �����", array.checkbox.button_enter_in_report) then
				cfg.settings.enter_report = not cfg.settings.enter_report
				save()
			end
			for k,v in pairs(cfg.customotvet) do
				if string.rlower(v):find(string.rlower(u8:decode(array.buffer.text_ans.v))) or string.rlower(v):find(translateText(u8:decode(array.buffer.text_ans.v))) then
					if imgui.Button(u8(v), imgui.ImVec2((sw * 0.5) - 295, 24)) or (wasKeyPressed(VK_RETURN) and not sampIsChatInputActive()) then
						if not array.answer.customans then 
							array.answer.customans = v
						end
					end
				end
			end
		else
			if imgui.Button(u8'�������', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_Q) and not sampIsChatInputActive()) then
				array.answer.rabotay = true
			end
			imgui.Tooltip('Q')
			imgui.SameLine()
			if imgui.Button(u8'�����', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_E) and not sampIsChatInputActive()) then
				array.answer.slejy = true
			end
			imgui.Tooltip('E')
			imgui.SameLine()
			if imgui.Button('Skin/Color', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_R) and not sampIsChatInputActive()) then
				start_my_answer()
			end
			imgui.Tooltip('R')
			imgui.SameLine()
			if imgui.Button(u8'��������', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_V) and not sampIsChatInputActive()) then
				imgui.OpenPopup('peredat')
			end
			imgui.Tooltip('V')
			if imgui.Button(u8'��������', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_G) and not sampIsChatInputActive()) then
				imgui.OpenPopup('option')
			end
			if imgui.BeginPopup('option') then
				if imgui.Button(u8'������ (1)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_1) then
					array.nakazatreport.oftop = true
					array.answer.nakajy = true
				end
				if imgui.Button(u8'���� (2)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_2) then
					array.nakazatreport.capsrep = true
					array.answer.nakajy = true
				end
				if imgui.Button(u8'����������� ������������� (3)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_3) then
					array.nakazatreport.oskadm = true
					array.answer.nakajy = true
				end
				if imgui.Button(u8'������� �� ������������� (4)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_4) then
					array.nakazatreport.kl = true
					array.answer.nakajy = true
				end
				if imgui.Button(u8'���/���� ������ (5)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_5) then
					array.nakazatreport.oskrod = true
					array.answer.nakajy = true
				end
				if imgui.Button(u8'���������������� (6)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_6) then
					array.nakazatreport.poprep = true
					array.answer.nakajy = true
				end
				if imgui.Button(u8'�����������/�������� (7)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_7) then
					array.nakazatreport.oskrep = true
					array.answer.nakajy = true
				end
				if imgui.Button(u8'����������� ������� (8)', imgui.ImVec2(250, 25)) or wasKeyPressed(VK_8) then
					array.nakazatreport.matrep = true
					array.answer.nakajy = true
				end
				if imgui.Button(u8'������ (9)', imgui.ImVec2(250,25)) or wasKeyPressed(VK_9) then
					array.nakazatreport.rozjig = true
				end
				imgui.EndPopup()
			end
			imgui.Tooltip('G')
			imgui.SameLine()
			if imgui.Button(u8'�������� ID', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_B) and not sampIsChatInputActive()) then
				array.answer.uto4id = true
			end
			imgui.Tooltip('B')
			imgui.SameLine()
			if imgui.Button(u8'�����', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_F) and not sampIsChatInputActive()) then
				array.answer.uto4 = true
			end
			imgui.Tooltip('F')
			imgui.SameLine()
			if imgui.Button(u8'���������', imgui.ImVec2(120, 25)) or (wasKeyPressed(VK_Y) and not sampIsChatInputActive()) then
				array.answer.otklon = true
			end
			imgui.Tooltip('Y')
			if imgui.BeginPopup('peredat') then
				if imgui.Button(u8'�������� ������ ������� �������������� (1)', imgui.ImVec2(350, 25)) or isKeyDown(VK_1) then
					sampCloseCurrentDialogWithButton(0)
					array.windows.fast_report.v = false
				end
				if imgui.Button(u8'�������� ������ (2)', imgui.ImVec2(350, 25)) or isKeyDown(VK_2) then
					array.answer.peredamrep = true
				end
				imgui.EndPopup()
			end
		end
		imgui.Separator()
		if imadd.ToggleButton('##doptextans', array.checkbox.check_add_answer_report) then
			cfg.settings.add_answer_report = not cfg.settings.add_answer_report
			save()
		end
		imgui.SameLine()
		imgui.Text(u8'�������� �������������� ����� � ������ ' .. fa.ICON_COMMENTING_O)
		if imadd.ToggleButton('##saveans', array.checkbox.check_save_answer) then
			cfg.settings.custom_answer_save = not cfg.settings.custom_answer_save
			save()
		end
		imgui.Tooltip(u8'��������� ��� ����� � ������. �� ���������, ���� ���-�� �������� � ������ �������� ��������')
		imgui.SameLine()
		imgui.Text(u8'��������� ������ ����� � ���� ������ ������� ' .. fa.ICON_DATABASE)
		if imadd.ToggleButton('##newcolor', array.checkbox.check_color_report) then
			if not cfg.settings.on_color_report then
				sampAddChatMessage(tag .. '���� �� ������� �������� ���� - ������� HTML ���� � ������ �������', -1)
				sampSetChatInputText('/color_report ')
				sampSetChatInputEnabled(true)
			end
			cfg.settings.on_color_report = not cfg.settings.on_color_report
			save()
		end
		imgui.Tooltip(u8'��������� ������� � ������. �� ���������, ���� ���-�� �������� � ������ �������� ��������\n������ ������������� ������������ ��� ���.������')
		imgui.SameLine()
		imgui.Text(u8'����������� ��� ����� � ������ ���� ' .. fa.ICON_TACHOMETER)
		imgui.PopFont()
		imgui.End()
	end
	if array.windows.recon_menu.v then
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.position_recon_menu_x, cfg.settings.position_recon_menu_y))
		imgui.Begin("##recon", array.windows.recon_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.ShowCursor = false
		imgui.PushFont(fontsize)
		imgui.BeginGroup()
			if imgui.Button(u8'����� ' ..fa.ICON_MALE, imgui.ImVec2(120, 25)) then menu_in_recon = '������� ����' end imgui.SameLine()
			if imgui.Button(u8'� ������� ' .. fa.ICON_USERS, imgui.ImVec2(120, 25)) then menu_in_recon = '�������������� �������' end
		imgui.EndGroup()
		imgui.BeginGroup()
			if menu_in_recon == '������� ����' then
				imgui.SetCursorPosX(10)
				if imgui.Button(fa.ICON_FILES_O) then
					setClipboardText(sampGetPlayerNickname(control_player_recon))
					sampAddChatMessage(tag .. '��� ���������� � ����� ������. (ctrl + v)', -1)
				end
				imgui.SameLine()
				if sampIsPlayerConnected(control_player_recon) then
					imgui.Text(sampGetPlayerNickname(control_player_recon) .. '[' .. control_player_recon .. ']')
				end
				imgui.Separator()
				if array.inforeport[14] then
					imgui.Text(u8'�������� ����: ' .. array.inforeport[3])
					imgui.Text(u8'��������: ' .. array.inforeport[4])
					imgui.Text(u8'������: ' .. array.inforeport[6])
					imgui.Text(u8'��������: ' .. array.inforeport[7])
					imgui.Text('Ping: ' .. array.inforeport[5])
					imgui.Text('AFK: ' .. array.inforeport[9])
					imgui.Text('VIP: ' .. array.inforeport[11])
					imgui.Text('Passive mode: ' .. array.inforeport[12])
					imgui.Text(u8'����� �����: ' .. array.inforeport[13])
					imgui.Text(u8'��������: ' .. array.inforeport[14])
				else imgui.Text(u8'���������� � ������ ����������.') end
				if imgui.Button(u8'���������� ������ ����������', imgui.ImVec2(250, 25)) then
					sampSendChat('/statpl ' .. sampGetPlayerNickname(control_player_recon))
				end
				if imgui.Button(u8'���������� ������ ����������', imgui.ImVec2(250, 25)) then
					sampSendClickTextdraw(array.textdraw.stats)
				end
				if imgui.Button(u8'���������� /offstats ����������', imgui.ImVec2(250, 25)) then
					sampSendChat('/offstats ' .. sampGetPlayerNickname(control_player_recon))
					sampSendDialogResponse(16200, 1, 0)
				end
				if imgui.Button(u8'���������� ���������� ������', imgui.ImVec2(250, 25)) then
					sampSendChat('/tonline')
				end
			elseif menu_in_recon == '�������������� �������' then
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
	if array.windows.menu_in_recon.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowPos(imgui.ImVec2((sw*0.5)-300, sh-60))
		imgui.Begin("##recon+", array.windows.menu_in_recon, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
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
		imgui.Tooltip('NumPad 4')
		imgui.SameLine()
		if imgui.Button(u8'�������� ������') then
			imgui.OpenPopup('ban')
		end
		imgui.SameLine()
		if imgui.Button(u8'�������� � ������') then
			imgui.OpenPopup('jail')
		end
		imgui.SameLine()
		if imgui.Button(u8'������ ���') then
			imgui.OpenPopup('mute')
		end
		imgui.SameLine()
		if imgui.Button(u8'������� ������') then
			imgui.OpenPopup('kick')
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
		imgui.Tooltip('NumPad 6')
		imgui.SetCursorPosX(40)
		if imgui.Button(u8'�����') or (wasKeyPressed(VK_Q) and not (sampIsChatInputActive() or sampIsDialogActive())) then
			sampSendChat('/reoff')
		end
		imgui.Tooltip(u8'Q')
		imgui.SameLine()
		if imgui.Button(u8'��������') then
			sampSendChat('/slap ' .. control_player_recon)
		end
		imgui.SameLine()
		if imgui.Button(u8'����������')  then
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
		if imgui.Button(u8'�����������������')then
			lua_thread.create(function()
				sampSendChat('/reoff')
				wait(3000)
				sampSendChat('/agt ' .. control_player_recon)
			end)
		end
		imgui.SameLine()
		if (imgui.Button(u8'��������') or (wasKeyPressed(VK_R)) and not (sampIsChatInputActive() or sampIsDialogActive())) then
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
		if imgui.BeginPopup('mute') then
			imgui.CenterText(u8'�������� �������')
			for k,v in pairs(basic_command.mute) do
				local name = string.gsub(v, '/mute _ (%d+) ', '')
				if not string.sub(v, -3):find('x(%d+)')  then
					if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
						sampSendChat(string.gsub(v, '_', control_player_recon))
						array.windows.recon_mute_menu.v = false
						showCursor(false,false)
					end
				end
			end
			imgui.EndPopup()
		elseif imgui.BeginPopup('jail') then
			imgui.CenterText(u8'�������� �������')
			for k,v in pairs(basic_command.jail) do
				if not string.sub(v, -3):find('x(%d+)')  then
					local name = string.gsub(v, '/jail _ (%d+) ', '')
					if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
						sampSendChat(string.gsub(v, '_', control_player_recon))
						array.windows.recon_jail_menu.v = false
					end
				end
			end
			imgui.EndPopup()
		elseif imgui.BeginPopup('ban') then
			imgui.CenterText(u8'�������� �������')
			for k,v in pairs(basic_command.ban) do
				local name = string.gsub(string.gsub(string.gsub(v, '/ban _ (%d+) ', ''), '/siban _ (%d+) ', ''), '/iban _ (%d+) ', '')
				if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
					sampSendChat(string.gsub(v, '_', control_player_recon))
					array.windows.recon_ban_menu.v = false
				end
			end
			imgui.EndPopup()
		elseif imgui.BeginPopup('kick') then
			imgui.CenterText(u8'�������� �������')
			for k,v in pairs(basic_command.kick) do
				local name = string.gsub(v, '/kick _ ', '')
				if imgui.Button(u8(name), imgui.ImVec2(250, 25)) then
					sampSendChat(string.gsub(v, '_', control_player_recon))
					array.windows.recon_kick_menu.v = false
				end
			end
			imgui.EndPopup()
		end
		imgui.End()
	end
	if array.windows.custom_ans.v then -- ���� ����� � ������
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2((sw*0.5)+15, sh*0.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'��� �����', array.windows.custom_ans, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if wasKeyPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end
		if not array.windows.fast_report.v then array.windows.custom_ans.v = false end
		imgui.PushFont(fontsize)
		if imgui.RadioButton(u8"ID ������", array.checkbox.custom_ans, 0) then
			if not skin then
				skin = {}
				for i = 0, 311 do
					skin[#skin+1] = imgui.CreateTextureFromFile('moonloader\\'..'\\resource\\skin\\skin_'..i..'.png')
				end
			end
		end
		imgui.SameLine()
		if imgui.RadioButton(u8"ID ������", array.checkbox.custom_ans, 1) then
			if not html_color then
				html_color = {}
				local file_color = io.open('moonloader\\' .. "\\resource\\skin\\color.txt","r")
				if file_color then for line in file_color:lines() do html_color[#html_color + 1] = u8:decode(line);end file_color:close() end
			end
		end 
		imgui.SameLine()
		if imgui.RadioButton(u8"�������� ����", array.checkbox.custom_ans, 2) then
			if not array.auto then
				array.auto = {}
				for i = 400, 611 do
					array.auto[#array.auto+1] = imgui.CreateTextureFromFile('moonloader\\'..'\\resource\\auto\\vehicle_'..i..'.png')
				end
			end
		end
		imgui.Separator()
		if array.checkbox.custom_ans.v == 0 then
			imgui.CenterText(u8'��������� ���� ����� �������� � ������ ������.')
			for i = 1, 312 do
				imgui.Image(skin[i], imgui.ImVec2(75, 150))
				if imgui.IsItemClicked(0) then array.buffer.text_ans.v = array.buffer.text_ans.v .. ('ID: '..i-1) ..' ' end
				if i%9~=0 then imgui.SameLine() end
			end
		elseif array.checkbox.custom_ans.v == 1 then
			imgui.CenterText(u8'��������� ���� ����� �������� � ������ ������.')
			for i = 1, 256 do 
				imgui.TextColoredRGB(u8(html_color[i]))
				if imgui.IsItemClicked(0) then array.buffer.text_ans.v = array.buffer.text_ans.v .. string.sub(string.sub(html_color[i], 1, 7), 2) .. ' ' end 
				if i%7~=0 then imgui.SameLine() end 
			end
		elseif array.checkbox.custom_ans.v == 2 then
			imgui.CenterText(u8'��������� ��������� ����� �������� � ������ ������.')
			imgui.NewInputText('##SearchBar3', array.buffer.find_custom_answer, sw*0.5, u8'������ ����������', 2)			
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
	if array.windows.answer_player_report.v then -- ������ ����� ������ � ������
		imgui.SetNextWindowPos(imgui.ImVec2(sw-250, 0), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������ ����� ������ �� ������", array.windows.answer_player_report.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.CenterText(u8'�� ��������� ������ �� �������')
		imgui.CenterText(u8'�������� ����������?')
		if imgui.Button(u8'��������� �� �������� (1)', imgui.ImVec2(250, 25)) or (wasKeyPressed(VK_1) and not (sampIsChatInputActive() or sampIsDialogActive())) then
			sampProcessChatInput('/n ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		if imgui.Button(u8'������ ����� ���� (2)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_2) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/cl ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		if imgui.Button(u8'����� �������. (3)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_3) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/nak ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		if imgui.Button(u8'������� ���. (4)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_4) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/pmv ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		if imgui.Button(u8'����� AFK (5)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_5) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/afk ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		if imgui.Button(u8'����� �� � ���� (6)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_6) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/nv ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		if imgui.Button(u8'��� �����-������������ (7)', imgui.ImVec2(250,25)) or (wasKeyPressed(VK_7) and not (sampIsChatInputActive() or sampIsDialogActive()))  then
			sampProcessChatInput('/dpr ' .. copies_player_recon)
			copies_player_recon = nil
			array.windows.answer_player_report.v = false
		end
		if (wasKeyPressed(VK_RBUTTON) or wasKeyPressed(VK_F)) and not sampIsChatInputActive() then
			if isCursorActive() then showCursor(false,false)
			else showCursor(true,false) end
		end
		imgui.CenterText(u8'����� ������ �������, ���� ��������')
		imgui.CenterText(u8'��������� �������: ��� ��� F')
		imgui.CenterText(u8'���� ������� 5 ������.')
		if isGamePaused() then array.windows.answer_player_report.v = false end
		imgui.End()
	end
	if array.windows.render_admins.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.render_admins_positionX, cfg.settings.render_admins_positionY))
		imgui.Begin('##render_admins', array.windows.render_admins, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
		for i = 1, #array.admins - 1 do imgui.TextColoredRGB(array.admins[i]) end
        imgui.End()
	end
	if array.windows.new_flood_mess.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(265,340), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'����� ����', array.windows.new_flood_mess, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Button(u8'������ ��� ������� /mess\n��� ���� ���� ������� ����.', imgui.ImVec2(250,32)) then sampAddChatMessage(tag .. '������ ������ � �������',-1) sampSendChat('/mcolors') end
		imgui.Text(u8'��������: ')
		imgui.PushItemWidth(250)
		imgui.InputText('##title_flood_mess', array.buffer.title_flood_mess)
		imgui.PopItemWidth()
		imgui.Text(u8'�����: ')
		imgui.InputTextMultiline("##5", array.buffer.new_flood_mess, imgui.ImVec2(250, 100))
		if imgui.Button(u8'���������', imgui.ImVec2(250, 24)) then
			if #(u8:decode(array.buffer.new_flood_mess.v)) > 3 and #(u8:decode(array.buffer.title_flood_mess.v)) ~= 0 then
				if array.buffer.new_flood_mess.v ~= 0 then
					if tonumber(string.sub(array.buffer.new_flood_mess.v, 1, 1)) then
						cfg.myflood[u8:decode(array.buffer.title_flood_mess.v)] = string.gsub(u8:decode(array.buffer.new_flood_mess.v), '\n', '\\n')
						save()
						array.buffer.title_flood_mess.v = ''
						array.buffer.new_flood_mess.v = ''
					else sampAddChatMessage(tag .. '���� �� ������', -1) end
				else sampAddChatMessage(tag .. '�� �� ������� ����� �����', -1) end
			else sampAddChatMessage(tag .. '��� �� ��������� ���������?', -1) end
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
		imgui.End()
	end
	if array.windows.pravila.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5,0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw*0.5,sh*0.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'������', array.windows.pravila, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.RadioButton(u8"�������", array.checkbox.checked_radio_button, 1)
		imgui.SameLine()
		imgui.RadioButton(u8"������� �������", array.checkbox.checked_radio_button, 2)
		imgui.SameLine()
		imgui.RadioButton(u8"��������� �������", array.checkbox.checked_radio_button, 3)
		if wasKeyPressed(VK_SPACE) then imgui.SetKeyboardFocusHere(-1) end
		if array.checkbox.checked_radio_button.v == 1 then
			imgui.NewInputText('##SearchBar6', array.buffer.find_rules, sw*0.5, u8'����� �� ��������', 2)
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
				prochee = '������� ��� ������ �� ��������',
				help = '��������������� �������',
				ans = '������ �������',
				mute = '������ ���������� ����',
				rmute = '������ ���������� �������',
				jail = '������ ���������',
				ban = '���������� ��������',
				kick = '������� ������',
			}
			if imgui.CollapsingHeader( u8('��� �������') ) then
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
		elseif array.checkbox.checked_radio_button.v == 3 then
			for i = 1, 18 do
				if imgui.CollapsingHeader(u8('������� ������� - ' .. i)) then
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
	if array.windows.menu_chatlogger.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.5), (sh * 0.5)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw*0.7, sh*0.8), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'����������� ����', array.windows.menu_chatlogger, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		if imgui.IsWindowAppearing() then chat = {1, 500, 1} end -- 1 �������� ������ �������, 2 �������� - ����� �������, 3 - ��������.
		imgui.PushFont(fontsize)
		imgui.CenterText(u8'�������� ���� ��� ���������')
		imgui.Text(u8'����������: ������� �� ������ - �������� ��� � ����� ������.\n�������� ������� ���� ����� ������������ ����� ���������������.\n� ����� ���������� �������� �� ��� ���������, ������ ���� ����������� ������ ��������� � ����.')
		if imgui.Checkbox('##cl', array.checkbox.check_on_chatlog) then
			cfg.settings.chat_log = not cfg.settings.chat_log
			save()
		end
		imgui.SameLine()
		if array.checkbox.check_on_chatlog.v then imgui.Text(u8'���������� ��� ���� � ��������� � ������')
		else imgui.Text(u8'�� ���������� ��� ���� ��� ����������� ���������.') end
		imgui.PushItemWidth(sw*0.7 - 30)
		if imgui.Combo('##chatlog', array.checkbox.option_find_log, array.files_chatlogs, array.checkbox.option_find_log) then chat = {1, 500, 1} end
		imgui.NewInputText('##searchlog', array.buffer.find_log, (sw*0.7)-30, u8'���������� ������', 2)
		imgui.PopItemWidth()
		if array.checkbox.option_find_log.v == 0 then 	--= ���������, ��� ����������, ����������� �� ����'
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
					if imgui.Button(u8'<- ���������� ��������'..' ('..(chat[3] - 1)..')') then
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
				if imgui.Button(u8'��������� �������� ' .. '('..chat[3].. ') ->') then
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
			for i = chat[1], chat[2] do
				if string.rlower(array.chatlog_1[i]):find(string.rlower(u8:decode(array.buffer.find_log.v))) then
					imgui.Text(u8(array.chatlog_1[i]))
					if imgui.IsItemClicked(0) then setClipboardText(array.chatlog_1[i]) sampAddChatMessage(tag..'������ ����������� � ������ ������',-1) end
				end
			end
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
					if imgui.Button(u8'<- ���������� ��������'..' ('..(chat[3] - 1)..')') then
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
				if imgui.Button(u8'��������� �������� ' .. '('..chat[3].. ') ->') then
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
			for i = chat[1], chat[2] do
				if string.rlower(array.chatlog_2[i]):find(string.rlower(u8:decode(array.buffer.find_log.v))) then
					imgui.Text(u8(array.chatlog_2[i]))
					if imgui.IsItemClicked(0) then setClipboardText(array.chatlog_2[i]) sampAddChatMessage(tag..'������ ����������� � ������ ������',-1) end
				end
			end
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
					if imgui.Button(u8'<- ���������� ��������'..' ('..(chat[3] - 1)..')') then
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
				if imgui.Button(u8'��������� �������� ' .. '('..chat[3].. ') ->') then
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
			for i = chat[1], chat[2] do
				if string.rlower(array.chatlog_3[i]):find(string.rlower(u8:decode(array.buffer.find_log.v))) then
					imgui.Text(u8(array.chatlog_3[i]))
					if imgui.IsItemClicked(0) then setClipboardText(array.chatlog_3[i]) sampAddChatMessage(tag..'������ ����������� � ������ ������',-1) end
				end
			end
		end
		imgui.PopFont()
		imgui.End()
	end
end
function sampev.onSendCommand(command) -- ����������� ������������ �����-���������
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
end
function sampev.onServerMessage(color,text) -- ����� ��������� �� ����
	if cfg.settings.render_admins and (text:match('����� ������������������� �� �������:') or text:match('���� ���������:') or text:match('����� ������������� � ����:')) then
		return false
	elseif text:match("(.+)%((%d+)%) ������� �������� � ���: ") then
		sampAddChatMessage('',-1)
		sampAddChatMessage(text, 0xff6347) -- ����� �� ���������� ����� ���������
		sampAddChatMessage('',-1)
		return false
	elseif text:match('%[A%] NEARBY CHAT: .+') or text:match('%[A%] SMS: .+') then
		array.checkbox.check_render_ears.v = true
		local text = string.gsub(text, 'NEARBY CHAT:', '{87CEEB}AT-NEAR:{FFFFFF}')
		local text = string.gsub(text, 'SMS:', '{4682B4}AT-SMS:{FFFFFF}')
		local text = string.gsub(text, ' �������� ', '')
		local text = string.gsub(text, ' ������ ', '->')
		local text = string.sub(text, 5) -- ������� [A]
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
					while true do -- ���� ���� �� ����� �������
						array.admin_form = {}
						local find_admin_form = string.gsub(text, '%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: {(.+)}', '')
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
								break
							else
								array.admin_form = {}
								sampAddChatMessage(tag .. 'ID �� ���������, ���� ��������� ��� ����.', -1)
								break
							end
						else break end
					end
				end
			end
		end
		if cfg.settings.admin_chat then
			local admlvl, prefix, nickadm, idadm, admtext  = text:match('%[A%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]: (.+)')
			local messange = (string.sub(prefix, 2) .. ' ' .. admlvl .. ' ' ..  nickadm .. '(' .. idadm .. '): '.. admtext)
			if #array.adminchat == cfg.settings.strok_admin_chat then
				for i = 0, #array.adminchat do
					if i ~= #array.adminchat then array.adminchat[i] = array.adminchat[i+1]
					else array.adminchat[#array.adminchat] = messange end
				end
			else array.adminchat[#array.adminchat + 1] = messange end
			return false
		end
	elseif not AFK then
		log(text)
		if cfg.settings.automute and (text:match("%((%d+)%): (.+)") or text:match("%[(%d+)%]: (.+)")) 			and not (text:match("%[a%-(%d+)%] (%(.+)%) (.+)%[(%d+)%]:") or text:match('������� %[(%d+)%]:') or text:match('������� (.+)%[(%d+)%]: ')) then
			local command = '/mute '
			if text:match('������') then
				command = '/rmute '
			end
			local text = text:rlower() .. ' '
			if text:match('%((%d+)%)') then oskid = text:match('%((%d+)%)') text = string.gsub(text, ".+%((%d+)%):",'')
			else oskid = text:match('%[(%d+)%]') text = string.gsub(text, ".+%[(%d+)%]:", '') end
			local text = string.gsub(text, '{%w%w%w%w%w%w}', '')
			if cfg.settings.smart_automute then
				for i = 1, #array.spisokoskrod do
					if text:match(' '.. array.spisokoskrod[i]) then
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[�T]{DCDCDC} '..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[��]', -1)
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampSendChat(command .. oskid .. ' 5000 �����������/���������� ������')
						notify('{66CDAA}[AT-AutoMute]', '������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '���������� ������.')
						return false
					end
				end
				for i = 1, #array.spisokrz do
					if text:match(' '..array.spisokrz[i]) then
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[��]', -1)
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampSendChat(command .. oskid .. ' 5000 ������ ������.�����')
						notify('{66CDAA}[AT-AutoMute]', '������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '������ ������.�����')
						return false
					end
				end
				for i = 1, #array.spisokproject do
					if text:match(' ' .. array.spisokproject[i]) then
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage('{00FF00}[�T]{DCDCDC} '..sampGetPlayerNickname(oskid) .. '['..oskid..']: ' .. text .. ' {00FF00}[��]', -1)
						sampAddChatMessage('==========================================================================', 0x00FF00)
						sampAddChatMessage(tag .. '������������� ���������� ������� ���� /cc', -1)
						sampSendChat(command ..oskid.. ' 1000 ���������� ����.��������')
						notify('{66CDAA}[AT-AutoMute]', '������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. array.spisokproject[i])
						return false
					end
				end
			end
			for i = 1, #array.osk do	-- ������ ���������� � 1
				if not text:match(' � ') and text:match('%s'.. array.osk[i]) then
					for a = 1, #array.spisokor do
						if text:match(array.spisokor[a]) then
							sampAddChatMessage('==========================================================================', 0x00FF00)
							sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[��]', -1)
							sampAddChatMessage('==========================================================================', 0x00FF00)
							sampSendChat(command .. oskid .. ' 5000 �����������/���������� �����')
							notify('{66CDAA}[AT-AutoMute]', '������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. array.osk[i] .. ' - ' .. array.spisokor[a])
							return false
						end
					end
					sampAddChatMessage('==========================================================================', 0x00FF00)
					sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[��]', -1)
					sampAddChatMessage('==========================================================================', 0x00FF00)
					sampSendChat(command .. oskid .. ' 400 �����������/��������')
					notify('{66CDAA}[AT-AutoMute]', '������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. array.osk[i])
					return false
				end
			end
			for i = 1, #array.mat do -- ������ ���������� � 1
				if text:match(' '.. array.mat[i]) then
					for a = 1, #array.spisokor do
						if text:match(array.spisokor[a]) then
							sampAddChatMessage('==========================================================================', 0x00FF00)
							sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[��]', -1)
							sampAddChatMessage('==========================================================================', 0x00FF00)
							sampSendChat(command .. oskid .. ' 5000 �����������/���������� �����')
							notify('{66CDAA}[AT-AutoMute]', '������� ����������:\n' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. array.mat[i] .. ' - ' .. array.spisokor[a])
							return false
						end
					end
					sampAddChatMessage('==========================================================================', 0x00FF00)
					sampAddChatMessage('{00FF00}[�T]{DCDCDC} ' ..sampGetPlayerNickname(oskid) .. '['..oskid..']: '.. text .. ' {00FF00}[��]', -1)
					sampAddChatMessage('==========================================================================', 0x00FF00)
					sampSendChat(command .. oskid .. ' 300 ����������� �������')
					notify('{66CDAA}[AT-AutoMute]', '' .. sampGetPlayerNickname(oskid) .. '[' .. oskid .. ']\n' .. '�������� �����: ' .. array.mat[i])				
					return false
				end
			end
			if array.flood.message[oskid] then
				if ( array.flood.message[oskid] ~= text ) or  ( (os.clock() - array.flood.time[oskid]) > 40 ) then 
					array.flood.message[oskid] = text
					array.flood.time[oskid] = os.clock()
					array.flood.count[oskid] = 1
				else
					if array.flood.count[oskid] == 3 and cfg.settings.smart_automute then -- ���� 4 ��������� �� ���
						array.flood.message[oskid] = nil
						lua_thread.create(function()
							while sampIsDialogActive() do wait(1000) end
							sampAddChatMessage(tag .. '��������� ���� � ����! ���������� ' .. sampGetPlayerNickname(oskid)..'['..oskid..']', -1)
							sampAddChatMessage(tag .. '�������� 4 ��������� �� ' .. math.ceil(os.clock() - array.flood.time[oskid]) .. '/40 ���.', 0xA9A9A9)
							sampAddChatMessage('{CD853F}Flood {ffffff}- '..sampGetPlayerNickname(oskid)..'['..oskid..']: '..text, -1)
							sampSendChat('/mute ' .. oskid .. ' 120 ����/C���')
						end)
					else array.flood.count[oskid] = array.flood.count[oskid] + 1 end
				end
			else
				array.flood.message[oskid] = text
				array.flood.time[oskid] = os.clock()
				array.flood.count[oskid] = 1
			end
		elseif text:match('%<AC%-WARNING%> {ffffff}(.+)%[(%d+)%]{82b76b} ������������� � ������������� ���%-��������%: {ffffff}Weapon hack %[code%: 015%]%.') and cfg.settings.weapon_hack then
			if not sampIsDialogActive() then 
				sampSendChat('/iwep '.. string.match(text, "%[(%d+)%]"))
			end
			return false
		end
	end
end
function sampev.onShowTextDraw(id, data) -- ��������� ��������� ����������
	if cfg.settings.on_custom_recon_menu then
		for k,v in pairs(data) do
			local v = tostring(v)
			if v == 'REFRESH' then 
				lua_thread.create(function()
					wait(0) -- ���� ����� �������� ����������
					array.textdraw.refresh = id  -- ���������� �� ������ �������� � ������
					sampTextdrawSetStyle(array.textdraw.refresh, -1)
				end)
			elseif v:match('~n~') then
				if not v:match('~g~') then
					array.textdraw.inforeport = id  -- ���� ������ � ������
					lua_thread.create(function()
						wait(0) -- ���� ����� �������� ����������
						sampTextdrawSetStyle(array.textdraw.inforeport, -1) -- ���������� � ��������� �����
						while not array.windows.recon_menu.v do wait(100) end
						while array.windows.recon_menu.v do
							array.inforeport = textSplit(sampTextdrawGetString(array.textdraw.inforeport), "~n~") -- ���������� � ������, ���������� � �����������
							if array.inforeport[3] ==   '-1'   then array.inforeport[3] = '-' end  --========= �� ����
							if array.inforeport[6] == '0 : 0 ' then array.inforeport[6] = '-' end  --====== ������
							--=========== �������� ��� =======--------
							if     array.inforeport[11] == '0' then array.inforeport[11] = '-'
							elseif array.inforeport[11] == '1' then array.inforeport[11] = 'Standart'
							elseif array.inforeport[11] == '2' then array.inforeport[11] = 'Premium'
							elseif array.inforeport[11] == '3' then array.inforeport[11] = 'Diamond'
							elseif array.inforeport[11] == '4' then array.inforeport[11] = 'Platinum'
							elseif array.inforeport[11] == '5' then array.inforeport[11] = 'Personal' end
							--=========== �������� ��� =======--------
							wait(1000)
						end
					end)
				else return false end
			elseif v:match('(.+)%((%d+)%)') then
				array.textdraw.name_report = id
				control_player_recon = tonumber(string.match(v, '%((%d+)%)')) -- ��� ������ � ������
				array.windows.recon_menu.v = true
				array.windows.menu_in_recon.v = true
				imgui.Process = true
				return false
			elseif v == 'STATS' then 
				array.textdraw.stats = id
				lua_thread.create(function()
					wait(1) -- ���� ����� �������� ���������� 
					sampTextdrawSetStyle(array.textdraw.stats, -1)
					if cfg.settings.keysync then keysync(control_player_recon) end
				end)
			elseif v == 'CLOSE' then return false
			elseif v == 'BAN' then return false
			elseif v == 'MUTE' then return false
			elseif v == 'KICK' then return false
			elseif v == 'JAIL' then return false end
		end
		------=========== ������� ������ ����������, ��������� �� � �������� =======---------------
		for i = 0, #array.textdraw_delete do if id == array.textdraw_delete[i] then return false end end
	end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text) -- ������ � ��������� ���������
	if title == '{ff8587}������������� ������� (������)' and cfg.settings.render_admins then
		sampSendDialogResponse(dialogId, 1, 0)
		lua_thread.create(function()
			array.admins = textSplit(text, '\n')
			local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			for i = 1, #array.admins - 1 do -- {FFFFFF}N.E.O.N(0) ({2E8B57}��.�������������{FFFFFF}) | �������: {ff8587}6{FFFFFF} | ��������: {ff8587}0 �� 3{FFFFFF} | ���������: {ff8587}
				local rang = string.sub(string.gsub(string.match(array.admins[i], '(%(.+)%)'), '(%(%d+)%)', ''), 3) --{FFFFFF}N.E.O.N(0) | �������: {ff8587}18{FFFFFF} | ��������: {ff8587}0 �� 3{FFFFFF} | ���������: {ff8587}60
				array.admins[i] = string.gsub(array.admins[i], '{%w%w%w%w%w%w}', "")
				local afk = string.match(array.admins[i], 'AFK: (.+)')
				local name, id, _, lvl, _, _ = string.match(array.admins[i], '(.+)%((%d+)%) %((.+)%) | �������: (%d+) | ��������: (%d+) �� 3 | ���������: (.+)')
				array.admins[i] = string.gsub(array.admins[i], '���������: (.+)', "")
				if #rang > 2 then
					if afk then array.admins[i] = name .. '(' .. id .. ') ' .. rang .. ' ' .. lvl .. ' AFK: ' .. afk
					else array.admins[i] = name .. '(' .. id .. ') ' .. rang .. ' '.. lvl end
				else
					_, id, lvl = string.match(array.admins[i], '(.+)%((%d+)%) | �������: (%d+)')
					rang = '�����������'
				end
				if cfg.settings.autoprefix then
					local lvl, rang, id = tonumber(lvl), string.gsub(rang, '{%w%w%w%w%w%w}', ''), tonumber(id)
					if id ~= myid and autoprefix_access then
						if (lvl > 0 and lvl < 10) and rang ~= '��.�������������' then
							wait(1000)
							sampAddChatMessage(tag .. '� �������������� ' .. sampGetPlayerNickname(id) .. ' ��������� �������� �������.', -1)
							sampAddChatMessage(tag .. '��������� ������: ' .. rang .. ' -> {' .. cfg.settings.prefixma .. '}��.�������������', -1)
							sampSendChat('/prefix ' .. id .. ' ��.������������� ' .. cfg.settings.prefixma)
							wait(3000)
							sampSendChat('/admins')
							notify('{FF6347}[AT] �������������� ������ ��������', '������������� '..sampGetPlayerNickname(id)..'['..id ..']\n��� ���������� ����� �������.\n' .. rang .. '-> ��.�������������.')
						elseif (lvl > 11 and lvl < 15) and rang ~= '�������������' then
							wait(1000)
							sampAddChatMessage(tag .. '� �������������� ' .. sampGetPlayerNickname(id) .. ' ��������� �������� �������.', -1)
							sampAddChatMessage(tag .. '��������� ������: ' .. rang .. ' -> {' ..cfg.settings.prefixa..'}�������������', -1)
							sampSendChat('/prefix ' .. id .. ' ������������� ' .. cfg.settings.prefixa)
							wait(3000)
							sampSendChat('/admins')
							notify('{FF6347}[AT] �������������� ������ ��������', '������������� '..sampGetPlayerNickname(id)..'['..id ..']\n��� ���������� ����� �������.\n' .. rang .. '-> �������������.')
						elseif (lvl > 16 and lvl < 18) and rang ~= '��.�������������' then
							wait(1000)
							sampAddChatMessage(tag .. '� �������������� ' .. sampGetPlayerNickname(id) .. ' ��������� �������� �������.', -1)
							sampAddChatMessage(tag .. '��������� ������: ' .. rang .. ' -> {' .. cfg.settings.prefixsa..'}��.�������������', -1)
							sampSendChat('/prefix ' .. id .. ' ��.������������� ' .. cfg.settings.prefixsa)
							wait(3000)
							sampSendChat('/admins')
							notify('{FF6347}[AT] �������������� ������ ��������', '������������� '..sampGetPlayerNickname(id)..'['..id ..']\n��� ���������� ����� �������.\n' .. rang .. '-> ��.�������������.')
						end
					elseif lvl == 18 and rang ~= '��.�������������' then
						autoprefix_access = true
						print('�� �� ������������ �������!')
					end
				end
			end
		end)
		return false
	elseif dialogId == 1098 then -- ����������
		sampSendDialogResponse(dialogId, 1, math.floor(sampGetPlayerCount(false) / 10) - 1)
		return false
	elseif cfg.settings.weapon_hack and button1 == '������' and button2 ~= '�������' then
		lua_thread.create(function()
			local text = textSplit(text, '\n')
			for i = 1, #text - 1 do
				local _,weapon, patron = text[i]:match('(%d+)	Weapon: (%d+)     Ammo: (.+)')
				if (text[i]:find('-')) or (weapon == '0' and patron ~= '0') then
					sampAddChatMessage(tag .. '����������� ����� - ' .. title..'['..sampGetPlayerIdByNickname(title)..']',-1)
					sampAddChatMessage(tag .. '������ (ID): ' .. weapon..'. �������: '..patron, -1)
					notify('{66CDAA}[AT] ����-���', '������ (ID): ' .. weapon..'\n�������: '..patron)
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
				while sampIsDialogActive() do wait(0) end
				player_cheater = nil
				sampSendChat('/iban '..sampGetPlayerIdByNickname(title)..' 7 ��� �� ������')
				notify('{66CDAA}[AT] ����-���', '�������� /iwep ����� ����� �\n���������� ���� - ���������')
			else sampAddChatMessage(tag .. '������ ������ ' .. title .. '[' .. sampGetPlayerIdByNickname(title) .. ']. �� ����������� �������� ����� �� ����������.', -1) end
		end)
	elseif title == 'Mobile' and control_player_recon then -- �������� � ���� �� �����
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
			sampAddChatMessage(tag .. '����������� ������������ - ' .. player, -1)
			if isTrigger then sampAddChatMessage(tag .. '���������� ������� ����� - ��������� ����������.', -1)
			else sampAddChatMessage(tag .. '���������� ������� ����� - ������������ ���������', -1) end
			wait(0)
			sampCloseCurrentDialogWithButton(0)
		end)
	elseif title == 'Get Offline Stats' then -- ���� /offstats ��� ����� ����� ����������� � ���� ������������ ��� /sbanip
		if find_ip_player then sampSendDialogResponse(dialogId, 1, 0) return false end
		if regip then lua_thread.create(function() wait(0) sampCloseCurrentDialogWithButton(0) end) end
	elseif button1 == '�������' and find_ip_player then -- ���� /offstats ������������ ��� /sbanip
		sampSendDialogResponse(dialogId,1,0)
		for k,v in pairs(textSplit(text, '\n')) do
			if k == 12 then 
				regip = string.sub(v, 17) 
			elseif k == 13 then 
				lastip = string.sub(v, 18) 
			end 
		end
		find_ip_player = false
		return false
	elseif dialogId == 2348 and array.windows.fast_report.v then array.windows.fast_report.v = false
	elseif dialogId == 2349 then -- ���� � ����� ��������.
		array.answer, array.windows.answer_player_report.v, peremrep, myid, reportid = {}, false, nil, nil, nil
		local text = textSplit(text, '\n')
		text[1] = string.gsub(string.gsub(text[1], '{.+}', ''), '�����: ', '')
		text[4] = string.gsub(string.gsub(text[4], '{.+}', ''), '������: ', '')
		autor = text[1]																			--1
		if sampGetPlayerIdByNickname(autor) then autorid = sampGetPlayerIdByNickname(autor)		--1
		else autorid = '�� � ����' end 
		textreport = text[4]																	--4
		reportid = tonumber(string.match(string.gsub(textreport, '%,',' ')--[[���� �������, ��-�� ��� �� ����� ID]], '%d[%d.,]*')) --4
		if not sampIsPlayerConnected(reportid) then 											--4
			_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED) 									--4
		end																			--4
		lua_thread.create(function()
			if cfg.settings.on_custom_answer then 
				array.windows.fast_report.v,imgui.Process=true,true
				wait(500)
				array.answer = {}
				while array.windows.fast_report.v and not (array.answer.rabotay or array.answer.uto4 or array.answer.nakajy or array.answer.customans or array.answer.slejy or array.answer.jb or array.answer.ojid or array.answer.moiotvet or array.answer.uto4id or array.answer.nakazan or array.answer.otklon or array.answer.peredamrep) do wait(100) end
				sampSendDialogResponse(dialogId,1,0)
			end
		end)
	elseif dialogId == 2350 then -- ���� � ������������ ������� ��� ��������� ������
		array.windows.fast_report.v = false
		if not peremrep then
			if array.answer.rabotay then peremrep = ('�����(�) ������ �� ����� ������!')
			elseif array.answer.slejy then
				if not reportid then peremrep = ('����������� � ������') array.answer.slejy = nil
				elseif reportid and reportid ~= myid then
					if not sampIsPlayerConnected(reportid) then
						if reportid < 300 then
							peremrep = ('��������� ���� ����� ��� ' .. reportid .. ' ID ��������� ��� ����.') 
							array.answer.slejy = nil
						else peremrep = ('����������� � ������') end
					else peremrep = ('����������� � ������ �� ������� ' .. sampGetPlayerNickname(reportid) .. '['..reportid..']') end
				elseif myid then if reportid == myid then peremrep = ('�� ������� ��� ID (^_^)') array.answer.slejy = nil end end
			elseif array.answer.nakazan then peremrep = ('������ ����� ��� ��� �������.')
			elseif array.answer.uto4id then peremrep = ('�������� ID ���������� � /report.')
			elseif array.answer.nakajy then peremrep = ('������ �������� �� ��������� ������ /report')  
			elseif array.answer.jb then peremrep = ('�������� ������ �� forumrds.ru')
			elseif array.answer.peredamrep then peremrep = ('������� ��� ������.')
			elseif array.answer.rabotay then peremrep = ('�����(�) ������ �� ����� ������.')
			elseif array.answer.customans then peremrep = array.answer.customans
			elseif array.answer.uto4 then peremrep = ('���������� � ������ ��������� �� ����� https://forumrds.ru')
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
				return false
			end
		end
		if peremrep then
			if #(peremrep) > 80 then
				sampAddChatMessage(tag .. '��� ����� �������� ������� �������, ���������� ��������� �����.',-1) 
				peremrep = nil
				lua_thread.create(function()
					wait(0)
					sampCloseCurrentDialogWithButton(0)
				end)
			else
				if cfg.settings.on_color_report and (#peremrep + 6) < 80 then
					if cfg.settings.color_report == '*' then peremrep = ('{'..color()..'}' .. peremrep)
					else peremrep = (cfg.settings.color_report .. peremrep) end
				end
				if cfg.settings.add_answer_report and (#peremrep + #(cfg.settings.mytextreport)) < 80 then peremrep = (peremrep ..('{'..color()..'} '..cfg.settings.mytextreport)) end
				if #(peremrep) < 4 then peremrep = peremrep .. '    ' end
				if cfg.settings.custom_answer_save and array.answer.moiotvet then cfg.customotvet[ #cfg.customotvet + 1 ] = u8:decode(array.buffer.text_ans.v) save() end	
				sampSendDialogResponse(dialogId, 1, 0)
				sampCloseCurrentDialogWithButton(0)
				array.buffer.text_ans.v = ''
				return false
			end
		end
	elseif dialogId == 2351 and peremrep then -- ���� � ������� �� ������
		sampSendDialogResponse(dialogId, 1, 1, peremrep)
		lua_thread.create(function()
			while sampIsDialogActive() do wait(1) end
			if array.answer.control_player then sampSendChat('/re ' .. autorid)
			elseif array.answer.slejy then sampSendChat('/re ' .. reportid)
			elseif array.answer.peredamrep then sampSendChat('/a ' .. autor .. '[' .. autorid .. '] | ' .. textreport)
			elseif array.answer.nakajy then
				if not autorid then autorid = autor command = '/rmuteoff '
				else command = '/rmute ' end
				if array.nakazatreport.oftop then       sampSendChat(command  .. autorid .. ' 120 ������ � /report')
				elseif array.nakazatreport.oskadm then  sampSendChat(command  .. autorid .. ' 2500 ����������� �������������')
				elseif array.nakazatreport.oskrep then  sampSendChat(command  .. autorid .. ' 400 �����������/��������')
				elseif array.nakazatreport.poprep then  sampSendChat(command  .. autorid .. ' 120 ����������������')
				elseif array.nakazatreport.oskrod then  sampSendChat(command  .. autorid .. ' 5000 �����������/���������� �����')
				elseif array.nakazatreport.capsrep then sampSendChat(command  .. autorid .. ' 120 ���� � /report')
				elseif array.nakazatreport.matrep then  sampSendChat(command  .. autorid .. ' 300 ����������� �������')
				elseif array.nakazatreport.rozjig then  sampSendChat(command  .. autorid .. ' 5000 ������')
				elseif array.nakazatreport.kl then      sampSendChat(command  .. autorid .. ' 3000 �������') end
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
						else sampAddChatMessage(tag .. '�����, ���������� ������, ��������� ��� ����.', -1) end
					end
				else copies_player_recon = nil end
			end
		end)
		return false
	end
end

function sampev.onDisplayGameText(style, time, text) -- �������� ����� �� ������.
	if text == ('~w~RECON ~r~OFF') or text == ('~w~RECON ~r~OFF~n~~r~PLAYER DISCONNECT') then 
		array.windows.recon_menu.v = false 
		array.windows.menu_in_recon.v = false
		return false
	elseif text == ('~y~REPORT++') then
		if not AFK then
			if atr and not sampIsDialogActive() then sampSendChat("/ans") sampSendDialogResponse(2348, 1, 0) end
			if cfg.settings.notify_report then printStyledString('~n~~p~REPORT ++', 700, 4) end
		end
		return false
	end
end

function log(text) -- ���������� ���
	if cfg.settings.chat_log then
		local data_today = os.date("*t") -- ������ ���� �������
		local log = ('moonloader\\config\\chatlog\\chatlog '.. data_today.day..'.'..data_today.month..'.'..data_today.year..'.txt')
		local file = io.open(log,"a")
		if file then file:write('['..data_today.hour..':'..data_today.min ..':'..data_today.sec..'] ' .. encrypt(text, 3)..'\n') file:close() end
	end
end

function render_admins()
	wait(5000)
	while true do
		while sampIsDialogActive() do wait(500) end
		wait(300)
		if not AFK then sampSendChat('/admins') end
		wait(30000)
	end
end

function autoonline() 
	while true do
		wait(63000) 
		while sampIsDialogActive() do wait(500) end
		if not AFK then sampSendChat("/online") end 
	end 
end

function update(param)
	local dlstatus = require('moonloader').download_status
	if param == 'fs' or param == 'all' then
		sampAddChatMessage(tag .. '��������, ������� ������� ����������.', -1)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_FastSpawn.lua", 'moonloader//resource//AT_FastSpawn.lua', function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. '������ ������� ���������� ������ �������� ������',-1)
			end  
		end)
	end 
	if param == 'mp' or param == 'all' then
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_MP.lua", 'moonloader//resource//AT_MP.lua', function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. '������ ������� ���������� ������ ������ �����������',-1)
			end 
		end)
	end
	if param == 'main' or param == 'all' then
		sampAddChatMessage(tag .. '��������, ������� ������� ����������.', -1)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/my_lib.lua", 'moonloader//lib//my_lib.lua', function(id, status) end)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/rules.txt", 'moonloader//config//AT//rules.txt', function(id, status)  end)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_Trassera.lua", 'moonloader//resource//AT_Trassera.lua', function(id, status) end)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/control_work_AT.lua", 'moonloader//control_work_AT.lua', function(id, status) end)
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminTools.lua", thisScript().path, function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. '������ ������� ���������� ������ ��',-1)
			end 
		end)
	end
	lua_thread.create(function()
		wait(10000)
		reloadScripts()
	end)
end

function onWindowMessage(msg, wparam, lparam) -- ���������� ALT + Enter
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
		local fonts = renderCreateFont('TimesNewRoman', 12, 5) -- ����� ��� ��������
		while true do
			wait(2)
			if array.admin_form.bool and array.admin_form.timer and array.admin_form.sett then
				timer = os.clock() - array.admin_form.timer
				renderFontDrawText(fonts, '{FFFFFF}���������� ����� �� ��������������.\n����� U, ����� ������� ��� J - ����� ���������\n������� �� �������� 5 ���, ������: '..tostring(os.date("!*t", timer).sec), sw/2, sh/2, 0xFFFFFFFF)
				if timer>5 then break end
			end
			if not (sampIsChatInputActive() or sampIsDialogActive()) then
				if wasKeyPressed(VK_U) or cfg.settings.autoaccept_form then
					if sampIsPlayerConnected(array.admin_form.idadmin) then
						if not (array.admin_form.forma):match('kick') and not (array.admin_form.forma):match('off') and not (array.admin_form.forma):match('akk') then
							local _, id, sec, prichina = (array.admin_form.forma):match('(.+) (.+) (.+) (.+)')
							if not (tonumber(id) or tonumber(sec) or prichina) then
								sampSendChat('/a �� - ��������.')
								break
							end
						end
						if array.admin_form.probid and not sampIsPlayerConnected(array.admin_form.probid) then
							sampAddChatMessage(tag .. '��������� ����� �� � ����', -1)
							break
						end
						if not array.admin_form.styleform then sampSendChat(array.admin_form.forma .. ' // ' .. sampGetPlayerNickname(array.admin_form.idadmin))
						else sampSendChat(array.admin_form.forma) end
						wait(1000)
						sampSendChat('/a AT - �������.')
					else sampAddChatMessage(tag .. '������������� �� � ����.', -1) end
					break
				end
				if wasKeyPressed(VK_J) then
					sampAddChatMessage(tag .. '����� ���������', -1)
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
			if wasKeyPressed(strToIdKeys(cfg.settings.open_tool)) then  -- ������ ��������� ����
				array.windows.menu_tools.v = not array.windows.menu_tools.v
				imgui.Process = true
				if array.windows.recon_menu.v then 	-- ��������� ������� ���� ����� ���� �������
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
			if not AFK and cfg.settings.control_afk then
				lua_thread.create(function()

					mem.write(0x747FB6, 0x1, 1, true) -- ������� � ���
					mem.write(0x74805A, 0x1, 1, true)
					mem.fill(0x74542B, 0x90, 8, true)
					mem.fill(0x53EA88, 0x90, 6, true)

					local memset = function(addr, arr)
						for i = 1, #arr do
							mem.write(addr + i - 1, arr[i], 1, true)
						end
					end

					for i = 0, (cfg.settings.control_afk*10) do
						wait(6000)
						if not AFK then
							mem.write(0x747FB6, 0x0, 1, true) -- ������� �� ���
							mem.write(0x74805A, 0x0, 1, true)
							memset(0x74542B, { 0x50, 0x51, 0xFF, 0x15, 0x00, 0x83, 0x85, 0x00 })
							memset(0x53EA88, { 0x0F, 0x84, 0x7B, 0x01, 0x00, 0x00 })
							break
						elseif i == (cfg.settings.control_afk*10) then ffi.C.ExitProcess(0)--[[game over]] end
					end
				end)
			end
			AFK = true
		else AFK = false end
	end
end
--============= Wallhack ==============--

function wallhack()
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

function on_wallhack() -- ��������� WallHack (��������)
	local pStSet = sampGetServerSettingsPtr();
	local NTdist = mem.getfloat(pStSet + 39)
	local NTwalls = mem.getint8(pStSet + 47)
	local NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 900.0) -- ��������� ���������� 900 ������
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
end
function off_wallhack() -- ���������� WallHack (��������)
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, 30)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
end

---============ ����������� ������ ������ ================-----
function start_my_answer()
	if start_download then sampAddChatMessage('������� �������� ��� ���.', -1)
	else
		if not file_exists('moonloader\\'..'\\resource\\skin\\skin_311.png') or not file_exists('moonloader\\'..'\\resource\\auto\\vehicle_611.png') then
			start_download = true
			sampAddChatMessage(tag .. '����� ��������� ������� ��� �� ���������. ����� ��� �� �������� �� ������ � ����� ��������.', -1)
			lua_thread.create(function()
				while array.windows.fast_report.v do wait(1000) end
				sampAddChatMessage(tag..'���������� � ������ �� ���������! ����� 5 ������ ������ �����, ���� ����� ��������.', -1)
				wait(5000)
				if not directory_exists('moonloader\\' .. "\\resource\\skin") then os.execute("mkdir moonloader\\resource\\skin") end
				if not directory_exists('moonloader\\'.. "\\resource\\auto") then os.execute("mkdir moonloader\\resource\\auto") end
				wait(3000)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				sampAddChatMessage(tag..'����� ���� �������, ������� �������� ������. ������� �� ���������� ����� ����� � (~)', -1)
				sampAddChatMessage(tag..'��������� ����� �������� ~ 5 �����.', -1)
				sampAddChatMessage(tag..'� ������, ���� �� ������� �� ���� �������� - ��������� ����� ������ � ������.', -1)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				sampAddChatMessage('',-1)
				local dlstatus 			= require('moonloader').download_status
				for i = 0, 311 do
					downloadUrlToFile("https://assets.open.mp/assets/images/skins/"..i..".png", 'moonloader\\' .. '\\resource\\skin\\skin_'..i..'.png', function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							print('�������� ���������� � ������: ' .. i .. '/311')
							if i == 311 then
								print('������ ��� � ���������� � ����, ��������.') 
							end
						end 
					end)
				end
				for i = 400,611 do
					downloadUrlToFile("https://gta-serv.ru/images/stories/vehicle/vehicle_".. i ..".jpg", 'moonloader\\' .. '\\resource\\auto\\vehicle_'..i..'.png', function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then
							print('�������� ���������� � ����: ' .. i-400 .. '/211')
						end
						if i==611 then print('�������� ������ ����-����...') print('�������� HTML-����� ...') end
					end)
				end
				downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/color.txt", 'moonloader\\' .. '\\resource\\skin\\color.txt', function(id, status)
					if status == dlstatus.STATUS_ENDDOWNLOADDATA then
						print('��������� ���������, ������ ������������ �������� �������� � ������� ������.')
						start_download = false
					end
				end)
			end)
		else array.windows.custom_ans.v = not array.windows.custom_ans.v end
	end
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
					
					KeyCap("TAB", (array.keys[plState]["TAB"] ~= nil), mimgui.ImVec2(40, 30)); mimgui.SameLine()
					KeyCap("Q", (array.keys[plState]["Q"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("W", (array.keys[plState]["W"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("E", (array.keys[plState]["E"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("R", (array.keys[plState]["R"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()


					KeyCap("RM", (array.keys[plState]["RKM"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("LM", (array.keys[plState]["LKM"] ~= nil), mimgui.ImVec2(30, 30))					


					KeyCap("Shift", (array.keys[plState]["Shift"] ~= nil), mimgui.ImVec2(40, 30)); mimgui.SameLine()
					KeyCap("A", (array.keys[plState]["A"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("S", (array.keys[plState]["S"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("D", (array.keys[plState]["D"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("C", (array.keys[plState]["C"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					
					KeyCap("Enter", (array.keys[plState]["Enter"] ~= nil), mimgui.ImVec2(65, 30))

					KeyCap("Ctrl", (array.keys[plState]["Ctrl"] ~= nil), mimgui.ImVec2(40, 30)); mimgui.SameLine()
					KeyCap("Alt", (array.keys[plState]["Alt"] ~= nil), mimgui.ImVec2(30, 30)); mimgui.SameLine()
					KeyCap("Space", (array.keys[plState]["Space"] ~= nil), mimgui.ImVec2(170, 30))

				mimgui.EndGroup()

				if not array.windows.recon_menu.v then
					array.windows.menu_in_recon.v = false
					keysync('off')
				end
			else
				mimgui.Text(u8"����� ������� �� ���� ���������\n���� ����� ��� � �� �������� � ���� ���������:\nQ - �������� �����, R - �������� � ������.\n������� ������� ��������������� ���������� ������...")
				auto_update_recon()
				if not array.windows.recon_menu.v then array.windows.menu_in_recon.v = false keysync('off') end
			end
		mimgui.End()
    end
)
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
function scanDirectory(path) -- ��������� ��� ����� � �����
    array.files_chatlogs = {}
	local lfs = require("lfs")
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local fullPath = path .. "/" .. file
            local attributes = lfs.attributes(fullPath)
            if attributes.mode == "directory" then
                local nestedFiles = scanDirectory(fullPath)
                for _, nestedFile in ipairs(nestedFiles) do table.insert(array.files_chatlogs, nestedFile) end
            else table.insert(array.files_chatlogs, file) end
        end
    end
    return array.files_chatlogs
end
--------=================== ������� ID � ����-���� =============------------------------
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