require 'lib.moonloader'
script_name 'AT Plus+' 
script_author 'Neon4ik'
script_properties("work-in-pause") 
local imgui = require 'imgui' 
local version = 1.5
local key = require 'vkeys'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
local u8 = encoding.UTF8 
local imadd = require 'imgui_addons'
local sampev = require 'lib.samp.events'
local dektor_window_state = imgui.ImBool(false)
local main_window_state = imgui.ImBool(false)
local secondary_window_state = imgui.ImBool(false)
local tag = '{DC143C}AdminTools Plus+: {FFFACD}'
local sw, sh = getScreenResolution()
local inicfg = require 'inicfg'
local offadmins = {}
local cfg = inicfg.load({
    settings = {
		delete_point = true,
		auto_al = false,
		auto_hello = false,
		hello_text = 'Здравствуйте, _, желаю Вам приятного администрирования :3',
		warning_report = false,
		count_warning = 3,
		mytext_warning_report = 'Уважаемые администраторы, срочно возьмите репорт!!!',
		number_report = 3,
		time_alogin = 2,
    },
	listNoResult = {
		'N.E.O.N',
		'LONDON',
		'Coder',
		'Kintzel.'
	},
}, 'AT//ATPlus.ini')
inicfg.save(cfg, 'AT//ATPlus.ini')

local buffer = {
	text_buffer = imgui.ImBuffer(16384),
	text_buffer2 = imgui.ImBuffer(1024),
	text_buffer3 = imgui.ImBuffer(1024),
	delete_admin = imgui.ImBuffer(1024),
	hello_admin = imgui.ImBuffer(u8(cfg.settings.hello_text),1024),
	mytext = imgui.ImBuffer(u8(cfg.settings.mytext_warning_report),1024)
}
local checkbox = {
	delete_point = imgui.ImBool(cfg.settings.delete_point),
	auto_hello = imgui.ImBool(cfg.settings.auto_hello),
	auto_al = imgui.ImBool(cfg.settings.auto_al),
	warning_report = imgui.ImBool(cfg.settings.warning_report),
}
local style_selected2 = imgui.ImInt(cfg.settings.count_warning-1)
local style_selected = imgui.ImInt(cfg.settings.number_report-2)
local selected_item = imgui.ImInt(2)
local selected_item2 = imgui.ImInt(0)
local style_selected3 = imgui.ImInt(cfg.settings.time_alogin-1)
local check_admin = imgui.ImInt(6) -- 7 дней
local makeadmin = {}
local kai = {}
local kick_admin = {} -- для открытия /offadmins
local kick_admin2 = {} -- выбранные в программе
local newlvl = 1
local SendKai = -1
local offadmins = {}
local topadm = {}


sampRegisterChatCommand('update_atp', function()
	local dlstatus = require('moonloader').download_status
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminToolsPlus.lua", thisScript().path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(tag .. 'Скрипт обновлен.', -1)
			thisScript():reload()
		end
	end)
end)
function main()
	while not sampIsPlayerConnected() do wait(1000) end
	local dlstatus = require('moonloader').download_status
    downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminToolsPlus.ini", "moonloader//config//AT//AdminToolsPlus.ini", function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local AdminToolsPlus = inicfg.load(nil, 'moonloader//config//AT//AdminToolsPlus.ini')
			if AdminToolsPlus then
				if tonumber(AdminToolsPlus.script.version) > version then
					update = true
					sampAddChatMessage(		  '========================================================',-1)
					sampAddChatMessage(tag .. 'Обнаружено обновление! Чтобы обновиться вводи /update_atp', -1)
					sampAddChatMessage(		  '========================================================',-1)
				end
			end
		end
	end)

	sampAddChatMessage(tag .. 'Скрипт инициализирован. Активация: /atp', -1)
	while true do
		wait(5000)
		if isGamePaused() then AFK = true
		else AFK = false end
	end
end
function imgui.OnDrawFrame()
	if not main_window_state.v and not secondary_window_state.v and not dektor_window_state.v then
		imgui.Process = false
		showCursor(false,false)
	end
	if dektor_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.3), sh * 0.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("AdminTools+", dektor_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imgui.Checkbox(u8'Авто-напоминание /al', checkbox.auto_al) then
			cfg.settings.auto_al = not cfg.settings.auto_al
			save()
		end
		if cfg.settings.auto_al then
			imgui.Text(u8'Кол-во минут без /alogin')
			imgui.SameLine()
			imgui.PushItemWidth(50)
			if imgui.Combo("##time", style_selected3, {'1','2', '3', '4', '5', '6'}, 7) then
				cfg.settings.time_alogin = style_selected3.v + 1
			end
			imgui.PopItemWidth()
		end
		if imgui.Checkbox(u8'Приветствие администраторов', checkbox.auto_hello) then
			cfg.settings.auto_hello = not cfg.settings.auto_hello
			save()
		end
		if cfg.settings.auto_hello then
			if imgui.InputText('##autohello', buffer.hello_admin) then
				cfg.settings.hello_text = u8:decode(buffer.hello_admin.v)
				save()
			end
			imgui.TextWrapped(u8'Ник администратора обозначается символом _')
		end
		if imgui.Checkbox(u8'Напоминание о репорте в /a', checkbox.warning_report) then
			cfg.settings.warning_report = not cfg.settings.warning_report
			save()
		end
		if cfg.settings.warning_report then
			imgui.Text(u8'Кол-во повторов сообщения: ')
			imgui.SameLine()
			imgui.PushItemWidth(50)
			if imgui.Combo("##selected2", style_selected2, {'1', '2', '3', '4', '5'}, 6) then
				cfg.settings.count_warning = style_selected2.v + 1
				save()
			end
			imgui.PopItemWidth()
			imgui.Text(u8'Триггер (кол-во репортов): ')
			imgui.SameLine()
			imgui.PushItemWidth(50)
			if imgui.Combo("##selected", style_selected, {'2' ,'3', '4', '5', '6'}, 6) then
				cfg.settings.number_report = style_selected.v + 2
				save()
			end
			imgui.PopItemWidth()
			if imgui.InputText('##mytext', buffer.mytext) then
				cfg.settings.mytext_warning_report = u8:decode(buffer.mytext.v)
				save()
			end
		end
		if imgui.Button(u8'Подвести итоги недели', imgui.ImVec2(230,24)) then
			main_window_state.v = not main_window_state.v
			dektor_window_state.v = not dektor_window_state.v
		end
		imgui.Text(u8'/cb - проверить игрока на блокировку')
		imgui.Text(u8'/cadm - статистика администратора')
		imgui.End()
	end
	if main_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.3), sh * 0.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Автоматическое подведение итогов.", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imadd.ToggleButton('##antipoint', checkbox.delete_point) then
			cfg.settings.delete_point = not cfg.settings.delete_point
			save()
		end
		imgui.SameLine()
		imgui.Text(u8'Удалять точки в центре ников')
		imgui.InputTextMultiline("##", buffer.text_buffer, imgui.ImVec2(270, 300))
		if #topadm == 0 or #offadmins == 0 then
			imgui.Text(u8'Пробито администраторов - ' .. #offadmins)
			imgui.Text(u8('Пробито баллов у ' .. #topadm .. ' администраторов'))
			if imgui.Button(u8'Пробить информацию о администраторах', imgui.ImVec2(270,24)) then
				if not sampIsDialogActive() then
					lua_thread.create(function()
						buffer.text_buffer.v = u8'Не пытайтесь закрыть диалоги досрочно\nВаш интернет может не успевать\nпрогружать диалоги, скрипт сам все\nзакроет!\nДанный текст пропадет сам\nСразу после того\nКак сверит всю информацию\nВ ином случае перезайдите в игру..\nи повторите процедуру.'
						sampSendChat('/topadm')
						while not sampIsDialogActive(2232) do wait(100) end
						while sampIsDialogActive(2232) do sampCloseCurrentDialogWithButton(0) wait(100) end
						sampSendChat('/offadmins')
						buffer.text_buffer.v = ''
					end)
				end

			end
		end
		if #offadmins ~= 0 and #topadm ~= 0 then
			if imgui.Button(u8'Выбрать диапазон баллов', imgui.ImVec2(270, 25)) then
				if #offadmins ~= 0 and #topadm ~= 0 then
					secondary_window_state.v = not secondary_window_state.v
				else sampAddChatMessage(tag .. 'Вы ещё не прошлись по спискам администраторов.', -1)
				end
			end
		end
		if imgui.Button(u8'Пробить срок выдачи админ-прав', imgui.ImVec2(270, 25)) then
			if #kick_admin2 ~= 0 and not sampIsDialogActive() then
				lua_thread.create(function()
					sampAddChatMessage(tag .. 'Запускаю проверку на новеньких администраторов', -1)
					sampAddChatMessage(tag .. 'Не закрывайте диалоги!', -1)
					kick_admin = {} -- массив снятых адм
					for k,v in pairs(kick_admin2) do
						local name_admin = string.gsub(v, '=(.+)', '')
						local name_admin = string.gsub(name_admin, '%s', '')
						while sampIsDialogActive() do wait(0) sampCloseCurrentDialogWithButton(0) end
						sampSendChat('/ap')
						sampSendDialogResponse(1034, 1, 1)
						sampAddChatMessage(tag .. 'Проверяю: '..name_admin,-1)
						sampSendDialogResponse(6020, 1, 1, name_admin)
						while not sampIsDialogActive(0) do wait(0) end
						while sampIsDialogActive(0) do wait(0) end
					end
					wait(1000)
					for i = 1, #kick_admin do --genetica [15 -> 16 LVL] 93 балла
						-- да колхоз, но я просидел больше 2 часов но так и не додумался как сделать чтобы он удалял слово "баллов", стандартный (.+) просто все удалял
						buffer.text_buffer.v = string.gsub(buffer.text_buffer.v, u8('\n'..kick_admin[i] .. ' %[(%d+) %-%> (%d+) LVL%] (%d+) баллов'), u8'')
						buffer.text_buffer.v = string.gsub(buffer.text_buffer.v, u8('\n'..kick_admin[i] .. ' %[(%d+) %-%> (%d+) LVL%] (%d+) балла'), u8'')
						buffer.text_buffer.v = string.gsub(buffer.text_buffer.v, u8('\n'..kick_admin[i] .. ' %[(%d+) %-%> (%d+) LVL%] (%d+) балл'), u8'')
						buffer.text_buffer.v = string.gsub(buffer.text_buffer.v, u8('\n'..kick_admin[i] .. ' %[(%d+) LVL%] (%d+) баллов'), u8'')
						buffer.text_buffer.v = string.gsub(buffer.text_buffer.v, u8('\n'..kick_admin[i] .. ' %[(%d+) LVL%] (%d+) балла'), u8'')
						buffer.text_buffer.v = string.gsub(buffer.text_buffer.v, u8('\n'..kick_admin[i] .. ' %[(%d+) LVL%] (%d+) балл'), u8'')
						for k,v in pairs(makeadmin) do
							if v:find(kick_admin[i]) then
								table.remove(makeadmin, k)
								sampAddChatMessage(tag .. 'Администратор {A9A9A9}' .. kick_admin[i] ..' {FFFFFF}встал на пост менее ' .. check_admin.v + 1 .. ' дней назад - удален из списка снятий/предов', -1)
							end
						end
						for k,v in pairs(kai) do
							if v:find(kick_admin[i]) then
								table.remove(kai, k)
							end
						end
					end
					secondary_window_state.v = false
					main_window_state.v = true
					kick_admin2 = {}
				end)
			else sampAddChatMessage('Вы никого не снимали с поста', -1) end
		end
		if imgui.Button(u8'Сбросить', imgui.ImVec2(135,25)) then
			offadmins = {}
			kick_admin = {}
			kick_admin2 = {}
			buffer.text_buffer.v = u8''
			topadm = {}
			kai = {}
			makeadmin = {}
			sampAddChatMessage(tag .. 'Сброшено.', -1)
		end
		imgui.SameLine()
		if imgui.Button(u8'Перезагрузить', imgui.ImVec2(125,25)) then
			thisScript():reload()
		end
		imgui.Separator()
		imgui.Text(u8'После выставления всех параметров.')
		if imgui.Button(u8'Взаимодействие с Каем.', imgui.ImVec2(270, 25)) then
			buffer.text_buffer.v = ''
			for k, v in pairs(kai) do
				buffer.text_buffer.v = buffer.text_buffer.v .. u8(v) .. '\n'
			end
			kai = {} -- обнуляем настройки
		end
		if imgui.Button(u8'Отобразить новые уровни', imgui.ImVec2(270, 25)) then
			buffer.text_buffer.v = ''
			for k, v in pairs(makeadmin) do
				v = string.gsub(v, '  ', ' ') -- удаляем лишние пробелы если они имеются.
				buffer.text_buffer.v = buffer.text_buffer.v .. v .. '\n'
			end
		end
		if buffer.text_buffer.v:find('/makeadmin') then
			if imgui.Button(u8'Выдать уровни.', imgui.ImVec2(270, 25)) and not sampIsDialogActive() then
				sampAddChatMessage(tag .. 'Начинаю выдавать уровни...', -1)
				printStyledString('process ...', #(textSplit(buffer.text_buffer.v, '\n')) * 3000, 7)
				lua_thread.create(function()
					for k, v in pairs(textSplit(buffer.text_buffer.v, '\n')) do
						local v = string.gsub(v, '%s', ' ') -- удаляем лишние пробелы если они имеются.
						while sampIsDialogActive() do wait(0) end
						sampAddChatMessage(tag .. 'Выдаю уровень администратору: {7CFC00}' .. v,-1)
						sampSendChat(v)
						wait(3000)
					end
				end)
				makeadmin = {} -- обнуляем настройки
			end
		end
        imgui.End()
    end
	if secondary_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Настройки", secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.Text(u8'От:              До:')
		imgui.PushItemWidth(50)
		imgui.InputText('##1', buffer.text_buffer2)
		imgui.PopItemWidth()
		imgui.SameLine()
		imgui.SetCursorPosX(75)
		imgui.PushItemWidth(50)
		imgui.InputText('##2', buffer.text_buffer3)
		imgui.PopItemWidth()
		if imgui.Button(u8'Сохранить', imgui.ImVec2(115, 25)) then
			if (newlvl == 0 and SendKai ~= 0) or (SendKai == 0 and newlvl ~= 0) then
				sampAddChatMessage(tag .. 'Вы не можете исключить игрока из конференции, не сняв его с поста, и аналогично.', -1)
			elseif #(buffer.text_buffer2.v)~=0 then -- проверка введен ли промежуток баллов
				if #(buffer.text_buffer.v) == 0 then -- если в основном меню ничего нет - вывести доп инфу
					local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					buffer.text_buffer.v = u8('@all Итоги недели\nПодвёл итоги многоуважаемый ' .. sampGetPlayerNickname(myid) .. '\nПри поддержке: AdminTools by N.E.O.N\nВ соответствии с еженедельной нормой\nПроводим реформацию состава.\n\n') 
				end
				if #(buffer.text_buffer3.v)==0 then buffer.text_buffer3.v = '3000' end
				if tonumber(buffer.text_buffer2.v) < tonumber(buffer.text_buffer3.v)  then
					buffer.text_buffer.v = buffer.text_buffer.v .. '===================================\n'
					if newlvl == 0 then
						buffer.text_buffer.v = (buffer.text_buffer.v .. '[' .. buffer.text_buffer2.v  .. ' - '.. buffer.text_buffer3.v .. u8' баллов] = Сняты с поста\n')
					elseif newlvl == 'Skip' then
						buffer.text_buffer.v = (buffer.text_buffer.v .. '[' .. buffer.text_buffer2.v  .. ' - '.. buffer.text_buffer3.v .. u8' баллов] = ' .. SendKai .. word_ball(nil, SendKai) .. '\n')
					else
						buffer.text_buffer.v = (buffer.text_buffer.v .. '[' .. buffer.text_buffer2.v  .. ' - '.. buffer.text_buffer3.v .. u8' баллов] = +' .. newlvl .. u8' LVL и ' .. SendKai .. word_ball(nil, SendKai) .. '\n')
					end
					buffer.text_buffer.v = buffer.text_buffer.v .. '===================================\n'
					for _,k in pairs(topadm) do
						local nick, peremball = string.match(k, '(.+) = (.+)') -- находим ник и баллы
						local peremball = tonumber(string.sub(peremball, 1, -4))   -- удаляем числа после точки 1235.11
						if (tonumber(buffer.text_buffer2.v) <= peremball) and (peremball <= tonumber(buffer.text_buffer3.v)) then
							for k,v in pairs(offadmins) do
								peremlvl = tonumber(string.match(string.sub(v,-3), '%d[%d.,]*'))
								local v = string.gsub(v, '=(%d+)', '')
								nick = string.gsub(nick, '=(%d+)', '')
								if string.sub(nick,1,-2) == ' ' then
									nick = string.sub(nick,1,-2)
								end
								local v = string.gsub(v, '= (%d+)', '')
								nickv = string.gsub(v,'=(.+)', '')
								for h,m in pairs(cfg.listNoResult) do -- если администратор есть в списке исключений - удаляем его
									if nickv:match(m) then
										k,v = nil, nil
									end
								end
								if v then
									if (string.gsub(v, '%=(.+)', '') == nick) or (string.gsub(v, '%=(.+)', '') == string.sub(nick,1,-1)) then -- записываем в конфиг информацию о Кае then -- записываем в конфиг информацию о Кае
										for d,s in pairs(kai) do -- защита от повторного открытия списка, удаляем повторяшек
											if s:find(nick) then
												kai[d], kai[s] = nil, nil
											end
										end
										for d,s in pairs(makeadmin) do -- защита от повторного открытия списка, удаляем повторяшек
											if s:find(nick) then
												makeadmin[d], makeadmin[s] = nil, nil
											end
										end
										local nick = string.gsub(nick, '%s', '') -- удаляем лишние точки
										local nick_kai = nick -- даем значение нику для Кая
										if cfg.settings.delete_point then
											local nick_1 = string.sub(nick, 1,1) -- узнаем первый символ ника
											local nick_2 = string.sub(nick,-1) -- узнаем последний символ ника
											nick_kai = string.gsub(string.sub(string.sub(nick, 2), 1, -2), '%.', '') -- удаляем точки в центре ника.
											nick_kai = (nick_1 .. nick_kai .. nick_2) -- присваиваем новое значение
										end
										local nick_kai = string.gsub(nick_kai, '%s','')
										local nick_kai = string.gsub(nick_kai, '=(.+)','')
										if SendKai == 0 then
											kai[#kai + 1] = 'Кай кик ' .. nick_kai
											kick_admin2[#kick_admin2 + 1] = nick
										elseif SendKai == 1 then
											kai[#kai + 1] = 'Кай пред ' .. nick_kai
											kick_admin2[#kick_admin2 + 1] = nick
										elseif SendKai == 2 then
											kai[#kai + 1] = 'Кай пред 2 ' .. nick_kai
											kick_admin2[#kick_admin2 + 1] = nick
										elseif SendKai == -1 then
											kai[#kai + 1] = 'Кай снять пред ' .. nick_kai
										elseif SendKai == -2 then
											kai[#kai + 1] = 'Кай снять пред 2 ' .. nick_kai
										end
										if tonumber(peremlvl) ~= 18 then -- Записываем информацию о /makeadmin и выводим инфу
											
											if newlvl ~= 'Skip' then
												if selected_item.v == 0 then
													makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' 0'
													buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl ..' LVL' .. '] ' .. peremball .. word_ball(peremball)
												elseif tonumber(newlvl) + tonumber(peremlvl) > 18 then
													local newnewlvl = tonumber(newlvl) - 1
													if tonumber(newnewlvl) + tonumber(peremlvl) > 18 then
														newnewlvl = tonumber(newnewlvl) - 1
														makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' ' .. (tonumber(peremlvl) + tonumber(newnewlvl))
														buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl .. ' -> ' .. peremlvl+newnewlvl.. ' LVL' .. '] ' .. peremball .. word_ball(peremball)
													end
													makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' ' .. (tonumber(peremlvl) + tonumber(newnewlvl))
													buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl .. ' -> ' .. peremlvl+newnewlvl.. ' LVL' .. '] ' .. peremball .. word_ball(peremball)
												else
													makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' ' .. (tonumber(peremlvl) + tonumber(newlvl))
													buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl .. ' -> ' .. peremlvl+newlvl.. ' LVL' .. '] ' .. peremball .. word_ball(peremball)
												end
											else
												buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl .. ' LVL' .. '] ' .. peremball ..word_ball(peremball)
											end
										else
											buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl ..' LVL'.. '] ' .. peremball .. word_ball(peremball)
										end
									end
								end
							end
						end
					end
					if tonumber(buffer.text_buffer2.v) == 0 then -- если 0 баллов (т.е администратора вообще нет в /topadm) то делаем те же действия
						for k,v in pairs(offadmins) do
							local nick = string.gsub(string.gsub(v,'=(.+)', ''), '%s', '')
							for d,s in pairs(topadm) do
								local s = string.gsub(string.gsub(s, '= (.+)', ''), '%s', '')
								if nick == s then 
									a = true 
								end 
							end 
							for s,m in pairs(cfg.listNoResult) do 
								if nick == m then 
									a = true  
								end
							end
							if a then 
								a = nil 
							else
								local nick_kai = nick
								if cfg.settings.delete_point then 
									nick_1 = string.sub(v, 1, 1) 
									nick_2 = string.sub(v,-1) 
									nick_kai = string.gsub(string.sub(string.sub(v, 2), 1, -2), '%.', '') 
									nick_kai = (nick_1 .. nick_kai .. nick_2) 
								end 
								if SendKai == 0 then 
									kai[#kai + 1] = 'Кай кик ' .. nick_kai 
									makeadmin[#makeadmin + 1] = ('/makeadmin ' .. v .. ' 0') 
									kick_admin2[#kick_admin2 + 1] = v
								end
								local lvl = string.match(v, '=(.+)') -- number
								local lvl = string.gsub(lvl, '%s', '') -- delete point
								buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. lvl ..' LVL]' .. u8' 0 баллов' .. '\n'
							end
						end 
					end
				else sampAddChatMessage(tag .. 'Вы не указали количество баллов', -1) end
			else sampAddChatMessage(tag .. 'Данные введены некорректно.', -1) end
		end
		imgui.Text(u8'Уровень.')
		imgui.PushItemWidth(115)
		if imgui.Combo('##newlvl', selected_item, {u8'Снять', u8'Оставить', u8'+1 уровень', u8'+2 уровня', u8'+3 уровня'}, 5) then
			if selected_item.v == 0 then
				newlvl = 0
				selected_item2.v = 2
				SendKai = 0
			elseif selected_item.v == 1 then
				newlvl = 'Skip'
			elseif selected_item.v == 2 then
				newlvl = 1
			elseif selected_item.v == 3 then
				newlvl = 2
			elseif selected_item.v == 4 then
				newlvl = 3
			end
		end
		imgui.PopItemWidth()
		imgui.Text(u8'Кай.')
		imgui.PushItemWidth(115)
		if imgui.Combo('##newpred', selected_item2, {u8'Снять 1 пред', u8'Снять 2 преда', u8'Кикнуть', u8'Выдать 1 пред', u8'Выдать 2 преда', u8'Ничего'}, 6) then
			if selected_item2.v == 0 then
				SendKai = -1
			elseif selected_item2.v == 1 then
				SendKai = -2
			elseif selected_item2.v == 2 then
				SendKai = 0
			elseif selected_item2.v == 3 then
				SendKai = 1
			elseif selected_item2.v == 4 then
				SendKai = 2
			elseif selected_item2.v == 5 then
				SendKai = 'Skip'
			end
		end
		imgui.PopItemWidth()
		imgui.PushItemWidth(50)
		imgui.Text(u8'Дни.')
		imgui.Combo('##option_days', check_admin, {'1', '2', '3', '4', '5', '6', '7'}, 7)
		if imgui.IsItemHovered() then
			imgui.BeginTooltip() -- подсказка при наведении на кнопку
			imgui.Text(u8'Если отыграно меньше данного кол-ва дней (включительно) - убрать из списка.\nДопустим те, кто встали недавно, в список не попадут.')
			imgui.EndTooltip()
		end
		imgui.PopItemWidth()
		imgui.Text(u8'Добавить искл: /newadm')
		imgui.Text(u8'Удалить искл: /deladm')
		if imgui.Button(u8'Вывести исключения') then
			for i = 2, #cfg.listNoResult do
				sampAddChatMessage(cfg.listNoResult[i],-1)
			end
		end
		imgui.End()
	end
end


function sampev.onServerMessage(color,text)
	if not AFK then
		if cfg.settings.auto_hello and text:match("%[A%] Администратор (.+)%[(%d+)%] %(%d+ level%) авторизовался в админ панели") then
			local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			local _, autorizate_admin = text:match('%[A%] Администратор (.+)%[(%d+)%]')
			if tonumber(autorizate_admin) ~= myid then
				lua_thread.create(function()
					while sampIsDialogActive() do wait(100) end
					sampSendChat('/a ' .. string.gsub(cfg.settings.hello_text, '_', sampGetPlayerNickname(autorizate_admin)))
				end)
			end
			sampAddChatMessage(text, 0xafafaf)
		end
		if cfg.settings.auto_al and text:match('%[A%] (.+)%((%d+)%) не авторизовался как администратор уже (.+) минут%(ы%)') then --[A] Dirty_DeSanta(76) не авторизовался как администратор уже 1 минут(ы)
			local _, autorizate_admin, time = text:match('%[A%] (.+)%((%d+)%) не авторизовался как администратор уже (.+) минут%(ы%)')
			if tonumber(time) >= cfg.settings.time_alogin then
				lua_thread.create(function()
					while sampIsDialogActive() do wait(100) end
					sampSendChat('/ans ' .. autorizate_admin .. ' Здравствуйте! Вы забыли ввести /alogin!')
					sampSendChat('/ans ' .. autorizate_admin .. ' Введите команду /alogin и свой пароль, пожалуйста.')
				end)
				sampAddChatMessage(text, 0xafafaf)
			end
		end 
		if cfg.settings.warning_report and text:match('Жалоба #(%d) | ') then
			local number_report = tonumber(text:match('Жалоба #(%d) | '))
			if number_report >= cfg.settings.number_report then
				lua_thread.create(function()
					while sampIsDialogActive() do wait(100) end
					for i = 0, cfg.settings.count_warning-1 do
						sampSendChat('/a ' .. cfg.settings.mytext_warning_report)
						wait(2500)
					end
				end)
				sampAddChatMessage(text,-1)
			end
		end
	end
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
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if button1 == '{f76663}X' and imgui.Process then	-- окно /offadmins - администратор
		lua_thread.create(function()
			local text = textSplit(text, '\n')
			if text[27] then -- защита от крашей
				--{FFFFFF}Дата выдачи:				{63BD4E}[2023-10-02 23:09:30]. {FFFFFF}
				local year, month, day = text[27]:match('{63BD4E}%[(%d+)%-(%d+)%-(%d+) (%d%d):(%d%d):(%d%d)%]')
				local days = daysPassed(year, month, day)
				if days < check_admin.v + 1 then
					kick_admin[#kick_admin+1] = title
				end
				wait(100)
				sampCloseCurrentDialogWithButton(0)
			end
		end)
	elseif dialogId == 4829 and imgui.Process then
		local text = textSplit(text, '\n')
		for k,v in pairs(text) do
			local v = string.sub(v, 9)
			if v:match('Оффлайн') then v = string.sub(v, 1, -16) end -- адаптируемся под условия
			if v:match('Онлайн') then v = string.sub(v, 1, -15) end -- адаптируемся под условия
			if #v > 0 and v ~= 'Ник	{ffffff}Уровень администратора	' and v~='<<< Назад' and v ~= 'Далее >>>' then
				local v = string.sub(v, 1, -2)
				local lvl1 = string.sub(v, -2) -- считываем первое значение уровня
				if string.sub(v, -2) == '1' then -- если администратор выше 10 уровня - изменить настройки
					v = string.sub(v, 1, -2)
					lvl2 = string.sub(v, -2)
				end
				if lvl2 then lvl = lvl1 .. lvl2 -- Конкретный, точный лвл
				else lvl = lvl1 end
				local v = string.sub(v, 1, -3) 
				for d,s in pairs(offadmins) do -- защита от повторного открытия списка, удаляем повторяшек
					if s == (v .. '=' .. lvl) then
						offadmins[d], offadmins[s] = nil, nil
					end
				end
				offadmins[#offadmins + 1] =  (v .. '=' .. lvl) -- записываем информацию о админе в конфиг
				local lvl, lvl1, lvl2 = nil, nil, nil
			end
			if text[#text-1]:match('Далее >>>') then sampSendDialogResponse(4829, 1, #text-3)
			else sampCloseCurrentDialogWithButton(0) end
		end
	elseif dialogId == 2232 and imgui.Process then
		topadm = {} -- создаем массив
		local text = textSplit(text, '\n')
		for k,v in pairs(text) do
			if #v > 0 and v ~= '{ffffff}Ник	{ffffff}Уровень администратора	{ffffff}Баллов' then
				local v = string.sub(v, 10)
				if string.sub(v, -1) == '0' or string.sub(v, -1) == '1' or string.sub(v, -1) == '2' or string.sub(v, -1) == '3' or string.sub(v, -1) == '4' or string.sub(v, -1) == '5' or string.sub(v, -1) == '6' or string.sub(v, -1) == '7' or string.sub(v, -1) == '8' or string.sub(v, -1) == '9' then
					v = string.sub(v,2) -- удаляем информацию о LVLах, для этого у нас есть /offadmins
				end
				local v = string.sub(v, 2)
				if string.sub(v, 1, 1) == ' ' then -- удаляем лишний пробел
					v = string.sub(v, 2)
				end
				local ballov = string.match(v, '%S+$') -- узнаем кол-во баллов
				if ballov then
					v = string.sub(v, 1, -#ballov) -- удаляем из никнейма кол-во баллов
				end
				v = string.sub(v, 1, -5)
				topadm[#topadm + 1] = (v .. ' = ' .. ballov) -- записываем файл в конфигурацию
			end
		end
	end
end
function textSplit(str, delim, plain)
    local tokens, pos, plain = {}, 1, not (plain == false)
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end
function word_ball(number, kai) -- определяем как правильно писать баллов или балла
	if not kai then
		if number % 10 == 0 then return u8' баллов\n'
		elseif number % 10 == 1 and number % 100 ~= 11 then return u8" балл\n"
		elseif 2 <= number and number % 10 <= 4 and (number % 100 < 10 or number % 100 >= 20) then return u8" балла\n"
		else return u8" баллов\n" end
	else
		if kai ~= -1 and kai ~= 1 then return u8' преда'
		else return u8' пред' end
	end
end

function save()
	inicfg.save(cfg, 'AT//ATPlus.ini')	
end
sampRegisterChatCommand('deladm', function(param)
	if #param >= 3 then
		for k, v in pairs(cfg.listNoResult) do
			if cfg.listNoResult[k] == param then
				cfg.listNoResult[k] = nil
				save()
				sampAddChatMessage(tag .. 'Выбранный вами администратор ' .. param .. ' был успешно удалено из списка', -1)
				a = true
				break
			else    
				a = false
			end
		end
		if not a then
			sampAddChatMessage(tag .. 'Такого администратора в списке нет.', -1)
			a = nil
		end
	end
end)
sampRegisterChatCommand('newadm', function(param)
	if #param >= 3 then
		for k, v in pairs(cfg.listNoResult) do
			if cfg.listNoResult[k] == param then
				sampAddChatMessage(tag .. 'Выбранный вами администратор - ' .. param .. ' уже имеется в списке.' , -1)
				a = true
				break
			else    
				a = false
			end
		end
		if not a then
			cfg.listNoResult[#cfg.listNoResult + 1] = param
			save()
			sampAddChatMessage(tag .. 'Выбранный вами администратор - ' .. param .. ' был успешно добавлен в исключения', -1)
			a = nil
		end
	end
end)
sampRegisterChatCommand('atp', function()
	dektor_window_state.v = not dektor_window_state.v
	imgui.Process = dektor_window_state.v
end)
sampRegisterChatCommand('cban', function(param)
	if sampIsDialogActive() or #param == 0 then return false end
	sampSendChat('/ap')
	sampSendDialogResponse(1034, 1, 8)
	sampSendDialogResponse(6030, 1, 1, param)
end)
sampRegisterChatCommand('cadm', function(param)
	if sampIsDialogActive() or #param == 0 then return false end
	sampSendChat('/ap')
	sampSendDialogResponse(1034, 1, 1)
	sampSendDialogResponse(6020, 1, 1, param)
end)
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
